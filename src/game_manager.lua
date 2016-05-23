

local game = require("src.model.game.game")
local player_helper = require("src.model.game.player_helper")

local json_helper = require("src.helper.util.json_helper")
local file_helper = require("src.helper.util.file_helper")

local game_manager = {}

game_manager.game = game

function game_manager.create(hero_data_file_path, level_data_file_path, team_data_file_path, main_team)
	local teams = json_helper:decode(file_helper.getFileText(team_data_file_path))
	
	local hero_list = player_helper.loadPlayers(hero_data_file_path, teams)
	game_manager.game.initialize(hero_list, nil)
end

return game_manager
