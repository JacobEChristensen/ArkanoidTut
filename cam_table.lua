cam = camera.new()

function cam.shake( length )
	local orig_x, orig_y = cam:position()
	timer.during( length, function() cam:lookAt(orig_x + math.random(-2,2), orig_y + math.random(-2,2)) end, function()
    	-- reset camera position
    	cam:lookAt(orig_x, orig_y)
	end)
end

return cam