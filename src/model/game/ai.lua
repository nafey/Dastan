local points = require("src.model.geometry.points")
local player_helper = require("src.model.game.player_helper")

local ai = {}

-- TODO: this hard code is sinful
ai.main_team = 1
ai.ai_team = 2

-- Returns point to which you can move
function ai.moveToEnemy(player, move_map, enemy) 
	local ret = {}
	
	for dir = 1, 4 do
		local pt_check = points.rotate(enemy.pos, dir)
		if (move_map.safe(pt_check.x, pt_check.y) ~= 0) then
			ret = pt_check
		end
	end
	
	return ret
end

-- Select enemy to attack
function ai.selectEnemyForAttack(player, move_map, enemies)
	-- pick the lowest hp enemy
	local hp_min = 99999
	local enemy = {}
	
	for i = 1, #enemies do 
		if (hp_min > enemies[i].hp) then
			hp_min = enemies[i].hp
			enemy = enemies[i]
		end
	end
	
	return enemy
end

-- returns the point to move to come close to enemy center
function ai.moveToEnemyCenter(player_list, move_map)
	local target_point = player_helper.findTeamCenter(ai.main_team, player_list)
	local best_point = points.createPoint(9999, 9999)
	
	local dist = points.dist(best_point, target_point)
	
	
	for i = 1, move_map.width do
		for j = 1, move_map.height do
			if (move_map.safe(i, j) ~= 0) then
				if (dist > points.dist(target_point, points.createPoint(i, j))) then
					dist = points.dist(target_point, points.createPoint(i, j))
					best_point = points.createPoint(i, j)
				end
			end
		end
	end
	
	return best_point
end

-- returns a list of recommendation which describes all the things that AI will do
-- Always ends with select next action
function ai.aiTurn(player, player_list, move_map, level)
	local recommend = {}
	
	-- check if enemies in range
	local enemies = player_helper.findEnemyInRange(player, player_list, move_map)
	
	if (#enemies > 0) then
		recommend.code = "recommend_attack"
		
		local enemy = ai.selectEnemyForAttack(player, move_map, enemies)
		local move_point = ai.moveToEnemy(player, move_map, enemy)
		
		recommend.enemy = enemy
		recommend.move_point = move_point
	else 
		recommend.code = "recommend_move"
		-- select point
		local move_point = ai.moveToEnemyCenter(player_list, move_map)
		recommend.move_point = points.createPoint(move_point.x, move_point.y)
	end
	
	return recommend
end

return ai 