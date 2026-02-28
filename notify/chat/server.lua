local Config = rawget(_G, 'Config') or {}
if Config.NotifyBackend ~= 'chat' then return end

local Compat = _G.SV_Compat
if not Compat then return end

Compat.Notify = Compat.Notify or {}

Compat.Notify.Send = function(src, message, ntype, duration, title)
	if not src or src == 0 then return false end
	TriggerClientEvent('chat:addMessage', src, { args = { title ~= '' and title or 'notify', tostring(message or '') } })
	return true
end

Compat.SendNotify = Compat.Notify.Send

print('[sv_compat] notify backend: chat')
