
local composer = require( "composer" )

local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local levelloader = require("src.helper.levelloader")

local points = require("src.model.points")
local grids = require("src.model.grids")


local scene = composer.newScene()
local player = null
local move_result = null


local grid_level1 = grids.createGrid(15, 10)


function scene:create( event )
	local levelname =  "arena"
	
	local player_start_x = 7
	local player_start_y = 4
	
	-- The order here is important dont move it up or down as it affects the draw order
	self.view.background = display.newGroup()
	self.view.selection = display.newGroup()
	self.view.player = display.newGroup()

	-- display a background image
	local bg = display.newImageRect("res/maps/" .. levelname .. ".png", display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	self.view.background:insert(bg)
	
	grid_level1 = levelloader.loadlevel(levelname)
	
	move_result = geometry.flood(grid_level1, points.createPoint(player_start_x, player_start_y), 4)
	geometry.drawGrid(move_result, self.view.selection)
	
	player = sprites.draw("res/char_med.png", player_start_x - 1, player_start_y - 1, player)
	
	self.view.background:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	local x = math.floor(event.x / TILE_X)
	local y = math.floor(event.y / TILE_Y)
	
	if (move_result[x + 1][y + 1] ~= 0) then
		player.x = x * TILE_X
		player.y = y * TILE_Y
		
		-- Remove all the children sprites without removing the parent itself
		for i = 1, scene.view.selection.numChildren do
			scene.view.selection:remove(1)
		end
		
		move_result = geometry.flood(grid_level1, points.createPoint(math.floor(event.x / TILE_X) + 1, math.floor(event.y / TILE_Y) + 1) , 4)
		geometry.drawGrid(move_result, scene.view.selection)
	end
end



scene:addEventListener( "create", scene )

return scene