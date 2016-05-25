local file_helper = require("src.helper.util.file_helper")
local strings = require("src.helper.util.strings_helper")

local grids = require("src.model.geometry.grids")
local points = require("src.model.geometry.points")

local levelloader = {}

function levelloader.loadLevel(levelpath)
	-- Path for the file to read
	
	local level_file = file_helper.getFile(levelpath, "r")

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



return levelloader