--Helper functions for displaying sprites
local sprites = {}
function sprites.draw(path, x, y, rotate) 
	rotate = rotate or 0;
	
	local options =
	{
		width = TILE_X,
		height = TILE_Y,
		numFrames = 1
	}
	
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
	
	--Ensure rot is around center only
	if (rotate ~= 0) then
		sprite.anchorX = 0.5
		sprite.anchorY = 0.5
		sprite.x = sprite.x + TILE_X / 2
		sprite.y = sprite.y + TILE_Y / 2
		sprite:rotate(rotate)
	else
		sprite.anchorX = 0
		sprite.anchorY = 0
	end	
	
	return sprite
end

return sprites