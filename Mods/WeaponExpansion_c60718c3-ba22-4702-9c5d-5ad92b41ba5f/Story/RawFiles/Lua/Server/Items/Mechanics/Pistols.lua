Config.Skill.Pistols = {
	AllShootSkills = {
		"Projectile_LLWEAPONEX_Pistol_Shoot",
		"Projectile_LLWEAPONEX_Pistol_Shoot_Enemy",
	},
	RaceToProjectileBone = {
		Dwarf = "Dummy_L_HandFX",
		Human = "Dummy_L_HandFX",
		Elf = "Dummy_R_HandFX",
		Lizard = "Dummy_R_HandFX",
	},
	PistolEffects = {
		Dwarf = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
		},
		Elf = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
		},
		Human = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT",
		},
		Lizard = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
		},
	},
	EffectRemoveDelay = {
		Dwarf = 600,
		Human = 400,
		Elf = 250,
		Lizard = 800,
	},
	PlaySheathe = {
		Dwarf = true,
		Elf = true
	}
}

---@param character EsvCharacter
local function _GetPistolExplosionEffect(character)
	local race = GameHelpers.Character.GetBaseRace(character)
	local isFemale = GameHelpers.Character.IsFemale(character) and 1 or 0
	local raceData = Config.Skill.Pistols.PistolEffects[race]
	if raceData then
		local effect = raceData[isFemale]
		return effect
	end
	return "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT"
end

---@param character EsvCharacter
local function _GetPistolRemoveDelay(character)
	local race = GameHelpers.Character.GetBaseRace(character)
	local delay = Config.Skill.Pistols.EffectRemoveDelay[race]
	if delay then
		return delay
	end
	return 150
end

---@param character EsvCharacter
local function _ShouldPlaySheatheAnimation(character)
	local race = GameHelpers.Character.GetBaseRace(character)
	return Config.Skill.Pistols.PlaySheathe[race] == true
end

--Prioritized last, in case other mods add to this table
Ext.Events.SessionLoaded:Subscribe(function ()
	-- SkillManager.Register.BeforeProjectileShoot(Config.Skill.Pistols.AllShootSkills, function (e)
	-- 	--local target = GameHelpers.TryGetObject(e.Data.Target)
	-- 	if not GameHelpers.IsValidHandle(e.Data.Target) then
	-- 		local skillRange = Ext.Stats.GetAttribute(e.Skill, "TargetRadius")
	-- 		local targetPos = e.Data.EndPosition
	-- 		targetPos[2] = targetPos[2] + 2.0
	-- 		local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_Pistol_MaxBonusDistance", 12.0)
	-- 		local currentDist = GameHelpers.Math.GetDistance(e.Character.WorldPos, targetPos)
	-- 		--If targeting the ground near the edge of the skill range, extend the end target position
	-- 		if currentDist < skillRange - 1.0 then
	-- 			local dist = maxDistance - skillRange
	-- 			if dist > 0 then
	-- 				e.Data.IgnoreObjects = false
	-- 				targetPos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, dist, targetPos[1], targetPos[2], targetPos[3])
	-- 				e.Data.EndPosition = targetPos
	-- 			end
	-- 		end
	-- 	end
	-- end)

	SkillManager.Register.ProjectileShoot(Config.Skill.Pistols.AllShootSkills, function (e)
		local race = GameHelpers.Character.GetBaseRace(e.Character)
		local bone = Config.Skill.Pistols.RaceToProjectileBone[race]
		if bone then
			e.Data.RootTemplate.CastBone = bone
		end

		local status = _GetPistolExplosionEffect(e.Character)
		if status then
			GameHelpers.Status.Apply(e.Character, status, 0.0, false, e.Character)
		end
	end)

	SkillManager.Register.Hit(Config.Skill.Pistols.AllShootSkills, function(e)
		--PISTOL_CLOAKEDJUMP
		if e.Data.TargetObject and e.Data.TargetObject:HasTag("LLWEAPONEX_Pistol_MarkedForCrit") then
			if not e.Data:HasHitFlag("CriticalHit", true) then
				local critPerPoint = GameHelpers.GetExtraData("SkillAbilityCritMultiplierPerPoint", 5)
				local attackerStats = e.Character.Stats
				local critMult = (attackerStats.RogueLore * critPerPoint) * 0.01
				e.Data:SetHitFlag("CriticalHit", true)
				e.Data:MultiplyDamage(1 + critMult)
			end
			e.Data:SetHitFlag("Hit", true)
			e.Data:SetHitFlag("Dodged", false)
			e.Data:SetHitFlag("Missed", false)
			e.Data:SetHitFlag("Blocked", false)
			ClearTag(e.Data.Target, "LLWEAPONEX_Pistol_MarkedForCrit")
			CharacterStatusText(e.Data.Target, "LLWEAPONEX_StatusText_Pistol_MarkedCrit")
		end
		if e.Data.Success then
			-- Silver bullets do bonus damage to undead/voidwoken
			if TagHelpers.IsUndeadOrVoidwoken(e.Data.Target) then
				if Skills.HasTaggedRuneBoost(e.Character.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_Pistols") then
					local bonus = GameHelpers.GetExtraData("LLWEAPONEX_Pistol_SilverBonusDamage", 1.5)
					if bonus > 0 then
						e.Data:MultiplyDamage(bonus, true)
					end
				end
			end

			--PISTOL_ADRENALINE
			if e.Character:HasTag("LLWEAPONEX_Pistol_Adrenaline_Active") then
				ClearTag(e.Character.MyGuid, "LLWEAPONEX_Pistol_Adrenaline_Active")
				local damageBoost = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_Adrenaline_DamageBoost", 50.0) * 0.01
				if damageBoost > 0 then
					e.Data:MultiplyDamage(1 + damageBoost)
					CharacterStatusText(e.Character.MyGuid, "LLWEAPONEX_StatusText_Pistol_AdrenalineBoost")
				end
			end
		end
	end)

	SkillManager.Register.Used(Config.Skill.Pistols.AllShootSkills, function(e)
		if _ShouldPlaySheatheAnimation(e.Character) then
			Timer.StartObjectTimer("LLWEAPONEX_Pistol_ApplyShootingEffectStatus", e.Character, 350)
		else
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, true, e.Character)
		end
	end)

	Timer.Subscribe("LLWEAPONEX_Pistol_ApplyShootingEffectStatus", function (e)
		if e.Data.UUID then
			GameHelpers.Status.Apply(e.Data.Object, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, true, e.Data.Object)
		end
	end)
	
	SkillManager.Register.Cast(Config.Skill.Pistols.AllShootSkills, function(e)
		local delay = _GetPistolRemoveDelay(e.Character)
		if delay and delay > 0 then
			Timer.StartObjectTimer("LLWEAPONEX_RemovePistolEffect", e.Character, delay)
		else
			GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_FX_PISTOL_A_SHOOTING")
		end
	end)

	SkillManager.Register.MemorizationChanged(Config.Skill.Pistols.AllShootSkills, function (e)
		if GameHelpers.Character.IsPlayer(e.Character) then
			print(e.Skill, GameHelpers.Character.EquipmentHasSkill(e.Character, Config.Skill.Pistols.AllShootSkills))
			if e.Data == false and not GameHelpers.Character.EquipmentHasSkill(e.Character, e.Skill) then
				CharacterRemoveSkill(e.CharacterGUID, "Shout_LLWEAPONEX_Pistol_Reload")
			end
		end
	end)
end, {Priority=999})

Timer.Subscribe("LLWEAPONEX_RemovePistolEffect", function(e)
	if e.Data.Object then
		GameHelpers.Status.Remove(e.Data.Object, "LLWEAPONEX_FX_PISTOL_A_SHOOTING")
	end
end)