
local myname, Quecho = ...


Quecho.quests = setmetatable({}, {__index = function (t,i)
	local v = {}
	rawset(t, i, v)
	return v
end})


local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(frame, event, ...) if Quecho[event] then return Quecho[event](Quecho, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")


function Quecho:ADDON_LOADED(event, addon)
	if addon ~= myname then return end

	self:QUEST_LOG_UPDATE()

	RegisterAddonMessagePrefix("Quecho")
	RegisterAddonMessagePrefix("Quecho2")
	RegisterAddonMessagePrefix("Quecho3")
	RegisterAddonMessagePrefix("Quecho4")

	f:RegisterEvent("UI_INFO_MESSAGE")
	f:RegisterEvent("CHAT_MSG_ADDON")
	f:RegisterEvent("QUEST_LOG_UPDATE")

	f:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end


local function PrintF(...) print(string.format(...)) end


---------------------------
--      Reset timer      --
---------------------------

local DELAY = 60 * 5
local sendtimes, nextpurge = {}
local function OnUpdate(f)
	if not nextpurge then f:SetScript("OnUpdate", nil) end

	local now = GetTime()
	if now >= (nextpurge + DELAY) then
		local next2
		for sender,objectives in pairs(Quecho.quests) do
			for objective in pairs(objectives) do
				local t = sendtimes[sender..objective]
				if (t + DELAY) <= now then
					sendtimes[sender..objective] = nil
					Quecho.quests[sender][objective] = nil
				elseif not next2 or t < next2 then next2 = t end
			end
		end

		WatchFrame_Update()
		if not next2 then f:SetScript("OnUpdate", nil) end
		nextpurge = next2
	end
end


------------------------------
--      Event Handlers      --
------------------------------

function Quecho:UI_INFO_MESSAGE(event, msg)
	if not msg or not (msg:find("(.+) %(Complete%)") or msg:find("(.+): (%d+/%d+)")) then return end
	SendAddonMessage("Quecho", msg, "PARTY")
end


local myname = UnitName("player")
function Quecho:CHAT_MSG_ADDON(event, prefix, msg, channel, sender)
	if sender == myname then return end

	if prefix == "Quecho" then
		local _, _, objective, progress = msg:find("([^:]+):? %(?([^)]+)%)?")

		sendtimes[sender..objective] = GetTime()
		if not nextpurge then
			nextpurge = GetTime()
			f:SetScript("OnUpdate", OnUpdate)
		end
		self.quests[sender][objective] = progress

		WatchFrame_Update()

	elseif prefix == "Quecho2" then PrintF("%s turned in %s ", sender, msg)
	elseif prefix == "Quecho3" then PrintF("%s accepted %s ", sender, msg)
	elseif prefix == "Quecho4" then PrintF("%s abandoned %s ", sender, msg) end
end


local currentquests, oldquests, firstscan, abandoning = {}, {}, true
function Quecho:QUEST_LOG_UPDATE()
	currentquests, oldquests = oldquests, currentquests
	wipe(currentquests)

	for i=1,GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		if link then currentquests[self.qids[link]] = link end
	end

	if firstscan then
		firstscan = nil
		return
	end

	for id,link in pairs(oldquests) do if not currentquests[id] then SendAddonMessage(abandoning and "Quecho4" or "Quecho2", link, "PARTY") end end
	for id,link in pairs(currentquests) do if not oldquests[id] then SendAddonMessage("Quecho3", link, "PARTY") end end

	abandoning = nil
end


local orig = AbandonQuest
function AbandonQuest(...)
	abandoning = true
	return orig(...)
end


-- /run LoadAddOn("Quecho"); Quecho_DebugComm()
-- function Quecho_DebugComm()
-- 	Quecho:CHAT_MSG_ADDON("", "Quecho", "Something: 1/12", "", "Joe")
-- 	Quecho:CHAT_MSG_ADDON("", "Quecho", "Something: 2/12", "", "Bob")
-- end
