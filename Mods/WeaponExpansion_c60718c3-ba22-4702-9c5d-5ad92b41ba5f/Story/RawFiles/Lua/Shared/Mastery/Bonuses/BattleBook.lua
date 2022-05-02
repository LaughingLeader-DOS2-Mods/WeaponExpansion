local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 1, {
	rb:Create("BATTLEBOOK_CONCUSSION", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_BasicAttackConcussion", "<font color='#99AACC'>Basic attacks have a [ExtraData:LLWEAPONEX_MB_BattleBook_ConcussionChance]% chance to give the target a Concussion for [ExtraData:LLWEAPONEX_MB_BattleBook_ConcussionTurns] turn(s).</font>")
	}):RegisterOnWeaponTagHit(MasteryID.BattleBook, function(tag, attacker, target, data, targetIsObject, skill, self)
		if not skill then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ConcussionChance", 25.0)
			local turns = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ConcussionTurns", 1)
			if chance > 0 and turns > 0 then
				if chance >= 100 or Ext.Random(0,100) <= chance then
					GameHelpers.Status.Apply(target, "LLWEAPONEX_CONCUSSION", turns*6.0, 0, attacker, 1.0, false)
					PlaySound(target.MyGuid, "LLWEAPONEX_FFT_Dictionary_Book_Hit")
				end
			end
		end
	end),
	rb:Create("BATTLEBOOK_FIRST_AID", {
		Skills = {"Target_FirstAid", "Target_FirstAidEnemy"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_FirstAid", "<font color='#99AACC'>Medical book knowledge restores an additional <font color='#97FBFF'>[Stats:LLWEAPONEX_MASTERYBONUS_BATTLEBOOK_FIRST_AID:HealValue]% [Handle:h67a4c781g589ag4872g8c46g870e336074bd:Vitality]</font>.</font>"),
		Statuses = {"RESTED"},
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_BattleBook_FirstAid_Active", false),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Rested", "Duration increased by [ExtraData:LLWEAPONEX_MB_BattleBook_Rested_TurnBonus]")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			local turnBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Rested_TurnBonus", 1)
			data:ForEach(function(v, targetType, skillEventData)
				if turnBonus > 0 then
					SetTag(v, "LLWEAPONEX_BattleBook_FirstAid_Active")
				end
				ApplyStatus(v, "LLWEAPONEX_MASTERYBONUS_BATTLEBOOK_FIRST_AID", 0.0, 0, char)
			end)
		end
	end):RegisterStatusListener("Applied", function(target, status, source, bonuses)
		if bonuses.BATTLEBOOK_RESTED[source] == true then
			local turnBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Rested_TurnBonus", 1)
			if turnBonus > 0 then
				GameHelpers.Status.ExtendTurns(target, status, turnBonus, true, false)
			end
		end
	end):RegisterStatusListener("Removed", function(target, status)
		ClearTag(target, "LLWEAPONEX_BattleBook_FirstAid_Active")
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 2, {
	rb:Create("BATTLEBOOK_BLESS", {
		Skills = {"Target_Bless", "Target_EnemyBless"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Bless", "<font color='#99AACC'>Deep knowledge of sacred texts allows [Key:Target_Bless_DisplayName] to deal [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_BattleBook_BlessUndeadDamage] to enemy Undead.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			data:ForEach(function(v, targetType, skillEventData)
				if CharacterIsEnemy(v, char) == 1 and GameHelpers.Character.IsUndead(v) then
					GameHelpers.Damage.ApplySkillDamage(char, v, "Projectile_LLWEAPONEX_MasteryBonus_BattleBook_BlessUndeadDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
					CharacterStatusText(v, "LLWEAPONEX_StatusText_BattleBook_BlessDamage")
					RemoveStatus(v, "BLESSED")
				end
			end, data.TargetMode.Objects)
		end
	end),
	rb:Create("BATTLEBOOK_SCROLLS", {
		AllSkills = true,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Scrolls", "<font color='#99AACC'>Gain [ExtraData:LLWEAPONEX_MB_BattleBook_ScrollUseAPBonus] AP on use. Can only happen once per turn.</font>"),
		---@param self MasteryBonusData
		---@param skillOrStatus string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param data EsvStatus|StatEntrySkillData
		GetIsTooltipActive = function (self, skillOrStatus, character, tooltipType, data)
			--Kind of a hack where the ItemTooltip code will send this function the value "scroll" to tell it to display the bonus text
			if skillOrStatus ~= "scroll" or not character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP") then
				return false
			end
		end,
	}):RegisterOsirisListener("CharacterUsedItem", 2, "after", function(characterid, itemid)
		local character = GameHelpers.GetCharacter(characterid)
		local item = Ext.GetItem(itemid)
		if character and item 
		and not character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP")
		and GameHelpers.ItemHasTag(item, "SCROLLS")
		or (GameHelpers.Item.IsObject(item) and string.find(item.StatsId, "SCROLL_")) then
			local apBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ScrollUseAPBonus", 1)
			if apBonus ~= 0 then
				TurnEndRemoveTags["LLWEAPONEX_BattleBook_ScrollBonusAP"] = true
				SetTag(characterid, "LLWEAPONEX_BattleBook_ScrollBonusAP")
				CharacterAddActionPoints(characterid, apBonus)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 4, {
	
})