if MasterySystem == nil then
	MasterySystem = {}
end

function Mastery.CanGrantXP(uuid)
	if IsTagged(uuid, "LLDUMMY_TrainingDummy") == 1 then
		return true
	end
	if ObjectIsCharacter(uuid) == 0 then
		return false
	end
	if NRD_CharacterGetInt(uuid, "Resurrected") == 0
	and not IsPlayer(uuid)
	and CharacterIsSummon(uuid) == 0
	and CharacterIsPartyFollower(uuid) == 0
	and Osi.LeaderLib_Helper_QRY_IgnoreCharacter(uuid) ~= true
	and CharacterIsInCombat(uuid) == 1
	and GameHelpers.Character.IsEnemyOfParty(uuid)
	then
		return true
	end
	return false
end

function MasterySystem.GrantDeathExperienceToParty(enemy)
	local bossMult = IsBoss(enemy) == 1 and 2.0 or 1.0
	local mult = Ext.ExtraData.LLWEAPONEX_Mastery_DeathExperienceMult or 1.0
	local expGain = mult * bossMult
	for i,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
		AddMasteryExperienceForAllActive(StringHelpers.GetUUID(db[1]), expGain)
	end
end

--Mods.WeaponExpansion.AddMasteryExperienceForAllActive(Mods.WeaponExpansion.Origin.Harken, 20.0)
function MasterySystem.GrantBasicAttackExperience(player, enemy, mastery)
	if IsTagged(enemy, "LLDUMMY_TrainingDummy") == 1 then
		local expGain = Ext.ExtraData.LLWEAPONEX_Mastery_TrainingDummyExperienceMult or 0.1
		if mastery then
			AddMasteryExperience(player, mastery, expGain)
		else
			AddMasteryExperienceForAllActive(player, expGain)
		end
	elseif Mastery.CanGrantXP(enemy) then
		local expGain = Ext.ExtraData.LLWEAPONEX_Mastery_BasicAttackExperienceMult or 0.5
		if mastery then
			AddMasteryExperience(player, mastery, expGain)
		else
			AddMasteryExperienceForAllActive(player, expGain)
		end
	end
end

function MasterySystem.GrantWeaponSkillExperience(player, enemy, mastery)
	if Mastery.CanGrantXP(enemy) then
		local expGain = Ext.ExtraData.LLWEAPONEX_Mastery_WeaponSkillExperienceMult or 0.5
		if IsTagged(enemy, "LLDUMMY_TrainingDummy") == 1 then
			expGain = Ext.ExtraData.LLWEAPONEX_Mastery_TrainingDummyExperienceMult or 0.1
		end
		if mastery == nil then
			AddMasteryExperienceForAllActive(player, expGain)
		else
			AddMasteryExperience(player, mastery, expGain)
		end
	end
end

RegisterProtectedOsirisListener("CharacterPrecogDying", 1, "after", function(enemy)
	if Mastery.CanGrantXP(enemy) then
		MasterySystem.GrantDeathExperienceToParty(enemy)
	end
end)