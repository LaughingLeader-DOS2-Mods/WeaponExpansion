function TagWeapon(uuid)
	---@type EsvItem
	local item = Ext.GetItem(uuid)
	if item.ItemType == "Weapon" then
		local tag = WeaponTypeToTag[item.Stats.WeaponType]
		if tag ~= nil then
			SetTag(uuid, tag)
			LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with ("..tag..").")
		end
	elseif item.ItemType == "Shield" then
		SetTag(uuid, "LLWEAPONEX_Shield")
		LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with (LLWEAPONEX_Shield).")
	end
end