local animations = require("src.model.animations")


local animation_manager = {}
animation_manager.list = {}


function animation_manager.animateCharacterMove(character, path, callback)
	local move = animations.characterMoveAnimation(character, path, 0.25, callback)
	table.insert(animation_manager.list, move)
end

function animation_manager.step() 
	for i = #animation_manager.list, 1, -1 do
		if (animation_manager.list[i].hasMore) then
			animation_manager.list[i].step()
		else
			table.remove(animation_manager.list, i)
		end
	end
end

return animation_manager