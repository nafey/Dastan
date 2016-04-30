local player_helper = {}

local move_threshold = 100

local function passedThreshold(player_list)
	local max_val = -1
	local max_i = -1
	
	for i = 1, #player_list do
		if (player_list[i]["movement_points"] > max_val) then
			max_i = i 
			max_val = player_list[i]["movement_points"]
		end
	end
	
	local ret = -1 
	if (max_val >= 100) then
		ret = max_i
	end
	return ret
end

function player_helper.selectNextMover(player_list) 
	local ret = null
	
	while (passedThreshold(player_list) == -1) do
		for i = 1, #player_list do
			player_list[i]["movement_points"] = player_list[i]["movement_points"] + player_list[i]["speed"]
		end
	end
	
	ret = player_list[passedThreshold(player_list)]
	ret["movement_points"] = ret["movement_points"] - 100
	
	return ret
end

return player_helper