SkillConfiguration.Pistols = {
	AllShootSkills = {
		"Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand",
		"Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand",
		"Projectile_LLWEAPONEX_Pistol_Shoot_RightHand",
		"Projectile_LLWEAPONEX_Pistol_Shoot_RightHand",
	},
	RaceToSkill = {
		DWARF = "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand",
		HUMAN = "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand",
		ELF = "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand",
		LIZARD = "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand",
	},
	PistolEffects = {
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("DWARF", 0, "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", 600, "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("DWARF", 1, "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", 600, "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("ELF", 0, "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", 250, "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("ELF", 1, "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", 250, "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("HUMAN", 0, "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", 400, "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("HUMAN", 1, "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", 400, "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("LIZARD", 0, "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", 800, "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT");
		-- DB_LLWEAPONEX_Pistols_HandProjectiles("LIZARD", 1, "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", 800, "LLWEAPONEX_FX_PISTOL_EXPLOSION_RIGHT");
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

local function GetPistolProjectileSkill(char)
	for tag,skill in pairs(SkillConfiguration.Pistols.RaceToSkill) do
		if char:HasTag(tag) then
			return skill
		end
	end
	return "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand"
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
	RegisterSkillListener(SkillConfiguration.Pistols.AllShootSkills, function (caster, skill, state, data)
		if state == SKILL_STATE.BEFORESHOOT then
			---@type EsvShootProjectileRequest
			local request = data
			local target = GameHelpers.TryGetObject(request.Target)
			if target == nil then
				local caster = GameHelpers.GetCharacter(caster)
				local targetPos = request.EndPosition
				targetPos[2] = targetPos[2] + 2.0
				local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_Pistol_MaxBonusDistance", 12.0)
				local currentDist = GameHelpers.Math.GetDistance(caster.WorldPos, targetPos)
				local dist = maxDistance - currentDist
				request.IgnoreObjects = false
				targetPos = GameHelpers.Math.ExtendPositionWithForwardDirection(caster, dist, targetPos[1], targetPos[2], targetPos[3])
				request.EndPosition = targetPos
			end
		elseif state == SKILL_STATE.SHOOTPROJECTILE then
			local caster = GameHelpers.GetCharacter(caster)
			local status = GetPistolExplosionEffect(caster)
			if status then
				GameHelpers.Status.Apply(caster, status, 0.0, 0, caster)
			end
		end
	end)
end, {Priority=999})

Timer.RegisterListener("LLWEAPONEX_RemovePistolEffect", function(timerName, char)
	if char then
		GameHelpers.Status.Remove(char, "LLWEAPONEX_FX_PISTOL_A_SHOOTING")
	end
end)

RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot", function(skill, char, state, data)
	if state == SKILL_STATE.USED then
		local caster = GameHelpers.TryGetObject(char)
		if ShouldPlaySheatheAnimation(caster) then
			Timer.StartOneshot("Timers_LLWEAPONEX_EquipPistolFX", 350, function()
				GameHelpers.Status.Apply(char, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, 1, char)
			end)
		else
			GameHelpers.Status.Apply(char, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, 1, char)
		end
	elseif state == SKILL_STATE.CAST then
		local delay = GetPistolRemoveDelay(GameHelpers.TryGetObject(char))
		Timer.Start("LLWEAPONEX_RemovePistolEffect", delay, char)
	end
end)

local function ShootPistolAtObject(source,target)
	source = GameHelpers.GetCharacter(source)
	target = GameHelpers.TryGetObject(target)

	local skill = GetPistolProjectileSkill(source)
	-- For some reason, KNOCKED_DOWN types makes the target un-hittable by projectiles shot by script
	-- Allies also cannot be hit by script-spawned 0 ExplodeRadius projectiles, so we have to force the hit there too.
	local forceHit = GameHelpers.Status.HasStatusType(target, "KNOCKED_DOWN")
	if not forceHit and GameHelpers.Ext.ObjectIsCharacter(target) and not GameHelpers.Character.IsEnemy(source, target) then
		forceHit = true
	end
	GameHelpers.Skill.ShootProjectileAt(target, skill, source, {SetHitObject = forceHit})
end
Ext.NewCall(ShootPistolAtObject, "LLWEAPONEX_ShootPistolAtObject", "(CHARACTERGUID)_Source, (GUIDSTRING)_Target")

local function ShootPistolAtPosition(source,x,y,z)
	local level = CharacterGetLevel(source)
	local skill = GetPistolProjectileSkill(source)

	local character = GameHelpers.GetCharacter(source)
	local pos = character.Stats.Position
	local rot = character.Stats.Rotation
	--Ext.Print("Rotation:",Ext.JsonStringify(rot))
	--Ext.Print("attacker.Position:",Ext.JsonStringify(pos))

	NRD_ProjectilePrepareLaunch()
	NRD_ProjectileSetString("SkillId", skill)
	NRD_ProjectileSetInt("CasterLevel", level)
	NRD_ProjectileSetGuidString("Caster", source)
	NRD_ProjectileSetVector3("SourcePosition", pos[1],pos[2] + 2.0, pos[3])
	NRD_ProjectileSetGuidString("Source", source)

	local distanceMult = 15.0
	local heightDiff = math.abs(math.abs(pos[2]) - math.abs(y))
	if heightDiff >= 2.0 then
		distanceMult = 1.0
	else
		local forwardVector = {
			-rot[7] * distanceMult,
			0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
			-rot[9] * distanceMult,
		}
		--Ext.Print("forwardVector:",Ext.JsonStringify(forwardVector))
	
		x = pos[1] + forwardVector[1]
		--y = pos[2] + forwardVector[2]
		z = pos[3] + forwardVector[3]
	end
	y = GameHelpers.Grid.GetY(x,z)
	--Ext.Print("heightDiff:",heightDiff)
	--Ext.Print("targetPos:",Ext.JsonStringify({x,y,z}))

	NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
	NRD_ProjectileSetVector3("TargetPosition", x,y,z)

	--PlayEffectAtPosition("RS3_FX_Skills_Void_SwapGround_Impact_Root_01",x,y,z)

	NRD_ProjectileLaunch()
end
Ext.NewCall(ShootPistolAtPosition, "LLWEAPONEX_ShootPistolAtPosition", "(CHARACTERGUID)_Source, (REAL)_x, (REAL)_y, (REAL)_z")