
local myname, ns = ...


local WATCHFRAME_INITIAL_OFFSET = WATCHFRAME_INITIAL_OFFSET or 0
local WATCHFRAME_TYPE_OFFSET = WATCHFRAME_TYPE_OFFSET or 10


local f = CreateFrame("Frame", nil, UIParent)
f:SetWidth(1) f:SetHeight(1)
local lines = setmetatable({}, {__index = function(t, i)
	local fs = f:CreateFontString(nil, nil, "GameFontNormal")
	rawset(t, i, fs)
	return fs
end})


local current = 0
local function AddLine(text, maxwidth, lineFrame, nextAnchor, newline, numQuestWatches, r, g, b)
	current = current + 1
	local l = lines[current]
	l:SetText(text)
	l:SetTextColor(r or .75, g or .61, b or 0)
	if nextAnchor then
		local yOffset = newline and -WATCHFRAME_TYPE_OFFSET or 0
		l:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", 0, yOffset)
	else
		l:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET)
	end
	return math.max(maxwidth, l:GetStringWidth()), l, numQuestWatches + 1
end


local function AddQuests(lineFrame, nextAnchor, maxHeight, frameWidth)
	local maxWidth, numQuestWatches, lastLine = 0, 0

	current = 0
	for _,fs in ipairs(lines) do fs:SetText() end

	for sender,values in pairs(ns.quests) do
		if next(values) then
			maxWidth, lastLine, numQuestWatches = AddLine(sender, maxWidth, lineFrame, lastLine or nextAnchor, true, numQuestWatches)
			for i,v in pairs(values) do
				maxWidth, lastLine = AddLine("-  "..i..": "..v, maxWidth, lineFrame, lastLine, false, numQuestWatches, 0.7, 0.7, 0.9)
			end
		end
	end

	return lastLine or nextAnchor, maxWidth, numQuestWatches, 0
end

if ns.isWOD then
	local function GetAnchor()
		local block = BONUS_OBJECTIVE_TRACKER_MODULE.lastBlock
		if block and block:IsShown() then return block end

		block = AUTO_QUEST_POPUP_TRACKER_MODULE.lastBlock
		if block and block:IsShown() then return block end

		return QUEST_TRACKER_MODULE.lastBlock
	end


	function ns.Update()
		local anchor = GetAnchor()
		AddQuests(f)
		f:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
		f:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -10)
	end
else
	WatchFrame_AddObjectiveHandler(AddQuests)
end
