local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_advanced_weapons:checkComponents', function(source, cb, requiredComponents)
    local xPlayer = ESX.GetPlayerFromId(source)
    local missingComponents = {}
    local hasAllComponents = true
    
    for _, component in ipairs(requiredComponents) do
        local item = xPlayer.getInventoryItem(component.item)
        
        if item == nil or item.count < component.amount then
            hasAllComponents = false
            table.insert(missingComponents, {
                item = component.item,
                label = item and item.label or component.item,
                amount = component.amount - (item and item.count or 0)
            })
        end
    end
    
    cb(hasAllComponents, missingComponents)
end)

RegisterServerEvent('esx_advanced_weapons:finishCrafting')
AddEventHandler('esx_advanced_weapons:finishCrafting', function(weaponName, weaponType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local weaponConfig = nil
    if weaponType == 'legal' then
        for _, weapon in ipairs(Config.CraftableWeapons.legal) do
            if weapon.name == weaponName then
                weaponConfig = weapon
                break
            end
        end
    else
        for _, weapon in ipairs(Config.CraftableWeapons.illegal) do
            if weapon.name == weaponName then
                weaponConfig = weapon
                break
            end
        end
    end
    
    if not weaponConfig then
        print("Error: Configuración de arma no encontrada para " .. weaponName)
        return
    end
    
    local hasAllComponents = true
    for _, component in ipairs(weaponConfig.components) do
        local item = xPlayer.getInventoryItem(component.item)
        if item == nil or item.count < component.amount then
            hasAllComponents = false
            break
        end
    end
    
    if not hasAllComponents then
        xPlayer.showNotification('~r~Error: No tienes los componentes necesarios')
        return
    end
    
    for _, component in ipairs(weaponConfig.components) do
        xPlayer.removeInventoryItem(component.item, component.amount)
    end
    
    local serialNumber = GenerateSerialNumber(weaponType)
    local weaponItemName = "custom_" .. weaponName
    
    xPlayer.addInventoryItem(weaponItemName, 1)
    
    MySQL.Async.execute('INSERT INTO custom_weapons (owner, serial_number, weapon_model, weapon_type, components) VALUES (@owner, @serial, @model, @type, @components)', {
        ['@owner'] = xPlayer.identifier,
        ['@serial'] = serialNumber,
        ['@model'] = weaponName,
        ['@type'] = weaponType,
        ['@components'] = json.encode(weaponConfig.components)
    })
    
    if weaponType == 'legal' then
        xPlayer.showNotification(string.format('~g~Arma fabricada exitosamente! ~n~~w~Serial: %s', serialNumber))
        
        if math.random(1, 100) <= 30 then
            TriggerClientEvent('esx_advanced_weapons:policeNotification', -1, 
                string.format('Arma legal fabricada: %s por %s', weaponConfig.label, xPlayer.getName()))
        end
    else
        xPlayer.showNotification('~r~Arma ilegal fabricada - Mantenla oculta!')
        
        if math.random(1, 100) <= 60 then
            TriggerClientEvent('esx_advanced_weapons:policeAlert', -1, 
                GetEntityCoords(GetPlayerPed(source)))
        end
    end
end)

function GenerateSerialNumber(weaponType)
    local prefix = weaponType == 'legal' and 'LEG' or 'ILL'
    local randomNum = math.random(100000, 999999)
    return string.format('%s-%s-%s', prefix, os.date('%y%m'), randomNum)
end

ESX.RegisterServerCallback('esx_advanced_weapons:buyLicense', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local licenseConfig = nil
    for _, license in ipairs(Config.Legal.licenseTypes) do
        if license.name == licenseType then
            licenseConfig = license
            break
        end
    end
    
    if not licenseConfig then
        cb(false)
        return
    end
    
    if xPlayer.getMoney() >= licenseConfig.price then
        xPlayer.removeMoney(licenseConfig.price)
        
        MySQL.Async.execute('INSERT INTO weapon_licenses (owner, license_type, expiry_date) VALUES (@owner, @type, @expiry)', {
            ['@owner'] = xPlayer.identifier,
            ['@type'] = licenseType,
            ['@expiry'] = os.date('%Y-%m-%d %H:%M:%S', os.time() + (30 * 24 * 60 * 60))
        })
        
        cb(true)
    else
        cb(false)
    end
end)