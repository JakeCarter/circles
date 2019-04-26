-- libCircles
-- todo: write a description

local libCircles = {}

libCircles._circles = {}

-- todo: rename p to _p
libCircles.p = {}
libCircles.p.x = 128/2
libCircles.p.y = 64/2
  
-- adds a new circle at x, y and returns its index
function libCircles.addCircle(x, y)
  -- todo: test optional arguments
  x = libCircles.p.x
  y = libCircles.p.y
  
	local c = {}
	c.x = x
	c.y = y
	c.r = 1
	
	table.insert(libCircles._circles, c)
		
	return #libCircles._circles
end	

-- removes the circle at the given index, or the last circle if index is nil
function libCircles.removeCircle(index)
  index = #libCircles._circles
  
	table.remove(libCircles._circles, index)
end

function libCircles.removeAllCircles()
  libCircles._circles = {}
end

-- todo: rename redrawCircles to forEachCircle
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

function libCircles.updateCursor(dx, dy)
  libCircles.p.x = libCircles.p.x + dx
  -- todo: update to using min/max to clamp and add unit tests
  if libCircles.p.x < 0 then
    libCircles.p.x = 0
  elseif libCircles.p.x > 128 then
    libCircles.p.x = 128
  end

  libCircles.p.y = libCircles.p.y + dy
  -- todo: update to using min/max to clamp and add unit tests
  if libCircles.p.y < 0 then
    libCircles.p.y = 0
  elseif libCircles.p.y > 64 then
    libCircles.p.y = 64
  end
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
-- todo: add unit test of 3 circles colliding
-- todo: fix typ-o in name "collisions"
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
-- todo: rename to _notifyOfCircleBurst.
function libCircles._handleCircleBurst(c)
  if libCircles.handleCircleBurst ~= nil then
    libCircles.handleCircleBurst(c.x, c.y, c.r)
  end
  -- todo: don't reset until we've detected and notified about all bursts
  c.r = 1
end

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

return libCircles
