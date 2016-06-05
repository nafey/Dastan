local composer = require("composer")

local scene = composer.newScene()

function click()
	composer.gotoScene( "src.level.level1" )
end

function scene:create( event )	
	local bg = display.newGroup()
	local img = display.newImageRect(bg,"res/maps/info.png", 480, 320)
	img.anchorX = 0
	img.anchorY = 0
	
	bg:addEventListener("tap", click)
end

scene:addEventListener( "create", scene )

return scene