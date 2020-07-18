local DATA = {}

AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if DATA[netId] then
        DATA[netId] = nil
        TriggerClientEvent('entitydata:removed', -1, netId)
    end
end)

RegisterNetEvent('entitydata:set')
AddEventHandler ('entitydata:set', function(netId, key, value)
    if DATA[netId] then
        DATA[netId][key] = value
    else
        DATA[netId] = {
            key = value,
        }
    end
    TriggerClientEvent('entitydata:set', -1, key, value)
end)

RegisterNetEvent('entitydata:get-bulk')
AddEventHandler ('entitydata:get-bulk', function()
    TriggerClientEvent('entitydata:set-bulk', source, DATA)
end)