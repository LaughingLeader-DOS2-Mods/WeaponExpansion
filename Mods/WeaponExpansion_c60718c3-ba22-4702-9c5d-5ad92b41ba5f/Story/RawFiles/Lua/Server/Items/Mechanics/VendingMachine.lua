Config.VendingMachine = {
	StartingItems = {
		Stats = {TOOL_Hammer_LLWEAPONEX_Runesmith_A = 1},
		RootTemplates = {
			--LLWEAPONEX_TradeBag_AttributeTokens_Initial
			["39696124-ca27-4c76-860e-29aec727b5a7"] = 1
		},
	}
}

VendingMachine = {}

function VendingMachine.AddStartingItems()
	local vm = GameHelpers.GetCharacter(NPC.VendingMachine, "EsvCharacter")
	if vm then
		local addItems = TableHelpers.Clone(Config.VendingMachine.StartingItems)
		for _,guid in pairs(vm:GetInventoryItems()) do
			local item = GameHelpers.GetItem(guid, "EsvItem")
			if item then
				if addItems.Stats[item.StatsId] then
					addItems.Stats[item.StatsId] = nil
				end
				local template = GameHelpers.GetTemplate(item)
				if template and addItems.RootTemplates[template] then
					addItems.RootTemplates[template] = nil
				end
			end
		end
		for stat,amount in pairs(addItems.Stats) do
			local newItemGUID,newItem = GameHelpers.Item.CreateItemByStat(stat, {Amount=amount, IsIdentified=true})
			if newItemGUID and newItem then
				--So trade treasure generation doesn't delete these
				newItem.TreasureGenerated = false
				newItem.UnsoldGenerated = false
				ItemToInventory(newItemGUID, NPC.VendingMachine, newItem.Amount, 0, 1)
			end
		end
		for template,amount in pairs(addItems.RootTemplates) do
			local newItem = GameHelpers.Item.CreateItemByTemplate(template, {Amount=amount, IsIdentified=true})
			if newItem then
				--So trade treasure generation doesn't delete these
				newItem.TreasureGenerated = false
				newItem.UnsoldGenerated = false
				ItemToInventory(newItem.MyGuid, NPC.VendingMachine, newItem.Amount, 0, 1)
			end
		end
	end
end

function VendingMachine.Init()
	local vendingMachine = NPC.VendingMachine
	Osi.DB_DoNotFace(vendingMachine)
	Osi.DB_Dialogs(vendingMachine, "LLWEAPONEX_VendingMachine_A")
	Osi.DB_BlockThreatenedDialog(vendingMachine)
	Osi.DB_NoLowAttitudeDialog(vendingMachine)
	CharacterDisableAllCrimes(vendingMachine)
	SetCanJoinCombat(vendingMachine, 0)
	CharacterSetImmortal(vendingMachine, 1)
	SetTag(vendingMachine, "LeaderLib_DisableTreasureTableLimit")

	Osi.LeaderLib_Trader_Register_GlobalTrader("LLWEAPONEX.VendingMachine", vendingMachine)

	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "TestLevel_LL_WeaponExpansion", 40.56, 0.0, 29.63)
	--LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "TUT_Tutorial_A", 31.19, 4.0, -252.77);

	--Dungeon Shrine in Fort Joy
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "FJ_FortJoy_Main", 196.21, -3.98, 647.16)
	Osi.LeaderLib_Trader_Register_Rotation_Position("LLWEAPONEX.VendingMachine", "FJ_FortJoy_Main", 204.38, -4.57, 649.32)

	--Lady Vengeance 1st floor
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "LV_HoE_Main", 336.39, 7.8, 577.70)
	Osi.LeaderLib_Trader_Register_Rotation_Position("LLWEAPONEX.VendingMachine", "LV_HoE_Main", 336.39, 7.8, 579.0)

	--Lady Vengeance 1st floor
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "RC_Main", 740.56, 8.11, -41.46)
	Osi.LeaderLib_Trader_Register_Rotation_Position("LLWEAPONEX.VendingMachine", "RC_Main", 740.56, 8.11, -40.22)

	--Lady Vengeance 1st floor
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "CoS_Main", 228.84, 16.09, 284.24)
	Osi.LeaderLib_Trader_Register_Rotation_Position("LLWEAPONEX.VendingMachine", "CoS_Main", 226.68, 16.09, 284.24)

	--Outside
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.VendingMachine", "Arx_Main", 407.41, 39.19, 14.01)
	Osi.LeaderLib_Trader_Register_Rotation_Position("LLWEAPONEX.VendingMachine", "Arx_Main", 409.22, 39.19, 13.19)

	VendingMachine.AddStartingItems()
end

local _IndoorsRegion = {
	LV_HoE_Main = true,
	RC_Main = true,
	CoS_Main = true,
}

Ext.Osiris.RegisterListener("LeaderLib_Traders_OnSpawned", 3, "after", function (guid, traderID, region)
	if StringHelpers.GetUUID(guid) == NPC.VendingMachine and ObjectGetFlag(guid, "LLWEAPONEX_Vending_Initialized") == 0 then
		guid = NPC.VendingMachine
		Osi.PROC_LoopEffect("LLWEAPONEX_VendingMachine_WeaponDisplay_Quarterstaff_01", guid, "LLWEAPONEX_FX_VendingMachine_WeaponDisplay_Hook", region, "Dummy_WeaponDisplay_Hook")
		Osi.PROC_LoopEffect("LLWEAPONEX_VendingMachine_WeaponDisplay_ThrowingWeapons_01", guid, "LLWEAPONEX_FX_VendingMachine_WeaponDisplay_Bottom", region, "Dummy_WeaponDisplay_Bottom")
		ObjectSetFlag(guid, "LLWEAPONEX_Vending_Initialized", 0)

		if not _IndoorsRegion[region] then
			Osi.PROC_LoopEffect("LLWEAPONEX_VendingMachine_A_PipeSmoke_01", guid, "LLWEAPONEX_FX_VendingMachine_Smoke", region, "Dummy_SmokeFX")
		else
			Osi.PROC_LoopEffect("LLWEAPONEX_VendingMachine_A_PipeSmoke_02", guid, "LLWEAPONEX_FX_VendingMachine_Smoke", region, "Dummy_SmokeFX")
		end
	end
end)

Events.CharacterLeveledUp:Subscribe(function (e)
	if e.CharacterGUID == NPC.VendingMachine then
		local level = e.Character.Stats.Level
		for _,v in pairs(e.Character:GetInventoryItems()) do
			local item = GameHelpers.GetItem(v, "EsvItem")
			if item and not GameHelpers.Item.IsObject(item) and item.Stats.Level < level then
				ItemLevelUpTo(item.MyGuid, level)
			end
		end
	elseif e.IsPlayer then
		Timer.Start("LLWEAPONEX_VendingMachine_LevelUp", 500)
	end
end)

Timer.Subscribe("LLWEAPONEX_VendingMachine_LevelUp", function (e)
	local level = GameHelpers.Character.GetHighestPlayerLevel()
	if level > 1 then
		CharacterLevelUpTo(NPC.VendingMachine, level)
	end
end)

Ext.Osiris.RegisterListener("ItemTemplateAddedToCharacter", 3, "after", function (template, itemGUID, charGUID)
	--LLWEAPONEX_TradeBag_AttributeTokens_Initial
	if StringHelpers.GetUUID(template) == "39696124-ca27-4c76-860e-29aec727b5a7" then
		--LLWEAPONEX_TradeBag_AttributeTokens
		Transform(itemGUID, "c8b9b34d-a1a8-446e-993f-ff5c1338bc8a", 1, 1, 1)
		GenerateTreasure(itemGUID, "ST_LLWEAPONEX_VendingMachine_AttributeTokens_Start", -1, charGUID)
	end
end)

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.ENDED then
		ObjectClearFlag(NPC.VendingMachine, "LLWEAPONEX_Vending_Initialized", 0)
		Osi.LLWEAPONEX_VendingMachine_ClearSaleCooldown()
	end
end)

Events.GameTimeChanged:Subscribe(function (e)
	local saleDuration = GetVarInteger(NPC.VendingMachine, "LLWEAPONEX_SaleDuration") or 0
	if saleDuration > 0 then
		saleDuration = saleDuration - 1
		SetVarInteger(NPC.VendingMachine, "LLWEAPONEX_SaleDuration", saleDuration)
		if saleDuration <= 0 then
			DialogSetVariableString("LLWEAPONEX_VendingMachine_A", "LLWEAPONEX_VendingMachine_SaleStatus_b12f911c-7a98-4ff1-a35c-f2127335884f", "")
			ObjectClearFlag(NPC.VendingMachine, "LLWEAPONEX_VendingMachine_PlayedSaleEffect", 0)
			ObjectClearFlag(NPC.VendingMachine, "LLWEAPONEX_VendingMachine_SaleActive", 0)
			PartySetShopPriceModifier(NPC.VendingMachine, CharacterGetHostCharacter(), 100)
		end
	end
	if saleDuration <= 0 then
		local cooldown = GetVarInteger(NPC.VendingMachine, "LLWEAPONEX_SaleCooldown") or 0
		if cooldown <= 0 then
			local chance = SettingsManager.GetVariableValue(ModuleUUID, "VendingMachineSaleChance", 40)
			local saleDiscount = SettingsManager.GetVariableValue(ModuleUUID, "VendingMachineSaleDiscount", 50)
			if chance > 0 and saleDiscount >= 0 and GameHelpers.Math.Roll(chance) then
				cooldown = Ext.Utils.Random(GameHelpers.GetExtraData("LLWEAPONEX_VendingMachine_SaleCooldown_Min", 2), GameHelpers.GetExtraData("LLWEAPONEX_VendingMachine_SaleCooldown_Max", 5))
				SetVarInteger(NPC.VendingMachine, "LLWEAPONEX_SaleCooldown", cooldown)
				
				saleDuration = Ext.Utils.Random(GameHelpers.GetExtraData("LLWEAPONEX_VendingMachine_SaleDuration_Min", 1), GameHelpers.GetExtraData("LLWEAPONEX_VendingMachine_SaleDuration_Max", 3))
				SetVarInteger(NPC.VendingMachine, "LLWEAPONEX_SaleDuration", saleDuration)
				
				DialogSetVariableTranslatedString("LLWEAPONEX_VendingMachine_A", "LLWEAPONEX_VendingMachine_SaleStatus_b12f911c-7a98-4ff1-a35c-f2127335884f", "h75552db2ge537g4642gb684g9b77712b9dbd", " You see a sign that reads: 'Limited time sale now active!'")
				ObjectSetFlag(NPC.VendingMachine, "LLWEAPONEX_VendingMachine_SaleActive", 0)
				PartySetShopPriceModifier(NPC.VendingMachine, CharacterGetHostCharacter(), saleDiscount)
			end
		else
			cooldown = cooldown - 1
			SetVarInteger(NPC.VendingMachine, "LLWEAPONEX_SaleCooldown", cooldown)
		end
	end
end)

Ext.Osiris.RegisterListener("DialogStarted", 2, "after", function (dialog, instance)
	if dialog == "LLWEAPONEX_VendingMachine_A" then
		if ObjectGetFlag(NPC.VendingMachine, "LLWEAPONEX_VendingMachine_SaleActive") == 1
		and ObjectGetFlag(NPC.VendingMachine, "LLWEAPONEX_VendingMachine_PlayedSaleEffect") == 0
		then
			EffectManager.PlayEffect("LLWEAPONEX_FX_VendingMachine_Words_Sale_01", NPC.VendingMachine, {Bone="Dummy_OverheadFX"})
			ObjectSetFlag(NPC.VendingMachine, "LLWEAPONEX_VendingMachine_PlayedSaleEffect", 0)
		end
	end
end)

--Prevent attitude increases from happy deals (it's a machine)
Ext.Osiris.RegisterListener("DB_AttitudeAdjustMent", 3, "after", function (charGUID, traderGUID, attitude)
	if attitude ~= 0 and StringHelpers.GetUUID(traderGUID) == NPC.VendingMachine then
		Osi.DB_AttitudeAdjustMent:Delete(charGUID, traderGUID, attitude)
	end
end)

--Prevent attitude increases from "insulting" deals (it's a machine)
Ext.Osiris.RegisterListener("DB_InsultCounter", 3, "after", function (charGUID, traderGUID, count)
	if count ~= 0 and StringHelpers.GetUUID(traderGUID) == NPC.VendingMachine then
		Osi.DB_InsultCounter:Delete(charGUID, traderGUID, count)
	end
end)