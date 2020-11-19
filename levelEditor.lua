local levelEditor = {}

local bricks = require "bricks"
local walls = require "walls"
local editor_tile = require "editor_tile"

local world = bump.newWorld()

local bricktype_clipboard = 00

function levelEditor.makeGrid()
	for i = 1, bricks.rows do
		for j = 1, bricks.columns do
			editor_tile.make_tile( i, j )
		end
	end
end

function levelEditor.load( prev_state, ... )
	walls.construct_walls( world )
	levelEditor.makeGrid()
end

function levelEditor.enter( prev_state, ... )
	game_objects = ...
end

function levelEditor.update( dt )
	editor_tile.update( dt )
end

function levelEditor.draw()
	walls.draw()
	editor_tile.draw()
end

function levelEditor.keyreleased( key, code )
	if key == "escape" then
		love.event.quit()
	end
end

function levelEditor.mousereleased( x, y, button, istouch)
	if button == 1 then
		editor_tile.react_on_left_click()
	end
	if button == 2 then
		editor_tile.react_on_right_click()
	end
end

function levelEditor.keyreleased( key, code )
	if key == 'c' then
		bricktype_clipboard = editor_tile.react_on_copy()
	elseif key == 'v' then
		editor_tile.react_on_paste( bricktype_clipboard )
	elseif key == 'e' then
		levelEditor.export()
	end
end

function levelEditor.exit()
	game_objects = nil
end

function levelEditor.export()
	--testTable = { 10, 10, 13 }
	--testTable = editor_tile.current_level_tiles
	testTable = editor_tile.getLevel()
	t = "levels/temp/testSave" .. tostring(os.date("%d-%m-%Y")) .. "-" .. tostring(os.date("%H%M%S")) .. ".txt"
	table.save( testTable, t)
end

return levelEditor