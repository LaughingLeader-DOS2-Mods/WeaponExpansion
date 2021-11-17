local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 4, {
	
})

function GainThrowingMasteryXP(uuid, target)
	if IsPlayer(uuid) then
		MasterySystem.GrantWeaponSkillExperience(uuid, target, "LLWEAPONEX_ThrowingAbility")
	end
end

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function OnBalrinAxeThrow(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		GainThrowingMasteryXP(char, data.Target)
	end
end
RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A", OnBalrinAxeThrow)
RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", OnBalrinAxeThrow)


---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function OnThrowWeapon(skill, char, state, data)
	if state == SKILL_STATE.USED then
		local mainhand = StringHelpers.GetUUID(CharacterGetEquippedItem(char, "Weapon"))
		local offhand = StringHelpers.GetUUID(CharacterGetEquippedItem(char, "Shield"))
		PersistentVars.SkillData.ThrowWeapon[char] = {
			Weapon = mainhand,
			Shield = offhand
		}
		Osi.DB_LLWEAPONEX_Throwing_Temp_MovingObjectWeapon_Waiting(char)
	elseif state == SKILL_STATE.PROJECTILEHIT then
		if not StringHelpers.IsNullOrEmpty(data.Target) then
			if ObjectIsCharacter(data.Target) == 1 then
				DeathManager.ListenForDeath("ThrowWeapon", data.Target, char, 500)
			end
	
			local mainWeapon = nil
			local offhandWeapon = nil
			
			local weaponData = PersistentVars.SkillData.ThrowWeapon[char]
			if weaponData ~= nil then
				if not StringHelpers.IsNullOrEmpty(weaponData.Weapon) then
					mainWeapon = Ext.GetItem(weaponData.Weapon).Stats
				end
				if not StringHelpers.IsNullOrEmpty(weaponData.Shield) then
					local item = Ext.GetItem(weaponData.Shield)
					if item.ItemType == "Weapon" then
						offhandWeapon = item.Stats
					end
				end
			end
	
			GameHelpers.Damage.ApplySkillDamage(Ext.GetCharacter(char), data.Target, "Projectile_LLWEAPONEX_ThrowWeapon_ApplyDamage", HitFlagPresets.GuaranteedWeaponHit, mainWeapon, offhandWeapon, true)
		else
			PersistentVars.SkillData.ThrowWeapon[char] = nil
		end
	end
end
RegisterSkillListener("Projectile_LLWEAPONEX_ThrowWeapon", OnThrowWeapon)
RegisterSkillListener("Projectile_LLWEAPONEX_ThrowWeapon_Enemy", OnThrowWeapon)

DeathManager.RegisterListener("ThrowWeapon", function(target, attacker, targetDied)
	local data = PersistentVars.SkillData.ThrowWeapon[attacker]
	if data ~= nil then
		if targetDied then
			if not StringHelpers.IsNullOrEmpty(data.Weapon) then
				NRD_CharacterEquipItem(attacker, data.Weapon, "Weapon", 0, 0, 1, 1)
			end
			if not StringHelpers.IsNullOrEmpty(data.Shield) then
				NRD_CharacterEquipItem(attacker, data.Shield, "Shield", 0, 0, 1, 1)
			end
		end
		PersistentVars.SkillData.ThrowWeapon[attacker] = nil
	end
end)