local myname, Quecho = ...


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
	if nextAnchor then l:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", 0, newline and -WATCHFRAME_TYPE_OFFSET or 0)
	else l:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET) end
	return math.max(maxwidth, l:GetStringWidth()), l, numQuestWatches + 1
end


WatchFrame_AddObjectiveHandler(function(lineFrame, nextAnchor, maxHeight, frameWidth)
	local maxWidth, numQuestWatches, lastLine = 0, 0

	current = 0
	for _,fs in ipairs(lines) do fs:SetText() end

	for sender,values in pairs(Quecho.quests) do
		if next(values)then
			maxWidth, lastLine, numQuestWatches = AddLine(sender, maxWidth, lineFrame, lastLine or nextAnchor, true, numQuestWatches)
			for i,v in pairs(values) do maxWidth, lastLine = AddLine(" - "..i..": "..v, maxWidth, lineFrame, lastLine, false, numQuestWatches, 0.8, 0.8, 0.8) end
		end
	end

	return lastLine or nextAnchor, maxWidth, numQuestWatches, 0
end)
