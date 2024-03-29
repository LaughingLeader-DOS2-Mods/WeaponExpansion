if Mastery.Register == nil then
	Mastery.Register = {}
end

---@param mastery string
---@param displayName TranslatedString
---@param masteryColor string
---@param ranks table<integer,MasteryRankDisplayInfo>
function Mastery.Register.NewMastery(mastery, displayName, masteryColor, ranks)
	if masteryColor == nil then
		masteryColor = "#FFFFFF"
	end
	if Masteries[mastery] == nil then
		Masteries[mastery] = MasteryDataClasses.MasteryData:Create(mastery, displayName, masteryColor, ranks)
	end
end

---@param mastery string
---@param rank integer
---@param id string
---@param bonus MasteryBonusData|MasteryBonusData[]
function Mastery.Register.NewRankBonus(mastery, rank, id, bonus)
	MasteryBonusManager.AddRankBonuses(mastery, rank, bonus)
end

---@param mastery string
---@param rank integer
---@param stringKey string
---@param defaultEnabled boolean|nil
function Mastery.Register.NewRankText(mastery, rank, stringKey, defaultEnabled)
	if rank ~= nil and rank > Mastery.Variables.MaxRank then
		rank = Mastery.Variables.MaxRank
	end
	if defaultEnabled == nil then
		defaultEnabled = true
	end
	if Mastery.AdditionalRankText[mastery] == nil then
		Mastery.AdditionalRankText[mastery] = {}
	end
	if Mastery.AdditionalRankText[mastery][rank] == nil then
		Mastery.AdditionalRankText[mastery][rank] = {}
	end
	Mastery.AdditionalRankText[mastery][rank][stringKey] = defaultEnabled
end