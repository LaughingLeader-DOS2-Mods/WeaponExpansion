
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
	--"WinBoost",
	--"LoseBoost",
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

end
Ext.RegisterListener("StatusGetDescriptionParam", StatusGetDescriptionParam)

function GetStatusTooltipText(character, statusName)
	local status = PrepareStatusProperties(statusName)
	if status ~= nil then
		---@type string
		local name,_ = Ext.GetTranslatedStringFromKey(status.DisplayName)
		local description,_ = Ext.GetTranslatedStringFromKey(status.Description)
		if status.DescriptionParams ~= nil and status.DescriptionParams ~= "" then
			local descParams = StringHelpers.Split(status.DescriptionParams, ";")
			for paramText in string.gmatch(description, "%[%d+%]") do
				local paramNumText = paramText:gsub("%[", ""):gsub("%]", "")
				local paramNum = tonumber(paramNumText)
				local paramKey = descParams[paramNum]
				if paramNum ~= nil and paramKey ~= nil then
					if string.find(paramKey, ":Damage") and string.find(paramKey, "Skill:") then
						paramKey = "["..string.gsub(paramKey, ":Damage", ""):gsub("Skill:", "SkillDamage:").."]"
					end
					local paramValue = GameHelpers.Tooltip.ReplacePlaceholders(paramKey, character)
					description = string.gsub(description, paramText:gsub("%[", "%%["):gsub("%]", "%%]"), paramValue)
				end
			end
		end
		return string.format("<p align='center'><font size='24'>%s</font></p><img src='Icon_Line' width='350%%'><br>%s", name:upper(), description)
	else
		Ext.PrintError("[WeaponExpansion:GetStatusTooltipText] No status for name ("..statusName..")")
	end
end