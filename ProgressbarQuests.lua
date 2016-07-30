
local myname, ns = ...


local function IsProgressive(questID)
	local _, _, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID)

	if not numObjectives then return end

	for i=1,numObjectives do
		local _, objectiveType = GetQuestObjectiveInfo(questID, i, false)
		if objectiveType == "progressbar" then return true end
	end

	return false
end


ns.ProgressbarQuests = setmetatable({}, {
	__index = function(t,i)
		local v = IsProgressive(i)
		t[i] = v
		return v
	end,
})
