Config = {}

-- Debug mode - enables verbose logging
Config.Debug = true

-- Notify position/type defaults for ox_lib
Config.Notify = {
    position = 'top-right',
    duration = 5000,
}

-- Backend selection (set to explicit value or 'auto-detect')
Config.Framework = 'esx' -- Options: auto-detect, esx, qbcore, qbox
Config.Inventory = 'ox_inventory' -- Options: auto-detect, ox_inventory, qb-inventory, qs-inventory
Config.Target = 'ox_target'    -- Options: auto-detect, ox_target, qb-target, qtarget
Config.NotifyBackend = '17mov' -- Options: auto-detect, ox_lib, 17mov, qb, chat
Config.DispatchBackend = 'qs-dispatch' -- Options: auto-detect, ps-dispatch, cd_dispatch, qs-dispatch, log
Config.ProgressBackend = '17mov' -- Options: auto-detect, ox_lib, 17mov, none
Config.TextUIBackend = 'ox_lib' -- Options: auto-detect, ox_lib, qbcore, qbox, qs-textui, none
Config.Zone = 'ox_lib' -- Options: auto-detect, sv_poly, ox_lib, none

-- AUTO DETECT CONFIG
if Config.Framework == 'autodetect' or Config.Framework == 'auto-detect' then
    if GetResourceState('es_extended') == 'started' then
        Config.Framework = 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        Config.Framework = 'qbcore'
    elseif GetResourceState('qbx_core') == 'started' then
        Config.Framework = 'qbox'
    else
        Config.Framework = 'custom'
    end
end

if Config.Inventory == 'autodetect' or Config.Inventory == 'auto-detect' then
    Config.Inventory = 'custom'
    for _, name in ipairs({ 'ox_inventory', 'qb-inventory', 'qs-inventory' }) do
        if GetResourceState(name) == 'started' then
            Config.Inventory = name
            break
        end
    end
end

if Config.Target == 'autodetect' or Config.Target == 'auto-detect' then
    Config.Target = 'custom'
    for _, name in ipairs({ 'ox_target', 'qb-target', 'qtarget' }) do
        if GetResourceState(name) == 'started' then
            Config.Target = name
            break
        end
    end
end

if Config.NotifyBackend == 'autodetect' or Config.NotifyBackend == 'auto-detect' then
    if GetResourceState('ox_lib') == 'started' then
        Config.NotifyBackend = 'ox_lib'
    elseif GetResourceState('17mov_Hud') == 'started' then
        Config.NotifyBackend = '17mov'
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        Config.NotifyBackend = 'qb'
    else
        Config.NotifyBackend = 'chat'
    end
end

if Config.DispatchBackend == 'autodetect' or Config.DispatchBackend == 'auto-detect' then
    if GetResourceState('ps-dispatch') == 'started' then
        Config.DispatchBackend = 'ps-dispatch'
    elseif GetResourceState('cd_dispatch') == 'started' then
        Config.DispatchBackend = 'cd_dispatch'
    elseif GetResourceState('qs-dispatch') == 'started' then
        Config.DispatchBackend = 'qs-dispatch'
    else
        Config.DispatchBackend = 'log'
    end
end

if Config.ProgressBackend == 'autodetect' or Config.ProgressBackend == 'auto-detect' then
    if GetResourceState('ox_lib') == 'started' then
        Config.ProgressBackend = 'ox_lib'
    elseif GetResourceState('17mov_Hud') == 'started' then
        Config.ProgressBackend = '17mov'
    else
        Config.ProgressBackend = 'none'
    end
end

if Config.TextUIBackend == 'autodetect' or Config.TextUIBackend == 'auto-detect' then
    if GetResourceState('ox_lib') == 'started' then
        Config.TextUIBackend = 'ox_lib'
    elseif GetResourceState('qs-textui') == 'started' then
        Config.TextUIBackend = 'qs-textui'
    elseif GetResourceState('qbx_core') == 'started' then
        Config.TextUIBackend = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        Config.TextUIBackend = 'qbcore'
    else
        Config.TextUIBackend = 'none'
    end
end

if Config.Zone == 'autodetect' or Config.Zone == 'auto-detect' then
    if GetResourceState('sv_poly') == 'started' then
        Config.Zone = 'sv_poly'
    elseif GetResourceState('ox_lib') == 'started' then
        Config.Zone = 'ox_lib'
    else
        Config.Zone = 'none'
    end
end

return Config
