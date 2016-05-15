local animations = require("src.model.animations")
local points = require("src.model.points")
local sprite_data = require("src.helper.sprite_data")

local animation_manager = {}
animation_manager.list = {}
local main_character_bob = nil

function animation_manager.characterBob(character)
	local bob = animations.characterBob(character)
	table.insert(animation_manager.list, bob)
	main_character_bob = bob
end

function animation_manager.stopBob()
	if (main_character_bob ~= nil) then
		main_character_bob.stop()
		animation_manager.clearDead()
	end
end

function animation_manager.animateTriggeredAbility(character, affected, ability, callback)
	if (ability.name == "roar") then
		local anim_list = {}
		
		local pt = points.createPoint(character.pos.x - 1, character.pos.y - 1)
		local roar = animations.showAnimationOnce(sprite_data.getRoarFxData(), pt)
		table.insert(anim_list, roar)
		
		
		local roar_list = {}
		
		for i = 1, #affected do
			local roar_after = animations.showAnimationOnce(sprite_data.getRoarFxFinalData(), affected[i].pos)
			table.insert(roar_list, roar_after)
		end
		
		local parallel = animations.playParallel(roar_list)
		table.insert(anim_list, parallel)
		
		local seq = animations.playSequence(anim_list, callback)
		table.insert(animation_manager.list, seq)
	elseif (ability.name == "scatter_shot") then
		local anim_list = {}
		
		local pt = points.createPoint(character.pos.x - 1, character.pos.y - 1)
		local scatter = animations.showAnimationOnce(sprite_data.getScatterShotFxData(), pt)
		table.insert(anim_list, scatter)
		
		local hit_list = {}
		
		for i = 1, #affected do
			local scatter_after = animations.attackImpactAnimation(character, affected[i])
			table.insert(hit_list, scatter_after)
		end
		
		local parallel = animations.playParallel(hit_list)
		table.insert(anim_list, parallel)
		
		local seq = animations.playSequence(anim_list, callback)
		table.insert(animation_manager.list, seq) 
	end
end

function animation_manager.animateTargetedAbility(character, target, ability, callback)
	if (ability.name == "double_strike") then
		local attack1 = animations.characterAttackAnimation(character, target)
		local attack2 = animations.characterAttackAnimation(character, target)
		
		local anims = {}
		
		table.insert(anims, attack1)
		table.insert(anims, attack2)
		
		local anim_seq = animations.playSequence(anims, callback)
		table.insert(animation_manager.list, anim_seq)
	elseif (ability.name == "shoot") then
		local pow_sheet = sprite_data.getPowSheetData()
	
		local attack_seq = animations.attackImpactAnimation(character, target, callback)
		table.insert(animation_manager.list, attack_seq)
	end
end

function animation_manager.animateCharacterMove(character, path, callback)
	local move = animations.characterMoveAnimation(character, path, 0.25, callback)
	table.insert(animation_manager.list, move)
end

function animation_manager.animateCharacterAttack(character, attacked, callback)
	local attack_seq = animations.characterAttackAnimation(character, attacked, callback)
	table.insert(animation_manager.list, attack_seq)
end

function animation_manager.debug(character)
	--local move1 = animations.characterTranslate(character, points.createPoint(9, 3), 350)
	--local move2 = animations.characterTranslate(character, points.createPoint(10, 6), 350)
	--	
	--local move_anims = {}
	--table.insert(move_anims, move1)
	--table.insert(move_anims, move2)
	--
	--local seq = animations.playSequence(move_anims)
	--table.insert(animation_manager.list, seq)
	
	--local pow_sheet = sprite_data.getPowSheetData()
	--local move = animations.showAnimationOnce(pow_sheet, character.pos)
	--table.insert(animation_manager.list, move)
	
	--local poke = animations.poke(character, false, false)
	--table.insert(animation_manager.list, poke)
	
	--table.insert(animation_manager.list, move)
	
	--local blink = animations.blink(character.sprite, 3, 100)
	--table.insert(animation_manager.list, blink)
end

function animation_manager.step() 
	for i = #animation_manager.list, 1, -1 do
		if (animation_manager.list[i].has_more) then
			animation_manager.list[i].step()
		end
	end
	
	animation_manager.clearDead()
end

function animation_manager.clearDead()
	for i = #animation_manager.list, 1, -1 do
		if (not animation_manager.list[i].has_more) then
			animation_manager.list[i].stop()
			
			if (animation_manager.list[i].callback ~= nil) then
				animation_manager.list[i].callback()
			end
			
			table.remove(animation_manager.list, i)
		end
	end
end

return animation_manager