local points = require("src.model.points")
local grids = require("src.model.grids")
local sprites = require("src.helper.sprites")

local geometry = {}


local function manhattan(x, y, x_, y_)
	return math.abs(x - x_) + math.abs(y - y_)
end



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

function geometry.isAdjacent(x, y, x1, y1) 
	local ret = false
	
	if ((x == x1 - 1) and (y == y1)) then 	
		ret = true
	end
	
	if ((x == x1) and (y == y1 - 1)) then 
		ret = true
	end
	
	if ((x == x1 + 1) and (y == y1)) then 
		ret = true
	end
	
	if ((x == x1) and (y == y1 + 1)) then 
		ret = true
	end
	
	return ret
end

function geometry.isAdjacentToEnemy(x, y, player_list, your_team)
	local ret = false
	for i = 1, #player_list do 
		if (not(ret) and geometry.isAdjacent(x, y, player_list[i].pos.x, player_list[i].pos.y)) then
			if (player_list[i].team ~= your_team) then
				ret = true
			end
		end
	end
	
	return ret
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

--		Variable Never used
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
		
--		Variable i not being used
		i = i + 1
	end
	
	return tested
end

return geometry