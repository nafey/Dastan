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

function geometry.floodFill(g, p, range) 
	local grid = grids.copyGrid(g)
	local function toIndex(i, j) 
		return (j - 1) * grid.width + (i - 1)
	end
	
	local function toPoint(index)
		return points.createPoint(index % grid.width + 1 , math.floor(index / grid.width) + 1 )
	end
	for j = 1, grid.height do
		for i = 1, grid.width do
			if (grid.safe(i, j) == 1) then
				grid[i][j] = -1
			end
			
			if (i == p.x and j == p.y) then
				grid[i][j] = 1
			end
							
		end
	end
		
	local open_list = {}
	local open_lookup = {}
	table.insert(open_list, toIndex(p.x, p.y))
	table.insert(open_lookup, tostring(toIndex(p.x, p.y)), true)
	
	local closed_lookup = {}
	
	-- infinity breaker
	-- change while condition to something like (#open_list > 0 and a < 40) for debug
	local a = 0
	
	print("here")
	
	while (#open_list > 0) do
		local pop = table.remove(open_list, 1)
		
		open_lookup[tostring(pop)] = false
		table.insert(closed_lookup, tostring(pop), true)
		
		local pt = toPoint(pop)
		
		if (grid.safe(pt.x, pt.y) > range) then
			break
		end
		
		-- top
		if (pt.y ~= 1) then
			if (grid.safe(pt.x , pt.y - 1) == 0) then
				local idx = toIndex(pt.x, pt.y - 1)
				
				if (not open_lookup[tostring(idx)] and not closed_lookup[tostring(idx)]) then
					grid[pt.x][pt.y - 1] = grid[pt.x][pt.y] + 1
					table.insert(open_lookup, tostring(idx), true)
					table.insert(open_list, idx)
				end
			end
		end
		
		-- left
		if (pt.x ~= 1) then
			if (grid.safe(pt.x - 1, pt.y ) == 0) then
				local idx = toIndex(pt.x - 1, pt.y)
				
				if (not open_lookup[tostring(idx)] and not closed_lookup[tostring(idx)]) then
					grid[pt.x - 1][pt.y] = grid[pt.x][pt.y] + 1

					table.insert(open_lookup, tostring(idx), true)
					table.insert(open_list, idx)
				end
			end
		end
		
		-- bot
		if (pt.y ~= grid.height) then
			if (grid.safe(pt.x, pt.y + 1) == 0) then
				local idx = toIndex(pt.x, pt.y + 1)
				
				if (not open_lookup[tostring(idx)] and not closed_lookup[tostring(idx)]) then
					grid[pt.x][pt.y + 1] = grid[pt.x][pt.y] + 1
					table.insert(open_lookup, tostring(idx), true)
					table.insert(open_list, idx)
				end
			end
		end
		
		-- right
		if (pt.x ~= grid.width) then
			if (grid.safe(pt.x + 1, pt.y) == 0) then
				local idx = toIndex(pt.x + 1, pt.y)
				
				if (not open_lookup[tostring(idx)] and not closed_lookup[tostring(idx)]) then
					grid[pt.x + 1][pt.y] = grid[pt.x][pt.y] + 1
					table.insert(open_lookup, tostring(idx), true)
					table.insert(open_list, idx)
				end
			end
		end
		
		a = a + 1
	end
	
	
	for j = 1, grid.height do
		for i = 1, grid.width do
			if (grid.safe(i, j) == -1) then
				grid[i][j] = 0
			end
		end
	end
	
	return grid
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