local Config = rawget(_G, 'Config') or {}
if Config.NotifyBackend ~= '17mov' then return end
if GetResourceState('17mov_Hud') ~= 'started' then return end

RegisterNetEvent('sv_compat:notify', function(payload)
    if GetResourceState('17mov_Hud') ~= 'started' then return end
    local data = payload or {}
    local text = tostring(data.message or '')
    local ntype = data.type or 'info'
    local title = tostring(data.title or '')
    local time = data.duration or (Config.Notify and Config.Notify.duration) or 5000
    exports['17mov_Hud']:ShowNotification(text, ntype, title, time)
end)

print('[sv_compat] notify backend (client): 17mov')
