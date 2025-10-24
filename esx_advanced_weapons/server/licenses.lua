
local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_advanced_weapons:getPlayerLicenses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT * FROM weapon_licenses WHERE owner = @owner AND status = "active" AND expiry_date > NOW()', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        cb(result or {})
    end)
end)

ESX.RegisterServerCallback('esx_advanced_weapons:hasLicense', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM weapon_licenses WHERE owner = @owner AND license_type = @type AND status = "active" AND expiry_date > NOW()', {
        ['@owner'] = xPlayer.identifier,
        ['@type'] = licenseType
    }, function(count)
        cb(count > 0)
    end)
end)

RegisterCommand('addlicense', function(source, args, rawCommand)
    if source == 0 then
        print("Uso: addlicense [playerId] [licenseType]")
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin' then
        xPlayer.showNotification('~r~No tienes permisos administrativos')
        return
    end
    
    if #args < 2 then
        xPlayer.showNotification('~y~Uso: /addlicense [id] [tipo_licencia]')
        return
    end
    
    local targetId = tonumber(args[1])
    local licenseType = args[2]
    local targetXPlayer = ESX.GetPlayerFromId(targetId)
    
    if targetXPlayer then
        MySQL.Async.execute('INSERT INTO weapon_licenses (owner, license_type, expiry_date) VALUES (@owner, @type, @expiry)', {
            ['@owner'] = targetXPlayer.identifier,
            ['@type'] = licenseType,
            ['@expiry'] = os.date('%Y-%m-%d %H:%M:%S', os.time() + (365 * 24 * 60 * 60))
        })
        
        xPlayer.showNotification('~g~Licencia añadida a ' .. targetXPlayer.getName())
        targetXPlayer.showNotification('~g~Has recibido una licencia de armas: ' .. licenseType)
    else
        xPlayer.showNotification('~r~Jugador no encontrado')
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(24 * 60 * 60 * 1000)
        
        MySQL.Async.execute('UPDATE weapon_licenses SET status = "expired" WHERE expiry_date < NOW() AND status = "active"', {}, function(rowsChanged)
            if rowsChanged > 0 then
                print("[ESX_Advanced_Weapons] " .. rowsChanged .. " licencias marcadas como expiradas")
            end
        end)
    end
end)