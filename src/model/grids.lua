local grids = {}

function grids.createGrid(size_x, size_y) 
	local g = {}
	g.width = size_x
	g.height = size_y
	for i = 1, size_x do
		g[i] = {}
		for j = 1, size_y do
			g[i][j] = 0
		end
	end
	
	function g.print()
		for j = 1, size_y do
			for i = 1, size_x do 
				io.write(g[i][j] .. " ")
			end
			
			io.write("\n")
		end
	end
	
	-- TODO: consider changing OOB to -1
	--safe get on a grid value if OOB then return 0
	function g.safe(i, j)
		local ret = 0
		if ((i >= 1 and i <= g.width) and (j >= 1 and j <= g.height)) then
			ret = g[i][j]
		end
		
		return ret
	end
	
	return g
end

function grids.copyGrid(grid) 
	local g = grids.createGrid(grid.width, grid.height)
	
	for i = 1, grid.width do
		for j = 1, grid.height do
			g[i][j] = grid.safe(i, j)
		end
	end
		
	return g
end

-- Checks number of 1 value grid adjacent the particular position
-- called by the draw grid function
function grids.adjacency(grid, x, y)
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

return grids