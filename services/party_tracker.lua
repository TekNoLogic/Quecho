
local myname, ns = ...


local WATCHFRAME_INITIAL_OFFSET = WATCHFRAME_INITIAL_OFFSET or 0
local WATCHFRAME_TYPE_OFFSET = WATCHFRAME_TYPE_OFFSET or 10


local quests = ns.NewMemoizingTable(function() return {} end)


local function AddLine(text, anchor, header)
	local line = ns.GetLine()
	line:SetText(text)

	if header then
		line:SetTextColor(0.75, 0.61, 0)
	else
		line:SetTextColor(0.7, 0.7, 0.9)
	end

	if anchor then
		if header then
			line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -WATCHFRAME_TYPE_OFFSET)
		else
			line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
		end
	else
		line:SetPoint("TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET)
	end

	return line
end


local function Update()
	ns.HideLines()

	local anchor
	for sender,values in pairs(quests) do
		if next(values) then
			anchor = AddLine(sender, anchor, true)
			for i,v in pairs(values) do
				anchor = AddLine("-  "..i..": "..v, anchor, false)
			end
		end
	end

	ns.AnchorLines()
end


local function OnPartyExpire(self, message, sender, objective)
	quests[sender][objective] = nil
	Update()
end


function OnPartyProgress(self, message, sender, objective, progress)
	quests[sender][objective] = progress
	Update()
end


ns.RegisterCallback("_PARTY_EXPIRE", OnPartyExpire)
ns.RegisterCallback("_PARTY_PROGRESS", OnPartyProgress)
