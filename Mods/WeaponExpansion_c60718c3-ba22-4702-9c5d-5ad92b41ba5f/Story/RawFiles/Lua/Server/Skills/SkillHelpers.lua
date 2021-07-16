local SkillSlots = {}

function SaveSkillSlot(char, skill)
	if SkillSlots[char] == nil then
		SkillSlots[char] = {}
	end
	SkillSlots[char][skill] = NRD_SkillBarFindSkill(char, skill)
end

function RestoreSkillSlot(char, previousSkill, replacementSkill)
	if SkillSlots[char] ~= nil then
		local nextSlot = SkillSlots[char][previousSkill]
		if nextSlot ~= nil then
			local currentSlot = NRD_SkillBarFindSkill(char, replacementSkill)
			NRD_SkillBarClear(char, currentSlot)
			NRD_SkillBarSetSkill(char, nextSlot, replacementSkill)
			SkillSlots[char][previousSkill] = nil
		end
	end
end

---Just a shortcut for exploding a skill with "Enemy Only" set to true, so only enemies or allies with friendly fire are hit.
---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
---@param playCastEffects boolean|nil
---@param playTargetEffects boolean|nil
---@param extraParams table|nil
function ExplodeSkill(target, skill, source, extraParams, playCastEffects, playTargetEffects)
	GameHelpers.Skill.Explode(target, skill, source, nil, true, playCastEffects, playTargetEffects, extraParams)
end

---@param chance integer
---@param onlyOnce boolean|nil If true, don't roll a second time if the first failed.
function BonusRoll(chance, onlyOnce)
	if Ext.Random(1,999) <= chance then
		return true
	elseif not onlyOnce and (Ext.Random(1,0) == 1 and Ext.Random(1,999) <= chance) then
		return true
	end
	return false
end