local game = {}

game.hero_list = nil
game.level = nil


function game.initialize(hero_list, level)
	game.hero_list = hero_list
	game.level = level
	
	game.level.print()
end


return game
