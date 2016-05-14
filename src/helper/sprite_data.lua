local sprite_data = {}


function sprite_data.getPowSheetData() 
	local ret = {}
	 ret["options"] = {
		width = "32",
		height = "32",
		numFrames = "3"
	}
	
	ret["sequence"] = {
		{
			name = "default",
			start = 1,
			count = 3,
			time = 200,
			loopCount = 1,
			loopDirection = "forward"
		}
	}
	
	ret["image"] = "res/fx/powsheet.png"
	
	return ret;
end

return sprite_data