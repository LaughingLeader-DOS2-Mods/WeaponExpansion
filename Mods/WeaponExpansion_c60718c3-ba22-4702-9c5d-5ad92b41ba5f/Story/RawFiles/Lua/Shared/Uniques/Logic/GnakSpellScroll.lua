if not Vars.IsClient then
	local SpellData = {
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_BlindingRadiance = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Divine_Prepare_Divine_Hand_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Divine_Prepare_Divine_Hand_02"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Shout_BlindingRadiance_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Divine_BlindingRadiance_Cast_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_AIR",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_BurnMyEyes = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Divine_Cast_Target_Touch_R_Hand_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Divine_Cast_Target_Touch_cast_01"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Target_BurnMyEyes_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Divine_Burnmyeye_Impact_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_FIRE",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_Contamination = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Earth_Cast_Self_Touch_Hand_01_Poison"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Earth_Cast_Aoe_Voodoo_Hand_01"
				}
			},
			DefaultDropCount = 3,
			DisplayName = "Shout_Contamination_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Earth_Cast_Aoe_Voodoo_Root_01",
					Scale = 1.0
				},
				{
					Effect = "RS3_FX_Skills_Earth_Contamination_Impact_01",
					Scale = 1.0
				},
				{
					Effect = "RS3_FX_Skills_Earth_Cast_Aoe_Voodoo_Root_Textkey_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_POISON",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_DimensionalBolt = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Void_Divine_Cast_Hand_01"
				}
			},
			DefaultDropCount = 4,
			DisplayName = "Projectile_DimensionalBolt_DisplayName",
			ExplodeEffects = {},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_SUMMONING",
			ShootProjectile = true
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_Earthquake = 
		{
			CasterEffects = {},
			DefaultDropCount = 2,
			DisplayName = "Quake_Earthquake_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Earth_Cast_Shout_Earthquake_Root_01",
					Scale = 0.45
				},
				{
					Effect = "RS3_FX_Skills_Earth_Cast_Shout_Earthquake_Root_02",
					Scale = 0.45
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_EARTH",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_FavourableWind = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_GP_Status_FavourableWind_Aura_Root_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Air_Wind_Cast_Ground_01"
				}
			},
			DefaultDropCount = 1,
			DisplayName = "Shout_FavourableWind_DisplayName",
			ExplodeEffects = {},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_AIR",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_FlamingDaggers = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Fire_Cast_Throw_Line_Hand_01"
				}
			},
			DefaultDropCount = 4,
			DisplayName = "Projectile_FlamingDaggers_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_GP_Impacts_FlamingDagger_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_FIRE",
			ShootProjectile = true
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_Fortify = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Earth_Cast_Self_Earth_Root_01"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Target_Fortify_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Earth_TargetEffect_Fortify_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_EARTH",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_GraspOfTheStarved = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Voodoo_Cast_Summon_Totem_Hand_01"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Target_GraspOfTheStarved_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Voodoo_Cast_Summon_Totem_Decay_GraspStarved_Root_01",
					Scale = 1.0
				},
				{
					Effect = "RS3_FX_Skills_Voodoo_Decaying_GraspStarved_Impact_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_NECROMANCY",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_HailStrike = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_Prepare_Water_Hand_01_Snow"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_Cast_AoE_Air_Root_01_Snow"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_GP_Impacts_HailStrike_01"
				}
			},
			DefaultDropCount = 4,
			DisplayName = "ProjectileStrike_HailStrike_DisplayName",
			ExplodeEffects = {},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_WATER",
			ShootProjectile = true
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_Haste = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Fire_Cast_Aoe_Divine_Hand_02"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Target_Haste_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Fire_Haste_Impact_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_FIRE",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_Ignition = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Fire_Cast_Ground_Fire_Hand_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Fire_Cast_FireOverlay_01"
				}
			},
			DefaultDropCount = 3,
			DisplayName = "Shout_Ignition_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Fire_Cast_Ground_Fire_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_FIRE",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_MagicShell = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_Cast_Self_Earth_Root_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_Cast_Self_Earth_Hand_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_FrostyShell_Impact_Root_01"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Target_FrostyShell_DisplayName",
			ExplodeEffects = {},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_WATER",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_MosquitoSwarm = 
		{
			CasterEffects = {},
			DefaultDropCount = 4,
			DisplayName = "Target_MosquitoSwarm_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Voodoo_Blood_Swarm_Target_01",
					Scale = 1.0
				},
				{
					Effect = "RS3_FX_Skills_Voodoo_Cast_Aoe_Voodoo_Blood_Swarm_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_NECROMANCY",
			ShootProjectile = true
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_PyroclasticRock = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Earth_Cast_Ground_Earth_Root_01"
				}
			},
			DefaultDropCount = 4,
			DisplayName = "Projectile_PyroclasticRock_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_GP_Impacts_PyroclasticRock_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_EARTH",
			ShootProjectile = true
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_Restoration = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_Cast_Self_Water_Root_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Water_Cast_Self_Water_Hand_01"
				}
			},
			DefaultDropCount = 2,
			DisplayName = "Target_Restoration_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Water_Restoration_Impact_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_WATER",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_ShockingTouch = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Air_Lightning_Cast_Hand_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Air_Lightning_Cast_Target_Touch_Hand_01"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Air_Cast_Target_Touch_Root_01"
				}
			},
			DefaultDropCount = 4,
			DisplayName = "Target_ShockingTouch_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Air_Lightning_Target_01",
					Scale = 1.0
				},
				{
					Effect = "RS3_FX_Skills_Air_Cast_Target_Touch_Hand_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_AIR",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TentacleLash = 
		{
			CasterEffects = {},
			DefaultDropCount = 3,
			DisplayName = "Target_TentacleLash_DisplayName",
			ExplodeEffects = 
			{
				{
					Effect = "RS3_FX_Skills_Totem_Lash_Impact_Root_01",
					Scale = 1.0
				}
			},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_POLYMORPH",
			ShootProjectile = false
		},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface = 
		{
			CasterEffects = 
			{
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Totem_Prepare_Totem_Root_01_Nebula"
				},
				{
					Bone = "Dummy_FX_02",
					Effect = "RS3_FX_Skills_Totem_Cast_Summon_Totem_Root_01"
				}
			},
			DefaultDropCount = 3,
			DisplayName = "Summon_TotemFromSurface_DisplayName",
			ExplodeEffects = {},
			Frequency = 1,
			Material = "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_MATERIAL_SUMMONING",
			ShootProjectile = true
		}
	}


	local function InitializeSpellEffects()
		PersistentVars.SkillData.GnakSpells = {}
		for skill,data in pairs(SpellData) do
			PersistentVars.SkillData.GnakSpells[skill] = data.DefaultDropCount
		end
	end

	EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
		if not e.Equipped then
			for skill,data in pairs(SpellData) do
				if data.Material ~= nil then
					GameHelpers.Status.Remove(e.Character, data.Material)
				end
			end
		end
	end, {MatchArgs={Tag="LLWEAPONEX_GnakSpellScrollEquipped"}})

	local maxRoll = 99999

	local function SetRanges(tbl)
		local rangeStart = 1
		local maxRoll = (maxRoll - (#tbl*2))
		local totalFrequency = 0
		for i=1,#tbl do
			local entry = tbl[i]
			if entry.Frequency > 0 then
				totalFrequency = totalFrequency + entry.Frequency
			end
		end
		if totalFrequency > 0 then
			for i=1,#tbl do
				local entry = tbl[i]
				if entry.Frequency > 0 then
					entry.StartRange = rangeStart
					if i == #tbl then
						entry.EndRange = maxRoll
					else
						entry.EndRange = math.min(maxRoll, rangeStart + math.ceil((entry.Frequency/totalFrequency) * maxRoll))
					end
					rangeStart = entry.EndRange+1
				else
					entry.StartRange = -1
					entry.EndRange = -1
				end
			end
		end
		--PrintDebug(Ext.JsonStringify(tbl))
		return tbl
	end

	---@class GnakDropEntry:{ID:string, Frequency:integer, StartRange:integer, EndRange:integer}

	---@return GnakDropEntry[]
	local function BuildDropList()
		if PersistentVars.SkillData.GnakSpells == nil or Common.TableLength(PersistentVars.SkillData.GnakSpells, true) == 0 then
			InitializeSpellEffects()
		end
		local spells = {}
		for skill,dropCount in pairs(PersistentVars.SkillData.GnakSpells) do
			if dropCount > 0 then
				local data = SpellData[skill]
				spells[#spells+1] = {ID=skill, Frequency=data.Frequency}
			end
		end
		if #spells == 0 then
			InitializeSpellEffects()
			for skill,dropCount in pairs(PersistentVars.SkillData.GnakSpells) do
				local data = SpellData[skill]
				spells[#spells+1] = {ID=skill, Frequency=data.Frequency}
			end
		end
		spells = SetRanges(Common.ShuffleTable(spells))
		return spells
	end

	---@param spells GnakDropEntry[]
	---@param roll integer
	---@return string skill
	local function GetRandomSpell(spells, roll)
		for i,v in pairs(spells) do
			--print(string.format("[%s] Start(%s)/End(%s)/(%s)", self.ID, self.StartRange, self.EndRange, roll))
			if roll >= v.StartRange and roll <= v.EndRange then
				PersistentVars.SkillData.GnakSpells[v.ID] = PersistentVars.SkillData.GnakSpells[v.ID] - 1
				return v.ID
			end
		end
		return "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_DimensionalBolt"
	end

	local DimensionBoltSurfaces = {
		"SurfaceFire",
		"SurfaceWater",
		"SurfaceWaterElectrified",
		"SurfaceWaterFrozen",
		"SurfaceBlood",
		"SurfacePoison",
		"SurfaceOil",
	}

	local TotemSurfaceFlags = {
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Fire", Flags = { "Lava", "Fire" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Fire_01", Template="84a171b0-c44d-4689-b8fc-25e32676cd76"},
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Water", Flags = { "Water" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Water_01", Template="bd8d5043-5cf7-427c-8dfc-829b7c6065d2"},
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Air", Flags = { "Electrified" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Lightning_01", Template="dd564396-1c61-44b9-b20a-2e35de986a2c"},
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Poison", Flags = { "Poison" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Poison_01", Template="cabefda4-6839-44e7-8e5e-7c1942fc13ca"},
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Oil", Flags = { "Oil"}, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Oil_01", Template="c542a8df-8352-4cc5-a839-e5016c1f29a6"},
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Blood", Flags = { "Blood" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Blood_01", Template="8921ef15-d694-49c2-9721-95ddf0c6652e"},
		{Skill="Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Source", Flags = { "Source" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Default_01", Template="f2a4628f-c279-48a5-a243-9db6f903826a"},
		--RS3_FX_Skills_Totem_Impact_Summon_Ice_01
	}

	local function _GetTotemLifetime()
		local skill = Ext.Stats.Get("Summon_TotemFromSurface")
		if skill then
			if skill.Lifetime < 0 then
				return -1
			elseif skill.Lifetime > 0 then
				--One turn less than default, but make it a minimum of 1 turn
				return math.max(6.0, (skill.Lifetime - 1) * 6)
			end
		end
		return 12
	end

	---@param source EsvCharacter
	---@param target EsvCharacter|EsvItem|number
	local function FireSpell(source, target)
		local sourceGUID = GameHelpers.GetUUID(source)
		local targetGUID = GameHelpers.GetUUID(target)
		local pos = source.WorldPos
		local hitText = GameHelpers.GetStringKeyText("LLWEAPONEX_StatusText_GnakSpellScroll_BadaBoom", "<font color='#ED9D07'>Bada Boom</font>")
		local t = type(target)
		local targetIsItem = false
		if t == "userdata" then
			targetIsItem = GameHelpers.Ext.ObjectIsItem(target)
			if targetIsItem then
				DisplayText(targetGUID, hitText)
			else
				CharacterStatusText(targetGUID, hitText)
			end
			pos = target.WorldPos
		elseif t == "table" then
			pos = target
			CharacterStatusText(sourceGUID, hitText)
		end
		local spells = BuildDropList()
		if spells ~= nil then
			local spell = GetRandomSpell(spells, Ext.Utils.Random(1,maxRoll))
			--local spell = "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface"
			local data = SpellData[spell]

			local fireSpell = true

			if data.CasterEffects ~= nil then
				for i,v in pairs(data.CasterEffects) do
					EffectManager.PlayEffect(v.Effect, source, {Bone=v.Bone})
				end
			end

			if data.ExplodeEffects ~= nil then
				for i,v in pairs(data.ExplodeEffects) do
					EffectManager.PlayEffectAt(v.Effect, pos, {Scale=v.Scale})
				end
			end

			if data.Material ~= nil then
				EffectManager.PlayEffect("LLWEAPONEX_FX_Status_SpellScroll_ElementShifted_01", source, {Bone="Dummy_FX_02"})
				GameHelpers.Status.Apply(source, data.Material, -1.0, true, source)
			end

			if spell == "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_DimensionalBolt" then
				local surface = Common.GetRandomTableEntry(DimensionBoltSurfaces)
				if surface then
					GameHelpers.Surface.CreateSurface(pos, surface, 1.0, 12, source.Handle, true)
				end
			elseif spell == "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface" then
				fireSpell = false
				local level = source.Stats.Level
				local totemLifetime =  _GetTotemLifetime()
				local grid = Ext.Entity.GetAiGrid()
				local totemTemplate = "98be4473-a55a-495a-adac-0bda6dc69343"
				local totemSummonEffect = "RS3_FX_Skills_Totem_Impact_Summon_Default_01"

				---Randomize table, just in case surfaces overlap here
				local shuffled = TableHelpers.ShuffleTable(TotemSurfaceFlags)
				for i=1,#shuffled do
					local data = shuffled[i]
					if grid:SearchForCell(pos[1], pos[3], 2.0, data.Flags, -1.0) then
						totemTemplate = data.Template
						totemSummonEffect = data.Effect
						break
					end
				end
				local sx,sy,sz,b = GameHelpers.Grid.GetValidPositionInRadius(pos, 6.0)
				if not b then
					--sx,sy,sz,b = GameHelpers.Grid.GetValidPositionAlongLine(source, GameHelpers.Math.GetDirectionalVectorBetweenPositions(source.WorldPos, pos), 1.0)
					sx,sy,sz,b = GameHelpers.Grid.GetValidPositionInRadius(pos, 12.0)
				end
				if b then
					local totemGUID = NRD_Summon(sourceGUID, totemTemplate, sx,sy,sz, totemLifetime, level, 1, 1)
					if not StringHelpers.IsNullOrEmpty(totemGUID) then
						GameHelpers.SetScale(totemGUID, 0.5)
						Timer.StartOneshot("Timers_LLWEAPONEX_PlayTotemEffects_"..totemGUID, 500, function()
							local totem = GameHelpers.GetCharacter(totemGUID)
							EffectManager.PlayEffect("RS3_FX_Skills_Totem_Target_Nebula_01", totem)
							EffectManager.PlayEffect(totemSummonEffect, totem)
						end)
					end
				end
			end

			if fireSpell then
				if data.ShootProjectile then
					GameHelpers.Skill.ShootProjectileAt(targetGUID, spell, sourceGUID)
				else
					GameHelpers.Skill.Explode(targetGUID, spell, sourceGUID)
				end
			end

			local text = GameHelpers.GetStringKeyText("LLWEAPONEX_StatusText_GnakSpellScroll_Spell", "<font color='#ED9D07'>Spell Triggered! [1]</font>")
			local spellName = GameHelpers.GetStringKeyText(data.DisplayName, "")
			if spellName ~= "" then
				text = string.gsub(text, "%[1%]", spellName)
				CharacterStatusText(sourceGUID, text)
			end

			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Status_SpellScroll_Hit_Text_01", pos)

			return true
		end
		return false
	end

	DeathManager.OnDeath:Subscribe(function (e)
		GameHelpers.Skill.SetCooldown(e.Source, "Shout_LLWEAPONEX_SpellScroll_PrepareMagic", 0)
	end, {MatchArgs={ID="GnakSpellScroll", Success=true}})

	local function ListenForDeath(target, attacker, delay)
		DeathManager.ListenForDeath("GnakSpellScroll", GameHelpers.GetUUID(target), GameHelpers.GetUUID(attacker), delay)
	end

	Events.OnBasicAttackStart:Subscribe(function (e)
		if e.TargetIsObject and GameHelpers.Status.IsActive(e.Attacker, "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_HIT_READY") then
			ListenForDeath(e.Target, e.Attacker, 3000)
		end
	end)

	Events.OnWeaponTagHit:Subscribe(function (e)
		if e.TargetIsObject and not e.Skill and GameHelpers.Status.IsActive(e.Attacker, "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_HIT_READY") then
			ListenForDeath(e.Target, e.Attacker, 1500)
			if FireSpell(e.Attacker, e.Target) then
				GameHelpers.Status.Remove(e.Attacker, "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_HIT_READY")
			end
		end
	end, {MatchArgs={Tag="LLWEAPONEX_GnakSpellScrollEquipped"}})

	Ext.RegisterConsoleCommand("printgnak", function(cmd)
		local SpellEntries = {}
		for _,entry in pairs(Osi.DB_LeaderLib_Randomization_Entries:Get("LLWEAPONEX_BattleBooks_SpellScroll_Spells", nil, nil, nil)) do
			local groupId,id,frequency,dropCount = table.unpack(entry)
			local dataEntry = {
				Frequency = frequency, 
				DefaultDropCount = dropCount,
				CasterEffects = {},
				ExplodeEffects = {},
				DisplayName = "",
				Projectile = "",
				Material = ""
			}
			SpellEntries[id] = dataEntry
			for _,db in pairs(Osi.DB_LLWEAPONEX_BattleBooks_SpellScroll_CasterEffects:Get(id, nil, nil)) do
				local id,effect,bone = table.unpack(db)
				local effectData = {
					Effect = effect,
					Bone = bone
				}
				table.insert(dataEntry.CasterEffects, effectData)
			end
			for _,db in pairs(Osi.DB_LLWEAPONEX_BattleBooks_SpellScroll_ExplodeEffects:Get(id, nil, nil)) do
				local id,effect,scale = table.unpack(db)
				local effectData = {
					Effect = effect,
					Scale = scale
				}
				table.insert(dataEntry.ExplodeEffects, effectData)
			end
			for _,db in pairs(Osi.DB_LLWEAPONEX_BattleBooks_SpellScroll_SpellNames:Get(id, nil)) do
				local id,name = table.unpack(db)
				dataEntry.DisplayName = name
			end
			for _,db in pairs(Osi.DB_LLWEAPONEX_BattleBooks_SpellScroll_ProjectileSettings:Get(id, nil, nil)) do
				local id,material,projectile = table.unpack(db)
				dataEntry.Material = material
				dataEntry.Projectile = projectile
			end
		end
		Ext.SaveFile("LLWEAPONEX_GnakSpells.json", Ext.JsonStringify(SpellEntries))
	end)

	StatusManager.Subscribe.Applied({"LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_FX_DIMENSIONALBOLT", "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_FX_TENTACLE"}, function (e)
		Timer.StartObjectTimer("LLWEAPONEX_BattleBooks_SpellScroll_RemoveBeamStatuses", e.Target, 500)
	end)

	Timer.Subscribe("LLWEAPONEX_BattleBooks_SpellScroll_RemoveBeamStatuses", function (e)
		GameHelpers.Status.Remove(e.Data.Object, {"LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_FX_DIMENSIONALBOLT", "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_FX_TENTACLE"})
	end)
end