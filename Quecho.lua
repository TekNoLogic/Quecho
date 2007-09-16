
------------------------------
--      Are you local?      --
------------------------------

local myname = UnitName("player")
local partychat = false


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
	self:RegisterEvent("CHAT_MSG_SYSTEM")
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
	if not msg then return end

	if not msg:find("(.+): (%d+/%d+)") then return end

	SendAddonMessage("Quecho", msg, "PARTY")
	if partychat then SendChatMessage(msg, "PARTY") end
end


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

	elseif prefix == "Quecho2" then
		self:Print(sender, "Quest turned in: "..msg)
	elseif prefix == "Quecho3" then
		self:Print(sender, "Quest accepted: "..msg)
	end
end


function Quecho:CHAT_MSG_SYSTEM(event, msg)
	local _, _, text = msg:find("Quest accepted: (.*)")
	if text then SendAddonMessage("Quecho3", text, "PARTY") end
end


local orig = GetQuestReward
GetQuestReward = function(...)
	SendAddonMessage("Quecho2", GetTitleText(), "PARTY")

	return orig(...)
end

