local bricks = {}
bricks.image = love.graphics.newImage( "img/800x600/bricks.png" )
bricks.tile_width = 64
bricks.tile_height = 32
bricks.tileset_width = 384
bricks.tileset_height = 160
bricks.rows = 11
bricks.columns = 8
bricks.top_left_position = vector( 47, 34 )
bricks.brick_width = bricks.tile_width
bricks.brick_height = bricks.tile_height
bricks.horizontal_distance = 0
bricks.vertical_distance = 0
bricks.current_level_bricks = {}
bricks.breaking_bricks = {}

local simple_break_sound = {
	love.audio.newSource(
		"sounds/simple_break/recordered_glass_norm.ogg",
		"static"),
	love.audio.newSource(
		"sounds/simple_break/edgardedition_glass_hit_norm.ogg",
		"static")
}

local armored_hit_sound = {
   love.audio.newSource(
      "sounds/armored_hit/qubodupImpactMetal_short_norm.ogg",
      "static"),
   love.audio.newSource(
      "sounds/armored_hit/cast_iron_clangs_14_short_norm.ogg",
      "static"),
   love.audio.newSource(
      "sounds/armored_hit/cast_iron_clangs_22_short_norm.ogg",
      "static") }

local armored_break_sound = {
   love.audio.newSource(
      "sounds/armored_break/armored_glass_break_short_norm.ogg",
      "static"),
   love.audio.newSource(
      "sounds/armored_break/ngruber__breaking-glass_6_short_norm.ogg",
      "static") }

local ball_heavyarmored_sound = {
   love.audio.newSource(
      "sounds/heavy_armored_hit/cast_iron_clangs_11_short_norm.ogg",
      "static"),
   love.audio.newSource(
      "sounds/heavy_armored_hit/cast_iron_clangs_18_short_norm.ogg",
      "static") }

local snd_rng = love.math.newRandomGenerator( os.time() )
local timer_rng = love.math.newRandomGenerator( os.time() )

function bricks.is_simple( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 1 )
end

function bricks.is_armored( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 2 )
end

function bricks.is_scratched( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 3 )
end

function bricks.is_cracked( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 4 )
end

function bricks.is_heavyarmored( single_brick )
   local row = math.floor( single_brick.bricktype / 10 )
   return ( row == 5 )
end

function bricks.add_to_current_level_bricks( brick )
   table.insert( bricks.current_level_bricks, brick )
end

function bricks.bricktype_to_quad( bricktype )
	local row = math.floor( bricktype / 10 )
	local col = bricktype % 10
	local x_pos = bricks.tile_width * ( col - 1 )
	local y_pos = bricks.tile_height * ( row - 1 )
	return love.graphics.newQuad( x_pos, y_pos,
								  bricks.tile_width, bricks.tile_height,
								  bricks.tileset_width, bricks.tileset_height )
end

function bricks.new_brick( position, width, height, bricktype, bonustype, i )
	return( { position = position,
			  width = width or bricks.brick_width,
			  height = height or bricks.brick_height,
			  bricktype = bricktype,
			  quad = bricks.bricktype_to_quad( bricktype ),
			  bonustype = bonustype,
			  scale = 1,
			  broken = false,
			  isBrick = true,
			  index = i } )
end

function bricks.draw_brick ( single_brick )
	--[[love.graphics.rectangle('line',	
							single_brick.position_x,
							single_brick.position_y,
							single_brick.width,
							single_brick.height )
	local r, g, b, a = love.graphics.getColor( )
	if single_brick.bricktype == 1 then
		love.graphics.setColor( 255, 0, 0, 100 )
	elseif single_brick.bricktype == 2 then
		love.graphics.setColor( 0, 255, 0, 100 )
	elseif single_brick.bricktype == 3 then
		love.graphics.setColor( 0, 0, 255, 100 )
	end
	love.graphics.rectangle( 'fill',	
							single_brick.position_x,
							single_brick.position_y,
							single_brick.width,
							single_brick.height )
	love.graphics.setColor( r, g, b, a )--]]
	if single_brick.quad then
		--print(single_brick.bonustype)
		love.graphics.draw( bricks.image,
							single_brick.quad,
							single_brick.position.x,
							single_brick.position.y,
							0,
							single_brick.scale,
							single_brick.scale )
	else
		print("no brick quad error")
	end
end

function bricks.construct_level( level, world )
	bricks.no_more_bricks = false
	local offset = 400
	for row_index, row in ipairs( level.bricks ) do
		for col_index, bricktype in ipairs ( row ) do
			if bricktype ~= 0 then
				local bonustype
				local new_brick_position_x = bricks.top_left_position.x + ( col_index - 1 ) * ( bricks.brick_width + bricks.horizontal_distance )
				local new_brick_position_y = bricks.top_left_position.y + ( row_index - 1 ) * ( bricks.brick_height + bricks.vertical_distance ) - offset
				local new_brick_position = vector( new_brick_position_x, new_brick_position_y )
				if level.bonuses then
					bonustype = level.bonuses[ row_index ][ col_index ]
				end
				local new_brick = bricks.new_brick( new_brick_position,
													bricks.brick_width,
													bricks.brick_height,
													bricktype,
													bonustype )
				bricks.tween_brick( new_brick, offset )
				world:add( new_brick, new_brick.position.x, new_brick.position.y, new_brick.width, new_brick.height)
				table.insert( bricks.current_level_bricks, new_brick )
			end
		end
	end
end

function bricks.tween_brick( single_brick, offset )
	local time = 1.5
	local time_offset = snd_rng:random()
	timer.tween( time + time_offset, single_brick, {position = vector( single_brick.position.x, single_brick.position.y + offset ) }, 'in-bounce' )
end

function bricks.clear_current_level_bricks( world )
	for i in pairs( bricks.current_level_bricks ) do
		world:remove(bricks.current_level_bricks[i]) 
		bricks.current_level_bricks[i] = nil
	end
	for i in pairs( bricks.breaking_bricks ) do
		bricks.breaking_bricks[i] = nil
	end
end

function bricks.armored_to_scratched( single_brick )
   single_brick.bricktype = single_brick.bricktype + 10
   single_brick.quad = bricks.bricktype_to_quad( single_brick.bricktype )
end

function bricks.scratched_to_cracked( single_brick )
   single_brick.bricktype = single_brick.bricktype + 10
   single_brick.quad = bricks.bricktype_to_quad( single_brick.bricktype )
end

function bricks.brick_hit_by_ball( brick, shift_ball, bonuses, score_display, ball, world )
	if bricks.is_simple( brick ) then
		bonuses.generate_bonus(
			vector( brick.position.x + brick.width / 2,
					brick.position.y + brick.height / 2 ),
					brick.bonustype )
		score_display.add_score_for_simple_brick( brick, ball )
		world:remove(brick)
		table.insert( bricks.breaking_bricks, brick )
		bricks.break_brick(brick)
		local snd = simple_break_sound[ snd_rng:random( #simple_break_sound ) ]
		snd:play()
		table.remove( bricks.current_level_bricks, get_key_for_value(bricks.current_level_bricks, brick))
	elseif bricks.is_armored( brick ) then
		bricks.armored_to_scratched( brick )
		local snd = armored_hit_sound[ snd_rng:random( #armored_hit_sound ) ]
		snd:play()
	elseif bricks.is_scratched( brick ) then
		bricks.scratched_to_cracked( brick )
		local snd = armored_hit_sound[ snd_rng:random( #armored_hit_sound ) ]
		snd:play()
	elseif bricks.is_cracked( brick ) then
		bonuses.generate_bonus(
			vector( brick.position.x + brick.width / 2,
					brick.position.y + brick.height / 2 ),
			brick.bonustype )
		world:remove(brick)
		table.insert( bricks.breaking_bricks, brick )
		bricks.break_brick(brick)
		score_display.add_score_for_cracked_brick( brick, ball )
		table.remove( bricks.current_level_bricks, get_key_for_value(bricks.current_level_bricks, brick))
		local snd = armored_break_sound[ snd_rng:random( #armored_break_sound ) ]
		snd:play()
	elseif bricks.is_heavyarmored( brick ) then
		local snd = ball_heavyarmored_sound[ snd_rng:random( #ball_heavyarmored_sound ) ]
		snd:play()
	end
end

function bricks.break_brick( single_brick )
	timer.tween(0.5, single_brick, {scale = 0})
	local shift_x = single_brick.position.x + single_brick.width / 2
	local shift_y = single_brick.position.y + single_brick.height / 2
	timer.tween(0.5, single_brick, {position = vector(shift_x, shift_y) } )
end

function bricks.update_brick ( world, brick )
	world:update( brick, brick.position.x, brick.position.y)
end

function bricks.draw()
   for _, brick in pairs( bricks.current_level_bricks ) do   --(*1)
      bricks.draw_brick( brick )
   end
   for _, brick in pairs( bricks.breaking_bricks ) do   --(*1)
      bricks.draw_brick( brick )
   end
end

function bricks.update( dt, world )
	timer.update( dt )
	local no_more_bricks = true
   	for _, brick in pairs( bricks.current_level_bricks ) do
   		if bricks.is_heavyarmored ( brick ) then
   			no_more_bricks = no_more_bricks and true
   		else
   			no_more_bricks = no_more_bricks and false
   		end
   		bricks.update_brick( world, brick )
   	end
   	bricks.no_more_bricks = no_more_bricks
end

function get_key_for_value(table, value)
	for k,v in pairs(table) do
		if v == value then
			return k
		end
	end
	return nil
end

return bricks