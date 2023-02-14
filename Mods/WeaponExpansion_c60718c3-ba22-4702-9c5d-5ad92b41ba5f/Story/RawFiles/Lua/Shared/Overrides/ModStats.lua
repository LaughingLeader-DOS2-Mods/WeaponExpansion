local _MOD_OVERRIDES = {}

local type = type

---@generic T
---@param modGUID Guid
---@param statType `T`
---@return fun(statID:string, attributes:T)
local function _Add(modGUID, statType)
	if _MOD_OVERRIDES[modGUID] == nil then
		_MOD_OVERRIDES[modGUID] = {}
	end
	local addAttributesFunc = nil
	addAttributesFunc = function(statID, attributes)
		local t = type(statID)
		if t == "table" then
			for i=1,#statID do
				addAttributesFunc(statID[i], attributes)
			end
		elseif t == "string" then
			_MOD_OVERRIDES[modGUID][statID] = attributes
		else
			error("Invalid statID type (" .. t .. ")", 2)
		end
	end
	return addAttributesFunc
end

---@param addTags string[]
---@return LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<string>
local function _AppendTags(addTags)
	return function (statId, attributeId, value)
		if StringHelpers.IsNullOrEmpty(value) then
			return StringHelpers.Join(";", addTags)
		else
			local tags = TableHelpers.MakeUnique(Common.MergeTables(StringHelpers.Split(value, ";"), addTags), true)
			return StringHelpers.Join(";", tags)
		end
	end
end

--Animation Plus Support
_Add("326b8784-edd7-4950-86d8-fcae9f5c457c", "StatEntrySkillData")({
	"Target_SingleHandedAttack",
	"Target_LLWEAPONEX_SinglehandedAttack"
},{
	CastAnimation = "skill_cast_ll_suckerpunch_01_cast",
	CastSelfAnimation = "skill_cast_ll_suckerpunch_01_cast",
	CastTextEvent = "cast",
})

--Tactician Class Mod by Perceux
_Add("4d50be50-288d-4da4-9c9c-358e8668af84", "StatEntryWeapon")({
	"WPN_Tactician_Banner_DO2",
	"WPN_Tactician_Banner_Whiterun",
	"WPN_Tactician_Banner_Sniper",
	"WPN_Tactician_Banner_Paladin",
	"WPN_Tactician_Banner_Chaos",
	"WPN_Tactician_Banner_DO_U",
	"WPN_Tactician_Banner_Stormbreaker",
	"WPN_Tactician_Banner_Stormbreaker_U",
	"WPN_Tactician_Banner_Sniper_U",
	"WPN_Tactician_Banner_Chaos_U",
	"WPN_Tactician_Banner_Paladin_U",
	"WPN_Tactician_Banner_Start",
},{
	Tags = _AppendTags({"LLWEAPONEX_Banner", "LLWEAPONEX_Banner_Equipped"})
})

return _MOD_OVERRIDES