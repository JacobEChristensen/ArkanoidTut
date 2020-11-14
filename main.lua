io.stdout:setvbuf("no") -- printing while running

vector = require "libs/vector"
timer = require "libs/timer"
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
-- SCREEEN SHAAAAKEKEKE

-- BUG:
-- remove offset between bricks
-- platform glue ball sticking
-- platform ball reverse collision not working
-- score display scaling tweening
-- score display go to text not score

-- look at music volume might be 10% too loud

-- think fixed:
-- platform double collision

function love.load()
	local love_window_width = 800
	local love_window_height = 600
	love.window.setMode( love_window_width,
						 love_window_height,
						 { fullscreen = false } )
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

