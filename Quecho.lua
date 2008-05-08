
-------------------------------------
--      Namespace Declaration      --
-------------------------------------

Quecho = DongleStub("Dongle-1.0"):New("Quecho")


function Quecho:Initialize()
	self.quests = setmetatable({}, {__index = function (t,i)
		local v = {}
		rawset(t, i, v)
		return v
	end})
end


function Quecho:Enable()
	self:RegisterEvent("UI_INFO_MESSAGE")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:QUEST_LOG_UPDATE()
end


---------------------------
--      Reset timer      --
---------------------------

local DELAY = 60 * 5
local sendtimes, nextpurge = {}
local f = CreateFrame("Frame")
local function OnUpdate(f)
	if not nextpurge then f:SetScript("OnUpdate", nil) end

	local now = GetTime()
	if now >= (nextpurge + DELAY) then
		local next2
		for sender,objectives in pairs(Quecho.quests) do
			for objective in pairs(objectives) do
				local t = sendtimes[sender..objective]
				if (t + DELAY) <= now then
					Quecho:Debug(1, "Purging", sender..objective)
					sendtimes[sender..objective] = nil
					Quecho.quests[sender][objective] = nil
				elseif not next2 or t < next2 then next2 = t end
			end
		end

		Quecho:UpdateTracker()
		if not next2 then f:SetScript("OnUpdate", nil) end
		nextpurge = next2
	end
end


------------------------------
--      Event Handlers      --
------------------------------

function Quecho:UI_INFO_MESSAGE(event, msg)
	if not msg or not msg:find("(.+): (%d+/%d+)") then return end
	SendAddonMessage("Quecho", msg, "PARTY")
end


local myname = UnitName("player")
function Quecho:CHAT_MSG_ADDON(event, prefix, msg, channel, sender)
	if sender == myname then return end

	if prefix == "Quecho" then
		local _, _, objective, progress = msg:find("(.+): (%d+/%d+)")
		self:Debug(1, sender, msg, objective, progress)

		sendtimes[sender..objective] = GetTime()
		if not nextpurge then
			nextpurge = GetTime()
			f:SetScript("OnUpdate", OnUpdate)
		end
		self.quests[sender][objective] = progress

		self:UpdateTracker()

	elseif prefix == "Quecho2" then self:PrintF("%s turned in %s ", sender, msg)
	elseif prefix == "Quecho3" then self:PrintF("%s accepted %s ", sender, msg)
	elseif prefix == "Quecho4" then self:PrintF("%s abandoned %s ", sender, msg) end
end


local currentquests, oldquests, firstscan, abandoning = {}, {}, true
function Quecho:QUEST_LOG_UPDATE()
	currentquests, oldquests = oldquests, currentquests
	for i in pairs(currentquests) do currentquests[i] = nil end

	for i=1,GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		if link then currentquests[link] = true end
	end

	if firstscan then
		firstscan = nil
		return
	end

	for link in pairs(oldquests) do if not currentquests[link] then SendAddonMessage(abandoning and "Quecho4" or "Quecho2", link, "PARTY") end end
	for link in pairs(currentquests) do if not oldquests[link] then SendAddonMessage("Quecho3", link, "PARTY") end end

	abandoning = nil
end


local orig = AbandonQuest
function AbandonQuest(...)
	abandoning = true
	return orig(...)
end

