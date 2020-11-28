TagHelpers = {}

local undeadVoidwokenTags = {
	"VOIDWOKEN",
	"UNDEAD",
	"VOIDLING",
	"DRILLWORM",
	"MERMAN",
	"VOIDSECT",
	"ALANBIRD",
	"MOLESPITTER",
	"NIGHTFANG",
	"VOIDWOLF",
}

---@param target EsvCharacter|EsvItem
function TagHelpers.IsUndeadOrVoidwoken(target)
	if Ext.IsServer() and type(target) == "string" then
		for i,tag in pairs(undeadVoidwokenTags) do
			if IsTagged(target, tag) == 1 then
				return true
			end
		end
	else
		if target == nil or target.HasTag == nil then
			return false
		end
		for i,tag in pairs(undeadVoidwokenTags) do
			if target:HasTag(tag) then
				return true
			end
		end
	end
	return false
end