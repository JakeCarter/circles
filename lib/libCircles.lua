-- libCircles.lua by @JakeCarter
-- libCircles is a circle sequencer. Clients can add circles to the system, when two circles touch a random one is chosen to burst. When it bursts it calls a handler that the client sets.
-- Public API:
--  Properties:
--   p - cursor position. contains x and y properties. defaults to center of screen
--   shouldBurstOnScreenEdge - bool flag indicating whether a circle should burst if it touches a screen edge. defaults to false
--   handleCircleBurst - function handler that is called when a circle bursts. defaults to nil
--  Functions:
--   addCircle(x, y) - adds a circle to the system and returns its index. x and y are optional. if they are omitted, a cirlce will be added at p.x, p.y
--   removeCircle(index) - removes the circle at the given index. index is optional. if it is omitted, the last circle will be removed
--   removeAllCircles() - removes all circles
--   forEachCirlce(handler) - iterates through each circle calling the handler passing in the current circle
--   updateCircles() - increments each circle's size and runs collision detection
--   updateCursor(dx, dy) - updates p with the given x, y deltas

local libCircles = {}

libCircles.p = {}
libCircles.shouldBurstOnScreenEdge = false

function libCircles.reset()
  libCircles._circles = {}
  
  libCircles.p = {}
  libCircles.p.x = 128/2
  libCircles.p.y = 64/2
  
  libCircles.handleCircleBurst = nil
end
libCircles.reset()
  
--- adds a new circle at x, y and returns its index
-- @param x the x position. optional, defaults to p.x
-- @param y the y position. optional, defaults to p.y
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

--- removes the circle at the given index
-- @param index the index of the circle to remove. optional, defaults to the index of the last circle that was added
function libCircles.removeCircle(index)
  index = index or #libCircles._circles
  
	table.remove(libCircles._circles, index)
end

--- removes all circles
function libCircles.removeAllCircles()
  libCircles._circles = {}
end

--- iterates over each circle calling handler
-- @param handler the handler to call. handler will be passed a circle which contains x, y and r properties
function libCircles.forEachCircle(handler)
  if handler ~= nil then
    for i=1,#libCircles._circles do
      local c = libCircles._circles[i]
      handler(c)
	  end
	end
end

--- updates the circles and performs collision detection
function libCircles.updateCircles()
  libCircles._growCircles()
	local circlesToBurst = libCircles._detectCollisions()
  for k,v in pairs(circlesToBurst) do
    libCircles._notifyOfCircleBurst(k)
    k.r = 1
  end
end

--- updates the cursor using the x and y deltas. these values are clamped to ensure the cursor stays on screen
-- @param dx The x delta that is added to p.x
-- @param dy The y delta that is added to p.y
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
