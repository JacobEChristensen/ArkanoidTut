local platform = {}
local platform_starting_pos = vector( 300, 500 )
platform.position = vector( 300, 500 )
platform.speed = vector ( 800, 0 )
platform.image = love.graphics.newImage( "img/800x600/platform_var.png" )
platform.small_tile_width = 75
platform.small_tile_height = 16
platform.small_tile_x_pos = 0
platform.small_tile_y_pos = 0
platform.norm_tile_width = 108
platform.norm_tile_height = 16
platform.norm_tile_x_pos = 0
platform.norm_tile_y_pos = 32
platform.large_tile_width = 141
platform.large_tile_height = 16
platform.large_tile_x_pos = 0
platform.large_tile_y_pos = 64
platform.glued_x_pos_shift = 192
platform.tileset_width = 333
platform.tileset_height = 80
platform.quad = love.graphics.newQuad( platform.norm_tile_x_pos,
				     				   platform.norm_tile_y_pos,
								       platform.norm_tile_width,
								       platform.norm_tile_height,
								       platform.tileset_width,
								       platform.tileset_height )
platform.width = platform.norm_tile_width
platform.height = platform.norm_tile_height
platform.size = "norm"
platform.isPlatform = true


function platform.bounce_from_wall( shift_platform, wall )
	platform.position.x = platform.position.x + shift_platform.x
	if wall.next_level_bonus then
		platform.activated_next_level_bonus = true
	end
end

function platform.react_on_increase_bonus()
	if platform.size == "small" then
		platform.width = platform.norm_tile_width
		platform.height = platform.norm_tile_height
		platform.quad = love.graphics.newQuad(
			platform.norm_tile_x_pos, platform.norm_tile_y_pos,
			platform.norm_tile_width, platform.norm_tile_height,
			platform.tileset_width, platform.tileset_height )
		platform.size = "norm"
	elseif platform.size == "norm" then
		platform.width = platform.large_tile_width
		platform.height = platform.large_tile_height
		platform.quad = love.graphics.newQuad(
			platform.large_tile_x_pos, platform.large_tile_y_pos,
			platform.large_tile_width, platform.large_tile_height,
			platform.tileset_width, platform.tileset_height )
		platform.size = "large"
	end
end

function platform.react_on_decrease_bonus()
	if platform.size == "large" then
		platform.width = platform.norm_tile_width
		platform.height = platform.norm_tile_height
		platform.quad = love.graphics.newQuad(
			platform.norm_tile_x_pos, platform.norm_tile_y_pos,
			platform.norm_tile_width, platform.norm_tile_height,
			platform.tileset_width, platform.tileset_height )
		platform.size = "norm"
	elseif platform.size == "norm" then
		platform.width = platform.small_tile_width
		platform.height = platform.small_tile_height
		platform.quad = love.graphics.newQuad(
			platform.small_tile_x_pos, platform.small_tile_y_pos,
			platform.small_tile_width, platform.small_tile_height,
			platform.tileset_width, platform.tileset_height )
		platform.size = "small"
	end
end

function platform.react_on_glue_bonus()
	platform.glued = true
	if platform.size == "small" then
		platform.quad = love.graphics.newQuad(
			platform.small_tile_x_pos + platform.glued_x_pos_shift,
			platform.small_tile_y_pos,
			platform.small_tile_width,
			platform.small_tile_height,
			platform.tileset_width,
			platform.tileset_height )
	elseif platform.size == "norm" then
		platform.quad = love.graphics.newQuad(
			platform.norm_tile_x_pos + platform.glued_x_pos_shift,
			platform.norm_tile_y_pos,
			platform.norm_tile_width,
			platform.norm_tile_height,
			platform.tileset_width,
			platform.tileset_height )
	elseif platform.size == "large" then
		platform.quad = love.graphics.newQuad(
			platform.large_tile_x_pos + platform.glued_x_pos_shift,
			platform.large_tile_y_pos,
			platform.large_tile_width,
			platform.large_tile_height,
			platform.tileset_width,
			platform.tileset_height )
	end
end

function platform.remove_glued_effect()
   if platform.glued then
      platform.glued = false
      if platform.size == "small" then
         platform.quad = love.graphics.newQuad(
            platform.small_tile_x_pos,
            platform.small_tile_y_pos,
            platform.small_tile_width,
            platform.small_tile_height,
            platform.tileset_width,
            platform.tileset_height )
      elseif platform.size == "norm" then
         platform.quad = love.graphics.newQuad(
            platform.norm_tile_x_pos,
            platform.norm_tile_y_pos,
            platform.norm_tile_width,
            platform.norm_tile_height,
            platform.tileset_width,
            platform.tileset_height )
      elseif platform.size == "large" then
         platform.quad = love.graphics.newQuad(
            platform.large_tile_x_pos,
            platform.large_tile_y_pos,
            platform.large_tile_width,
            platform.large_tile_height,
            platform.tileset_width,
            platform.tileset_height )
      end
   end
end
		

function platform.reset_size_to_norm()
	platform.width = platform.norm_tile_width
	platform.height = platform.norm_tile_height
	platform.quad = love.graphics.newQuad(
		platform.norm_tile_x_pos, platform.norm_tile_y_pos,
		platform.norm_tile_width, platform.norm_tile_height,
		platform.tileset_width, platform.tileset_height )
	platform.size = "norm"
end

function platform.remove_bonuses_effects()
	platform.remove_glued_effect()
	platform.reset_size_to_norm()
	platform.activated_next_level_bonus = false
end

function platform.reset()
	--platform.position = platform_starting_pos
	timer.tween( 1, platform.position, platform_starting_pos, 'in-out-quad' )
	platform.remove_bonuses_effects()
end

function platform.follow_mouse( dt )
	local x, y = love.mouse.getPosition()
	local left_wall_plus_half_platform = 34 + platform.width / 2
	local right_wall_minus_half_platform = 576 - platform.width / 2	
	if  x > left_wall_plus_half_platform and x < right_wall_minus_half_platform then
		platform.position.x = x - platform.width / 2
	elseif x < left_wall_plus_half_platform then
		platform.position.x = left_wall_plus_half_platform - platform.width / 2
	elseif x > right_wall_minus_half_platform then
		platform.position.x = right_wall_minus_half_platform - platform.width / 2 
	end
end

function platform.make( world )
	world:add(platform, platform.position.x, platform.position.y, platform.width, platform.height )
end

function platform.update( dt, world)
	if controls == "keyboard" then
		if love.keyboard.isDown("right") then
			platform.position = platform.position + (platform.speed * dt)
		end
		if love.keyboard.isDown("left") then
			platform.position = platform.position - (platform.speed * dt)
		end
	elseif controls == "mouse" then
		platform.follow_mouse( dt )
	end
	world:update(platform, platform.position.x, platform.position.y, platform.width, platform.height )
end

function platform.draw()
	love.graphics.draw( platform.image,
						platform.quad,
						platform.position.x,
						platform.position.y )
--[[	love.graphics.rectangle('line',
							platform.position.x,
							platform.position.y,
							platform.width,
							platform.height )--]]
end

return platform