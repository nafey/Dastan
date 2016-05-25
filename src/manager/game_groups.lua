local game_groups = {}

function game_groups.initializeGroups(view)
	-- The order here is important dont move it up or down as it affects the draw order
	view.background = display.newGroup()
	
	--view.selection = display.newGroup()
	--view.player = display.newGroup()
	--view.ui = display.newGroup()
	--view.ui.hp = display.newGroup()
	--view.ui.play_area = display.newGroup()
	--view.ui.frame = display.newGroup()
	
end

return game_groups