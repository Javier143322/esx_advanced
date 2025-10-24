local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_advanced_weapons:checkPlayerWeapons', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetXPlayer = ESX.GetPlayerFromId(targetId)
    
    if xPlayer.job.name ~= 'police' then
        cb(false, 'No tienes autorización para revisar armas')
        return
    end
    
    if not targetXPlayer then
        cb(false, 'Jugador no encontrado')
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM custom_weapons WHERE owner = @owner', {
        ['@owner'] = targetXPlayer.identifier
    }, function(weapons)
        MySQL.Async.fetchAll('SELECT * FROM weapon_licenses WHERE owner = @owner AND status = "active" AND expiry_date > NOW()', {
            ['@owner'] = targetXPlayer.identifier
        }, function(licenses)
            cb(true, {
                weapons = weapons or {},
                licenses = licenses or {},
                playerName = targetXPlayer.getName()
            })
        end)
    end)
end)

RegisterServerEvent('esx_advanced_weapons:confiscateWeapon')
AddEventHandler('esx_advanced_weapons:confiscateWeapon', function(weaponId, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetXPlayer = ESX.GetPlayerFromId(targetId)
    
    if xPlayer.job.name ~= 'police' then
        return
    end
    
    MySQL.Async.fetchScalar('SELECT owner FROM custom_weapons WHERE id = @id', {
        ['@id'] = weaponId
    }, function(owner)
        if owner == targetXPlayer.identifier then
            MySQL.Async.execute('DELETE FROM custom_weapons WHERE id = @id', {
                ['@id'] = weaponId
            })
            
            targetXPlayer.removeInventoryItem('custom_' .. weaponId, 1)
            
            xPlayer.showNotification('~g~Arma ilegal confiscada')
            targetXPlayer.showNotification('~r~Tu arma ilegal ha sido confiscada por la policía')
            
            print(string.format("[ESX_Advanced_Weapons] %s confiscó arma ID %s de %s", 
                xPlayer.getName(), weaponId, targetXPlayer.getName()))
        end
    end)
end)

RegisterCommand('revisararmas', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= 'police' then
        xPlayer.showNotification('~r~Solo para cuerpos de seguridad')
        return
    end
    
    if #args == 0 then
        TriggerClientEvent('esx_advanced_weapons:checkNearestPlayer', source)
    else
        local targetId = tonumber(args[1])
        if targetId then
            TriggerClientEvent('esx_advanced_weapons:showWeaponsCheck', source, targetId)
        else
            xPlayer.showNotification('~y~Uso: /revisararmas [id_jugador]')
        end
    end
end)

RegisterServerEvent('esx_advanced_weapons:raidWorkshop')
AddEventHandler('esx_advanced_weapons:raidWorkshop', function(location)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= 'police' then
        return
    end
    
    TriggerClientEvent('esx_advanced_weapons:policeRaid', -1, location)
    
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local player = ESX.GetPlayerFromId(playerId)
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        local distance = #(playerCoords - vector3(location.x, location.y, location.z))
        
        if distance < 50.0 then
            local illegalItems = {'stolen_frame', 'illegal_barrel', 'silencer'}
            for _, item in ipairs(illegalItems) do
                local playerItem = player.getInventoryItem(item)
                if playerItem and playerItem.count > 0 then
                    if math.random(1, 100) <= 50 then
                        player.removeInventoryItem(item, math.random(1, playerItem.count))
                        player.showNotification('~r~La policía te ha confiscado ' .. playerItem.count .. ' ' .. item)
                    end
                end
            end
        end
    end
    
    xPlayer.addMoney(5000)
    xPlayer.showNotification('~g~Redada completada - Recompensa: $5000')
end)
