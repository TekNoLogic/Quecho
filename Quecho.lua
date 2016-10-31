
local myname, ns = ...


ns.quests = setmetatable({}, {__index = function (t,i)
	local v = {}
	rawset(t, i, v)
	return v
end})


local f = CreateFrame("Frame")


local function OnLoad()
	RegisterAddonMessagePrefix("Quecho")
	RegisterAddonMessagePrefix("Quecho2")
	RegisterAddonMessagePrefix("Quecho3")
	RegisterAddonMessagePrefix("Quecho4")

	ns.RegisterCallback("CHAT_MSG_ADDON", ns.CHAT_MSG_ADDON)
end
ns.RegisterCallback("_THIS_ADDON_LOADED", OnLoad)


---------------------------
--      Reset timer      --
---------------------------

local DELAY = 60 * 5
local sendtimes = {}
local function ExpireObjectives()
	local cutoff = GetTime() - DELAY
	local dirty
	for sender,objectives in pairs(ns.quests) do
		for objective in pairs(objectives) do
			if sendtimes[sender..objective] <= cutoff then
				sendtimes[sender..objective] = nil
				ns.quests[sender][objective] = nil
				dirty = true
			end
		end
	end

	if dirty then ns.Update() end
end


------------------------------
--      Event Handlers      --
------------------------------

local myname = UnitName("player").. "-".. GetRealmName():gsub(" ", "")
function ns.CHAT_MSG_ADDON(self, event, prefix, msg, channel, sender)
	if sender == myname then return end

	if prefix == "Quecho" then
		local _, _, objective, progress = msg:find("([^:]+):? %(?([^)]+)%)?")

		local now = GetTime()
		sendtimes[sender..objective] = now
		ns.StartTimer(now + DELAY + 0.1, ExpireObjectives)

		ns.quests[sender][objective] = progress

		ns.Update()

	elseif prefix == "Quecho2" then ns.Printf("%s turned in %s ", sender, msg)
	elseif prefix == "Quecho3" then ns.Printf("%s accepted %s ", sender, msg)
	elseif prefix == "Quecho4" then ns.Printf("%s abandoned %s ", sender, msg) end
end


-- function Quecho_DebugComm()
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 1/12", "", "Joe")
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 2/12", "", "Bob")
-- end

--[[
/run LoadAddOn("Quecho"); Quecho_DebugComm() --]]
