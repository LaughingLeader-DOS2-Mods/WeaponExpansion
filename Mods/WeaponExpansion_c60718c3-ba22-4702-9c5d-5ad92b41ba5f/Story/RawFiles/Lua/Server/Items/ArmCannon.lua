function ArmCannon_SyncData(item)
	local energy = GetVarInteger(item, "LLWEAPONEX_ArmCannon_Energy")
	PersistentVars.SkillData.RunicCannonCharges[item] = energy
	SyncVars()
end