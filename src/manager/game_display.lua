local game = require("src.model.game.game")
local player_helper = require("src.model.game.player_helper")

local sprites = require("src.helper.ui.sprites")
local draw_helper = require("src.helper.ui.draw_helper")

local json_helper = require("src.helper.util.json_helper")
local file_helper = require("src.helper.util.file_helper")
local level_loader = require("src.helper.util.level_loader")

local game_display = {}

-- All logic stuff
game_display.game = game

-- All UI stuff 
game_display.ui = {}

-- Scene
game_display.scene = nil

function game_display.setupUI()
	draw_helper.drawMoveOrder(game_display.game.player_list, 
		game_display.root.ui.frame.move_order)
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
	
	-- initialize game
	game_display.game.initialize(player_list, level)
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
	game_display.root.player = display.newGroup()
	
	game_display.ui.player_sprites = {}
	for i = 1, #game_display.game.player_list do
		local player = game_display.game.player_list[i]
		game_display.ui.player_sprites [player.name] = sprites.draw("res/chars/" .. player.name .. ".png", 
			player.pos.x - 1, player.pos.y - 1, 0, game_display.root.player)
	end
	
	-- Frame
	game_display.root.ui = display.newGroup()
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
	game_display.setupUI()
	
end

return game_display
