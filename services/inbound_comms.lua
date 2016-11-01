
local myname, ns = ...


local OBJECTIVE_PROGRESS = "([^:]+):? %(?([^)]+)%)?"
local MESSAGES = {
	[ns.COMM_TOKEN_ABANDON] = "_PARTY_ABANDON",
	[ns.COMM_TOKEN_ACCEPT]  = "_PARTY_ACCEPT",
	[ns.COMM_TOKEN_TURNIN]  = "_PARTY_TURNIN",
}


local player_name = UnitName("player").. "-".. GetRealmName():gsub(" ", "")
function OnAddonChatMsg(self, event, prefix, msg, channel, sender)
	if sender == player_name then return end

	if MESSAGES[prefix] then
		return ns.SendMessage(MESSAGES[prefix], sender, msg)
	end

	if prefix == ns.COMM_TOKEN_PROGRESS then
		local _, _, objective, progress = msg:find(OBJECTIVE_PROGRESS)
		ns.SendMessage("_PARTY_PROGRESS", sender, objective, progress)
	end
end


local function OnLoad()
	RegisterAddonMessagePrefix(ns.COMM_TOKEN_ABANDON)
	RegisterAddonMessagePrefix(ns.COMM_TOKEN_ACCEPT)
	RegisterAddonMessagePrefix(ns.COMM_TOKEN_PROGRESS)
	RegisterAddonMessagePrefix(ns.COMM_TOKEN_TURNIN)

	ns.RegisterCallback("CHAT_MSG_ADDON", OnAddonChatMsg)
end
ns.RegisterCallback("_THIS_ADDON_LOADED", OnLoad)
