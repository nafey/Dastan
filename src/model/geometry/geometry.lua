local points = require("src.model.geometry.points")
local grids = require("src.model.geometry.grids")

local geometry = {}

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
		return points.create(index % grid.width + 1 , math.floor(index / grid.width) + 1 )
	end
	for j = 1, grid.height do
		for i = 1, grid.width do
			if (grid.safe(i, j) == 1) then
				grid.put(i, j, -1)
			end
			
			if (i == p.x and j == p.y) then
				grid.put(i, j, 1)
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
		
		for dir = 1, 4 do
			-- TODO: decide if this needs to be reworked
			local pt_adj = points.rotate(pt, dir)
			if (pt.y == 1 and dir == 1) then
				-- skip
			elseif (pt.x == 1 and dir == 2) then
				-- skip
			elseif (pt.y == grid.height and dir == 3) then
				-- skip
			elseif (pt.x == grid.width and dir == 4) then
				-- skip
			elseif (grid.rotate(pt.x, pt.y, dir) == 0) then
				local idx = toIndex(pt_adj.x, pt_adj.y)
				if (not open_lookup[tostring(idx)] and not closed_lookup[tostring(idx)]) then
					grid.rotate_put(pt.x, pt.y, dir, grid.safe(pt.x, pt.y) + 1)
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
				grid.put(i, j, 0)
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
	local curr = points.copy(d)
	table.insert(ret, points.copy(curr))
	
	-- infinity breaker
	local a = 0
	
	while(tonumber(map.safe(curr.x, curr.y)) ~= 1) do
		local found_flag = false
		for dir = 1, 4 do
			if (not found_flag) then
				local curr_adj = points.rotate(curr, dir)
				if (map.safe(curr_adj.x, curr_adj.y) == map.safe(curr.x, curr.y) - 1) then
					curr = curr_adj
					found_flag = true
				end
			end
		end		
		table.insert(ret,points.copy(curr))
		a = a + 1
	end
	
	local ret_reversed = {}
	
	
	for i = #ret, 1, -1 do
		table.insert(ret_reversed, ret[i])
	end
	
	return ret_reversed
end

return geometry