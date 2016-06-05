local composer = require("composer")

local scene = composer.newScene()

function click()
	composer.gotoScene( "src.level.info" )
end

function scene:create( event )	
	local bg = display.newGroup()
	local img = display.newImageRect(bg,"res/maps/intro.jpg", 480, 320)
	img.anchorX = 0
	img.anchorY = 0
	
	bg:addEventListener("tap", click)
end

scene:addEventListener( "create", scene )

return scene