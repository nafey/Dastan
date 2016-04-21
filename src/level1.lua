
local composer = require( "composer" )
local sprites = require("src.sprites")
local movement = require("src.movement")
local point = require("src.points")
local grids = require("src.grids")


local scene = composer.newScene()

player = null


function scene:create( event )
	
	local sceneGroup = self.view

	-- display a background image
	local background = display.newImageRect( "res/map.png", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
		
	player = sprites.draw("res/char_med.png", 1, 2)
	
	grid = grids.createGrid(15, 10)
	
	movement.flood(grid, points.createPoint(4, 3), 1)

	sceneGroup:insert( background )
	sceneGroup:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	print("Tap at " .. event.x .. " " .. event.y)
	
	player.x = math.floor(event.x / TILE_X) * TILE_X
	player.y = math.floor(event.y / TILE_Y) * TILE_Y
end



scene:addEventListener( "create", scene )

return scene