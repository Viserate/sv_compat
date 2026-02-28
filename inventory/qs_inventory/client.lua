local Config = rawget(_G, 'Config') or {}
if Config.Inventory ~= 'qs-inventory' and Config.Inventory ~= 'qs_inventory' then return end
if GetResourceState('qs-inventory') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

CompatClient.Inventory = CompatClient.Inventory or {}
CompatClient.Inventory.backend = 'qs-inventory'

CompatClient.Inventory.InInventory = function()
	return exports['qs-inventory']:inInventory() or false
end

CompatClient.Inventory.SetInventoryDisabled = function(state)
	exports['qs-inventory']:setInventoryDisabled(state and true or false)
	return true
end

CompatClient.Inventory.Search = function(item)
	return exports['qs-inventory']:Search(item)
end

CompatClient.Inventory.GetUserInventory = function()
	return exports['qs-inventory']:getUserInventory()
end

CompatClient.Inventory.SetInClothing = function(state)
	exports['qs-inventory']:setInClothing(state and true or false)
	return true
end

print('[sv_compat] inventory backend (client): qs-inventory')
