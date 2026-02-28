local Config = rawget(_G, 'Config') or {}
if Config.Zone ~= 'ox_lib' then return end
if GetResourceState('ox_lib') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

CompatClient.Zones = CompatClient.Zones or {}
CompatClient.Zones.backend = 'ox_lib'
CompatClient.Zones._zones = CompatClient.Zones._zones or {}
CompatClient.Zones._meta = CompatClient.Zones._meta or {}
CompatClient.Zones._state = CompatClient.Zones._state or {}

local zones = CompatClient.Zones

local function setState(name, val)
    zones._state[name] = val
end

local function safeInvoke(cfg, fn, ...)
    if not fn then return end
    if cfg and cfg.script and GetResourceState(cfg.script) ~= 'started' then
        return
    end
    local ok, err = pcall(fn, ...)
    if not ok then
           -- suppressed zone callback error log
    end
end

zones.AddPoly = function(cfg)
    if not cfg or not cfg.name or not cfg.points or #cfg.points < 3 then return false end
    if not lib or not lib.zones or not lib.zones.poly then return false end


    -- remove existing
    if zones._zones[cfg.name] and zones._zones[cfg.name].remove then
        zones._zones[cfg.name]:remove()
    end

    local thickness = cfg.thickness or 3.0
    local opts = {
        points = cfg.points,
        thickness = thickness,
        debug = cfg.debug or false,
        inside = function(...)
            safeInvoke(cfg, cfg.inside, ...)
        end,
        onEnter = function(...)
            setState(cfg.name, true)
            safeInvoke(cfg, cfg.onEnter, ...)
        end,
        onExit = function(...)
            setState(cfg.name, false)
            safeInvoke(cfg, cfg.onExit, ...)
        end,
    }

    local zone = lib.zones.poly(opts)
    if not zone then return false end

    zones._zones[cfg.name] = zone
    zones._meta[cfg.name] = {
        script = cfg.script or GetInvokingResource() or GetCurrentResourceName() or 'unknown',
    }
    zones._state[cfg.name] = false
    return true
end

zones.AddSphere = function(cfg)
    if not cfg or not cfg.name or not cfg.coords then return false end
    if not lib or not lib.zones or not lib.zones.sphere then return false end

    if zones._zones[cfg.name] and zones._zones[cfg.name].remove then
        zones._zones[cfg.name]:remove()
    end

    local opts = {
        coords = cfg.coords,
        radius = cfg.radius or 2.0,
        debug = cfg.debug or false,
        inside = function(...)
            safeInvoke(cfg, cfg.inside, ...)
        end,
        onEnter = function(...)
            setState(cfg.name, true)
            safeInvoke(cfg, cfg.onEnter, ...)
        end,
        onExit = function(...)
            setState(cfg.name, false)
            safeInvoke(cfg, cfg.onExit, ...)
        end,
    }

    local zone = lib.zones.sphere(opts)
    if not zone then return false end

    zones._zones[cfg.name] = zone
    zones._meta[cfg.name] = {
        script = cfg.script or GetInvokingResource() or GetCurrentResourceName() or 'unknown',
    }
    zones._state[cfg.name] = false
    return true
end

zones.RemoveZone = function(name)
    if not name then return false end
    local z = zones._zones[name]
    if z and z.remove then z:remove() end
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
    if not name then return false end
    local z = zones._zones[name]
    if not z or not z.contains then return false end
    local pos = coords or GetEntityCoords(PlayerPedId())
    return z:contains(pos)
end

print('[sv_compat] Zones backend: ox_lib')
