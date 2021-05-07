local function TagFromStats(uuid, stat)
	local tagged = false
	for statWord,tag in pairs(Tags.StatWordToTag) do
		if string.find(stat, statWord) then
			SetTag(uuid, tag)
			--PrintDebug("[WeaponExpansion:TagFromStats] Tagged ("..uuid..")["..stat.."] with ("..tag..").")
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

	-- Has mastery tag but is missing LLWEAPONEX_TaggedWeaponType
	for tag,data in pairs(Masteries) do
		if IsTagged(uuid, tag) == 1 then
			SetTag(uuid, "LLWEAPONEX_TaggedWeaponType")
			return true
		end
	end

	local template = StringHelpers.GetUUID(GetTemplate(uuid))
	local templateTag = Tags.TemplateToTag[template]
	PrintDebug("TagWeapon", uuid, statType, stat, template, templateTag)
	if templateTag ~= nil then
		if type(templateTag) == "table" then
			for i,tag in pairs(templateTag) do
				SetTag(uuid, templateTag)
				PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..template.."] with ("..templateTag..").")
			end
		else
			SetTag(uuid, templateTag)
			PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..template.."] with ("..templateTag..").")
		end
		tagged = true
	else
		if StringHelpers.IsNullOrEmpty(statType) or StringHelpers.IsNullOrEmpty(stat) then
			---@type EsvItem
			local item = Ext.GetItem(uuid)
			if not TagFromStats(uuid, item.StatsId) then
				if item.ItemType == "Weapon" then
					local tag = Tags.WeaponTypeToTag[item.Stats.WeaponType]
					if tag ~= nil then
						SetTag(uuid, tag)
						PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with ("..tag..").")
						tagged = true
					end
				elseif item.ItemType == "Shield" then
					SetTag(uuid, "LLWEAPONEX_Shield")
					PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..item.StatsId.."] with (LLWEAPONEX_Shield).")
					tagged = true
				end
			else
				tagged = true
			end
		elseif not StringHelpers.IsNullOrEmpty(stat) then
			if not TagFromStats(uuid, stat) then
				if statType == "Weapon" then
					local tag = Tags.WeaponTypeToTag[Ext.StatGetAttribute(stat, "WeaponType")]
					if tag ~= nil then
						SetTag(uuid, tag)
						PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..stat.."] with ("..tag..").")
						tagged = true
					end
				elseif statType == "Shield" then
					SetTag(uuid, "LLWEAPONEX_Shield")
					PrintDebug("[WeaponExpansion:TagWeapon] Tagged ("..uuid..")["..stat.."] with (LLWEAPONEX_Shield).")
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