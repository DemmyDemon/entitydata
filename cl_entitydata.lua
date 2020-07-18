local DATA = {}

RegisterNetEvent('entitydata:set')
AddEventHandler ('entitydata:set', function(netId, key, value)
    if not DATA[netId] then
        DATA[netId] = {}
    end
    DATA[netId][key] = value
end)

RegisterNetEvent('entitydata:set-bulk')
AddEventHandler ('entitydata:set-bulk', function(bulkData)
    DATA = bulkData
end)

function GetNetData(netId, key)
    if DATA[netId] and key then
        return DATA[netId][key]
    end
end
exports('EntityGetDataByNetworkId', GetNetData)

function GetEntityData(entity, key)
    if key and DoesEntityExist(entity) and NetworkGetEntityIsNetworked(entity) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        if DATA[netId] then
            return DATA[netId][key]
        end
    end
end
exports('EntityGetData', GetEntityData)
