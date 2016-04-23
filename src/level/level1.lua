
local composer = require( "composer" )
local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local points = require("src.model.points")
local grids = require("src.model.grids")


local scene = composer.newScene()
local player = null


grid_level1 = grids.createGrid(15, 10)


function scene:create( event )
	
	local sceneGroup = self.view

	-- display a background image
	local background = display.newImageRect("res/map.png", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	sceneGroup:insert(1,  background )
	
	grid_level1[5][2] = 1
	grid_level1[5][3] = 1
	grid_level1[5][4] = 1
	grid_level1[6][4] = 1
	grid_level1[6][2] = 1
	grid_level1[9][4] = 1
	grid_level1[9][6] = 1
	grid_level1[6][9] = 1
	grid_level1[4][9] = 1
	
	local selectionGroup = display.newGroup()
	sceneGroup:insert(2, selectionGroup)
	
	local result = geometry.flood(grid_level1, points.createPoint(5, 5), 4)
	geometry.drawGrid(result, selectionGroup)
	
	player = sprites.draw("res/char_med.png", 4, 4)
	grid_level1.print()
	
	sceneGroup:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	local x = scene.view
	print("Tap at " .. event.x .. " " .. event.y)
	
	local sceneGroup = scene.view
	
	player.x = math.floor(event.x / TILE_X) * TILE_X
	player.y = math.floor(event.y / TILE_Y) * TILE_Y
	
	sceneGroup:remove(2)
	local selectionGroup = display.newGroup()
	sceneGroup:insert(2, selectionGroup)
	
	local result = geometry.flood(grid_level1, points.createPoint(math.floor(event.x / TILE_X) + 1, math.floor(event.y / TILE_Y) + 1) , 4)
	geometry.drawGrid(result, selectionGroup)
	
end



scene:addEventListener( "create", scene )

return scene