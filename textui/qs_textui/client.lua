local Config = rawget(_G, 'Config') or {}
if Config.TextUIBackend ~= 'qs-textui' then return end
if GetResourceState('qs-textui') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

CompatClient.TextUI = CompatClient.TextUI or {}
CompatClient.TextUI.backend = 'qs-textui'

local activeId = nil

local function toVector3(v)
    if v and v.x and v.y and v.z then return vector3(v.x, v.y, v.z) end
    if type(v) == 'vector3' then return v end
    return nil
end

CompatClient.TextUI.Show = function(text, opts)
    local options = opts or {}
    local coords = toVector3(options.coords)
    if not coords then
        print('[sv_compat][qs-textui] show skipped: coords missing')
        return false
    end

    activeId = options.id or options.name or 'sv_compat_textui'
    exports['qs-textui']:create3DTextUI(activeId, {
        coords = coords,
        displayDist = options.displayDist or options.displayDistance or 6.0,
        interactDist = options.interactDist or options.interactDistance or 2.0,
        enableKeyClick = options.enableKeyClick ~= false,
        keyNum = options.keyNum or options.key or 38,
        key = options.keyLabel or options.key or 'E',
        text = text or options.text or options.message or '',
        triggerData = options.triggerData or {
            triggerName = options.triggerName or '',
            args = options.args or {},
        }
    })
    return true
end

CompatClient.TextUI.Hide = function()
    -- qs-textui does not expose a documented removal; no-op.
    activeId = nil
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

print('[sv_compat] textui backend (client): qs-textui')
