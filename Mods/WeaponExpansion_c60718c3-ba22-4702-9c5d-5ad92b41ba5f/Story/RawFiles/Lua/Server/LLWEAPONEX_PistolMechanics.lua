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
	if LeaderLib_Ext_HasStatusType(target, "KNOCKED_DOWN") then
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
	NRD_ProjectilePrepareLaunch()
	NRD_ProjectileSetString("SkillId", skill)
	NRD_ProjectileSetInt("CasterLevel", level)
	NRD_ProjectileSetGuidString("Caster", source)
	NRD_ProjectileSetGuidString("SourcePosition", source)
	NRD_ProjectileSetGuidString("Source", source)

	local character = Ext.GetCharacter(source)
	local distanceMult = 15.0
	local rot = character.Rotation
	local forwardVector = {
		-rot[7] * distanceMult,
		-rot[8] * distanceMult,
		-rot[9] * distanceMult,
	}
	local pos = character.Position
	x = pos[1] + forwardVector[1]
	--y = pos[2] + forwardVector[2]
	z = pos[3] + forwardVector[3]

	NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
	NRD_ProjectileSetVector3("TargetPosition", x,y,z)

	NRD_ProjectileLaunch()
end
Ext.NewCall(ShootPistolAtObject, "LLWEAPONEX_ShootPistolAtPosition", "(CHARACTERGUID)_Source, (REAL)_x, (REAL)_y, (REAL)_z")