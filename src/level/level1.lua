local composer = require( "composer" )
local scene = composer.newScene()

TILE_X = 32
TILE_Y = 32

local game_manager = require("src.manager.game_manager")
game_manager.initialize(scene, "res/data/char_dat.json", "res/maps/small.csv", "res/maps/small.png", "res/data/team_dat.json", 1)

function scene:create( event )	
	game_manager.create(scene.view)
end

scene:addEventListener( "create", scene )

return scene