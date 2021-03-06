-- TODO: change this shit. This is too complicated and hard codey

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

function sprite_data.getRoarFxData()
	local ret = {}
	 ret["options"] = {
		width = "96",
		height = "96",
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
	
	ret["image"] = "res/fx/roar_fx.png"
	
	return ret;
end

function sprite_data.getRoarFxFinalData()
	local ret = {}
	
	ret["options"] = {
		width = "32",
		height = "32",
		numFrames = "5"
	}
	
	ret["sequence"] = {
		{
			name = "default",
			start = 1,
			count = 3,
			time = 400,
			loopCount = 1,
			loopDirection = "forward"
		}
	}
	
	ret["image"] = "res/fx/roar_fx_final.png"
	
	return ret;
end

function sprite_data.getScatterShotFxData()
	local ret = {}
	 ret["options"] = {
		width = "96",
		height = "96",
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
	
	ret["image"] = "res/fx/scatter_shot_fx.png"
	
	return ret;
end

function sprite_data.getHealFxData() 
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
	
	ret["image"] = "res/fx/heal_fx.png"
	
	return ret;
end

function sprite_data.getSpeedRushFxData() 
	local ret = {}
	 ret["options"] = {
		width = "32",
		height = "64",
		numFrames = "9"
	}
	
	ret["sequence"] = {
		{
			name = "default",
			start = 1,
			count = 9,
			time = 600,
			loopCount = 1,
			loopDirection = "forward"
		}
	}
	
	ret["image"] = "res/fx/speed_rush_fx.png"
	
	return ret;
end


return sprite_data