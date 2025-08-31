-- Local LogService module
-- Sends logs to Studio console and optional local HTTP server

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LogService = {}

-- Config
local DEFAULT_HTTP_URL = "http://127.0.0.1:5000/log"
local HTTP_URL = DEFAULT_HTTP_URL
local HTTP_ENABLED = true
local STUDIO_ONLY = true -- only send HTTP when running in Studio

-- HTTP behavior
local REQUEST_TIMEOUT_SECONDS = 5.0
local MAX_RETRIES = 3
local BACKOFF_BASE_SECONDS = 0.5
local BACKOFF_MAX_SECONDS = 30.0

-- Context
local IS_STUDIO = RunService:IsStudio()
local IS_SERVER = RunService:IsServer()
local CONTEXT = if IS_SERVER then "Server" else "Client"

-- Internal backoff on HTTP failures
local cooldownUntil = 0.0
local httpDisabledWarned = false

local function now()
	return os.clock()
end

local function getClientId(): string?
	if IS_SERVER then
		return nil
	end
	local lp = Players.LocalPlayer
	if lp then
		return tostring(lp.UserId)
	end
	-- Fallback label when LocalPlayer not ready yet
	return "LocalPlayer"
end

local function canSendHttp(): boolean
	if not HTTP_ENABLED then
		return false
	end
	if STUDIO_ONLY and not IS_STUDIO then
		return false
	end
	if not HttpService.HttpEnabled then
		if not httpDisabledWarned then
			warn("[LogService] HttpService is disabled. Remote logging is inactive.")
			httpDisabledWarned = true
		end
		return false
	end
	if cooldownUntil > 0 and now() < cooldownUntil then
		return false
	end
	return true
end

local function isoTimestampUtc(): string
	local dt = DateTime.now()
	local base = os.date("!%Y-%m-%dT%H:%M:%S", dt.UnixTimestamp)
	local ms = dt.UnixTimestampMillis % 1000
	return string.format("%s.%03dZ", base, ms)
end

local function backoffDelay(attempt: number): number
	local exp = BACKOFF_BASE_SECONDS * (2 ^ (attempt - 1))
	local jitter = math.random() * 0.2 -- up to 200ms jitter
	return math.min(exp + jitter, BACKOFF_MAX_SECONDS)
end

local function sendHttp(level: string, message: string, data: any?)
	if not canSendHttp() then
		return
	end

	local payload: any = {
		timestamp = isoTimestampUtc(),
		level = string.upper(level),
		message = message,
		context = CONTEXT,
	}
	if data ~= nil then
		payload.data = data
	end
	if CONTEXT == "Client" then
		payload.client_id = getClientId()
	end

	-- Validate client_id presence for client logs
	if CONTEXT == "Client" and (payload.client_id == nil or payload.client_id == "") then
		warn("[LogService] client_id missing for client log; skipping remote send.")
		return
	end

	spawn(function()
		local encoded = HttpService:JSONEncode(payload)
		local function attemptSend(attempt: number)
			if attempt > MAX_RETRIES then
				-- Apply a cooldown after exhausting retries
				cooldownUntil = now() + backoffDelay(MAX_RETRIES)
				return
			end

			local completed = false
			local timedOut = false
			local function scheduleRetry(delaySec: number)
				task.delay(delaySec, function()
					attemptSend(attempt + 1)
				end)
			end

			-- Timeout watcher
			task.delay(REQUEST_TIMEOUT_SECONDS, function()
				if completed then return end
				timedOut = true
				scheduleRetry(backoffDelay(attempt))
			end)

			local ok, resOrErr = pcall(function()
				return HttpService:RequestAsync({
					Url = HTTP_URL,
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json",
						["Accept"] = "application/json",
					},
					Body = encoded,
				})
			end)

			if timedOut then
				-- Late response; ignore. Retry already scheduled.
				return
			end
			completed = true

			if not ok then
				-- Network/transport error
				scheduleRetry(backoffDelay(attempt))
				return
			end

			local res = resOrErr
			if not res.Success then
				local code = tonumber(res.StatusCode) or 0
				if code == 429 then
					local retryAfter = 1.0
					local decodeOk, body = pcall(function()
						return HttpService:JSONDecode(res.Body or "")
					end)
					if decodeOk and typeof(body) == "table" and typeof(body.retry_after) == "number" then
						retryAfter = body.retry_after
					end
					scheduleRetry(math.max(retryAfter, backoffDelay(attempt)))
					return
				elseif code >= 500 and code < 600 then
					scheduleRetry(backoffDelay(attempt))
					return
				else
					-- 4xx other than 429: do not retry
					return
				end
			end

			-- Success: clear cooldown
			cooldownUntil = 0.0
		end

		-- initial attempt
		attemptSend(1)
	end)
end

local function emitConsole(level: string, message: string)
	local prefix = "[" .. level .. "] [" .. CONTEXT .. "] "
	if level == "WARN" then
		warn(prefix .. message)
	elseif level == "ERROR" then
		-- Use warn to avoid halting execution
		warn(prefix .. message)
	else
		print(prefix .. message)
	end
end

function LogService.log(level: string, message: any, data: any?)
	local lvl = string.upper(level)
	local msgStr = if typeof(message) == "string" then message else tostring(message)
	emitConsole(lvl, msgStr)
	sendHttp(lvl, msgStr, data)
end

function LogService.debug(message: any, data: any?)
	LogService.log("DEBUG", message, data)
end

function LogService.info(message: any, data: any?)
	LogService.log("INFO", message, data)
end

function LogService.warn(message: any, data: any?)
	LogService.log("WARN", message, data)
end

function LogService.error(message: any, data: any?)
	LogService.log("ERROR", message, data)
end

-- Configuration helpers
function LogService.setHttpUrl(url: string)
	HTTP_URL = url
end

function LogService.setHttpEnabled(enabled: boolean)
	HTTP_ENABLED = enabled
end

function LogService.setStudioOnly(enabled: boolean)
	STUDIO_ONLY = enabled
end

function LogService.isServer(): boolean
	return IS_SERVER
end

function LogService.isStudio(): boolean
	return IS_STUDIO
end

function LogService.context(): string
	return CONTEXT
end

return LogService
