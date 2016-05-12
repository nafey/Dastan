local points = require("src.model.points")
local grids = require("src.model.grids")
local sprites = require("src.helper.sprites")

local geometry = {}



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

-- Get an array of points showing path from p to debug
-- map: a Grid of FloodFill result
-- p: Point for current position
-- d: Point for destination
function geometry.getPath(map, p, d)
	if (map.safe(p.x, p.y) == 0 or map.safe(d.x, d.y) == 0) then
		return nil
	end
	
	local ret = {}
	local curr = points.copyPoint(d)
	table.insert(ret, points.copyPoint(curr))
	
	-- infinity breaker
	local a = 0
	
	while(map.safe(curr.x, curr.y) ~= 1 and a < 10) do
		if(map.safe(curr.x, curr.y - 1) == map.safe(curr.x, curr.y) - 1) then
			-- top
			curr.y = curr.y - 1
		elseif (map.safe(curr.x - 1, curr.y) == map.safe(curr.x, curr.y) - 1) then
			-- left
			curr.x = curr.x - 1
		elseif (map.safe(curr.x, curr.y + 1) == map.safe(curr.x, curr.y) - 1) then
			curr.y = curr.y + 1
		else 
			curr.x = curr.x + 1
		end
		
		table.insert(ret, points.copyPoint(curr))
		a = a + 1
	end
	
	for i = 1, #ret do
		ret[i].print(true)
	end
	
	return ret
	
end


return geometry