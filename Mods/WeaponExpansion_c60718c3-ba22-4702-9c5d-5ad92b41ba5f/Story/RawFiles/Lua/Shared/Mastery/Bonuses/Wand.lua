local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 1, {
	rb:Create("WAND_ELEMENTAL_WEAKNESS", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Wand_ElementalWeakness", "<font color='#9BF0FF'>Targets hit by basic attacks become weak to your wand's element, gaining [Special:LLWEAPONEX_WeaponElementalWeakness] for [ExtraData:LLWEAPONEX_MB_Wand_ElementalWeaknessTurns] turn(s).</font>"),
		GetIsTooltipActive = function(bonus, id, character, tooltipType, status)
			if tooltipType == "skill" then
				if GameHelpers.CharacterOrEquipmentHasTag(character, "LLWEAPONEX_Wand_Equipped") then
					if id == "ActionAttackGround" then
						return Mastery.Variables.Bonuses.HasElementalWeaknessWeapon(character)
					end
				end
			end
			return false
		end
	}):RegisterOnWeaponTagHit("LLWEAPONEX_Wand", function(tag, attacker, target, data, targetIsObject, skill, self)
		if not skill then
			local duration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Wand_ElementalWeaknessTurns", 1) * 6.0
			if duration > 0 then
				for slot,v in pairs(GameHelpers.Item.FindTaggedEquipment(attacker, "LLWEAPONEX_Wand")) do
					local weapon = Ext.GetItem(v)
					if weapon and weapon.ItemType == "Weapon" then
						for i, stat in pairs(weapon.Stats.DynamicStats) do
							if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
								local status = Mastery.Variables.Bonuses.ElementalWeaknessStatuses[stat.DamageType]
								if status then
									GameHelpers.Status.Apply(target, status, duration, false, attacker, 1.1)
								end
							end
						end
					end
				end
			end
		end
	end),

	rb:Create("WAND_BLOOD_EMPOWER", {
		Skills = {"Shout_FleshSacrifice", "Shout_EnemyFleshSacrifice"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Wand_FleshSacrifice", "<font color='#CC33FF'>Allies standing on <font color='#F13324'>blood surfaces</font> or in <font color='#F13324'>blood clouds</font> gain a <font color='#33FF00'>[Stats:Stats_LLWEAPONEX_BloodEmpowered:DamageBoost]% damage bonus</font>, while enemies take [Special:LLWEAPONEX_MasteryBonus_FleshSacrifice_Damage].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			local grid = Ext.GetAiGrid()
			for _,partyMember in pairs(GameHelpers.GetParty(char, true, true, true, false)) do
				local x,y,z = GetPosition(partyMember)
				if GameHelpers.Surface.HasSurface(x,z "Blood", 1.5, true, nil, grid) then
					GameHelpers.Status.Apply(partyMember, "LLWEAPONEX_BLOOD_EMPOWERED", 6.0, 0, char)
				end
			end
		end
	end),
})

local _skillToTooltip = {
	ProjectileStrike_HailStrike = ts:CreateFromKey("LLWEAPONEX_MB_Wand_SurfaceBoost_Water", "[Placeholder]"),
	Projectile_FlamingDaggers = ts:CreateFromKey("LLWEAPONEX_MB_Wand_SurfaceBoost_Fire", "[Placeholder]"),
	Projectile_LightningBolt = ts:CreateFromKey("LLWEAPONEX_MB_Wand_SurfaceBoost_Air", "[Placeholder]"),
	Projectile_PoisonDartStart = ts:CreateFromKey("LLWEAPONEX_MB_Wand_SurfaceBoost_Poison", "[Placeholder]"),
	Projectile_PyroclasticRock = ts:CreateFromKey("LLWEAPONEX_MB_Wand_SurfaceBoost_Earth", "[Placeholder]")
}

_skillToTooltip.ProjectileStrike_EnemyHailStrike = _skillToTooltip.ProjectileStrike_HailStrike
_skillToTooltip.Projectile_EnemyFlamingDaggers = _skillToTooltip.Projectile_FlamingDaggers
_skillToTooltip.Projectile_EnemyLightningBolt = _skillToTooltip.Projectile_LightningBolt
_skillToTooltip.Projectile_EnemyPoisonDartStart = _skillToTooltip.Projectile_PoisonDartStart
_skillToTooltip.Projectile_EnemyPyroclasticRock = _skillToTooltip.Projectile_PyroclasticRock

local surfaceBonus = rb:Create("WAND_SURFACE_BOOST", {
	Skills = {"Projectile_FlamingDaggers", "Projectile_PyroclasticRock", "Projectile_LightningBolt", "Projectile_PoisonDartStart", "ProjectileStrike_HailStrike", "ProjectileStrike_EnemyHailStrike", "Projectile_EnemyFlamingDaggers", "Projectile_EnemyLightningBolt", "Projectile_EnemyPoisonDartStart", "Projectile_EnemyPyroclasticRock"},
	---@param bonus MasteryBonusData
	---@param skill string
	---@param character EclCharacter
	---@param tooltipType string
	OnGetTooltip = function(bonus, skill, character, tooltipType)
		if _skillToTooltip[skill] then
			return _skillToTooltip[skill].Value
		end
	end,
})

if not Ext.IsClient() then
	local _skillToSurfaces = {
		ProjectileStrike_HailStrike = {
			"Deepwater",
			"FrostCloud",
			"Water",
			"WaterBlessed",
			"WaterCloud",
			"WaterCloudBlessed",
			"WaterCloudCursed",
			"WaterCloudElectrified",
			"WaterCloudElectrifiedBlessed",
			"WaterCloudElectrifiedCursed",
			"WaterCloudElectrifiedPurified",
			"WaterCloudPurified",
			"WaterCursed",
			"WaterElectrified",
			"WaterElectrifiedBlessed",
			"WaterElectrifiedCursed",
			"WaterElectrifiedPurified",
			"WaterFrozen",
			"WaterFrozenBlessed",
			"WaterFrozenCursed",
			"WaterFrozenPurified",
			"WaterPurified"
		},
		Projectile_FlamingDaggers = {
			"ExplosionCloud",
			"Fire",
			"FireBlessed",
			"FireCloud",
			"FireCloudBlessed",
			"FireCloudCursed",
			"FireCloudPurified",
			"FireCursed",
			"FirePurified",
			"Lava"
		},
		Projectile_LightningBolt = {
			"BloodCloudElectrified",
			"BloodCloudElectrifiedBlessed",
			"BloodCloudElectrifiedCursed",
			"BloodCloudElectrifiedPurified",
			"BloodElectrified",
			"BloodElectrifiedBlessed",
			"BloodElectrifiedCursed",
			"BloodElectrifiedPurified",
			"WaterCloudElectrified",
			"WaterCloudElectrifiedBlessed",
			"WaterCloudElectrifiedCursed",
			"WaterCloudElectrifiedPurified",
			"WaterElectrified",
			"WaterElectrifiedBlessed",
			"WaterElectrifiedCursed",
			"WaterElectrifiedPurified"
		},
		Projectile_PoisonDartStart = {
			"Poison",
			"PoisonBlessed",
			"PoisonCloud",
			"PoisonCloudBlessed",
			"PoisonCloudCursed",
			"PoisonCloudPurified",
			"PoisonCursed",
			"PoisonPurified"
		},
		Projectile_PyroclasticRock = {
			"Oil",
			"OilBlessed",
			"OilCursed",
			"OilPurified"
		}
	}
	_skillToSurfaces.ProjectileStrike_EnemyHailStrike = _skillToSurfaces.ProjectileStrike_HailStrike
	_skillToSurfaces.Projectile_EnemyFlamingDaggers = _skillToSurfaces.Projectile_FlamingDaggers
	_skillToSurfaces.Projectile_EnemyLightningBolt = _skillToSurfaces.Projectile_LightningBolt
	_skillToSurfaces.Projectile_EnemyPoisonDartStart = _skillToSurfaces.Projectile_PoisonDartStart
	_skillToSurfaces.Projectile_EnemyPyroclasticRock = _skillToSurfaces.Projectile_PyroclasticRock
	
	Mastery.Variables.Bonuses.WandSkillToSurfaces = _skillToSurfaces

	local surfaceBoostText = ts:CreateFromKey("LLWEAPONEX_StatusText_Wand_FireSurfaceBonus", "<font color='#B658FF'>Wand Mastery: [1] Surface Spell Boost!</font>")
	
	---@param func fun(source:EsvCharacter, target:number[], skill:string, data:HitData, bonuses:string[])
	local function CreateCallback(func)
		return func
	end
	
	local _specialSkillSurfaceCallback = {
		ProjectileStrike_HailStrike = CreateCallback(function (source, target, skill, data, bonuses)
			CharacterStatusText(source.MyGuid, surfaceBoostText:ReplacePlaceholders(LocalizedText.DamageTypeNames.Water.Text.Value))
		end),
		Projectile_FlamingDaggers = CreateCallback(function (source, target, skill, data, bonuses)
			local projectiles = GameHelpers.GetExtraData("LLWEAPONEX_MB_Wand_SurfaceBonus_Fire_Projectiles", 4)
			if projectiles > 0 then
				for i=0,projectiles do
					local ran = Ext.Random(0,1000) * 0.001
					local angle = Ext.Round(360 * ran)
					local pos = GameHelpers.Math.GetPositionWithAngle(target, angle, Ext.Random(6,9))
					NRD_ProjectilePrepareLaunch()
					local sx,sy,sz = table.unpack(target)
					local tx,ty,tz = table.unpack(pos)
					ty = ty + (Ext.Random(0,1) == 1 and Ext.Random(-20,20) or 0)
					NRD_ProjectileSetVector3("SourcePosition", sx,sy,sz)
					NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
					NRD_ProjectileSetInt("CasterLevel", source.Stats.Level)
					NRD_ProjectileSetInt("AlwaysDamage", 1)
					NRD_ProjectileSetString("SkillId", "Projectile_TrapFireballNoIgnite")
					NRD_ProjectileSetGuidString("Caster", source.MyGuid)
					NRD_ProjectileLaunch()
				end
				CharacterStatusText(source.MyGuid, surfaceBoostText:ReplacePlaceholders(LocalizedText.DamageTypeNames.Fire.Text.Value))
			end
		end),
		Projectile_LightningBolt = CreateCallback(function (source, target, skill, data, bonuses)
			CharacterStatusText(source.MyGuid, surfaceBoostText:ReplacePlaceholders(LocalizedText.DamageTypeNames.Air.Text.Value))
		end),
		Projectile_PoisonDartStart = CreateCallback(function (source, target, skill, data, bonuses)
			CharacterStatusText(source.MyGuid, surfaceBoostText:ReplacePlaceholders(LocalizedText.DamageTypeNames.Poison.Text.Value))
		end),
		Projectile_PyroclasticRock = CreateCallback(function (source, target, skill, data, bonuses)
			CharacterStatusText(source.MyGuid, surfaceBoostText:ReplacePlaceholders(LocalizedText.DamageTypeNames.Earth.Text.Value))
		end),
	}
	_specialSkillSurfaceCallback.ProjectileStrike_EnemyHailStrike = _specialSkillSurfaceCallback.ProjectileStrike_HailStrike
	_specialSkillSurfaceCallback.Projectile_EnemyFlamingDaggers = _specialSkillSurfaceCallback.Projectile_FlamingDaggers
	_specialSkillSurfaceCallback.Projectile_EnemyLightningBolt = _specialSkillSurfaceCallback.Projectile_LightningBolt
	_specialSkillSurfaceCallback.Projectile_EnemyPoisonDartStart = _specialSkillSurfaceCallback.Projectile_PoisonDartStart
	_specialSkillSurfaceCallback.Projectile_EnemyPyroclasticRock = _specialSkillSurfaceCallback.Projectile_PyroclasticRock
	Mastery.Variables.Bonuses.WandSkillToSurfaceCallback = _specialSkillSurfaceCallback

	local _JustRanWandSurfaceBonus = {}

	Timer.Subscribe("LLWEAPONEX_ClearJustRanWandSurfaceBonus", function (e)
		_JustRanWandSurfaceBonus[e.Data.UUID] = nil
	end)

	surfaceBonus:RegisterSkillListener(
	---@param data ProjectileHitData
	function(bonuses, skill, character, state, data)
		local char = GameHelpers.GetUUID(character)
		if not char then
			return
		end
		if _JustRanWandSurfaceBonus[char] ~= true then
			if state == SKILL_STATE.BEFORESHOOT then
				local pos = data.EndPosition
				local surfaces = _skillToSurfaces[skill]
				local surfaceCallback = _specialSkillSurfaceCallback[skill]
				if surfaceCallback and surfaces then
					local hasSurface = GameHelpers.Surface.HasSurface(pos[1], pos[3], surfaces, 3.0, false)
					if hasSurface then
						if PersistentVars.SkillData.WandSurfaceBonuses[char] == nil then
							PersistentVars.SkillData.WandSurfaceBonuses[char] = {}
						end
						PersistentVars.SkillData.WandSurfaceBonuses[char][skill] = true
						local stat = Ext.GetStat(skill)
						local targetAmount = stat.AmountOfTargets or 0
						if targetAmount > 1 then
							_JustRanWandSurfaceBonus[char] = true
							Timer.StartObjectTimer("LLWEAPONEX_ClearJustRanWandSurfaceBonus", char, math.max(stat.ProjectileDelay+1 * 10, 500))
						end
					end
				end
			elseif state == SKILL_STATE.PROJECTILEHIT then
				local matchedBonuses = PersistentVars.SkillData.WandSurfaceBonuses[char]
				if matchedBonuses and matchedBonuses[skill] then
					matchedBonuses[skill] = nil
					if not Common.TableHasAnyEntry(matchedBonuses) then
						PersistentVars.SkillData.WandSurfaceBonuses[char] = nil
					end
					local surfaceCallback = _specialSkillSurfaceCallback[skill]
					if surfaceCallback then
						local source = GameHelpers.GetCharacter(char)
						local b,err = xpcall(surfaceCallback, debug.traceback, source, data.Position, skill, data, bonuses)
						if not b then
							Ext.PrintError(err)
						end
					end
				end
			end
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 2, {
	surfaceBonus
})

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 4, {
	
})