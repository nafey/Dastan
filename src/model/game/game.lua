local player_helper = require("src.model.game.player_helper")

-- TODO: Is it really needed here?
local geometry = require("src.model.geometry.geometry")

local game = {}

game.player_list = nil
game.level = nil
game.selected_player = nil
game.move_map = nil

function game.selectNextPlayer()
	game.selected_player = player_helper.selectNextMover(game.player_list, false)

	local raw_level = player_helper.getMovementGrid(game.level)
	local level_with_players = player_helper.markPlayers(raw_level, game.player_list, game.selected_player)
	
	game.move_map = geometry.floodFill(level_with_players, game.selected_player.pos, game.selected_player.range)
end

function game.initialize(player_list, level)
	game.player_list = player_list
	game.level = level
	
	-- Set players at positions
	local player_pos = player_helper.getPlayerPositions(game.level)
	
	for i = 1, #game.player_list do
		local p = game.player_list[i]
		p.pos = player_pos[p.start_pos]
	end
	
	-- Set the selected player_helper
	game.selectNextPlayer()
end


return game
