
local function IsEngineStatus(status)
    if Mods.LeaderLib ~= nil then
        return Mods.LeaderLib.Data.EngineStatus[status] == true
    else
        return status ~= "HIT" and status ~= "LEADERSHIP"
    end
end

Ext.RegisterOsirisListener("NRD_OnHit", 4, "before", function (target, source, damage, handle)
    local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
	if skillprototype ~= "" and skillprototype ~= nil then
        local skill = nil
		skill = string.gsub(skillprototype, "_%-?%d+$", "")
        print(string.format("(%s) NRD_OnHit(%s)", Ext.MonotonicTime(), skill))
	end
end)

Ext.RegisterOsirisListener("CharacterStatusAttempt", 3, "before", function(char, status, _)
    if not IsEngineStatus(status) then
        local leaveAction = Ext.StatGetAttribute(status, "LeaveAction")
        if status == "CHILLED" or leaveAction ~= nil and leaveAction ~= "" then
            print(string.format("(%s) CharacterStatusAttempted(%s, %s)", Ext.MonotonicTime(), char, status))
        end
    end
end)

RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "before", function(char, status, _)
    if not IsEngineStatus(status) then
        local leaveAction = Ext.StatGetAttribute(status, "LeaveAction")
        if status == "CHILLED" or leaveAction ~= nil and leaveAction ~= "" then
            print(string.format("(%s) CharacterStatusApplied(%s, %s)", Ext.MonotonicTime(), char, status))
        end
    end
end)

RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "before", function(char, status, _)
    if not IsEngineStatus(status) then
        local leaveAction = Ext.StatGetAttribute(status, "LeaveAction")
        if status == "CHILLED" or leaveAction ~= nil and leaveAction ~= "" then
            print(string.format("(%s) CharacterStatusRemoved(%s, %s)", Ext.MonotonicTime(), char, status))
        end
    end
end)

RegisterProtectedExtenderListener("ShootProjectile", function (projectile)
    print(string.format("(%s) ShootProjectile(%s)", Ext.MonotonicTime(), projectile.SkillId))
end)

RegisterProtectedExtenderListener("ProjectileHit", function (projectile, hitObject, position)
    print(string.format("(%s) ProjectileHit(%s)", Ext.MonotonicTime(), projectile.SkillId))
end)

--- @type EsvShootProjectileRequest request
RegisterProtectedExtenderListener("BeforeShootProjectile", function (request)
    print(string.format("(%s) BeforeShootProjectile(%s)", Ext.MonotonicTime(), request.SkillId))
end)

--- @param caster EsvGameObject
--- @param position number[]
--- @param damageList DamageList
RegisterProtectedExtenderListener("GroundHit", function (caster, position, damageList)
    print(string.format("(%s) GroundHit(%s)", Ext.MonotonicTime(), caster.MyGuid))
end)