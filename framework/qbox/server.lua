local Config = rawget(_G, 'Config') or {}
if Config.Framework ~= 'qbox' then return end
if GetResourceState('qbx_core') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

local core = exports['qbx_core']
Compat.Framework = Compat.Framework or {}
Compat.Framework.backend = 'qbox'
Compat.Framework.Core = core

Compat.Framework.GetPlayer = function(src)
	if not core or not core.GetPlayer then return nil end
	return core:GetPlayer(src)
end

Compat.Framework.GetIdentifier = function(src)
	local player = Compat.Framework.GetPlayer(src)
	if player and player.PlayerData and player.PlayerData.citizenid then
		return player.PlayerData.citizenid
	end
	return nil
end

Compat.Framework.GetMoney = Compat.Framework.GetMoney or function(src, account)
	account = account or 'cash'
	local player = Compat.Framework.GetPlayer(src)
	if not player or not player.PlayerData or not player.PlayerData.money then return 0 end
	local acct = account == 'money' and 'cash' or account
	return player.PlayerData.money[acct] or 0
end

Compat.Framework.RemoveMoney = Compat.Framework.RemoveMoney or function(src, account, amount)
	account = account or 'cash'
	amount = amount or 0
	local player = Compat.Framework.GetPlayer(src)
	if not player or not player.Functions or not player.Functions.RemoveMoney then return false end
	local acct = account == 'money' and 'cash' or account
	return player.Functions.RemoveMoney(acct, amount) ~= false
end

Compat.Framework.AddMoney = Compat.Framework.AddMoney or function(src, account, amount)
	account = account or 'cash'
	amount = amount or 0
	local player = Compat.Framework.GetPlayer(src)
	if not player or not player.Functions or not player.Functions.AddMoney then return false end
	local acct = account == 'money' and 'cash' or account
	player.Functions.AddMoney(acct, amount)
	return true
end

Compat.GetMoney = Compat.GetMoney or Compat.Framework.GetMoney
Compat.RemoveMoney = Compat.RemoveMoney or Compat.Framework.RemoveMoney
Compat.AddMoney = Compat.AddMoney or Compat.Framework.AddMoney

-- Set player job
Compat.Framework.SetJob = Compat.Framework.SetJob or function(src, jobName, jobGrade)
	local player = Compat.Framework.GetPlayer(src)
	if not player or not player.Functions or not player.Functions.SetJob then return false end
	player.Functions.SetJob(jobName, tonumber(jobGrade) or 0)
	return true
end

-- Set offline player job (database)
Compat.Framework.SetJobOffline = Compat.Framework.SetJobOffline or function(identifier, jobName, jobGrade)
	if not identifier or not jobName then return false end
	MySQL.execute('UPDATE players SET job = ?, grade = ? WHERE citizenid = ?', 
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
	exports.oxmysql:query('SELECT charinfo FROM players WHERE citizenid = ?', {identifier}, function(result)
		if result and #result > 0 and result[1].charinfo then
			local charinfo = json.decode(result[1].charinfo)
			if charinfo and charinfo.firstname and charinfo.lastname then
				local name = charinfo.firstname .. ' ' .. charinfo.lastname
				if Config.Debug then print('[sv_compat] GetCharacterName: Found name: ' .. tostring(name)) end
				if cb then cb(name) end
			else
				if Config.Debug then print('[sv_compat] GetCharacterName: Charinfo exists but no name fields') end
				if cb then cb(nil) end
			end
		else
			if Config.Debug then print('[sv_compat] GetCharacterName: No player found for identifier: ' .. tostring(identifier)) end
			if cb then cb(nil) end
		end
	end)
end

print('[sv_compat] framework backend: qbox')
