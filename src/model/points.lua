local points = {}

function points.createPoint(x, y) 
	local p = {}
	p.x = x or 0
	p.y = y or 0
	
	function p.print(newline)
		newline = newline or false
		io.write("(" .. p.x .. ", " .. p.y .. ")")

		if (newline) then
			io.write("\n")
		end
	end
	return p
end

--Prints all the points in an array of points
function points.printPoints(pointsTable) 
	io.write("{")
	for i = 1, #pointsTable do
		pointsTable[i].print()
		io.write( ", ")
	end

	io.write("}\n")
end 

return points