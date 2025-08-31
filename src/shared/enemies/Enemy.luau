--!strict

-- Enemy.luau
-- Core Enemy ModuleScript that handles individual enemy behavior,
-- linear movement logic, and state management for Phase 1

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local EnemyConstants = require(ReplicatedStorage.Shared.constants.EnemyConstants)
local LogService = require(ReplicatedStorage.Shared.LogService)

export type EnemyState = "Spawning" | "Moving" | "ReachedTarget" | "Destroyed"

export type Enemy = {
	id: string,
	spawnPosition: Vector3,
	targetPosition: Vector3,
	currentPosition: Vector3,
	maxHealth: number,
	health: number,
	speed: number,
	direction: Vector3,
	distanceToTarget: number,
	totalDistance: number,
	state: EnemyState,
	part: Part?,
	milestoneLogged: {[string]: boolean},
	
	TakeDamage: (self: Enemy, damage: number) -> boolean,
	GetHealth: (self: Enemy) -> number,
	GetMaxHealth: (self: Enemy) -> number,
	IsAlive: (self: Enemy) -> boolean,
	Update: (self: Enemy, deltaTime: number) -> boolean,
	GetPosition: (self: Enemy) -> Vector3,
	GetState: (self: Enemy) -> EnemyState,
	GetSpeed: (self: Enemy) -> number,
	GetDistanceToTarget: (self: Enemy) -> number,
	GetDirection: (self: Enemy) -> Vector3,
	GetId: (self: Enemy) -> string,
	Destroy: (self: Enemy) -> (),
	_SetState: (self: Enemy, newState: EnemyState) -> (),
	_CreatePart: (self: Enemy) -> (),
	_UpdatePartPosition: (self: Enemy) -> (),
	_DestroyPart: (self: Enemy) -> (),
	_LogMovementMilestones: (self: Enemy) -> (),
}

local Enemy = {}
Enemy.__index = Enemy

-- Workspace management
local function getOrCreateEnemiesFolder(): Folder
	local enemiesFolder = workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = "Enemies"
		enemiesFolder.Parent = workspace
		LogService.info("Created Enemies folder in workspace")
	end
	return enemiesFolder
end

-- Constructor: Create a new enemy instance
function Enemy.new(spawnPosition: Vector3, targetPosition: Vector3): Enemy
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
	self.totalDistance = self.distanceToTarget
	
	-- Movement milestone tracking
	self.milestoneLogged = {}
	
	-- Initial state
	self.state = EnemyConstants.STATES.SPAWNING
	
	-- Create visual Part representation
	self:_CreatePart()
	
	LogService.info("Enemy spawned with Part", {
		id = self.id,
		spawn = spawnPosition,
		target = targetPosition,
		health = self.health,
		speed = self.speed,
		partCreated = self.part ~= nil,
	})
	
	return self
end

-- Health management methods
function Enemy:TakeDamage(damage: number): boolean
  local self = self :: Enemy
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
    self:_SetState(EnemyConstants.STATES.DESTROYED :: EnemyState)
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
  local self = self :: Enemy
  if not self:IsAlive() then
    return false -- Dead enemies don't move
  end
  
  -- Handle state transitions
  if self.state == EnemyConstants.STATES.SPAWNING then
    self:_SetState(EnemyConstants.STATES.MOVING :: EnemyState)
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
    self:_SetState(EnemyConstants.STATES.REACHED_TARGET :: EnemyState)
    
    -- Synchronize Part position to exact target
    self:_UpdatePartPosition()
    
    LogService.info("Enemy reached target", {
      id = self.id,
      finalPosition = self.currentPosition,
    })
    
    return true -- Still alive, just reached target
  end
  
  -- Normal movement update
  self.currentPosition = newPosition
  
  -- Log movement milestones for educational debugging
  self:_LogMovementMilestones()
  
  -- Synchronize Part position with logical position
  self:_UpdatePartPosition()
  
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

-- Part management methods
function Enemy:_CreatePart()
	local enemiesFolder = getOrCreateEnemiesFolder()
	
	-- Create the enemy Part with visual styling from EnemyConstants
	local part = Instance.new("Part")
	part.Name = "Enemy_" .. self.id
	part.Size = EnemyConstants.ENEMY_SIZE
	part.Color = EnemyConstants.ENEMY_COLOR
	part.Material = EnemyConstants.ENEMY_MATERIAL
	part.Transparency = EnemyConstants.ENEMY_TRANSPARENCY
	part.Position = self.currentPosition
	part.Shape = Enum.PartType.Block
	part.Anchored = true -- Enemies don't use physics, we control movement
	part.CanCollide = false -- Don't interfere with other game objects
	part.Parent = enemiesFolder
	
	-- Store Part reference
	self.part = part
	
	-- Add CollectionService tag for efficient querying
	CollectionService:AddTag(part, "Enemy")
	
	LogService.info("Enemy Part created", {
		id = self.id,
		partName = part.Name,
		position = part.Position,
		size = part.Size,
		color = part.Color,
	})
end

function Enemy:_UpdatePartPosition()
	if self.part and self.part.Parent then
		self.part.Position = self.currentPosition
	end
end

function Enemy:_DestroyPart()
	if self.part and self.part.Parent then
		local part = self.part
		
		-- Remove CollectionService tag
		CollectionService:RemoveTag(part, "Enemy")
		
		LogService.info("Enemy Part destroyed", {
			id = self.id,
			partName = part.Name,
			finalPosition = part.Position,
		})
		
		-- Clear reference first, then destroy
		local selfAny = self :: any
		selfAny.part = nil
		part:Destroy()
	end
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
	
	-- Clean up Part representation
	self:_DestroyPart()
	
	-- Set to destroyed state
	self.state = EnemyConstants.STATES.DESTROYED
	self.health = 0
end

-- Movement milestone logging for educational debugging
function Enemy:_LogMovementMilestones()
	if self.totalDistance == 0 then
		return -- Avoid division by zero
	end
	
	local progressPercent = ((self.totalDistance - self.distanceToTarget) / self.totalDistance) * 100
	
	-- Log milestone when enemy starts moving (5% progress)
	if progressPercent >= 5 and not self.milestoneLogged["started"] then
		self.milestoneLogged["started"] = true
		LogService.info("Enemy movement started", {
			id = self.id,
			progress = string.format("%.1f%%", progressPercent),
			position = self.currentPosition,
			speed = self.speed,
			distanceRemaining = self.distanceToTarget,
		})
	end
	
	-- Log halfway point milestone (50% progress)
	if progressPercent >= 50 and not self.milestoneLogged["halfway"] then
		self.milestoneLogged["halfway"] = true
		LogService.info("Enemy reached halfway point", {
			id = self.id,
			progress = string.format("%.1f%%", progressPercent),
			position = self.currentPosition,
			distanceRemaining = self.distanceToTarget,
		})
	end
	
	-- Log near goal milestone (90% progress)  
	if progressPercent >= 90 and not self.milestoneLogged["nearGoal"] then
		self.milestoneLogged["nearGoal"] = true
		LogService.info("Enemy near goal", {
			id = self.id,
			progress = string.format("%.1f%%", progressPercent),
			position = self.currentPosition,
			distanceRemaining = self.distanceToTarget,
		})
	end
end

return Enemy