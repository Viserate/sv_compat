-- Minimal usage example: call compat directly and let it handle the selected backend.
local Compat = exports['sv_compat'] and exports['sv_compat']:GetCompat()

local function addItem(playerId, itemName, amount, metadata)
    if not Compat or not Compat.Inventory or not Compat.Inventory.AddItem then return false end
    return Compat.Inventory.AddItem(playerId, itemName, amount or 1, metadata)
end

-- Example command: /givecompat <item> <count>
RegisterCommand('givecompat', function(src, args)
    local item = args[1]
    local count = tonumber(args[2]) or 1
    if not item then
        TriggerClientEvent('chat:addMessage', src, { args = { 'compat', 'usage: /givecompat <item> [count]' } })
        return
    end

    local ok = addItem(src, item, count, {})
    if ok then
        TriggerClientEvent('chat:addMessage', src, { args = { 'compat', ('gave %sx %s'):format(count, item) } })
    else
        TriggerClientEvent('chat:addMessage', src, { args = { 'compat', 'failed to give item' } })
    end
end, false)