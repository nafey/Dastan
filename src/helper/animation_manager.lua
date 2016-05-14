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


function animation_manager.animateCharacterMove(character, path, callback)
	local move = animations.characterMoveAnimation(character, path, 0.25, callback)
	table.insert(animation_manager.list, move)
end

function animation_manager.animateCharacterAttack(character, attacked, callback)
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
			table.remove(animation_manager.list, i)
		end
	end
end

return animation_manager