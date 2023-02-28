Debug = {
	MasteryTests = false,
	AddOriginsToParty = false,
	CreateOriginPresetEquipment = false
}
Math = { AbilityScaling = {}}
if Text == nil then
	Text = {}
end
MasterySystem = {}

Config = {
	Skill = {
		BannerRally = {
			Templates = {
				Dome_LLWEAPONEX_Banner_Rally_DivineOrder = "d5c842bf-8eb0-46cd-a928-e4f989f91010", -- LLWEAPONEX_Skill_Rally_Banner_DivineOrder_A
				Dome_LLWEAPONEX_Banner_Rally_Dwarves = "cfdf3976-4696-473d-8f4b-fd1461f8d708", -- LLWEAPONEX_Skill_Rally_Banner_Dwarves_A
			},
			SkillToStatus = {
				Dome_LLWEAPONEX_Banner_Rally_DivineOrder = "LLWEAPONEX_BANNER_RALLY_DIVINEORDER",
				Dome_LLWEAPONEX_Banner_Rally_Dwarves = "LLWEAPONEX_BANNER_RALLY_DWARVES",
			}
		}
	},
    Status = {
        RemoveOnTurnEnding = {
            LLWEAPONEX_MASTERYBONUS_VULNERABLE = true,
        },
		ChaosPowerSurfaces = {
			"Fire",
			"Water",
			"WaterElectrified",
			"WaterFrozen",
			"Blood",
			"BloodElectrified",
			"BloodFrozen",
			"Poison",
			"Oil",
			"Source",
			"Web",
			"WaterCloud",
			"BloodCloud",
			"SmokeCloud",
		}
    },
	TempData = {
		RecalculatedUnarmedSkillDamage = {}
	},
	Visuals = {
		--Root Template to Visual
		DualShields = {
			CombatShieldBones = {
				Unsheathed = "Dummy_R_Hand",
				Sheathed = "Dummy_Weapon_XB",
			},
			CombatShieldTemplates = {
				--WPN_LLWEAPONEX_CombatShield_Blackring_1H_A
				["ec353f1e-c1ca-46d1-83ef-e9f4fea14475"] = {
					Visual = "00052b22-e1e7-4f41-a057-3d8a3b7a57bf",
					Sheathed = "eb0b2cc0-0c2f-4a9d-93f5-2fadb05971e4",
				},
				--WPN_LLWEAPONEX_CombatShield_Common_1H_A
				["8c7da07b-ad11-4a0c-8406-0261977042b6"] = {
					Visual = "5ace814c-adfa-4e72-b992-4d22832ffe5a",
					Sheathed = "80624a17-d95e-4cc8-8a94-08c151059636",
				},
				--WPN_LLWEAPONEX_CombatShield_Dwarves_1H_A
				["bc034226-19bd-45e6-be7d-ec0d28c2e412"] = {
					Visual = "0b075b93-84f2-4ad5-b420-81ebabb7f847",
					Sheathed = "df8b6237-d031-44d7-b729-a80eb074f3b3",
				},
				--WPN_LLWEAPONEX_CombatShield_Elves_1H_B
				["1268f5f0-e484-42ea-8c13-0014e6aeaaad"] = {
					Visual = "b1b30d3a-1d6a-4601-a96d-9be2c3900451",
					Sheathed = "07ea0986-0edb-4c58-925a-d76cc586908b",
				},
				--WPN_LLWEAPONEX_CombatShield_Humans_1H_A
				["3a404dab-4862-4490-aa0f-bc27d06fdc6c"] = {
					Visual = "1683a154-2a19-42db-bd76-f9b43202715e",
					Sheathed = "48491cef-a2de-4dec-9d65-9c6aea8a769e",
				},
				--WPN_LLWEAPONEX_CombatShield_Lizards_1H_C
				["067f48be-857d-43a8-bd0a-add59f025843"] = {
					Visual = "f26bd2f5-34a0-435c-93c2-7a40f9d577fa",
					Sheathed = "8f9e56cf-dd16-4c31-9bc7-6f6acb9cc6c3",
				},
			}
		},
		Pistols = {
			--Pistols that are weight painted to the hand, specifically for shooting animations
			Shoot = {
				["94838d55-d5e6-4115-b736-b8b26f321003"] = {
					Dwarf = {Male = "ae2df405-c25f-4eb2-8df0-9003710b23d8", Female = "e15430cf-e638-49ca-9eec-b16495135ac6"},
					Elf = {Male = "92f3f4df-e302-45a3-9b05-23e4e514dd56", Female = "0c619254-d225-46d2-aa12-382875dd62e9"},
					Human = {Male = "df1d0006-dc11-4b4e-8f15-1b3d99ec3f21", Female = "f56ed8f8-f6e8-49a8-a43b-6a5fe4dcc376"},
					Lizard = {Male = "9e04cf00-d793-4684-a76f-340eb45a5ebb", Female = "a3e3fa6d-af4d-4e6a-8328-555aa3754417"},
				}
			}
		}
	}
}

if UniqueVars == nil then UniqueVars = {} end

local defaultExperienceAmounts = {
	[0] = {Amount = 45, Required = 0},
	[1] = {Amount = 30, Required = 1000},
	[2] = {Amount = 20, Required = 3000},
	[3] = {Amount = 12, Required = 6000},
	[4] = {Amount = 0, Required = 12000},
	--[5] = {Amount = 0, Required = 36000},
}

Mastery = {
	---@type table<string, MasteryBonusData[]>
	Bonuses = {},
	BonusID = {},
	Params = {},
	Variables = {
		RankVariables = {
			--Updated from ExtraData values
			[0] = {Amount = 45, Required = 0},
			[1] = {Amount = 30, Required = 1000},
			[2] = {Amount = 20, Required = 3000},
			[3] = {Amount = 12, Required = 6000},
			[4] = {Amount = 0, Required = 12000},
		},
		MaxRank = 4,
		ThrowingMasteryItemTags = {"GRENADES", "LLWEAPONEX_Throwing"},
		---Characters/items that grant reduced mastery XP, and can do so outside of combat
		TrainingDummyTags = {"LLDUMMY_TrainingDummy", "TrainingDummy"},
	},
	PermanentMasteries = {
		LLWEAPONEX_ThrowingAbility = true
	},
	AdditionalRankText = {}
}
LeaveActionData = {}
Temp = {
	StatusSource = {},
	OriginalUniqueStats = {}
}

Skills = {
	Params = {},
	DamageParam = {},
	Damage = {},
	DamageFunctions = {},
	WarfareMeleeSkills = {},
	ScoundrelMeleeSkills = {},
	Data = {}
}

AttributeScaleTables = {
	NoMemory = {"Strength", "Finesse", "Intelligence", "Wits", "Constitution"},
	Default = {"Strength", "Finesse", "Intelligence"},
}

Tags = {
	TemplateToTag = {},
	WeaponTypeToTag = {},
	RangedWeaponTags = {},
	StatWordToTag = {},
	WeaponTypes = {},
	---Client-side
	---@type table<string, fun(character:EsvCharacter, skill:string, tag:string, tooltip:TooltipData):string,boolean>
	SkillBonusText = {},
	ExtraProperties = {
		LLWEAPONEX_PirateGloves_Equipped = true,
		LLWEAPONEX_InfinitePickpocket = true,
		LLWEAPONEX_Blunderbuss_Equipped = true,
		LLWEAPONEX_MagicMissileWand_Equipped = true,
		LLWEAPONEX_UniqueThrowingAxeA = true,
		LLWEAPONEX_PacifistsWrath_Equipped = true,
		LLWEAPONEX_AnatomyBook_Equipped = true,
		LLWEAPONEX_DeathEdge_Equipped = true,
		LLWEAPONEX_PowerGauntlets_Equipped = true,
		LLWEAPONEX_RunicCannon_Equipped = function (tag, item, tooltip)
			local max = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3, true)
			local energy = ClientVars.RunicCannonEnergy[item.NetID] or 0
			return Text.ItemTooltip.RunicCannonEnergy:ReplacePlaceholders(energy, max)
		end,
		LLWEAPONEX_RunicCannonWeapon_Equipped = true,
		LLWEAPONEX_DevilHand_Equipped = true,
	}
}

Origin = {
	-- S_Player_LLWEAPONEX_Harken_e446752a-13cc-4a88-a32e-5df244c90d8b
	Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
	-- S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6
	Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6",
}

OriginColors = {
	Korvash = {
		LadyC = 0xff1B1B1B,
		Default = 0xff303032
	}
}

NPC = {
	VendingMachine = "680d2702-721c-412d-b083-4f5e816b945a",
	BishopAlexander = "03e6345f-1bd3-403c-80e2-a443a74f6349",
	Dallis = "69b951dc-55a4-44b8-a2d5-5efedbd7d572",
	Slane = "c099caa6-1938-4b4f-9365-d0881c611e71",
	UniqueHoldingChest = "80976258-a7a5-4430-b102-ba91a604c23f",
	WeaponMaster = "3cabc61d-6385-4ae3-b38f-c4f24a8d16b5"
}

if not MODID then
	MODID = {}
end

MODID.DivinityUnleashed = "e844229e-b744-4294-9102-a7362a926f71"
MODID.EE2Core = "63bb9b65-2964-4c10-be5b-55a63ec02fa0"
MODID.ArmorMitigation = "edf1898c-d375-47e7-919a-11d5d44d1cca"
MODID.Origins = "1301db3d-1f54-4e98-9be5-5094030916e4"
MODID.Mimicry = "d9cac48f-1294-68f8-dd4d-b5ea38eaf2d6"

MODID.ArmorDisablingMods = {
	MODID.DivinityUnleashed,
	MODID.ArmorMitigation,
}

function ArmorSystemIsDisabled()
	for _,v in pairs(MODID.ArmorDisablingMods) do
		if Ext.Mod.IsModLoaded(v) then
			return true
		end
	end
	return false
end

Mods.LeaderLib.Import(Mods.WeaponExpansion)

Ext.Require("Shared/System/TestingSystem.lua")
Ext.Require("Shared/Mastery/Classes/_Init.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/Data/WeaponTypesTags.lua")
Ext.Require("Shared/Data/UnarmedWeaponStats.lua")
Ext.Require("Shared/Helpers/UnarmedHelpers.lua")
Ext.Require("Shared/Helpers/TagHelpers.lua")
Ext.Require("Shared/Damage/GameMathAlternatives.lua")
Ext.Require("Shared/Damage/AbilityBasedScaling.lua")
Ext.Require("Shared/Damage/SkillDamageFunctions.lua")
Ext.Require("Shared/Damage/GetSkillDamageHandler.lua")
Ext.Require("Shared/Damage/UnarmedScalingMath.lua")
Ext.Require("Shared/Damage/UnarmedDamageScaling.lua")
Ext.Require("Shared/Overrides/_Init.lua")
Ext.Require("Shared/SkillAPListener.lua")
Ext.Require("Shared/SharedDataHooks.lua")
Ext.Require("Shared/CustomSkillProperties.lua")

-- if Vars.DebugMode then
-- 	Ext.Require("Shared/Debug/GameMathTracing.lua")
-- end

RegisterLeaveActionPrefix("LLWEAPONEX")

local function SetupFemaleKorvash()
	Ext.IO.AddPathOverride("Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/CharacterCreation/OriginPresets/LLWEAPONEX_Korvash.lsx", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/LLWEAPONEX_Korvash_Female.lsx")
	Ext.IO.AddPathOverride("Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Globals/TestLevel_LL_WeaponExpansion/Characters/S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6.lsf", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/S_Player_LLWEAPONEX_Korvash_Female_3f20ae14-5339-4913-98f1-24476861ebd6.lsf")
	GameHelpers.VoiceMetaData.Register.ScholarFemale(Origin.Korvash)
end

--Ext.Stats.AddVoiceMetaData(_C().MyGuid, "h8b9b59e1ge00eg4d0bgb328gb18a298a9381", "Localization/English/Soundbanks/v7b6c1f26fe4e40bda5d0e6ff58cef4fe_h8b9b59e1ge00eg4d0bgb328gb18a298a9381.wem", 5.044792)

Ext.Events.SessionLoaded:Subscribe(function (e)
	-- local femaleKorvash = false--Ext.ExtraData.LLWEAPONEX_Origins_FemaleKorvashEnabled == 1
	-- if femaleKorvash then
	-- 	SetupFemaleKorvash()
	-- end
	GameHelpers.VoiceMetaData.Register.ScholarMale(Origin.Korvash)
	--Ext.Stats.AddVoiceMetaData("3f20ae14-5339-4913-98f1-24476861ebd6", "h8b9b59e1ge00eg4d0bgb328gb18a298a9381", "Localization/English/Soundbanks/v7b6c1f26fe4e40bda5d0e6ff58cef4fe_h8b9b59e1ge00eg4d0bgb328gb18a298a9381.wem", 5.044792)
	--Harken
	GameHelpers.VoiceMetaData.Register.WarriorMale(Origin.Harken)
end)

local function LoadExperienceVariables()
	local RankVariables = {}
	local maxRank = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_MaxRank", 4, true)
	local lastRankExpGain = 45
	local lastRequiredNextLevelExperience = 1000
	for i=0,maxRank+1,1 do
		local rankGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_ExperienceGain"..tostring(i), nil)
		if rankGain == nil then
			local defaultRankGain = defaultExperienceAmounts[i]
			if defaultRankGain ~= nil then
				rankGain = defaultRankGain.Amount
			else
				rankGain = lastRankExpGain / 2
			end
		end
		local requiredNextLevelExperience = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_RequiredExperience"..tostring(i), nil)
		if requiredNextLevelExperience == nil then
			local defaultRequiredNextLevelExperience = defaultExperienceAmounts[i]
			if defaultRequiredNextLevelExperience ~= nil then
				requiredNextLevelExperience = defaultRequiredNextLevelExperience.Required
			else
				lastRequiredNextLevelExperience = lastRequiredNextLevelExperience * 1.5
			end
		end
		RankVariables[i] = {
			Amount = rankGain,
			Required = requiredNextLevelExperience
		}
		lastRankExpGain = rankGain
		lastRequiredNextLevelExperience = requiredNextLevelExperience
	end
	--PrintDebug("[WeaponExpansion] Loaded mastery experience variables:")
	--PrintDebug("==========================")
	--PrintDebug(Common.Dump(RankVariables))
	--PrintDebug("==========================")

	Mastery.Variables.MaxRank = math.floor(maxRank)
	Mastery.Variables.RankVariables = RankVariables

	local farSightStatuses = {}

	for skill in GameHelpers.Stats.GetSkills(true) do
		if skill.Requirements ~= nil then
			for i,v in pairs(skill.Requirements) do
				if v.Param == "LLWEAPONEX_NoMeleeWeaponEquipped" then
					Skills.WarfareMeleeSkills[skill.Name] = true
					break
				elseif v.Param == "LLWEAPONEX_CannotUseScoundrelSkills" then
					Skills.ScoundrelMeleeSkills[skill.Name] = true
					break
				end
			end
		end
		if skill.SkillType == "Projectile" then
			if skill.Requirement == "RangedWeapon" and skill.ChanceToPierce <= 0
			and (skill.ForGameMaster == "Yes" or MasteryBonusManager.Vars.CrossbowProjectilePiercingSkills[skill.Using]) --Allow enemy versions of skills / derivatives
			then
				MasteryBonusManager.Vars.CrossbowProjectilePiercingSkills[skill.Name] = true
			end
		end
		if skill.Name == "Target_Farsight" then
			for _,v in pairs(skill.SkillProperties) do
				if v.Type == "Status" and v.StatusChance > 0 then
					table.insert(farSightStatuses, v.Action)
				end
			end
		end
	end

	farSightStatuses = TableHelpers.MakeUnique(farSightStatuses, true)
	local bonus = MasteryBonusManager.GetRankBonus("LLWEAPONEX_Bow", 4, "BOW_FARSIGHT")
	if bonus then
		bonus.Statuses = farSightStatuses
	end
end

---@return ModSettings
function GetSettings()
	return SettingsManager.GetMod(ModuleUUID, true, true)
end

Ext.Events.SessionLoaded:Subscribe(function(e)
	LoadExperienceVariables()
	EnableFeature("ApplyBonusWeaponStatuses")
	EnableFeature("FixChaosDamageDisplay")
	EnableFeature("FixCorrosiveMagicDamageDisplay")
	EnableFeature("FixRifleWeaponRequirement")
	EnableFeature("FixSkillTagRequirements")
	EnableFeature("FormatTagElementTooltips")
	EnableFeature("StatusParamSkillDamage")
	EnableFeature("TooltipGrammarHelper")
    EnableFeature("FixFarOutManSkillRangeTooltip")
    EnableFeature("ReplaceTooltipPlaceholders")
    EnableFeature("FixTooltipEmptySkillProperties")
end)

Ext.IO.AddPathOverride("Mods/Helaene_Class_Marauder_53ed8826-71d6-452a-b9e5-faef35da8628/CharacterCreation/ClassPresets/Class_Marauder.lsx", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/LLWEAPONEX_Helaene_Marauder.lsx")