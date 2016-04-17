-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
-- include the Corona "composer" module
local composer = require "composer"

display.setStatusBar( display.HiddenStatusBar )

-- load menu screen
composer.gotoScene( "level1" )