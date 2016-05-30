local game_engine = require("src.model.game.game_engine")
local player_helper = require("src.model.game.player_helper")
-- TODO: change player to unit everywhere
-- TODO: Is it really needed here?
local geometry = require("src.model.geometry.geometry")

local game = {}

game.player_list = nil
game.level = nil
game.selected_player = nil
game.move_map = nil
game.action_queue = {}

-- TODO: This needs to be fixed
game.main_team = 1

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

function game.submitInteraction(interaction)
	if (interaction.code == "move") then
		-- TODO: this should be handled better
		--if (interaction.point.x == game.selected_player.pos.x and
		--	interaction.point.y == game.selected_player.pos.y) then
		--	--check if you are adjacent to enemy
		--	if (player_helper.isAdjacentToEnemy(game.selected_player.pos.x, game.selected_player.pos.y, 
		--			game.player_list, game.selected_player.team)) then
		--		-- queue attack
		--		
		--	else 
		--		-- selectNextPlayer
		--		game.selectNextPlayer()
		--		
		--		-- enqueue select action
		--		local select_action = {}
		--		select_action.code = "select"
		--		select_action.player = game.selected_player
		--		
		--		table.insert(game.action_queue, select_action)
		--	end
		--else
			-- move player
			local ret = player_helper.movePlayer(game.move_map, 
				game.selected_player, interaction.point)
			
			-- enqueue move action
			local move_action = {}
			move_action.code = "move"
			move_action.player = game.selected_player
			move_action.path = ret
			table.insert(game.action_queue, move_action)
			
			if (not player_helper.isAdjacentToEnemy(game.selected_player.pos.x, game.selected_player.pos.y, 
				game.player_list, game.selected_player.team)) then
				-- selectNextPlayer
				game.selectNextPlayer()
				
				-- enqueue select action
				local select_action = {}
				select_action.code = "select"
				select_action.player = game.selected_player
				
				table.insert(game.action_queue, select_action)
			end
		--end
	
	elseif (interaction.code == "move_cancel") then
		-- selectNextPlayer
		game.selectNextPlayer()
		
		-- enqueue select action
		local select_action = {}
		select_action.code = "select"
		select_action.player = game.selected_player
		
		table.insert(game.action_queue, select_action)
	elseif (interaction.code == "attack") then
		game_engine.playerAttack(interaction.attacker, interaction.defender, game.player_list)
				
		local attack_action = {}
		attack_action.code = "action"
		attack_action.attacker = interaction.attacker
		attack_action.defender = interaction.defender
		
		table.insert(game.action_queue, attack_action)
		
		-- selectNextPlayer
		game.selectNextPlayer()
		
		-- enqueue select action
		local select_action = {}
		select_action.code = "select"
		select_action.player = game.selected_player
		
		table.insert(game.action_queue, select_action)
	end
end


return game
