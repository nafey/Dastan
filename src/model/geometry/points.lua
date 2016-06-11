local points = {}

function points.create(x, y) 
	local p = {}
	p.x = x or 0
	p.y = y or 0
	
	function p.print(newline)
		newline = newline or false
		io.write(p.str())

		if (newline) then
			io.write("\n")
		end
	end
	
	function p.str()
		return "(" .. p.x .. ", " .. p.y .. ")"
	end
	return p
end

function points.equals(p1, p2) 
	return (p1.x == p2.x) and (p2.y == p1.y)
end

function points.copy(p)
	local ret = points.create(p.x, p.y)
	return ret
end

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
	local ret = points.copy(p1)
	if (ratio <= 0) then
		ret = points.copy(p1)
	elseif (ratio >= 1) then
		ret = points.copy(p2)
	else
		ret = points.create(p1.x + (p2.x - p1.x) * ratio, p1.y + (p2.y - p1.y) * ratio)
	end
	
	return ret
end

function points.rotate(pt, dir) 
	if (dir == 1) then
		return points.create(pt.x, pt.y - 1)
	elseif (dir == 2) then	
		return points.create(pt.x - 1, pt.y)
	elseif (dir == 3) then
		return points.create(pt.x, pt.y + 1)
	else 
		return points.create(pt.x + 1, pt.y)
	end
end

function points.isAdjacent(x1, y1, x2, y2) 
	local p1 = points.create(x1, y1)
	local p2 = points.create(x2, y2)
	
	for dir = 1, 4 do
		local adj = points.rotate(p1, dir)
		if (points.equals(adj, p2)) then
			return true
		end
	end
	
	return false
end



return points