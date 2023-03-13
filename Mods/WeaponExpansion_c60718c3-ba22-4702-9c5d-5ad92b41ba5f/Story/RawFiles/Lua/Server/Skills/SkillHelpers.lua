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

---Roll two times.
---@param chance integer
---@param onlyOnce boolean|nil If true, don't roll a second time if the first failed.
---@param minValue integer|nil Defaults to 1
---@param maxValue integer|nil Defaults to 999.
function BonusRoll(chance, onlyOnce, minValue, maxValue)
	if chance == 0 then
		return false
	end
	minValue = minValue or 1
	maxValue = maxValue or 999
	if Ext.Utils.Random(1,999) <= chance then
		return true
	elseif not onlyOnce and (Ext.Utils.Random(0,1) == 1 and Ext.Utils.Random(1,999) <= chance) then
		return true
	end
	return false
end