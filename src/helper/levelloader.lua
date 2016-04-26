local strings = require("src.helper.strings")
local grids = require("src.model.grids")

local levelloader = {}

function levelloader.loadlevel(levelname)
	-- Path for the file to read
	local path = system.pathForFile( "src/level/" .. levelname .. ".csv", system.ResourceDirectory )

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

return levelloader