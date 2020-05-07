function OnStatusApplied(target,status,source)
	local skill = LeaveActionData[status]
	if skill ~= nil then
		Ext.Print(status,skill,target)
		local turns = GetStatusTurns(target, status)
		if turns == 0 then
			LeaderLib.ExplodeProjectile(source, target, skill)
		else
			local handle = NRD_StatusGetHandle(target, status)
			Temp.StatusSource[handle] = source
		end
	end
end

function OnStatusRemoved(target,status)
	local skill = LeaveActionData[status]
	if skill ~= nil then
		Ext.Print(status,skill,target)
		local handle = NRD_StatusGetHandle(target, status)
		if handle ~= nil then
			local source = Temp.StatusSource[handle]
			if source ~= nil then
				LeaderLib.ExplodeProjectile(source, target, skill)
				Temp.StatusSource[handle] = nil
			end
		else
			Ext.Print("Handle for status ",status," on target ",target, "is nil")
		end
	end
end