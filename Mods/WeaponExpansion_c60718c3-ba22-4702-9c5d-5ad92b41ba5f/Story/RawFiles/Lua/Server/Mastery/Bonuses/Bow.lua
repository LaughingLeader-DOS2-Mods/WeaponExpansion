
---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function PinDownBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["BOW_DOUBLE_SHOT"] == true then
			-- Support for a mod making Pin Down shoot multiple arrows through the use of iterating tables.
			local shotBonus = false
			local isInCombat = CharacterIsInCombat(char) == 1
			if skillData.TotalTargetObjects ~= nil and skillData.TotalTargetObjects > 0 then
				for i,v in ipairs(skillData.TargetObjects) do
					local target = nil
					if isInCombat then
						local maxDist = Ext.StatGetAttribute(skill, "TargetRadius")
						local targets = MasteryBonusManager.GetClosestCombatEnemies(char, maxDist, true, 3, v)
						if #targets > 0 then
							target = Common.GetRandomTableEntry(targets)
						else
							target = v
						end
					end

					if target ~= nil then
						GameHelpers.ShootProjectile(char, target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", true)
						shotBonus = true
					else
						local x,y,z = GetPosition(v)
						y = y + 1.0
						GameHelpers.ShootProjectileAtPosition(char, x,y,z, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
						shotBonus = true
					end
				end
			end

			if not shotBonus and skillData.TotalTargetPositions ~= nil and skillData.TotalTargetPositions > 0 then
				local character = Ext.GetCharacter(char)
				local rot = character.Stats.Rotation
				local forwardVector = {
					-rot[7] * 1.25,
					0,
					-rot[9] * 1.25,
				}

				for i,v in ipairs(skillData.TargetPositions) do
					local target = nil
					local x,y,z = table.unpack(v)
					if isInCombat then
						local maxDist = Ext.StatGetAttribute(skill, "TargetRadius")
						local targets = MasteryBonusManager.GetClosestCombatEnemies(char, maxDist, true, 3, v)
						if #targets > 0 then
							target = Common.GetRandomTableEntry(targets)
						end
					end

					if target ~= nil then
						GameHelpers.ShootProjectile(char, target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", true)
					else
						x = x + forwardVector[1]
						z = z + forwardVector[3]
						GameHelpers.ShootProjectileAtPosition(char, x,y,z, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Projectile_PinDown", PinDownBonuses)
LeaderLib.RegisterSkillListener("Projectile_EnemyPinDown", PinDownBonuses)