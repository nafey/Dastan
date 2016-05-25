local player_helper = require("src.model.game.player_helper")

local game = {}

game.player_list = nil
game.level = nil


function game.initialize(player_list, level)
	game.player_list = player_list
	game.level = level
	
	local player_pos = player_helper.getPlayerPositions(game.level)
	
	for i = 1, #game.player_list do
		local p = game.player_list[i]
		p.pos = player_pos[p.start_pos]
	end
	
end


return game
