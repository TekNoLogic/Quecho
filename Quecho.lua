
local myname, ns = ...


ns.quests = setmetatable({}, {__index = function (t,i)
	local v = {}
	rawset(t, i, v)
	return v
end})


local f = CreateFrame("Frame")


function ns.OnLoad()
	ns.QUEST_LOG_UPDATE()

	RegisterAddonMessagePrefix("Quecho")
	RegisterAddonMessagePrefix("Quecho2")
	RegisterAddonMessagePrefix("Quecho3")
	RegisterAddonMessagePrefix("Quecho4")

	ns.RegisterEvent("UI_INFO_MESSAGE")
	ns.RegisterEvent("CHAT_MSG_ADDON")
	ns.RegisterEvent("QUEST_LOG_UPDATE")
end


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

	if ns.isWOD and dirty then ns.Update()
	elseif dirty then WatchFrame_Update() end
end


------------------------------
--      Event Handlers      --
------------------------------

function ns.UI_INFO_MESSAGE(event, msg)
	if not msg then return end
	if not (msg:find("(.+) %(Complete%)") or msg:find("(.+): (%d+/%d+)")) then
		return
	end

	SendAddonMessage("Quecho", msg, "PARTY")
end


local myname = UnitName("player").. "-".. GetRealmName()
function ns.CHAT_MSG_ADDON(event, prefix, msg, channel, sender)
	if sender == myname then return end

	if prefix == "Quecho" then
		local _, _, objective, progress = msg:find("([^:]+):? %(?([^)]+)%)?")

		local now = GetTime()
		sendtimes[sender..objective] = now
		ns.StartTimer(now + DELAY + 0.1, ExpireObjectives)

		ns.quests[sender][objective] = progress

		if ns.isWOD then ns.Update()
		else WatchFrame_Update() end

	elseif prefix == "Quecho2" then ns.Printf("%s turned in %s ", sender, msg)
	elseif prefix == "Quecho3" then ns.Printf("%s accepted %s ", sender, msg)
	elseif prefix == "Quecho4" then ns.Printf("%s abandoned %s ", sender, msg) end
end


local currentquests, oldquests, firstscan, abandoning = {}, {}, true
function ns.QUEST_LOG_UPDATE()
	currentquests, oldquests = oldquests, currentquests
	wipe(currentquests)

	local i, count, _, total = 0, 0, GetNumQuestLogEntries()
	while count < total do
		i = i + 1
		local link = GetQuestLink(i)
		if link then
			count = count + 1
			currentquests[ns.qids[link]] = link
		end
	end

	if firstscan then
		firstscan = nil
		return
	end

	for id,link in pairs(oldquests) do
		if not currentquests[id] then
			SendAddonMessage(abandoning and "Quecho4" or "Quecho2", link, "PARTY")
		end
	end
	for id,link in pairs(currentquests) do
		if not oldquests[id] then SendAddonMessage("Quecho3", link, "PARTY") end
	end

	abandoning = nil
end


local orig = AbandonQuest
function AbandonQuest(...)
	abandoning = true
	return orig(...)
end


-- /run LoadAddOn("Quecho"); Quecho_DebugComm()
-- function Quecho_DebugComm()
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 1/12", "", "Joe")
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 2/12", "", "Bob")
-- end
