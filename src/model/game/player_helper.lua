
local file_helper = require("src.helper.util.file_helper")
local json_helper = require("src.helper.util.json_helper")

local points = require("src.model.geometry.points")
local grids = require("src.model.geometry.grids")

local geometry = require("src.model.geometry.geometry")

local players = require("src.model.game.players")
local game_engine = require("src.model.game.game_engine")

-- TODO: ensure this does not modify the state of any game object
local player_helper = {}

local move_threshold = 100

-- Finds the mean point for the team
function player_helper.findTeamCenter(team, player_list)
	local x = 0
	local y = 0
	local count = 0
	for i = 1, #player_list do
		if (player_list[i].team == team) then
			x = x + player_list[i].pos.x
			y = y + player_list[i].pos.y
			count = count + 1
		end
	end
	
	if (count == 0) then
		count = 1
	end
	
	
	x = math.floor(x / count)
	y = math.floor(y / count)
	
	return points.create(x, y)
end

function player_helper.findInAbilityRange(character, player_list, range, selector)
	local affected = {}
	
	for i = 1, #player_list do
		
		if (geometry.manhattan(player_list[i].pos.x, player_list[i].pos.y, 
			character.pos.x, character.pos.y) <= range) then
			local add_flag = true
			
			if (selector == "enemy" and character.team == player_list[i].team) then
				add_flag = false
			end
			
			if (selector == "ally" and character.team ~= player_list[i].team) then
				add_flag = false
			end
			
			if (add_flag) then
				table.insert(affected, player_list[i])
			end
		end
	end
	
	return affected
end

function player_helper.useTriggeredAbility(selected_player, affected, ability)
	if (ability.name == "roar") then
		for i = 1, #affected do
			affected[i].attack = affected[i].attack + 1
		end
	elseif (ability.name == "scatter_shot") then
		-- cant'kill
		-- TODO: ^^^^ HACK, HACK, HACK
		for i = 1, #affected do
			if (affected[i].hp > ability.damage) then
				affected[i].hp = affected[i].hp - ability.damage
			end
		end
	elseif (ability.name == "speed_rush") then
		for i = 1, #affected do
			affected[i].speed = affected[i].speed + 1
		end
	end
end

function player_helper.useTargetedAbility(character, target, ability, player_list) 
	local did_kill = false
	if (ability.name == "double_strike") then
		did_kill = game_engine.damage(target, character.attack * 2, player_list)
	elseif (ability.name == "shoot") then
		did_kill = game_engine.damage(target, ability.damage, player_list)
	elseif (ability.name == "heal") then
		if (target.hp < target.max_hp - ability.heal) then
			target.hp = target.hp + ability.heal
		else 
			target.hp = target.max_hp
		end
	end
	
	return did_kill
end

function player_helper.isTargetable(character, player_list, ability, x, y)
	local valid_target_flag = false
	
	for i = 1, #player_list do
		if (player_list[i].pos.x == x and player_list[i].pos.y == y) then
			valid_target_flag = true
			if (geometry.manhattan(x, y, character.pos.x, character.pos.y) > tonumber(ability.range)) then
				valid_target_flag = false
			end
			
			if (ability.select == "enemy") then
				if (character.team == player_list[i].team) then
					valid_target_flag = false
				end
			elseif (ability.select == "ally") then
				if (character.team ~= player_list[i].team) then
					valid_target_flag = false
				end
			end
		end
	end
	
	return valid_target_flag
end

-- TODO: Cleaner solution for representing start pos on map 
-- TODO: Combine with markPlayers
-- Cleans the movementGrid to remove P1 to P6
function player_helper.getMovementGrid(levelgrid, player_list, player_name)
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

-- Adds 1 to any grid with all the positions for the players
function player_helper.markPlayers(levelgrid, player_list,  player_name) 
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

-- TODO: consider not passing map to this method and infer it here itself 
function player_helper.movePlayer(map, player, destination) 
	if (map.safe(player.pos.x, player.pos.y) == 0 or map.safe(destination.x, destination.y) == 0) then
		return nil
	end
	
	local ret = geometry.getPath(map, player.pos, destination)
	
	player.pos.x = destination.x
	player.pos.y = destination.y
	
	return ret
end

-- set later to true if you just want to move without setting movement_points
-- usually you would want to do this when you want to forecast movement
-- TODO: think about not modifying player attr within this method
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

function player_helper.getPlayerPositions(levelgrid)
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
				ret[levelgrid.safe(i, j)] = points.create(i, j)
			end
		end
	end
			
	return ret
end

function player_helper.loadPlayers(path, teams)
	local json_list = json_helper:decode(file_helper.getFileText(path))
	local player_list = {}
	for i = 1, #json_list do
		local json = json_list[i]
		
		for j = 1, #teams do
			if (teams[j]["name"] == json["name"]) then
				local ability_1 = json["ability_1"]
				local ability_2 = json["ability_2"]
				local p = players.createPlayer(json["name"], json["label"], 
											   json["hp"], json["attack"], 
											   json["speed"], json["range"],
											   ability_1, ability_2)
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


function player_helper.isAdjacentToEnemy(x, y, player_list, your_team)
	local ret = false
	for i = 1, #player_list do 
		if (not(ret) and points.isAdjacent(x, y, player_list[i].pos.x, player_list[i].pos.y)) then
			if (player_list[i].team ~= your_team) then
				ret = true
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

-- Get all players
function player_helper.findEnemyInRange(player, player_list, move_map)
	local ret = {}
	
	for i = 1, #player_list do
		local add_flag = false
		
		for dir = 1, 4 do
			local pt_check = points.rotate(player_list[i].pos, dir)
			
			if (move_map.safe(pt_check.x, pt_check.y) ~= 0) then
				if (player_list[i].team ~= player.team) then
					add_flag = true
				end
			end
		end
		
		if (add_flag) then
			table.insert(ret, player_list[i])
		end
	end
	
	return ret
end

return player_helper