



--
--
-- include the Corona "composer" module
-- load menu screen
-- main.lua
-- Your code here
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
local composer = require "composer"

display.setStatusBar( display.HiddenStatusBar )
TILE_X = 32
TILE_Y = 32

composer.gotoScene( "src.level1" )