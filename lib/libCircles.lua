-- libCircles

local libCircles = {}

libCircles._circles = {}
libCircles.debug = false

-- adds a new circle at x, y and returns its index
function libCircles.addCircle(x, y)
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
	table.remove(libCircles._circles, index)
	
	if libCircles.debug then
	  print("removed circle at index: " .. index)
	end
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
	-- todo: detect colisions and call handler
	libCircles._detectColisions()
end

--[[ 
Private Helpers
--]]

function libCircles._growCircles()
	-- grow each circle
	if libCircles.debug then
	  print("_growCircles()")
	end
	
	for i=1,#libCircles._circles do
		local c = libCircles._circles[i]
		c.r = c.r + 1
	end	
end

function libCircles._detectColisions()
  for i=1,#libCircles._circles do
		local c = libCircles._circles[i]
		if c.r > 64 then
		  -- too big, start it over
		  c.r = 1
		end
	end
end

return libCircles
