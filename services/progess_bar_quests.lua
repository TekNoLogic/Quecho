
local myname, ns = ...


local quests = {}


local function AddQuest(self, message, quest_id)
	if not ns.ProgressbarQuests[quest_id] then return end

	quests[quest_id] = GetQuestObjectiveInfo(quest_id, 1, false)
end


local function OnLoad()
	for i=1,GetNumQuestLogEntries() do
		local _, _, _, _, _, _, _, quest_id = GetQuestLogTitle(i)
		if quest_id then AddQuest(nil, nil, quest_id) end
	end
end


local function OnQuestTurnedIn(self, message, quest_id)
	if not quests[id] then return end

	ns.SendMessage("_QUEST_PROGRESS", quests[id].. ": 100%")
	quests[id] = nil
end


local PROGRESS = "%s: %.1f%%"
local function GetProgressMessage(quest_id, name)
	local name = quests[quest_id]
	local percent = GetQuestProgressBarPercent(quest_id)
	return PROGRESS:format(name, percent)
end


local function OnQuestLogUpdate()
	for quest_id in pairs(quests) do
		ns.SendMessage("_QUEST_PROGRESS", GetProgressMessage(quest_id))
	end
end


ns.RegisterCallback("_QUEST_ACCEPTED", AddQuest)
ns.RegisterCallback("_QUEST_TURNED_IN", OnQuestTurnedIn)
ns.RegisterCallback("_QUEST_LOG_UPDATE", OnQuestLogUpdate)
ns.RegisterCallback("_THIS_ADDON_LOADED", OnLoad)
