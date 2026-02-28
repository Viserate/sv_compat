local Config = rawget(_G, 'Config') or {}

local Compat = _G.SV_Compat or {
	Inventory = {},
	Progress = {},
	Target = {},
	Notify = {},
	Dispatch = {},
	Framework = {},
	TextUI = {},
}

_G.SV_Compat = Compat

Compat.Progress = Compat.Progress or {}
Compat.Progress.Start = Compat.Progress.Start or function(src, data)
	if Compat.Progress.Show then
		return Compat.Progress.Show(src, data)
	end
	if not src or src == 0 then return false end
	TriggerClientEvent('sv_compat:progress', src, data or {})
	return true
end

if not Compat.Progress.Cancel then
	Compat.Progress.Cancel = function(src)
		if not src or src == 0 then return false end
		TriggerClientEvent('sv_compat:progressCancel', src)
		return true
	end
end

exports('GetCompat', function()
	return Compat
end)

-- Basic readiness/identifier helpers so consumers (e.g., sv_illegaldrops) have a stable API
Compat.IsPlayerReady = Compat.IsPlayerReady or function(playerId)
	if not playerId then return false end
	local ping = GetPlayerPing(playerId)
	return ping and ping >= 0
end

Compat.GetIdentifier = Compat.GetIdentifier or function(playerId)
	if Compat.Framework and Compat.Framework.GetIdentifier then
		local ok, id = pcall(Compat.Framework.GetIdentifier, playerId)
		if ok and id then return id end
	end
	if not playerId then return nil end
	local first = GetPlayerIdentifier(playerId, 0)
	return first
end

-- Server-side target helpers: broadcast to clients so target backends can add/remove entries
local function dispatchTargetEvent(eventName, targets, ...)
	local payload = { ... }
	if targets == nil or targets == 0 then
		TriggerClientEvent(eventName, -1, table.unpack(payload))
		return true
	end
	if type(targets) == 'table' then
		for _, playerId in ipairs(targets) do
			if playerId and playerId > 0 then
				TriggerClientEvent(eventName, playerId, table.unpack(payload))
			end
		end
		return true
	end
	if type(targets) == 'number' and targets > 0 then
		TriggerClientEvent(eventName, targets, table.unpack(payload))
		return true
	end
	return false
end

Compat.Target = Compat.Target or {}
Compat.Target.backend = Compat.Target.backend or Config.Target

Compat.Target.AddModel = Compat.Target.AddModel or function(models, options, targets)
	if not models then return false end
	return dispatchTargetEvent('sv_compat:target:addModel', targets, models, options)
end

Compat.Target.RemoveModel = Compat.Target.RemoveModel or function(models, targets)
	if not models then return false end
	return dispatchTargetEvent('sv_compat:target:removeModel', targets, models)
end

Compat.Target.AddEntity = Compat.Target.AddEntity or function(entities, options, targets)
	if not entities then return false end
	return dispatchTargetEvent('sv_compat:target:addEntity', targets, entities, options)
end

Compat.Target.RemoveEntity = Compat.Target.RemoveEntity or function(entities, targets)
	if not entities then return false end
	return dispatchTargetEvent('sv_compat:target:removeEntity', targets, entities)
end

print('[sv_compat] server initialized')
