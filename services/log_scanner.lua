
local myname, ns = ...


function ns.Diff(current, previous, abandon_in_progress)
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


function ns.ScanLog(quests)
	for i=1,GetNumQuestLogEntries() do
		local quest_id, detail = GetQuestInfo(i)
		if quest_id then quests[quest_id] = detail end
	end

	return quests
end
