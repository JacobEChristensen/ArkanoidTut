local score_display = {}
score_display.position = vector( 640, 32)
score_display.width = 120
score_display.height = 65
score_display.separation = 35
score_display.score = 0
score_display.score_buffer = 0
score_display.score_animations = {}
score_display.scale = 1
score_display.accurate = true


local bungee_font = love.graphics.newFont("/fonts/Bungee_Inline/BungeeInline-regular.ttf", 20)

function add_score_anim( brick, ball, score )
	score_display.accurate = false
	local anim = {}
	anim.position = brick.position:clone()
	anim.position.x = anim.position.x + brick.width / 2
	anim.score = score * ball.combo
	anim.scale = 1 + ball.combo / 10
	anim.done = false
	timer.tween(1, anim, {position = score_display.position }, 'in-quad', function() anim.done = true end)
	table.insert( score_display.score_animations, anim )
end

function score_display.reset()
	score_display.score_buffer = 0
	score_display.score = 0
end

function score_display.add_score_for_simple_brick( brick, ball )
	local score_increase = 10
	add_score_anim( brick, ball, score_increase )
end

function score_display.add_score_for_cracked_brick( brick, ball )
	local score_increase = 30
	add_score_anim( brick, ball, score_increase )
end

function score_display.scale_display_up()
	timer.tween(0.5, score_display, {scale = 1.5}, 'in-quad', function() score_display.scale_display_down() end )
end

function score_display.scale_display_down()
	timer.tween(0.5, score_display, {scale = 1}, 'in-quad', function() score_display.scale = 1 end )
end

function score_display.update( dt )
	if score_display.score_buffer > 1000 then
		score_display.score = score_display.score + 100
		score_display.score_buffer = score_display.score_buffer - 100
	elseif score_display.score_buffer > 100 then
		score_display.score = score_display.score + 10
		score_display.score_buffer = score_display.score_buffer - 10
	elseif score_display.score_buffer > 0 then
		score_display.score = score_display.score + 1
		score_display.score_buffer = score_display.score_buffer - 1
	end
	if score_display.score_buffer == 0 and score_display.score_animations[1] == nil and not score_display.accurate then
		score_display.accurate = true
		--print("works")
	end
end

function score_display.draw()
	local oldfont = love.graphics.getFont()
	love.graphics.setFont( bungee_font )
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor( 1, 1, 1, 230/255 )
	love.graphics.printf( "Score:",
						 score_display.position.x,
						 score_display.position.y,
						 score_display.width,
						 "center",
						 0,
						 score_display.scale )
	love.graphics.printf( score_display.score,
						 score_display.position.x,
						 score_display.position.y + score_display.separation,
						 score_display.width,
						 "center",
						 0,
						 score_display.scale )
	for i, anim in ipairs( score_display.score_animations ) do
		if anim.done then
				--score_display.scale_display_up()
				score_display.score_buffer = score_display.score_buffer + anim.score
			table.remove( score_display.score_animations, i)
		else
			love.graphics.print( "+" .. tostring( anim.score ),
								 anim.position.x,
								 anim.position.y,
								 0,
								 anim.scale )
		end
	end
	love.graphics.setFont( oldfont )
    love.graphics.setColor( r, g, b, a )
end

return score_display