local points = require("src.model.geometry.points")

local players = {}

function players.createPlayer(name, label, hp, attack, speed, range, ability_1, ability_2) 
	local p = {}
	p.name = name
	p.label = label
	p.hp = hp
	p.attack = attack
	p.attack_buff = 0
	p.speed = speed
	p.range = range
	p.start_pos = nil
	p.pos = points.create(0, 0)
	p.team = nil
	p.movement_points = 0
	p.movement_points_later = 0
	p.max_hp = hp
	
	if (ability_1 ~= nil) then
		p.ability_1 = ability_1
	end
	
	if (ability_2 ~= nil) then
		p.ability_2 = ability_2
	end
	
	
	function p.move(x, y)
		p.sprite.x = (x - 1) * TILE_X	
		p.sprite.y = (y - 1) * TILE_Y
		p.pos.x = x
		p.pos.y = y
	end	
	
	return p
end

return players