local points = require("src.model.geometry.points")
local animations = require("src.helper.ui.animations")
local sprite_data = require("src.helper.ui.sprite_data")

local animation_manager = {}
animation_manager.list = {}

function animation_manager.animateDeath(sprite, callback, args)
	local death_blink = animations.blink(sprite, 10, 50, callback, args)
	table.insert(animation_manager.list, death_blink)
end

function animation_manager.characterBob(sprite, character)
	local bob = animations.characterBob(sprite, character)
	table.insert(animation_manager.list, bob)
end

function animation_manager.stopBob()
	for i = 1, #animation_manager.list do
		if (animation_manager.list[i].name == "bob") then
			animation_manager.list[i].stop()
		end
	end
	animation_manager.clearDead()
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
	elseif (ability.name == "speed_rush") then
		local anim_list = {}
		
		local pt = points.createPoint(character.pos.x, character.pos.y - 1)
		local rush_fx = sprite_data.getSpeedRushFxData()
		local rush = animations.showAnimationOnce(rush_fx, pt, callback)
		table.insert(anim_list, rush)
		
		
		local roar_list = {}
		
		for i = 1, #affected do
			local roar_after = animations.showAnimationOnce(sprite_data.getRoarFxFinalData(), affected[i].pos)
			table.insert(roar_list, roar_after)
		end
		
		local parallel = animations.playParallel(roar_list)
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
	elseif (ability.name == "heal") then
		local heal_fx = sprite_data.getHealFxData()
		local heal = animations.showAnimationOnce(heal_fx, target.pos, callback)
		table.insert(animation_manager.list, heal)
	end
end

function animation_manager.animateCharacterMove(sprite, action, callback, args)
	local path = {}
	
	for i = 1, #action.path do
		table.insert(path, points.createPoint((action.path[i].x - 1) * TILE_X, 
			(action.path[i].y - 1) * TILE_Y))
	end
	local move = animations.moveSprite(sprite, path, callback, action)
	table.insert(animation_manager.list, move)
end

function animation_manager.animateCharacterAttack(attacker, defender, callback, args)
	local attack_seq = animations.attack(attacker, defender, callback, args)
	table.insert(animation_manager.list, attack_seq)
end

function animation_manager.debug(displayGroup, sprite, callback, args)
	--local move1 = animations.characterTranslate(character, points.createPoint(9, 3), 350)
	--local move2 = animations.characterTranslate(character, points.createPoint(10, 6), 350)
	--	
	--local move_anims = {}
	--table.insert(move_anims, move1)
	--table.insert(move_anims, move2)
	--
	--local seq = animations.playSequence(move_anims)
	--table.insert(animation_manager.list, seq)
	
	--local anim_data = sprite_data.getPowSheetData()
	--local once = animations.showAnimationOnce(anim_data, points.createPoint(sprite.x, sprite.y))
	--table.insert(animation_manager.list, once)
	
	--local sheet = graphics.newImageSheet(anim_data["image"], anim_data["options"])
	--local sequence = anim_data["sequence"]
	--
	--display.newSprite(sheet, sequence)
	
	--local move = animations.showAnimationOnce(displayGroup, pow_sheet, points.createPoint(30, 30))
	--table.insert(animation_manager.list, move)
	
	--local poke = animations.poke(character, false, false)
	--table.insert(animation_manager.list, poke)
	
	--table.insert(animation_manager.list, move)
	
	--local blink = animations.blink(sprite, 3, 100)
	--table.insert(animation_manager.list, blink)
	
	--local move1 = animations.characterTranslate(sprite, points.createPoint(288, 128), 
	--	200)
	--local move2 = animations.characterTranslate(sprite, points.createPoint(320, 128),
	--	200)
	--
	--local anim_list = {}
	--
	--table.insert(anim_list, move1)
	--table.insert(anim_list, move2)
	--
	--local seq = animations.playSequence(anim_list, callback, args)
	--
	--table.insert(animation_manager.list, seq)
	
	--table.insert(animation_manager.list, poke)
	
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
			table.remove(animation_manager.list, i)
		end
	end
end

return animation_manager