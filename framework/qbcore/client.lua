local Config = rawget(_G, 'Config') or {}
if Config.Framework ~= 'qbcore' then return end
if GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local function getQB()
	if GetResourceState('qb-core') == 'started' and exports['qb-core'] then return exports['qb-core']:GetCoreObject() end
	if GetResourceState('qbx_core') == 'started' and exports['qbx_core'] then return exports['qbx_core'] end
	return nil
end

local QBCore = getQB()
if not QBCore then return end

CompatClient.Framework = CompatClient.Framework or {}
CompatClient.Framework.backend = 'qbcore'
CompatClient.Framework.Core = QBCore

print('[sv_compat] framework backend (client): qbcore')
