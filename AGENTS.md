# Repository Guidelines

## Project Structure & Module Organization
- Source: `src/client`, `src/server`, `src/shared` mapped via `default.project.json`.
- Place file: `TowerDefense.rbxlx` (built) and/or `TowerDefense.rbxl` (checked in for convenience).
- Entry points: `src/client/init.client.luau`, `src/server/init.server.luau`.
- Shared modules: `src/shared` (e.g., `Hello.luau`). Keep modules focused and reusable.

## Build, Test, and Development Commands
- Build place: `rojo build -o "TowerDefense.rbxlx"`
  - Exports the game to a binary place file for Studio.
- Live sync: `rojo serve`
  - Starts Rojo; open `TowerDefense.rbxlx` in Roblox Studio to sync code from `src/*` into services defined in `default.project.json`.
- Validate mapping: `rojo sourcemap default.project.json` (optional)
  - Prints source → instance mapping to spot misplacements.

## Coding Style & Naming Conventions
- Language: Luau. Prefer clear, idiomatic Roblox APIs.
- Indentation: tabs (match current files). Max line length ~100.
- Files: PascalCase for modules (`Hello.luau`), `init.client.luau` / `init.server.luau` for entry scripts.
- Functions/locals: lowerCamelCase; constants: UPPER_SNAKE_CASE.
- Services: `local Players = game:GetService("Players")` at file top.
- Organization: client-only under `src/client`, server-only under `src/server`, shared logic under `src/shared`.

## Testing Guidelines
- No framework is committed yet. Prefer TestEZ when adding tests.
- Location: `src/shared/tests` (or closest relevant folder).
- Naming: `*.spec.luau` (e.g., `Pathing.spec.luau`).
- Running: via a TestEZ runner in Studio or a CLI harness; aim for meaningful unit coverage on shared modules.

## Commit & Pull Request Guidelines
- Commits: imperative mood, small and scoped (e.g., `server: spawn waves sequentially`).
- Include context: what changed, why, and any migration notes.
- PRs: clear description, linked issues, steps to validate (Studio + Rojo), and screenshots/video for user-facing changes.
- Keep `default.project.json` and directory mappings in sync when moving files.

## Security & Configuration Tips
- Do not commit secrets or API keys; configure per-environment in Studio.
- Avoid using privileged services on the client; keep sensitive logic on the server.
- Large asset imports belong in Studio; reference via `ReplicatedStorage`/`ServerStorage` rather than shipping binaries in `src`.

