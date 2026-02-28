local Config = rawget(_G, 'Config') or {}
if Config.Inventory ~= 'ox_inventory' and Config.Inventory ~= 'ox-inventory' then return end

local Debug = (GetConvar('sv_compat_debug', 'false') == 'true') or (Config and Config.Debug == true)

local function getExport(name)
	local ok, res = pcall(function()
		return exports.ox_inventory[name]
	end)
	if ok and type(res) == 'function' then return res end
	return nil
end

local Compat = _G.SV_Compat
if not Compat then return end

local itemHandlers = {}
local initialized = false
local ox = nil
local phoneItems = {
	burner_phone = true,
}

local function firePhoneOpen(src, itemName)
	if src and src > 0 and phoneItems[itemName] then
		TriggerClientEvent('sv_illegaldrops:openPhone', src)
	end
end

local function waitForOx()
	local state = GetResourceState('ox_inventory')
	if state ~= 'started' then
		if state == 'starting' then
			local waited = 0
			while waited < 5000 and GetResourceState('ox_inventory') == 'starting' do
				Wait(100)
				waited = waited + 100
			end
		else
			print('[sv_compat] ox_inventory not started (state=' .. tostring(state) .. ')')
			return false
		end
	end

	local waited = 0
	while waited <= 5000 do
		ox = exports.ox_inventory
		if ox then return true end
		Wait(100)
		waited = waited + 100
	end
	print('[sv_compat] ox_inventory export not available after wait')
	return false
end

local function initOx()
	if initialized then return true end
	if not waitForOx() then return false end

	Compat.Inventory = Compat.Inventory or {}
	Compat.Inventory.backend = 'ox_inventory'

	Compat.Inventory.AddItem = function(src, item, count, metadata)
		return ox:AddItem(src, item, count or 1, metadata) ~= false
	end
	Compat.AddItem = Compat.Inventory.AddItem

	Compat.Inventory.RemoveItem = function(src, item, count, metadata, slot)
		return ox:RemoveItem(src, item, count or 1, metadata, slot) ~= false
	end
	Compat.RemoveItem = Compat.Inventory.RemoveItem

	Compat.Inventory.HasItem = function(src, item, metadata)
		return (ox:GetItemCount(src, item, metadata) or 0) > 0
	end
	Compat.HasItem = Compat.Inventory.HasItem

	Compat.Inventory.GetItemCount = function(src, item, metadata)
		return ox:GetItemCount(src, item, metadata) or 0
	end
	Compat.GetItemCount = Compat.Inventory.GetItemCount

	-- Usable items via ox_inventory export routing
	Compat.Inventory.RegisterUsableItem = function(item, cb)
		if not item or not cb then return false end
		local name = tostring(item)
		if itemHandlers[name] then return true end

		itemHandlers[name] = cb

		local ok, err = pcall(function()
			exports(name, function(event, itemData, inventory, slot, data)
				local src = (inventory and (inventory.source or (inventory.player and inventory.player.source))) or 0
				local meta = (slot and slot.metadata) or (itemData and itemData.metadata) or data or itemData

				print(('[sv_compat] ox usable fired item=%s src=%s slot=%s event=%s'):format(name, tostring(src), tostring(slot and slot.slot or slot), tostring(event)))
				firePhoneOpen(src, name)

				local handler = itemHandlers[name]
				if handler then
					local status, res = pcall(handler, src, meta, event, itemData, inventory, slot, data)
					if not status then
						print(('[sv_compat] ox_inventory handler error for %s: %s'):format(name, res))
					end
					return res
				end
				return false
			end)
		end)

		if not ok then
			print(('[sv_compat] ox_inventory export registration failed for %s: %s'):format(name, err))
			itemHandlers[name] = nil
			return false
		end

		print(('[sv_compat] ox_inventory usable routed via export: %s'):format(name))
		return true
	end
	-- Do not override an existing framework-level RegisterUsableItem (e.g., ESX) if already set
	if not Compat.RegisterUsableItem then
		Compat.RegisterUsableItem = Compat.Inventory.RegisterUsableItem
	end

	-- Fallback: hook ox_inventory use events directly if available (newer ox versions)
	if ox and ox.registerHook then
		local function hookUse(eventName)
			local ok, err = pcall(function()
				return ox:registerHook(eventName, function(payload)
					local itemName = payload and payload.name or payload and payload.item or payload and payload.itemName
					local handler = itemName and itemHandlers[tostring(itemName)]
					if not handler then return end
					local src = payload.source or 0
					local meta = (payload.slot and payload.slot.metadata) or payload.metadata or payload.info or payload
					local slot = payload.slot
					print(('[sv_compat] ox hook %s fired item=%s src=%s slot=%s'):format(eventName, tostring(itemName), tostring(src), tostring(slot and slot.slot or slot)))
					firePhoneOpen(src, itemName)
					local status, res = pcall(handler, src, meta, eventName, payload.item, payload.inventory, slot, payload)
					if not status then
						print(('[sv_compat] ox_inventory handler error for %s via hook: %s'):format(itemName, res))
					end
					return res
				end, { itemFilter = nil })
			end)
			if not ok then
				print(('[sv_compat] ox_inventory registerHook %s failed: %s'):format(eventName, err))
			end
		end

		hookUse('useItem')
		hookUse('usedItem')
	end

	Compat.Inventory.OpenInventory = function(src)
		TriggerClientEvent('ox_inventory:openInventory', src, 'player', src)
		return true
	end
	Compat.OpenInventory = Compat.Inventory.OpenInventory

	Compat.Inventory.OpenStash = function(src, stashId)
		TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stashId)
		return true
	end
	Compat.OpenStash = Compat.Inventory.OpenStash

	Compat.Inventory.RegisterShop = function(id, data)
		local fn = getExport('RegisterShop')
		if fn then
			local ok2, res = pcall(function()
				return fn(ox, id, data)
			end)
			if Debug then
				print(('[sv_compat] RegisterShop(RegisterShop) id=%s ok=%s res=%s'):format(tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 then return res ~= false end
		end
		fn = getExport('registerShop')
		if fn then
			local ok2, res = pcall(function()
				return fn(ox, id, data)
			end)
			if Debug then
				print(('[sv_compat] RegisterShop(registerShop) id=%s ok=%s res=%s'):format(tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 then return res ~= false end
		end
		if Debug then
			print(('[sv_compat] RegisterShop failed id=%s; exports RegisterShop=%s registerShop=%s'):format(tostring(id), tostring(type(getExport('RegisterShop'))), tostring(type(getExport('registerShop')))))
		end
		return false
	end
	Compat.RegisterShop = Compat.Inventory.RegisterShop

	Compat.Inventory.OpenShop = function(src, id, data)
		local payload = {
			id = id,
			shopId = id
		}
		if type(data) == 'table' then
			payload.id = data.id or payload.id
			payload.shopId = data.shopId or payload.shopId
			payload.type = data.type or data.shopType
			payload.shopType = data.shopType or payload.shopType
			payload.label = data.label or data.name
			payload.slots = data.slots or payload.slots
			payload.items = data.items or payload.items
			payload.groups = data.groups or payload.groups
			payload.coords = data.coords or payload.coords
			payload.distance = data.distance or payload.distance
		end
		local fn = getExport('OpenShop')
		if fn then
			local ok2, res = pcall(function()
				return fn(ox, src, id)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(OpenShop src,id) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
			ok2, res = pcall(function()
				return fn(ox, id, src)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(OpenShop id,src) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
			ok2, res = pcall(function()
				return fn(ox, id)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(OpenShop id) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
		end
		fn = getExport('openShop')
		if fn then
			local ok2, res = pcall(function()
				return fn(ox, src, id)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(openShop src,id) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
			ok2, res = pcall(function()
				return fn(ox, id, src)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(openShop id,src) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
			ok2, res = pcall(function()
				return fn(ox, id)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(openShop id) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
		end
		local fn = getExport('OpenInventory')
		if fn then
			local ok2, res = pcall(function()
				return fn(ox, src, 'shop', payload)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(OpenInventory id) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
			if payload.type then
				ok2, res = pcall(function()
					return fn(ox, src, 'shop', { type = payload.type, shopId = payload.shopId, id = payload.id, coords = payload.coords, distance = payload.distance, label = payload.label, slots = payload.slots, items = payload.items, groups = payload.groups })
				end)
				if Debug then
					print(('[sv_compat] OpenShop(OpenInventory type) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
				end
				if ok2 and res ~= false then return true end
			end
		end
		fn = getExport('openInventory')
		if fn then
			local ok2, res = pcall(function()
				return fn(ox, src, 'shop', payload)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(openInventory id) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
			if payload.type then
				ok2, res = pcall(function()
					return fn(ox, src, 'shop', { type = payload.type, shopId = payload.shopId, id = payload.id, coords = payload.coords, distance = payload.distance, label = payload.label, slots = payload.slots, items = payload.items, groups = payload.groups })
				end)
				if Debug then
					print(('[sv_compat] OpenShop(openInventory type) src=%s id=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(ok2), tostring(res)))
				end
				if ok2 and res ~= false then return true end
			end
		end
		if Debug then
			print(('[sv_compat] OpenShop failed src=%s id=%s; exports OpenInventory=%s openInventory=%s'):format(tostring(src), tostring(id), tostring(type(getExport('OpenInventory'))), tostring(type(getExport('openInventory')))))
		end
		local fnForce = getExport('forceOpenInventory') or getExport('ForceOpenInventory')
		if fnForce then
			local forceData = payload.type or payload.shopType or payload.shopId or payload.id or id
			local ok2, res = pcall(function()
				return fnForce(ox, src, 'shop', forceData)
			end)
			if Debug then
				print(('[sv_compat] OpenShop(forceOpenInventory) src=%s id=%s data=%s ok=%s res=%s'):format(tostring(src), tostring(id), tostring(forceData), tostring(ok2), tostring(res)))
			end
			if ok2 and res ~= false then return true end
		end
		local shopKey = payload.type or payload.shopType or payload.shopId or payload.id or id
		TriggerClientEvent('ox_inventory:openInventory', src, 'shop', shopKey)
		if Debug then
			print(('[sv_compat] OpenShop(event openInventory) src=%s shop=%s'):format(tostring(src), tostring(shopKey)))
		end
		TriggerClientEvent('sv_compat:inventory:openShop', src, id, data)
		return true
	end
	Compat.OpenShop = Compat.Inventory.OpenShop

	Compat.Inventory.RegisterStash = function(id, label, slots, weight, owner)
		return ox:RegisterStash(id, label or id, slots or 50, weight or 50000, owner) ~= false
	end
	Compat.RegisterStash = Compat.Inventory.RegisterStash

	-- Weight helpers using ox canCarryWeight where available; fallback to weight fields
	Compat.Inventory.GetPlayerWeight = function(src)
		if ox.CanCarryWeight then
			local inv = ox:GetInventory(src)
			if inv and inv.weight then return inv.weight end
		end
		if ox.GetPlayerWeight then return ox:GetPlayerWeight(src) or 0 end
		local inv = ox:GetInventory(src)
		if inv and inv.weight then return inv.weight end
		return 0
	end
	Compat.GetPlayerWeight = Compat.Inventory.GetPlayerWeight

	Compat.Inventory.GetMaxWeight = function(src)
		if ox.CanCarryWeight then
			local inv = ox:GetInventory(src)
			if inv and inv.maxWeight then return inv.maxWeight end
		end
		if ox.GetMaxWeight then return ox:GetMaxWeight(src) or 0 end
		local inv = ox:GetInventory(src)
		if inv and inv.maxWeight then return inv.maxWeight end
		return 0
	end
	Compat.GetMaxWeight = Compat.Inventory.GetMaxWeight

	-- Direct canCarryWeight wrapper: expects (source, weight)
	Compat.Inventory.CanCarryWeight = function(src, weight)
		if ox.CanCarryWeight then
			return ox:CanCarryWeight(src, weight)
		end

		-- Fallback: approximate using weight/maxWeight fields
		local inv = ox:GetInventory(src)
		if not inv or not inv.weight or not inv.maxWeight then return true end
		local cur = inv.weight or 0
		local max = inv.maxWeight or 0
		if max <= 0 then return true end
		return (cur + (weight or 0)) <= max
	end
	Compat.CanCarryWeight = Compat.Inventory.CanCarryWeight

	Compat.Inventory.CanCarryItem = function(src, item, count, metadata)
		if ox.CanCarryItem then
			return ox:CanCarryItem(src, item, count or 1, metadata)
		end
		if ox.CanCarryWeight then
			local info = ox:Items(item)
			local weight = info and (info.weight or 0) or 0
			return Compat.Inventory.CanCarryWeight(src, (weight or 0) * (count or 1))
		end
		return true
	end
	Compat.CanCarryItem = Compat.Inventory.CanCarryItem

	Compat.Inventory.GetItemWeight = function(item)
		local info = ox:Items(item)
		if not info then return nil end
		return info.weight or 0
	end
	Compat.GetItemWeight = Compat.Inventory.GetItemWeight

	Compat.Inventory.IsWeapon = function(item)
		local info = ox:Items(item)
		return info and info.type == 'weapon'
	end
	Compat.IsWeapon = Compat.Inventory.IsWeapon

	Compat.Inventory.GetWeaponAmmo = function(src, item)
		local entry = ox:GetItem(src, item, nil, true)
		if entry and entry.metadata and entry.metadata.ammo then
			return entry.metadata.ammo
		end
		return 0
	end
	Compat.GetWeaponAmmo = Compat.Inventory.GetWeaponAmmo

	Compat.Inventory.SetWeaponAmmo = function(src, item, ammo)
		local entry = ox:GetItem(src, item, nil, true)
		if entry and entry.slot then
			entry.metadata = entry.metadata or {}
			entry.metadata.ammo = ammo
			return ox:SetMetadata(src, entry.slot, entry.metadata) ~= false
		end
		return false
	end
	Compat.SetWeaponAmmo = Compat.Inventory.SetWeaponAmmo

	-- Generic metadata setter for consumers (e.g., burner_phone uses)
	Compat.Inventory.SetMetadata = function(src, slot, metadata)
		if not slot or not metadata then return false end
		return ox:SetMetadata(src, slot, metadata) ~= false
	end
	Compat.SetMetadata = Compat.Inventory.SetMetadata

	-- Expose GetItem so consumers can retrieve slot/metadata via compat
	Compat.Inventory.GetItem = function(src, item, metadata, returnTable)
		local entry = ox:GetItem(src, item, metadata, true)
		if not entry then return nil end
		if returnTable then return entry end
		return entry.count or entry.amount or entry.quantity or 0
	end
	Compat.GetItem = Compat.Inventory.GetItem

	-- Helper to find first matching item slot + metadata
	Compat.Inventory.FindFirst = function(src, item)
		local inv = ox:GetInventory(src)
		if not inv then return nil, nil end
		local bag = inv.items or inv.inventory or inv
		if not bag then return nil, nil end
		for _, entry in pairs(bag) do
			local name = entry.name or entry.label or entry.id
			if name == item then
				return entry.metadata, entry.slot or entry.slotId or entry.slot_id
			end
		end
		return nil, nil
	end
	Compat.FindFirst = Compat.Inventory.FindFirst

	Compat.Inventory.ListItems = function(src)
		local inv = ox:GetInventory(src)
		if not inv then return {} end
		local list = {}
		local bag = inv.items or inv.inventory or inv
		for _, item in pairs(bag) do
			local name = item.name or item.label or item.id or 'unknown'
			local count = item.count or item.amount or item.quantity or item.stack or 0
			list[#list + 1] = {
				name = name,
				count = count,
				slot = item.slot,
				metadata = item.metadata,
			}
		end
		return list
	end
	Compat.ListItems = Compat.Inventory.ListItems

	print(('[sv_compat] debug ox init: ListItems type=%s, Compat.Inventory type=%s'):format(
		type(Compat.Inventory.ListItems), type(Compat.Inventory)
	))

	print('[sv_compat] inventory backend: ox_inventory')
	initialized = true
	return true
end

	RegisterCommand('sv_compat_ox_exports', function(source)
		if source and source > 0 then return end
		local ok, exportsList = pcall(GetResourceExports, 'ox_inventory')
		if ok then
			print(('[sv_compat] ox_inventory exports: %s'):format(json.encode(exportsList or {})))
			return
		end
		local count = GetNumResourceMetadata('ox_inventory', 'exports') or 0
		local list = {}
		for i = 0, count - 1 do
			local val = GetResourceMetadata('ox_inventory', 'exports', i)
			if val then list[#list + 1] = val end
		end
		local version = GetResourceMetadata('ox_inventory', 'version', 0)
		print(('[sv_compat] ox_inventory exports (metadata): %s'):format(json.encode(list)))
		if version then
			print(('[sv_compat] ox_inventory version: %s'):format(tostring(version)))
		end
	end, true)

initOx()

AddEventHandler('onResourceStart', function(res)
	if res == 'ox_inventory' then
		Wait(0)
		initOx()
	end
end)
