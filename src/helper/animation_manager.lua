local animations = require("src.model.animations")


local animation_manager = {}
animation_manager.list = {}
local main_character_bob = nil

function animation_manager.characterBob(character)
	local bob = animations.characterBob(character)
	table.insert(animation_manager.list, bob)
	main_character_bob = bob
end

function animation_manager.beforeMainCharMove()
	if (main_character_bob ~= nil) then
		main_character_bob.stop()
		animation_manager.clearDead()
	end
end

function animation_manager.animateCharacterMove(character, path, callback)
	
	local move = animations.characterMoveAnimation(character, path, 0.25, callback)
	table.insert(animation_manager.list, move)
end

function animation_manager.step() 
	for i = #animation_manager.list, 1, -1 do
		if (animation_manager.list[i].has_more) then
			animation_manager.list[i].step()
		else
			table.remove(animation_manager.list[i], i)
		end
	end
	
end

function animation_manager.clearDead()
	for i = #animation_manager.list, 1, -1 do
		if (not animation_manager.list[i].has_more) then
			table.remove(animation_manager.list, i)
		end
	end
end

return animation_manager