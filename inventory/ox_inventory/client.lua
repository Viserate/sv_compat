local Config = rawget(_G, 'Config') or {}
if Config.Inventory ~= 'ox_inventory' and Config.Inventory ~= 'ox-inventory' then return end

local function initCompat()
	local waited = 0
	while GetResourceState('ox_inventory') ~= 'started' and waited < 10000 do
		Wait(200)
		waited = waited + 200
	end
	if GetResourceState('ox_inventory') ~= 'started' then return end

	local CompatClient = _G.SV_Compat_Client
	if not CompatClient then return end

	CompatClient.Inventory = CompatClient.Inventory or {}
	CompatClient.Inventory.backend = 'ox_inventory'

CompatClient.Inventory.GetItemCount = function(source, item, metadata)
	local name = item
	local meta = metadata
	if type(source) ~= 'number' then
		if source == nil then
			name = item
			meta = metadata
		else
			name = source
			meta = item
		end
	end
	if exports and exports.ox_inventory then
		if exports.ox_inventory.GetItemCount then
			local ok, res = pcall(function()
				return exports.ox_inventory:GetItemCount(name, meta)
			end)
			if ok then return res or 0 end
		end
		if exports.ox_inventory.Search then
			local ok, res = pcall(function()
				return exports.ox_inventory:Search('count', name)
			end)
			if ok then return res or 0 end
		end
	end
	return 0
end

CompatClient.Inventory.HasItem = function(source, item, amountOrMeta)
	local amount = type(amountOrMeta) == 'number' and amountOrMeta or 1
	local meta = type(amountOrMeta) == 'table' and amountOrMeta or nil
	local count = CompatClient.Inventory.GetItemCount(source, item, meta)
	return (count or 0) >= amount
end

local itemNames = nil

CompatClient.Inventory.GetItemLabel = function(item)
	if not item or item == '' then return item end
	if itemNames == nil and exports and exports.ox_inventory then
		local ok, items = pcall(function()
			return exports.ox_inventory:Items()
		end)
		if ok and type(items) == 'table' then
			itemNames = {}
			for name, data in pairs(items) do
				itemNames[name] = data.label
			end
		end
	end
	if itemNames and itemNames[item] then
		return itemNames[item]
	end
	return item
end

print('[sv_compat] inventory backend (client): ox_inventory')
end

CreateThread(initCompat)

local Debug = (GetConvar('sv_compat_debug', 'false') == 'true') or (Config and Config.Debug == true)

local function tryOpenShop(id, shopData)
	local ok = false
	if exports and exports.ox_inventory then
		local payload = nil
		if type(shopData) == 'table' then
			payload = {
				id = shopData.id or id,
				shopId = shopData.shopId or id,
				type = shopData.type or shopData.shopType,
				label = shopData.label or shopData.name,
				slots = shopData.slots,
				items = shopData.items,
				groups = shopData.groups,
				coords = shopData.coords,
				distance = shopData.distance
			}
		end
		local attempts = {
			{ fn = 'openShop', args = { id }, label = 'openShop id' },
			{ fn = 'OpenShop', args = { id }, label = 'OpenShop id' },
			payload and { fn = 'openInventory', args = { 'shop', payload }, label = 'openInventory payload' } or nil,
			{ fn = 'openInventory', args = { 'shop', { id = id } }, label = 'openInventory id' },
			{ fn = 'openInventory', args = { 'shop', { type = id } }, label = 'openInventory type' },
			{ fn = 'openInventory', args = { 'shop', { shopId = id } }, label = 'openInventory shopId' },
			{ fn = 'openInventory', args = { 'shop', id }, label = 'openInventory string' },
			payload and { fn = 'OpenInventory', args = { 'shop', payload }, label = 'OpenInventory payload' } or nil,
			{ fn = 'OpenInventory', args = { 'shop', { id = id } }, label = 'OpenInventory id' },
			{ fn = 'OpenInventory', args = { 'shop', { type = id } }, label = 'OpenInventory type' },
			{ fn = 'OpenInventory', args = { 'shop', { shopId = id } }, label = 'OpenInventory shopId' },
			{ fn = 'OpenInventory', args = { 'shop', id }, label = 'OpenInventory string' }
		}
		for _, attempt in ipairs(attempts) do
			if not attempt then
				goto continue
			end
			if ok then break end
			local okGet, fn = pcall(function() return exports.ox_inventory[attempt.fn] end)
			if okGet and type(fn) == 'function' then
				local ok2, res = pcall(function()
					return fn(exports.ox_inventory, table.unpack(attempt.args))
				end)
				ok = ok or (ok2 and res == true)
				if Debug then
					print(('[sv_compat] client %s id=%s ok=%s res=%s'):format(attempt.label, tostring(id), tostring(ok2), tostring(res)))
				end
			elseif Debug then
				print(('[sv_compat] client %s missing export'):format(attempt.label))
			end
			::continue::
		end
	end
	return ok
end

RegisterNetEvent('sv_compat:inventory:openShop', function(shopId, shopData)
	if shopData and exports and exports.ox_inventory then
		local okReg, fn = pcall(function() return exports.ox_inventory.RegisterShop end)
		if okReg and type(fn) == 'function' then
			local ok2, res = pcall(function()
				return fn(exports.ox_inventory, shopId, shopData)
			end)
			if Debug then
				print(('[sv_compat] client RegisterShop id=%s ok=%s res=%s'):format(tostring(shopId), tostring(ok2), tostring(res)))
			end
		end
		okReg, fn = pcall(function() return exports.ox_inventory.registerShop end)
		if okReg and type(fn) == 'function' then
			local ok2, res = pcall(function()
				return fn(exports.ox_inventory, shopId, shopData)
			end)
			if Debug then
				print(('[sv_compat] client registerShop id=%s ok=%s res=%s'):format(tostring(shopId), tostring(ok2), tostring(res)))
			end
		end
	end
	local ok = tryOpenShop(shopId, shopData)
	if Debug then
		print(('[sv_compat] client openShop event id=%s ok=%s'):format(tostring(shopId), tostring(ok)))
	end
end)

print('[sv_compat] inventory backend (client): ox_inventory')
