
local composer = require( "composer" )

local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local levelloader = require("src.helper.levelloader")
local player_helper = require("src.helper.player_helper")


local teams = {}
local a1 = {}
a1["name"] = "lan"
a1["team"] = 1
a1["start_pos"] = "P1"

local a2 = {}
a2["name"] = "asha"
a2["team"] = 1
a2["start_pos"] = "P2"

local a3 = {}
a3["name"] = "balzar"
a3["team"] = 1
a3["start_pos"] = "P3"


local a4 = {}
a4["name"] = "uruk"
a4["team"] = 2
a4["start_pos"] = "P4"

local a5 = {}
a5["name"] = "feyd"
a5["team"] = 2
a5["start_pos"] = "P5"

local a6 = {}
a6["name"] = "pan"
a6["team"] = 2
a6["start_pos"] = "P6"



table.insert(teams, a1)
table.insert(teams, a2)
table.insert(teams, a3)
table.insert(teams, a4)
table.insert(teams, a5)
table.insert(teams, a6)

local player_list = player_helper.loadPlayers("res/data/char_dat.json", teams)

local points = require("src.model.points")
local grids = require("src.model.grids")

local selected_player = null

local scene = composer.newScene()

local move_result = null

local grid_level1 = grids.createGrid(15, 10)


function scene:create( event )
	
	local levelname =  "arena"
	
	-- The order here is important dont move it up or down as it affects the draw order
	self.view.background = display.newGroup()
	self.view.selection = display.newGroup()
	self.view.player = display.newGroup()

	-- display a background image
	local bg = display.newImageRect("res/maps/" .. levelname .. ".png", display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	self.view.background:insert(bg)

	
	-- load the level
	local raw_level1 = levelloader.loadlevel(levelname)
	local player_pos = levelloader.getPlayerPositions(raw_level1)
	
	
	for i = 1, #player_list do
		local p = player_list[i]
		p.pos = player_pos[p.start_pos]
	end
	
	for i = 1, #player_list do
		local p = player_list[i]
		
		p.sprite = sprites.draw("res/chars/"..p["name"] .. ".png", p.pos.x - 1, p.pos.y - 1, 0, self.view.player)
	end
	
	selected_player = player_helper.selectNextMover(player_list)
	grid_level1 = levelloader.getMovementGrid(raw_level1)
	local grid_level1_with_players = levelloader.markPlayers(grid_level1, player_list, selected_player.name)
	
	move_result = geometry.flood(grid_level1_with_players, selected_player.pos, selected_player.range)
	geometry.drawGrid(move_result, self.view.selection)
	
	--player = sprites.draw("res/chars/sam.png", 4 - 1, 4 - 1, 0, self.view.player)
	
	self.view.background:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	local x = math.floor(event.x / TILE_X)
	local y = math.floor(event.y / TILE_Y)
	
	if (move_result[x + 1][y + 1] ~= 0) then
		selected_player.sprite.x = x * TILE_X
		selected_player.sprite.y = y * TILE_Y
		selected_player.pos.x = x + 1
		selected_player.pos.y = y + 1
		
		-- Remove all the children sprites without removing the parent itself
		for i = 1, scene.view.selection.numChildren do
			scene.view.selection:remove(1)
		end
		
		selected_player = player_helper.selectNextMover(player_list)
		
		
		local grid_level1_with_players = levelloader.markPlayers(grid_level1, player_list, selected_player.name)
		
		move_result = geometry.flood(grid_level1_with_players, selected_player.pos, selected_player["range"])
		geometry.drawGrid(move_result, scene.view.selection)
	end
end



scene:addEventListener( "create", scene )

return scene