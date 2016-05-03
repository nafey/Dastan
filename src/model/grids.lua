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

return grids