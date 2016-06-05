local game_engine = {}

function game_engine.kill(name, player_list) 
	local rem = -1
	
	for i = 1, #player_list do
		if (player_list[i].name == name) then
			rem = i
		end
	end
	
	-- TODO: add remove sprite somewhere
	-- TODO: add remove player action
	if (rem ~= -1) then
		table.remove(player_list, rem)
	end
end

function game_engine.damage(player, damage, player_list)
	local kill_flag = false
	player.hp = player.hp - damage	
	
	if (player.hp <= 0) then
		game_engine.kill(player.name, player_list)
		kill_flag = true
	end
	
	return kill_flag
end

function game_engine.playerAttack(attacker, attacked, player_list) 
	local did_kill = false
	did_kill = game_engine.damage(attacked, attacker.attack, player_list)
	return did_kill
end

return game_engine