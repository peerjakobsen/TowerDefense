--!strict

-- Enemy.luau
-- Core Enemy ModuleScript that handles individual enemy behavior,
-- linear movement logic, and state management for Phase 1

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local EnemyConstants = require(ReplicatedStorage.Constants.EnemyConstants)
local LogService = require(ReplicatedStorage.LogService)

export type EnemyState = "Spawning" | "Moving" | "ReachedTarget" | "Destroyed"

export type EnemyData = {
  id: string,
  spawnPosition: Vector3,
  targetPosition: Vector3,
  currentPosition: Vector3,
  health: number,
  maxHealth: number,
  speed: number,
  state: EnemyState,
  direction: Vector3,
  distanceToTarget: number,
}

local Enemy = {}
Enemy.__index = Enemy

-- Constructor: Create a new enemy instance
function Enemy.new(spawnPosition: Vector3, targetPosition: Vector3): EnemyData
  local self = setmetatable({}, Enemy) :: any

  -- Generate unique ID for this enemy
  self.id = HttpService:GenerateGUID(false)
  
  -- Position data
  self.spawnPosition = spawnPosition
  self.targetPosition = targetPosition
  self.currentPosition = spawnPosition
  
  -- Health system
  self.maxHealth = EnemyConstants.BASE_HEALTH
  self.health = self.maxHealth
  
  -- Movement system
  self.speed = EnemyConstants.BASE_SPEED
  self.direction = (targetPosition - spawnPosition).Unit
  self.distanceToTarget = (targetPosition - spawnPosition).Magnitude
  
  -- Initial state
  self.state = EnemyConstants.STATES.SPAWNING
  
  LogService.info("Enemy spawned", {
    id = self.id,
    spawn = spawnPosition,
    target = targetPosition,
    health = self.health,
    speed = self.speed,
  })
  
  return self
end

-- Health management methods
function Enemy:TakeDamage(damage: number): boolean
  if self.state == EnemyConstants.STATES.DESTROYED then
    return false -- Already destroyed, ignore damage
  end
  
  self.health = math.max(0, self.health - damage)
  
  LogService.info("Enemy took damage", {
    id = self.id,
    damage = damage,
    healthRemaining = self.health,
    maxHealth = self.maxHealth,
  })
  
  -- Check for death
  if self.health <= 0 then
    self:_SetState(EnemyConstants.STATES.DESTROYED)
    LogService.info("Enemy destroyed by damage", {
      id = self.id,
    })
    return true -- Enemy was destroyed
  end
  
  return false -- Enemy survived
end

function Enemy:GetHealth(): number
  return self.health
end

function Enemy:GetMaxHealth(): number
  return self.maxHealth
end

function Enemy:IsAlive(): boolean
  return self.state ~= EnemyConstants.STATES.DESTROYED and self.health > 0
end

-- Movement and update logic
function Enemy:Update(deltaTime: number): boolean
  if not self:IsAlive() then
    return false -- Dead enemies don't move
  end
  
  -- Handle state transitions
  if self.state == EnemyConstants.STATES.SPAWNING then
    self:_SetState(EnemyConstants.STATES.MOVING)
  end
  
  -- Only move if in MOVING state
  if self.state ~= EnemyConstants.STATES.MOVING then
    return true -- Still alive but not moving
  end
  
  -- Calculate movement for this frame
  local movementDistance = self.speed * deltaTime
  local newPosition = self.currentPosition + (self.direction * movementDistance)
  
  -- Update current distance to target
  self.distanceToTarget = (self.targetPosition - newPosition).Magnitude
  
  -- Check if we've reached the target (within threshold)
  if self.distanceToTarget <= EnemyConstants.GOAL_DETECTION_DISTANCE then
    -- Snap to exact target position
    self.currentPosition = self.targetPosition
    self.distanceToTarget = 0
    self:_SetState(EnemyConstants.STATES.REACHED_TARGET)
    
    LogService.info("Enemy reached target", {
      id = self.id,
      finalPosition = self.currentPosition,
    })
    
    return true -- Still alive, just reached target
  end
  
  -- Normal movement update
  self.currentPosition = newPosition
  
  return true -- Still alive and moving
end

-- Position and state tracking methods
function Enemy:GetPosition(): Vector3
  return self.currentPosition
end

function Enemy:GetState(): EnemyState
  return self.state
end

function Enemy:GetSpeed(): number
  return self.speed
end

function Enemy:GetDistanceToTarget(): number
  return self.distanceToTarget
end

function Enemy:GetDirection(): Vector3
  return self.direction
end

function Enemy:GetId(): string
  return self.id
end

-- Private helper for state changes with logging
function Enemy:_SetState(newState: EnemyState)
  local oldState = self.state
  self.state = newState
  
  LogService.info("Enemy state changed", {
    id = self.id,
    oldState = oldState,
    newState = newState,
    position = self.currentPosition,
  })
end

-- Cleanup and destruction logic
function Enemy:Destroy()
  if self.state == EnemyConstants.STATES.DESTROYED then
    return -- Already destroyed
  end
  
  LogService.info("Enemy destroyed", {
    id = self.id,
    finalPosition = self.currentPosition,
    finalHealth = self.health,
    finalState = self.state,
  })
  
  -- Set to destroyed state
  self.state = EnemyConstants.STATES.DESTROYED
  self.health = 0
  
  -- Clean up any references (for future Part management)
  -- This will be expanded in Task 3 when we add visual Parts
end

return Enemy