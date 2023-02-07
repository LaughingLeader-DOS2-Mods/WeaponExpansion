UniqueVars.VictoryEvilTags = {
	"VOIDWOKEN",
	"DEMON",
	"DEMONS",
	"MAGISTER",
	"UNDEAD",
	"RECORD_ANTAGONIST",
	"LLDUMMY_TrainingDummy",
}

Tags.ExtraProperties.LLWEAPONEX_SwordofVictory_Equipped = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_SwordofVictory_EvilSlayer", "Deal +[ExtraData:LLWEAPONEX_SwordofVictory_EvilSlayerDamageMultiplier]% Weapon Damage When Slaying Evil")

---@param target EsvCharacter|EclCharacter
local function _IsEvil(target)
	for i=1,#UniqueVars.VictoryEvilTags do
		if target:HasTag(UniqueVars.VictoryEvilTags[i]) then
			return true
		end
	end
	return false
end

if not Vars.IsClient then
	local _justPlayedSound = {}

	--Leadership now redirects [ExtraData:LLWEAPONEX_SwordofVictory_DamageRedirectionAmount]% of damage taken by allies to you.

	--- @param target EsvCharacter|EsvItem
	--- @param attacker EsvCharacter|EsvItem
	--- @param data HitData
	function SwordofVictory_OnHit(target, attacker, data)
		local leadership = target:GetStatus("LEADERSHIP")
		if leadership and Ext.Utils.IsValidHandle(leadership.StatusSourceHandle) then
			local leader = GameHelpers.TryGetObject(leadership.StatusSourceHandle)
			if leader and GameHelpers.Ext.ObjectIsCharacter(leader)
			and leader.MyGuid ~= attacker.MyGuid
			and GameHelpers.CharacterOrEquipmentHasTag(leader, "LLWEAPONEX_SwordofVictory_Equipped")
			and GameHelpers.Character.CanAttackTarget(leader, attacker, false)
			then
				local mult = GameHelpers.GetExtraData("LLWEAPONEX_SwordofVictory_DamageRedirectionAmount", 15)
				if mult > 0 then
					local damageMult = math.min(1.0, mult * 0.01)
					if damageMult > 0 then
						local preTotalDamage = data.Damage
						local redirectedDamage = data:RedirectDamage(leader.MyGuid, damageMult)
						local postTotalDamage = data.Damage
						EffectManager.PlayEffect("RS3_FX_GP_Status_Retaliation_01", leader, {Bone="Dummy_BodyFX"})
						EffectManager.PlayEffect("RS3_FX_GP_Status_Retaliation_Beam_01", target, {Bone="Dummy_BodyFX", BeamTargetBone="Dummy_BodyFX", BeamTarget=leader.Handle})
						SignalTestComplete("LLWEAPONEX_Victory_DamageRedirected")
						local damageReduced = string.format("%i => %i", preTotalDamage, postTotalDamage)
						local name = GameHelpers.GetDisplayName(leader)
						local text = GameHelpers.Tooltip.ReplacePlaceholders(Text.CombatLog.VictoryDamageRedirected:ReplacePlaceholders(GameHelpers.Tooltip.FormatDamageList(redirectedDamage), GameHelpers.GetDisplayName(target), name, damageReduced))
						CombatLog.AddCombatText(text)
					end
				end
			end
		end
		if GameHelpers.Ext.ObjectIsCharacter(target)
		and data:IsFromWeapon()
		and GameHelpers.CharacterOrEquipmentHasTag(attacker, "LLWEAPONEX_SwordofVictory_Equipped")
		---@cast target EsvCharacter
		and _IsEvil(target)
		then
			local mult = GameHelpers.GetExtraData("LLWEAPONEX_SwordofVictory_EvilSlayerDamageMultiplier", 10)
			if mult > 0 then
				data:MultiplyDamage(1 + Ext.Utils.Round(mult * 0.01))
				SignalTestComplete("LLWEAPONEX_Victory_EvilSlayerDamageBonus")
				EffectManager.PlayEffect("RS3_FX_GP_Status_Firebrand_Subject_Weapon_01", attacker)
				--local pos = target.WorldPos
				--pos[2] = pos[2] + (target.AI.AIBoundsHeight * 0.5)
				--EffectManager.PlayEffectAt("RS3_FX_GP_Status_Firebrand_Subject_Hand_01", pos)
				EffectManager.PlayEffectAt("RS3_FX_GP_Status_Firebrand_Subject_Hand_01", data.HitStatus.ImpactPosition)
				local targetGUID = target.MyGuid
				if not _justPlayedSound[targetGUID] then
					PlaySound(targetGUID, "Skill_Summon_IncarnateRangedAttack_Cast_Fire")
					--PlaySound(targetGUID, "GP_Combat_DeathType_Fire")
					--PlaySound(target.MyGuid, "Skill_Fire_FireInfusion_Impact")
					_justPlayedSound[targetGUID] = true
				end
				local timerName = string.format("LLWEAPONEX_VictoryBonusDamageSoundBuffer_%s", targetGUID)
				Timer.Cancel(timerName)
				Timer.StartOneshot(timerName, 500, function (e)
					_justPlayedSound[targetGUID] = nil
				end)
			end
		end
	end

	WeaponExTesting.RegisterUniqueTest("victory", function (test)
		local char1,char2,dummy,cleanup = WeaponExTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, "Class_Knight_Lizards", nil, false)
		test.Cleanup = cleanup
		test:Wait(250)
		local weapon = GameHelpers.Item.CreateItemByStat("WPN_UNIQUE_LLWEAPONEX_Sword_1H_SwordofVictory_A")
		test:Wait(250)
		SetTag(weapon, "LLWEAPONEX_Testing")
		NRD_CharacterEquipItem(char1, weapon, "Weapon", 0, 0, 1, 1)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		SetFaction(char1, "PVP_1")
		SetFaction(dummy, "PVP_1")
		SetFaction(char2, "PVP_2")
		CharacterAddAbility(char1, "Leadership", 10)
		-- CharacterSetFightMode(char1, 1, 1)
		-- CharacterSetFightMode(char2, 1, 1)
		test:Wait(250)
		CharacterSetTemporaryHostileRelation(char1, char2)
		CharacterSetTemporaryHostileRelation(dummy, char2)
		test:Wait(250)
		test:AssertEquals(GameHelpers.CharacterOrEquipmentHasTag(char1, "LLWEAPONEX_SwordofVictory_Equipped"), true, "Missing 'LLWEAPONEX_SwordofVictory_Equipped' tag on char1")
		test:AssertEquals(GameHelpers.Character.CanAttackTarget(char1, char2, false), true, "char2 is not an enemy of char1")
		test:Wait(250)
		CharacterAttack(char2, dummy)
		test:WaitForSignal("LLWEAPONEX_Victory_DamageRedirected", 5000)
		test:AssertGotSignal("LLWEAPONEX_Victory_DamageRedirected")
		test:Wait(2000)
		CharacterAttack(char2, dummy)
		test:WaitForSignal("LLWEAPONEX_Victory_DamageRedirected", 5000)
		test:AssertGotSignal("LLWEAPONEX_Victory_DamageRedirected")
		test:Wait(2000)
		SetTag(char2, "DEMON")
		test:Wait(250)
		CharacterAttack(char1, char2)
		test:WaitForSignal("LLWEAPONEX_Victory_EvilSlayerDamageBonus", 5000)
		test:AssertGotSignal("LLWEAPONEX_Victory_EvilSlayerDamageBonus")
		test:Wait(500)
		test.SignalSuccess = nil
		--Make sure the damage isn't redirected outside of Leadership range
		local range = GameHelpers.GetExtraData("LeadershipRange", 8)
		local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, range + 1))
		TeleportToPosition(char1, x,y,z, "", 0, 1)
		test:Wait(2000)
		CharacterAttack(char2, dummy)
		test:Wait(2000)
		test:AssertNotGotSignal("LLWEAPONEX_Victory_DamageRedirected")
		test:Wait(2000)
		return true
	end)

	EquipmentManager.Events.UnsheathedChanged:Subscribe(function (e)
		if GameHelpers.Character.IsPlayer(e.Character) then
			if e.Unsheathed then
				local evilObjects = {}
				for _,v in pairs(e.Character:GetNearbyCharacters(12.0)) do
					if v ~= e.Character.MyGuid then
						local obj = GameHelpers.TryGetObject(v)
						if obj and _IsEvil(obj) or obj.PlayerCustomData and obj.PlayerCustomData.OriginName == "Fane" then
							evilObjects[#evilObjects+1] = obj.NetID
							CharacterStatusText(obj.MyGuid, "Evil")
							--EffectManager.PlayClientEffect("RS3_FX_UI_Exclamation_Mark_01:Dummy_OverheadFX", obj, nil, e.Character)
							--Mods.LeaderLib.EffectManager.PlayClientEffect("RS3_FX_UI_Exclamation_Mark_01:Dummy_OverheadFX", me.MyGuid)
						end
					end
				end
				if #evilObjects > 0 then
					--GameHelpers.Net.PostToUser(e.Character, "LLWEAPONEX_Victory_PlayClientEffects", {Targets=evilObjects})
				end
			else
				GameHelpers.Net.PostToUser(e.Character, "LLWEAPONEX_Victory_StopClientEffects")
			end
		end
	end, {MatchArgs={Tag="LLWEAPONEX_SwordofVictory_Equipped"}})
else
	local _effects = {}
	Ext.RegisterNetListener("LLWEAPONEX_Victory_PlayClientEffects", function (channel, payload, user)
		local data = Common.JsonParse(payload)
		if data and data.Targets then
			for _,netid in pairs(data.Targets) do
				local obj = GameHelpers.TryGetObject(netid)
				if obj then
					VisualManager.CreateClientEffect("RS3_FX_UI_Exclamation_Mark_01", obj, {})
				end
			end
		end
	end)

	Ext.RegisterNetListener("LLWEAPONEX_Victory_StopClientEffects", function (channel, payload, user)
		
	end)
end