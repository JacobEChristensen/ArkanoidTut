local gamePaused = {}
local game_objects = {}

local bungee_font = love.graphics.newFont("/fonts/Bungee_Inline/BungeeInline-regular.ttf", 30)

function gamePaused.cast_shadow()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor( 10/255, 10/255, 10/255, 100/255 )
	love.graphics.rectangle("fill",
							0,
							0,
							love.graphics.getWidth(),
							love.graphics.getHeight() )
	love.graphics.setColor( r, g, b, a)
end

function gamePaused.enter( prev_state, ... )
	game_objects = ...
end

function gamePaused.exit()
	game_objects = nil 
end

function gamePaused.update( dt )
end

function gamePaused.draw()
	for _, obj in pairs( game_objects ) do
		if type(obj) == "table" and obj.draw then
			obj.draw()
		end
	end
	gamePaused.cast_shadow()

	local oldfont = love.graphics.getFont()
	love.graphics.setFont( bungee_font )
   	love.graphics.printf("Game is paused...", 108, 110, 400, "center" )
   	love.graphics.setFont( oldfont )
end

function gamePaused.keyreleased( key, code )
	if key == 'return' then
		gamestates.set_state( "game" )
	elseif key == 'escape' then
		love.event.quit()
	end
end

function gamePaused.mousereleased( x, y, button, istouch)
	if button == 'l' or button == 1 then
		gamestates.set_state( "game" )
	elseif button == 'r' or button == 2 then
		love.event.quit()
	end
end

return gamePaused