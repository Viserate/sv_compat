local Config = rawget(_G, 'Config') or {}
if Config.Zone ~= 'sv_poly' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local zones = CompatClient.Zones
local initialized = false

local function init()
    if initialized then return end
    if GetResourceState('sv_poly') ~= 'started' then return end
    local poly = exports['sv_poly']
    if not poly then return end

    CompatClient.Zones = CompatClient.Zones or {}
    CompatClient.Zones.backend = 'sv_poly'
    CompatClient.Zones._zones = CompatClient.Zones._zones or {}
    CompatClient.Zones._meta = CompatClient.Zones._meta or {}
    CompatClient.Zones._state = CompatClient.Zones._state or {}

    zones = CompatClient.Zones
    zones._poly = poly
    initialized = true
    print('[sv_compat] Zones backend: sv_poly')
end

CreateThread(function()
    while not initialized do
        init()
        if initialized then break end
        Wait(500)
    end
end)

local function setState(name, val)
    zones._state[name] = val
end

zones.AddPoly = function(cfg)
    if not initialized then return false end
    if not cfg or not cfg.name or not cfg.points or #cfg.points < 3 then return false end


    if zones._zones[cfg.name] then
        zones._poly:RemoveZone(cfg.name)
    end

    local opts = {
        thickness = cfg.thickness or 3.0,
        minZ = cfg.minZ,
        maxZ = cfg.maxZ,
        debug = cfg.debug or false,
        script = cfg.script or GetInvokingResource() or GetCurrentResourceName() or 'unknown',
        onEnter = function(...)
            setState(cfg.name, true)
            if cfg.onEnter then cfg.onEnter(...) end
        end,
        onExit = function(...)
            setState(cfg.name, false)
            if cfg.onExit then cfg.onExit(...) end
        end,
        onInside = cfg.inside
    }

    local zone = zones._poly:CreatePolyZone(cfg.name, cfg.points, opts)
    if not zone then return false end

    zones._zones[cfg.name] = true
    zones._meta[cfg.name] = { script = opts.script }
    zones._state[cfg.name] = false
    return true
end

zones.AddSphere = function(cfg)
    if not initialized then return false end
    if not cfg or not cfg.name or not cfg.coords then return false end

    if zones._zones[cfg.name] then
        zones._poly:RemoveZone(cfg.name)
    end

    local opts = {
        debug = cfg.debug or false,
        script = cfg.script or GetInvokingResource() or GetCurrentResourceName() or 'unknown',
        onEnter = function(...)
            setState(cfg.name, true)
            if cfg.onEnter then cfg.onEnter(...) end
        end,
        onExit = function(...)
            setState(cfg.name, false)
            if cfg.onExit then cfg.onExit(...) end
        end,
        onInside = cfg.inside
    }

    local zone = zones._poly:CreateSphereZone(cfg.name, cfg.coords, cfg.radius or 2.0, opts)
    if not zone then return false end

    zones._zones[cfg.name] = true
    zones._meta[cfg.name] = { script = opts.script }
    zones._state[cfg.name] = false
    return true
end

zones.RemoveZone = function(name)
    if not initialized then return false end
    if not name then return false end
    zones._poly:RemoveZone(name)
    zones._zones[name] = nil
    zones._meta[name] = nil
    zones._state[name] = nil
    return true
end

zones.ClearZonesForScript = function(scriptName)
    if not scriptName then return end
    for name, meta in pairs(zones._meta) do
        if meta.script == scriptName then
            zones.RemoveZone(name)
        end
    end
end

zones.GetState = function(name)
    return zones._state[name]
end

zones.TestPoint = function(name, coords)
    if not initialized then return false end
    if not name then return false end
    local pos = coords or GetEntityCoords(PlayerPedId())
    return zones._poly:IsInside(name, pos)
end


print('[sv_compat] Zones backend: sv_poly')