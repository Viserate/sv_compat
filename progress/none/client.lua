local Config = rawget(_G, 'Config') or {}
if Config.ProgressBackend ~= 'none' then return end

RegisterNetEvent('sv_compat:progress', function(_)
	-- no-op
end)

RegisterNetEvent('sv_compat:progressCancel', function()
	-- no-op
end)

print('[sv_compat] progress backend (client): none')
