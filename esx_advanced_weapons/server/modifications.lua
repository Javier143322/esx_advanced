local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_advanced_weapons:getCustomWeapons', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT * FROM custom_weapons WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        cb(result or {})
    end)
end)

ESX.RegisterServerCallback('esx_advanced_weapons:getAvailableAttachments', function(source, cb, weaponModel)
    local attachments = {
        {
            name = 'red_dot_sight',
            label = 'Mira Red Dot',
            price = 2500,
            stats = {accuracy = 15, control = 5},
            legal = true
        },
        {
            name = 'silencer',
            label = 'Silenciador',
            price = 5000,
            stats = {damage = -5, accuracy = 10, range = -10},
            legal = false
        },
        {
            name = 'extended_mag',
            label = 'Cargador Extendido',
            price = 3000,
            stats = {fire_rate = 10, mobility = -5, control = -5},
            legal = false
        },
        {
            name = 'grip',
            label = 'Empuñadura',
            price = 2000,
            stats = {control = 15, accuracy = 5, mobility = -3},
            legal = true
        }
    }
    
    local filteredAttachments = {}
    for _, attachment in ipairs(attachments) do
        table.insert(filteredAttachments, attachment)
    end
    
    cb(filteredAttachments)
end)

ESX.RegisterServerCallback('esx_advanced_weapons:canInstallAttachment', function(source, cb, weapon, attachment)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if weapon.owner ~= xPlayer.identifier then
        cb(false, 'No eres el propietario de esta arma')
        return
    end
    
    if xPlayer.getMoney() < attachment.price then
        cb(false, 'No tienes suficiente dinero')
        return
    end
    
    if weapon.weapon_type == 'legal' and not attachment.legal then
        cb(false, 'No puedes instalar attachments ilegales en armas legales')
        return
    end
    
    cb(true)
end)

RegisterServerEvent('esx_advanced_weapons:installAttachment')
AddEventHandler('esx_advanced_weapons:installAttachment', function(weaponId, attachment)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchScalar('SELECT owner FROM custom_weapons WHERE id = @id', {
        ['@id'] = weaponId
    }, function(owner)
        if owner ~= xPlayer.identifier then
            xPlayer.showNotification('~r~Error de seguridad: No eres el propietario')
            return
        end
        
        MySQL.Async.fetchScalar('SELECT attachments FROM custom_weapons WHERE id = @id', {
            ['@id'] = weaponId
        }, function(currentAttachmentsJson)
            local currentAttachments = json.decode(currentAttachmentsJson or '[]')
            
            for _, installed in ipairs(currentAttachments) do
                if installed.name == attachment.name then
                    xPlayer.showNotification('~y~Este attachment ya está instalado')
                    return
                end
            end
            
            table.insert(currentAttachments, {
                name = attachment.name,
                label = attachment.label,
                stats = attachment.stats
            })
            
            MySQL.Async.execute('UPDATE custom_weapons SET attachments = @attachments WHERE id = @id', {
                ['@id'] = weaponId,
                ['@attachments'] = json.encode(currentAttachments)
            })
            
            xPlayer.removeMoney(attachment.price)
            
            xPlayer.showNotification('~g~Attachment instalado: ' .. attachment.label .. ' - $' .. attachment.price)
            
            print(string.format("[ESX_Advanced_Weapons] %s instaló %s en arma ID: %s", 
                xPlayer.getName(), attachment.name, weaponId))
        end)
    end)
end)

RegisterServerEvent('esx_advanced_weapons:removeAttachment')
AddEventHandler('esx_advanced_weapons:removeAttachment', function(weaponId, attachment)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchScalar('SELECT owner FROM custom_weapons WHERE id = @id', {
        ['@id'] = weaponId
    }, function(owner)
        if owner ~= xPlayer.identifier then
            xPlayer.showNotification('~r~Error de seguridad: No eres el propietario')
            return
        end
        
        MySQL.Async.fetchScalar('SELECT attachments FROM custom_weapons WHERE id = @id', {
            ['@id'] = weaponId
        }, function(currentAttachmentsJson)
            local currentAttachments = json.decode(currentAttachmentsJson or '[]')
            local newAttachments = {}
            
            for _, installed in ipairs(currentAttachments) do
                if installed.name ~= attachment.name then
                    table.insert(newAttachments, installed)
                end
            end
            
            MySQL.Async.execute('UPDATE custom_weapons SET attachments = @attachments WHERE id = @id', {
                ['@id'] = weaponId,
                ['@attachments'] = json.encode(newAttachments)
            })
            
            xPlayer.showNotification('~y~Attachment removido: ' .. attachment.label)
        end)
    end)
end)
