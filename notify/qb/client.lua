local Config = rawget(_G, 'Config') or {}
if Config.NotifyBackend ~= 'qb' then return end
if GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') ~= 'started' then return end

RegisterNetEvent('sv_compat:notify', function(payload)
	local data = payload or {}
	local title = data.title or ''
	local msg = data.message or ''
	local ntype = data.type or 'primary'
	local dur = data.duration or (Config.Notify and Config.Notify.duration) or 5000
	TriggerEvent('QBCore:Notify', title ~= '' and (title .. ' - ' .. msg) or msg, ntype, dur)
end)

print('[sv_compat] notify backend (client): qb')
