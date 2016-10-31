
local myname, ns = ...


local abandon_in_progress


local function Diff(current, previous)
	-- If we don't have full data, don't do anything
	if not next(current) or not next(previous) then return end

	for id,link in pairs(previous) do
		if not current[id] then
			if abandon_in_progress then
				ns.SendMessage("_QUEST_ABANDONED", id, link)
			else
				ns.SendMessage("_QUEST_TURNED_IN", id, link)
			end
		end
	end

	for id,link in pairs(current) do
		if not previous[id] then
			ns.SendMessage("_QUEST_ACCEPTED", id, link)
		end
	end
end


local function GetQuestInfo(index)
	local title, _, _, is_header, _, _, _, quest_id = GetQuestLogTitle(index)
	if is_header then return end

	assert(quest_id, "No quest ID found for item at index ".. index)

	local link = GetQuestLink(quest_id)

	if link then
		ns.Debug(quest_id, link)
		return quest_id, link
	else
		ns.Debug("No link", quest_id, title)
		return quest_id, title
	end
end


local function ScanLog(quests)
	for i=1,GetNumQuestLogEntries() do
		local quest_id, detail = GetQuestInfo(i)
		if quest_id then quests[quest_id] = detail end
	end
end


local currentquests, oldquests = {}, {}
local function OnQuestLogUpdate()
	-- Don't swap if we don't have any data in the last scan
	if next(currentquests) then
		currentquests, oldquests = oldquests, currentquests
		wipe(currentquests)
	else
		print("Skipping swap")
	end

	ScanLog(currentquests)

	if not next(currentquests) then print("Empty scan, wtf?") end

	Diff(currentquests, oldquests)

	abandon_in_progress = nil
end


local orig = AbandonQuest
function AbandonQuest(...)
	abandon_in_progress = true
	return orig(...)
end


local function OnLoad()
	ScanLog(currentquests)
	ns.RegisterCallback("_QUEST_LOG_UPDATE", OnQuestLogUpdate)
end
ns.RegisterCallback("_THIS_ADDON_LOADED", OnLoad)
