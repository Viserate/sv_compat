local Config = rawget(_G, 'Config') or {}
if Config.Framework ~= 'esx' then return end
if GetResourceState('es_extended') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

local ESX = exports['es_extended'] and exports['es_extended']:getSharedObject()
if not ESX then return end

Compat.Framework = Compat.Framework or {}
Compat.Framework.backend = 'esx'
Compat.Framework.Core = ESX

Compat.Framework.GetPlayer = function(src)
	if not ESX or not ESX.GetPlayerFromId then return nil end
	return ESX.GetPlayerFromId(src)
end

Compat.Framework.GetIdentifier = function(src)
	local xPlayer = Compat.Framework.GetPlayer(src)
	return xPlayer and xPlayer.getIdentifier and xPlayer.getIdentifier() or nil
end

Compat.Framework.GetMoney = Compat.Framework.GetMoney or function(src, account)
	account = account or 'money'
	local xPlayer = Compat.Framework.GetPlayer(src)
	if not xPlayer then return 0 end
	if xPlayer.getAccount then
		local acct = xPlayer.getAccount(account)
		if acct and acct.money then return acct.money end
	end
	if xPlayer.getMoney then return xPlayer.getMoney() end
	return 0
end

Compat.Framework.RemoveMoney = Compat.Framework.RemoveMoney or function(src, account, amount)
	account = account or 'money'
	amount = amount or 0
	local xPlayer = Compat.Framework.GetPlayer(src)
	if not xPlayer then return false end
	if xPlayer.removeAccountMoney then
		return xPlayer.removeAccountMoney(account, amount) ~= false
	end
	if xPlayer.removeMoney then
		return xPlayer.removeMoney(amount) ~= false
	end
	return false
end

Compat.Framework.AddMoney = Compat.Framework.AddMoney or function(src, account, amount)
	account = account or 'money'
	amount = amount or 0
	local xPlayer = Compat.Framework.GetPlayer(src)
	if not xPlayer then return false end
	if xPlayer.addAccountMoney then
		xPlayer.addAccountMoney(account, amount)
		return true
	end
	if xPlayer.addMoney then
		xPlayer.addMoney(amount)
		return true
	end
	return false
end

Compat.GetMoney = Compat.GetMoney or Compat.Framework.GetMoney
Compat.RemoveMoney = Compat.RemoveMoney or Compat.Framework.RemoveMoney
Compat.AddMoney = Compat.AddMoney or Compat.Framework.AddMoney

-- Set player job
Compat.Framework.SetJob = Compat.Framework.SetJob or function(src, jobName, jobGrade)
	local xPlayer = Compat.Framework.GetPlayer(src)
	if not xPlayer or not xPlayer.setJob then return false end
	xPlayer.setJob(jobName, tonumber(jobGrade) or 0)
	return true
end

-- Set offline player job (database)
Compat.Framework.SetJobOffline = Compat.Framework.SetJobOffline or function(identifier, jobName, jobGrade)
	if not identifier or not jobName then return false end
	MySQL.execute('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', 
		{jobName, tonumber(jobGrade) or 0, identifier})
	return true
end

-- Get character name by identifier
Compat.Framework.GetCharacterName = Compat.Framework.GetCharacterName or function(identifier, cb)
	if not identifier then 
		if Config.Debug then print('[sv_compat] GetCharacterName: No identifier provided') end
		if cb then cb(nil) end
		return 
	end
	if Config.Debug then print('[sv_compat] GetCharacterName: Querying for identifier: ' .. tostring(identifier)) end
	exports.oxmysql:query('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier}, function(result)
		if Config.Debug then
			print('[sv_compat] GetCharacterName: Query returned ' .. tostring(result and #result or 0) .. ' results')
			if result and #result > 0 then
				print('[sv_compat] GetCharacterName: firstname = ' .. tostring(result[1].firstname))
				print('[sv_compat] GetCharacterName: lastname = ' .. tostring(result[1].lastname))
			end
		end
		if result and #result > 0 then
			local name = (result[1].firstname or '') .. ' ' .. (result[1].lastname or '')
			name = name:match('^%s*(.-)%s*$') -- trim whitespace
			if Config.Debug then print('[sv_compat] GetCharacterName: Final name: "' .. tostring(name) .. '"') end
			if cb then cb(name) end
		else
			if Config.Debug then print('[sv_compat] GetCharacterName: No user found for identifier: ' .. tostring(identifier)) end
			if cb then cb(nil) end
		end
	end)
end

-- Usable items (ESX RegisterUsableItem)
local esxUsableHandlers = {}

Compat.RegisterUsableItem = Compat.RegisterUsableItem or function(item, cb)
	if not ESX or not ESX.RegisterUsableItem then return false end
	if not item or not cb then return false end
	local name = tostring(item)
	if esxUsableHandlers[name] then return true end

	ESX.RegisterUsableItem(name, function(source, esxItem)
		local meta = nil
		if esxItem then
			meta = esxItem.metadata or esxItem.info or esxItem.data
		end
		local status, res = pcall(cb, source, meta, 'use', esxItem, nil, nil, nil)
		if not status then
			print(('[sv_compat] ESX usable handler error for %s: %s'):format(name, res))
		end
		return res
	end)

	esxUsableHandlers[name] = true
	print(('[sv_compat] esx usable registered via RegisterUsableItem: %s'):format(name))
	return true
end

print('[sv_compat] framework backend: esx')

-- Debug: Verify GetCharacterName exists
if Config.Debug then
	print('[sv_compat] ESX GetCharacterName function registered: ' .. tostring(Compat.Framework.GetCharacterName ~= nil))
end
