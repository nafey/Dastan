
local composer = require( "composer" )

local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local levelloader = require("src.helper.levelloader")
local player_helper = require("src.helper.player_helper")

local points = require("src.model.points")
local grids = require("src.model.grids")

local selected_player = null


local scene = composer.newScene()

local move_result = null

local player_list = {}
local p1  = {};
p1["name"] = "sam"
p1["hp"] = 20
p1["attack"] = 4
p1["speed"] = 16
p1["range"] = 4
p1["start_pos"] = "P1"
p1["pos"] = points.createPoint(0, 0)
p1["team"] = 1
p1["movement_points"] = 0
p1["sprite"] = null

local p2  = {};
p2["name"] = "ben"
p2["hp"] = 25
p2["attack"] = 3
p2["speed"] = 12
p2["range"] = 4
p2["start_pos"] = "P4"
p2["pos"] = points.createPoint(0, 0)
p2["team"] = 2
p2["movement_points"] = 0
p2["sprite"] = null

table.insert(player_list, p1)
table.insert(player_list, p2)

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
	
	grid_level1 = levelloader.getMovementGrid(raw_level1)
	
	for i = 1, #player_list do
		local p = player_list[i]
		p["pos"] = player_pos[p["start_pos"]]
	end
	
	for i = 1, #player_list do
		local p = player_list[i]
		
		p["sprite"] = sprites.draw("res/chars/"..p["name"] .. ".png", p["pos"].x - 1, p["pos"].y - 1, 0, self.view.player)
	end
	
	selected_player = player_helper.selectNextMover(player_list)
	
	move_result = geometry.flood(grid_level1, points.createPoint(selected_player["pos"].x, selected_player["pos"].y), selected_player["range"])
	geometry.drawGrid(move_result, self.view.selection)
	
	--player = sprites.draw("res/chars/sam.png", 4 - 1, 4 - 1, 0, self.view.player)
	
	self.view.background:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	local x = math.floor(event.x / TILE_X)
	local y = math.floor(event.y / TILE_Y)
	
	if (move_result[x + 1][y + 1] ~= 0) then
		selected_player["sprite"].x = x * TILE_X
		selected_player["sprite"].y = y * TILE_Y
		selected_player["pos"].x = x + 1
		selected_player["pos"].y = y + 1
		
		-- Remove all the children sprites without removing the parent itself
		for i = 1, scene.view.selection.numChildren do
			scene.view.selection:remove(1)
		end
		
		selected_player = player_helper.selectNextMover(player_list)
		
		
		move_result = geometry.flood(grid_level1, points.createPoint(selected_player["pos"].x, selected_player["pos"].y), selected_player["range"])
		geometry.drawGrid(move_result, scene.view.selection)
	end
end



scene:addEventListener( "create", scene )

return scene