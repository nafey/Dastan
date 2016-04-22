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
	return g
end

return grids