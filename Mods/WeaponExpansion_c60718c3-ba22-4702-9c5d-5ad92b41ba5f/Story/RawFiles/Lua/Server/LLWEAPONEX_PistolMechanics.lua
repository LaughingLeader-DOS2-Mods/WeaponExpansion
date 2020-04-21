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

local function GetPistolProjectileSkill(source)
	local isFemale = IsTagged(source, "FEMALE")
	local race = GetRaceTag(source)
	if race == nil then race = "HUMAN" end

	local skillEntry = Osi.DB_LLWEAPONEX_Pistols_HandProjectiles:Get(race, isFemale, nil, nil, nil)
	if skillEntry ~= nil then
		return skillEntry[1][3]
	else
		return "Projectile_LLWEAPONEX_Pistol_A_Shoot_RightHand"
	end
end

local function ShootPistolAtObject(source,target)
	local level = CharacterGetLevel(source)
	local skill = GetPistolProjectileSkill(source)
	NRD_ProjectilePrepareLaunch()
	NRD_ProjectileSetString("SkillId", skill)
	NRD_ProjectileSetInt("CasterLevel", level)
	NRD_ProjectileSetGuidString("Caster", source)
	NRD_ProjectileSetGuidString("SourcePosition", source)
	NRD_ProjectileSetGuidString("Source", source)
	-- For some reason, KNOCKED_DOWN types makes the target un-hittable by projectiles shot by scripts
	if (ObjectIsCharacter(target) and CharacterIsEnemy(source,target) == 0) or LeaderLib_Ext_HasStatusType(target, "KNOCKED_DOWN") then
		NRD_ProjectileSetGuidString("HitObject", target)
		NRD_ProjectileSetGuidString("HitObjectPosition", target)
	end
	NRD_ProjectileSetGuidString("TargetPosition", target)
	NRD_ProjectileLaunch()
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
	Ext.Print("heightDiff:",heightDiff)

	--Ext.Print("targetPos:",Ext.JsonStringify({x,y,z}))

	NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
	NRD_ProjectileSetVector3("TargetPosition", x,y,z)

	--PlayEffectAtPosition("RS3_FX_Skills_Void_SwapGround_Impact_Root_01",x,y,z)

	NRD_ProjectileLaunch()
end
Ext.NewCall(ShootPistolAtPosition, "LLWEAPONEX_ShootPistolAtPosition", "(CHARACTERGUID)_Source, (REAL)_x, (REAL)_y, (REAL)_z")