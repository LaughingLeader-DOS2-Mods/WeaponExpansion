if MasterySystem == nil then
	MasterySystem = {}
end

---@param uuid CharacterParam
---@return boolean
function MasterySystem.CanGrantXP(uuid)
	uuid = GameHelpers.GetUUID(uuid)
	if not uuid then
		return false
	end
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
	local mult = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_DeathExperienceMult", 1.0)
	local expGain = mult * bossMult
	for player in GameHelpers.Character.GetPlayers() do
		if MasterySystem.CanGainExperience(player) then
			AddMasteryExperienceForAllActive(player, expGain)
		end
	end
end

---@param character CharacterParam
---@return boolean
function MasterySystem.CanGainExperience(character)
	if character then
		return (GameHelpers.Character.IsPlayer(character) and GameHelpers.DB.HasUUID("DB_IsPlayer", character))
	end
	return false
end

--Mods.WeaponExpansion.AddMasteryExperienceForAllActive(Mods.WeaponExpansion.Origin.Harken, 20.0)
function MasterySystem.GrantBasicAttackExperience(player, enemy, mastery)
	if IsTagged(enemy, "LLDUMMY_TrainingDummy") == 1 then
		local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_TrainingDummyExperienceMult", 0.1)
		if mastery then
			AddMasteryExperience(player, mastery, expGain)
		else
			AddMasteryExperienceForAllActive(player, expGain)
		end
	elseif MasterySystem.CanGrantXP(enemy) then
		local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_BasicAttackExperienceMult", 0.5)
		if mastery then
			AddMasteryExperience(player, mastery, expGain)
		else
			AddMasteryExperienceForAllActive(player, expGain)
		end
	end
end

function MasterySystem.GrantWeaponSkillExperience(player, enemy, mastery)
	if MasterySystem.CanGrantXP(enemy) then
		local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_WeaponSkillExperienceMult", 0.5)
		if IsTagged(enemy, "LLDUMMY_TrainingDummy") == 1 then
			expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_TrainingDummyExperienceMult", 0.1)
		end
		if mastery == nil then
			AddMasteryExperienceForAllActive(player, expGain)
		else
			AddMasteryExperience(player, mastery, expGain)
		end
	end
end

RegisterProtectedOsirisListener("CharacterPrecogDying", 1, "after", function(enemy)
	if MasterySystem.CanGrantXP(enemy) then
		MasterySystem.GrantDeathExperienceToParty(enemy)
	end
end)

local UnarmedSkills = {
	"Target_SingleHandedAttack",
	"Target_LLWEAPONEX_SinglehandedAttack",
	"Target_PetrifyingTouch",
}

SkillManager.Register.Hit(UnarmedSkills, function(e)
	if e.Data.Success and MasterySystem.CanGainExperience(e.Character) then
		MasterySystem.GrantWeaponSkillExperience(e.Character, e.Data.Target, "LLWEAPONEX_Unarmed")
	end
end)

function GainThrowingMasteryXP(uuid, target)
	if MasterySystem.CanGainExperience(uuid) then
		MasterySystem.GrantWeaponSkillExperience(uuid, target, "LLWEAPONEX_ThrowingAbility")
	end
end