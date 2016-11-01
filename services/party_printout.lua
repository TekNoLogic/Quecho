
local myname, ns = ...


local FORMATS = {
	_PARTY_ABANDON = "%s abandoned %s",
	_PARTY_ACCEPT = "%s accepted %s",
	_PARTY_TURNIN = "%s turned in %s",
}


function OnPartyAction(self, message, sender, msg)
	ns.Printf(FORMATS[message], sender, msg)
end


ns.RegisterCallback("_PARTY_ABANDON", OnPartyAction)
ns.RegisterCallback("_PARTY_ACCEPT", OnPartyAction)
ns.RegisterCallback("_PARTY_TURNIN", OnPartyAction)
