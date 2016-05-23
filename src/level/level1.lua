local composer = require( "composer" )

local game_manager = require("src.game_manager")

local player_state = require("src.model.game.player_state")
local player_helper = require("src.model.game.player_helper")

local points = require("src.model.geometry.points")
local grids = require("src.model.geometry.grids")
local geometry = require("src.model.geometry.geometry")

local levelloader = require("src.helper.util.level_loader")

local sprites = require("src.helper.ui.sprites")
local draw_helper = require("src.helper.ui.draw_helper")
local animation_manager = require("src.helper.ui.animation_manager")

local selected_player_state = player_state.awaiting_player_move

local main_team = 1


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

local selected_player = nil
local targeted_player = nil

local affected = nil

local used_ability = nil

local player_list = player_helper.loadPlayers("res/data/char_dat.json", teams)

local levelname = "small"
local levelpath = "res/maps/small.csv"
local raw_level1 = levelloader.loadLevel(levelpath)
local move_map = nil

local lock_tap_event = false


local scene = composer.newScene()

game_manager.create(scene, "res/data/char_dat.json", "res/maps/small.csv", "res/data/team_dat.json", 1)

return scene