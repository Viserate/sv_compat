local Config = rawget(_G, 'Config') or {}
if Config.Inventory ~= 'qs-inventory' and Config.Inventory ~= 'qs_inventory' then return end
if GetResourceState('qs-inventory') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

local qs = exports['qs-inventory']
if not qs then return end

Compat.Inventory = Compat.Inventory or {}
Compat.Inventory.backend = 'qs-inventory'

Compat.Inventory.AddItem = function(src, item, count, metadata, slot)
	return qs:AddItem(src, item, count or 1, slot, metadata) ~= false
end
Compat.AddItem = Compat.Inventory.AddItem

Compat.Inventory.RemoveItem = function(src, item, count, metadata, slot)
	return qs:RemoveItem(src, item, count or 1, slot, metadata) ~= false
end
Compat.RemoveItem = Compat.Inventory.RemoveItem

Compat.Inventory.HasItem = function(src, item, metadata)
	local total = qs:GetItemTotalAmount(src, item)
	return (total or 0) > 0
end
Compat.HasItem = Compat.Inventory.HasItem

Compat.Inventory.GetItemCount = function(src, item, metadata)
	return qs:GetItemTotalAmount(src, item) or 0
end
Compat.GetItemCount = Compat.Inventory.GetItemCount

Compat.Inventory.CanCarryItem = function(src, item, count)
	return qs:CanCarryItem(src, item, count or 1) ~= false
end
Compat.CanCarryItem = Compat.Inventory.CanCarryItem

Compat.Inventory.RegisterUsableItem = function(item, cb)
	if not item or not cb then return false end
	qs:CreateUsableItem(item, cb)
	return true
end
Compat.RegisterUsableItem = Compat.Inventory.RegisterUsableItem

Compat.Inventory.RegisterStash = function(src, id, slots, weight)
	return qs:RegisterStash(src or 0, id, slots or 50, weight or 1000) ~= false
end
Compat.RegisterStash = Compat.Inventory.RegisterStash

Compat.Inventory.AddToStash = function(stashId, item, amount, slot, info, stashSlots, stashWeight)
	return qs:AddItemIntoStash(stashId, item, amount or 1, slot, info, stashSlots, stashWeight) ~= false
end
Compat.AddToStash = Compat.Inventory.AddToStash

Compat.Inventory.RemoveFromStash = function(stashId, item, amount, slot, stashSlots, stashWeight)
	return qs:RemoveItemIntoStash(stashId, item, amount or 1, slot, stashSlots, stashWeight) ~= false
end
Compat.RemoveFromStash = Compat.Inventory.RemoveFromStash

Compat.Inventory.GetStashItems = function(stashId)
	return qs:GetStashItems(stashId)
end
Compat.GetStashItems = Compat.Inventory.GetStashItems

Compat.Inventory.OpenInventory = function(src)
	TriggerClientEvent('qs-inventory:client:openInventory', src)
	return true
end
Compat.OpenInventory = Compat.Inventory.OpenInventory

Compat.Inventory.OpenStash = function(src, stashId)
	TriggerClientEvent('qs-inventory:client:openInventory', src, 'stash', stashId)
	return true
end
Compat.OpenStash = Compat.Inventory.OpenStash

Compat.Inventory.GetPlayerWeight = function(src)
	return 0
end
Compat.GetPlayerWeight = Compat.Inventory.GetPlayerWeight

Compat.Inventory.GetMaxWeight = function(src)
	return 0
end
Compat.GetMaxWeight = Compat.Inventory.GetMaxWeight

Compat.Inventory.IsWeapon = function(item)
	return false
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
	local inv = qs.GetInventory and qs.GetInventory(qs, src)
	if not inv then return {} end
	local list = {}
	for _, item in pairs(inv) do
		if item and item.name then
			list[#list + 1] = {
				name = item.name,
				count = item.amount or item.count or item.quantity or 0,
				slot = item.slot,
				metadata = item.info or item.metadata,
			}
		end
	end
	return list
end
Compat.ListItems = Compat.Inventory.ListItems

print('[sv_compat] inventory backend: qs-inventory')
