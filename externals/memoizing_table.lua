
local myname, ns = ...


-- Create a table that memoizes the results of a function
function ns.NewMemoizingTable(func)
	local function index(t, i)
		local v = func(i)
		t[i] = v
		return v
	end

	local t, mt = {}, {__index = index}
	setmetatable(t, mt)
	return t, mt
end
