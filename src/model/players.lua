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
	
	return p
end

return players