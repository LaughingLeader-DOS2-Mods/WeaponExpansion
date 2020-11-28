StatHelpers = {}

function StatHelpers.GetAttribute(stat, attribute, fallback)
	local value = Ext.StatGetAttribute(stat, attribute)
	if StringHelpers.IsNullOrEmpty(value) then
		return fallback
	end
	return value
end