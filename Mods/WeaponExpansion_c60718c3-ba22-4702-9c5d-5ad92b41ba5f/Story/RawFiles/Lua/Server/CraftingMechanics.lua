local attributes = {
	Strength = true,
	Finesse = true,
	Intelligence = true,
	Constitution = true,
	Memory = true,
	Wits = true,
}

local function findAttributeToken(a,b,c,d,e)

end

---@param char string
---@param a string
---@param b string
---@param c string
---@param d string
---@param e string
---@param requestIDStr string
function CanCombineItem(char, a, b, c, d, e, requestIDStr)
	local requestID = tonumber(requestIDStr)

end

---@param char string
---@param a string|nil	Combined template
---@param b string|nil	Combined template
---@param c string|nil	Combined template
---@param d string|nil	Combined template
---@param e string|nil	Combined template
---@param newItem string
function ItemTemplateCombinedWithItemTemplate(char, a, b, c, d, e, newItem)

end

function ChangeItemScaling(item, attribute)
	local itemStat = NRD_ItemGetStatsId(item)
	---@type StatEntryWeapon
	local stat = Ext.GetStat(itemStat)
	if stat.Requirements ~= nil then
		local addedRequirement = false
		if #stat.Requirements > 0 then
			for i,req in pairs(stat.Requirements) do
				if attributes[req.Requirement] == true then
					req.Requirement = attribute
					addedRequirement = true
				end
			end
		end
		if not addedRequirement then
			table.insert(stat.Requirements, {
				Requirement = attribute,
				Param = 0,
				Not = false
			})
		end
	else
		stat.Requirements = {
			{
				Requirement = attribute,
				Param = 0,
				Not = false
			}
		}
	end
    Ext.SyncStat(stat)
end