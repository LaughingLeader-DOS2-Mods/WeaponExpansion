---@type TranslatedString
local ts = Classes["TranslatedString"]

local function PrintArray(name, arr)
	if arr ~= nil and #arr > 0 then
		for i=0,#arr do
			print(name, i, arr[i])
		end
	else
		print(name, "nil")
	end
end

local WeaponSkills = {
	Projectile_LLWEAPONEX_Throw_UniqueAxe_A = true,
	Target_LLWEAPONEX_SinglehandedAttack = true
}

---@param ui UIObject
---@param method string
local function OnUpdateMemory(ui, method)
	local main = ui:GetRoot()
	local array = main.memoryCommitted
	if #array > 0 then
		for i=0,#array,5 do
			local memoryCost = array[i]
			local school = array[i+1]
			local skillid = array[i+2]
			local isActive = array[i+3]
			local listID = array[i+4]
			if skillid ~= nil and WeaponSkills[skillid] == true then
				array[i+4] = 2.0
				listID = 2.0
			end
			print("memoryCommitted", i, string.format("memoryCost(%s) school(%s) skillid(%s) isActive(%s) listID(%s)", memoryCost, school, skillid, isActive, listID))
		end
		-- for i=0,#array do
		-- 	print("memoryCommitted", i, array[i])
		-- end
	end

	main.skillPane_mc.setMemory(0,"Target_LLWEAPONEX_SinglehandedAttack",3,2,main.skillsColors[2]);

	-- local list = main.skillPane_mc.memoryLists.content_array
	-- if #list > 0 then
	-- 	for i=0,#list do
	-- 		print("main.skillPane_mc.memoryLists", i, list[i])
	-- 		local mc = list[i]
	-- 		if mc ~= nil then
	-- 			print(mc.memoryHolder.length)
	-- 			local arr = mc.memoryHolder.content_array
	-- 			if arr ~= nil and #arr > 0 then
	-- 				for i=0,#arr do
	-- 					local skill = arr[i]
	-- 					if skill ~= nil then
	-- 						print(i, string.format("skill(%s) tooltipID(%s) school(%s) learned(%s) isActive(%s)", skill.skillID, skill.tooltipID, skill.skillSchool, skill.isLearned, skill.m_isActive))
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

---@param ui UIObject
---@param method string
---@param bFilter boolean
local function OnUpdateSkills(ui, method, bFilter)
	local main = ui:GetRoot()
	local array = main.skillsUpdateList
	if #array > 0 then
		for i=0,#array,6 do
			local skillid = array[i]
			local tooltipID = array[i+1]
			local school = array[i+2]
			local learned = array[i+3]
			local listID = array[i+4]
			local isActive = array[i+5]
			print("skillsUpdateList", i, string.format("skill(%s) tooltipID(%s) school(%s) learned(%s) list(%s) isActive(%s)", skillid, tooltipID, school, learned, listID, isActive))
		end
		-- for i=0,#array do
		-- 	print("skillsUpdateList", i, array[i])
		-- end
	end

	local list = main.skillPane_mc.skillLists.content_array
	if #list > 0 then
		for i=0,#list do
			print("main.skillPane_mc.skillLists", i, list[i])
			local mc = list[i]
			if mc ~= nil then
				print(mc.list.length)
				local arr = mc.list.content_array
				if arr ~= nil and #arr > 0 then
					for i=0,#arr do
						local skill = arr[i]
						if skill ~= nil then
							print(i, string.format("skill(%s) tooltipID(%s) school(%s) learned(%s) isActive(%s)", skill.skillID, skill.tooltipID, skill.skillSchool, skill.isLearned, skill.m_isActive))
						end
					end
				end
			end
		end
	end
end

-- Ext.RegisterListener("SessionLoaded", function()
-- 	local ui = Ext.GetUIByType(Data.UIType.skills)
-- 	if ui ~= nil then
-- 		--Ext.RegisterUIInvokeListener(ui, "updateSkills", OnUpdateSkills)
-- 		--Ext.RegisterUIInvokeListener(ui, "updateMemory", OnUpdateMemory, "before")
-- 	end
-- end)