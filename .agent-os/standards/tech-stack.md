# Roblox Game Tech Stack

## Context

Tech stack defaults for Roblox game development projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

## Core Tools
- Language: Luau (Roblox's typed Lua)
- Game Engine: Roblox Studio
- Development Environment: VS Code or Cursor
- Sync Tool: Rojo 7.4+ (live sync to Studio)
- Version Control: Git
- Project Structure: Simple src folder organization

## Development Workflow
- Primary Tool: `rojo serve` for live development
- Code Editor: VS Code/Cursor with Luau LSP
- Testing Environment: Roblox Studio
- Deployment: Roblox Studio publish
- NO build scripts needed for development
- NO complex testing frameworks required

## File Organization
- src/server - ServerScriptService scripts
- src/client - StarterPlayer/StarterPlayerScripts
- src/shared - ReplicatedStorage modules
- src/workspace - Workspace parts and models

## Project Configuration
- Rojo Project: default.project.json
- Git Ignore: .rbxl and .rbxlx files
- Development Server: rojo serve (port 34872)
- Studio Plugin: Rojo Studio Plugin for sync

## Dependencies (Optional)
- Package Manager: None required (keep it simple)
- External Packages: Only when absolutely necessary
- Focus: Learn core Roblox APIs first

## Development Philosophy
- Start simple, add complexity gradually
- Use built-in Roblox services
- Avoid over-engineering
- Focus on game mechanics over frameworks
- Learn by building and experimenting