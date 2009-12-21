
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
local function AddLine(text, maxwidth, heightUsed, r, g, b)
	current = current + 1
	local l = lines[current]
	l:SetText(text)
	l:SetTextColor(r or .75, g or .61, b or 0)
	return math.max(maxwidth, l:GetStringWidth()), heightUsed + l:GetHeight()
end


WatchFrame_AddObjectiveHandler(function(lineFrame, initialOffset, maxHeight, frameWidth)
	local maxWidth = 0
	local heightUsed = 0

	f:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset - WATCHFRAME_QUEST_OFFSET)

	current = 0
	for _,fs in ipairs(lines) do fs:SetText() end

	for sender,values in pairs(Quecho.quests) do
		if next(values)then
			maxWidth, heightUsed = AddLine(sender, maxWidth, heightUsed)
			for i,v in pairs(values) do maxWidth, heightUsed = AddLine(" - "..i..": "..v, maxWidth, heightUsed, 0.8, 0.8, 0.8) end
		end
	end

	return heightUsed, maxWidth
end)
