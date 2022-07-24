Main = {}
Debug = {
	MasteryTests = false,
	AddOriginsToParty = false,
	CreateOriginPresetEquipment = false
}
Math = { AbilityScaling = {}}
Text = {}

if SkillConfiguration == nil then SkillConfiguration = {} end

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
		MaxRank = 4
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
Vars = {
	GAME_STARTED = false,
	SEND_USER_ID = false,
	isInCharacterCreation = false,
	DebugMode = Ext.IsDeveloperMode() == true
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
		--LLWEAPONEX_SwordofVictory_Equipped = true,
	}
}

Origin = {
	-- S_Player_LLWEAPONEX_Harken_e446752a-13cc-4a88-a32e-5df244c90d8b
	Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
	-- S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6
	Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6",
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
		if Ext.IsModLoaded(v) then
			return true
		end
	end
	return false
end

---@type ModSettings
Settings = {}

Mods.LeaderLib.Import(Mods.WeaponExpansion)

Ext.Require("Shared/System/TestingSystem.lua")
Ext.Require("Shared/Mastery/Classes/_Init.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/Data/WeaponTypesTags.lua")
Ext.Require("Shared/Data/UnarmedWeaponStats.lua")
Ext.Require("Shared/Helpers/StatHelpers.lua")
Ext.Require("Shared/Helpers/UnarmedHelpers.lua")
Ext.Require("Shared/Helpers/TagHelpers.lua")
Ext.Require("Shared/Helpers/ExtenderHelpers.lua")
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
	Ext.AddPathOverride("Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/CharacterCreation/OriginPresets/LLWEAPONEX_Korvash.lsx", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/LLWEAPONEX_Korvash_Female.lsx")
	Ext.AddPathOverride("Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Globals/TestLevel_LL_WeaponExpansion/Characters/S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6.lsf", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/S_Player_LLWEAPONEX_Korvash_Female_3f20ae14-5339-4913-98f1-24476861ebd6.lsf")
	GameHelpers.VoiceMetaData.Register.ScholarFemale(Origin.Korvash)
end

Ext.RegisterListener("ModuleLoading", function()
	local femaleKorvash = false--Ext.ExtraData.LLWEAPONEX_Origins_FemaleKorvashEnabled == 1
	if femaleKorvash then
		SetupFemaleKorvash()
	else
		GameHelpers.VoiceMetaData.Register.ScholarMale(Origin.Korvash)
	end
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
					Skills.WarfareMeleeSkills[skill] = true
					break
				elseif v.Param == "LLWEAPONEX_CannotUseScoundrelSkills" then
					Skills.ScoundrelMeleeSkills[skill] = true
					break
				end
			end
		end
		if skill.SkillType == "Projectile" then
			if skill.Requirement == "RangedWeapon" and skill.ChanceToPierce <= 0
			and (skill.ForGameMaster == "Yes" or MasteryBonusManager.Vars.BowProjectilePiercingSkills[skill.Using]) --Allow enemy versions of skills / derivatives
			then
				MasteryBonusManager.Vars.BowProjectilePiercingSkills[skill.Name] = true
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

Ext.RegisterListener("SessionLoaded", function()
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
end)

Ext.AddPathOverride("Mods/Helaene_Class_Marauder_53ed8826-71d6-452a-b9e5-faef35da8628/CharacterCreation/ClassPresets/Class_Marauder.lsx", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/LLWEAPONEX_Helaene_Marauder.lsx")