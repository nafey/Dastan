

local game = require("src.model.game.game")
local player_helper = require("src.model.game.player_helper")

local json_helper = require("src.helper.util.json_helper")
local file_helper = require("src.helper.util.file_helper")
local level_loader = require("src.helper.util.level_loader")

local game_manager = {}

game_manager.game = game

function game_manager.create(hero_data_file_path, level_data_file_path, team_data_file_path, main_team)
	-- Load team data
	local teams = json_helper:decode(file_helper.getFileText(team_data_file_path))
	
	-- Load hero data
	local hero_list = player_helper.loadPlayers(hero_data_file_path, teams)
	
	-- Load level data
	local level = level_loader.loadLevel(level_data_file_path)
	
	
	game_manager.game.initialize(hero_list, level)
end

return game_manager
