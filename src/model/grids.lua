local points = require("src.model.points")

local grids = {}

function grids.createGrid(size_x, size_y) 
	local g = {}
	g.width = size_x
	g.height = size_y
	
	g.size = g.width * g.height
	for i = 1, g.size do
		g[i] = 0
	end
	
	function g.print()
		for j = 1, size_y do
			for i = 1, size_x do 
				io.write(g.safe(i, j) .. " ")
			end
			
			io.write("\n")
		end
	end
	
	function g.get(i, j) 
		local ret = 0
		ret = g[(i - 1) + (j - 1) * g.width + 1]
		
		return ret
	end
	
	-- throw no error get
	function g.safe(i, j)
		local ret = 0
		if ((i >= 1 and i <= g.width) and (j >= 1 and j <= g.height)) then
			ret = g.get(i, j)
		end
		
		return ret
	end
	
	function g.set(i, j, val) 
		g[(i - 1) + (j - 1) * g.width + 1] = val
	end
	
	-- throw no error set
	function g.put(i, j, val)
		if ((i >= 1 and i <= g.width) and (j >= 1 and j <= g.height)) then
			g.set(i, j, val)
		end
	end
	
	-- dir can be one of the following
	-- 1 : top i.e. (i, j - 1)
	-- 2: left i.e. (i - 1, j)
	-- 3 : bot i.e. (i, j + 1)
	-- anything else : right i.e (i + 1, j)
	function g.rotate(i, j, dir)
		local rot = points.rotate(points.createPoint(i, j), dir)
		return g.safe(rot.x, rot.y)
	end
	
	function g.rotate_put(i, j, dir, val) 
		local rot = points.rotate(points.createPoint(i, j), dir)
		g.put(rot.x, rot.y, val)
	end
	
	return g
end

function grids.copyGrid(grid) 
	local g = grids.createGrid(grid.width, grid.height)
	
	for i = 1, grid.size do
		g[i] = grid[i]
	end
	
	return g
end

-- Checks number of 1 value grid adjacent the particular position
-- called by the draw grid function
function grids.adjacency(grid, x, y)
	local ret = 0
	
	if (grid.safe(x, y) == 1) then
		for dir = 1, 4 do
			if (grid.rotate(x, y, dir) == 1) then	
				ret = ret + 1
			end
		end
	end
	
--	if (grid[x][y] == 1) then
--		-- check top
--		if (grid.safe(x, y - 1) == 1) then
--			ret = ret + 1
--		end
--		
--		-- check left
--		if (grid.safe(x - 1, y) == 1) then
--			ret = ret + 1
--		end
--		
--		-- check bottom
--			if (grid.safe(x, y + 1) == 1) then
--				ret = ret + 1
--			end
--		
--		-- check right
--		if (grid.safe(x + 1, y) == 1) then
--			ret = ret + 1
--		end
--	end
	
	return ret
end

return grids