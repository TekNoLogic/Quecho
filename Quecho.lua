
------------------------------
--      Are you local?      --
------------------------------

local tablet = AceLibrary("Tablet-2.0")
local myname = UnitName("player")
local quests, lastsend, sendtimes, delayedval = {}, {}, {}

local partychat = false


-------------------------------------
--      Namespace Declaration      --
-------------------------------------

Quecho = DongleStub("Dongle-Beta0"):New("Quecho")


---------------------------
--      Ace Methods      --
---------------------------

function Quecho:Enable()
	self:RegisterEvent("UI_INFO_MESSAGE")
	self:RegisterEvent("CHAT_MSG_ADDON")
end


-----------------------------
--      FuBar Methods      --
-----------------------------

function Quecho:OnTooltipUpdate()
	for sender,quests in pairs(quests) do
		local cat = tablet:AddCategory("text", sender)
		for idx,items in pairs(quests) do
			cat:AddLine("text", idx)
			for _,item in ipairs(items) do
				cat:AddLine("text", item)
			end
		end
	end
end


------------------------------
--      Event Handlers      --
------------------------------

function Quecho:UI_INFO_MESSAGE(msg)
--~ 	if not msg or GetNumPartyMembers() == 0 then return end
	if not msg then return end

	local subtxt = gsub(msg, "(.*): %d+%s*/%s*%d+","%1", 1)
	if subtxt == msg then return end

	SendAddonMessage("Quecho", msg, "PARTY")
	if partychat then SendChatMessage(msg, "PARTY") end
end


function Quecho:CHAT_MSG_ADDON(prefix, msg, channel, sender)
	if prefix ~= "Quecho" then return end
--~~ 	if sender == myname then return end
	self:Debug(1, sender, msg)
	self:Print(sender, msg)

--~ 	sendtimes[sender..msg] = GetTime()
--~ 	self:ScheduleEvent("Quecho_CheckTimes", 302)
--~ 	lastsend[sender] = msg
--~ 	if not quests[sender] then quests[sender] = {} end
--~ 	if not quests[sender][msg] then quests[sender][msg] = {}
--~ 	else
--~ 		for i in pairs(quests[sender][msg]) do quests[sender][msg][i] = nil end
--~ 		quests[sender][msg].reset = 1
--~ 		quests[sender][msg].reset = nil
--~ 		table.setn(quests[sender][msg], 0)
--~ 	end

--~ 	self:Update()
end


function Quecho:Quecho_CheckTimes()
	local changed

	for sender,quests in pairs(quests) do
		for quest in pairs(quests) do
			if sendtimes[sender..quest] < (GetTime() - 300) then
				quests[sender][quest] = nil
				sendtimes[sender..quest] = nil
				changed = true
			end
		end
	end

	if changed then self:Update() end
end

