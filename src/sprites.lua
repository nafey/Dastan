--Helper functions for displaying sprites
local sprites = {}
function sprites.draw(path, x, y, anchor_x, anchor_y) 
	anchor_x = anchor_x or 0;
	anchor_y = anchor_y or 0;
	
	local options =
	{
		width = TILE_X,
		height = TILE_Y,
		numFrames = 1
	}
	print(path)
	local sheet = graphics.newImageSheet( path, options )
	
	local sequenceData =
	{
		name="default",
		start=1,
		count=1
	}
	
	local sprite = display.newSprite(sheet, sequenceData);
	sprite.x = x * TILE_X
	sprite.y = y * TILE_Y
	sprite.anchorX = anchor_x;
	sprite.anchorY = anchor_y;
	
	return sprite
end

return sprites