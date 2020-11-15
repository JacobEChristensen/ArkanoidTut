local balls = require "balls"
local platform = require "platform"
local bricks = require "bricks"
local bonuses = require "bonuses"
local walls = require "walls"
local side_panel = require "side_panel"
local collisions = require "collisions"
local levels = require "levels"

local ended = false

local world = bump.newWorld()

local game = {}

function game.switch_to_next_level( bricks, ball, levels, side_panel, world )
	if bricks.no_more_bricks or platform.activated_next_level_bonus then
		ended = true
		if side_panel.score_display.accurate then
			ended = false
			bricks.clear_current_level_bricks( world )
			bonuses.clear_current_level_bonuses()
			platform.reset()
			balls.reset()
			if levels.current_level < #levels.sequence then
				gamestates.set_state( "game", { current_level = levels.current_level + 1 } )
			elseif levels.current_level >= #levels.sequence then
				gamestates.set_state( "gameFinished", {side_panel = side_panel} )
			end
		end
	end
end

function game.check_no_more_balls( ball, lives_display )
	if balls.no_more_balls then
		lives_display.lose_life()
		if lives_display.lives < 0 then
			gamestates.set_state( "gameover", { ball, platform, bricks, walls, side_panel } )
		else
			balls.reset( world )
			platform.remove_bonuses_effects()
			walls.remove_bonuses_effects()
			bonuses.clear_current_level_bonuses()
		end
	end
end

function game.load( prev_state, ... )
	walls.construct_walls( world )
	platform.make( world )
end

function game.enter( prev_state, ... )
	args = ...
	if prev_state == "gameover" or prev_state == "gameFinished" then
		side_panel.reset()
		balls.reset( world )
		platform.remove_bonuses_effects()
		bricks.clear_current_level_bricks( world )
		walls.remove_bonuses_effects()
		music:seek( 0 )
	end
	if prev_state == "gamePaused" then
		music:play()
	end
	if args and args.current_level then
		levels.current_level = args.current_level
		local level = levels.require_current_level()
		bricks.construct_level( level, world )
		balls.reset( world )
		platform.remove_bonuses_effects()
		walls.remove_bonuses_effects()
	end
end

function game.update( dt )
	if not ended then
		balls.update( dt, platform, bricks, world, bonuses, side_panel.score_display )
	end
	platform.update( dt, world )
	bricks.update( dt, world )
	bonuses.update( dt )
	walls.update( dt )
	side_panel.update( dt )
	collisions.resolve_collisions( balls, platform, walls, bricks, bonuses, side_panel, world)
	side_panel.lives_display.add_life_if_score_reached( side_panel.score_display.score )
	game.check_no_more_balls( balls, side_panel.lives_display )
	game.switch_to_next_level( bricks, ball, levels, side_panel )
end

function game.draw()
	balls.draw()
	platform.draw()
	bricks.draw()
	bonuses.draw()
	walls.draw()
	side_panel.draw()
end

function game.keyreleased( key, code )
	if key == 'c' then
		bricks.clear_current_level_bricks( world )
	elseif key == 'escape' then
		music:pause()
		gamestates.set_state( "gamePaused", { balls, platform, bricks, walls, side_panel })
	elseif key == 'space' or key == ' ' then
		balls.launch_single_ball_from_platform()
	elseif key == 'x' then
		control_switch()
		print(controls)
	end
end

function game.mousereleased( x, y, button, istouch)
	if button == 'l' or button == 1 then
		balls.launch_single_ball_from_platform()
	elseif button == 'r' or button == 2 then
		music:pause()
		gamestates.set_state( "gamePaused", { balls, platform, bricks, walls, side_panel })
	end
end

return game