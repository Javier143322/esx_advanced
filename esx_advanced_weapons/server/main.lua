local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_advanced_weapons:checkLegalAccess', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasJobAccess = false
    local hasLicense = false
    
    for _, job in ipairs(Config.Legal.requiredJobs) do
        if xPlayer.job.name == job then
            hasJobAccess = true
            break
        end
    end
    
    hasLicense = true
    
    cb(hasJobAccess, hasLicense)
end)

ESX.RegisterServerCallback('esx_advanced_weapons:checkIllegalAccess', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasJobAccess = false
    local reputation = 0
    
    for _, job in ipairs(Config.Illegal.requiredJobs) do
        if xPlayer.job.name == job then
            hasJobAccess = true
            break
        end
    end
    
    reputation = 5
    
    cb(hasJobAccess, reputation)
end)

RegisterServerEvent('esx_advanced_weapons:craftWeapon')
AddEventHandler('esx_advanced_weapons:craftWeapon', function(weaponName, weaponType)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(string.format("Jugador %s está fabricando: %s (%s)", xPlayer.getName(), weaponName, weaponType))
end)
