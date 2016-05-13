local points = require("src.model.points")

local animations = {}

function animations.characterMoveAnimation(character, path, speed, callback) 
	local a = {}
	
	a.character = character
	a.path = path
	a.hasMore = true
	
	a.i = 0
	
	a.start = points.copyPoint(character.pos)
	a.curr = points.copyPoint(character.pos)
	
	if (#path == 1) then
		a.hasMore = false
		callback()
		return nil
	end
	
	a.target_i = 2
	a.target = points.copyPoint(path[a.target_i])
	
	a.ratio = 0
		
	function a.step()
		if(a.ratio >= 1) then
			a.curr = points.copyPoint(a.target)
			if (a.target_i < #path) then
				a.target_i = a.target_i + 1
				a.target = points.copyPoint(path[a.target_i])
				a.start = points.copyPoint(a.curr)
				a.ratio = 0
			else
				a.hasMore = false
				character.move(a.curr.x, a.curr.y)
				callback()
			end
		end
		if (a.hasMore) then
			a.curr = points.lerp(a.start, a.target, a.ratio)
			a.ratio = a.ratio + speed
		end
		
		character.move(a.curr.x, a.curr.y)
		
	end
	
	return a
end

return animations