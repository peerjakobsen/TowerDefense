--!strict

-- Projectile.luau  
-- Projectile creation, movement, and impact system for tower combat.
-- Uses TweenService for smooth projectile movement and handles damage application.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local LogService = require(ReplicatedStorage.Shared.LogService)

-- Projectile configuration
local PROJECTILE_CONFIG = {
  speed = 50, -- studs per second
  size = Vector3.new(0.5, 0.5, 0.5),
  color = Color3.new(1, 1, 0), -- Yellow projectile
  hitDistance = 1.0, -- Distance threshold for hit detection
  timeoutDuration = 10.0, -- Max time before projectile self-destructs
}

export type Projectile = {
  id: string,
  startPosition: Vector3,
  targetPosition: Vector3,
  damage: number,
  part: Part?,
  tween: Tween?,
  targetEnemy: any?,
  
  FireAt: (self: Projectile, enemy: any) -> (),
  GetPosition: (self: Projectile) -> Vector3,
  GetId: (self: Projectile) -> string,
  Destroy: (self: Projectile) -> (),
  _CreatePart: (self: Projectile) -> (),
  _DestroyPart: (self: Projectile) -> (),
  _StartMovement: (self: Projectile) -> (),
  _OnHitTarget: (self: Projectile) -> (),
  _CheckHitDetection: (self: Projectile) -> boolean,
}

local Projectile = {}
Projectile.__index = Projectile

-- Workspace management
local function getOrCreateProjectilesFolder(): Folder
  local projectilesFolder = workspace:FindFirstChild("Projectiles")
  if not projectilesFolder then
    projectilesFolder = Instance.new("Folder")
    projectilesFolder.Name = "Projectiles"
    projectilesFolder.Parent = workspace
    LogService.info("Created Projectiles folder in workspace")
  end
  return projectilesFolder
end

-- Constructor: Create a new projectile instance
function Projectile.new(startPosition: Vector3, targetPosition: Vector3, damage: number): Projectile
  local self = setmetatable({}, Projectile) :: any
  
  -- Generate unique ID for this projectile
  self.id = HttpService:GenerateGUID(false)
  
  -- Position and damage data
  self.startPosition = startPosition
  self.targetPosition = targetPosition  
  self.damage = damage
  self.targetEnemy = nil
  
  -- Create visual representation
  self:_CreatePart()
  
  LogService.info("Projectile created", {
    id = self.id,
    startPosition = startPosition,
    targetPosition = targetPosition,
    damage = damage,
  })
  
  return self
end

-- Fire projectile at specific enemy target
function Projectile:FireAt(enemy: any)
  self.targetEnemy = enemy
  
  -- Update target position to current enemy position for better accuracy
  if enemy and enemy:IsAlive() then
    self.targetPosition = enemy:GetPosition()
  end
  
  -- Start projectile movement
  self:_StartMovement()
  
  LogService.info("Projectile fired at enemy", {
    id = self.id,
    targetId = enemy and enemy:GetId() or "unknown",
    targetPosition = self.targetPosition,
  })
end

-- Get current projectile position
function Projectile:GetPosition(): Vector3
  if self.part and self.part.Parent then
    return self.part.Position
  end
  return self.startPosition
end

-- Get projectile ID
function Projectile:GetId(): string
  return self.id
end

-- Destroy projectile and cleanup
function Projectile:Destroy()
  LogService.info("Projectile destroyed", {
    id = self.id,
    finalPosition = self:GetPosition(),
  })
  
  -- Stop any active tween
  if self.tween then
    self.tween:Cancel()
    self.tween = nil
  end
  
  -- Clean up visual representation
  self:_DestroyPart()
  
  -- Clear target reference
  self.targetEnemy = nil
end

-- Create visual projectile representation
function Projectile:_CreatePart()
  local projectilesFolder = getOrCreateProjectilesFolder()
  
  -- Create the projectile Part
  local part = Instance.new("Part")
  part.Name = "Projectile_" .. self.id
  part.Size = PROJECTILE_CONFIG.size
  part.Color = PROJECTILE_CONFIG.color
  part.Material = Enum.Material.Neon
  part.Position = self.startPosition
  part.Shape = Enum.PartType.Ball
  part.Anchored = true
  part.CanCollide = false
  part.Parent = projectilesFolder
  
  -- Store Part reference
  self.part = part
  
  LogService.info("Projectile Part created", {
    id = self.id,
    partName = part.Name,
    position = part.Position,
    size = part.Size,
  })
end

-- Destroy projectile visual representation
function Projectile:_DestroyPart()
  if self.part and self.part.Parent then
    local part = self.part
    
    LogService.info("Projectile Part destroyed", {
      id = self.id,
      partName = part.Name,
      finalPosition = part.Position,
    })
    
    -- Clear reference first, then destroy
    self.part = nil
    part:Destroy()
  end
end

-- Start projectile movement using TweenService
function Projectile:_StartMovement()
  if not self.part or not self.part.Parent then
    return
  end
  
  -- Calculate travel time based on distance and speed
  local distance = (self.targetPosition - self.startPosition).Magnitude
  local travelTime = distance / PROJECTILE_CONFIG.speed
  
  -- Create tween for smooth movement
  local tweenInfo = TweenInfo.new(
    travelTime,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.InOut,
    0, -- No repeats
    false, -- Don't reverse
    0 -- No delay
  )
  
  local tween = TweenService:Create(self.part, tweenInfo, {
    Position = self.targetPosition
  })
  
  self.tween = tween
  
  -- Connect to tween events
  tween.Completed:Connect(function()
    -- Check for hit when movement completes
    if self:_CheckHitDetection() then
      self:_OnHitTarget()
    end
    -- Clean up projectile after impact or miss
    self:Destroy()
  end)
  
  -- Start the movement
  tween:Play()
  
  -- Set up timeout cleanup
  Debris:AddItem(self.part, PROJECTILE_CONFIG.timeoutDuration)
  
  LogService.info("Projectile movement started", {
    id = self.id,
    travelTime = travelTime,
    distance = distance,
  })
end

-- Handle projectile hitting target
function Projectile:_OnHitTarget()
  if not self.targetEnemy or not self.targetEnemy:IsAlive() then
    LogService.info("Projectile hit position but target no longer valid", {
      id = self.id,
    })
    return
  end
  
  -- Apply damage to enemy using EnemyService
  local EnemyService = require(script.Parent.Parent.services.EnemyService)
  local damageApplied = EnemyService.DamageEnemy(self.targetEnemy:GetId(), self.damage)
  
  if damageApplied then
    LogService.info("Projectile hit target successfully", {
      id = self.id,
      targetId = self.targetEnemy:GetId(),
      damage = self.damage,
      targetHealth = self.targetEnemy:GetHealth(),
    })
  else
    LogService.warn("Projectile failed to apply damage", {
      id = self.id,
      targetId = self.targetEnemy:GetId(),
      damage = self.damage,
    })
  end
end

-- Check if projectile is close enough to target for hit detection
function Projectile:_CheckHitDetection(): boolean
  if not self.targetEnemy or not self.targetEnemy:IsAlive() then
    return false
  end
  
  local currentPosition = self:GetPosition()
  local targetPosition = self.targetEnemy:GetPosition()
  local distance = (currentPosition - targetPosition).Magnitude
  
  local hit = distance <= PROJECTILE_CONFIG.hitDistance
  
  LogService.info("Projectile hit detection", {
    id = self.id,
    distance = distance,
    hitThreshold = PROJECTILE_CONFIG.hitDistance,
    hit = hit,
  })
  
  return hit
end

return Projectile