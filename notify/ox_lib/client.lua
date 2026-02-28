local Config = rawget(_G, 'Config') or {}
if Config.NotifyBackend ~= 'ox_lib' then return end
if GetResourceState('ox_lib') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

RegisterNetEvent('sv_compat:notify', function(payload)
	if GetResourceState('ox_lib') ~= 'started' then return end
	local data = payload or {}
	lib.notify({
		title = data.title or '',
		description = data.message or '',
		type = data.type or 'inform',
		duration = data.duration or (Config.Notify and Config.Notify.duration) or 5000,
		position = data.position or (Config.Notify and Config.Notify.position) or 'top-right',
	})
end)

print('[sv_compat] notify backend (client): ox_lib')
