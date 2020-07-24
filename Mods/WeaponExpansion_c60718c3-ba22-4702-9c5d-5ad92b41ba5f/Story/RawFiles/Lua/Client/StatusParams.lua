
local statusAttributes = {
	"Level",
	"Using",
	"StatusType",
	"Icon",
	"DisplayName",
	"DisplayNameRef",
	"Description",
	"DescriptionRef",
	"DescriptionParams",
	"OverrideDefaultDescription",
	"FormatColor",
	"SavingThrow",
	"IsChanneled",
	"Instant",
	"StatusEffect",
	"StatusEffectOverrideForItems",
	"StatusEffectOnTurn",
	"MaterialType",
	"Material",
	"MaterialApplyBody",
	"MaterialApplyArmor",
	"MaterialApplyWeapon",
	"MaterialApplyNormalMap",
	"MaterialFadeAmount",
	"MaterialOverlayOffset",
	"MaterialParameters",
	"HealingEvent",
	"HealStat",
	"HealType",
	"HealValue",
	"StatsId",
	"IsInvulnerable",
	"IsDisarmed",
	"StackId",
	"StackPriority",
	"AuraRadius",
	"AuraSelf",
	"AuraAllies",
	"AuraEnemies",
	"AuraNeutrals",
	"AuraItems",
	"AuraFX",
	"ImmuneFlag",
	"CleanseStatuses",
	"MaxCleanseCount",
	"ApplyAfterCleanse",
	"SoundStart",
	"SoundLoop",
	"SoundStop",
	"DamageEvent",
	"DamageStats",
	"DeathType",
	"DamageCharacters",
	"DamageItems",
	"DamageTorches",
	"FreezeTime",
	"SurfaceChange",
	"PermanentOnTorch",
	"AbsorbSurfaceType",
	"AbsorbSurfaceRange",
	"Skills",
	"BonusFromAbility",
	"Items",
	"OnlyWhileMoving",
	"DescriptionCaster",
	"DescriptionTarget",
	"WinBoost",
	"LoseBoost",
	"WeaponOverride",
	"ApplyEffect",
	"ForGameMaster",
	"ResetCooldowns",
	"ResetOncePerCombat",
	"PolymorphResult",
	"DisableInteractions",
	"LoseControl",
	"AiCalculationSkillOverride",
	"HealEffectId",
	"ScaleWithVitality",
	"VampirismType",
	"BeamEffect",
	"HealMultiplier",
	"InitiateCombat",
	"Projectile",
	"Radius",
	"Charges",
	"MaxCharges",
	"DefendTargetPosition",
	"TargetConditions",
	"Toggle",
	"LeaveAction",
	"DieAction",
	"PlayerSameParty",
	"PlayerHasTag",
	"PeaceOnly",
	"Necromantic",
	"RetainSkills",
	"BringIntoCombat",
	"ApplyStatusOnTick",
	"IsResistingDeath",
	"TargetEffect",
	"DamagePercentage",
	"ForceOverhead",
	"TickSFX",
	"ForceStackOverwrite",
	"FreezeCooldowns",
}

---@param statusName string
---@return StatEntryStatusData
local function PrepareStatusProperties(statusName)
	if statusName ~= nil and statusName ~= "" then
		local status = {Name = statusName}
		for i,v in pairs(statusAttributes) do
			status[v] = Ext.StatGetAttribute(statusName, v)
		end
		return status
	end
	return nil
end

local function TryPrintName(obj, prop)
	local b,result = pcall(function()
		return tostring(obj[prop])
	end)
	if b then return result end
	return tostring(obj)
end

---@param status EsvStatus
---@param statusSource EsvGameObject
---@param target StatCharacter
---@param param string
function StatusGetDescriptionParam(status, statusSource, target, param, ...)
	if param == "Skill" then
		local params = {...}
		if params[2] == "Damage" then
			local skill = params[1]
			if skill ~= nil then
				local skillSource = statusSource or target
				local damageSkillProps = ExtenderHelpers.CreateSkillTable(skill)
				local damageRange = Game.Math.GetSkillDamageRange(skillSource, damageSkillProps)
				if damageRange ~= nil then
					local damageTexts = {}
					local totalDamageTypes = 0
					for damageType,damage in pairs(damageRange) do
						local min = damage[1]
						local max = damage[2]
						if min > 0 or max > 0 then
							if max == min then
								table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i", max)))
							else
								table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i-%i", min, max)))
							end
						end
						totalDamageTypes = totalDamageTypes + 1
					end
					if totalDamageTypes > 0 then
						if totalDamageTypes > 1 then
							return LeaderLib.Common.StringJoin(", ", damageTexts)
						else
							return damageTexts[1]
						end
					end
				end
			end
		else
			local skillName = params[1]
			local attribute = params[2]
			if skillName ~= nil and attribute ~= nil then
				local value = Ext.StatGetAttribute(skillName, attribute)
				if value ~= nil then
					if type(value) == "number" then
						return math.tointeger(value)
					else
						return tostring(value)
					end
				end
			end
		end
		return ""
	end
end
Ext.RegisterListener("StatusGetDescriptionParam", StatusGetDescriptionParam)

function GetStatusTooltipText(character, statusName)
	local status = PrepareStatusProperties(statusName)
	if status ~= nil then
		---@type string
		local name = Ext.GetTranslatedStringFromKey(status.DisplayName)
		local description = Ext.GetTranslatedStringFromKey(status.Description)
		if status.DescriptionParams ~= nil and status.DescriptionParams ~= "" then
			for i,param in status.DescriptionParams:gmatch("%[%d%]") do
				Ext.Print(status, param)
			end
		end
		return string.format("<p align='center'><font size='24'>%s</font></p><img src='Icon_Line' width='350%%'><br>%s", name:upper(), description)
	else
		Ext.PrintError("[WeaponExpansion:GetStatusTooltipText] No status for name ("..statusName..")")
	end
end