local Config = rawget(_G, 'Config') or {}
if Config.ProgressBackend ~= '17mov' then return end
if GetResourceState('17mov_Hud') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

Compat.Progress = Compat.Progress or {}

Compat.Progress.Show = function(src, data)
    if not src or src == 0 then return false end
    TriggerClientEvent('sv_compat:progress', src, data or {})
    return true
end

Compat.Progress.Cancel = function(src)
    if not src or src == 0 then return false end
    TriggerClientEvent('sv_compat:progressCancel', src)
    return true
end

print('[sv_compat] progress backend: 17mov')
