local composer = require("composer")

local scene = composer.newScene()

function scene:create( event )	
	print("New Scene!!")
end

scene:addEventListener( "create", scene )

return scene