-- libCircles
-- todo: write a description

local libCircles = {}

libCircles._circles = {}

-- cursor position
libCircles.p = {}
libCircles.shouldBurstOnScreenEdge = false

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
	local circlesToBurst = libCircles._detectCollisions()
  for k,v in pairs(circlesToBurst) do
    libCircles._notifyOfCircleBurst(k)
    k.r = 1
  end
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

function libCircles._detectCollisions()
  local circlesToBurst = {}
  
  for i=1,#libCircles._circles do
    local c1 = libCircles._circles[i]
    if libCircles._isCircleTooBig(c1) then
      circlesToBurst[c1] = true
    else
      for j=i+1,#libCircles._circles do
        local c2 = libCircles._circles[j]
        
        if libCircles._isCircleTooBig(c2) then
          circlesToBurst[c2] = true
        elseif libCircles._areCirclesTouching(c1, c2) then
          -- randomly pick one to burst
          if math.random(2) == 1 then
            circlesToBurst[c1] = true
          else
            circlesToBurst[c2] = true
          end
        end
      end 
    end    
  end
  
  return circlesToBurst
end

function libCircles._notifyOfCircleBurst(c)
  if libCircles.handleCircleBurst ~= nil then
    libCircles.handleCircleBurst(c)
  end
end

function libCircles._isCircleTooBig(c)
  if libCircles.shouldBurstOnScreenEdge then
    local top = c.y - c.r
    local right = c.x + c.r
    local bottom = c.y + c.r
    local left = c.x - c.r
    
    return top < 0 or right > 128 or bottom > 64 or left < 0
  else 
    return c.r > 64
  end
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
