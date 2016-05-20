local strings = require("src.helper.strings")
local grids = require("src.model.grids")
local points = require("src.model.points")
local file_helper = require("src.helper.file_helper")

local levelloader = {}

function levelloader.loadlevel(levelname)
	-- Path for the file to read
	
	local level_file = file_helper.getFile("res/maps/" .. levelname .. ".csv", "r")

	local ret = nil
	
	-- Found the file
	local j = 0
	
	local width = 0
	local height = 0
	
	
	for line in level_file:lines() do
		local line_split = strings.split(line, ",")

		if (j == 0) then
			width = tonumber(line_split[1])
			height = tonumber(line_split[2])
			
			ret = grids.createGrid(width, height)
		else
			for i = 1, width do
				if tonumber(line_split[i]) ~= nil then
					ret.put(i, j, tonumber(line_split[i]))
				else 
					ret.put(i, j, line_split[i])
				end
			end
		end
		j = j + 1
	end
	
	-- Close the file handle
	io.close( level_file )
	
	return ret
end

function levelloader.getPlayerPositions(levelgrid)
	-- is true only when i,j corresponds to P1 ...P6
	function isPlayerPosition(i, j) 
		local ret = false
		
		if (tonumber(levelgrid.safe(i, j)) == nil) then
			if (string.find(levelgrid.safe(i, j), "P")) then
				if (tonumber(string.sub(levelgrid.safe(i, j), 2)) ~= nil) then
					if (tonumber(string.sub(levelgrid.safe(i, j), 2)) <= 6 and tonumber(string.sub(levelgrid.safe(i, j), 2)) >= 1) then
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
				ret[levelgrid.safe(i, j)] = points.createPoint(i, j)
			end
		end
	end
		
	return ret
end

function levelloader.getMovementGrid(levelgrid, player_list, player_name)
	local ret = grids.createGrid(levelgrid.width, levelgrid.height)
	
	for i = 1, levelgrid.width do
		for j = 1, levelgrid.height do
			if (tonumber(levelgrid.safe(i, j)) ~= nil) then
				ret.put(i, j, levelgrid.safe(i, j))
			else 
				ret.put(i, j, 0)
			end
		end
	end
	
	return ret
end


function levelloader.markPlayers(levelgrid, player_list,  player_name) 
	local ret = grids.copyGrid(levelgrid)
	
	if (player_list ~= nil) then
		for i = 1, #player_list do
			if (player_list[i].name ~= player_name) then
				ret.put(player_list[i].pos.x, player_list[i].pos.y, 1)
			end
		end
	end
	
	return ret
end


return levelloader