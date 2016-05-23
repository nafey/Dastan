local game = require("src.model.game.game")
local player_helper = require("src.model.game.player_helper")

local game_manager = {}

game_manager.game = game

function game_manager.create(hero_data_file_path, level_data_file_path, main_team)
	local teams = {}
	local a1 = {}
	a1["name"] = "uruk"
	a1["team"] = 2
	a1["start_pos"] = "P1"

	local a2 = {}
	a2["name"] = "asha"
	a2["team"] = 2
	a2["start_pos"] = "P2"

	local a3 = {}
	a3["name"] = "balzar"
	a3["team"] = 2
	a3["start_pos"] = "P3"


	local a4 = {}
	a4["name"] = "lan"
	a4["team"] = 1
	a4["start_pos"] = "P4"

	local a5 = {}
	a5["name"] = "feyd"
	a5["team"] = 1
	a5["start_pos"] = "P5"

	local a6 = {}
	a6["name"] = "pan"
	a6["team"] = 1
	a6["start_pos"] = "P6"


	table.insert(teams, a1)
	table.insert(teams, a2)
	table.insert(teams, a3)
	table.insert(teams, a4)
	table.insert(teams, a5)
	table.insert(teams, a6)
	
	local hero_list = player_helper.loadPlayers("res/data/char_dat.json", teams)
	game_manager.game.initialize(hero_list, nil)
end

return game_manager
