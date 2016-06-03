local points = require("src.model.geometry.points")
local player_helper = require("src.model.game.player_helper")

local ai = {}

-- TODO: this hard code is sinful
ai.main_team = 1
ai.ai_team = 2

-- returns the point to move to come close to enemy center
function ai.moveToEnemy(player_list, move_map)
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
	recommend.code = "recommend_move"
	-- select point
	
	local move_target = ai.moveToEnemy(player_list, move_map)
	
	recommend.point = points.createPoint(move_target.x, move_target.y)
	
	return recommend
end

return ai 