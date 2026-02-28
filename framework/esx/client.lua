local Config = rawget(_G, 'Config') or {}
if Config.Framework ~= 'esx' then return end
if GetResourceState('es_extended') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local ESX = exports['es_extended'] and exports['es_extended']:getSharedObject()
if not ESX then return end

CompatClient.Framework = CompatClient.Framework or {}
CompatClient.Framework.backend = 'esx'
CompatClient.Framework.Core = ESX

print('[sv_compat] framework backend (client): esx')
