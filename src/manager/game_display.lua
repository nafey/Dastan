local game = require("src.model.game.game")
local player_helper = require("src.model.game.player_helper")

local sprites = require("src.helper.ui.sprites")

local json_helper = require("src.helper.util.json_helper")
local file_helper = require("src.helper.util.file_helper")
local level_loader = require("src.helper.util.level_loader")

local game_groups = require("src.manager.game_groups")

local game_manager = {}

-- All logic stuff
game_manager.game = game

-- All UI stuff 
game_manager.ui = {}

-- Scene
game_manager.scene = nil

function game_manager.initialize(scene, player_data_file_path, level_data_file_path, level_background_image, team_data_file_path, main_team)
	-- Load team data
	local teams = json_helper:decode(file_helper.getFileText(team_data_file_path))
	
	-- Load hero data
	local player_list = player_helper.loadPlayers(player_data_file_path, teams)
	
	-- Load level data
	local level = level_loader.loadLevel(level_data_file_path)
	
	-- Background image 
	game_manager.ui.background = level_background_image
	
	-- initialize game
	game_manager.game.initialize(player_list, level)
end

function game_manager.create(root)
	local level_width = 480
	local level_height = 256
	local frame_height = 64
	
	
	game_manager.root = root
	game_groups.initializeGroups(game_manager.root)
		
	-- Background setup
	game_manager.root.background.bg = display.newImageRect(root.background, game_manager.ui.background, level_width, level_height )
	game_manager.root.background.bg.anchorX = 0
	game_manager.root.background.bg.anchorY = 0
	
	-- Show Players
	game_manager.ui.player_sprites = {}
	
	for i = 1, #game_manager.game.player_list do
		local player = game_manager.game.player_list[i]
		game_manager.ui.player_sprites [player.name] = sprites.draw("res/chars/" .. player.name .. ".png", 
			player.pos.x - 1, player.pos.y - 1, 0, game_manager.root.player)
	end
	
	-- Show Frame
	game_manager.root.ui.frame.ui_frame = display.newImageRect(root.ui.frame, "res/ui/ui_frame.png", level_width, frame_height)
	game_manager.root.ui.frame.ui_frame.anchorX = 0
	game_manager.root.ui.frame.ui_frame.anchorY = 0
	

	
end

return game_manager
