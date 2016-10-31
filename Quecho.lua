
local myname, ns = ...


ns.quests = setmetatable({}, {__index = function (t,i)
	local v = {}
	rawset(t, i, v)
	return v
end})


local f = CreateFrame("Frame")


local function OnLoad()
	ns.QUEST_LOG_UPDATE()

	RegisterAddonMessagePrefix("Quecho")
	RegisterAddonMessagePrefix("Quecho2")
	RegisterAddonMessagePrefix("Quecho3")
	RegisterAddonMessagePrefix("Quecho4")

	ns.RegisterEvent("UI_INFO_MESSAGE", ns.UI_INFO_MESSAGE)
	ns.RegisterEvent("CHAT_MSG_ADDON", ns.CHAT_MSG_ADDON)
	ns.RegisterEvent("QUEST_LOG_UPDATE", ns.QUEST_LOG_UPDATE)
end
ns.RegisterEvent("_THIS_ADDON_LOADED", OnLoad)


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

function ns.UI_INFO_MESSAGE(self, event, msgtype, msg)
	if not msg then return end
	if not (msg:find("(.+) %(Complete%)") or msg:find("(.+): (%d+/%d+)")) then
		return
	end

	SendAddonMessage("Quecho", msg, "PARTY")
end


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


local currentquests, oldquests, firstscan, abandoning = {}, {}, true
local progressbars = {}
function ns.QUEST_LOG_UPDATE()
	-- Don't swap if we don't have any data in the last scan
	if next(currentquests) then
		currentquests, oldquests = oldquests, currentquests
		wipe(currentquests)
	end

	local i, count = 0, 0
	local _, total = GetNumQuestLogEntries()
	for i=1,GetNumQuestLogEntries() do
		local _, _, _, _, _, _, _, quest_id = GetQuestLogTitle(i)
		local link = quest_id and GetQuestLink(quest_id)
		if link then
			currentquests[quest_id] = link
			if ns.ProgressbarQuests[quest_id] then
				progressbars[quest_id] = GetQuestObjectiveInfo(quest_id, 1, false)
			end
		end
	end

	if firstscan then
		firstscan = nil
		return
	end

	-- If our scan was empty, don't announce changes
	if not next(currentquests) then return end

	for id,link in pairs(oldquests) do
		if not currentquests[id] then
			SendAddonMessage(abandoning and "Quecho4" or "Quecho2", link, "PARTY")
			if progressbars[id] then
				SendAddonMessage("Quecho", progressbars[id].. ": 100%", "PARTY")
				progressbars[id] = nil
			end
		end
	end
	for id,link in pairs(currentquests) do
		if not oldquests[id] then
			SendAddonMessage("Quecho3", link, "PARTY")
			if ns.ProgressbarQuests[id] then
				progressbars[id] = GetQuestObjectiveInfo(id, 1, false)
			end
		end
	end

	for id,name in pairs(progressbars) do
		local msg = string.format("%s: %.1f%%", name, GetQuestProgressBarPercent(id))
		SendAddonMessage("Quecho", msg, "PARTY")
	end

	abandoning = nil
end


local orig = AbandonQuest
function AbandonQuest(...)
	abandoning = true
	return orig(...)
end


-- function Quecho_DebugComm()
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 1/12", "", "Joe")
-- 	ns.CHAT_MSG_ADDON("", "Quecho", "Something: 2/12", "", "Bob")
-- end

--[[
/run LoadAddOn("Quecho"); Quecho_DebugComm() --]]
