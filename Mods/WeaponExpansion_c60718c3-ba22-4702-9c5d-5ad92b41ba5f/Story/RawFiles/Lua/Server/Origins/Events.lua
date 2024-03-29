local function PlayFrostdyneLoopedEffect(x, y, z)
	local handle = PlayLoopEffectAtPosition("RS3_FX_UI_Exclamation_Mark_01", x, y, z)
	local removeEffectHandleFunc = nil
	removeEffectHandleFunc = function(item, character)
		if Uniques.Frostdyne:IsValid(item) then
			StopLoopEffect(handle)
			Uniques.Frostdyne:RemoveEventListener("ItemAddedToCharacter", removeEffectHandleFunc)
			Timer.Cancel("Timers_LLWEAPONEX_SlaneRewardExclamationEffect")
		end
	end
	Uniques.Frostdyne:AddEventListener("ItemAddedToCharacter", removeEffectHandleFunc)
	Timer.StartOneshot("Timers_LLWEAPONEX_SlaneRewardExclamationEffect", 5000, function()
		StopLoopEffect(handle)
		Uniques.Frostdyne:RemoveEventListener("ItemAddedToCharacter", removeEffectHandleFunc)
	end)
end

function FortJoyEvent(event)
	fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:FortJoyEvent]", event)
	if event == "AlexanderDefeated" then
		--Ext.Utils.Print(string.format("[FJ_AlexanderDefeated] Owner(%s) Alex(%s) Pos(%s)", Uniques.DivineBanner.Owner, NPC.BishopAlexander, Common.Dump(GameHelpers.GetCharacter(NPC.BishopAlexander).WorldPos)))
		local uuid = Uniques.DivineBanner:GetUUID(NPC.BishopAlexander)
		if uuid then
			local x,y,z = GetPosition(NPC.BishopAlexander)
			if x == nil then
				x,y,z = GetPosition(NPC.Dallis)
			end
			Uniques.DivineBanner:ReleaseFromOwner(uuid, true)
			ItemScatterAt(uuid, x, y, z)
			PlayEffectAtPosition("RS3_FX_Skills_Divine_Barrage_Impact_01", x, y, z)
		end
	elseif event == "SlaneReward" then
		local uuid = Uniques.Frostdyne:GetUUID(NPC.Slane)
		if uuid then
			Uniques.Frostdyne:ReleaseFromOwner(uuid, false)
			if CharacterIsDead(NPC.Slane) == 0 then
				ItemToInventory(uuid, NPC.Slane, 1, 0, 1)
			else
				local x,y,z = GetPosition(NPC.Slane)
				ItemScatterAt(uuid, x, y, z)
				Timer.StartOneshot("Timers_LLWEAPONEX_SlaneRewardEffect", 500, function()
					local x,y,z = GetPosition(uuid)
					y = GameHelpers.Grid.GetY(x, z)
					PlayEffectAtPosition("RS3_FX_Skills_Totem_Impact_Target_Root_Ice_01", x, y, z)
					PlayFrostdyneLoopedEffect(x, y+2, z)
				end)
			end
		end
	end
end

--Mods.WeaponExpansion.FortJoyEvent("SlaneReward")