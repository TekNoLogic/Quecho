
local myname, ns = ...


local COMPLETE = "(.+) %(Complete%)"
local PROGRESS = "(.+): (%d+/%d+)"


local function OnUIInfoMessage(self, event, msgtype, msg)
	if not msg then return end
	if not (msg:find(COMPLETE) or msg:find(PROGRESS)) then return end

	ns.SendMessage("_QUEST_PROGRESS", msg)
end

ns.RegisterCallback("UI_INFO_MESSAGE", OnUIInfoMessage)
