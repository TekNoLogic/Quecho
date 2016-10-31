
local myname, ns = ...


-- The quest log does wierd shit while the player is dematerialized, so this
-- provides an addon message that we know will fire only when the player exists


local function OnQuestLogUpdate(self, event, ...)
	ns.SendMessage("_QUEST_LOG_UPDATE", ...)
end


local function OnPlayerEnteringWorld(self)
	ns.RegisterCallback(self, "QUEST_LOG_UPDATE", OnQuestLogUpdate)
end


local function OnPlayerLeavingWorld(self)
	ns.UnregisterCallback(self, "QUEST_LOG_UPDATE")
end


local function OnLoad(self)
	ns.RegisterCallback(self, "QUEST_LOG_UPDATE", OnQuestLogUpdate)
	ns.RegisterCallback(self, "PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
	ns.RegisterCallback(self, "PLAYER_LEAVING_WORLD", OnPlayerLeavingWorld)

	ns.SendMessage("_QUEST_LOG_UPDATE")
end


ns.RegisterCallback({}, "_THIS_ADDON_LOADED", OnLoad)
