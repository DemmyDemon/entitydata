local resource = GetCurrentResourceName()

if GetCurrentResourceName() ~= 'entitydata' then
    function EntityGetDataByNetworkId(...)
        return exports.entitydata:EntityGetDataByNetworkId(...)
    end
    function EntityGetData(...)
        return exports.entitydata:EntityGetData(...)
    end
    function EntitySetData(...)
        return exports.entitydata:EntitySetData(...)
    end
end

local PENDING = {}
local SUBSCRIBERS = {}
RegisterNetEvent('entitydata:set')
AddEventHandler('entitydata:set',function(netId, key, value)
    if SUBSCRIBERS[key] then
        if not PENDING[netId] then
            PENDING[netId] = {}
        end
        PENDING[netId][key] = value
    end
end

function TriggerSubscibers(entity, key, value)
    if SUBSCRIBERS[key] then
        local subscriberCount = 0
        for subscriber, callback in pairs(SUBSCRIBERS[key]) do
            local success, message = pcall(callback, entity, key, value)
            if success then
                subscriberCount = subscriberCount + 1
            else
                print('ENTITY DATA SUBSCRIBER ERROR: '..message..' in '..subscriber)
                SUBSCRIBERS[key][subscriber] = nil
            end
        end
        if subscriberCount == 0 then
            SUBSCRIBERS[key] = nil
        end
    end
end

Citizen.CreateThread(function()
    while true do
        for netId, data in pairs(PENDING) do
            if NetworkDoesEntityExistWithNetworkId(netId) then
                local entity = NetworkGetEntityFromNetworkId(netId)
                for key, value in pairs(data) do
                    TriggerSubscibers(entity, key, value)
                end
                PENDING[netId] = nil
            end
            Citizen.Wait(0)
        end
        Citizen.Wait(0)
    end
end)

function SubscribeToEntityData(key, callback)
    assert(typeof(key) == 'string' and key ~= '', 'Argument 2, key, must be a string, and can not be empty for SubscribeNetEntityData')
    assert(typeof(callback) == 'function', 'Argument 3, callback function, is required for SubscribeNetEntityData')

    local cbInfo = debug.getinfo(callback, "S")
    local subscriber = string.format('%s:%s', cbInfo.short_src, cbInfo.linedefined)
    if not SUBSCRIBERS[key] then
        SUBSCRIBERS[key] = {}
    end
    SUBSCRIBERS[key][subscriber] = callback
    return subscriber
end

function UnsubscribeFromEntityData(subscriber)
    for key, subscribers in pairs(SUBSCRIBERS) do
        local subscriberCount = 0
        for candidate, callback in pairs(subscribers) do
            if candidate == subscriber then
                subscribers[candidate] = nil
            else
                subscriberCount = subscriberCount + 1
            end
        end
        if subscriberCount == 0 then
            SUBSCRIBERS[key] = nil
        end
    end
end
