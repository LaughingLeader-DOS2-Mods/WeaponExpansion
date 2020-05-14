local cleansedStatuses = {
	"FEAR",
	"MADNESS",
	"SLEEP"
}

function Banner_ApplyEncouragedBonus(target, source)
	local cleansed = {}
	for i,status in pairs(cleansedStatuses) do
		if HasActiveStatus(target, status) == 1 then
			RemoveStatus(target, status)
			cleansed[cleansed+1] = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "DisplayName"))
		end
	end
	if cleansed then
		--PlayBeamEffect(source, target, "RS3_FX_GP_Status_Retaliation_Beam_01", "Dummy_R_HandFX", "Dummy_BodyFX")
		ApplyStatus(target, "LLWEAPONEX_ENCOURAGED_CLEANSE_BEAM_FX", 0.0, 1, source)
		local text = Ext.GetTranslatedStringFromKey("LLWEAPONEX_StatusText_Encourage_Cleansed"):gsub("%[1%]", LeaderLib.Common.StringJoin("/", cleansed))
		CharacterStatusText(target,text)
	end
end