local collisions = {}

local platform = require "platform"
local balls = require "balls"
local bricks = require "bricks"
local walls = require "walls"

function collisions.check_rectangles_overlap( a, b )
	local overlap = false
	local shift_b = vector ( 0, 0 )
	if not( a.x + a.width < b.x or b.x + b.width < a.x or a.y + a.height < b.y or b.y + b.height < a.y ) then
		overlap = true
		if ( a.x + a.width / 2 ) < ( b.x + b.width / 2 ) then
			shift_b.x = ( a.x + a.width ) - b.x
		else
			shift_b.x = a.x - ( b.x + b.width )
		end
		if ( a.y + a.height / 2) < ( b.y + b.height / 2 ) then
			shift_b.y = ( a.y + a.height ) - b.y
		else
			shift_b.y = a.y - ( b.y + b.height )
		end
	end
	return overlap, shift_b
end

function collisions.ball_platform_collision( ball, platform )
	local overlap, shift_ball
	local ball_hitbox_increase = 0
	local a = { x = platform.position.x,
				y = platform.position.y,
				width = platform.width + ball_hitbox_increase,
				height = platform.height + ball_hitbox_increase }
	for _, ball in pairs( balls.current_balls ) do
		local b = { x = ball.position.x - ball.radius,
					y = ball.position.y - ball.radius,
					width = 2 * ball.radius,
					height = 2 * ball.radius }
		overlap, shift_ball = collisions.check_rectangles_overlap( a, b )
		if overlap and not ball.stuck_to_platform and not ball.last_bounce_is_platform then
			--print( "ball-platform collision" )
			balls.platform_rebound( ball, shift_ball, platform )
		end
	end
end

function collisions.ball_walls_collision( ball, walls )
	local overlap, shift_ball
	for i, ball in pairs( balls.current_balls ) do
		local b = { x = ball.position.x - ball.radius,
					y = ball.position.y - ball.radius,
					width = 2 * ball.radius,
					height = 2 * ball.radius }
		for j, wall in pairs( walls.current_level_walls ) do
			local a = { x = wall.position.x,
						y = wall.position.y,
						width = wall.width,
						height = wall.height }
			overlap, shift_ball = collisions.check_rectangles_overlap( a, b )
			if overlap then
				--print( "ball-wall collision" )
				--balls.wall_rebound( ball, shift_ball )
			end
		end
	end
end

function collisions.platform_walls_collision( platform, walls )
	local overlap, shift_platform
	local b = { x = platform.position.x,
				y = platform.position.y,
				width = platform.width,
				height = platform.height }
	for _, wall in pairs( walls.current_level_walls ) do
		local a = { x = wall.position.x,
					y = wall.position.y,
					width = wall.width,
					height = wall.height }
		overlap, shift_platform = collisions.check_rectangles_overlap( a, b )
		if overlap then
			--print( "platform-wall collision" )
			platform.bounce_from_wall( shift_platform, wall )
		end
	end
end


function collisions.ball_bricks_collision( ball, bricks, bonuses, score_display )
	local overlap, shift_ball
	for j, ball in pairs( balls.current_balls ) do
		local b = { x = ball.position.x - ball.radius,
					y = ball.position.y - ball.radius,
					width = 2 * ball.radius,
					height = 2 * ball.radius }
		for i, brick in pairs( bricks.current_level_bricks ) do
			local a = { x = brick.position.x,
						y = brick.position.y,
						width = brick.width,
						height = brick.height }
			overlap, shift_ball = collisions.check_rectangles_overlap( a, b )
			if overlap then
				--print( "ball-brick collision" )
				--balls.brick_rebound( ball, shift_ball, bricks, brick )
				--bricks.brick_hit_by_ball( i, brick, shift_ball, bonuses, score_display, ball )
			end
		end
	end
end

function collisions.platform_bonuses_collision( platform, bonuses, balls, walls, lives_display, world )
	local overlap
	local b = { x = platform.position.x,
				y = platform.position.y, 
				width = platform.width,
				height = platform.height }
	for i, bonus in pairs( bonuses.current_level_bonuses ) do
		local a = { x = bonus.position.x - bonuses.radius,
					y = bonus.position.y - bonuses.radius,
					width = 2 * bonuses.radius,
					height = 2 * bonuses.radius}
		overlap = collisions.check_rectangles_overlap( a, b )
		if overlap then
			bonuses.bonus_collected( i, bonus, balls, platform, walls, lives_display, world )
		end
	end
end

function collisions.resolve_collisions( balls, platform, walls, bricks, bonuses, side_panel, world )
	--collisions.ball_platform_collision( balls, platform )
	--collisions.ball_walls_collision( balls, walls )
	--collisions.ball_bricks_collision( balls, bricks, bonuses, side_panel.score_display )
	--collisions.platform_walls_collision( platform, walls )
	collisions.platform_bonuses_collision( platform, bonuses, balls, walls, side_panel.lives_display, world )
end

return collisions