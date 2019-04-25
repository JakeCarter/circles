function deepcompare(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then return t1 == t2 end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcompare(v1,v2) then return false end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deepcompare(v1,v2) then return false end
  end
  return true
end

local libc = dofile('/Users/jake/Code/norns/circles/lib/libCircles.lua')

assert(libc ~= nil)
assert(deepcompare(libc.p, {["x"] = 64, ["y"] = 32}))
assert(#libc._circles == 0)

libc.addCircle()
assert(#libc._circles == 1)
assert(libc._circles[1].r == 1)

libc.update()
assert(libc._circles[1].r == 2)

libc.removeAllCircles()
assert(#libc._circles == 0)

libc.p.x = 30
libc.addCircle()
libc.p.x = 40
libc.addCircle()
assert(#libc._circles == 2)
assert(libc._circles[1].r == 1)
assert(libc._circles[2].r == 1)

-- test burst
libc.update()
libc.update()
libc.update()
assert(libc._circles[1].r == 4)
assert(libc._circles[2].r == 4)

local burstCount = 0
libc.handleCircleBurst = function(x, y, r)
    assert(r == 5)
    burstCount = burstCount + 1
end
libc.update()
assert(libc._circles[1].r == 1)
assert(libc._circles[2].r == 1)
assert(burstCount == 2)

print("all tests passed!")

