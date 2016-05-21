local file_helper = {}

function file_helper.getFileText(path)

	-- Path for the file to read
	local path = system.pathForFile(path, system.ResourceDirectory )
	-- Open the file handle
	local file, errorString = io.open(path, "r")
	
	local contents = ""
	
	if not file then
		-- Error occurred; output the cause
		print( "File error: " .. errorString )
	else
		contents = file:read("*all")
				
		-- Close the file handle
		io.close( file )
	end

	file = nil
	
	return contents
end

function file_helper.getFile(path, option)

	-- Path for the file to read
	local path = system.pathForFile(path, system.ResourceDirectory )
	-- Open the file handle
	local file, errorString = io.open(path, option)
		
	if not file then
		-- Error occurred; output the cause
		print( "File error: " .. errorString )

		io.close( file )
		file = nil
	end
	
	return file
end



return file_helper