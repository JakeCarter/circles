-- libCircles

local libCircles = {}

libCircles._circles = {}
libCircles.debug = false

libCircles.p = {}
libCircles.p.x = 128/2
libCircles.p.y = 64/2
  
-- adds a new circle at x, y and returns its index
function libCircles.addCircle(x, y)
  x = libCircles.p.x
  y = libCircles.p.y
  
	local c = {}
	c.x = x
	c.y = y
	c.r = 1
	
	table.insert(libCircles._circles, c)
	
	if libCircles.debug then
	  print("circle added at point: " .. x .. ", " .. y .. " with index: " .. #libCircles._circles)
	end
	
	return #libCircles._circles
end	

-- removes a the circle at the given index
function libCircles.removeCircle(index)
  index = #libCircles._circles
  
	table.remove(libCircles._circles, index)
	
	if libCircles.debug then
	  print("removed circle at index: " .. index)
	end
end

function libCircles.removeAllCircles()
  libCircles._circles = {}
end

function libCircles.redrawCircles(handler)
  if handler ~= nil then
    for i=1,#libCircles._circles do
      local c = libCircles._circles[i]
      handler(c)
	  end
	end
end

-- updates the circles and calls the redraw function you set, if you set one
function libCircles.update()
  libCircles._growCircles()
	libCircles._detectColisions()
end

function libCircles.redrawCursor(handler)
  if handler ~= nil then
    handler(libCircles.p.x, libCircles.p.y)
  end
end

function libCircles.updateCursor(dx,dy)
  libCircles.p.x = libCircles.p.x + dx
  if libCircles.p.x < 0 then
    libCircles.p.x = 0
  elseif libCircles.p.x > 128 then
    libCircles.p.x = 128
  end

  libCircles.p.y = libCircles.p.y + dy
  if libCircles.p.y < 0 then
    libCircles.p.y = 0
  elseif libCircles.p.y > 64 then
    libCircles.p.y = 64
  end
end

--[[ 
Private Helpers
--]]

function libCircles._log(msg)
	if libCircles.debug then
	  print(msg)
	end
end

function libCircles._growCircles()
	-- grow each circle
	if libCircles.debug then
	 -- print("_growCircles()")
	end
	
	for i=1,#libCircles._circles do
		local c = libCircles._circles[i]
		c.r = c.r + 1
	end	
end

function libCircles._detectColisions()
  for i=1,#libCircles._circles do
		local c = libCircles._circles[i]
		if libCircles._isCircleTooBig(c) then
		  libCircles._handleCircleBurst(c)
		end
		local hitCircle = libCircles._didCircleAtIndexCollideWithOtherCircles(i)
		if hitCircle ~= nil then
		  libCircles._handleCircleBurst(hitCircle)
		  libCircles._handleCircleBurst(c)
		end
  end
end

libCircles.handleCircleBurst = nil
function libCircles._handleCircleBurst(c)
  if libCircles.handleCircleBurst ~= nil then
    libCircles.handleCircleBurst(c.x, c.y, c.r)
  end
  c.r = 1
end

function libCircles._isCircleTooBig(c)
  return c.r > 64
end

function libCircles._didCircleAtIndexCollideWithOtherCircles(c1i)
  -- compare c with other circles
  local c1 = libCircles._circles[c1i]
  
  for c2i=1,#libCircles._circles do
    -- libCircles._log("c2i: " .. c2i)
    if c1i ~= c2i then
      local c2 = libCircles._circles[c2i]
      -- libCircles._log("c2: " .. c2)
      if libCircles._areCirclesTouching(c1, c2) then
        return c2
      end
    end
  end
  
  return nil
end

function libCircles._areCirclesTouching(c1, c2)
	local distSq = (c1.x - c2.x) * (c1.x - c2.x) + (c1.y - c2.y) * (c1.y - c2.y)
	local radSumSq = (c1.r + c2.r) * (c1.r + c2.r)
	
	if distSq == radSumSq then
	  return true
	elseif distSq > radSumSq then
		return false
	else
		return true
	end
end

return libCircles
