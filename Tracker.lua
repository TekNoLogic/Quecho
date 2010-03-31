
local myname, Quecho = ...


local f = CreateFrame("Frame", nil, UIParent)
f:SetWidth(1) f:SetHeight(1)
local lines = setmetatable({}, {__index = function(t, i)
	local fs = f:CreateFontString(nil, nil, "GameFontNormal")
	if i == 1 then fs:SetPoint("TOPLEFT") else fs:SetPoint("TOPLEFT", t[i-1], "BOTTOMLEFT") end
	rawset(t, i, fs)
	return fs
end})


local current = 0
local function AddLine(text, maxwidth, heightUsed, numQuestWatches, r, g, b)
	current = current + 1
	local l = lines[current]
	l:SetText(text)
	l:SetTextColor(r or .75, g or .61, b or 0)
	return math.max(maxwidth, l:GetStringWidth()), heightUsed + l:GetHeight(), numQuestWatches + 1
end


WatchFrame_AddObjectiveHandler(function(lineFrame, initialOffset, maxHeight, frameWidth)
	local maxWidth, heightUsed, numQuestWatches = 0, 0, 0

	f:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset - WATCHFRAME_QUEST_OFFSET)

	current = 0
	for _,fs in ipairs(lines) do fs:SetText() end

	for sender,values in pairs(Quecho.quests) do
		if next(values)then
			maxWidth, heightUsed, numQuestWatches = AddLine(sender, maxWidth, heightUsed, numQuestWatches)
			for i,v in pairs(values) do maxWidth, heightUsed = AddLine(" - "..i..": "..v, maxWidth, heightUsed, numQuestWatches, 0.8, 0.8, 0.8) end
		end
	end

	return heightUsed, maxWidth, numQuestWatches
end)
