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


function game_display.setupUI()
	-- Draw Character info
	draw_helper.showCharDetails(game_display.root.ui.frame.char_dat.face,
		game_display.root.ui.frame.char_dat.desc,
		game_display.game.selected_player)

	-- Movement Grid draw
	draw_helper.drawMovementGrid(game_display.game.move_map, 
		game_display.root.selection, 
		game_display.game.player_list, 
		game_display.game.selected_player.team, 
		game_display.game.selected_player.pos)
	
	-- Move Order draw
	draw_helper.drawMoveOrder(game_display.game.player_list, 
		game_display.root.ui.frame.move_order)
		
	-- Drop Dead
	local rem = {}
	for k,v in pairs(game_display.ui.player_sprites) do
		local k_died = true
		
		for i = 1, #game.player_list do
			if (k == game.player_list[i].name) then
				k_died = false
			end
		end
		
		if (k_died) then
			table.insert(rem, k)
		end
	end
	
	for i = 1, #rem do
		game_display.ui.player_sprites[rem[i]]:removeSelf()
		game_display.ui.player_sprites[rem[i]] = nil
	end
end

function game_display.actionCallback(action)
	if (action.code == "move") then
		game_display.executing = false
	elseif (action.code == "attack") then
		game_display.executing = false
		game_display.setupUI()
	end
end

function game_display.executeAction(action)
	if (action.code == "move") then
		draw_helper.emptyGroup(game_display.root.selection)
		
		animation_manager.animateCharacterMove(
			game_display.ui.player_sprites[action.player.name], 
			action,
			game_display.actionCallback)
		game_display.executing = true
	elseif (action.code == "select") then
		game_display.setupUI()
		game_display.ui.game_state = game_state.awaiting_player_move
	elseif(action.code == "attack_choice") then
		draw_helper.drawAttackGrid(game.selected_player.pos, game_display.root.selection, game.player_list, 
			game.selected_player.team, game_display.root.ui.play_area)
		game_display.ui.game_state = game_state.awaiting_attack_confirmation
	elseif(action.code == "attack") then
		draw_helper.emptyGroup(game_display.root.selection)
		
		local attacker_sprite = game_display.ui.player_sprites[action.attacker.name]
		local defender_sprite = game_display.ui.player_sprites[action.defender.name]
		
		animation_manager.animateCharacterAttack(attacker_sprite, defender_sprite, 
			game_display.actionCallback, action)
		game_display.executing = true
	end
end





function game_display.tap( event ) 
	local x = math.floor(event.x / TILE_X) + 1
	local y = math.floor(event.y / TILE_Y) + 1
	
	if (not game_display.executing) then
		if (game_display.ui.game_state == game_state.awaiting_player_move) then
			if (game.move_map.safe(x, y) ~= 0) then
				
				local interaction = {}
				
				interaction.code = "move"
				interaction.point = points.createPoint(x, y)
				
				game.submitInteraction(interaction)
			end
		elseif (game_display.ui.game_state == game_state.awaiting_attack_confirmation) then
			if (x == game.selected_player.pos.x and y == game.selected_player.pos.y) then
				
				local interaction = {}
				
				interaction.code = "move_cancel"
				
				draw_helper.emptyGroup(game_display.root.ui.play_area)
				game.submitInteraction(interaction)
			end
			
			if (player_helper.isEnemyAtPosition(x, y, game.player_list, game.selected_player.team) == 1) then
				
				local interaction = {}
				
				interaction.code = "attack"
				interaction.attacker = game.selected_player
				interaction.defender = player_helper.getPlayerAtPosition(x, y, game.player_list)
				
				draw_helper.emptyGroup(game_display.root.ui.play_area)
				game.submitInteraction(interaction)
			end
		end
	end
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
	
	draw_helper.drawHpBars(game.player_list, game_display.ui.player_sprites, game.main_team, game_display.root.ui.hp)
end

function game_display.debug2(args)
	print(args)
end

function game_display.debug()
	animation_manager.debug(game_display.root.ui.play_area, game_display.ui.player_sprites[game.selected_player.name], game_display.debug2, "Hello World")
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
	for i = 1, #game_display.game.player_list do
		local player = game_display.game.player_list[i]
		game_display.ui.player_sprites [player.name] = sprites.draw("res/chars/" .. player.name .. ".png", 
			player.pos.x - 1, player.pos.y - 1, 0, game_display.root.player)
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
	--game_display.root.ui.frame.button.button1:addEventListener("tap", ability1click)
	
			-- BUTTON 2
	game_display.root.ui.frame.button.button2 = display.newGroup()
	game_display.root.ui.frame.button.button2.x = 50
	--game_display.root.ui.frame.button:insert(game_display.root.ui.frame.button.button2)
	--game_display.root.ui.frame.button.button2:addEventListener("tap", ability2click)
	
	game_display.setupUI()
	
	-- Expect clicks
	game_display.ui.game_state = game_state.awaiting_player_move
	
	-- Tap Listener
	game_display.root.background:addEventListener("tap", game_display.tap)
	
	game_display.debug()
end


return game_display
