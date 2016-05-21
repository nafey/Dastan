local game = {}

local game.hero_list = nil
local game.level = nil

function game.initialize(hero_list, level)
	game.hero_list = hero_list
	game.level = level
end

return game

