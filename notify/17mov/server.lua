local Config = rawget(_G, 'Config') or {}
if Config.NotifyBackend ~= '17mov' then return end
if GetResourceState('17mov_Hud') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

Compat.Notify = Compat.Notify or {}

Compat.Notify.Send = function(src, message, ntype, duration, title)
    if not src or src == 0 then return false end
    TriggerClientEvent('sv_compat:notify', src, {
        message = tostring(message or ''),
        type = ntype or 'info',
        duration = duration or (Config.Notify and Config.Notify.duration) or 5000,
        title = tostring(title or ''),
    })
    return true
end

Compat.SendNotify = Compat.Notify.Send

print('[sv_compat] notify backend: 17mov')
