RegisterStatusListener("StatusApplied", "LLWEAPONEX_BASILUS_HIT", function(target, status, source)
	local min = math.ceil(Ext.ExtraData.LLWEAPONEX_BasilusDagger_MinTurns or 2)
	local max = math.ceil(Ext.ExtraData.LLWEAPONEX_BasilusDagger_MaxTurns or 3)
	local duration = Ext.Random(min,max) * 6.0
	if HasActiveStatus(target, "LLWEAPONEX_BASILUS_HAUNTED") == 0 then
		ObjectSetFlag(target, "LLWEAPONEX_BasilusDagger_ListenForAction", 0)
		ApplyStatus(target, "LLWEAPONEX_BASILUS_HAUNTED", duration, 0, source)
	else
		local handle = NRD_StatusGetHandle(target, "LLWEAPONEX_BASILUS_HAUNTED")
		local statusObj = Ext.GetStatus(target, handle)
		if statusObj ~= nil then
			if statusObj.CurrentLifeTime < duration then
				statusObj.CurrentLifeTime = duration
				statusObj.RequestClientSync = true
			end
		end
	end
end)

function Basilus_OnTargetActionTaken(target)
	local handle = NRD_StatusGetHandle(target, "LLWEAPONEX_BASILUS_HAUNTED")
	if handle ~= nil then
		local statusObj = Ext.GetStatus(target, handle)
		if statusObj ~= nil and statusObj.StatusSourceHandle ~= nil then
			local source = Ext.GetCharacter(statusObj.StatusSourceHandle)
			if source ~= nil then
				local backstab = 0
				local chance = math.ceil(Ext.ExtraData.LLWEAPONEX_BasilusDagger_BackstabChance or 40)
				if chance >= 100 then
					backstab = 1
				elseif chance > 0 then
					local roll = Ext.Random(0,100)
					if roll > 0 and roll <= chance then
						backstab = 1
					end
				end
				local text = GameHelpers.GetStringKeyText("LLWEAPONEX_CombatLog_BasilusDaggerHauntedDamage", "<font color='#CC00FF'>[1] was haunted by the Blade of Basilus!</font>")
				text = string.gsub(text, "%[1%]", Ext.GetCharacter(target).DisplayName)
				GameHelpers.UI.CombatLog(text)
				if backstab == 1 then
					CharacterStatusText(target, "LLWEAPONEX_StatusText_BasilusHauntedDamage_Backstab")
				else
					CharacterStatusText(target, "LLWEAPONEX_StatusText_BasilusHauntedDamage_Normal")
				end
				GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_BasilusDagger_HauntedDamage", HitFlagPresets.GuaranteedWeaponHit:Append({Backstab=backstab,CriticalHit=backstab}))
			end
		end
	end
	ObjectClearFlag(target, "LLWEAPONEX_BasilusDagger_ListenForAction", 0)
end

-- BasicAttackManager.RegisterListener("OnStart", function(attacker, owner, target)
-- 	if ObjectGetFlag(attacker, "LLWEAPONEX_BasilusDagger_ListenForAction") == 1 then
-- 		Basilus_OnTargetActionTaken(attacker)
-- 	end
-- end)