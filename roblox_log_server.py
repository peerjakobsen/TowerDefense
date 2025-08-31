"""
Local Logging Server for Roblox Studio

Implements Task 1 from .agent-os/specs/2025-08-31-local-logging-system/tasks.md

Endpoints:
- POST /log    → accept JSON log entries and write to server/client txt+json files
- POST /clear  → truncate/reset all log files
- GET  /status → return basic stats for each log file

Run:  python3 roblox_log_server.py
Requires: Flask (pip install Flask)
"""

from __future__ import annotations

import json
import os
import threading
import time
from collections import deque, defaultdict
from datetime import datetime
from typing import Any, Dict, Tuple

from flask import Flask, jsonify, make_response, request


HOST = "127.0.0.1"
PORT = 5000

# File paths (under logs/ directory)
LOG_DIR = "logs"
SERVER_TXT = os.path.join(LOG_DIR, "roblox-server-logs.txt")
SERVER_JSON = os.path.join(LOG_DIR, "roblox-server-logs.json")
CLIENT_TXT = os.path.join(LOG_DIR, "roblox-client-logs.txt")
CLIENT_JSON = os.path.join(LOG_DIR, "roblox-client-logs.json")

JSON_MAX_ENTRIES = 1000

# Rate limit settings (basic protection)
WINDOW_SHORT_SEC = 5
MAX_SHORT = 50  # max requests per 5 seconds per IP
WINDOW_LONG_SEC = 60
MAX_LONG = 300  # max requests per 60 seconds per IP


app = Flask(__name__)

# Simple CORS for local tools (not required for Roblox HttpService, but useful generally)
def _add_cors(resp):
    resp.headers["Access-Control-Allow-Origin"] = "*"
    resp.headers["Access-Control-Allow-Headers"] = "Content-Type"
    resp.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return resp


# Concurrency control for file writes
file_lock = threading.Lock()

# Rate limiting storage: per-IP deques of timestamps
rate_buckets: Dict[str, deque] = defaultdict(deque)
rate_lock = threading.Lock()


def _ensure_files():
    os.makedirs(LOG_DIR, exist_ok=True)
    for path in (SERVER_TXT, SERVER_JSON, CLIENT_TXT, CLIENT_JSON):
        if not os.path.exists(path):
            # Create empty files
            with open(path, "a", encoding="utf-8"):
                pass


def _now_iso() -> str:
    return datetime.utcnow().isoformat(timespec="seconds") + "Z"


def _format_human(level: str, context: str, message: str, client_id: str | None) -> str:
    ts = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    if context == "Client":
        who = f"Client:{client_id or 'Unknown'}"
    else:
        who = "Server"
    return f"[{ts}] [{level}] [{who}] {message}"


def _append_line(path: str, line: str) -> None:
    with open(path, "a", encoding="utf-8") as f:
        f.write(line + "\n")


def _append_json(path: str, obj: Dict[str, Any]) -> None:
    # NDJSON format: one JSON per line
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(obj, ensure_ascii=False) + "\n")


def _rotate_json(path: str, max_entries: int = JSON_MAX_ENTRIES) -> None:
    try:
        with open(path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        if len(lines) > max_entries:
            # keep last N
            tail = lines[-max_entries:]
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(tail)
    except FileNotFoundError:
        # Recreate on demand
        with open(path, "a", encoding="utf-8"):
            pass


def _validate_log_payload(payload: Dict[str, Any]) -> Tuple[Dict[str, Any], str | None]:
    # Normalize and validate
    if not isinstance(payload, dict):
        return {}, "Invalid JSON body"

    level = str(payload.get("level", "")).upper()
    message = payload.get("message")
    context = payload.get("context")
    data = payload.get("data")
    client_id = payload.get("client_id")

    if level not in {"DEBUG", "INFO", "WARN", "ERROR"}:
        return {}, "Invalid or missing 'level' (DEBUG|INFO|WARN|ERROR)"
    if not isinstance(message, str) or message == "":
        return {}, "Missing 'message' string"
    if context not in {"Server", "Client"}:
        return {}, "Invalid or missing 'context' (Server|Client)"
    if data is not None and not isinstance(data, (dict, list, str, int, float, bool)):
        return {}, "'data' must be JSON-serializable"
    if context == "Client" and (client_id is None or client_id == ""):
        return {}, "Missing required field: client_id for client context logs"

    return {
        "level": level,
        "message": message,
        "context": context,
        "data": data,
        "client_id": client_id,
    }, None


def _rate_limited(ip: str) -> bool:
    now = time.time()
    with rate_lock:
        q = rate_buckets[ip]
        # Drop stale entries
        while q and (now - q[0]) > WINDOW_LONG_SEC:
            q.popleft()
        # Check windows
        count_long = len(q)
        count_short = sum(1 for t in q if (now - t) <= WINDOW_SHORT_SEC)
        if count_long >= MAX_LONG or count_short >= MAX_SHORT:
            return True
        q.append(now)
        return False


@app.before_request
def before_request():
    # Basic rate limiting for write endpoints
    if request.method in ("POST",):
        ip = request.remote_addr or "unknown"
        if _rate_limited(ip):
            resp = make_response(jsonify({"error": "Too Many Requests"}), 429)
            return _add_cors(resp)


@app.after_request
def after_request(resp):
    return _add_cors(resp)


@app.route("/log", methods=["POST", "OPTIONS"])
def log_endpoint():
    if request.method == "OPTIONS":
        return _add_cors(make_response("", 204))

    try:
        payload = request.get_json(force=True, silent=False)
    except Exception:
        return _add_cors(make_response(jsonify({"error": "Invalid JSON"}), 400))

    parsed, err = _validate_log_payload(payload)
    if err:
        return _add_cors(make_response(jsonify({"error": err}), 400))

    timestamp = _now_iso()
    entry: Dict[str, Any] = {
        "timestamp": timestamp,
        "level": parsed["level"],
        "message": parsed["message"],
        "context": parsed["context"],
        "data": parsed.get("data"),
    }
    if parsed["context"] == "Client":
        entry["client_id"] = parsed.get("client_id") or "Unknown"

    human = _format_human(
        parsed["level"], parsed["context"], parsed["message"], parsed.get("client_id")
    )

    try:
        with file_lock:
            if parsed["context"] == "Server":
                _append_line(SERVER_TXT, human)
                _append_json(SERVER_JSON, entry)
                _rotate_json(SERVER_JSON)
            else:
                _append_line(CLIENT_TXT, human)
                _append_json(CLIENT_JSON, entry)
                _rotate_json(CLIENT_JSON)
    except OSError as e:
        return _add_cors(make_response(jsonify({"error": f"File error: {e}"}), 500))

    # Console feedback
    print(f"[{timestamp}] accepted {parsed['context']} {parsed['level']}: {parsed['message']}")

    return jsonify({"status": "ok"})


@app.route("/clear", methods=["POST", "OPTIONS"])
def clear_endpoint():
    if request.method == "OPTIONS":
        return _add_cors(make_response("", 204))

    try:
        with file_lock:
            for path in (SERVER_TXT, SERVER_JSON, CLIENT_TXT, CLIENT_JSON):
                with open(path, "w", encoding="utf-8"):
                    pass
    except OSError as e:
        return _add_cors(make_response(jsonify({"error": f"File error: {e}"}), 500))

    print("[status] cleared all log files")
    return jsonify({"status": "cleared"})


def _file_stats(path: str) -> Dict[str, Any]:
    try:
        size = os.path.getsize(path)
        mtime = os.path.getmtime(path)
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            line_count = sum(1 for _ in f)
        return {
            "exists": True,
            "bytes": size,
            "lines": line_count,
            "modified": datetime.fromtimestamp(mtime).isoformat(timespec="seconds"),
        }
    except FileNotFoundError:
        return {"exists": False, "bytes": 0, "lines": 0, "modified": None}


@app.route("/status", methods=["GET"]) 
def status_endpoint():
    stats = {
        "server_txt": _file_stats(SERVER_TXT),
        "server_json": _file_stats(SERVER_JSON),
        "client_txt": _file_stats(CLIENT_TXT),
        "client_json": _file_stats(CLIENT_JSON),
    }
    return jsonify({"status": "ok", "files": stats})


def _startup_banner():
    print("Roblox Local Log Server running")
    print(f"Bind: http://{HOST}:{PORT}")
    print("Endpoints: POST /log, POST /clear, GET /status")


if __name__ == "__main__":
    _ensure_files()
    _startup_banner()
    # threaded=True for concurrent handling
    app.run(host=HOST, port=PORT, threaded=True)
