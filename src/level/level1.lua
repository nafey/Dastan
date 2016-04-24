
local composer = require( "composer" )
local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local points = require("src.model.points")
local grids = require("src.model.grids")


local scene = composer.newScene()
local player = null
local move_result = null


grid_level1 = grids.createGrid(15, 10)


function scene:create( event )
	
	self.view.background = display.newGroup()
	self.view.selection = display.newGroup()
	self.view.player = display.newGroup()

	-- display a background image
	local bg = display.newImageRect("res/map.png", display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	self.view.background:insert(bg)
	
	grid_level1[5][2] = 1
	grid_level1[5][3] = 1
	grid_level1[5][4] = 1
	grid_level1[6][4] = 1
	grid_level1[6][2] = 1
	grid_level1[9][4] = 1
	grid_level1[9][6] = 1
	grid_level1[6][9] = 1
	grid_level1[4][9] = 1
		
	move_result = geometry.flood(grid_level1, points.createPoint(5, 5), 4)
	geometry.drawGrid(move_result, self.view.selection)
	
	player = sprites.draw("res/char_med.png", 4, 4, player)
	grid_level1.print()
	
	self.view.background:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	local x = math.floor(event.x / TILE_X)
	local y = math.floor(event.y / TILE_Y)
	
	if (move_result[x + 1][y + 1] ~= 0) then
		player.x = x * TILE_X
		player.y = y * TILE_Y
		
		scene.view.selection:removeSelf()
		scene.view.selection = display.newGroup()
		
		move_result = geometry.flood(grid_level1, points.createPoint(math.floor(event.x / TILE_X) + 1, math.floor(event.y / TILE_Y) + 1) , 4)
		geometry.drawGrid(move_result, scene.view.selection)
	end
end



scene:addEventListener( "create", scene )

return scene