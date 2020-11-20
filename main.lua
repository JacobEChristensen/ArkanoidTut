io.stdout:setvbuf("no") -- printing while running

require "libs/SaveTableToFile"

vector = require "libs/vector"
timer = require "libs/timer"
bump = require "libs/bump"
camera = require "libs/camera"
gamestates = require "gamestates"

controls = "mouse"

music = love.audio.newSource( "sounds/music/S31-NightProwler.ogg", "stream" )
music:setLooping( true )

function control_switch()
	if controls == "mouse" then
		controls = "keyboard"
	else
		controls = "mouse"
	end
end

-- New Features

-- Revise Graphics
-- golf sticky first shot 

-- set up seperate animation and game states

-- BUG:
-- remove offset between bricks
-- platform glue ball sticking
-- score display scaling tweening
-- level switch ball thing 

-- look at music volume might be 10% too loud

function love.load()
	local love_window_width = 800
	local love_window_height = 600
	love.window.setMode( love_window_width,
						 love_window_height,
						 { fullscreen = false } )
	local title = "Jakeanoid"
	love.window.setTitle( title )
	gamestates.set_state( "menu" )
end

function love.quit()
	print("Thanks for playing!")
end

function love.update( dt )
	gamestates.state_event( "update", dt )
end

function love.draw()
	gamestates.state_event( "draw" )
end

function love.keyreleased( key, code )
	gamestates.state_event( "keyreleased", key, code )
end