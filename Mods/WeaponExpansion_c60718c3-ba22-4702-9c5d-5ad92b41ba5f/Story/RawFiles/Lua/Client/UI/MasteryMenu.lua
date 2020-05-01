local panelOpen = false

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	if call == "requestCloseUI" then
		ui:Hide()
		Ext.DestroyUI("MasteryMenu")
		panelOpen = false
	elseif call == "selectedMastery" then
		ui:Invoke("selectMastery", params[1])
	end
end

local function sortMasteries(a,b)
	return a:upper() < b:upper()
end

local testDescription = "This is some test description text.<br>Rank 1<br>Crippling Blow<br>If the target is disabled, deal additional piercing damage.<br><br>Rank 2<br>Blitz Attack<br>Each target hit becomes Vulnerable. If hit again, Vulnerable is removed and bonus damage is dealt.<br>Rank 3<br>Some Skill<br>Some other description here.<br><br>Rank 4<br>Super Cool Skill<br>Does all the cool things whenever you need it to. Not broken at all.<br><br><br><br><br>The End"

local function getMasteryDescriptionTitle(text)
	return text:gsub("</font>", " " .. Text.Mastery.Value .. "</font>")
end

local function OpenMasteryMenu(call,uuid)
	LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OpenMasteryMenu] Opening mastery menu for ("..uuid..")")
	local ui = Ext.GetUI("MasteryMenu")
	if ui == nil then
		LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OpenMasteryMenu] Creating mastery menu ui.")
		ui = Ext.CreateUI("MasteryMenu", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", 99)
	end
	if ui ~= nil and panelOpen == false then
		Ext.RegisterUICall(ui, "switchMenu", OnMenuEvent)
		Ext.RegisterUICall(ui, "requestCloseUI", OnMenuEvent)
		Ext.RegisterUICall(ui, "UIAssert", OnMenuEvent)
		Ext.RegisterUICall(ui, "overMastery", OnMenuEvent)
		Ext.RegisterUICall(ui, "selectedMastery", OnMenuEvent)
		Ext.RegisterUICall(ui, "buttonPressed", OnMenuEvent)
		--ui:Invoke("updateAddBaseTopTitleText", "Mods")
		ui:Invoke("setTitle", Text.MasteryMenu.Title.Value)
		ui:Invoke("setButtonText", Text.MasteryMenu.CloseButton.Value)
		local masteryKeys = {}
		for tag,data in pairs(Masteries) do
			table.insert(masteryKeys, tag)
		end
		table.sort(masteryKeys, sortMasteries)
		
		local i = 0
		for _,tag in ipairs(masteryKeys) do
			local data = Masteries[tag]
			ui:Invoke("addMastery", i, data.Name.Value, getMasteryDescriptionTitle(data.Name.Value), testDescription, 0, (Ext.Random(1,100) / 100), true)
			i = i + 1
		end
		ui:Invoke("selectMastery", 2)
		ui:Invoke("openMenu")
		ui:Show()
		panelOpen = true
	else
		Ext.PrintError("[WeaponExpansion_MasteryMenu.lua:OpenMasteryMenu] Error opening mastery menu.")
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", OpenMasteryMenu)