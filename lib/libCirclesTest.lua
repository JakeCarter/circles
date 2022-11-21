-- `include` is not a standard part of Lua. It is provided by the norns runtime, so I can't run it on my computer. This will check to see if the function exists and define something that works for me if it doesn't.
if (_G["include"] == nil) then
  include = function(path)
    return dofile("/Users/jake/Code/norns/circles/" .. path .. ".lua")
  end
end

local libc = dofile('/Users/jake/Code/norns/circles/lib/libCircles.lua')
--local libc = dofile('/home/we/dust/code/carter/circles/lib/libCircles.lua')

-- test default values
assert(libc ~= nil)
assert(libc.p.x == 64 and libc.p.y == 32)
assert(#libc._circles == 0)

-- test add circle with default values
libc.addCircle()
assert(#libc._circles == 1)
assert(libc._circles[1].r == 1)

-- test update
libc.updateCircles()
assert(libc._circles[1].r == 2)

-- test remove all circles
libc.removeAllCircles()
assert(#libc._circles == 0)

-- test add circle with given values
libc.addCircle(10, 20)
assert(#libc._circles == 1)
assert(libc._circles[1].x == 10)
assert(libc._circles[1].y == 20)

-- test reset
libc.handleCircleBurst = function(circle) end
assert(libc.handleCircleBurst ~= nil)
libc.reset()
assert(libc.p.x == 64 and libc.p.y == 32)
assert(#libc._circles == 0)
assert(libc.handleCircleBurst == nil)

-- test burst
libc.burst_type = 1
libc.p.x = 30
libc.addCircle()
libc.p.x = 40
libc.addCircle()
assert(#libc._circles == 2)
assert(libc._circles[1].r == 1)
assert(libc._circles[2].r == 1)

libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
assert(libc._circles[1].r == 4)
assert(libc._circles[2].r == 4)

-- a random circle will burst. we don't know which one. assert that only 1 of them has burst.
local burstCount = 0
libc.handleCircleBurst = function(circle)
  assert(circle.r == 5)
  burstCount = burstCount + 1
end
libc.updateCircles()
assert((libc._circles[1].r == 1 and libc._circles[2].r == 5) or (libc._circles[1].r == 5 and libc._circles[2].r == 1))
assert(burstCount == 1)
libc.reset()

-- test deterministic burst. bigger bubble should burst
libc.burst_type = libc.burst_types.deterministic
assert(#libc._circles == 0)
local c1Index = libc.addCircle(30, 0)
libc.updateCircles()
libc.addCircle(40, 0)
assert(#libc._circles == 2)
assert(libc._circles[1].r == 2)
assert(libc._circles[2].r == 1)

libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
burstCount = 0
libc.handleCircleBurst = function(circle)
  assert(circle == libc._circles[c1Index])
  assert(circle.r == 6)
  burstCount = burstCount + 1
end
libc.updateCircles()
assert(libc._circles[1].r == 1 and libc._circles[2].r == 5)
assert(burstCount == 1)
libc.reset()
libc.burst_type = libc.burst_types.random

-- test keeping cursor on screen: lower bound
libc.p.x = 0
libc.p.y = 0
libc.updateCursor(-1,-1)
assert(libc.p.x == 0)
assert(libc.p.y == 0)

-- test keeping cursor on screen: upper bound
libc.p.x = 128
libc.p.y = 64
libc.updateCursor(1,1)
assert(libc.p.x == 128-1)
assert(libc.p.y == 64-1)

-- test 3 circles colliding
libc.reset()
libc.addCircle(10, 32)
libc.addCircle(20, 32)
libc.addCircle(30, 32)
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.forEachCircle(function(c)
  assert(c.r == 4)
end)

-- ensure that at least 2 of them burst
local burstCount = 0
libc.handleCircleBurst = function(circle)
  burstCount = burstCount + 1
end
libc.updateCircles()
assert(burstCount == 2, "expected burstCount of 2 but got " .. burstCount)
libc.reset()

-- test remove circle at
libc.addCircle(10, 10)
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
libc.updateCircles()
assert(libc._circles[1].r == 10)
local p = {}
p.x = 10
p.y = 10
assert(libc._isPointInCircle(p, libc._circles[1]))
p.x = 15
p.y = 10
assert(libc._isPointInCircle(p, libc._circles[1]))
p.x = 22
p.y = 10
assert(not libc._isPointInCircle(p, libc._circles[1]))
p.x = 22
p.y = 5
assert(not libc._isPointInCircle(p, libc._circles[1]))
p.x = 9
p.y = 4
assert(libc._isPointInCircle(p, libc._circles[1]))
p.x = 1
p.y = 1
assert(not libc._isPointInCircle(p, libc._circles[1]))
p.x = 20
p.y = 10
assert(libc._isPointInCircle(p, libc._circles[1]))
p.x = -1
p.y = 10
assert(not libc._isPointInCircle(p, libc._circles[1]))

print("all tests passed!")
