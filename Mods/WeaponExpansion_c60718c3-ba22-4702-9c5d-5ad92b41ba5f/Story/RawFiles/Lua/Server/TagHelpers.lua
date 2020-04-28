
---@param uuid string An ITEMGUID to tag.
---@param statType string The item's stat type. Optional.
---@param stat string The item's stat. Optional.
function TagWeapon(uuid, statType, stat)
	if statType == nil or stat == nil then
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
	else
		if statType == "Weapon" then
			local tag = WeaponTypeToTag[Ext.StatGetAttribute(stat, "WeaponType")]
			if tag ~= nil then
				SetTag(uuid, tag)
				LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with ("..tag..").")
			end
		elseif statType == "Shield" then
			SetTag(uuid, "LLWEAPONEX_Shield")
			LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with (LLWEAPONEX_Shield).")
		end
	end
end