--!strict

-- Tower.luau
-- Individual tower behavior entity that manages enemy detection, targeting, firing,
-- and state management for the tower defense game.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LogService = require(ReplicatedStorage.Shared.LogService)

-- Tower configuration
local TOWER_CONFIG = {
  damage = 25,
  range = 20,
  fireRate = 1.0, -- shots per second
  projectileSpeed = 50,
  cost = 100 -- for future economy system
}

-- Tower states
export type TowerState = "Idle" | "Targeting" | "Firing"

export type Tower = {
  id: string,
  position: Vector3,
  range: number,
  damage: number,
  fireRate: number,
  state: TowerState,
  part: Part?,
  currentTarget: any?, -- Enemy reference
  lastFireTime: number,
  lastUpdateTime: number?,
  updateConnection: RBXScriptConnection?,
  
  Initialize: (self: Tower) -> (),
  Update: (self: Tower, deltaTime: number) -> (),
  SetTarget: (self: Tower, enemy: any?) -> (),
  CanFire: (self: Tower) -> boolean,
  FireAt: (self: Tower, enemy: any) -> (),
  GetPosition: (self: Tower) -> Vector3,
  GetRange: (self: Tower) -> number,
  GetState: (self: Tower) -> TowerState,
  GetId: (self: Tower) -> string,
  Destroy: (self: Tower) -> (),
  _SetState: (self: Tower, newState: TowerState) -> (),
  _CreatePart: (self: Tower) -> (),
  _DestroyPart: (self: Tower) -> (),
  _FindTargetInRange: (self: Tower) -> any?,
  _IsTargetInRange: (self: Tower, enemy: any) -> boolean,
}

local Tower = {}
Tower.__index = Tower

-- Workspace management
local function getOrCreateTowersFolder(): Folder
  local towersFolder = workspace:FindFirstChild("Towers")
  if not towersFolder then
    towersFolder = Instance.new("Folder")
    towersFolder.Name = "Towers"
    towersFolder.Parent = workspace
    LogService.info("Created Towers folder in workspace")
  end
  return towersFolder
end

-- Constructor: Create a new tower instance
function Tower.new(position: Vector3): Tower
  local self = setmetatable({}, Tower) :: any
  
  -- Generate unique ID for this tower
  self.id = HttpService:GenerateGUID(false)
  
  -- Position and range
  self.position = position
  self.range = TOWER_CONFIG.range
  self.damage = TOWER_CONFIG.damage
  self.fireRate = TOWER_CONFIG.fireRate
  
  -- State management
  self.state = "Idle"
  self.currentTarget = nil
  self.lastFireTime = 0
  
  -- Create visual representation
  self:_CreatePart()
  
  LogService.info("Tower created", {
    id = self.id,
    position = position,
    range = self.range,
    damage = self.damage,
    fireRate = self.fireRate,
  })
  
  return self
end

-- Initialize tower and start update loop
function Tower:Initialize()
  -- Connect to update loop at 10 FPS (every 0.1 seconds)
  self.updateConnection = RunService.Heartbeat:Connect(function(deltaTime)
    -- Throttle updates to 10 FPS for performance
    local currentTime = tick()
    if currentTime - (self.lastUpdateTime or 0) >= 0.1 then
      self:Update(deltaTime)
      self.lastUpdateTime = currentTime
    end
  end)
  
  LogService.info("Tower initialized with update loop", {
    id = self.id,
    updateRate = "10 FPS",
  })
end

-- Main tower update logic
function Tower:Update(deltaTime: number)
  -- Skip updates if tower is destroyed
  if not self.part or not self.part.Parent then
    return
  end
  
  -- Try to find a target if we don't have one or current target is invalid
  if not self.currentTarget or not self:_IsTargetInRange(self.currentTarget) then
    self:SetTarget(self:_FindTargetInRange())
  end
  
  -- Update state based on target availability
  if self.currentTarget then
    if self.state == "Idle" then
      self:_SetState("Targeting")
    end
    
    -- Try to fire if we can
    if self:CanFire() then
      self:FireAt(self.currentTarget)
    end
  else
    -- No target available, go idle
    if self.state ~= "Idle" then
      self:_SetState("Idle")
    end
  end
end

-- Set the current target enemy
function Tower:SetTarget(enemy: any?)
  local oldTarget = self.currentTarget
  self.currentTarget = enemy
  
  if enemy and enemy ~= oldTarget then
    LogService.info("Tower acquired new target", {
      towerId = self.id,
      enemyId = enemy:GetId(),
      distance = (enemy:GetPosition() - self.position).Magnitude,
    })
  elseif not enemy and oldTarget then
    LogService.info("Tower lost target", {
      towerId = self.id,
      previousTargetId = oldTarget:GetId(),
    })
  end
end

-- Check if tower can fire (cooldown check)
function Tower:CanFire(): boolean
  local currentTime = tick()
  local timeSinceLastFire = currentTime - self.lastFireTime
  local fireInterval = 1.0 / self.fireRate -- Convert fire rate to interval
  
  return timeSinceLastFire >= fireInterval
end

-- Fire at the specified enemy
function Tower:FireAt(enemy: any)
  if not enemy then
    return
  end
  
  local currentTime = tick()
  self.lastFireTime = currentTime
  
  -- Temporarily set state to firing
  self:_SetState("Firing")
  
  -- Create and fire projectile
  local Projectile = require(script.Parent.Projectile)
  local projectile = Projectile.new(self.position, enemy:GetPosition(), self.damage)
  projectile:FireAt(enemy)
  
  LogService.info("Tower fired projectile", {
    towerId = self.id,
    targetId = enemy:GetId(),
    damage = self.damage,
    targetPosition = enemy:GetPosition(),
  })
  
  -- Return to targeting state immediately (state will be managed by update loop)
  if self.currentTarget then
    self:_SetState("Targeting")
  else
    self:_SetState("Idle")
  end
end

-- Get tower position
function Tower:GetPosition(): Vector3
  return self.position
end

-- Get tower range
function Tower:GetRange(): number
  return self.range
end

-- Get tower state
function Tower:GetState(): TowerState
  return self.state
end

-- Get tower ID
function Tower:GetId(): string
  return self.id
end

-- Destroy tower and cleanup
function Tower:Destroy()
  LogService.info("Tower destroyed", {
    id = self.id,
    position = self.position,
    finalState = self.state,
  })
  
  -- Disconnect update loop
  if self.updateConnection then
    self.updateConnection:Disconnect()
    self.updateConnection = nil
  end
  
  -- Clean up visual representation
  self:_DestroyPart()
  
  -- Clear target reference
  self.currentTarget = nil
end

-- Private helper for state changes
function Tower:_SetState(newState: TowerState)
  local oldState = self.state
  self.state = newState
  
  if oldState ~= newState then
    LogService.info("Tower state changed", {
      id = self.id,
      oldState = oldState,
      newState = newState,
    })
  end
end

-- Create visual tower representation
function Tower:_CreatePart()
  local towersFolder = getOrCreateTowersFolder()
  
  -- Create the tower Part with basic styling
  local part = Instance.new("Part")
  part.Name = "Tower_" .. self.id
  part.Size = Vector3.new(2, 3, 2) -- Simple tower shape
  part.Color = Color3.new(0.5, 0.5, 0.8) -- Light blue color
  part.Material = Enum.Material.SmoothPlastic
  part.Position = self.position
  part.Shape = Enum.PartType.Block
  part.Anchored = true
  part.CanCollide = true -- Towers should block placement and movement
  part.Parent = towersFolder
  
  -- Store Part reference
  self.part = part
  
  LogService.info("Tower Part created", {
    id = self.id,
    partName = part.Name,
    position = part.Position,
    size = part.Size,
  })
end

-- Destroy tower visual representation
function Tower:_DestroyPart()
  if self.part and self.part.Parent then
    local part = self.part
    
    LogService.info("Tower Part destroyed", {
      id = self.id,
      partName = part.Name,
      finalPosition = part.Position,
    })
    
    -- Clear reference first, then destroy
    self.part = nil
    part:Destroy()
  end
end

-- Find closest enemy within range using EnemyService integration
function Tower:_FindTargetInRange(): any?
  -- We'll need to get a reference to EnemyService - this will be injected by TowerService
  -- For now, return nil and integrate this in subtask 2.8
  local EnemyService = require(script.Parent.Parent.services.EnemyService)
  
  if not EnemyService.IsInitialized() then
    return nil
  end
  
  -- Get enemies within range using EnemyService helper
  local enemiesInRange = EnemyService.GetEnemiesInRadius(self.position, self.range)
  
  if #enemiesInRange == 0 then
    return nil
  end
  
  -- Find closest enemy using simple distance calculation
  local closestEnemy = nil
  local closestDistance = math.huge
  
  for _, enemy in ipairs(enemiesInRange) do
    -- Only target living enemies
    if enemy:IsAlive() then
      local distance = (enemy:GetPosition() - self.position).Magnitude
      if distance < closestDistance then
        closestDistance = distance
        closestEnemy = enemy
      end
    end
  end
  
  return closestEnemy
end

-- Check if target is still in range and valid
function Tower:_IsTargetInRange(enemy: any): boolean
  if not enemy or not enemy:IsAlive() then
    return false
  end
  
  local distance = (enemy:GetPosition() - self.position).Magnitude
  return distance <= self.range
end

-- Manual Test Scenarios for Tower Development and Validation
-- These functions can be called from the Roblox Studio Command Bar for testing

function Tower.RunManualTests()
  LogService.info("Tower: Starting manual test scenarios")
  
  -- Test 1: Tower creation and initialization
  Tower.TestTowerCreation()
  
  -- Test 2: Enemy detection and targeting
  Tower.TestEnemyDetection()
  
  -- Test 3: Firing rate and cooldown management
  Tower.TestFiringMechanics()
  
  -- Test 4: State management
  Tower.TestStateManagement()
  
  LogService.info("Tower: Manual test scenarios completed")
end

function Tower.TestTowerCreation()
  LogService.info("=== Tower Test 1: Creation and Initialization ===")
  
  -- Test tower creation
  local testPosition = Vector3.new(0, 10, 0)
  local tower = Tower.new(testPosition)
  
  LogService.info("Tower created", {
    id = tower:GetId(),
    position = tower:GetPosition(),
    range = tower:GetRange(),
    state = tower:GetState()
  })
  
  -- Test initialization
  tower:Initialize()
  LogService.info("Tower initialized with update loop")
  
  -- Cleanup immediately (no wait in ModuleScript)
  tower:Destroy()
  LogService.info("✓ Tower creation test completed")
end

function Tower.TestEnemyDetection()
  LogService.info("=== Tower Test 2: Enemy Detection ===")
  
  -- Create test tower
  local tower = Tower.new(Vector3.new(0, 10, 0))
  tower:Initialize()
  
  LogService.info("Testing enemy detection with tower at", tower:GetPosition())
  LogService.info("Tower range:", tower:GetRange(), "studs")
  
  -- Check if EnemyService has active enemies
  local EnemyService = require(script.Parent.Parent.services.EnemyService)
  if EnemyService.IsInitialized() then
    local activeEnemies = EnemyService.GetActiveEnemies()
    LogService.info("Active enemies for detection test", {
      count = #activeEnemies
    })
    
    -- Test detection for each enemy
    for i, enemy in ipairs(activeEnemies) do
      local distance = (enemy:GetPosition() - tower:GetPosition()).Magnitude
      local inRange = distance <= tower:GetRange()
      
      LogService.info("Enemy detection test " .. i, {
        enemyId = enemy:GetId(),
        enemyPosition = enemy:GetPosition(),
        distance = distance,
        inRange = inRange
      })
    end
  else
    LogService.warn("EnemyService not initialized - cannot test enemy detection")
  end
  
  -- Note: In real testing, let the tower run in Studio for manual observation
  LogService.info("Tower detection test completed - observe tower behavior in Studio")
  
  tower:Destroy()
  LogService.info("✓ Enemy detection test completed")
end

function Tower.TestFiringMechanics()
  LogService.info("=== Tower Test 3: Firing Mechanics ===")
  
  -- Create test tower
  local tower = Tower.new(Vector3.new(0, 10, 0))
  tower:Initialize()
  
  -- Test firing cooldown
  LogService.info("Testing firing cooldown system")
  LogService.info("Fire rate:", tower.fireRate, "shots per second")
  LogService.info("Expected cooldown:", 1.0 / tower.fireRate, "seconds")
  
  -- Test CanFire function
  local canFire1 = tower:CanFire()
  LogService.info("CanFire test 1", {
    canFire = canFire1,
    timeSinceLastFire = tick() - tower.lastFireTime
  })
  
  -- Simulate firing
  if canFire1 then
    tower.lastFireTime = tick()
    LogService.info("Simulated firing - updated lastFireTime")
  end
  
  -- Test again immediately (should be false due to cooldown)
  local canFire2 = tower:CanFire()
  LogService.info("CanFire test 2 (immediate)", {
    canFire = canFire2,
    timeSinceLastFire = tick() - tower.lastFireTime,
    expectedCooldown = 1.0 / tower.fireRate
  })
  
  tower:Destroy()
  LogService.info("✓ Firing mechanics test completed")
end

function Tower.TestStateManagement()
  LogService.info("=== Tower Test 4: State Management ===")
  
  -- Create test tower
  local tower = Tower.new(Vector3.new(0, 10, 0))
  LogService.info("Initial tower state:", tower:GetState())
  
  -- Test state transitions
  tower:_SetState("Targeting")
  LogService.info("After setting to Targeting:", tower:GetState())
  
  tower:_SetState("Firing")
  LogService.info("After setting to Firing:", tower:GetState())
  
  tower:_SetState("Idle")
  LogService.info("After setting to Idle:", tower:GetState())
  
  -- Test target management
  LogService.info("Testing target management")
  tower:SetTarget(nil)
  LogService.info("Set target to nil")
  
  -- Note: Cannot test with real enemy without EnemyService integration
  LogService.info("Target management test (limited without active enemies)")
  
  tower:Destroy()
  LogService.info("✓ State management test completed")
end

return Tower