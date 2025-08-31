--!strict

-- EnemyTest.server.luau
-- Simple test script to validate Enemy module functionality

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Wait for shared modules to be available
repeat task.wait() until ReplicatedStorage:FindFirstChild("Shared")

local Enemy = require(ReplicatedStorage.Shared.enemies.Enemy)
local MapConstants = require(ReplicatedStorage.Shared.constants.MapConstants)
local LogService = require(ReplicatedStorage.Shared.LogService)

LogService.info("Starting Enemy module test")

-- Test 1: Create an enemy
local testEnemy = Enemy.new(
  MapConstants.SPAWN_POSITION,
  MapConstants.GOAL_POSITION
)

LogService.info("Test 1: Enemy created", {
  id = testEnemy:GetId(),
  position = testEnemy:GetPosition(),
  state = testEnemy:GetState(),
  health = testEnemy:GetHealth(),
  speed = testEnemy:GetSpeed(),
})

-- Test 2: Test health system
local damageTaken = testEnemy:TakeDamage(25)
LogService.info("Test 2: Damage test", {
  destroyed = damageTaken,
  health = testEnemy:GetHealth(),
  isAlive = testEnemy:IsAlive(),
})

-- Test 3: Test movement simulation (5 seconds)
LogService.info("Test 3: Starting 5-second movement simulation")

local startTime = tick()
local connection
connection = RunService.Heartbeat:Connect(function(deltaTime)
  local elapsed = tick() - startTime
  
  -- Update enemy
  local stillAlive = testEnemy:Update(deltaTime)
  
  -- Log every 1 second or when state changes
  if elapsed >= 5 or not stillAlive or testEnemy:GetState() ~= "Moving" then
    LogService.info("Movement update", {
      elapsed = elapsed,
      position = testEnemy:GetPosition(),
      state = testEnemy:GetState(),
      distanceToTarget = testEnemy:GetDistanceToTarget(),
      stillAlive = stillAlive,
    })
    
    -- End test after 5 seconds or enemy reaches target
    if elapsed >= 5 or testEnemy:GetState() == "ReachedTarget" then
      connection:Disconnect()
      testEnemy:Destroy()
      LogService.info("Enemy test completed successfully")
    end
  end
end)