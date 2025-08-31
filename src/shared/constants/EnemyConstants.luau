--!strict

-- EnemyConstants.luau
-- Centralized enemy configuration constants for Phase 1 linear movement

local EnemyConstants = {}

-- Enemy health and damage
EnemyConstants.BASE_HEALTH = 100
EnemyConstants.HEALTH_INCREMENT = 20  -- Per wave scaling

-- Movement constants
EnemyConstants.BASE_SPEED = 15  -- Studs per second
EnemyConstants.SPEED_INCREMENT = 2   -- Per wave scaling

-- Spawn timing and limits (Phase 1)
EnemyConstants.SPAWN_INTERVAL = 2.0  -- Seconds between enemy spawns
EnemyConstants.MAX_CONCURRENT_ENEMIES = 8  -- 5-10 range for Phase 1
EnemyConstants.ENEMIES_PER_WAVE = 5

-- Distance threshold for goal detection and cleanup
EnemyConstants.GOAL_DETECTION_DISTANCE = 3.0  -- Studs

-- Visual properties for enemy Parts
EnemyConstants.ENEMY_SIZE = Vector3.new(2, 2, 2)
EnemyConstants.ENEMY_COLOR = Color3.new(1, 0.2, 0.2)  -- Red-ish
EnemyConstants.ENEMY_MATERIAL = Enum.Material.Neon
EnemyConstants.ENEMY_TRANSPARENCY = 0.1

-- Enemy states enum
EnemyConstants.STATES = {
  SPAWNING = "Spawning",
  MOVING = "Moving", 
  REACHED_TARGET = "ReachedTarget",
  DESTROYED = "Destroyed",
}

return EnemyConstants