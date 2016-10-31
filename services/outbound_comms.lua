
local myname, ns = ...


local function OnQuestAbandoned(self, message, id, link)
	SendAddonMessage(ns.COMM_TOKEN_ABANDON, link, "PARTY")
end


local function OnQuestAccepted(self, message, id, link)
	SendAddonMessage(ns.COMM_TOKEN_ACCEPT, link, "PARTY")
end


local function OnQuestProgress(self, message, text)
	SendAddonMessage(ns.COMM_TOKEN_PROGRESS, text, "PARTY")
end


local function OnQuestTurnedIn(self, message, id, link)
	SendAddonMessage(ns.COMM_TOKEN_TURNIN, link, "PARTY")
end


ns.RegisterCallback("_QUEST_ABANDONED", OnQuestAbandoned)
ns.RegisterCallback("_QUEST_ACCEPTED", OnQuestAccepted)
ns.RegisterCallback("_QUEST_PROGRESS", OnQuestProgress)
ns.RegisterCallback("_QUEST_TURNED_IN", OnQuestTurnedIn)
