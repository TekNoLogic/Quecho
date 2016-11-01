
local myname, ns = ...


if not I_AM_TEKKUB then return end


function QuechoTest()
	ns.SendMessage("_PARTY_ACCEPT", "Testburr", "[Rawr!]")
	ns.SendMessage("_PARTY_ABANDON", "Testburr", "[Rawr!]")
	ns.SendMessage("_PARTY_TURNIN", "Testburr", "[Rawr!]")
	ns.SendMessage("_PARTY_PROGRESS", "Testburr", "Rawr", "imma beah")
end

--[[
/run LoadAddOn("Quecho"); QuechoTest()
]]
