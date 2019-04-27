local libc = dofile('/Users/jake/Code/norns/circles/lib/libCircles.lua')

-- test default values
assert(libc ~= nil)
assert(libc.p.x == 64 and libc.p.y == 32)
assert(#libc._circles == 0)

-- test add circle with default values
libc.addCircle()
assert(#libc._circles == 1)
assert(libc._circles[1].r == 1)

-- test update
libc.update()
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
libc.handleCircleBurst = function(x, y, r) end
assert(libc.handleCircleBurst ~= nil)
libc._reset()
assert(libc.p.x == 64 and libc.p.y == 32)
assert(#libc._circles == 0)
assert(libc.handleCircleBurst == nil)

-- test burst
libc.p.x = 30
libc.addCircle()
libc.p.x = 40
libc.addCircle()
assert(#libc._circles == 2)
assert(libc._circles[1].r == 1)
assert(libc._circles[2].r == 1)

libc.update()
libc.update()
libc.update()
assert(libc._circles[1].r == 4)
assert(libc._circles[2].r == 4)

-- a random circle will burst. we don't know which one. assert that only 1 of them has burst.
local burstCount = 0
libc.handleCircleBurst = function(x, y, r)
    assert(r == 5)
    burstCount = burstCount + 1
end
libc.update()
assert((libc._circles[1].r == 1 and libc._circles[2].r == 5) or (libc._circles[1].r == 5 and libc._circles[2].r == 1))
assert(burstCount == 1)

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
assert(libc.p.x == 128)
assert(libc.p.y == 64)

print("all tests passed!")

