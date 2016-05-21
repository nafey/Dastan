local grids = require("src.model.geometry.grids")
local geometry = require("src.model.geometry.geometry")
local player_helper = require("src.helper.game.player_helper")

local sprites = require("src.helper.ui.sprites")

local draw_helper = {}

function draw_helper.emptyGroup(displayGroup) 
	for i = 1, displayGroup.numChildren do
		displayGroup:remove(1)
	end
end

function draw_helper.targetCharacters(user, player_list, level, selection, range, displayGroup)
	draw_helper.emptyGroup(displayGroup)

	local g = grids.createGrid(level.width, level.height)
	local area = geometry.floodFill(g, user.pos, range)
	
	local blue = "res/ui/aura_single.png"
	local red = "res/ui/aura_single_red.png"
	local green = "res/ui/aura_single_green.png"
	
	for i = 1, #player_list do
		local point_val = area[player_list[i].pos.x][player_list[i].pos.y]
		local png = ""
		local selectCriteriaFlag = true
		
		if (point_val ~= 0) then
			if (point_val == 1) then
				png = blue
			elseif (point_val > 1) then
				if (user.team == player_list[i].team) then
					png = green
					if (selection == "enemy") then
						selectCriteriaFlag = false
					end
				else
					png = red
					if (selection == "ally") then
						selectCriteriaFlag = false
					end
				end
			end
			if (selectCriteriaFlag) then
				sprites.draw(png, player_list[i].pos.x - 1, player_list[i].pos.y - 1, 0, displayGroup)
			end
		end
	end
end

function draw_helper.drawButtons(displayGroup, character)
	draw_helper.emptyGroup(displayGroup.button1)
	draw_helper.emptyGroup(displayGroup.button2)
	
	if (character.ability_1 == nil or character.ability_2 == nil) then
		return
	end
	local open = "res/ui/button_open.png"
	local down = "res/ui/button_down.png"

	local icon1 = "res/ui/" .. character.ability_1.name .. ".png"
	local icon2 = "res/ui/" .. character.ability_2.name .. ".png"
	
	if (character.ability_1.open) then
		local button1 = sprites.drawSprite(displayGroup.button1, open, 0, 0, 45, 49)
		local button1_icon = sprites.drawSprite(displayGroup.button1, icon1, 6, 6, 33, 33)
	else
		local button1 = sprites.drawSprite(displayGroup.button1, down, 0, 4, 45, 45)
		local button1_icon = sprites.drawSprite(displayGroup.button1, icon1, 6, 10, 33, 33)
	end
	
	if (character.ability_2.open) then
		local button2 = sprites.drawSprite(displayGroup.button2, open, 0, 0, 45, 49)
		local button2_icon = sprites.drawSprite(displayGroup.button2, icon2, 6, 6, 33, 33)
	else
		local button2 = sprites.drawSprite(displayGroup.button2, down, 0, 4, 45, 45)
		local button2_icon = sprites.drawSprite(displayGroup.button2, icon2, 6, 10, 33, 33)
	end
end

function draw_helper.drawFace(displayGroup, character)
	draw_helper.emptyGroup(displayGroup)
	
	local png = "res/chars/" .. character.name .. "_icon.png"
	local face = display.newImageRect(displayGroup, png, 48, 40)
	face.anchorX = 0
	face.anchorY = 0
end

function draw_helper.writeStuff(displayGroup, character)
	draw_helper.emptyGroup(displayGroup)
	local text_options = {
		parent = displayGroup,
		text = "Name:",
		font = "AR JULIAN",
		width = 70,
		align = "center",
		fontSize = "14",
		x = 0,
		y = 0
	}
	
	-- NAME LABEL
	text_options.x = 20
	text_options.y = 8
	
	local name_lbl = display.newText(text_options)
	name_lbl:setFillColor(0, 0, 0)
	
	-- ATTACK LABEL
	text_options.text = "Attack:"
	text_options.x = 26
	text_options.y = 22
	
	local attack_lbl = display.newText(text_options)
	attack_lbl:setFillColor(0, 0, 0)
	
	
	-- HP LABEL
	text_options.text = "HP:"
	text_options.x = 12
	text_options.y = 36
	
	local hp_lbl = display.newText(text_options)
	hp_lbl:setFillColor(0, 0, 0)
	
	
	-- NAME TEXT 
	text_options.text = character.label

	text_options.x = 60
	text_options.y = 8
	
	local name = display.newText(text_options)
	if (character.team == 1) then
		name:setFillColor(0, 1, 0)
	else
		name:setFillColor(1, 0, 0)
	end
	
	-- ATTACK TEXT
	text_options.text = character.attack
	
	text_options.x = 60
	text_options.y = 22
	
	local attack = display.newText(text_options)
	attack:setFillColor(0, 0, 0)
	
	-- HP TEXT
	text_options.text = character.hp .. " / " .. character.max_hp
	
	text_options.x = 60
	text_options.y = 36
	
	local hp = display.newText(text_options)
	hp:setFillColor(0, 0, 0)
end

function draw_helper.drawHpBars(player_list, main_team, displayGroup)
	draw_helper.emptyGroup(displayGroup)
			

	for i = 1, #player_list do 
		local p = player_list[i]
		local healthBar = display.newRect(displayGroup, (p.pos.x - 1)  * 32, (p.pos.y - 1) * 32 + 28, 32 * (p.hp / p.max_hp), 4)
		healthBar.anchorX = 0
		healthBar.anchorY = 0
		if (p.team == main_team) then
			healthBar:setFillColor( 000/255, 255/255, 0/255 )
		else
			healthBar:setFillColor( 255/255, 000/255, 0/255 )
		end
	end
end

-- Draw Move order thingy
function draw_helper.drawMoveOrder(player_list, displayGroup)
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
	
	draw_helper.emptyGroup(displayGroup)
	
	-- Predict the move_order for 6 turns to draw move order 
	for i = 1, #player_list do 
		local p = player_list[i]
		p.movement_points_later = p.movement_points
	end
	
	local next_6_movers = {}
	
	for i = 1, 6 do 
		p = player_helper.selectNextMover(player_list, true)
		table.insert(next_6_movers, p)
		drawIcon(p.name, p.team, i, displayGroup)
	end
	
end

function draw_helper.drawAttackGrid(pos, displayGroup, player_list, your_team, attackIconDisplayGroup)
	for i = 1, displayGroup.numChildren do
		displayGroup:remove(1)
	end
	
	local blue = "res/ui/aura_single.png"
	local red = "res/ui/aura_single_red.png"
	
	local attack_icon = "res/ui/attack_icon.png"
	
	sprites.draw(blue, pos.x - 1, pos.y - 1, 0, displayGroup)
	
	for i = 1, #player_list do
		if (geometry.isAdjacent(pos.x, pos.y, player_list[i].pos.x, player_list[i].pos.y)) then
			if (player_list[i].team ~= your_team) then
				sprites.draw(red, player_list[i].pos.x - 1, player_list[i].pos.y - 1, 0, displayGroup)
				
				if (attackIconDisplayGroup ~= nil) then
					sprites.draw(attack_icon, player_list[i].pos.x - 1, player_list[i].pos.y - 1, 0, attackIconDisplayGroup)
				end
			end
		end
	end
end

-- Being a passed a grid of accepted tiles draw the selected area
-- Mark the areas next to enemy players in red
-- send one mark_pos to highlight it in the grid
function draw_helper.drawMovementGrid(g, displayGroup, player_list, your_team, mark_pos) 
	local path_dot = "res/ui/aura_dot.png"
	local path_corner = "res/ui/aura_corner.png"
	local path_end = "res/ui/aura_end.png" 
	local path_pipe = "res/ui/aura_pipe.png"
	local path_side = "res/ui/aura_side.png"
	local path_single = "res/ui/aura_single.png"
	
	local path_dot_red = "res/ui/aura_dot_red.png"
	local path_corner_red = "res/ui/aura_corner_red.png"
	local path_end_red = "res/ui/aura_end_red.png"
	local path_pipe_red = "res/ui/aura_pipe_red.png"
	local path_side_red = "res/ui/aura_side_red.png"
	local path_single_red = "res/ui/aura_single_red.png"
	
	local grid = grids.copyGrid(g)
	for j = 1, grid.height do
		for i = 1, grid.width do
			if (grid.safe(i, j) ~= 0) then
				grid.put(i, j, 1)
			end
		end
	end			
	
	for i = 1, displayGroup.numChildren do
		displayGroup:remove(1)
	end
	
	local adj = grids.createGrid(grid.width, grid.height)
	for i = 1, grid.width do
		for j = 1, grid.height do
			if (grid.safe(i, j) == 1) then
				adj.put(i, j, grids.adjacency(grid, i, j))
			end
		end
	end
		
	local function drawEndAura(x, y) 
		local png = path_end
		
		if (geometry.isAdjacentToEnemy(x, y, player_list, your_team)) then
			png = path_end_red
		end
		
		local rot = 0
		
		--rotate top
		if (adj.safe(x, y + 1) ~= 0) then
			rot = 90
		end
		
		--rotate right
		if (adj.safe(x - 1, y) ~= 0) then
			rot = 180
		end
		
		--rotate bot
		if (adj.safe(x, y - 1) ~= 0) then
			rot = 270
		end
			
		sprites.draw(png, x - 1, y - 1, rot, displayGroup)
	end
	
		
	local function drawCornerOrPipeAura(x, y)
		local rot = 0
		local png = path_corner
		if (geometry.isAdjacentToEnemy(x, y, player_list, your_team)) then
			png = path_corner_red
		end
		
		-- determine if pipe or corner
		if (adj.safe(x - 1, y) ~= 0) then
			if (adj.safe(x + 1, y) ~= 0) then
				-- identified hort pipe
				rot = 90
				png = path_pipe
				
				if (geometry.isAdjacentToEnemy(x, y, player_list, your_team)) then
					png = path_pipe_red
				end
			else
				-- identified corner find rot now
				if (adj.safe(x, y - 1) ~= 0) then
					-- bottom right corner
					rot = 180
				else 
					-- bound to be top right corner
					rot = 90
				end
			end
		elseif (adj.safe(x + 1, y) ~= 0) then
			-- identified corner find rot now
			if (adj.safe(x, y - 1) ~= 0) then
				-- bottom left corner
				rot = 270
			end -- no need for else as top left is the default case
		else
			-- identified vert pipe
			png = path_pipe
			if (geometry.isAdjacentToEnemy(x, y, player_list, your_team)) then
				png = path_pipe_red
			end
		end
		
		
		
		-- decreasing by 1 because the screen is zero based and adj is 1 based
		sprites.draw(png, x - 1, y - 1, rot, displayGroup)
	end
	
	local function drawSideAura(x, y)
		local rot = 0
		
		local png = path_side
		if (geometry.isAdjacentToEnemy(x, y, player_list, your_team)) then
			png = path_side_red
		end
		
		--rotate top
		if (y == 1 or adj.safe(x, y - 1) == 0) then
			rot = 90
		end
		
		--rotate right
		if (x == adj.width or adj.safe(x + 1, y) == 0) then
			rot = 180
		end
		
		--rotate bot
		if (y == adj.height or adj.safe(x, y + 1) == 0) then
			rot = 270
		end
		
		-- decreasing by 1 because the screen is zero based and adj is 1 based
		sprites.draw(png, x - 1, y - 1, rot, displayGroup)
	end
	
	local function drawDotAura(x, y)
		local rot = 0	
		--local png = path_dot
		
		-- top left 
		if ((adj.safe(x, y - 1) ~= 0) and (adj.safe(x - 1, y) ~= 0)) then
			if (adj.safe(x - 1, y - 1) == 0) then
				-- decreasing by 1 because the screen is zero based and adj is 1 based
				sprites.draw(path_dot, x - 1, y - 1, rot, displayGroup)
			end
		end
		
		-- top right 
		if ((adj.safe(x, y - 1) ~= 0) and (adj.safe(x + 1, y) ~= 0)) then
			if (adj.safe(x + 1, y - 1) == 0) then
				rot = 90
				-- decreasing by 1 because the screen is zero based and adj is 1 based
				sprites.draw(path_dot, x - 1, y - 1, rot, displayGroup)
			end
		end
		
		-- bot right 
		if ((adj.safe(x + 1, y) ~= 0) and (adj.safe(x, y + 1) ~= 0)) then
					
			if (adj.safe(x + 1, y + 1) == 0) then
				rot = 180
				-- decreasing by 1 because the screen is zero based and adj is 1 based
				sprites.draw(path_dot, x - 1, y - 1, rot, displayGroup)
			end
		end
		
		-- bot left 
		if ((adj.safe(x, y + 1) ~= 0) and (adj.safe(x - 1, y) ~= 0)) then
			if (adj.safe(x - 1, y + 1) == 0) then
				rot = 270
				-- decreasing by 1 because the screen is zero based and adj is 1 based
				sprites.draw(path_dot, x - 1, y - 1, rot, displayGroup)
			end
		end
	end
	
	local function drawSingleAura(x, y)
		local png = path_single
		if (geometry.isAdjacentToEnemy(x, y, player_list, your_team)) then
			png = path_side_red
		end
		
		sprites.draw(png, x - 1, y - 1, 0, displayGroup)
	end
	
	adj.print()
	
	--where adjacency is 1
	for i = 1, adj.width do
		for j = 1, adj.height do
			if (adj.safe(i, j) == 1) then
				drawEndAura(i , j)
			elseif (adj.safe(i, j) == 2) then
				drawCornerOrPipeAura(i, j)
			elseif (adj.safe(i, j) == 3) then
				drawSideAura(i, j)
			end	
			if (adj.safe(i, j) ~= 0) then
				drawDotAura(i, j)
			end
			
			if (adj.safe(i, j) == 0) then
				if (grid.safe(i, j) == 1) then
					drawSingleAura(i, j)
				end
			end
			
			if (mark_pos~= nil) then
				if ((i == mark_pos.x) and (j == mark_pos.y)) then
					drawSingleAura(i, j)
				end
			end
			
			
		end
	end
end

return draw_helper