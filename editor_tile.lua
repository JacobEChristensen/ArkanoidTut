local editor_tile = {}

editor_tile.image = love.graphics.newImage( "img/800x600/bricks.png" )
editor_tile.tile_width = 64
editor_tile.tile_height = 32
editor_tile.tileset_width = 384
editor_tile.tileset_height = 160
editor_tile.rows = 11
editor_tile.columns = 8
editor_tile.top_left_position = vector( 47, 34 )
editor_tile.bricks_width = editor_tile.tile_width
editor_tile.bricks_height = editor_tile.tile_height
editor_tile.horizontal_distance = 0
editor_tile.vertical_distance = 0
editor_tile.current_level_tiles = {}

function editor_tile.is_simple( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 1 )
end

function editor_tile.is_armored( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 2 )
end

function editor_tile.is_scratched( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 3 )
end

function editor_tile.is_cracked( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 4 )
end

function editor_tile.is_heavyarmored( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 5 )
end

function editor_tile.add_to_current_level_editor_tile( brick )
   table.insert( editor_tile.current_level_editor_tile, brick )
end

function editor_tile.bricktype_to_quad( bricktype )
	local row = math.floor( bricktype / 10 )
	local col = bricktype % 10
	local x_pos = editor_tile.tile_width * ( col - 1 )
	local y_pos = editor_tile.tile_height * ( row - 1 )
	return love.graphics.newQuad( x_pos, y_pos,
								  editor_tile.tile_width, editor_tile.tile_height,
								  editor_tile.tileset_width, editor_tile.tileset_height )
end

function editor_tile.new_brick( position, width, height, bricktype )
	return( { position = position,
			  width = width or editor_tile.brick_width,
			  height = height or editor_tile.brick_height,
			  bricktype = bricktype,
			  quad = editor_tile.bricktype_to_quad( bricktype ),
			  selected = false
			} )
end

function editor_tile.draw_brick ( single_brick )
	local r, g, b, a = love.graphics.getColor()
	if single_brick.selected then
		love.graphics.setColor( 1, 0, 0, 1 )
	else 
		love.graphics.setColor( 1, 1, 1, 1 )
	end
	love.graphics.rectangle( "line",
							 single_brick.position.x,
							 single_brick.position.y,
							 editor_tile.tile_width,
							 editor_tile.tile_height )
	love.graphics.setColor( r, g, b, a )
	if single_brick.quad then
		love.graphics.draw( editor_tile.image,
							single_brick.quad,
							single_brick.position.x,
							single_brick.position.y )
	else
		print("no brick quad error")
	end
end

function editor_tile.draw()
   for _, brick in pairs( editor_tile.current_level_tiles ) do
      editor_tile.draw_brick( brick )
   end
end

function editor_tile.update_tile( mouse_pos, tile, dt )
	if( editor_tile.inside( tile, mouse_pos ) ) then
		tile.selected = true
	else
		tile.selected = false
	end
end

function editor_tile.inside( tile, pos )
	return tile.position.x < pos.x and pos.x < ( tile.position.x + editor_tile.tile_width ) and tile.position.y < pos.y and pos.y < ( tile.position.y + editor_tile.tile_height )
end

function editor_tile.update( dt )
	local mouse_pos = vector( love.mouse.getPosition() )
	for _, tile in pairs( editor_tile.current_level_tiles ) do
		editor_tile.update_tile( mouse_pos, tile, dt )
	end
end

function editor_tile.make_tile( i, j )
	local new_brick_position_x = editor_tile.top_left_position.x + ( j - 1 ) * ( editor_tile.tile_width + editor_tile.horizontal_distance )
	local new_brick_position_y = editor_tile.top_left_position.y + ( i - 1 ) * ( editor_tile.tile_height + editor_tile.vertical_distance )
	local new_brick_position = vector( new_brick_position_x, new_brick_position_y )
	local bricktype = 00
	local new_brick = editor_tile.new_brick( new_brick_position,
										editor_tile.tile_width,
										editor_tile.tile_height,
										bricktype )
	table.insert( editor_tile.current_level_tiles, new_brick )
end

function editor_tile.react_on_left_click()
	for _, tile in pairs( editor_tile.current_level_tiles ) do
      if tile.selected then 
      	editor_tile.tile_change_bricktype( tile )
      end
   end
end

function editor_tile.react_on_right_click()
	for _, tile in pairs( editor_tile.current_level_tiles ) do
      if tile.selected then 
      	editor_tile.tile_reset_bricktype( tile )
      end
   end
end

function editor_tile.react_on_copy() 
	for _, tile in pairs( editor_tile.current_level_tiles ) do
      if tile.selected then
      	return tile.bricktype
      end
   end
end

function editor_tile.react_on_paste( bricktype ) 
	for _, tile in pairs( editor_tile.current_level_tiles ) do
      if tile.selected then
      	tile.bricktype = bricktype
   		tile.quad = editor_tile.bricktype_to_quad( tile.bricktype )
      end
   end
end

function editor_tile.tile_reset_bricktype( tile )
	tile.bricktype = 00
	tile.quad = editor_tile.bricktype_to_quad( tile.bricktype )
end

function editor_tile.tile_change_bricktype( tile )
	--tile.bricktype = 11
	if tile.bricktype == 00 or tile.bricktype == 51 then
		tile.bricktype = 11
	elseif tile.bricktype == 11 then
		tile.bricktype = 21 
	elseif tile.bricktype == 21 then
		tile.bricktype = 12 
	elseif tile.bricktype == 12 then
		tile.bricktype = 22
	elseif tile.bricktype == 22 then
		tile.bricktype = 13
	elseif tile.bricktype == 13 then
		tile.bricktype = 23
	elseif tile.bricktype == 23 then
		tile.bricktype = 14
	elseif tile.bricktype == 14 then
		tile.bricktype = 24
	elseif tile.bricktype == 24 then
		tile.bricktype = 15
	elseif tile.bricktype == 15 then
		tile.bricktype = 25
	elseif tile.bricktype == 25 then
		tile.bricktype = 16
	elseif tile.bricktype == 16 then
		tile.bricktype = 26
	elseif tile.bricktype == 26 then
		tile.bricktype = 51
	end

	tile.quad = editor_tile.bricktype_to_quad( tile.bricktype )
end

return editor_tile