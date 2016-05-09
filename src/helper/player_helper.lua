local file_helper = require("src.helper.file_helper")
local json_helper = require("src.helper.json_helper")
local players = require("src.model.players")

local player_helper = {}

local move_threshold = 100


-- set later to true if you just want to move without setting movement_points
-- usually you would want to do this when you want to forecast movement
function player_helper.selectNextMover(player_list, later) 
	local attr = "movement_points"
	
	if (later) then
		attr = "movement_points_later"
	end
	

	local function passedThreshold(player_list)
		local max_val = -1
		local max_i = -1
			
		for i = 1, #player_list do
			if (player_list[i][attr] > max_val) then
				max_i = i 
				max_val = player_list[i][attr]
			end
		end
		
		local ret = -1 
		if (max_val >= 100) then
			ret = max_i
		end
		return ret
	end
	
	local ret = null
	
	
	while (passedThreshold(player_list) == -1) do
		for i = 1, #player_list do
			player_list[i][attr] = player_list[i][attr] + player_list[i]["speed"]
		end
	end
	
	ret = player_list[passedThreshold(player_list)]
	ret[attr] = ret[attr] - 100
	
	return ret
end

function player_helper.loadPlayers(path, teams)
	local json_list = json_helper:decode(file_helper.getFileText(path))
	local player_list = {}
	for i = 1, #json_list do
		local json = json_list[i]
		
		for j = 1, #teams do
			if (teams[j]["name"] == json["name"]) then
				local p = players.createPlayer(json["name"], json["label"], 
											   json["hp"], json["attack"], 
											   json["speed"], json["range"])
				p.team = teams[j]["team"]
				p.start_pos  = teams[j]["start_pos"]
				
				table.insert(player_list, p)
				
			end
		end
		
	end
	
	return player_list
end	

-- Finds if at the x, y an enemy is located
-- return 1 if this is an enemy position
-- return 0 if this is friendly position
function player_helper.isEnemyAtPosition(x, y, player_list, your_team)
	local ret = 0
	
	for i = 1, #player_list do 
		if (x == player_list[i].pos.x and y == player_list[i].pos.y) then
			if (player_list[i].team ~= your_team) then
				ret = 1
			end
		end
	end
	
	return ret
end

function player_helper.getPlayerAtPosition(x, y, player_list)
	local ret = nil
	for i = 1, #player_list do 
		if (x == player_list[i].pos.x and y == player_list[i].pos.y) then
			ret = player_list[i]
		end
	end
	
	return ret
end

function player_helper.kill(name, player_list) 
	local rem = -1
	for i = 1, #player_list do
		if (player_list[i].name == name) then
			rem = i
		end
	end
	
	if (rem ~= -1) then
		player_list[rem].sprite:removeSelf()
		table.remove(player_list, rem)
	end
end

function player_helper.playerAttack(attacker, attacked, player_list) 
	attacked.hp = attacked.hp - attacker.attack
	
	if (attacked.hp <= 0) then
		player_helper.kill(attacked.name, player_list)
	end
end

return player_helper