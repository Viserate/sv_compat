local Config = rawget(_G, 'Config') or {}
if Config.Framework ~= 'qbox' then return end
if GetResourceState('qbx_core') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local core = exports['qbx_core']
CompatClient.Framework = CompatClient.Framework or {}
CompatClient.Framework.backend = 'qbox'
CompatClient.Framework.Core = core

print('[sv_compat] framework backend (client): qbox')
