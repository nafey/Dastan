local points = require("src.model.points")
local grids = require("src.model.grids")
local sprites = require("src.helper.sprites")

local geometry = {}


local function manhattan(x, y, x_, y_)
	return math.abs(x - x_) + math.abs(y - y_)
end

-- Decides which tiles are accessible from a given point
-- Grid represents the active map
-- p is the character position
-- range is the distance it can cover in manhattan distance
function geometry.flood(grid, p, range) 

	--[[
		tested table cell values represent the following
		0: untested, unencountered squares
		0.5: to test and also available in testnext
			at the end no cell with this value should remain
		1: Accepted
		-1: Rejected
	]]
	local tested = grids.createGrid(grid.width, grid.height)
	local testnext = {p}
	
	local i = 0
	while ((#testnext > 0)) do
		local current = testnext[1]
		
		table.remove(testnext, 1)

		a = 1
		--if the location is not obstructed and not far
		if (grid[p.x][p.y] == 0) and (manhattan(p.x, p.y, current.x, current.y) <= range) then
			tested[current.x][current.y] = 1
			
			-- check top
			if (current.y ~= 1) then
				if (grid[current.x][current.y - 1] == 0) and(tested[current.x][current.y - 1] == 0) then
					tested[current.x][current.y - 1] = 0.5
					table.insert(testnext, points.createPoint(current.x, current.y - 1))
				end
			end
			-- check left
			if (current.x ~= 1) then
				if (grid[current.x - 1][current.y] == 0) and(tested[current.x - 1][current.y] == 0) then
					tested[current.x - 1][current.y] = 0.5
					table.insert(testnext, points.createPoint(current.x - 1, current.y))
				end
			end
			
			-- check bottom
			if (current.y ~= grid.height) then
				if (grid[current.x][current.y + 1] == 0) and(tested[current.x][current.y + 1] == 0) then
					tested[current.x][current.y + 1] = 0.5
					table.insert(testnext, points.createPoint(current.x, current.y + 1))
				end
			end
			
			-- check right
			if (current.x ~= grid.width) then
				if (grid[current.x + 1][current.y] == 0) and(tested[current.x + 1][current.y] == 0) then
					tested[current.x + 1][current.y] = 0.5
					table.insert(testnext, points.createPoint(current.x + 1, current.y))
				end
			end
		
		else 
			tested[current.x][current.y] = -1
		end
		
		
		i = i + 1
	end
	
	return tested
end
--[[
0 0 -1 1 1 1 -1 0 0 0 0 0 0 0 0 
0 -1 1 1 0 0 1 -1 0 0 0 0 0 0 0 
-1 1 1 1 0 1 1 1 -1 0 0 0 0 0 0 
1 1 1 1 0 0 1 1 1 -1 0 0 0 0 0 
1 1 1 1 1 1 1 1 1 1 -1 0 0 0 0 
1 1 1 1 1 1 1 1 1 -1 0 0 0 0 0 
-1 1 1 1 1 1 1 1 -1 0 0 0 0 0 0 
0 -1 1 1 1 1 1 -1 0 0 0 0 0 0 0 
0 0 -1 1 1 1 -1 0 0 0 0 0 0 0 0 
0 0 0 -1 1 -1 0 0 0 0 0 0 0 0 0 
]]
-- Checks number of 1 value grid adjacent the particular position
-- called by the draw grid function
local function adjacency(grid, x, y)
	local ret = 0
	
	if (grid[x][y] == 1) then
		-- check top
		if (grid.safe(x, y - 1) == 1) then
			ret = ret + 1
		end
		
		-- check left
		if (grid.safe(x - 1, y) == 1) then
			ret = ret + 1
		end
		
		-- check bottom
			if (grid.safe(x, y + 1) == 1) then
				ret = ret + 1
			end
		
		-- check right
		if (grid.safe(x + 1, y) == 1) then
			ret = ret + 1
		end
	end
	
	return ret
end



--Being a passed a grid of accepted tiles draw the selected area
function geometry.drawGrid(grid) 
	local adj = grids.createGrid(grid.width, grid.height)
	for i = 1, grid.width do
		for j = 1, grid.height do
			if (grid[i][j] == 1) then
				adj[i][j] = adjacency(grid, i, j)
			end
		end
	end
	
	adj.print()
	
	
	local function drawEndAura(x, y) 
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
		
		-- decreasing by 1 because the screen is zero based and adj is 1 based
		sprites.draw("res/aura_end.png", x - 1, y - 1, rot)
	end
	
		
	local function drawCornerOrPipeAura(x, y)
		rot = 0
		png = "res/aura_corner.png"
		
		-- determine if pipe or corner
		if (adj.safe(x - 1, y) ~= 0) then
			if (adj.safe(x + 1, y) ~= 0) then
				-- identified hort pipe
				rot = 90
				png = "res/aura_pipe.png"
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
			png = "res/aura_pipe.png"
		end
		
		
		
		-- decreasing by 1 because the screen is zero based and adj is 1 based
		sprites.draw(png, x - 1, y - 1, rot)
	end
	
	local function drawEdgeAura(x, y)
		local rot = 0
		
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
		sprites.draw("res/aura_side.png", x - 1, y - 1, rot)
	end
	
	local function drawDotAura(x, y)
	
	end
	
	--where adjacency is 1
	for i = 1, adj.width do
		for j = 1, adj.height do
			if (adj[i][j] == 1) then
				drawEndAura(i , j)
			elseif (adj[i][j] == 2) then
				drawCornerOrPipeAura(i, j)
			elseif (adj[i][j] == 3) then
				drawEdgeAura(i, j)
			end
		end
	end
end


return geometry