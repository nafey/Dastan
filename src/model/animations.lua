local points = require("src.model.points")

local animations = {}

function animations.characterMoveAnimation(character, path, speed, callback) 
	local a = {}
	
	a.has_more = true
		
	a.start = points.copyPoint(character.pos)
	a.curr = points.copyPoint(character.pos)
	
	if (#path == 1) then
		a.has_more = false
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
				a.has_more = false
				character.move(a.curr.x, a.curr.y)
				callback()
			end
		end
		if (a.has_more) then
			a.curr = points.lerp(a.start, a.target, a.ratio)
			a.ratio = a.ratio + speed
		end
		
		character.move(a.curr.x, a.curr.y)
	end
	
	function a.stop()
		--nothing to finalize
	end
	
	return a
end


function animations.characterBob(character)
	local a = {}
	a.has_more = true
	
	a.character = character
	a.last_time = nil
	
	
	a.amplitude = 0.1
	a.up = false
	
	a.period = 350
	a.period_elapsed = 0
	
	function a.step()
		if (a.last_time == nil) then
			a.last_time = system.getTimer()
		else
			local now = system.getTimer() 
			local delta = now - a.last_time
			a.last_time = now
			
			if (a.period_elapsed < a.period) then
				a.period_elapsed = a.period_elapsed + delta
			else
				a.period_elapsed = 0
				
				a.up = not a.up
				
				if (a.up) then
					a.character.sprite.y = a.character.sprite.y - TILE_Y * a.amplitude
				else
					a.character.sprite.y = a.character.sprite.y + TILE_Y * a.amplitude
				end
			end
		end
	end
	
	function a.stop()
		a.has_more = false
		a.character.move(a.character.pos.x, a.character.pos.y)
	end
	
	return a
end

return animations