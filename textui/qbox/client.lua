local Config = rawget(_G, 'Config') or {}
if Config.TextUIBackend ~= 'qbox' then return end
if GetResourceState('qbx_core') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

CompatClient.TextUI = CompatClient.TextUI or {}
CompatClient.TextUI.backend = 'qbox'

CompatClient.TextUI.Show = function(text, opts)
	local pos = opts and opts.position or 'left'
	local core = exports['qbx_core']
	if core and core.DrawText then core:DrawText(text or '', pos) end
	return true
end

CompatClient.TextUI.Hide = function()
	local core = exports['qbx_core']
	if core and core.HideText then core:HideText() end
	return true
end

RegisterNetEvent('sv_compat:textUI', function(payload)
	local data = payload or {}
	local hide = data.action == 'hide' or data.action == 'close' or data.display == false or data.visible == false or data.text == nil
	if hide then
		CompatClient.TextUI.Hide()
		return
	end
	CompatClient.TextUI.Show(data.text or data.message or '', data.options or data)
end)

print('[sv_compat] textui backend (client): qbox')
