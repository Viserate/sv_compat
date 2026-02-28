local Config = rawget(_G, 'Config') or {}
if Config.ProgressBackend ~= '17mov' then return end
if GetResourceState('17mov_Hud') ~= 'started' then return end

local active = false

local function buildAction(data)
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

RegisterNetEvent('sv_compat:progress', function(payload)
    if GetResourceState('17mov_Hud') ~= 'started' then return end
    local data = payload or {}
    local action = buildAction(data)

    active = true
    local ok, err = pcall(function()
        exports['17mov_Hud']:StartProgress(action, nil, nil, function(_finished)
            active = false
        end)
    end)

    if not ok then
        active = false
        print(('[sv_compat] 17mov progress error: %s'):format(err))
    end
end)

RegisterNetEvent('sv_compat:progressCancel', function()
    if GetResourceState('17mov_Hud') ~= 'started' then return end
    if not active then return end

    local ok, err = pcall(function()
        exports['17mov_Hud']:StopProgress()
    end)

    if not ok then
        print(('[sv_compat] 17mov progress cancel error: %s'):format(err))
    end

    active = false
end)

local CompatClient = _G.SV_Compat_Client
if CompatClient then
    CompatClient.Progress = CompatClient.Progress or {}
    CompatClient.Progress.backend = '17mov'
end

print('[sv_compat] progress backend (client): 17mov')
