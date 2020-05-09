
local statusAttributes = {
	"Ability",
	--"ActionPoints",
	--"Cooldown",
	"Damage Multiplier",
	"Damage Range",
	"Damage",
	"DamageType",
	"DeathType",
	"Distance Damage Multiplier",
	--"IsEnemySkill",
	--"IsMelee",
	"Level",
	--"Magic Cost",
	--"Memory Cost",
	--"OverrideMinAP",
	"OverrideSkillLevel",
	--"Range",
	--"SkillType",
	"Stealth Damage Multiplier",
	--"Tier",
	"UseCharacterStats",
	"UseWeaponDamage",
	"UseWeaponProperties",
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

local function StatusGetDescriptionParam(status, statusSource, target, param, ...)
	print(status.Name)
	LeaderLib.PrintDebug("[WeaponEx:StatusParams:StatusGetDescriptionParam] status("..TryPrintName(status, "Name")..") statusSource("..TryPrintName(statusSource, "Name")..") character("..TryPrintName(target, "Name")..") param("..tostring(param)..")")
	if param == "Skill" then
		local params = {...}
		LeaderLib.PrintDebug("params("..LeaderLib.Common.Dump(params)..")")
		if params[2] == "Damage" then
			local skill = params[1]
			if skill ~= nil then
				local skillSource = statusSource
				if skillSource == nil then
					skillSource = target
				end
				local damageSkillProps = Skills.PrepareSkillProperties(skill)
				local damageRange = Game.Math.GetSkillDamageRange(skillSource, damageSkillProps)
				if damageRange ~= nil then
					local damageTexts = {}
					local totalDamageTypes = 0
					for damageType,damage in pairs(damageRange) do
						local min = damage[1]
						local max = damage[2]
						if min > 0 or max > 0 then
							if max == min then
								table.insert(damageTexts, LeaderLib.Game.GetDamageText(damageType, string.format("%i", max)))
							else
								table.insert(damageTexts, LeaderLib.Game.GetDamageText(damageType, string.format("%i-%i", min, max)))
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
		end
	end
end
Ext.RegisterListener("StatusGetDescriptionParam", StatusGetDescriptionParam)

function GetStatusTooltipText(character, status)

end