
local myname, ns = ...


local C_Timer = _G.C_Timer

ns.StartRepeatingTimer = C_Timer.NewTicker

function ns.StartTimer(endtime, callback)
	local duration = endtime - GetTime()
	C_Timer.After(duration, callback)
end

function ns.StopRepeatingTimer(timer)
	timer:Cancel()
end
