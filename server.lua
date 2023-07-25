lib.callback.register('qbx-spawn:callback:HasApartment', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local Result = MySQL.single.await('SELECT * FROM apartments WHERE citizenid = ?', { Player.PlayerData.citizenid })
    return Result
end)

local function getApartmentInfo(apartmentType)
    local info
    for i = 1, #Apartments do
        if Apartments[i].type == apartmentType then info = { coords = Apartments[i].enter, label = Apartments[i].label } break end
    end
    return info
end

RegisterNetEvent('qbx-spawn:server:setupSpawn', function(playerSource)
    local player = QBCore.Functions.GetPlayer(playerSource)
    local hasApartment = MySQL.single.await('SELECT * FROM apartments WHERE citizenid = ?', { player.PlayerData.citizenid })
    if hasApartment then
        local apartmentInfo = getApartmentInfo(hasApartment.type)
        Spawns[#Spawns+1] = {
            coords = apartmentInfo.coords,
            label = apartmentInfo.label
        }
        local chosenSpawn = lib.callback.await('qbx-spawn:callback:chooseSpawn', playerSource, Spawns)
    else
        local chosenApartment = lib.callback.await('qbx-spawn:callback:chooseApartment', playerSource)
        local apartmentId = string.format('%s%s', Apartments[chosenApartment].type, player.PlayerData.citizenid)
        MySQL.insert('INSERT INTO apartments (name, type, label, citizenid) VALUES (?, ?, ?, ?)', {
            apartmentId,
            Apartments[chosenApartment].type,
            string.format('%s %s', Apartments[chosenApartment].label, math.random(1, 999999)),
            player.PlayerData.citizenid
        })
        TriggerClientEvent('apartments:client:SpawnInApartment', playerSource, apartmentId, Apartments[chosenApartment].type)
        TriggerClientEvent('apartments:client:SetHomeBlip', playerSource, Apartments[chosenApartment].type)
    end
end)

RegisterCommand('testing', function (source, args, raw)
    TriggerEvent('qbx-spawn:server:setupSpawn', source)
end)
