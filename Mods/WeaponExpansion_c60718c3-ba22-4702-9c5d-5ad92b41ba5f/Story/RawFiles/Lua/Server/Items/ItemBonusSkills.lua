local WeapontypeRequirements = {
	Sword = "MeleeWeapon",
	Club = "MeleeWeapon",
	Axe = "MeleeWeapon",
	Knife = {"DaggerWeapon", "MeleeWeapon"},
	Spear = "MeleeWeapon",
	Staff = {"StaffWeapon", "MeleeWeapon"},
	Bow = "RangedWeapon",
	Crossbow = "RangedWeapon",
	Rifle = {"RifleWeapon", "RangedWeapon"},
	--Wand = {"MeleeWeapon"},
}

local ItemBonusSkills = {
	MeleeWeapon = {},
	RangedWeapon = {},
	StaffWeapon = {},
	DaggerWeapon = {},
	RifleWeapon = {},
	ShieldWeapon = {},
}


-- local tierValue = {
--     None = 0,
--     Starter = 1,
--     Novice = 2,
--     Adept = 3,
--     Master = 4,
-- }

local bonusSkillAllowedTiers = {
    Starter = true,
    Novice = true,
    Adept = true,
}

local ignore_skill_names = {
	Enemy = true,
	Quest = true,
	QUEST = true,
	NPC = true
}

local function CanAddBonusSkill(stat, tier)
	if Ext.StatGetAttribute(stat, "ForGameMaster") == "Yes" then
		if bonusSkillAllowedTiers[tier] ~= true then
			return false
		end
		if Ext.StatGetAttribute(stat, "IsEnemySkill") == "Yes" then
			return false
		end
		for str,b in pairs(ignore_skill_names) do
			if string.find(stat, str) then
				return false
			end
		end
		return true
	else
		return false
	end
end

local function LoadBonusSkills()
    for i,skill in pairs(Ext.GetStatEntries("SkillData")) do
		local requirement = Ext.StatGetAttribute(skill, "Requirement")
		if not StringHelpers.IsNullOrEmpty(requirement) and requirement ~= "None" then 
			local tier = Ext.StatGetAttribute(skill, "Tier")
			if LeaderLib.PersistentVars["OriginalSkillTiers"] ~= nil then
				local originalTier = LeaderLib.PersistentVars["OriginalSkillTiers"][skill]
				if originalTier ~= nil then
					tier = originalTier
				end
			end
			if CanAddBonusSkill(skill) then
				table.push(ItemBonusSkills[requirement], {Skill = skill, Tier = tier})
			end
		end
	end
	print("[WeaponExpansion] Item bonus skills:", Ext.JsonStringify(ItemBonusSkills))
end

function RollForBonusSkill(item,stat,itemType,rarity)
	-- Legendary BoostType deltamods only start showing up at Epic rarity and above.
	local rarityVal = Data.RarityEnum[rarity]
	if rarityVal >= Data.RarityEnum.Epic then
		local skills = NRD_ItemGetPermanentBoostString(item, "Skills") or ""
		local nextSkill = nil
		if itemType == "Weapon" then
			local requirements = WeapontypeRequirements[Ext.StatGetAttribute(stat, "WeaponType")]
			if requirements ~= nil then
				local chance = Ext.ExtraData["LLWEAPONEX_Loot_BonusSkillChance_Weapon"] or 20
				if rarityVal > Data.RarityEnum.Epic then
					chance = chance + ((rarityVal - Data.RarityEnum.Epic) * 10)
				end
				if GameHelpers.Roll(chance) then
					local skillsTable = nil
					if type(requirements) == "table" then
						skillsTable = ItemBonusSkills[requirements[1]]
						if skillsTable == nil or #skillsTable == 0 then
							skillsTable = ItemBonusSkills[requirements[2]]
						end
					else
						skillsTable = ItemBonusSkills[requirements]
					end
					if skillsTable ~= nil and #skillsTable > 0 then
						local ranSkill = Common.GetRandomTableEntry(skillsTable)
						if ranSkill ~= nil and not string.find(skills, nextSkill) then
							nextSkill = ranSkill
						end
					end
				end
			end
		elseif itemType == "Shield" then
			local chance = Ext.ExtraData["LLWEAPONEX_Loot_BonusSkillChance_Shield"] or 30
			if GameHelpers.Roll(chance) then
				local ranSkill = Common.GetRandomTableEntry(ItemBonusSkills.ShieldWeapon)
				if ranSkill ~= nil and not string.find(skills, nextSkill) then
					nextSkill = ranSkill
				end
			end
		end
		if nextSkill ~= nil then
			local skills = NRD_ItemGetPermanentBoostString(item, "Skills")
			if not StringHelpers.IsNullOrEmpty(skills) then
				skills = skills .. ";" .. nextSkill
			else
				skills = nextSkill
			end
			print("[WeaponExpansion:RollForBonusSkill] Adding bonus skill "..nextSkill.." to item",item,skills)
			NRD_ItemSetPermanentBoostString(item, "Skills", skills)
		end
	end
end

return {
	Init = LoadBonusSkills()
}