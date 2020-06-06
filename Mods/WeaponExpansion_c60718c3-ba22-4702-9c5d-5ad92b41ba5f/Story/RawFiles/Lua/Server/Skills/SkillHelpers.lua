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