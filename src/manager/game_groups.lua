local game_groups = {}

function game_groups.initializeGroups(root)
	root.background = display.newGroup()
	root.player = display.newGroup()
	
	root.ui = display.newGroup()
	root.ui.frame = display.newGroup()
	root.ui.frame.y = 256
	root.ui:insert(root.ui.frame)
	
	root.ui.frame.move_order = display.newGroup()
	root.ui.frame.move_order.y = 19
	root.ui.frame.move_order.x = 277
	root.ui.frame:insert(root.ui.frame.move_order)
end

return game_groups