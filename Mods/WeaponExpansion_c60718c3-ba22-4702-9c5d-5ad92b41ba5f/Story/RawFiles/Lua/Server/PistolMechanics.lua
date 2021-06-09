local raceTags = {
	"DWARF",
	"ELF",
	"HUMAN",
	"LIZARD",
}

local function GetRaceTag(source)
	for i,tag in pairs(raceTags) do
		if IsTagged(source, tag) == 1 then
			return tag
		end
	end
	return nil
end

local function GetPistolProjectileSkill(char)
	local skill = "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand"
	if char:HasTag("DWARF") then
		skill = "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand"
	elseif char:HasTag("ELF") then
		skill = "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand"
	elseif char:HasTag("HUMAN") then
		skill = "Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand"
	elseif char:HasTag("LIZARD") then
		skill = "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand"
	end
	return skill
end

local PistolEffects = {
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
}

local function GetPistolExplosionEffect(char)
	local race = GetRaceTag(char.MyGuid) or "HUMAN"
	local isFemale = 0
	if char:HasTag("FEMALE") then
		isFemale = 1
	end
	local raceData = PistolEffects[race]
	if raceData then
		local effect = raceData[isFemale]
		return effect
	end
	return "LLWEAPONEX_FX_PISTOL_EXPLOSION_LEFT"
end

local function GetPistolRemoveDelay(char)
	if char:HasTag("DWARF") then
		return 600
	elseif char:HasTag("ELF") then
		return 250
	elseif char:HasTag("HUMAN") then
		return 400
	elseif char:HasTag("LIZARD") then
		return 800
	else
		return 150
	end
end

local function ShouldPlaySheatheAnimation(caster)
	if caster:HasTag("DWARF") or caster:HasTag("ELF") then
		return true
	end
	return false
end

---@param request EsvShootProjectileRequest
Ext.RegisterListener("BeforeShootProjectile", function (request)
	--print(string.format("(%s) BeforeShootProjectile(%s)", Ext.MonotonicTime(), request.SkillId))
	local skill = GetSkillEntryName(request.SkillId) or ""
	if skill == "Projectile_LLWEAPONEX_Pistol_Shoot" then
		local caster = Ext.GetCharacter(request.Caster)
		request.SkillId = GetPistolProjectileSkill(caster).."-1"
		local target = Ext.GetGameObject(request.Target)
		if target ~= nil then
			
		else
			local targetPos = request.EndPosition
			targetPos[2] = targetPos[2] + 2.0
			local maxDistance = Ext.ExtraData.LLWEAPONEX_Pistol_MaxBonusDistance or 12.0
			local currentDist = GameHelpers.Math.GetDistance(caster.WorldPos, targetPos)
			local dist = maxDistance - currentDist
			request.IgnoreObjects = false
			targetPos = GameHelpers.Math.ExtendPositionWithForwardDirection(caster, dist, targetPos[1], targetPos[2], targetPos[3])
			request.EndPosition = targetPos
		end
		print(target, Common.Dump(request.EndPosition))
	end
end)

---@param projectile EsvProjectile
Ext.RegisterListener("ShootProjectile", function (projectile)
	local skill = GetSkillEntryName(projectile.SkillId) or ""
	if string.find(skill, "Projectile_LLWEAPONEX_Pistol_Shoot") then
		local caster = Ext.GetCharacter(projectile.CasterHandle)
		local status = GetPistolExplosionEffect(caster)
		ApplyStatus(caster.MyGuid, status, 0.0, 0, caster.MyGuid)
		-- local handle = projectile.Handle
		-- print(string.format("SourcePosition(%s) Position(%s) PrevPosition(%s)", Common.Dump(projectile.SourcePosition), Common.Dump(projectile.Position), Common.Dump(projectile.PrevPosition)))
		-- StartOneshotTimer("LLWEAPONEX_Pistol_PlayProjectileExplosion_"..tostring(projectile.NetID), 1, function()
		-- 	projectile = Ext.GetGameObject(handle)
		-- 	print(handle, projectile)
		-- 	if projectile and projectile.Position then
		-- 		local x,y,z = table.unpack(projectile.Position)
		-- 		PlayEffectAtPosition("LLWEAPONEX_FX_Pistol_A_Shoot_01", x, y, z)
		-- 	end
		-- end)
	end
end)

Timer.RegisterListener("LLWEAPONEX_RemovePistolEffect", function(timerName, char)
	if char then
		RemoveStatus(char, "LLWEAPONEX_FX_PISTOL_A_SHOOTING")
	end
end)

RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot", function(skill, char, state, data)
	if state == SKILL_STATE.USED then
		local caster = Ext.GetCharacter(char)
		if ShouldPlaySheatheAnimation(caster) then
			StartOneshotTimer("Timers_LLWEAPONEX_EquipPistolFX", 350, function()
				ApplyStatus(char, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, 1, char)
			end)
		else
			ApplyStatus(char, "LLWEAPONEX_FX_PISTOL_A_SHOOTING", 12.0, 1, char)
		end
	elseif state == SKILL_STATE.CAST then
		local caster = Ext.GetCharacter(char)
		local delay = GetPistolRemoveDelay(caster)
		Timer.Start("LLWEAPONEX_RemovePistolEffect", delay, char)
	end
end)

local function ShootPistolAtObject(source,target)
	local skill = GetPistolProjectileSkill(source)
	-- For some reason, KNOCKED_DOWN types makes the target un-hittable by projectiles shot by scripts
	-- Allies also cannot be hit by script-spawned 0 ExplodeRadius projectiles, so we have to force the hit there too.
	local forceHit = (ObjectIsCharacter(target) == 1 and CharacterIsEnemy(source,target) == 0) or GameHelpers.Status.HasStatusType(target, "KNOCKED_DOWN")
	GameHelpers.ShootProjectile(source, target, skill, forceHit)
end
Ext.NewCall(ShootPistolAtObject, "LLWEAPONEX_ShootPistolAtObject", "(CHARACTERGUID)_Source, (GUIDSTRING)_Target")

local function ShootPistolAtPosition(source,x,y,z)
	local level = CharacterGetLevel(source)
	local skill = GetPistolProjectileSkill(source)

	local character = Ext.GetCharacter(source)
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