
local composer = require( "composer" )

local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local levelloader = require("src.helper.levelloader")
local player_helper = require("src.helper.player_helper")
local player_state = require("src.model.player_state")

local selected_player_state = player_state.awaiting_player_move


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

local grid_level1 = null

local function drawMoveOrder(player_list)
	local function drawIcon(name, team, position, group)
		local icon_path = "res/chars/" .. name .. "_icon.png"
		
		local frame_path = "res/ui/blue_frame.png"
		if (team == 2) then
			frame_path = "res/ui/red_frame.png"
		end
		
		local x = (position - 1) * TILE_X
		
		local red = display.newImageRect(group, frame_path, TILE_X, TILE_Y)
		red.anchorX = 0
		red.anchorY = 0
		red.x = x
		
		local icon = display.newImageRect(group, icon_path, 24, 20)
		icon.anchorX = 0
		icon. anchorY = 0
		icon.x = x + 4
		icon.y = 6
		
	end
	
	for i = 1, scene.view.ui.frame.move_order.numChildren do
		scene.view.ui.frame.move_order:remove(1)
	end
	
	-- Predict the move_order for 6 turns to draw move order 
	for i = 1, #player_list do 
		local p = player_list[i]
		p.movement_points_later = p.movement_points
	end
	
	local next_6_movers = {}
	
	for i = 1, 6 do 
		p = player_helper.selectNextMover(player_list, true)
		table.insert(next_6_movers, p)
		drawIcon(p.name, p.team, i, scene.view.ui.frame.move_order)
	end
	
end

function scene:create( event )
	
	local levelname =  "small"
	local level_width = 480
	local level_height = 256
	local frame_height = 64
	
	-- Background setup
	-- The order here is important dont move it up or down as it affects the draw order
	self.view.background = display.newGroup()
	self.view.background.bg = display.newImageRect(self.view.background, "res/maps/" .. levelname .. ".png", level_width, level_height )
	self.view.background.bg.anchorX = 0
	self.view.background.bg.anchorY = 0
	
	
	-- Other Display Groups
	self.view.selection = display.newGroup()
	self.view.player = display.newGroup()
	self.view.ui = display.newGroup()
	self.view.ui.play_area = display.newGroup()
	self.view.ui.frame = display.newGroup()
	
	
	self.view.ui.frame.ui_frame = display.newImageRect(self.view.ui.frame, "res/ui/ui_frame.png", level_width, frame_height)
	self.view.ui.frame.ui_frame.anchorX = 0
	self.view.ui.frame.ui_frame.anchorY = 0
	self.view.ui.frame.y = level_height
	
	self.view.ui.frame.move_order = display.newGroup()
	self.view.ui.frame.move_order.y = 19
	self.view.ui.frame.move_order.x = 277
	self.view.ui.frame:insert(self.view.ui.frame.move_order)
	
	
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
	
	-- Draw Move Order
	drawMoveOrder(player_list)
	
	-- Draw movement Grid
	selected_player = player_helper.selectNextMover(player_list, false)
	
	grid_level1 = levelloader.getMovementGrid(raw_level1)
	local grid_level1_with_players = levelloader.markPlayers(grid_level1, player_list, selected_player.name)
	
	move_result = geometry.flood(grid_level1_with_players, selected_player.pos, selected_player.range)
	geometry.drawGrid(move_result, self.view.selection, player_list, selected_player.team)
	
	
	self.view.background:addEventListener("tap", myTapEvent)	
end

function myTapEvent(event)
	local x = math.floor(event.x / TILE_X)
	local y = math.floor(event.y / TILE_Y)
	
	if (selected_player_state == player_state.awaiting_player_move) then
		if (move_result[x + 1][y + 1] ~= 0) then
			selected_player.sprite.x = x * TILE_X
			selected_player.sprite.y = y * TILE_Y
			selected_player.pos.x = x + 1
			selected_player.pos.y = y + 1
			
			if (geometry.isAdjacentToEnemy(selected_player.pos.x, selected_player.pos.y, player_list, selected_player.team)) then
				geometry.drawAttackGrid(selected_player.pos, scene.view.selection, player_list, selected_player.team, scene.view.ui.play_area)
				selected_player_state = player_state.awaiting_attack_confirmation
			else
			
				-- Draw Move Order
				drawMoveOrder(player_list)
				
				-- Draw Selected Player
				selected_player = player_helper.selectNextMover(player_list)		
								
				local grid_level1_with_players = levelloader.markPlayers(grid_level1, player_list, selected_player.name)
				
				move_result = geometry.flood(grid_level1_with_players, selected_player.pos, selected_player["range"])
				geometry.drawGrid(move_result, scene.view.selection, player_list, selected_player.team)
			end
		end
	elseif (selected_player_state == player_state.awaiting_attack_confirmation) then
	
	end
	
	
end



scene:addEventListener( "create", scene )

return scene