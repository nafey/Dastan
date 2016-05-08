local grids = require("src.model.grids")
local sprites = require("src.helper.sprites")
local geometry = require("src.helper.geometry")


local draw_helper = {}

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
function draw_helper.drawMovementGrid(grid, displayGroup, player_list, your_team) 
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
	
	for i = 1, displayGroup.numChildren do
		displayGroup:remove(1)
	end
	
	local adj = grids.createGrid(grid.width, grid.height)
	for i = 1, grid.width do
		for j = 1, grid.height do
			if (grid[i][j] == 1) then
				adj[i][j] = grids.adjacency(grid, i, j)
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
		if (y == 1 or adj[x][y - 1] == 0) then
			rot = 90
		end
		
		--rotate right
		if (x == adj.width or adj[x + 1][y] == 0) then
			rot = 180
		end
		
		--rotate bot
		if (y == adj.height or adj[x][y + 1] == 0) then
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
	
	--where adjacency is 1
	for i = 1, adj.width do
		for j = 1, adj.height do
			if (adj[i][j] == 1) then
				drawEndAura(i , j)
			elseif (adj[i][j] == 2) then
				drawCornerOrPipeAura(i, j)
			elseif (adj[i][j] == 3) then
				drawSideAura(i, j)
			end	
			if (adj[i][j] ~= 0) then
				drawDotAura(i, j)
			end
			
			if (adj[i][j] == 0) then
				if (grid[i][j] == 1) then
					drawSingleAura(i, j)
				end
			end
		end
	end
end

return draw_helper