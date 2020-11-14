local balls_ps = require 'balls_ps'
local sign = math.sign or function(x) return x < 0 and -1 or x > 0 and 1 or 0 end

local balls = {}
balls.image = love.graphics.newImage( "img/800x600/ball.png" )
local x_tile_pos = 0
local y_tile_pos = 0
local tile_width = 18
local tile_height = 18
local tileset_width = 18
local tileset_height = 18
balls.quad = love.graphics.newQuad( x_tile_pos, y_tile_pos,
								   tile_width, tile_height,
								   tileset_width, tileset_height )
balls.radius = tile_width / 2
local ball_x_shift = 0
local platform_height = 16
local platform_starting_pos = vector( 300, 500 )
local ball_platform_initial_separation = vector( ball_x_shift, -1 * platform_height / 2 - balls.radius - 1)
local initial_launch_speed_magnitude = 300

balls.current_balls = {}
balls.no_more_balls = false

balls_ps.setup()

local ball_wall_sound = love.audio.newSource(
   "sounds/ball_wall/pumpkin_break_01_short_norm.ogg",
   "static")

function balls.new_ball( position, speed, platform_launch_speed_magnitude, stuck_to_platform )
	return( { position = position,
			  speed = speed,
			  platform_launch_speed_magnitude = platform_launch_speed_magnitude,
			  stuck_to_platform = stuck_to_platform,
			  radius = balls.radius,
			  collision_counter = 0,
			  separation_from_platform_center = ball_platform_initial_separation,
			  quad = balls.quad,
			  combo = 0,
			  last_bounce_is_platform = false } )
end

function balls.add_ball( world, single_ball )
	world:add( single_ball, single_ball.position.x, single_ball.position.y, single_ball.radius, single_ball.radius )
	table.insert( balls.current_balls, single_ball )
end

function balls.launch_single_ball_from_platform()
	for _, single_ball in pairs( balls.current_balls ) do
		if single_ball.stuck_to_platform then
		   single_ball.stuck_to_platform = false
		   local platform_halfwidth = 70
		   local launch_direction = vector( single_ball.separation_from_platform_center.x / platform_halfwidth, -1 )
		   if single_ball.separation_from_platform_center.y < 0 then
			   single_ball.speed = launch_direction / launch_direction:len() * single_ball.platform_launch_speed_magnitude
			else
				launch_direction = vector( single_ball.separation_from_platform_center.x / platform_halfwidth, 1 )
				single_ball.speed = launch_direction / launch_direction:len() * single_ball.platform_launch_speed_magnitude
			end
			break
		end
	end
end

function balls.launch_all_balls_from_platform()
	for _, single_ball in pairs( balls.current_balls ) do
		if single_ball.stuck_to_platform then
		   single_ball.stuck_to_platform = false
		   local platform_halfwidth = 70
		   local launch_direction = vector( single_ball.separation_from_platform_center.x / platform_halfwidth, -1 )
		   if single_ball.separation_from_platform_center.y < 0 then
			   single_ball.speed = launch_direction / launch_direction:len() * single_ball.platform_launch_speed_magnitude
			else
				launch_direction = vector( single_ball.separation_from_platform_center.x / platform_halfwidth, 1 )
				single_ball.speed = launch_direction / launch_direction:len() * single_ball.platform_launch_speed_magnitude
			end
		end
	end
end

-- collision functions

function balls.normal_rebound( single_ball, shift_ball )
	local actual_shift = balls.determine_actual_shift( shift_ball )
	single_ball.position = single_ball.position + actual_shift
	if actual_shift.x ~= 0 then
		single_ball.speed.x = -single_ball.speed.x
	end
	if actual_shift.y ~= 0 then
		single_ball.speed.y = -single_ball.speed.y
	end
end

function balls.increase_collision_counter( single_ball )
	if not single_ball.stuck_to_platform then
		single_ball.collision_counter = single_ball.collision_counter + 1
	end
end

function balls.increase_speed_after_collision( single_ball )
	if not single_ball.stuck_to_platform then
		local speed_increase = 20
		local each_n_collisions = 10
		if single_ball.collision_counter ~= 0 and single_ball.collision_counter % each_n_collisions == 0 then
			single_ball.speed = single_ball.speed + single_ball.speed:normalized() * speed_increase
		end
	end
end

function balls.bounce_from_sphere( single_ball, platform, normal )
	local sphere_radius = 100
	local ball_center = single_ball.position
	local platform_center = platform.position + vector( platform.width / 2, platform.height / 2)
	local separation = ( ball_center - platform_center )
	
	--directions
	if normal.x == 0 and normal.y == -1 then
		--north
		local normal_direction = vector( separation.x / sphere_radius, normal.y )
		local v_norm = single_ball.speed:projectOn( normal_direction )
		local v_tan = single_ball.speed - v_norm
		local reverse_v_norm = v_norm * -1
		single_ball.speed = reverse_v_norm + v_tan
	elseif normal.x == 0 and normal.y == 1 then
		--south
		local normal_direction = vector( separation.x / sphere_radius, normal.y )
		local v_norm = single_ball.speed:projectOn( normal_direction )
		local v_tan = single_ball.speed - v_norm
		local reverse_v_norm = v_norm * -1
		single_ball.speed = reverse_v_norm + v_tan
	elseif normal.x == 1 and normal.y == 0 then
		--east
		single_ball.speed.x = single_ball.speed.x * -1
	elseif normal.x == -1 and normal.y == 0 then
		--west
		single_ball.speed.x = single_ball.speed.x * -1
	end
	
	
end

function balls.determine_actual_shift( shift_ball )
	local actual_shift = vector( 0, 0 )
	local min_shift = math.min( math.abs( shift_ball.x ), math.abs( shift_ball.y ) )
	if math.abs( shift_ball.x ) == min_shift then
		actual_shift.x = shift_ball.x
	else
		actual_shift.y = shift_ball.y
	end
	return actual_shift
end

function balls.min_angle_rebound( single_ball )
	local min_horizontal_rebound_angle = math.rad( 20 )
	local vx, vy = single_ball.speed:unpack()
	local new_vx, new_vy = vx, vy
	rebound_angle = math.abs( math.atan( vy / vx ) )
	if rebound_angle < min_horizontal_rebound_angle then
		new_vx = sign( vx ) * single_ball.speed:len() * math.cos( min_horizontal_rebound_angle )
		new_vy = sign( vy ) * single_ball.speed:len() * math.sin( min_horizontal_rebound_angle )
	end
	single_ball.speed = vector( new_vx, new_vy )
end


function balls.brick_rebound( single_ball, shift_ball, bricks, single_brick, bonuses, score_display, world )
	if not bricks.is_heavyarmored( single_brick ) then
		single_ball.combo = single_ball.combo + 1
		--print(single_ball.combo)
	end
	balls_ps.add_new( single_ball )
	bricks.brick_hit_by_ball( single_brick, shift_ball, bonuses, score_display, single_ball, world )
	--balls.normal_rebound( single_ball, shift_ball )
	balls.increase_collision_counter( single_ball )
	balls.increase_speed_after_collision( single_ball )
	last_bounce_is_platform = false
end

function balls.platform_rebound( single_ball, platform, normal )
	single_ball.combo = 0
	balls.increase_collision_counter( single_ball )
	balls.increase_speed_after_collision( single_ball )
	if not platform.glued then 
		balls.bounce_from_sphere( single_ball, platform, normal )
	else
		single_ball.stuck_to_platform = true
		local actual_shift = balls.determine_actual_shift( shift_ball )
		single_ball.position = single_ball.position + actual_shift
		single_ball.platform_launch_speed_magnitude = single_ball.speed:len()
		balls.compute_ball_platform_seperation( single_ball, platform )
	end
	last_bounce_is_platform = true
end

function balls.compute_ball_platform_seperation( single_ball, platform )
	local platform_center = vector(
		platform.position.x + platform.width / 2,
		platform.position.y + platform.height / 2 )
	local ball_center = single_ball.position:clone()
	single_ball.separation_from_platform_center = ball_center - platform_center
	--print( single_ball.separation_from_platform_center )
end


function balls.wall_rebound( single_ball, shift_ball )
	balls_ps.add_new( single_ball )
	--balls.normal_rebound( single_ball, shift_ball )
	balls.min_angle_rebound( single_ball )
	balls.increase_collision_counter( single_ball )
	balls.increase_speed_after_collision( single_ball )
	ball_wall_sound:play()
	last_bounce_is_platform = false
end

function balls.follow_platform( single_ball, platform )
	local target = vector( platform.position.x + platform.width / 2, platform.position.y - balls.radius )
	separation = ( single_ball.position - target ) * 0.1
	single_ball.position = single_ball.position - separation
end

function balls.check_balls_escaped_from_screen( world )
	for i, single_ball in pairs( balls.current_balls ) do
		local x, y = single_ball.position:unpack()
		local ball_top = y - single_ball.radius
		if ball_top > love.graphics.getHeight() then
			table.remove( balls.current_balls, i )
			world:remove( single_ball )
		end
	end
	if next( balls.current_balls ) == nil then
		balls.no_more_balls = true
	end
end

function balls.react_on_slow_down_bonus()
	local slowdown = 0.7
	for _, single_ball in pairs( balls.current_balls ) do
		single_ball.speed = single_ball.speed * slowdown
	end
end

function balls.react_on_accelerate_bonus()
	local accelerate = 1.3
	for _, single_ball in pairs( balls.current_balls ) do
		single_ball.speed = single_ball.speed * accelerate
	end
end

function balls.react_on_add_new_ball_bonus( world )
	local first_ball = balls.current_balls[1]
	local new_ball_position = first_ball.position:clone()
	local new_ball_speed = first_ball.speed:rotated( math.pi / 4 )
	local new_ball_launch_speed_magnitude = first_ball.platform_launch_speed_magnitude
	local new_ball_stuck = first_ball.stuck_to_platform
	balls.add_ball( world,
		balls.new_ball( new_ball_position, new_ball_speed,
						new_ball_launch_speed_magnitude,
						new_ball_stuck ) )
end

function balls.reset( world )
	balls.no_more_balls = false
	local keep_ball = balls.current_balls[1]
	for i in pairs( balls.current_balls ) do
		balls.current_balls[i] = nil
	end
	local position = platform_starting_pos + ball_platform_initial_separation
	local speed = vector( 0, 0 )
	local platform_launch_speed_magnitude = initial_launch_speed_magnitude
	local stuck_to_platform = true
	if keep_ball then
		keep_ball.speed = speed
		keep_ball.platform_launch_speed_magnitude = platform_launch_speed_magnitude
		keep_ball.stuck_to_platform = stuck_to_platform
		table.insert( balls.current_balls, keep_ball)
	else
		balls.add_ball( world, balls.new_ball(
							position, speed,
							platform_launch_speed_magnitude,
							stuck_to_platform ) )
	end
end

function balls.update_ball( single_ball, dt, platform, bricks, world, bonuses, score_display )
	if single_ball.stuck_to_platform then
		balls.follow_platform( single_ball, platform )
	else
		single_ball.position = single_ball.position + single_ball.speed * dt
		local actualX, actualY, cols, len = world:move(single_ball, single_ball.position.x, single_ball.position.y, ballFilter )
		single_ball.position = vector( actualX, actualY )

		for i = 1, len do
			local col = cols[1]
			local other = cols[i].other
			if other.isWall then
				balls.wall_rebound( single_ball, vector(0,0))
				balls.changeSpeedFromNormal( single_ball, col.normal.x, col.normal.y )
			elseif other.isBrick then
				balls.brick_rebound( single_ball, vector(0,0), bricks, other, bonuses, score_display, world )
				balls.changeSpeedFromNormal( single_ball, col.normal.x, col.normal.y )
			elseif other.isPlatform then
				balls.platform_rebound( single_ball, platform, vector( col.normal.x, col.normal.y ) )
				--balls.changeSpeedFromNormal( single_ball, col.normal.x, col.normal.y )
			end
		end
	end
end

local ballFilter = function(item, other)
	if other.isWall then return 'bounce'
	elseif other.isBrick then return 'bounce'
	elseif other.isPlatform then return 'bounce'
	end
end

function balls.changeSpeedFromNormal( single_ball, nx, ny )
	local vx, vy = single_ball.speed:unpack()

	if ( nx < 0 and vx > 0 ) or ( nx > 0 and vx < 0 ) then
		vx = -vx 
	end

	if ( ny < 0 and vy > 0 ) or ( ny > 0 and vy < 0 ) then
		vy = -vy 
	end

	single_ball.speed = vector( vx, vy )
end


function balls.update( dt, platform, bricks, world, bonuses, score_display )
	for _, ball in ipairs( balls.current_balls ) do
		balls.update_ball( ball, dt, platform, bricks, world, bonuses, score_display )
	end
	balls.check_balls_escaped_from_screen( world )
	balls_ps.update( dt )
end

function balls.draw_ball( single_ball )
	love.graphics.draw( balls.image,
						single_ball.quad,
						single_ball.position.x - single_ball.radius,
						single_ball.position.y - single_ball.radius )
	--[[local segments_in_circle = 16
	love.graphics.circle(  'line',
							ball.position.x,
							ball.position.y,
							ball.radius,
							segments_in_circle )--]]
end

function balls.draw()
	for _, ball in ipairs( balls.current_balls ) do
		balls.draw_ball( ball )
	end
	balls_ps.draw()
end

return balls