
local myname, ns = ...


local function GetQuestInfo(index)
	local title, _, _, is_header, _, _, _, quest_id = GetQuestLogTitle(i)
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

function ns.ScanLog(quests)
	for i=1,GetNumQuestLogEntries() do
		local quest_id, detail = GetQuestInfo(i)
		if quest_id then quests[quest_id] = detail end
	end

	return quests
end
