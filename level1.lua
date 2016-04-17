
local composer = require( "composer" )
local scene = composer.newScene()

background = null
player = null

function scene:create( event )

	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	background = display.newImageRect( "background.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
	
	background:addEventListener("tap", myTapEvent)
	
	local options =
	{
		width = 32,
		height = 32,
		numFrames = 1
	}
	local sheet = graphics.newImageSheet( "char_med.png", options )
	
	local sequenceData =
	{
		name="default",
		start=1,
		count=1
	}
	
	player = display.newSprite(sheet, sequenceData);
	player.x = 160
	player.y = 240
	player.anchorX = 0;
	player.anchorY = 0;
	
	player.id = "player"

	
	sceneGroup:insert( background )
end

function myTapEvent(event)
	print("Tap at " .. event.x .. " " .. event.y)
	
	player.x = math.floor(event.x / 32) * 32
	player.y = math.floor(event.y / 32) * 32
	
	
end



scene:addEventListener( "create", scene )

return scene