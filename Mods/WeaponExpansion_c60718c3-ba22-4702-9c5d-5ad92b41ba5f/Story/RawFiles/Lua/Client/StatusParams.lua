local function StatusGetDescriptionParam(status, statusSource, target, param, ...)
	LeaderLib.PrintDebug("[WeaponEx:StatusParams:StatusGetDescriptionParam] status("..tostring(status["Name"])..") statusSource("..tostring(statusSource["Name"])..") character("..tostring(target["Name"])..") param("..tostring(param)..")")
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
								table.insert(damageTexts, LeaderLib.Game.GetDamageText(damageType, math.tointeger(min)))
							else
								table.insert(damageTexts, LLeaderLib.Game.GetDamageText(damageType, string.format("%i-%i", min, max)))
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