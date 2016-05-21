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

function points.copyPoint(p)
	local ret = points.createPoint(p.x, p.y)
	return ret
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

function points.dist(p1, p2) 
	return math.sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

function points.lerp(p1, p2, ratio)
	local ret = points.copyPoint(p1)
	if (ratio <= 0) then
		ret = points.copyPoint(p1)
	elseif (ratio >= 1) then
		ret = points.copyPoint(p2)
	else
		ret = points.createPoint(p1.x + (p2.x - p1.x) * ratio, p1.y + (p2.y - p1.y) * ratio)
	end
	
	return ret
end

function points.rotate(pt, dir) 
	if (dir == 1) then
		return points.createPoint(pt.x, pt.y - 1)
	elseif (dir == 2) then	
		return points.createPoint(pt.x - 1, pt.y)
	elseif (dir == 3) then
		return points.createPoint(pt.x, pt.y + 1)
	else 
		return points.createPoint(pt.x + 1, pt.y)
	end
end

return points