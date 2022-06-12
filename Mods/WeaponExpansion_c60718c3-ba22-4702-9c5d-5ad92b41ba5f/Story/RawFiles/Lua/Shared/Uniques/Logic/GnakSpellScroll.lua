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

	function OnSpellScrollEquipped(char, item)
		
	end

	function OnSpellScrollUnequipped(char, item)
		for skill,data in pairs(SpellData) do
			if data.Material ~= nil then
				RemoveStatus(char, data.Material)
			end
		end
	end

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
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Fire = {Flags = { "Lava", "Fire" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Fire_01", Template="84a171b0-c44d-4689-b8fc-25e32676cd76"},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Water = {Flags = { "Water" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Water_01", Template="bd8d5043-5cf7-427c-8dfc-829b7c6065d2"},
		--RS3_FX_Skills_Totem_Impact_Summon_Ice_01
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Air = {Flags = { "Electrified" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Lightning_01", Template="dd564396-1c61-44b9-b20a-2e35de986a2c"},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Poison = {Flags = { "Poison" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Poison_01", Template="cabefda4-6839-44e7-8e5e-7c1942fc13ca"},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Oil = {Flags = { "Oil"}, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Oil_01", Template="c542a8df-8352-4cc5-a839-e5016c1f29a6"},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Blood = {Flags = { "Blood" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Blood_01", Template="8921ef15-d694-49c2-9721-95ddf0c6652e"},
		Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface_Source = {Flags = { "Source" }, Effect = "RS3_FX_Skills_Totem_Impact_Summon_Default_01", Template="f2a4628f-c279-48a5-a243-9db6f903826a"},
	}

	local function FireSpell(source, target)
		local x,y,z = GetPosition(source)
		local hitText = GameHelpers.GetStringKeyText("LLWEAPONEX_StatusText_GnakSpellScroll_BadaBoom", "<font color='#ED9D07'>Bada Boom</font>")
		if type(target) == "string" then
			if ObjectIsItem(target) == 1 then
				DisplayText(target, hitText)
			else
				CharacterStatusText(target, hitText)
			end
			x,y,z = GetPosition(target)
		elseif type(target) == "table" then
			x,y,z = table.unpack(target)
			CharacterStatusText(source, hitText)
		end
		local spells = BuildDropList()
		if spells ~= nil then
			local spell = GetRandomSpell(spells, Ext.Random(1,maxRoll))
			--local spell = "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface"
			local data = SpellData[spell]

			local fireSpell = true

			if data.CasterEffects ~= nil then
				for i,v in pairs(data.CasterEffects) do
					PlayEffect(source, v.Effect, v.Bone)
				end
			end

			if data.ExplodeEffects ~= nil then
				for i,v in pairs(data.ExplodeEffects) do
					PlayScaledEffectAtPosition(v.Effect, v.Scale, x, y, z)
				end
			end

			if data.Material ~= nil then
				PlayEffect(source, "LLWEAPONEX_FX_Status_SpellScroll_ElementShifted_01", "Dummy_FX_02")
				GameHelpers.Status.Apply(source, data.Material, -1.0, 1, source)
			end

			if spell == "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_DimensionalBolt" then
				local surface = Common.GetRandomTableEntry(DimensionBoltSurfaces)
				Osi.LeaderLib_Helper_CreateSurfaceWithOwnerAtPosition(source, x, y, z, surface, 1.0, 2)
			elseif spell == "Projectile_LLWEAPONEX_BattleBooks_SpellScroll_TotemFromSurface" then
				--ObjectSetFlag(source, "LLWEAPONEX_GnakSpellScroll_JustSummonedTotem", 0)
				local foundSurface = false
				local level = CharacterGetLevel(source)
				---@type AiGrid
				local grid = Ext.GetAiGrid()
				for totemSkill,totemData in pairs(TotemSurfaceFlags) do
					if grid:SearchForCell(x, z, 2.0, totemData.Flags, -1.0) then
						local totem = NRD_Summon(source, totemData.Template, x, y, z, 12.0, level, 1, 1)
						Timer.StartOneshot("Timers_LLWEAPONEX_PlayTotemEffects_"..totem, 500, function()
							PlayEffect(totem, "RS3_FX_Skills_Totem_Target_Nebula_01", "Dummy_Root")
							PlayEffect(totem, totemData.Effect, "Dummy_Root")
						end)
						GameHelpers.SetScale(totem, 0.5)
						foundSurface = true
						break
					end
				end
				fireSpell = false
				if not foundSurface then
					local totem = NRD_Summon(source, "98be4473-a55a-495a-adac-0bda6dc69343", x, y, z, 12.0, level, 1, 1)
					Timer.StartOneshot("Timers_LLWEAPONEX_PlayTotemEffects_"..totem, 500, function()
						PlayEffect(totem, "RS3_FX_Skills_Totem_Target_Nebula_01", "Dummy_Root")
						PlayEffect(totem, "RS3_FX_Skills_Totem_Impact_Summon_Default_01", "Dummy_Root")
					end)
					GameHelpers.SetScale(totem, 0.5)
				end
			end

			if fireSpell then
				if data.ShootProjectile then
					GameHelpers.ShootProjectile(source, target, spell, 0)
				else
					GameHelpers.ExplodeProjectile(source, target, spell)
				end
			end

			local text = GameHelpers.GetStringKeyText("LLWEAPONEX_StatusText_GnakSpellScroll_Spell", "<font color='#ED9D07'>Spell Triggered! [1]</font>")
			local spellName = GameHelpers.GetStringKeyText(data.DisplayName, "")
			if spellName ~= "" then
				text = string.gsub(text, "%[1%]", spellName)
				CharacterStatusText(source, text)
			end

			PlayEffectAtPosition("LLWEAPONEX_FX_Status_SpellScroll_Hit_Text_01", x, y, z)

			return true
		end
		return false
	end

	DeathManager.RegisterListener("GnakSpellScroll", function(target, attacker, targetDied)
		if targetDied and CharacterHasSkill(attacker, "Shout_LLWEAPONEX_SpellScroll_PrepareMagic") == 1 then
			NRD_SkillSetCooldown(attacker, "Shout_LLWEAPONEX_SpellScroll_PrepareMagic", 0.0)
			GameHelpers.UI.RefreshSkillBarSkillCooldown(attacker, "Shout_LLWEAPONEX_SpellScroll_PrepareMagic")
		end
	end)

	local function ListenForDeath(target, attacker, delay)
		DeathManager.ListenForDeath("GnakSpellScroll", GameHelpers.GetUUID(target), GameHelpers.GetUUID(attacker), delay)
	end

	AttackManager.OnStart.Register(function(attacker, target)
		if HasActiveStatus(attacker.MyGuid, "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_HIT_READY") == 1 then
			ListenForDeath(target, attacker, 3000)
		end
	end)

	AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_GnakSpellScrollEquipped", function(tag, attacker, target, data, targetIsObject, skill)
		if not skill and HasActiveStatus(attacker.MyGuid, "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_HIT_READY") == 1 then
			ListenForDeath(target, attacker, 1500)
			if FireSpell(attacker.MyGuid, target.MyGuid) then
				RemoveStatus(attacker.MyGuid, "LLWEAPONEX_BATTLEBOOK_SPELLSCROLL_HIT_READY")
			end
		end
	end)

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

end