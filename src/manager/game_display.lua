local points = require("src.model.geometry.points")

local game = require("src.model.game.game")
local player_helper = require("src.model.game.player_helper")

local sprites = require("src.helper.ui.sprites")
local draw_helper = require("src.helper.ui.draw_helper")
local animation_manager = require("src.helper.ui.animation_manager")

local json_helper = require("src.helper.util.json_helper")
local file_helper = require("src.helper.util.file_helper")
local level_loader = require("src.helper.util.level_loader")


local game_state = require("src.model.game.game_state")

local game_display = {}

-- All logic stuff
game_display.game = game


-- All UI Information 
game_display.ui = {}
-- All UI sprites 
game_display.root = {}

-- TODO: to use {} instead of nil for initialization


-- Scene for clicks and stuff
game_display.scene = {}

game_display.action_counter = 0 
game_display.executing = false

game_display.animation_manager = animation_manager

-- TODO: having move_map here is a hack
function game_display.setupUI(player, move_map)
	-- Draw Character info
	draw_helper.showCharDetails(game_display.root.ui.frame.char_dat.face,
		game_display.root.ui.frame.char_dat.desc,
		player)

	-- Movement Grid draw
	draw_helper.drawMovementGrid(move_map, 
		game_display.root.selection, 
		game_display.game.player_list, 
		player.team, 
		player.pos)
	
	-- Move Order draw
	-- TODO: look closely there is some issue with Move Order
	draw_helper.drawMoveOrder(player,
		game_display.game.player_list, 
		game_display.root.ui.frame.move_order)
		
	draw_helper.drawButtons(game_display.root.ui.frame.button,
		game.selected_player)
		
	-- Bob animation
	animation_manager.stopBob()
	animation_manager.characterBob(game_display.ui.player_sprites[player.name],
		player)
end

function game_display.triggeredAbilityCallback(action) 	
	game_display.executing = false
	
	for i = 1, #action.affected do
		-- Update the hp here
		local hp = 0
		for j = 1, #game.player_list do
			if (action.affected[i].name == game.player_list[j].name) then
				hp = game.player_list[j].hp
			end
		end
		
		game_display.ui.hp[action.affected[i].name] = hp
	end
	action.ability.open = true
end

function game_display.targetedAbilityCallback(action) 
	game_display.executing = false
		
	-- TODO: ui is an unfortunate name please change
	local hp = 0
	
	-- Update the hp here
	for i = 1, #game.player_list do
		if (action.target.name == game.player_list[i].name) then
			hp = game.player_list[i].hp
		end
	end
	
	game_display.ui.hp[action.target.name] = hp
	action.ability.open = true
end

function game_display.actionCallback(action)
	if (action.code == "move") then
		game_display.executing = false
	elseif (action.code == "attack") then
		game_display.executing = false
		
		-- TODO: ui is an unfortunate name please change
		local hp = 0
		
		-- Update the hp here
		for i = 1, #game.player_list do
			if (action.defender.name == game.player_list[i].name) then
				hp = game.player_list[i].hp
			end
		end
		
		game_display.ui.hp[action.defender.name] = hp
	elseif (action.code == "dead") then
		game_display.ui.player_sprites[action.died.name]:removeSelf()
		game_display.ui.player_sprites[action.died.name] = nil		
		
	end
end

-- Actions should have complete info about action to be performed
function game_display.executeAction(action)
	if (action.code == "move") then
		draw_helper.emptyGroup(game_display.root.selection)

		animation_manager.animateCharacterMove(
			game_display.ui.player_sprites[action.player.name], 
			action,
			game_display.actionCallback)
		game_display.executing = true
	elseif (action.code == "select") then
		game_display.setupUI(action.player, action.move_map)
		game_display.ui.game_state = game_state.awaiting_player_move
	elseif(action.code == "attack_choice") then
		draw_helper.drawAttackGrid(game_display.game.selected_player.pos, game_display.root.selection, game.player_list, 
			game_display.game.selected_player.team, game_display.root.ui.play_area)
		game_display.ui.game_state = game_state.awaiting_attack_confirmation
	elseif(action.code == "attack") then
		draw_helper.emptyGroup(game_display.root.selection)
		
		local attacker_sprite = game_display.ui.player_sprites[action.attacker.name]
		local defender_sprite = game_display.ui.player_sprites[action.defender.name]

		animation_manager.animateCharacterAttack(attacker_sprite, defender_sprite, 
			game_display.actionCallback, action)
		game_display.executing = true
	elseif (action.code == "dead") then
		animation_manager.animateDeath(game_display.ui.player_sprites[action.died.name], game_display.actionCallback, action)
	elseif (action.code == "ability") then
		if (action.ability.type == "targeted") then
			draw_helper.emptyGroup(game_display.root.selection)
			
			animation_manager.animateTargetedAbility(
				game_display.ui.player_sprites[game.selected_player.name], 
				game_display.ui.player_sprites[action.target.name], 
				action.ability, game_display.targetedAbilityCallback,
				action)
			game_display.executing = true
		elseif (action.ability.type == "triggered") then
			draw_helper.emptyGroup(game_display.root.selection)
		
			local affected_sprites = {}
			
			for i = 1, #action.affected do
				table.insert(affected_sprites, 
				game_display.ui.player_sprites[action.affected[i].name])
			end
			
			animation_manager.stopBob()
			
			animation_manager.animateTriggeredAbility(
				game_display.ui.player_sprites[action.user.name],
				affected_sprites, 
				action.ability, game_display.triggeredAbilityCallback, 
				action)
				
			game_display.executing = true
		end
	end
end


-- Pick up the latest action and execute it
function game_display.frame()
	game_display.animation_manager.step()
	
	if (not game_display.executing) then

		if (#game.action_queue > game_display.action_counter) then
			game_display.action_counter = game_display.action_counter + 1
			game_display.executeAction(
				game.action_queue[game_display.action_counter])
		end
	end
	
	draw_helper.drawHpBars(game.player_list, game_display.ui.hp, game_display.ui.player_sprites, game.main_team, game_display.root.ui.hp)
end

function game_display.initialize(scene, player_data_file_path, level_data_file_path, level_background_image, team_data_file_path, main_team)
	-- Load team data
	local teams = json_helper:decode(file_helper.getFileText(team_data_file_path))
	
	-- Load hero data
	local player_list = player_helper.loadPlayers(player_data_file_path, teams)
	
	-- Load level data
	local level = level_loader.loadLevel(level_data_file_path)
	
	-- Background image 
	game_display.ui.background = level_background_image
	game_display.ui.game_state = nil
	
	
	-- initialize game
	game_display.game.initialize(player_list, level)
end

function game_display.debug2(args)

end

function game_display.debug()
	animation_manager.debug(game_display.root.ui.play_area, game_display.ui.player_sprites[game.selected_player.name], game_display.debug2, "Hello World")
end

function abilityClick(ability)
	if (game_display.ui.game_state ~= game_state.awaiting_player_move) then
		return 
	end
	
	if (ability.type == "targeted") then
		-- TODO: Cardinal Sin: Storing UI info in model
		ability.open = false
		game.used_ability = ability
		
		draw_helper.targetCharacters(game.selected_player, game.player_list, game.level, 
											ability.select, ability.range,
											game_display.root.selection)
		
		draw_helper.drawButtons(game_display.root.ui.frame.button, game.selected_player)
		
		game_display.ui.game_state = game_state.awaiting_ability_target_confirmation
		animation_manager.stopBob()
	elseif (ability.type == "triggered") then
		ability.open = false
		
		game.used_ability = ability
		draw_helper.drawButtons(game_display.root.ui.frame.button, game.selected_player)
		
		local interaction = {}
		
		interaction.code = "ability"
		interaction.ability_type = "triggered"
		interaction.ability = ability
		
		game_display.game.submitInteraction(interaction)
	end
end

-- TODO: Only have one Ability Click listener
-- TODO: should have ability as argument here
function game_display.ability1click()
	if (game.selected_player.ability_1.open) then
		abilityClick(game.selected_player.ability_1)
	end
end

function game_display.ability2click()
	if (game.selected_player.ability_2.open) then
		abilityClick(game.selected_player.ability_2)
	end
end

function game_display.tap( event ) 
	local x = math.floor(event.x / TILE_X) + 1
	local y = math.floor(event.y / TILE_Y) + 1
	
	if (not game_display.executing) then
		if (game_display.ui.game_state == game_state.awaiting_player_move) then
			if (game_display.game.move_map.safe(x, y) ~= 0) then
				local interaction = {}
				
				interaction.code = "move"
				interaction.point = points.createPoint(x, y)
				
				-- Bob animation
				animation_manager.stopBob()
				
				game_display.game.submitInteraction(interaction)
			end
		elseif (game_display.ui.game_state == game_state.awaiting_attack_confirmation) then
			if (x == game_display.game.selected_player.pos.x and y == game_display.game.selected_player.pos.y) then
				
				local interaction = {}
				
				interaction.code = "move_cancel"
				
				draw_helper.emptyGroup(game_display.root.ui.play_area)
				game_display.game.submitInteraction(interaction)
			end
			
			if (player_helper.isEnemyAtPosition(x, y, game_display.game.player_list, game_display.game.selected_player.team) == 1) then
				
				local interaction = {}
				
				interaction.code = "attack"
				interaction.attacker = game_display.game.selected_player
				interaction.defender = player_helper.getPlayerAtPosition(x, y, game_display.game.player_list)
				
				draw_helper.emptyGroup(game_display.root.ui.play_area)
				game_display.game.submitInteraction(interaction)
			end
		elseif (game_display.ui.game_state == game_state.awaiting_ability_target_confirmation) then
			if (player_helper.isTargetable(game.selected_player, game.player_list, game.used_ability, x, y)) then
				local targeted_player = player_helper.getPlayerAtPosition(x, y, game.player_list)
				
				local interaction = {}
				
				interaction.code = "ability"
				interaction.ability_type = "targeted"
				
				interaction.targeted_player = targeted_player
				interaction.ability = game.used_ability
				game_display.game.submitInteraction(interaction)
			else
				game_display.ui.game_state = game_state.awaiting_player_move
				
				game.used_ability.open = true
				game_display.setupUI(game.selected_player, game.move_map)
			end
			
		end
	end
end

function game_display.create(root)
	local level_width = 480
	local level_height = 256
	local frame_height = 64
	
	
	game_display.root = root
		
	-- Background setup
	game_display.root.background = display.newGroup()
	game_display.root.background.bg = display.newImageRect(root.background, game_display.ui.background, level_width, level_height )
	game_display.root.background.bg.anchorX = 0
	game_display.root.background.bg.anchorY = 0
	
	-- Show Players
	game_display.root.selection = display.newGroup()
	game_display.root.player = display.newGroup()
	
	game_display.ui.player_sprites = {}
	game_display.ui.hp = {}
	for i = 1, #game_display.game.player_list do
		local player = game_display.game.player_list[i]
		game_display.ui.player_sprites [player.name] = sprites.draw("res/chars/" .. player.name .. ".png", 
			player.pos.x - 1, player.pos.y - 1, 0, game_display.root.player)
		game_display.ui.hp[player.name] = player.max_hp
	end
	
	-- Frame
	game_display.root.ui = display.newGroup()
	
	game_display.root.ui.hp = display.newGroup()
	game_display.root.ui:insert(game_display.root.ui.hp)
	
	game_display.root.ui.play_area = display.newGroup()
	game_display.root.ui:insert(game_display.root.ui.play_area)
	
	game_display.root.ui.frame = display.newGroup()
	game_display.root.ui.frame.y = 256
	game_display.root.ui:insert(game_display.root.ui.frame)
	
	
	-- Show Frame
	game_display.root.ui.frame.ui_frame = display.newImageRect(game_display.root.ui.frame, "res/ui/ui_frame.png", level_width, frame_height)
	game_display.root.ui.frame.ui_frame.anchorX = 0
	game_display.root.ui.frame.ui_frame.anchorY = 0
	
	-- Show Move Order
	game_display.root.ui.frame.move_order = display.newGroup()
	game_display.root.ui.frame.move_order.y = 19
	game_display.root.ui.frame.move_order.x = 277
	game_display.root.ui.frame:insert(game_display.root.ui.frame.move_order)
	
		-- CHAR DATA
	game_display.root.ui.frame.char_dat = display.newGroup()
	game_display.root.ui.frame:insert(game_display.root.ui.frame.char_dat)
			
			-- FACE
	game_display.root.ui.frame.char_dat.face = display.newGroup()
	game_display.root.ui.frame.char_dat.face.x = 13
	game_display.root.ui.frame.char_dat.face.y = 13
	game_display.root.ui.frame.char_dat:insert(game_display.root.ui.frame.char_dat.face)
			
			-- DESC
	game_display.root.ui.frame.char_dat.desc = display.newGroup()
	game_display.root.ui.frame.char_dat.desc.x = 63
	game_display.root.ui.frame.char_dat.desc.y = 13
	game_display.root.ui.frame.char_dat:insert(game_display.root.ui.frame.char_dat.desc)
	
		-- MOVE ORDER
	game_display.root.ui.frame.move_order = display.newGroup()
	game_display.root.ui.frame.move_order.y = 19
	game_display.root.ui.frame.move_order.x = 277
	game_display.root.ui.frame:insert(game_display.root.ui.frame.move_order)
	
		-- BUTTON
	game_display.root.ui.frame.button = display.newGroup()
	game_display.root.ui.frame.button.x = 170
	game_display.root.ui.frame.button.y = 7
	game_display.root.ui.frame:insert(game_display.root.ui.frame.button)
			
			-- BUTTON 1
	game_display.root.ui.frame.button.button1 = display.newGroup()
	game_display.root.ui.frame.button:insert(game_display.root.ui.frame.button.button1)
	game_display.root.ui.frame.button.button1:addEventListener("tap", game_display.ability1click)
	
			-- BUTTON 2
	game_display.root.ui.frame.button.button2 = display.newGroup()
	game_display.root.ui.frame.button.button2.x = 50
	game_display.root.ui.frame.button:insert(game_display.root.ui.frame.button.button2)
	game_display.root.ui.frame.button.button2:addEventListener("tap", game_display.ability2click)
	
	game_display.setupUI(game_display.game.selected_player, 
		game_display.game.move_map)
	
	-- Expect clicks
	game_display.ui.game_state = game_state.awaiting_player_move
	
	-- Tap Listener
	game_display.root.background:addEventListener("tap", game_display.tap)
	
	game_display.debug()
end


return game_display
