EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
	if e.Equipped then
		--This handles adding the secondary rune activation skill, for situations where the character is dual-wielding the same runeblade type
		if not e.AllTags.LLWEAPONEX_Runeblade_CustomRuneSkill then
			local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(e.Character)
			for tag,skills in pairs(Config.Runeblades.TagToSkill) do
				if e.AllTags[tag] then
					--local hasMainhandSkill = e.Character.SkillManager.Skills[skills.Mainhand]
					local hasOffhandSkill = e.Character.SkillManager.Skills[skills.Offhand]
					if GameHelpers.ItemHasTag(offhand, tag) and GameHelpers.ItemHasTag(mainhand, tag) and not hasOffhandSkill then
						CharacterAddSkill(e.CharacterGUID, skills.Offhand, 0)
					end
				end
			end
		end
	else
		for tag,skills in pairs(Config.Runeblades.TagToSkill) do
			if e.Character.SkillManager.Skills[skills.Offhand] then
				CharacterRemoveSkill(e.CharacterGUID, skills.Offhand)
			end
		end
	end
end, {MatchArgs={Tag="LLWEAPONEX_Runeblade"}})