local Config = rawget(_G, 'Config') or {}
if Config.TextUIBackend ~= 'ox_lib' then return end
if GetResourceState('ox_lib') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

CompatClient.TextUI = CompatClient.TextUI or {}
CompatClient.TextUI.backend = 'ox_lib'

CompatClient.TextUI.Show = function(text, opts)
	lib.showTextUI(text or '', opts)
	return true
end

CompatClient.TextUI.Hide = function()
	lib.hideTextUI()
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

print('[sv_compat] textui backend (client): ox_lib')
