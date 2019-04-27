-- libCircles
-- todo: write a description

local libCircles = {}

libCircles._circles = {}

-- cursor position
libCircles.p = {}

function libCircles._reset()
  libCircles._circles = {}
  
  libCircles.p = {}
  libCircles.p.x = 128/2
  libCircles.p.y = 64/2
  
  libCircles.handleCircleBurst = nil
end
libCircles._reset()
  
-- adds a new circle at x, y and returns its index
function libCircles.addCircle(x, y)
  x = x or libCircles.p.x
  y = y or libCircles.p.y
  
	local c = {}
	c.x = x
	c.y = y
	c.r = 1
	
	table.insert(libCircles._circles, c)
		
	return #libCircles._circles
end	

-- removes the circle at the given index, or the last circle if index is nil
function libCircles.removeCircle(index)
  index = index or #libCircles._circles
  
	table.remove(libCircles._circles, index)
end

function libCircles.removeAllCircles()
  libCircles._circles = {}
end

function libCircles.forEachCircle(handler)
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
	libCircles._detectCollisions()
end

function libCircles.updateCursor(dx, dy)
  libCircles.p.x = libCircles._clamp(libCircles.p.x + dx, 0, 128)
  libCircles.p.y = libCircles._clamp(libCircles.p.y + dy, 0, 64)
end

--[[ 
Private Helpers
--]]

function libCircles._growCircles()
	for i=1,#libCircles._circles do
		local c = libCircles._circles[i]
		c.r = c.r + 1
	end	
end

-- todo: refactor to return hit circles
function libCircles._detectCollisions()
  for i=1,#libCircles._circles do
		local c = libCircles._circles[i]
		if libCircles._isCircleTooBig(c) then
		  libCircles._handleCircleBurst(c)
		end
		local hitCircle = libCircles._didCircleAtIndexCollideWithOtherCircles(i)
		if hitCircle ~= nil then
		  if math.random(2) == 1 then
		    libCircles._handleCircleBurst(hitCircle)
		  else
		    libCircles._handleCircleBurst(c)
		  end
		end
  end
end

-- todo: rename to _notifyOfCircleBurst.
function libCircles._handleCircleBurst(c)
  if libCircles.handleCircleBurst ~= nil then
    libCircles.handleCircleBurst(c.x, c.y, c.r)
  end
  -- todo: don't reset until we've detected and notified about all bursts
  c.r = 1
end

-- todo: this should change to ensure the circle is always fully on screen
function libCircles._isCircleTooBig(c)
  return c.r > 64
end

-- todo: fix name or implementation; name implies a BOOL return type
function libCircles._didCircleAtIndexCollideWithOtherCircles(c1i)
  -- compare c1 with other circles
  local c1 = libCircles._circles[c1i]
  
  for c2i=1,#libCircles._circles do
    if c1i ~= c2i then
      local c2 = libCircles._circles[c2i]
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

function libCircles._clamp(value, min, max)
  if value < min then
    return min
  elseif value > max then
    return max
  else
    return value
  end
end

return libCircles
