local balls_ps = {}

function balls_ps.setup()
	local img = love.graphics.newImage("img/800x600/ball_debris.png")

	pSystem = love.graphics.newParticleSystem(img, 100)
	pSystem:setParticleLifetime( 0.5, 2 )
	pSystem:setRelativeRotation( true )
	pSystem:setLinearAcceleration(-30, -20, 30, 20)
	pSystem:setTangentialAcceleration( -100, 100 )
	pSystem:setLinearDamping( 0.3, 0.5)
	pSystem:setSpeed( 30, 150 ) 
	pSystem:setDirection( -3.14 / 2 )
	pSystem:setPosition( 0, 0 )
	pSystem:setColors( 1, 1, 1, 1, 1, 1, 1, 0 )
	pSystem:setSizeVariation( 0 )
	pSystem:setSizes( 1, 0.5, 0.3 )
end

function balls_ps.add_new( single_ball )
	local PS = pSystem:clone()
    PS:setPosition( single_ball.position.x, single_ball.position.y )
    local ball_polar = single_ball.speed:toPolar()
    local direction = nil
    local dirVec = single_ball.speed
    if single_ball.speed.x < 0 and single_ball.speed.y < 0 then 
        --direction = 3.14 + ball_polar.x
        direction = dirVec:angleTo( vector( 1, 0 ) ) - 3.14
    elseif single_ball.speed.x < 0 and single_ball.speed.y > 0 then
    	direction = dirVec:angleTo( vector( 1, 0 ) ) + 3.14
    elseif single_ball.speed.x > 0 and single_ball.speed.y > 0 then
    	direction = dirVec:angleTo( vector( 1, 0 ) ) + 3.14
    elseif single_ball.speed.x > 0 and single_ball.speed.y < 0 then
    	direction = 3*3.14 / 2 - ball_polar.x
    end
    if direction then
		PS:setDirection( direction )
	end
	PS:emit( 5 )
    table.insert( balls_ps, PS )
end

function balls_ps.update( dt )
	for _, PS in ipairs( balls_ps ) do
    PS:update( dt )
  end
end

function balls_ps.draw()
for _, PS in ipairs( balls_ps ) do
    love.graphics.draw(PS, 0, 0)
  end
end

return balls_ps