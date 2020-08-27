--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param grid AiGrid
--- @param position number[]
--- @param radius number
Ext.RegisterListener("GetSkillAPCost", function (skill, character, grid, position, radius)
	if Ext.IsDeveloperMode() then
		local ap,elementalAffinity = Game.Math.GetSkillAPCost(skill, character, grid, position, radius)
		print(string.format("[GetSkillAPCost] (%s) AP(%i) ElementalAffinity(%s)", skill.Name, ap, elementalAffinity))
	end
end)