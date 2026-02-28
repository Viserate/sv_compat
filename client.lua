local Config = rawget(_G, 'Config') or {}

local CompatClient = _G.SV_Compat_Client or {
	Target = {},
	Progress = {},
	TextUI = {},
	Notify = {},
	Zones = {},
}

_G.SV_Compat_Client = CompatClient

local function build17movAction(data)
	local control = data.controlDisables or data.controls or {}
	local animation = data.animation or {}
	local prop = data.prop or {}
	local propTwo = data.propTwo or {}
	local cancelAllowed = data.canCancel
	if cancelAllowed == nil then
		cancelAllowed = true
	end
	return {
		duration = tonumber(data.duration or data.length or data.time or 0) or 0,
		label = tostring(data.label or data.text or data.message or ''),
		useWhileDead = data.useWhileDead or false,
		canCancel = cancelAllowed,
		controlDisables = {
			disableMovement = control.disableMovement or data.disableMovement or false,
			disableCarMovement = control.disableCarMovement or data.disableCarMovement or false,
			disableMouse = control.disableMouse or data.disableMouse or false,
			disableCombat = control.disableCombat or data.disableCombat or false,
		},
		animation = {
			animDict = animation.animDict or data.animDict,
			anim = animation.anim or data.anim,
			flags = animation.flags or data.flags or 0,
			task = animation.task or data.task,
		},
		prop = {
			model = prop.model,
			bone = prop.bone,
			coords = prop.coords,
			rotation = prop.rotation,
		},
		propTwo = {
			model = propTwo.model,
			bone = propTwo.bone,
			coords = propTwo.coords,
			rotation = propTwo.rotation,
		},
	}
end

local function startProgressFallback(data)
	if GetResourceState('ox_lib') == 'started' and lib and lib.progressCircle then
		lib.progressCircle(data or {})
		return true
	end
	if GetResourceState('17mov_Hud') == 'started' then
		local ok = pcall(function()
			exports['17mov_Hud']:StartProgress(build17movAction(data or {}), nil, nil, function() end)
		end)
		return ok
	end
	return false
end

local function cancelProgressFallback()
	if GetResourceState('ox_lib') == 'started' and lib and lib.cancelProgress then
		lib.cancelProgress()
		return true
	end
	if GetResourceState('17mov_Hud') == 'started' then
		local ok = pcall(function()
			exports['17mov_Hud']:StopProgress()
		end)
		return ok
	end
	return false
end

CompatClient.Progress = CompatClient.Progress or {}
CompatClient.Progress.Start = CompatClient.Progress.Start or function(data)
	local cfg = rawget(_G, 'Config') or {}
	local backend = cfg.ProgressBackend
	local hasBackend = backend and backend ~= '' and backend ~= 'auto-detect' and backend ~= 'autodetect'
	local backendStarted = false
	if backend == 'ox_lib' then backendStarted = GetResourceState('ox_lib') == 'started' end
	if backend == '17mov' then backendStarted = GetResourceState('17mov_Hud') == 'started' end
	if backend == 'none' then backendStarted = true end

	if hasBackend and backendStarted then
		TriggerEvent('sv_compat:progress', data or {})
		return true
	end

	if startProgressFallback(data) then return true end
	TriggerEvent('sv_compat:progress', data or {})
	return true
end

CompatClient.Progress.Cancel = CompatClient.Progress.Cancel or function()
	local cfg = rawget(_G, 'Config') or {}
	local backend = cfg.ProgressBackend
	local hasBackend = backend and backend ~= '' and backend ~= 'auto-detect' and backend ~= 'autodetect'
	local backendStarted = false
	if backend == 'ox_lib' then backendStarted = GetResourceState('ox_lib') == 'started' end
	if backend == '17mov' then backendStarted = GetResourceState('17mov_Hud') == 'started' end
	if backend == 'none' then backendStarted = true end

	if hasBackend and backendStarted then
		TriggerEvent('sv_compat:progressCancel')
		return true
	end

	if cancelProgressFallback() then return true end
	TriggerEvent('sv_compat:progressCancel')
	return true
end

CompatClient.Inventory = CompatClient.Inventory or {}
CompatClient.Inventory.GetItemLabel = CompatClient.Inventory.GetItemLabel or function(item)
	return item
end

exports('GetItemLabel', function(item)
	local comp = _G.SV_Compat_Client
	if comp and comp.Inventory and comp.Inventory.GetItemLabel then
		local ok, res = pcall(comp.Inventory.GetItemLabel, item)
		if ok and res then return res end
	end
	return item
end)

exports('GetClientCompat', function()
	return CompatClient
end)

local function callTarget(method, ...)
	local target = CompatClient.Target
	if not target or type(target[method]) ~= 'function' then return end
	local ok, err = pcall(target[method], ...)
	if not ok then
		print(('[sv_compat] target %s error: %s'):format(method, err))
	end
end

RegisterNetEvent('sv_compat:target:addModel', function(models, options)
	callTarget('AddModel', models, options)
end)

RegisterNetEvent('sv_compat:target:removeModel', function(models)
	callTarget('RemoveModel', models)
end)

RegisterNetEvent('sv_compat:target:addEntity', function(entities, options)
	callTarget('AddEntity', entities, options)
end)

RegisterNetEvent('sv_compat:target:removeEntity', function(entities)
	callTarget('RemoveEntity', entities)
end)

print('[sv_compat] client initialized')
