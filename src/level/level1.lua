
local composer = require( "composer" )

local player_state = require("src.model.player_state")
local points = require("src.model.points")
local grids = require("src.model.grids")

local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")
local levelloader = require("src.helper.levelloader")
local player_helper = require("src.helper.player_helper")
local draw_helper = require("src.helper.draw_helper")
local animation_manager = require("src.helper.animation_manager")

local selected_player_state = player_state.awaiting_player_move

local main_team = 1


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

local selected_player = nil
local player_list = player_helper.loadPlayers("res/data/char_dat.json", teams)

local levelname = "small"
local raw_level1 = levelloader.loadlevel(levelname)
local move_map = nil

local lock_tap_event = false

local scene = composer.newScene()





local function selectNextCharacter()	
	-- Draw Move Order
	draw_helper.drawMoveOrder(player_list, scene.view.ui.frame.move_order)
	
	-- Draw movement Grid
	selected_player = player_helper.selectNextMover(player_list, false)
	
	local grid_level1 = levelloader.getMovementGrid(raw_level1)
	local grid_level1_with_players = levelloader.markPlayers(grid_level1, player_list, selected_player.name)
	
	move_map = geometry.floodFill(grid_level1_with_players, selected_player.pos, selected_player.range)
	
	draw_helper.drawMovementGrid(move_map, scene.view.selection, player_list, selected_player.team, selected_player.pos)
	
	animation_manager.characterBob(selected_player)
	selected_player_state = player_state.awaiting_player_move
end

function scene:create( event )
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
	self.view.ui.hp = display.newGroup()
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
	
	local player_pos = levelloader.getPlayerPositions(raw_level1)
	
	for i = 1, #player_list do
		local p = player_list[i]
		p.pos = player_pos[p.start_pos]
	end
	
	for i = 1, #player_list do
		local p = player_list[i]
		p.sprite = sprites.draw("res/chars/"..p["name"] .. ".png", p.pos.x - 1, p.pos.y - 1, 0, self.view.player)
	end
	
	selectNextCharacter()
	
	draw_helper.drawHpBars(player_list, main_team, scene.view.ui.hp)
	
	
	self.view.background:addEventListener("tap", tapEvent)	
	Runtime:addEventListener("enterFrame", enterFrame)
end

function tapEvent(event)
	if (lock_tap_event) then
		return
	end

	local x = math.floor(event.x / TILE_X)
	local y = math.floor(event.y / TILE_Y)
		
	
	if (selected_player_state == player_state.awaiting_player_move) then
		if (move_map[x + 1][y + 1] ~= 0) then
			draw_helper.emptyGroup(scene.view.selection)
			
			lock_tap_event = true
			selected_player_state = player_state.awaiting_attack_confirmation
			
			local path = geometry.getPath(move_map, selected_player.pos, points.createPoint(x + 1, y + 1))
			animation_manager.beforeMainCharMove()
			animation_manager.animateCharacterMove(selected_player, path, moveEndCallback)
		end
	elseif (selected_player_state == player_state.awaiting_attack_confirmation) then
		if (player_helper.isEnemyAtPosition(x + 1, y + 1, player_list, selected_player.team) == 1) then
			-- remove image icons
			for i = 1, scene.view.ui.play_area.numChildren do
				scene.view.ui.play_area:remove(1)
			end
			
			local attacked = player_helper.getPlayerAtPosition(x + 1, y + 1, player_list)
			
			player_helper.playerAttack(selected_player, attacked, player_list)
			selectNextCharacter()
			draw_helper.drawHpBars(player_list, main_team, scene.view.ui.hp)
		end
	end	
end

function enterFrame()
	animation_manager.step()
	draw_helper.drawHpBars(player_list, main_team, scene.view.ui.hp)
end

function moveEndCallback() 
	if (geometry.isAdjacentToEnemy(selected_player.pos.x, selected_player.pos.y, player_list, selected_player.team)) then
		draw_helper.drawAttackGrid(selected_player.pos, scene.view.selection, player_list, selected_player.team, scene.view.ui.play_area)
		selected_player_state = player_state.awaiting_attack_confirmation
	else
		selectNextCharacter()
		draw_helper.drawHpBars(player_list, main_team, scene.view.ui.hp)
	end
	
	lock_tap_event = false
end



scene:addEventListener( "create", scene )

return scene