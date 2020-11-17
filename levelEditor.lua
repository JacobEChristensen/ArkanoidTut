local levelEditor = {}

local bricks = require "bricks"
local walls = require "walls"

local world = bump.newWorld()

function levelEditor.drawGrid()
	for i = 1, bricks.rows do
		for j = 1, bricks.columns do
			love.graphics.rectangle( "line", 
				bricks.top_left_position.x + ( j - 1 ) * ( bricks.brick_width + bricks.horizontal_distance ), 
				bricks.top_left_position.y + ( i - 1 ) * ( bricks.brick_height + bricks.vertical_distance ), 
				bricks.brick_width, bricks.brick_height)
		end
	end
end

-- make a time class
-- keeps x,y position, selected for button pressing and the bricktype.
-- needs to have a display thing that shows the brick type  

function levelEditor.load( prev_state, ... )
	walls.construct_walls( world )
	levelEditor.drawGrid()
end

function levelEditor.enter( prev_state, ... )
	game_objects = ...
end

function levelEditor.update( dt )
end

function levelEditor.draw()
	walls.draw()
	levelEditor.drawGrid()
end

function levelEditor.keyreleased( key, code )
	if key == "escape" then
		love.event.quit()
	end
end

function levelEditor.mousereleased( x, y, button, istouch)

end

function levelEditor.exit()
	game_objects = nil
end

return levelEditor