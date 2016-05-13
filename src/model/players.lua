local points = require("src.model.points")

local players = {}

function players.createPlayer(name, label, hp, attack, speed, range) 
	local p = {}
	p.name = name
	p.label = label
	p.hp = hp
	p.attack = attack
	p.speed = speed
	p.range = range
	p.start_pos = nil
	p.pos = points.createPoint(0, 0)
	p.team = nil
	p.movement_points = 0
	p.movement_points_later = 0
	p.sprite = nil
	p.max_hp = hp
	
	function p.move(x, y)
		p.sprite.x = (x - 1) * TILE_X	
		p.sprite.y = (y - 1) * TILE_Y
		p.pos.x = x
		p.pos.y = y
	end	
	
	return p
end

return players