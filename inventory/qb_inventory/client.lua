local Config = rawget(_G, 'Config') or {}
if Config.Inventory ~= 'qb-inventory' and Config.Inventory ~= 'qb_inventory' then return end
if GetResourceState('qb-inventory') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

CompatClient.Inventory = CompatClient.Inventory or {}
CompatClient.Inventory.backend = 'qb-inventory'

print('[sv_compat] inventory backend (client): qb-inventory')
