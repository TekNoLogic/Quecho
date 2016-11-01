
local myname, ns = ...


ns.quests = setmetatable({}, {__index = function (t,i)
	local v = {}
	rawset(t, i, v)
	return v
end})


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

function OnPartyProgress(self, message, sender, objective, progress)
	local now = GetTime()
	sendtimes[sender..objective] = now
	ns.StartTimer(now + DELAY + 0.1, ExpireObjectives)

	ns.quests[sender][objective] = progress

	ns.Update()
end
ns.RegisterCallback("_PARTY_PROGRESS", OnPartyProgress)


-- function Quecho_DebugComm()
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 1/12", "", "Joe")
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 2/12", "", "Bob")
-- end

--[[
/run LoadAddOn("Quecho"); Quecho_DebugComm() --]]
