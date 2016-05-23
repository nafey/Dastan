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
local raw_level1 = levelloader.loadlevel(levelname)
local move_map = nil

local lock_tap_event = false

game_manager.create("res/data/char_dat.json", "res/maps/small.png", "res/data/team_dat.json", 1)



local scene = composer.newScene()

local function setupUI(character)
	draw_helper.drawMovementGrid(move_map, scene.view.selection, player_list, character.team, character.pos)
	draw_helper.drawFace(scene.view.ui.frame.char_dat.face, character)
	draw_helper.writeStuff(scene.view.ui.frame.char_dat.desc, character)
	draw_helper.drawButtons(scene.view.ui.frame.button, character)
end

local function selectCharacter(character) 
	local grid_level1 = levelloader.getMovementGrid(raw_level1)
	local grid_level1_with_players = levelloader.markPlayers(grid_level1, player_list, selected_player.name)
	
	move_map = geometry.floodFill(grid_level1_with_players, selected_player.pos, selected_player.range)
	
	setupUI(selected_player)
	
	animation_manager.characterBob(selected_player)
	selected_player_state = player_state.awaiting_player_move
end

local function selectNextCharacter()	
	-- Draw Move Order
	draw_helper.drawMoveOrder(player_list, scene.view.ui.frame.move_order)
	
	-- Draw movement Grid
	selected_player = player_helper.selectNextMover(player_list, false)
	selectCharacter(selected_player)
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
	
	-- UI FRAME SETUP
	
	self.view.ui.frame.ui_frame = display.newImageRect(self.view.ui.frame, "res/ui/ui_frame.png", level_width, frame_height)
	self.view.ui.frame.ui_frame.anchorX = 0
	self.view.ui.frame.ui_frame.anchorY = 0
	self.view.ui.frame.y = level_height
	
		-- CHAR DATA
	self.view.ui.frame.char_dat = display.newGroup()
	self.view.ui.frame:insert(self.view.ui.frame.char_dat)
			
			-- FACE
	self.view.ui.frame.char_dat.face = display.newGroup()
	self.view.ui.frame.char_dat.face.x = 13
	self.view.ui.frame.char_dat.face.y = 13
	self.view.ui.frame.char_dat:insert(self.view.ui.frame.char_dat.face)
			
			-- DESC
	self.view.ui.frame.char_dat.desc = display.newGroup()
	self.view.ui.frame.char_dat.desc.x = 63
	self.view.ui.frame.char_dat.desc.y = 13
	self.view.ui.frame.char_dat:insert(self.view.ui.frame.char_dat.desc)
	
		-- MOVE ORDER
	self.view.ui.frame.move_order = display.newGroup()
	self.view.ui.frame.move_order.y = 19
	self.view.ui.frame.move_order.x = 277
	self.view.ui.frame:insert(self.view.ui.frame.move_order)
	
		-- BUTTON
	self.view.ui.frame.button = display.newGroup()
	self.view.ui.frame.button.x = 170
	self.view.ui.frame.button.y = 7
	self.view.ui.frame:insert(self.view.ui.frame.button)
			
			-- BUTTON 1
	self.view.ui.frame.button.button1 = display.newGroup()
	self.view.ui.frame.button:insert(self.view.ui.frame.button.button1)
	self.view.ui.frame.button.button1:addEventListener("tap", ability1click)
	
			-- BUTTON 2
	self.view.ui.frame.button.button2 = display.newGroup()
	self.view.ui.frame.button.button2.x = 50
	self.view.ui.frame.button:insert(self.view.ui.frame.button.button2)
	self.view.ui.frame.button.button2:addEventListener("tap", ability2click)
	
	
	
	
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
	animation_manager.debug(selected_player)
	
	
	self.view.background:addEventListener("tap", tapEvent)	
	Runtime:addEventListener("enterFrame", enterFrame)
end

function tapEvent(event)
	if (lock_tap_event) then
		return
	end

	local x = math.floor(event.x / TILE_X) + 1
	local y = math.floor(event.y / TILE_Y) + 1
		
	
	if (selected_player_state == player_state.awaiting_player_move) then
		--print(1)
		if (move_map.safe(x, y) ~= 0) then
			--print(2)
			animation_manager.stopBob()
			lock_tap_event = true
			
			--print(3)
			draw_helper.emptyGroup(scene.view.selection)
			
			--print(4)
			local path = geometry.getPath(move_map, selected_player.pos, points.createPoint(x, y))
			selected_player_state = player_state.awaiting_attack_confirmation
			
			--print(5)
			animation_manager.animateCharacterMove(selected_player, path, moveEndCallback)
		end
	elseif (selected_player_state == player_state.awaiting_attack_confirmation) then
		if (player_helper.isEnemyAtPosition(x, y, player_list, selected_player.team) == 1) then
			animation_manager.stopBob()
			lock_tap_event = true
			
			-- remove image icons
			draw_helper.emptyGroup(scene.view.ui.play_area)
			
			targeted_player = player_helper.getPlayerAtPosition(x, y, player_list)
			animation_manager.animateCharacterAttack(selected_player, targeted_player, attackDoneCallback)
		end
	elseif (selected_player_state == player_state.awaiting_ability_target_confirmation) then
		if (player_helper.isTargetable(selected_player, player_list, used_ability, x, y)) then
			lock_tap_event = true
			
			targeted_player = player_helper.getPlayerAtPosition(x, y, player_list)
			animation_manager.animateTargetedAbility(selected_player, targeted_player, used_ability, targetAbilityCallback)
			
		end
	end
end

function enterFrame()
	--if (used_ability == nil) then
	--	print("nil")
	--else
	--	print(used_ability.name)
	--end
	
	animation_manager.step()
	draw_helper.drawHpBars(player_list, main_team, scene.view.ui.hp)
end

function triggeredAbilityCallback()
	
	player_helper.useTriggeredAbility(selected_player, affected, used_ability)
	used_ability.open = true
	affected = nil
	used_ability = nil
	
	draw_helper.drawButtons(scene.view.ui.frame.button, selected_player)
	
	lock_tap_event = false 
	selectNextCharacter()
end

function targetAbilityCallback()	
	
	player_helper.useTargetedAbility(selected_player, targeted_player, used_ability)
	used_ability.open = true
	
	draw_helper.drawButtons(scene.view.ui.frame.button, selected_player)
	targeted_player = nil
	used_ability = nil
	
	lock_tap_event = false
	selectNextCharacter()
end

function moveEndCallback() 
	if (geometry.isAdjacentToEnemy(selected_player.pos.x, selected_player.pos.y, player_list, selected_player.team)) then
		draw_helper.drawAttackGrid(selected_player.pos, scene.view.selection, player_list, selected_player.team, scene.view.ui.play_area)
		selected_player_state = player_state.awaiting_attack_confirmation
	else
		selectNextCharacter()
	end
	
	lock_tap_event = false
end

function attackDoneCallback()
	player_helper.playerAttack(selected_player, targeted_player, player_list)
	targeted_player = nil
	
	selectNextCharacter()
	
	lock_tap_event = false
end

function abilityClick(ability)
	if (selected_player_state ~= player_state.awaiting_player_move) then
		return nil
	end
	
	if (ability.type == "targeted") then
		if (selected_player_state ~= player_state.awaiting_ability_target_confirmation) then
			ability.open = false
			draw_helper.drawButtons(scene.view.ui.frame.button, selected_player)
			
			animation_manager.stopBob()
			
			draw_helper.targetCharacters(selected_player, player_list, raw_level1, 
											ability.select, ability.range,
											scene.view.selection)
			used_ability = ability
			selected_player_state = player_state.awaiting_ability_target_confirmation
			
		else
			selected_player_state = player_state.awaiting_player_move
			ability.open = true
			selectCharacter(selected_player)
		end
	elseif (ability.type == "triggered") then
		ability.open = false
		draw_helper.drawButtons(scene.view.ui.frame.button, selected_player)
		
		used_ability = ability
		
		lock_tap_event = true
		
		draw_helper.emptyGroup(scene.view.selection)
		
		affected = player_helper.findInRange(selected_player, player_list, ability.range, ability.select)
				
		animation_manager.stopBob()
		animation_manager.animateTriggeredAbility(selected_player, affected, used_ability, triggeredAbilityCallback)	
	end
end

function ability1click()
	abilityClick(selected_player.ability_1)
end

function ability2click()
	abilityClick(selected_player.ability_2)
end



scene:addEventListener( "create", scene )

return scene