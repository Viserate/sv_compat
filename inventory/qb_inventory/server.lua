local Config = rawget(_G, 'Config') or {}
if Config.Inventory ~= 'qb-inventory' and Config.Inventory ~= 'qb_inventory' then return end
if GetResourceState('qb-inventory') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

local function getQB()
	if GetResourceState('qb-core') == 'started' and exports['qb-core'] then return exports['qb-core']:GetCoreObject() end
	if GetResourceState('qbx_core') == 'started' and exports['qbx_core'] then return exports['qbx_core'] end
	return nil
end

local qb = exports['qb-inventory']
if not qb then return end
local QBCore = getQB()

Compat.Inventory = Compat.Inventory or {}
Compat.Inventory.backend = 'qb-inventory'

Compat.Inventory.AddItem = function(src, item, count, metadata)
	return qb:AddItem(src, item, count or 1, false, metadata) ~= false
end
Compat.AddItem = Compat.Inventory.AddItem

Compat.Inventory.RemoveItem = function(src, item, count, metadata, slot)
	if metadata then
		return qb:RemoveItem(src, item, count or 1, nil, metadata) ~= false
	end
	return qb:RemoveItem(src, item, count or 1, slot, metadata) ~= false
end
Compat.RemoveItem = Compat.Inventory.RemoveItem

Compat.Inventory.HasItem = function(src, item, metadata)
	local data = qb:GetItem(src, item, metadata)
	return data ~= nil
end
Compat.HasItem = Compat.Inventory.HasItem

Compat.Inventory.GetItemCount = function(src, item, metadata)
	local data = qb:GetItemsByName(src, item)
	if not data then return 0 end
	local total = 0
	for _, v in pairs(data) do
		if not metadata or (v.info and v.info == metadata) then
			total = total + (v.amount or 0)
		end
	end
	return total
end
Compat.GetItemCount = Compat.Inventory.GetItemCount

Compat.Inventory.RegisterUsableItem = function(item, cb)
	if not item or not cb then return false end
	if QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
		QBCore.Functions.CreateUseableItem(item, cb)
		return true
	end
	return false
end
Compat.RegisterUsableItem = Compat.Inventory.RegisterUsableItem

Compat.Inventory.OpenInventory = function(src)
	TriggerClientEvent('qb-inventory:client:openInventory', src)
	return true
end
Compat.OpenInventory = Compat.Inventory.OpenInventory

Compat.Inventory.OpenStash = function(src, stashId)
	TriggerClientEvent('qb-inventory:client:openInventory', src, 'stash', { id = stashId })
	return true
end
Compat.OpenStash = Compat.Inventory.OpenStash

Compat.Inventory.RegisterStash = function()
	return true
end
Compat.RegisterStash = Compat.Inventory.RegisterStash

Compat.Inventory.GetPlayerWeight = function(src)
	if not QBCore then return 0 end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return 0 end
	return player.PlayerData.weight or 0
end
Compat.GetPlayerWeight = Compat.Inventory.GetPlayerWeight

Compat.Inventory.GetMaxWeight = function(src)
	if not QBCore then return 0 end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return 0 end
	return player.PlayerData.maxweight or 0
end
Compat.GetMaxWeight = Compat.Inventory.GetMaxWeight

Compat.Inventory.CanCarryItem = function(src, item, count)
	local info = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
	local itemWeight = info and (info.weight or 0) or 0
	if itemWeight <= 0 then return true end
	local cur = Compat.Inventory.GetPlayerWeight(src) or 0
	local max = Compat.Inventory.GetMaxWeight(src) or 0
	if max <= 0 then return true end
	return (cur + (itemWeight * (count or 1))) <= max
end
Compat.CanCarryItem = Compat.Inventory.CanCarryItem

Compat.Inventory.GetItemWeight = function(item)
	local info = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
	if not info then return nil end
	return info.weight or 0
end
Compat.GetItemWeight = Compat.Inventory.GetItemWeight

Compat.Inventory.IsWeapon = function(item)
	local info = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
	return info and info.type == 'weapon'
end
Compat.IsWeapon = Compat.Inventory.IsWeapon

Compat.Inventory.GetWeaponAmmo = function()
	return 0
end
Compat.GetWeaponAmmo = Compat.Inventory.GetWeaponAmmo

Compat.Inventory.SetWeaponAmmo = function()
	return false
end
Compat.SetWeaponAmmo = Compat.Inventory.SetWeaponAmmo

Compat.Inventory.ListItems = function(src)
	local player = QBCore and QBCore.Functions and QBCore.Functions.GetPlayer and QBCore.Functions.GetPlayer(src)
	if not player or not player.PlayerData or not player.PlayerData.items then return {} end
	local list = {}
	for slot, item in pairs(player.PlayerData.items) do
		if item and item.name then
			list[#list + 1] = {
				name = item.name,
				count = item.amount or item.count or 0,
				slot = slot,
				metadata = item.info or item.metadata,
			}
		end
	end
	return list
end
Compat.ListItems = Compat.Inventory.ListItems

print('[sv_compat] inventory backend: qb-inventory')
