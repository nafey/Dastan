local strings = require("src.helper.strings")
local grids = require("src.model.grids")
local points = require("src.model.points")

local levelloader = {}

function levelloader.loadlevel(levelname)
	-- Path for the file to read
	local path = system.pathForFile( "res/maps/" .. levelname .. ".csv", system.ResourceDirectory )

	-- Open the file handle
	local file, errorString = io.open( path, "r" )
	
	local ret = nil

	if not file then
		-- Error occurred; output the cause
		print( "File error: " .. errorString )
	else
		 -- Found the file
		local j = 0
		
		local width = 0
		local height = 0
		
		
		for line in file:lines() do
			local line_split = strings.split(line, ",")

			if (j == 0) then
				width = tonumber(line_split[1])
				height = tonumber(line_split[2])
				
				ret = grids.createGrid(width, height)
			else
				for i = 1, width do
					if tonumber(line_split[i]) ~= nil then
						ret[i][j] = tonumber(line_split[i])
					else 
						ret[i][j] = line_split[i]
					end
				end
			end
			j = j + 1
		end
				
		-- Close the file handle
		io.close( file )
	end

	file = nil
	
	return ret
end

function levelloader.getPlayerPositions(levelgrid)
	-- is true only when i,j corresponds to P1 ...P6
	function isPlayerPosition(i, j) 
		local ret = false
		
		if (tonumber(levelgrid[i][j]) == nil) then
			if (string.find(levelgrid[i][j], "P")) then
				if (tonumber(string.sub(levelgrid[i][j], 2)) ~= nil) then
					if (tonumber(string.sub(levelgrid[i][j], 2)) <= 6 and tonumber(string.sub(levelgrid[i][j], 2)) >= 1) then
						ret = true
					end
				end
			end
		end
		
		return ret
	end
	
	local ret = {}
	for i = 1, levelgrid.width do
		for j = 1, levelgrid.height do
			if (isPlayerPosition(i,j)) then
				ret[levelgrid[i][j]] = points.createPoint(i, j)
			end
		end
	end
		
	return ret
end

function levelloader.getMovementGrid(levelgrid)
	local ret = grids.createGrid(levelgrid.width, levelgrid.height)
	
	for i = 1, levelgrid.width do
		for j = 1, levelgrid.height do
			if (tonumber(levelgrid[i][j]) ~= nil) then
				ret[i][j] = levelgrid[i][j]
			else 
				ret[i][j] = 0
			end
		end
	end
	
	return ret
end


return levelloader