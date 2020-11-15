local walls = {}
walls.side_wall_thickness = 34
walls.top_wall_thickness = 26
walls.right_border_x_pos = 576
walls.current_level_walls = {}

local image = love.graphics.newImage( "img/800x600/walls.png" )
local wall_vertical_tile_width = 32
local wall_vertical_tile_height = 96
local wall_vertical_tile_x_pos = 0
local wall_vertical_tile_y_pos = 0
local wall_horizontal_tile_width = 96
local wall_horizontal_tile_height = 26
local wall_horizontal_tile_x_pos = 64
local wall_horizontal_tile_y_pos = 0
local topleft_corner_tile_width = 64
local topleft_corner_tile_height = 64
local topleft_corner_tile_x_pos = 64
local topleft_corner_tile_y_pos = 32
local topright_corner_tile_width = 64
local topright_corner_tile_height = 64
local topright_corner_tile_x_pos = 128
local topright_corner_tile_y_pos = 32
local tileset_width = 192
local tileset_height = 96
local vertical_quad = love.graphics.newQuad(
   wall_vertical_tile_x_pos,
   wall_vertical_tile_y_pos,
   wall_vertical_tile_width,
   wall_vertical_tile_height,
   tileset_width, tileset_height )
local horizontal_quad = love.graphics.newQuad(
   wall_horizontal_tile_x_pos,
   wall_horizontal_tile_y_pos,
   wall_horizontal_tile_width,
   wall_horizontal_tile_height,
   tileset_width, tileset_height )
local topright_corner_quad = love.graphics.newQuad(
   topright_corner_tile_x_pos,
   topright_corner_tile_y_pos,
   topright_corner_tile_width,
   topright_corner_tile_height,
   tileset_width, tileset_height )
local topleft_corner_quad = love.graphics.newQuad(
   topleft_corner_tile_x_pos,
   topleft_corner_tile_y_pos,
   topleft_corner_tile_width,
   topleft_corner_tile_height,
   tileset_width, tileset_height )

function walls.new_wall( position, width, height, layout )
	return( { position = position,
 		   	  width = width,
 		      height = height,
 		      layout = layout,
 		      isWall = true } )
end

function walls.construct_walls( world )
	local left_wall = walls.new_wall(
		vector( 0, 0 ),
		walls.side_wall_thickness,
		love.graphics.getHeight(),
		"left"
	)
	local right_wall = walls.new_wall(
		vector( walls.right_border_x_pos, 0 ),
		walls.side_wall_thickness,
		love.graphics.getHeight(),
		"right"
	)
	local top_wall = walls.new_wall(
		vector( 0, 0 ),
		walls.right_border_x_pos,
		walls.top_wall_thickness,
		"top"
	)
	local bottom_wall = walls.new_wall(
		vector( walls.side_wall_thickness + 0.25 * (walls.right_border_x_pos - walls.side_wall_thickness), love.graphics.getHeight() - walls.top_wall_thickness ),
		0.5 * ( walls.right_border_x_pos - walls.side_wall_thickness ),
		walls.top_wall_thickness,
		"bottom"
	)
	world:add( left_wall, left_wall.position.x + 10, left_wall.position.y, left_wall.width, left_wall.height )
	world:add( right_wall, right_wall.position.x, right_wall.position.y, right_wall.width, right_wall.height )
	world:add( top_wall, top_wall.position.x, top_wall.position.y + 10, top_wall.width, top_wall.height )
	world:add( bottom_wall, bottom_wall.position.x, bottom_wall.position.y, bottom_wall.width, bottom_wall.height )
	walls.current_level_walls["left"] = left_wall
	walls.current_level_walls["right"] = right_wall
    walls.current_level_walls["top"] = top_wall
    walls.current_level_walls["bottom"] = bottom_wall
end

function walls.remove_bonuses_effects()
	walls.current_level_walls["right"].next_level_bonus = false
end

function walls.draw_wall ( single_wall )
	if ( single_wall.layout == 'top' ) then
		love.graphics.draw(
			image, topleft_corner_quad,
			single_wall.position.x, single_wall.position.y )
		love.graphics.draw(
			image, topright_corner_quad,
			single_wall.position.x + single_wall.width - topleft_corner_tile_width / 2,
			single_wall.position.y )
		local repeat_n_times = 4
		for i = 0, repeat_n_times do
			shift_x = topleft_corner_tile_width + i * wall_horizontal_tile_width
			love.graphics.draw(
				image, horizontal_quad,
				single_wall.position.x + shift_x, single_wall.position.y )
		end
	elseif single_wall.layout == 'left' then
		local repeat_n_times = math.floor( (single_wall.height - topright_corner_tile_height) / wall_vertical_tile_height )
		for i = 0, repeat_n_times do
			shift_y = topright_corner_tile_height + i * wall_vertical_tile_height
			love.graphics.draw( image,
								vertical_quad,
								single_wall.position.x,
								single_wall.position.y + shift_y )
		end
	elseif single_wall.layout == 'right' then
		local repeat_n_times = math.floor( (single_wall.height - topright_corner_tile_height) / wall_vertical_tile_height )
		for i = 0, repeat_n_times do
			if not ( single_wall.next_level_bonus and i == repeat_n_times - 1 ) then
				shift_y = topright_corner_tile_height + i * wall_vertical_tile_height
				love.graphics.draw( image,
									vertical_quad,
									single_wall.position.x,
									single_wall.position.y + shift_y )
			end
		end
	elseif single_wall.layout == 'bottom' then
		local repeat_n_times = 0
		scalar = single_wall.width / wall_horizontal_tile_width
      	for i = 0, repeat_n_times do
        	shift_x = i * wall_horizontal_tile_width
        	love.graphics.draw(
            	image, horizontal_quad,
            	single_wall.position.x + shift_x, single_wall.position.y, 0, scalar, 1 )
		end
	end

	--[[love.graphics.setColor( 255, 255, 255, 100 )
	if wall.next_level_bonus then 
		love.graphics.setColor( 0, 0, 250, 100 )
	end
	love.graphics.rectangle('line',	
							wall.position.x,
							wall.position.y,
							wall.width,
							wall.height )--]]
end

function walls.update_wall()
end

function walls.update ( dt )
	for _, wall in pairs( walls.current_level_walls ) do
      walls.update_wall( wall )
   	end
end

function walls.draw()
	for _, wall in pairs( walls.current_level_walls ) do   --(*1)
      walls.draw_wall( wall )
    end
end

return walls