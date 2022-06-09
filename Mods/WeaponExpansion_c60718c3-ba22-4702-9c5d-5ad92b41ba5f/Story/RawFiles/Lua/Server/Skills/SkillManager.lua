local SkillListeners = {
	SkillType = {},
	Element = {},
	Any = {}
}

if SkillManager == nil then
	SkillManager = {}
end

function SkillManager.RegisterTypeListener(skilltype, func)
	skilltype = string.lower(skilltype)
	if SkillListeners.SkillType[skilltype] == nil then
		SkillListeners.SkillType[skilltype] = {}
	end
	table.insert(SkillListeners.SkillType[skilltype], func)
end

function SkillManager.RegisterElementListener(element, func)
	element = string.lower(element)
	if SkillListeners.Element[element] == nil then
		SkillListeners.Element[element] = {}
	end
	table.insert(SkillListeners.Element[element], func)
end

function SkillManager.RegisterAnySkillListener(func)
	table.insert(SkillListeners.Any, func)
end

local function RunSkillCallbacks(tbl, uuid, state, skill, skilltype, element)
	for i=1,#tbl do
		local callback = tbl[i]
		local b,err = xpcall(callback, debug.traceback, uuid, state, skill, skilltype, element)
		if not b then
			Ext.PrintError(err)
		end
	end
end

function OnSkillEvent(uuid, state, skill, skilltype, element)
	element = string.lower(element)
	skilltype = string.lower(skilltype)

	local tbl = SkillListeners.Element[element]
	if tbl ~= nil and #tbl > 0 then
		RunSkillCallbacks(tbl, uuid, state, skill, skilltype, element)
	end

	local tbl = SkillListeners.SkillType[skilltype]
	if tbl ~= nil and #tbl > 0 then
		RunSkillCallbacks(tbl, uuid, state, skill, skilltype, element)
	end

	local tbl = SkillListeners.Any
	if #tbl > 0 then
		RunSkillCallbacks(tbl, uuid, state, skill, skilltype, element)
	end
end