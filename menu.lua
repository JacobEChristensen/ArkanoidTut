local menu = {}

local buttons = require "buttons"

local menu_buttons_image = love.graphics.newImage( "img/800x600/buttons.png" )
local button_tile_width = 128
local button_tile_height = 64
local play_button_tile_x_pos = 0
local play_button_tile_y_pos = 0
local quit_button_tile_x_pos = 0
local quit_button_tile_y_pos = 64
local selected_x_shift = 128
local tileset_width = 256
local tileset_height = 128
local play_button_quad = love.graphics.newQuad(
   play_button_tile_x_pos,
   play_button_tile_y_pos,
   button_tile_width,
   button_tile_height,
   tileset_width,
   tileset_height )
local play_button_selected_quad = love.graphics.newQuad(
   play_button_tile_x_pos + selected_x_shift,
   play_button_tile_y_pos,
   button_tile_width,
   button_tile_height,
   tileset_width,
   tileset_height )
local quit_button_quad = love.graphics.newQuad(
   quit_button_tile_x_pos,
   quit_button_tile_y_pos,
   button_tile_width,
   button_tile_height,
   tileset_width,
   tileset_height )
local quit_button_selected_quad = love.graphics.newQuad(
   quit_button_tile_x_pos + selected_x_shift,
   quit_button_tile_y_pos,
   button_tile_width,
   button_tile_height,
   tileset_width,
   tileset_height )

local start_button = {}
local quit_button = {}
local edit_button = {}

function menu.load( prev_state, ... )
	music:play()
	start_button = buttons.new_button{
		text = "New game",
		position = vector( (800 - button_tile_width ) / 2, 200 ),
		width = button_tile_width,
		height = button_tile_height,
		image = menu_buttons_image,
		quad = play_button_quad,
		quad_when_selected = play_button_selected_quad
	}
	quit_button = buttons.new_button{
		text = "Quit",
		position = vector( (800 - button_tile_width ) / 2, 310 ),
		width = button_tile_width,
		height = button_tile_height,
		image = menu_buttons_image,
		quad = quit_button_quad,
		quad_when_selected = quit_button_selected_quad
	}
	edit_button = buttons.new_button{
		text = "Edit",
		position = vector( (800 - button_tile_width ) / 2 + 1.5 * button_tile_width , 255 ),
		width = button_tile_width,
		height = button_tile_height,
		image = menu_buttons_image,
		--quad = quit_button_quad,
		--quad_when_selected = quit_button_selected_quad
	}
end

function menu.drawTutorial()
	love.graphics.print( "Controls: ",
						 10, 10)
	love.graphics.print( "By default the platform follows your mouse.",
						 10, 30)
	love.graphics.print( "Press X to switch to using the arrow keys",
						 10, 50)
	love.graphics.print( "In mouse controls, left click shoots the ball",
						 10, 70)
	love.graphics.print( "and right click pauses the game",
						 10, 90)
	love.graphics.print( "Using the keyboard, shoot with space and pause with esc",
						 10, 110)
end

function menu.update( dt )
	buttons.update_button( start_button, dt )
	buttons.update_button( quit_button, dt )
	buttons.update_button( edit_button, dt )
end

function menu.draw()
	--love.graphics.print("Menu gamestate. Press Enter to continue.", 280, 250)
	buttons.draw_button( start_button )
	buttons.draw_button( quit_button )
	buttons.draw_button( edit_button )
	menu.drawTutorial()
end

--[[function menu.keyreleased( key, code )
	if key == 'return' then
		gamestates.set_state( "game", { current_level = 1} )
	elseif key == 'escape' then
		love.event.quit()
	end
end--]]

function menu.mousereleased( x, y, button, istouch)
	if button == 'l' or button == 1 then
		if buttons.mousereleased( start_button, x, y, button ) then
			gamestates.set_state( "game", { current_level = 1} )
		elseif buttons.mousereleased( quit_button, x, y, button ) then
			love.event.quit()
		elseif buttons.mousereleased( edit_button, x, y, button ) then
			gamestates.set_state( "levelEditor" )
		end
	elseif button == 'r' or button == 2 then
		love.event.quit()
	end
end

return menu