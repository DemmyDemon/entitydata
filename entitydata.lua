local ID_SUBSCRIBERS = {}
RegisterNetEvent('entitydata:set')
AddEventHandler('entitydata:set',function(netId, key, value)
    if ID_SUBSCRIBERS[netId] then
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local entity = NetworkGetEntityFromNetworkId(netId)
            for name, sub in pairs(ID_SUBSCRIBERS[netId]) do
                if sub.key == key then
                    local success, message = pcall(sub.callback, entity, key, value)
                    if not success then
                        print('ERROR in '..name..': '..message)
                    end
                end
            end
        end
    end
    if KEY_SUBSCRIBERS[key] then
end)

function SubscribeNetEntityData(netId, key, callback)

    assert(typeof(netId) == 'number' and key % 1 == 0 and key > 0, 'Argument 1, netId, must be a positive integer for SubscribeNetEntityData')
    assert(typeof(key) == 'string' and key ~= '', 'Argument 2, key, must be a string, and can not be empty for SubscribeNetEntityData')
    assert(typeof(callback) == 'function', 'Argument 3, callback function, is required for SubscribeNetEntityData')

    local cbInfo = debug.getinfo(callback, "S")
    local subscriber = string.format('%s:%s', cbInfo.short_src, cbInfo.linedefined)

    if ID_SUBSCRIBERS[netId] then
        ID_SUBSCRIBERS[subscriber] = {
            key = key,
            callback = callback,
        }
    end
end