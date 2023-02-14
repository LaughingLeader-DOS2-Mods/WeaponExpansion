local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 4, {
	
})

if not Vars.IsClient then
	RegisterSkillListener({"Projectile_LLWEAPONEX_Throw_UniqueAxe_A", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand"}, function(skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			GainThrowingMasteryXP(char, data.Target)
		end
	end)
	
	RegisterSkillListener({"Projectile_LLWEAPONEX_ThrowWeapon", "Projectile_LLWEAPONEX_ThrowWeapon_Enemy"}, function(skill, char, state, data)
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
						mainWeapon = GameHelpers.GetItem(weaponData.Weapon).Stats
					end
					if not StringHelpers.IsNullOrEmpty(weaponData.Shield) then
						local item = GameHelpers.GetItem(weaponData.Shield)
						if item.ItemType == "Weapon" then
							offhandWeapon = item.Stats
						end
					end
				end
		
				GameHelpers.Damage.ApplySkillDamage(GameHelpers.GetCharacter(char, "EsvCharacter"), data.Target, "Projectile_LLWEAPONEX_ThrowWeapon_ApplyDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=true, MainWeapon=mainWeapon, OffhandWeapon=offhandWeapon})
			else
				PersistentVars.SkillData.ThrowWeapon[char] = nil
			end
		end
	end)

	DeathManager.OnDeath:Subscribe(function (e)
		local data = PersistentVars.SkillData.ThrowWeapon[e.SourceGUID]
		if data ~= nil then
			if e.Success then
				if not StringHelpers.IsNullOrEmpty(data.Weapon) then
					NRD_CharacterEquipItem(e.SourceGUID, data.Weapon, "Weapon", 0, 0, 1, 1)
				end
				if not StringHelpers.IsNullOrEmpty(data.Shield) then
					NRD_CharacterEquipItem(e.SourceGUID, data.Shield, "Shield", 0, 0, 1, 1)
				end
			end
			PersistentVars.SkillData.ThrowWeapon[e.SourceGUID] = nil
		end
	end, {MatchArgs={ID="ThrowWeapon"}})

	--Throwing Experience
	SkillManager.Register.Cast("All", function (e)
		if e.SourceItem and GameHelpers.ItemHasTag(e.SourceItem, Mastery.Variables.ThrowingMasteryItemTags)
		and MasterySystem.CanGainExperience(e.Character) then
			local primaryTarget = nil
			e.Data:ForEach(function (target, targetType, self)
				---@cast target Guid
				---Prioritize setting a boss as the primary target, since they grant more mastery XP
				if ObjectIsCharacter(target) == 1 and (not primaryTarget or IsBoss(target) == 1) then
					primaryTarget = target
				end
			end, e.Data.TargetMode.Objects)
			if primaryTarget then
				MasterySystem.GrantWeaponSkillExperience(e.Character, primaryTarget, MasteryID.Throwing)
			else
				--Gain xp just from throwing grenades/etc
				AddMasteryExperience(e.Character, MasteryID.Throwing, 0.25)
			end
		end
	end)
end