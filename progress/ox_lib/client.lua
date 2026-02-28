local Config = rawget(_G, 'Config') or {}
if Config.ProgressBackend ~= 'ox_lib' then return end
if GetResourceState('ox_lib') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local active = false

RegisterNetEvent('sv_compat:progress', function(data)
	if GetResourceState('ox_lib') ~= 'started' then return end
	active = true
	lib.progressCircle(data or {})
	active = false
end)

RegisterNetEvent('sv_compat:progressCancel', function()
	if GetResourceState('ox_lib') ~= 'started' then return end
	if active then
		lib.cancelProgress()
		active = false
	end
end)

CompatClient.Progress = CompatClient.Progress or {}
CompatClient.Progress.backend = 'ox_lib'

print('[sv_compat] progress backend (client): ox_lib')
