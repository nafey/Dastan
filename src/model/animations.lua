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

function animations.characterTranslate(character, to_point, period)
	local a = {}
	
	a.has_more = true
	
	a.character = character
	a.start = points.copyPoint(a.character.pos)
	a.to_point = points.copyPoint(to_point)
	a.period = period
	a.period_elapsed = 0
	
	a.last_time = nil 
	
	function a.step()
		if (a.last_time == nil) then
			a.last_time = system.getTimer()
		else
			local now = system.getTimer() 
			local delta = now - a.last_time
			a.last_time = now
			
			if (a.period_elapsed < a.period) then
				local p = points.lerp(a.start, a.to_point, a.period_elapsed/a.period)
				p.print()
				a.character.move(p.x, p.y)
				a.period_elapsed = a.period_elapsed + delta
			else
				a.period_elapsed = a.period
				a.stop()
			end
			
		end
	end
	
	function a.stop()
		a.has_more = false
		a.period_elapsed = 0
		a.character.move(a.to_point.x, a.to_point.y)
	end
	
	return a
end

function animations.playSequence(animation_list)
	local a = {}
	a.has_more = true
	
	a.list = animation_list
	
	print(a.list[1].has_more)
	print(a.list[2].has_more)
	
	
	if (#animation_list < 1) then
		return nil
	end
	
	a.idx = 1
	
	function a.step() 
		if (a.idx <= #a.list) then
			if (a.list[a.idx].has_more) then
				a.list[a.idx].step()
			else
				a.list[a.idx].stop()
				a.idx = a.idx + 1
			end
		else 
			a.stop()
		end
	end
		
	function a.stop() 
		a.has_more = false
	end
	
	return a
end

return animations