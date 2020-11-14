local lives_display = {}
lives_display.position = vector( 620, 500 )
lives_display.width = 170
lives_display.height = 65
lives_display.separation = 35
lives_display.livesDefault = 5
lives_display.lives = lives_display.livesDefault
lives_display.lives_added_from_score = 0

local bungee_font = love.graphics.newFont("/fonts/Bungee_Inline/BungeeInline-regular.ttf", 20)

function lives_display.add_life_if_score_reached( score )
	local score_milestone = (lives_display.lives_added_from_score + 1) * 3000
	if score >= score_milestone then
		lives_display.add_life()
		lives_display.lives_added_from_score = lives_display.lives_added_from_score + 1
	end
end

function lives_display.reset()
	lives_display.lives = lives_display.livesDefault
end

function lives_display.lose_life()
	lives_display.lives = lives_display.lives - 1
end

function lives_display.add_life()
	lives_display.lives = lives_display.lives + 1
end

function lives_display.update( dt )
end

function lives_display.draw()
	local oldfont = love.graphics.getFont()
	love.graphics.setFont( bungee_font )
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor( 1, 1, 1, 230/255 )
	love.graphics.printf( "EXTRA LIVES: " .. tostring( lives_display.lives ),
						 lives_display.position.x,
						 lives_display.position.y,
						 lives_display.width,
						 "center" )
	--TEEEEEMP
	love.graphics.printf( controls,
						 lives_display.position.x,
						 lives_display.position.y + lives_display.separation,
						 lives_display.width,
						 "center" )
	love.graphics.setFont( oldfont )
	love.graphics.setColor( r, g, b, a)
end

return lives_display