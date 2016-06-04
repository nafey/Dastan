local game_engine = require("src.model.game.game_engine")
local player_helper = require("src.model.game.player_helper")

local ai = require("src.model.game.ai")

-- TODO: change player to unit everywhere
-- TODO: Is it really needed here?
local geometry = require("src.model.geometry.geometry")

local game = {}

-- TODO: null initialization is probably dumb
game.player_list = nil
game.level = nil
game.selected_player = nil
game.move_map = nil
game.action_queue = {}

-- TODO: This needs to be fixed
game.main_team = 1

function game.selectNextPlayer()
		
	local keep_selecting = true
	
	while (keep_selecting) do
		game.selected_player = player_helper.selectNextMover(game.player_list, false)

		local raw_level = player_helper.getMovementGrid(game.level)
		local level_with_players = player_helper.markPlayers(raw_level, game.player_list, game.selected_player)
		
		game.move_map = geometry.floodFill(level_with_players, game.selected_player.pos, game.selected_player.range)
		if (game.selected_player.team == game.main_team) then
			keep_selecting = false
		else
			-- do ai stuff here
			local recommend = ai.aiTurn(game.selected_player, game.player_list, 
				game.move_map, game.level)
			
			if (recommend.code == "recommend_move") then
				-- enqueue move action
				-- TODO: No select action here?			
				local select_action = {}
				select_action.code = "select"
				select_action.player = game.selected_player
				select_action.move_map = game.move_map
							
				table.insert(game.action_queue, select_action)				
				
				-- TODO: Currently I can count this piece of code in three places
				--		 Modularize this shit
				-- TODO: Player Helper cant be expected to execute triggers move 
				--		 this to game engine
				local ret = player_helper.movePlayer(game.move_map, 
					game.selected_player, recommend.point)
				
				local move_action = {}
				move_action.code = "move"
				move_action.player = game.selected_player
				move_action.path = ret
				table.insert(game.action_queue, move_action)				
			end			
		end
	
	end

	
	
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
		-- enqueue move action
		local ret = player_helper.movePlayer(game.move_map, 
			game.selected_player, interaction.point)
		
		local move_action = {}
		move_action.code = "move"
		move_action.player = game.selected_player
		move_action.path = ret
				
		table.insert(game.action_queue, move_action)
		
		-- If you have moved to empty block select next player
		-- or get ready to attack
		if (not player_helper.isAdjacentToEnemy(game.selected_player.pos.x, game.selected_player.pos.y, 
			game.player_list, game.selected_player.team)) then
			-- selectNextPlayer
			game.selectNextPlayer()
			
			-- enqueue select action
			local select_action = {}
			select_action.code = "select"
			select_action.player = game.selected_player
			select_action.move_map = game.move_map
						
			table.insert(game.action_queue, select_action)
		else 
			local attack_choice_action = {}
			attack_choice_action.code = "attack_choice"
			attack_choice_action.player = game.selected_player
			
			table.insert(game.action_queue, attack_choice_action)
		end
	
	elseif (interaction.code == "move_cancel") then
		-- selectNextPlayer
		game.selectNextPlayer()
		
		-- enqueue select action
		local select_action = {}
		select_action.code = "select"
		select_action.player = game.selected_player
		select_action.move_map = game.move_map
		
		table.insert(game.action_queue, select_action)
	elseif (interaction.code == "attack") then
		game_engine.playerAttack(interaction.attacker, interaction.defender, game.player_list)
				
		local attack_action = {}
		attack_action.code = "attack"
		attack_action.attacker = interaction.attacker
		attack_action.defender = interaction.defender
		
		table.insert(game.action_queue, attack_action)
		
		-- selectNextPlayer
		game.selectNextPlayer()
		
		-- enqueue select action
		local select_action = {}
		select_action.code = "select"
		select_action.player = game.selected_player
		select_action.move_map = game.move_map
		
		table.insert(game.action_queue, select_action)
	end
end


return game
