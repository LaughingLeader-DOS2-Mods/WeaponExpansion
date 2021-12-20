---@type UniqueData
local UniqueData = UniqueManager.Classes.UniqueData

---@param uuid UUID
---@return boolean
function UniqueData:IsReleasedFromOwner(uuid)
	uuid = uuid or self:GetUUID(nil, false)
	if uuid then
		if ObjectGetFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner") == 1 then
			return true
		else
			local owner = self:GetOwner(uuid, false)
			if owner ~= nil and GameHelpers.Character.IsPlayer(owner) then
				return true
			end
		end
	end
	return false
end

---@param uuid UUID
---@param unequip boolean|nil Whether to unequip the item from its current owner.
function UniqueData:ReleaseFromOwner(uuid, unequip)
	assert(not StringHelpers.IsNullOrWhitespace(uuid), "[WeaponExpansion:UniqueData:ReleaseFromOwner] uuid must be a valid item UUID.")
	ObjectSetFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
	ObjectSetFlag(uuid, "LLWEAPONEX_UniqueData_Initialized", 0)
	if unequip then
		local owner = GameHelpers.Item.GetOwner(uuid)
		if unequip == true and type(owner) == "string" and GameHelpers.Item.ItemIsEquipped(owner, uuid) then
			ItemLockUnEquip(uuid, 0)
			CharacterUnequipItem(owner, uuid)
		end
	end
	ItemClearOwner(uuid)
end

function UniqueData:ResetRelease(uuid)
	uuid = uuid or self:GetUUID(nil,true)
	if uuid then
		ObjectClearFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
	end
end

---@param region string
---@param item EsvItem|nil
function UniqueData:MoveToRegionPosition(region, item)
	local targetPosition = self.LevelData[region]
	if targetPosition ~= nil then
		local x,y,z,pitch,yaw,roll = table.unpack(targetPosition)
		local host = CharacterGetHostCharacter()
		TeleportTo(self.UUID, host, "", 0, 1, 0)
		ItemToTransform(self.UUID, x,y,z,pitch,yaw,roll,1,nil)
	else
		local defaultNPCOwnerIsDead = self.DefaultOwner ~= nil and (not IsPlayer(self.DefaultOwner) and CharacterIsDead(self.DefaultOwner) == 1)
		-- Fallback
		if self.CanMoveToVendingMachine ~= false or defaultNPCOwnerIsDead then
			ItemToInventory(self.UUID, NPC.VendingMachine, 1, 0, 0)
		else
			ItemToInventory(self.UUID, NPC.UniqueHoldingChest, 1, 0, 0)
		end
	end
end

function UniqueData:Initialize(region, firstLoad, uuid)
	if uuid == nil then
		uuid = self.UUID
	end
	if GameHelpers.ObjectExists(uuid) then
		self.Initialized = ObjectGetFlag(uuid, "LLWEAPONEX_UniqueData_Initialized") == 1
		if firstLoad == true then
			self:ApplyProgression(self.ProgressionData, nil, Ext.GetItem(uuid), true)
		end
	end
end

function UniqueData:OnItemLeveledUp(item)
	self:ApplyProgression(self.ProgressionData, nil, item, false)
end

---@param uuid string
function UniqueData:AddCopy(uuid)
	assert(not StringHelpers.IsNullOrWhitespace(uuid), string.format("[WeaponExpansion:UniqueData:AddCopy] uuid must be a valid item UUID value(%s).", uuid))
	local setIsInitialized = ObjectGetFlag(self.DefaultUUID, "LLWEAPONEX_UniqueData_Initialized") ~= 0
	local setIsReleased = ObjectGetFlag(self.DefaultUUID, "LLWEAPONEX_UniqueData_ReleaseFromOwner") ~= 0
	AllUniques[uuid] = self
	PersistentVars.Uniques[uuid] = self.Tag
	if setIsInitialized then
		ObjectSetFlag(uuid, "LLWEAPONEX_UniqueData_Initialized", 0)
	end
	if setIsReleased then
		ObjectSetFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
	end
end

---@param target UUID
---@param uuid UUID|nil
function UniqueData:Equip(target, uuid)
	uuid = uuid or self.UUID
	if GameHelpers.ObjectExists(uuid) then
		local item = Ext.GetItem(uuid)
		local locked = item.UnEquipLocked
		if GameHelpers.Character.EquipItem(target, item) then
			if self.OnEquipped ~= nil then
				pcall(self.OnEquipped, self, target)
			end
			if locked then
				ItemLockUnEquip(item.MyGuid, 1)
			end
		end
	end
end

---@param target UUID
---@param uuid UUID|nil
---@param equip boolean|nil
function UniqueData:Transfer(target, uuid, equip)
	uuid = uuid or self.UUID
	assert(not StringHelpers.IsNullOrWhitespace(uuid) and GameHelpers.ObjectExists(uuid), "[WeaponExpansion:UniqueData:Equip] uuid must be a valid item UUID.")
	if target == "host" or not (target and Vars.DebugMode) then target = CharacterGetHostCharacter() end
	assert(not StringHelpers.IsNullOrWhitespace(target) and GameHelpers.ObjectExists(target), "[WeaponExpansion:UniqueData:Equip] target must be a valid object UUID.")
	self.Owner = target

	if GetInventoryOwner(uuid) ~= target then
		ItemLockUnEquip(uuid, 0)
		ItemToInventory(uuid, target, 1, 1, 1)
	end
	if equip == true then
		self:Equip(target, uuid)
	end
end

---@param entry UniqueProgressionEntry
---@param stat StatEntryWeapon
---@param item EsvItem
local function ApplyProgressionEntry(entry, stat, item, changes, firstLoad, level)
	local statChanged = false
	if not StringHelpers.IsNullOrEmpty(entry.MatchStat) then
		if stat ~= entry.MatchStat then
			return false
		end
	end
	if Ext.Version() < 53 then
		Ext.EnableExperimentalPropertyWrites()
	end
	local target = stat
	if entry.IsBoost == true then
		target = item.Stats.DynamicStats[2]
	end
	local attribute = entry:GetBoostAttribute(stat)
	if attribute == "ExtraProperties" then
		local props = target.ExtraProperties or {}
		if not string.find(Common.Dump(props), entry.Value.Action) then
			table.insert(props, entry.Value)
			statChanged = true
		end
	elseif attribute == "WeaponRange" then
		entry.Value = math.ceil(entry.Value / 100)
	elseif attribute == "Skills" then
		local current = target[attribute]
		if not StringHelpers.IsNullOrEmpty(current) then
			for i,v in pairs(StringHelpers.Split(entry.Value, ";")) do
				if not string.find(current, v) then
					target[attribute] = current .. ";" .. v
					statChanged = true
				end
			end
		else
			target[attribute] = entry.Value
			statChanged = true
		end
	elseif attribute == "Boosts" then
		-- TODO
		-- PrintDebug(stat.Name, attribute, stat.Boosts, "=>", entry.Value)
		-- stat.Boosts = entry.Value
		-- statChanged = true
		firstLoad = false
	elseif attribute == "DamageRange" then
		attribute = ""
		local damage = Game.Math.GetLevelScaledWeaponDamage(level)
		local minDamage = 0
		local maxDamage = 0
		local damageFrombase = stat.DamageFromBase + target.DamageFromBase
		local baseDamage = damage * (damageFrombase * 0.01)
		local baseRange = stat["Damage Range"]
		local range = baseDamage * ((baseRange+entry.Value) * 0.01)
		local baseMinDamage = item.Stats.DynamicStats[1].MinDamage
		local baseMaxDamage = item.Stats.DynamicStats[1].MaxDamage
		minDamage = Ext.Round(baseDamage - (range/2))
		maxDamage = Ext.Round(baseDamage + (range/2))
		changes.Boosts["MinDamage"] = (changes.Boosts["MinDamage"] or 0) + math.abs(minDamage - baseMinDamage)
		changes.Boosts["MaxDamage"] = (changes.Boosts["MaxDamage"] or 0) + math.abs(maxDamage - baseMaxDamage)
		if LeaderLib.Vars.DebugMode then
			LeaderLib.PrintLog("[%s] Damage Range (%s) MinDamage(%s => %s) MaxDamage(%s => %s)", stat.Name, entry.Value, baseMinDamage, minDamage, baseMinDamage+minDamage, baseMaxDamage, maxDamage, baseMaxDamage)
		end
		target.MinDamage = minDamage
		target.MaxDamage = maxDamage
		
	else
		PrintDebug(stat.Name, attribute, target[attribute], "=>", entry.Value)
		target[attribute] = entry.Value
		statChanged = true
	end
	if (statChanged or firstLoad == true) and not StringHelpers.IsNullOrEmpty(attribute) then
		changes.Boosts[attribute] = target[attribute]
	end
	return statChanged
end

---@param self UniqueData
---@param item EsvItem
---@param template string
---@param stat string
---@param level integer
local function CloneItem(self, item, template, stat, level)
	local constructor = Ext.CreateItemConstructor(item)
	---@type ItemDefinition
	local props = constructor[1]
	props.GoldValueOverwrite = math.floor(item.Stats.Value * 0.4)

	if item.ItemType == "Weapon" then
		-- Damage type fix
		-- Deltamods with damage boosts may make the weapon's damage type be all of that type, so overwriting the statType
		-- fixes this issue.
		local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
		if damageTypeString == nil then damageTypeString = "Physical" end
		local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
		props.DamageTypeOverwrite = damageTypeEnum
	end

	props.GenerationStatsId = stat
	props.StatsEntryName = stat
	props.IsIdentified = true
	props.OriginalRootTemplate = template
	props.RootTemplate = template
	props.DeltaMods = item.GetDeltaMods()
	props.GenerationLevel = level
	props.StatsLevel = level

	local cloned = constructor:Construct()
	if cloned ~= nil then
		ItemSetOwner(cloned.MyGuid, self.Owner)
		ItemToInventory(cloned, self.Owner, 1, 0, 0)
		self:AddCopy(cloned.MyGuid)
		PersistentVars.Uniques[item.MyGuid] = nil
		ItemRemove(item.MyGuid)
	else
		Ext.PrintError("Error constructing item?", item.MyGuid)
	end
end

---@param self UniqueData
---@param item EsvItem
---@param template string
---@param stat string
---@param level integer
local function TransformItem(self, item, template, stat, level, matchStat, matchTemplate)
	local currentTemplate = StringHelpers.GetUUID(GetTemplate(item.MyGuid))
	if currentTemplate == StringHelpers.GetUUID(template) then
		return true
	end
	if not StringHelpers.IsNullOrEmpty(matchTemplate) then
		if currentTemplate ~= matchTemplate then
			return false
		end
	end
	if not StringHelpers.IsNullOrEmpty(matchStat) then
		if item.Stats.Name ~= matchStat then
			return false
		end
	end
	local slot = ""
	local owner = GetInventoryOwner(item.MyGuid)
	if not StringHelpers.IsNullOrEmpty(owner) ~= nil and ObjectIsCharacter(owner) then
		local character = Ext.GetCharacter(owner)
		if character ~= nil then
			for _,slotid in LeaderLib.Data.VisibleEquipmentSlots:Get() do
				if StringHelpers.GetUUID(CharacterGetEquippedItem(character.MyGuid, slotid)) == item.MyGuid then
					slot = slotid
					break
				end
			end
			if slot ~= "" then
				CharacterUnequipItem(character.MyGuid, item.MyGuid)
			end
		end
	end
	local deltamods = item:GetDeltaMods()
	Transform(item.MyGuid, template, 1, 1, 1)
	if not StringHelpers.IsNullOrEmpty(stat) then
		item.StatsId = stat
	end

	for i,v in pairs(deltamods) do
		if not ItemHasDeltaModifier(item.MyGuid, v) then
			ItemAddDeltaModifier(item.MyGuid, v)
		end
	end

	ItemLevelUpTo(item.MyGuid, level)

	if not StringHelpers.IsNullOrEmpty(slot) and not StringHelpers.IsNullOrEmpty(owner) then
		Timer.StartOneshot("Timers_LLWEAPONEX_PostTransformEquip", 250, function()
			NRD_CharacterEquipItem(owner, item.MyGuid, slot, 0, 0, 1, 1)
		end)
	end
	return true
end

if Vars.DebugMode then
	function UniqueData:TryTransform(template)
		local item = Ext.GetItem(self.UUID)
		local level = CharacterGetLevel(CharacterGetHostCharacter())
		TransformItem(self, item, template, nil, level)
	end
end

local function EvaluateEntry(self, progressionTable, persist, item, level, stat, entry, changes, firstLoad)
	local statChanged = false
	if entry.Type == "UniqueProgressionEntry" then
		if ApplyProgressionEntry(entry, stat, item, changes, firstLoad, level) then
			statChanged = true
		end
	elseif entry.Type == "UniqueProgressionTransform" then
		if not StringHelpers.IsNullOrEmpty(entry.Template) then
			if TransformItem(self, item, entry.Template, entry.Stat, level, entry.MatchStat, entry.MatchTemplate) then
				statChanged = true
			end
		end
	elseif #entry > 0 then
		for i,v in pairs(entry) do
			if v.Type == "UniqueProgressionEntry" then
				if ApplyProgressionEntry(v, stat, item, changes, firstLoad, level) then
					statChanged = true
				end
			elseif v.Type == "UniqueProgressionTransform" then
				if not StringHelpers.IsNullOrEmpty(entry.Template) then
					if TransformItem(self, item, v.Template, v.Stat, level, v.MatchStat, v.MatchTemplate) then
						statChanged = true
					end
				end
			end
		end
	end
	return statChanged
end

local BoostAttributes = {
	--Durability = "integer",
	--DurabilityDegradeSpeed = "integer",
	StrengthBoost = "integer",
	FinesseBoost = "integer",
	IntelligenceBoost = "integer",
	ConstitutionBoost = "integer",
	MemoryBoost = "integer",
	WitsBoost = "integer",
	--SightBoost = "integer",
	--HearingBoost = "integer",
	VitalityBoost = "integer",
	SourcePointsBoost = "integer",
	MaxAP = "integer",
	StartAP = "integer",
	APRecovery = "integer",
	AccuracyBoost = "integer",
	DodgeBoost = "integer",
	LifeSteal = "integer",
	CriticalChance = "integer",
	ChanceToHitBoost = "integer",
	MovementSpeedBoost = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	FireResistance = "integer",
	AirResistance = "integer",
	WaterResistance = "integer",
	EarthResistance = "integer",
	PoisonResistance = "integer",
	--ShadowResistance = "integer",
	PiercingResistance = "integer",
	--CorrosiveResistance = "integer",
	PhysicalResistance = "integer",
	--MagicResistance = "integer",
	--CustomResistance = "integer",
	Movement = "integer",
	Initiative = "integer",
	Willpower = "integer",
	Bodybuilding = "integer",
	MaxSummons = "integer",
	--Value = "integer",
	--Weight = "integer",
	Skills = "string",
	--ItemColor = "string",
	--ModifierType = "integer",
	--ObjectInstanceName = "string",
	--BoostName = "string",
	--StatsType = "string",
}

local WeaponBoosts = {
	--DamageType = "integer",
	MinDamage = "integer",
	MaxDamage = "integer",
	DamageBoost = "integer",
	DamageFromBase = "integer",
	CriticalDamage = "integer",
	WeaponRange = "integer",
	CleaveAngle = "integer",
	CleavePercentage = "integer",
	AttackAPCost = "integer",
}

local ArmorBoosts = {
	ArmorValue = "integer",
	ArmorBoost = "integer",
	MagicArmorValue = "integer",
	MagicArmorBoost = "integer",
}

local ShieldBoosts = {
	ArmorValue = "integer",
	ArmorBoost = "integer",
	MagicArmorValue = "integer",
	MagicArmorBoost = "integer",
	Blocking = "integer",
}

local function ResetBoostAttributes(tbl, target, changes)
	for boost,type in pairs(tbl) do
		if target[boost] ~= nil then
			if type == "integer" then
				changes.Boosts[boost] = 0
				target[boost] = 0
			elseif type == "string" then
				changes.Boosts[boost] = ""
				target[boost] = ""
			end
		end
	end
end

local function ApplyStatsConfigurator(changes, stat)
	local UnpackCollection = Mods.S7_Config.UnpackCollection
	local Rematerialize = Mods.S7_Config.Rematerialize
	local SafeToModify = Mods.S7_Config.SafeToModify
	local toConfigure = Mods.S7_Config.toConfigure
	if toConfigure == nil then
		return
	end
    for _, config in ipairs(toConfigure) do --  Iterate over toConfigure queue
        for modID, JSONstring in pairs(config) do
			local JSONborne = Ext.JsonParse(JSONstring) --  Parsed JSONstring.
			for keyName, content in pairs(JSONborne) do --  Iterate over JSONborne.
				local nameList = Rematerialize(UnpackCollection(keyName, content)) -- extract stat-names to nameList.
				for name, _ in pairs(nameList) do
					if name == stat.Name then
						for key, value in pairs(content) do
							if SafeToModify(name, key) then --  Checks if attribute key is safe to modify.
								local v = Rematerialize(value)
								changes.Stats[key] = v
								stat[key] = v
							end
						end
					end
				end
			end
        end
    end
end

local function ResetUnique(item, stat, level, changes)
	local target = item.Stats.DynamicStats[2]
	ResetBoostAttributes(BoostAttributes, target, changes)
	local itemType = item.ItemType
	if itemType == "Weapon" then
		ResetBoostAttributes(WeaponBoosts, target, changes)
	elseif itemType == "Armor" then
		ResetBoostAttributes(ArmorBoosts, target, changes)
	elseif itemType == "Shield" then
		ResetBoostAttributes(ShieldBoosts, target, changes)
	end
	local originalValues = Temp.OriginalUniqueStats[item.Stats.Name]
	if originalValues ~= nil then
		for attribute,value in pairs(originalValues) do
			if attribute == "Damage Range" then
				local damage = Game.Math.GetLevelScaledWeaponDamage(level)
				local baseDamage = damage * (stat.DamageFromBase * 0.01)
				local range = baseDamage * (stat["Damage Range"] * 0.01)
				local min = Ext.Round(baseDamage - (range/2))
				local max = Ext.Round(baseDamage + (range/2))
				changes.Boosts["MinDamage"] = min
				changes.Boosts["MaxDamage"] = max
			else
				if attribute == "WeaponRange" then
					value = math.ceil(value / 100)
				end
				changes.Stats[attribute] = value
				stat[attribute] = value
			end
		end
		-- Stats Configurator
		if Ext.IsModLoaded("de8f15f2-65a2-4ee4-a25f-7a7ab0305a58") then
			local b,err = xpcall(ApplyStatsConfigurator, debug.traceback, changes, stat)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

---@param self UniqueData
---@param item EsvItem
local function TryApplyProgression(self, progressionTable, persist, item, level, changes, firstLoad)
	local statChanged = false
	local statId = item.Stats.Name
	if progressionTable ~= nil and statId ~= "" then
		local stat = Ext.GetStat(statId, level)
		for i=1,level do
			local entries = progressionTable[i]
			if entries ~= nil then
				if EvaluateEntry(self, progressionTable, persist, item, level, stat, entries, changes, firstLoad) then
					statChanged = true
				end
			end
		end
		if firstLoad == true then
			ResetUnique(item, stat, level, changes)
		end
		if statChanged or firstLoad == true then
			if persist == nil then
				persist = false
			end
			Ext.SyncStat(statId, persist)
		end
		item.Stats.ShouldSyncStats = true
	end
	return statChanged or firstLoad == true
end

---@param item EsvItem
local function StartApplyingProgression(self, progressionTable, persist, item, firstLoad)
	item = GameHelpers.GetItem(item)
	assert(item ~= nil and GameHelpers.Ext.ObjectIsItem(item), "[WeaponExpansion:UniqueData:StartApplyingProgression] item is not valid.")
	-- TODO - Testing. Making sure bonuses don't overlap if they're set to append when you save/load/change level/level up etc.
	-- Maybe they all need to be replacements to avoid that potential issue, in which case the stats need to be reviewed to make sure the progression
	-- enries aren't nerfing things.
	local level = item.Stats.Level
	local changes = {
		Boosts = {},
		Stats = {}
	}
	local b,result = xpcall(TryApplyProgression, debug.traceback, self, progressionTable, persist, item, level, changes, firstLoad)
	if not b then
		Ext.PrintError("[LLWEAPONEX] Error applying progression to unique", item.MyGuid, item.Stats.Name)
		Ext.PrintError(result)
	elseif result == true or firstLoad == true then
		if changes ~= nil and Common.TableHasAnyEntry(changes) then
			if changes.Stats["Damage Range"] ~= nil then
				local damage = Game.Math.GetLevelScaledWeaponDamage(level)
				local baseDamage = damage * (item.Stats.DamageFromBase * 0.01)
				local range = baseDamage * (item.Stats["Damage Range"] * 0.01)
				local min = Ext.Round(baseDamage - (range/2))
				local max = Ext.Round(baseDamage + (range/2))
				changes.Boosts["MinDamage"] = min
				changes.Boosts["MaxDamage"] = max
				changes.Stats["Damage Range"] = nil
			end
			EquipmentManager.SyncItemStatChanges(item, changes)
			local copies = self.Copies
			if copies then
				for uuid,owner in pairs(copies) do
					if uuid ~= item.MyGuid then
						local copyItem = Ext.GetItem(uuid)
						if copyItem ~= nil then
							EquipmentManager.SyncItemStatChanges(copyItem, changes)
						end
					end
				end
			end
		end
	end
end

---@param progressionTable table<integer,UniqueProgressionEntry|UniqueProgressionEntry[]>
---@param persist boolean
---@param item EsvItem
---@param firstLoad boolean|nil
function UniqueData:ApplyProgression(progressionTable, persist, item, firstLoad)
	progressionTable = progressionTable or self.ProgressionData
	item = GameHelpers.GetItem(item or self:GetUUID(nil,true))
	assert(item ~= nil, string.format("[WeaponExpansion:UniqueData:StartApplyingProgression] item (%s) is not valid for unique (%s).", item, self.Tag))
	StartApplyingProgression(self, progressionTable, persist, item, firstLoad)
	self.LastProgressionLevel = item.Stats.Level
end

function UniqueData:AddEventListener(event, callback)
	UniqueManager.EnableEvent(event)
	local listeners = self.Events[event]
	if not listeners then
		self.Events[event] = {}
		listeners = self.Events[event]
	end
	table.insert(listeners, callback)
	return #listeners
end

function UniqueData:RemoveEventListener(event, callback)
	local listeners = self.Events[event]
	if listeners then
		if type(callback) == "number" then
			table.remove(listeners, callback)
		else
			for i,v in pairs(listeners) do
				if v == callback then
					table.remove(listeners, i)
				end
			end
		end
	end
end
function UniqueData:InvokeEventListeners(event, ...)
	local listeners = self.Events[event]
	if listeners then
		InvokeListenerCallbacks(listeners, ...)
	end
end

---@alias UniqueDataEquippedEventCallback fun(unique:UniqueData, character:EsvCharacter, item:EsvItem, equipped:boolean):void

---@param callback UniqueDataEquippedEventCallback
function UniqueData:RegisterEquippedListener(callback)
	self.EquippedCallbacks[#self.EquippedCallbacks+1] = callback
end

---@param character EsvCharacter
---@param item EsvItem
function UniqueData:OnEquipped(character, item)
	InvokeListenerCallbacks(self.EquippedCallbacks, self, character, item, true)
end

---@param character EsvCharacter
---@param item EsvItem
function UniqueData:OnUnEquipped(character, item)
	InvokeListenerCallbacks(self.EquippedCallbacks, self, character, item, false)
end