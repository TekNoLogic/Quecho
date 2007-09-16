

local f = CreateFrame("Frame", nil, UIParent)
f:SetHeight(1)
f:SetPoint("TOPRIGHT", QuestWatchFrame, "TOPLEFT", -10, -13)
local lines = setmetatable({}, {__index = function(t, i)
	local fs = f:CreateFontString(nil, nil, "GameFontNormal")
	if i == 1 then fs:SetPoint("TOPLEFT") else fs:SetPoint("TOPLEFT", t[i-1], "BOTTOMLEFT") end
	rawset(t, i, fs)
	return fs
end})


local current = 0
local function AddLine(text, r, g, b)
	current = current + 1
	lines[current]:SetText(text)
	lines[current]:SetTextColor(r or .75, g or .61, b or 0)
	local w = lines[current]:GetStringWidth()
	if f:GetWidth() < w then f:SetWidth(w) end
end


function Quecho:UpdateTracker()
	current = 0
	for _,fs in ipairs(lines) do fs:SetText() end
	f:SetWidth(0)

	for sender,values in pairs(self.quests) do
		if next(values)then
			AddLine(sender)
			for i,v in pairs(values) do AddLine(" - "..i..": "..v, 0.8, 0.8, 0.8) end
		end
	end
end


local orig = QuestWatchFrame.Hide
local function posthook(frame, ...) frame:SetWidth(1); return ... end
QuestWatchFrame.Hide = function(frame, ...) return posthook(frame, orig(frame, ...)) end

if GetNumQuestWatches() == 0 then QuestWatchFrame:SetWidth(1) end