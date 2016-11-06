
local myname, ns = ...


local lines = {}
local parent = CreateFrame("Frame", nil, UIParent)
parent:SetSize(1, 1)


local function CreateLine()
	local line = parent:CreateFontString(nil, nil, "GameFontNormal")
	lines[line] = true
	return line
end


local function GetUnusedLine()
	for line in pairs(lines) do
		if not line:IsShown() then
			line:Show()
			return line
		end
	end
end


function ns.GetLine()
	return GetUnusedLine() or CreateLine()
end


function ns.HideLines()
	for line in pairs(lines) do line:Hide() end
end


local function GetAnchor()
	local block = BONUS_OBJECTIVE_TRACKER_MODULE.lastBlock
	if block and block:IsShown() then return block end

	block = AUTO_QUEST_POPUP_TRACKER_MODULE.lastBlock
	if block and block:IsShown() then return block end

	return QUEST_TRACKER_MODULE.lastBlock
end


function ns.AnchorLines(anchor)
	local anchor = GetAnchor()
	local yoffset = -1 * anchor.module.contentsHeight
	parent:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
	parent:SetPoint("RIGHT", anchor, "RIGHT", 0, -10)
end
