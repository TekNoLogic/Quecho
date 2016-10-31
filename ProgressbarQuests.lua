
local myname, ns = ...


local function IsProgressive(quest_id)
	local _, _, num_objectives = GetTaskInfo(quest_id)
	if not num_objectives then return end

	for i=1,num_objectives do
		local _, objective_type = GetQuestObjectiveInfo(quest_id, i, false)
		if objective_type == "progressbar" then return true end
	end

	return false
end


ns.ProgressbarQuests = ns.NewMemoizingTable(IsProgressive)
