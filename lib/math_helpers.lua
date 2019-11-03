local math_helpers = {}

math_helpers.clamp = function(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

math_helpers.scale = function(i, imin, imax, omin, omax)
	return ((i - imin) / (imax - imin)) * (omax - omin) + omin;
end

return math_helpers
