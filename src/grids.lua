grids = {}

function grids.createGrid(size_x, size_y) 
	g = {}
	g.width = size_x
	g.height = size_y
	for j = 1, size_y do
		g[j] = {}
		for i = 1, size_x do
			g[j][i] = 0
		end
	end
	
	function g.print()
		for j = 1, size_y do 
			for i = 1, size_x do
				io.write(g[j][i] .. " ")
			end
			
			io.write("\n")
		end
	end
	return g
end

return grids