local function TagFromStats(uuid, stat)
	local tagged = false
	for statWord,tag in pairs(Tags.StatWordToTag) do
		if string.find(stat, statWord) then
			SetTag(uuid, tag)
			--LeaderLib.PrintDebug("[WeaponExpansion:TagFromStats] Tagged ("..uuid..")["..stat.."] with ("..tag..").")
			tagged = true
		end
	end
	return tagged
end

---@param uuid string An ITEMGUID to tag.
---@param statType string The item's stat type. Optional.
---@param stat string The item's stat. Optional.
function TagWeapon(uuid, statType, stat)
	local tagged = false
	local template = GetTemplate(uuid)
	local templateTag = Tags.TemplateToTag[template]
	if templateTag ~= nil then
		if type(templateTag) == "table" then
			for i,tag in pairs(templateTag) do
				SetTag(uuid, templateTag)
				--LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..template.."] with ("..templateTag..").")
			end
		else
			SetTag(uuid, templateTag)
			--LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..template.."] with ("..templateTag..").")
		end
		tagged = true
	else
		if statType == nil or stat == nil then
			---@type EsvItem
			local item = Ext.GetItem(uuid)
			if not TagFromStats(uuid, item.StatsId) then
				if item.ItemType == "Weapon" then
					local tag = Tags.WeaponTypeToTag[item.Stats.WeaponType]
					if tag ~= nil then
						SetTag(uuid, tag)
						--LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with ("..tag..").")
						tagged = true
					end
				elseif item.ItemType == "Shield" then
					SetTag(uuid, "LLWEAPONEX_Shield")
					--LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with (LLWEAPONEX_Shield).")
					tagged = true
				end
			else
				tagged = true
			end
		else
			if not TagFromStats(uuid, stat) then
				if statType == "Weapon" then
					local tag = Tags.WeaponTypeToTag[Ext.StatGetAttribute(stat, "WeaponType")]
					if tag ~= nil then
						SetTag(uuid, tag)
						--LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..stat.."] with ("..tag..").")
						tagged = true
					end
				elseif statType == "Shield" then
					SetTag(uuid, "LLWEAPONEX_Shield")
					--LeaderLib.PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..stat.."] with (LLWEAPONEX_Shield).")
					tagged = true
				end
			else
				tagged = true
			end
		end
	end
	if tagged then
		SetTag(uuid, "LLWEAPONEX_TaggedWeaponType")
	end
end