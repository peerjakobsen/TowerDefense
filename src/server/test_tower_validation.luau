--!strict

-- Test script for MapService.IsValidTowerPosition validation
-- This script tests various positions to ensure tower placement validation works correctly

local MapService = require(script.Parent.services.MapService)
local LogService = require(game.ReplicatedStorage.Shared.LogService)

LogService.info("Starting MapService tower placement validation tests...")

-- Initialize MapService first
if not MapService.IsInitialized() then
	MapService.Initialize()
end

-- Test positions
local testPositions = {
	-- Valid positions (should return true)
	{ position = Vector3.new(0, 1, 10), expected = true, description = "Center of map, outside corridor" },
	{ position = Vector3.new(-20, 1, 5), expected = true, description = "Left side, outside corridor" }, 
	{ position = Vector3.new(20, 1, -8), expected = true, description = "Right side, outside corridor" },
	{ position = Vector3.new(-40, 1, 15), expected = true, description = "Near spawn, outside corridor" },
	{ position = Vector3.new(40, 1, -15), expected = true, description = "Near goal, outside corridor" },
	
	-- Invalid positions - outside map bounds (should return false)
	{ position = Vector3.new(60, 1, 0), expected = false, description = "Outside east boundary" },
	{ position = Vector3.new(-60, 1, 0), expected = false, description = "Outside west boundary" },
	{ position = Vector3.new(0, 1, 60), expected = false, description = "Outside north boundary" },
	{ position = Vector3.new(0, 1, -60), expected = false, description = "Outside south boundary" },
	
	-- Invalid positions - within path corridor (should return false)
	{ position = Vector3.new(0, 1, 0), expected = false, description = "Center of path corridor" },
	{ position = Vector3.new(0, 1, 1), expected = false, description = "1 stud from path center" },
	{ position = Vector3.new(0, 1, 2), expected = false, description = "Exactly at corridor edge" },
	{ position = Vector3.new(-10, 1, -1), expected = false, description = "Left side, within corridor" },
	{ position = Vector3.new(30, 1, 1.5), expected = false, description = "Right side, within corridor" },
	
	-- Edge cases - just outside corridor (should return true)
	{ position = Vector3.new(0, 1, 2.1), expected = true, description = "Just outside corridor (north)" },
	{ position = Vector3.new(0, 1, -2.1), expected = true, description = "Just outside corridor (south)" },
}

LogService.info("Running tower placement validation tests", { totalTests = #testPositions })

local passedTests = 0
local failedTests = 0

-- Run all tests
for i, test in ipairs(testPositions) do
	local result = MapService.IsValidTowerPosition(test.position)
	local passed = result == test.expected
	
	if passed then
		passedTests += 1
		LogService.info("✓ Test " .. i .. " PASSED", {
			description = test.description,
			position = test.position,
			expected = test.expected,
			actual = result
		})
	else
		failedTests += 1
		LogService.error("✗ Test " .. i .. " FAILED", {
			description = test.description,
			position = test.position,
			expected = test.expected,
			actual = result
		})
	end
end

-- Test summary
LogService.info("Tower placement validation test results", {
	totalTests = #testPositions,
	passed = passedTests,
	failed = failedTests,
	successRate = (passedTests / #testPositions) * 100
})

if failedTests == 0 then
	LogService.info("🎉 All tower placement validation tests PASSED!")
else
	LogService.warn("⚠️ Some tower placement validation tests FAILED. Check implementation.")
end