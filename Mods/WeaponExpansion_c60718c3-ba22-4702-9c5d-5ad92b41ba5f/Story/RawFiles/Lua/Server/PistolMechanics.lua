SkillConfiguration.Pistols = {
	AllShootSkills = {
		"Projectile_LLWEAPONEX_Pistol_Shoot",
		"Projectile_LLWEAPONEX_Pistol_Shoot_Enemy",
	},
	RaceToProjectileBone = {
		DWARF = "Dummy_L_HandFX",
		HUMAN = "Dummy_L_HandFX",
		ELF = "Dummy_R_HandFX",
		LIZARD = "Dummy_R_HandFX",
	},
	PistolEffects = {
		DWARF = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
		},
		ELF = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
		},
		HUMAN = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT",
		},
		LIZARD = {
			[0] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
			[1] = "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT",
		},
	},
	EffectRemoveDelay = {
		DWARF = 600,
		HUMAN = 400,
		ELF = 250,
		LIZARD = 800,
	},
	PlaySheathe = {
		DWARF = true,
		ELF = true
	}
}

local raceTags = {
	"DWARF",
	"ELF",
	"HUMAN",
	"LIZARD",
}

---@param character EsvCharacter
local function GetRaceTag(character)
	for _,tag in pairs(raceTags) do
		if character:HasTag(tag) then
			return tag
		end
	end
	return "HUMAN"
end

---@param char EsvCharacter
local function GetPistolExplosionEffect(char)
	local race = GetRaceTag(char)
	local isFemale = GameHelpers.Character.IsFemale(char) and 1 or 0
	local raceData = SkillConfiguration.Pistols.PistolEffects[race]
	if raceData then
		local effect = raceData[isFemale]
		return effect
	end
	return "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT"
end

---@param char EsvCharacter
local function GetPistolRemoveDelay(char)
	local race = GetRaceTag(char)
	local delay = SkillConfiguration.Pistols.EffectRemoveDelay[race]
	if delay then
		return delay
	end
	return 150
end

---@param char EsvCharacter
local function ShouldPlaySheatheAnimation(char)
	local race = GetRaceTag(char)
	return SkillConfiguration.Pistols.PlaySheathe[race] == true
end

--Prioritized last, in case other mods add to this table
Ext.Events.SessionLoaded:Subscribe(function ()
	-- SkillManager.Register.BeforeProjectileShoot(SkillConfiguration.Pistols.AllShootSkills, function (e)
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

	SkillManager.Register.ProjectileShoot(SkillConfiguration.Pistols.AllShootSkills, function (e)
		local raceTag = GetRaceTag(e.Character)
		local bone = SkillConfiguration.Pistols.RaceToProjectileBone[raceTag]
		if bone then
			e.Data.RootTemplate.CastBone = bone
		end

		local status = GetPistolExplosionEffect(e.Character)
		if status then
			GameHelpers.Status.Apply(e.Character, status, 0.0, false, e.Character)
		end
	end)

	SkillManager.Register.Hit(SkillConfiguration.Pistols.AllShootSkills, function(e)
		-- Silver bullets do bonus damage to undead/voidwoken
		if e.Data.Success then
			if TagHelpers.IsUndeadOrVoidwoken(e.Data.Target) then
				if Skills.HasTaggedRuneBoost(e.Character.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_Pistols") then
					local bonus = GameHelpers.GetExtraData("LLWEAPONEX_Pistol_SilverBonusDamage", 1.5)
					if bonus > 0 then
						e.Data:MultiplyDamage(bonus, true)
					end
				end
			end
		end
	end)

	SkillManager.Register.Used(SkillConfiguration.Pistols.AllShootSkills, function(e)
		if ShouldPlaySheatheAnimation(e.Character) then
			Timer.StartOneshot("", 350, function()
				GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, true, e.Character)
			end)
		else
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, true, e.Character)
		end
	end)
	
	SkillManager.Register.Cast(SkillConfiguration.Pistols.AllShootSkills, function(e)
		local delay = GetPistolRemoveDelay(e.Character)
		if delay and delay > 0 then
			Timer.StartObjectTimer("LLWEAPONEX_RemovePistolEffect", e.Character, delay)
		else
			GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_FX_PISTOL_A_SHOOTING")
		end
	end)

end, {Priority=999})

Timer.Subscribe("LLWEAPONEX_RemovePistolEffect", function(e)
	if e.Data.Object then
		GameHelpers.Status.Remove(e.Data.Object, "LLWEAPONEX_FX_PISTOL_A_SHOOTING")
	end
end)