--Helper functions for displaying sprites
local sprites = {}

function sprites.drawSprite(displayGroup, path, x, y, w, h)
	local options =
	{
		width = w,
		height = h,
		numFrames = 1
	}
	
	local sheet = graphics.newImageSheet( path, options )
	
	local sequenceData =
	{
		name="default",
		start=1,
		count=1
	}
	
	local sprite = nil
	
	if (displayGroup == nil) then
		sprite = display.newSprite(sheet, sequenceData);
	else
		sprite = display.newSprite(displayGroup, sheet, sequenceData);
	end
	
	sprite.x = x
	sprite.y = y
	sprite.anchorX = 0
	sprite.anchorY = 0
	
	return sprite
end

function sprites.draw(path, x, y, rotate, displayGroup) 
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
	
	local sprite = nil
	
	if (displayGroup == nil) then
		sprite = display.newSprite(sheet, sequenceData);
	else
		sprite = display.newSprite(displayGroup, sheet, sequenceData);
	end
	
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