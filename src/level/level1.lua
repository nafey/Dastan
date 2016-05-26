local composer = require( "composer" )
local scene = composer.newScene()

TILE_X = 32
TILE_Y = 32

local game_display = require("src.manager.game_display")
game_display.initialize(scene, "res/data/char_dat.json", "res/maps/small.csv", "res/maps/small.png", "res/data/team_dat.json", 1)

function enterFrame()
	game_display.frame()
end

function scene:create( event )	
	game_display.create(scene.view)
	Runtime:addEventListener("enterFrame", enterFrame)
end

scene:addEventListener( "create", scene )

return scene