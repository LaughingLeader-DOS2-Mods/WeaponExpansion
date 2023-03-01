---@param target EsvCharacter|EsvItem
local function _GetWeight(target)
	if GameHelpers.Ext.ObjectIsCharacter(target) then
		---@cast target EsvCharacter
		return target.Stats.DynamicStats[1].Weight
	else
		---@cast target EsvItem
		if target.StatsFromName then
			return target.StatsFromName.StatsEntry.Weight
		end
	end
	return 0
end

Config.Skill.Tossed = {
	StrengthToDistance = {
		[11] = 2,
		[12] = 2,
		[13] = 2,
		[14] = 3,
		[15] = 3,
		[16] = 3,
		[17] = 4,
		[18] = 4,
		[19] = 4,
		[20] = 4,
		[21] = 5,
		[22] = 5,
		[23] = 5,
		[24] = 5,
		[25] = 6,
		[26] = 6,
		[27] = 6,
		[28] = 7,
		[29] = 7,
		[30] = 7,
		[31] = 8,
		[32] = 8,
		[33] = 8,
		[34] = 9,
		[35] = 9,
		[36] = 10,
		[37] = 10,
		[38] = 10,
		[39] = 10,
	}
}

local function _GetTossDistance(strength)
	local min = GameHelpers.GetExtraData("AttributeBaseValue", 10)
	if strength <= min then
		return GameHelpers.GetExtraData("LLWEAPONEX_Toss_MinDistance", 1)
	end
	local softCap = GameHelpers.GetExtraData("AttributeSoftCap", 40)
	if strength >= softCap then
		return GameHelpers.GetExtraData("LLWEAPONEX_Toss_MaxDistance", 11)
	end
	return Config.Skill.Tossed.StrengthToDistance[strength] or 1
end

StatusManager.Subscribe.Applied("LLWEAPONEX_TOSSED", function (e)
	local weight = _GetWeight(e.Target)
	local strength = 0
	if GameHelpers.Ext.ObjectIsCharacter(e.Source) then
		strength = e.Source.Stats.Strength

		--Base Weight is 50,000, 1,000 weight == 1 weight unit in-game
		--20 STR == 200 max units == 200,000 max weight
		if weight <= 0
		or GlobalGetFlag("LLWEAPONEX_ThrowObjectLimitDisabled") == 1
		or strength >= GameHelpers.GetExtraData("AttributeSoftCap", 40)
		or Mastery.HasMasteryRequirement(e.Source, "LLWEAPONEX_ThrowingAbility_Mastery4", true)
		then
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_ThrowObject_Hit_01", e.Target.WorldPos)
			local distance = _GetTossDistance(strength)
			GameHelpers.Utils.ForceMoveObject(e.Target, {DistanceMultiplier=distance, ID="LLWEAPONEX_TOSSED", Source=e.Source, Skill="Target_LLWEAPONEX_ThrowObject", StartPos=e.Target.WorldPos})
		else
			CharacterStatusText(e.SourceGUID, "LLWEAPONEX_StatusText_ThrowObjectFailed")
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Status_ThrowObject_Failed_01", e.Target.WorldPos)
			--CharacterAddActionPoints(e.SourceGUID, 1)
		end
	end
end)

--[[
Default Weights
Book				500.0
Crate				10000.0
Steel Chest			10000.0
Chest				50000.0
Water Barrel		60000.0
DeathFog Barrel		95000.0
Strong Chest		100000.0
Metal Crate			150000.0
DeathFog Crate		200000.0
]]

Events.ForceMoveFinished:Subscribe(function (e)
	local weight = _GetWeight(e.Target)
	if weight > 0 then
		if weight >= GameHelpers.GetExtraData("CharacterWeightHeavy", 120000) then
			GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_Status_Tossed_Damage_Heavy", e.Source)
		elseif weight >= GameHelpers.GetExtraData("CharacterWeightMedium", 70000) then
			GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_Status_Tossed_Damage_Medium", e.Source)
		elseif weight >= GameHelpers.GetExtraData("CharacterWeightLight", 40000) then
			GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_Status_Tossed_Damage_Light", e.Source)
		else
			GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_Status_Tossed_Damage_SuperLight", e.Source)
		end
	end
end, {MatchArgs={ID="LLWEAPONEX_TOSSED"}})