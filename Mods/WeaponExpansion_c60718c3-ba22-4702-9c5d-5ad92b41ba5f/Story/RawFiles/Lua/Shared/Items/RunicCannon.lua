if Ext.IsServer() then
	function ArmCannon_SyncData(uuid)
		local energy = GetVarInteger(uuid, "LLWEAPONEX_ArmCannon_Energy")
		local item = Ext.GetItem(uuid)
		PersistentVars.SkillData.RunicCannonCharges[item.NetID] = energy
		Ext.BroadcastMessage("LLWEAPONEX_SyncArmCannonData", Ext.JsonStringify(PersistentVars.SkillData.RunicCannonCharges))
	end
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LLWEAPONEX_SyncArmCannonData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data ~= nil then
			local varTable = GameHelpers.Data.GetPersistentVars("WeaponExpansion", "SkillData", "RunicCannonCharges")
			varTable = data
			print("LLWEAPONEX_SyncArmCannonData", Common.Dump(PersistentVars.SkillData.RunicCannonCharges))
		end
	end)
end