
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
	local best_bottom = math.huge
	local best_anchor
	for i,module in pairs(ObjectiveTrackerFrame.MODULES) do
		local block = module.lastBlock
		local bottom = block and block:IsVisible() and block:GetBottom()
		if bottom and bottom < best_bottom then
			best_anchor, best_bottom = block, bottom
		end
	end
	return best_anchor
end


function ns.AnchorLines(anchor)
	local anchor = GetAnchor()
	parent:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
	parent:SetPoint("RIGHT", anchor, "RIGHT", 0, -10)
end
