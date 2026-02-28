local Config = rawget(_G, 'Config') or {}
if Config.DispatchBackend ~= 'ps-dispatch' then return end
if GetResourceState('ps-dispatch') ~= 'started' then return end

local Compat = _G.SV_Compat
if not Compat then return end

Compat.Dispatch = Compat.Dispatch or {}

Compat.Dispatch.Send = function(payload)
	if type(payload) ~= 'table' then return false end
	TriggerEvent('ps-dispatch:server:notify', payload)
	return true
end

Compat.SendDispatch = Compat.Dispatch.Send

print('[sv_compat] dispatch backend: ps-dispatch')
