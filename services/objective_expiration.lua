
local myname, ns = ...


local DELAY = 60 * 5


local sendtimes = ns.NewMemoizingTable(function() return {} end)


local function ExpireObjectives()
	local cutoff = GetTime() - DELAY

	for sender,objectives in pairs(sendtimes) do
		for objective,time in pairs(objectives) do
			if time <= cutoff then
				ns.SendMessage("_PARTY_EXPIRE", sender, objective)
				sendtimes[sender][objective] = nil
			end
		end
	end
end


function OnPartyProgress(self, message, sender, objective, progress)
	sendtimes[sender][objective] = GetTime()
	C_Timer.After(DELAY + 0.1, ExpireObjectives)
end


ns.RegisterCallback("_PARTY_PROGRESS", OnPartyProgress)
