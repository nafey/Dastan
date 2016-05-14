local points = require("src.model.points")
local sprite_data = require("src.helper.sprite_data")

local animations = {}

function animations.characterAttackAnimation(character, attacked, callback)
	local isHort = true
	local isPos = true
	
	if (character.pos.x > attacked.pos.x) then
		isPos = false
	elseif (character.pos.y > attacked.pos.y) then
		isHort = false
	elseif (character.pos.y < attacked.pos.y) then
		isHort = false
		isPos = false
	end
	
	local poke = animations.poke(character, isHort, isPos)
	
	local pow_sheet = sprite_data.getPowSheetData()
	local pow_anim = animations.showAnimationOnce(pow_sheet, attacked.pos)
	
	local blink = animations.blink(attacked.sprite, 3, 100)
	
	local attack_anims = {}
	table.insert(attack_anims, poke)
	table.insert(attack_anims, pow_anim)
	table.insert(attack_anims, blink)
	
	local attack_seq = animations.playSequence(attack_anims, callback)
	return attack_seq
end

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
	a.start = nil
	a.to_point = points.copyPoint(to_point)
	a.period = period
	a.period_elapsed = 0
	
	a.last_time = nil 
	
	function a.step()
		if (a.start == nil) then
			a.start = points.copyPoint(a.character.pos)
		end
		if (a.last_time == nil) then
			a.last_time = system.getTimer()
		else
			local now = system.getTimer() 
			local delta = now - a.last_time
			a.last_time = now
			
			if (a.period_elapsed < a.period) then
				local p = points.lerp(a.start, a.to_point, a.period_elapsed/a.period)
				
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


function animations.poke(character, isHort, isPositive) 
	local a = {}
	a.has_more = true
	a.amplitude = 0.3
	a.period = 40
	
	local list = {}
	local to_point = nil
	
	local sign = 0
	
	if (isPositive) then
		sign = 1
	else 
		sign = -1
	end
	
	
	if (isHort) then
		to_point = points.createPoint(character.pos.x + sign * a.amplitude, character.pos.y)
	else
		to_point = points.createPoint(character.pos.x, character.pos.y + sign * a.amplitude)
	end
	
	local move1 = animations.characterTranslate(character, to_point, a.period)
	local move2 = animations.characterTranslate(character, character.pos, a.period)
	
	table.insert(list, move1)
	table.insert(list, move2)
	
	a = animations.playSequence(list)
	
	return a 
end

function animations.showAnimationOnce(anim_data, pos)
	local a = {}
	a.has_more = true
	
	a.period = anim_data["sequence"][1].time
	a.period_elapsed = 0
	
	a.last_time = nil

	a.sheet = graphics.newImageSheet(anim_data["image"], anim_data["options"])
	a.sequence = anim_data["sequence"]
	
	
	
	function a.step() 
		if (a.last_time == nil) then
			a.last_time = system.getTimer()
			a.spr = display.newSprite(a.sheet, a.sequence)
			a.spr.x = (pos.x - 1) * TILE_X
			a.spr.y = (pos.y - 1) * TILE_Y
			a.spr.anchorX = 0
			a.spr.anchorY = 0
			a.spr:play()
		else
			local now = system.getTimer() 
			local delta = now - a.last_time
			a.last_time = now
			
			if (a.period_elapsed < a.period) then
				a.period_elapsed = a.period_elapsed + delta
			else
				a.period_elapsed = a.period
				a.has_more = false
			end
			
		end
	end
	
	function a.stop()
		a.spr:pause()
		a.spr:removeSelf()
	end
	
	return a
end

function animations.blink(sprite, times, period)
	local a = {}
	
	a.has_more = true
	
	a.sprite = sprite
	a.times = times
	a.times_curr = 1
	
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
				if (a.period_elapsed < a.period / 2) then
					a.sprite.alpha = 0
				else 
					a.sprite.alpha = 1
				end
				a.period_elapsed = a.period_elapsed + delta
			else
				if (a.times_curr < a.times) then
					a.period_elapsed = 0
					a.sprite.alpha = 1
					a.times_curr = a.times_curr + 1
				else
					a.period_elapsed = a.period
					a.has_more = false
				end
				
			end
			
		end
	end
	
	function a.stop()
		a.sprite.alpha = 1
	end
	
	return a
end

function animations.playSequence(animation_list, callback)
	local a = {}
	a.has_more = true
	a.callback = callback
	
	a.list = animation_list
	
	
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
		if (a.callback ~= nil) then
			a.callback()
		end
	end
	
	return a
end





return animations