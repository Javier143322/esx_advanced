local currentWeapon = nil
local availableAttachments = {}

function OpenModificationsMenu()
    ESX.TriggerServerCallback('esx_advanced_weapons:getCustomWeapons', function(weapons)
        if #weapons == 0 then
            ESX.ShowNotification('~y~No tienes armas personalizadas para modificar')
            return
        end
        
        ShowWeaponsSelectionMenu(weapons)
    end)
end

function ShowWeaponsSelectionMenu(weapons)
    local elements = {}
    
    for _, weapon in ipairs(weapons) do
        local components = json.decode(weapon.components or '[]')
        local attachments = json.decode(weapon.attachments or '[]')
        
        table.insert(elements, {
            label = string.format('%s (Serial: %s) - %d attachments', 
                GetWeaponLabel(weapon.weapon_model), 
                weapon.serial_number, 
                #attachments
            ),
            value = weapon.id,
            weapon = weapon
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_weapon_modify',
    {
        title = 'Seleccionar Arma a Modificar',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        currentWeapon = data.current.weapon
        ShowAttachmentsMenu(currentWeapon)
    end, function(data, menu)
        menu.close()
    end)
end

function ShowAttachmentsMenu(weapon)
    ESX.TriggerServerCallback('esx_advanced_weapons:getAvailableAttachments', function(attachments)
        availableAttachments = attachments
        
        local elements = {}
        local currentAttachments = json.decode(weapon.attachments or '[]')
        
        for _, attachment in ipairs(attachments) do
            local alreadyInstalled = false
            for _, installed in ipairs(currentAttachments) do
                if installed.name == attachment.name then
                    alreadyInstalled = true
                    break
                end
            end
            
            if not alreadyInstalled then
                table.insert(elements, {
                    label = string.format('+ %s - $%d', attachment.label, attachment.price),
                    value = attachment.name,
                    attachment = attachment,
                    type = 'add'
                })
            else
                table.insert(elements, {
                    label = string.format('✓ %s (Instalado)', attachment.label),
                    value = attachment.name,
                    attachment = attachment,
                    type = 'remove'
                })
            end
        end
        
        table.insert(elements, {
            label = '📊 Ver Estadísticas Actuales',
            value = 'stats'
        })
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'attachments_menu',
        {
            title = 'Modificaciones - ' .. GetWeaponLabel(weapon.weapon_model),
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'stats' then
                ShowWeaponStats(weapon)
            elseif data.current.type == 'add' then
                InstallAttachment(weapon, data.current.attachment)
            else
                RemoveAttachment(weapon, data.current.attachment)
            end
        end, function(data, menu)
            menu.close()
            currentWeapon = nil
        end)
    end, weapon.weapon_model)
end

function InstallAttachment(weapon, attachment)
    ESX.TriggerServerCallback('esx_advanced_weapons:canInstallAttachment', function(canInstall, reason)
        if canInstall then
            ESX.Progressbar("Instalando " .. attachment.label, 10000, {
                FreezePlayer = true,
                Animation = {
                    type = "anim",
                    dict = "amb@world_human_vehicle_mechanic@male@base",
                    lib = "base"
                },
                onFinish = function()
                    TriggerServerEvent('esx_advanced_weapons:installAttachment', weapon.id, attachment)
                    ESX.ShowNotification('~g~Attachment instalado: ' .. attachment.label)
                    ShowAttachmentsMenu(weapon)
                end,
                onCancel = function()
                    ESX.ShowNotification('~r~Instalación cancelada')
                end
            })
        else
            ESX.ShowNotification('~r~' .. (reason or 'No puedes instalar este attachment'))
        end
    end, weapon, attachment)
end

function RemoveAttachment(weapon, attachment)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_remove',
    {
        title = '¿Remover ' .. attachment.label .. '?',
        align = 'top-left',
        elements = {
            {label = 'Sí, remover', value = 'yes'},
            {label = 'Cancelar', value = 'no'}
        }
    }, function(data, menu)
        if data.current.value == 'yes' then
            TriggerServerEvent('esx_advanced_weapons:removeAttachment', weapon.id, attachment)
            ESX.ShowNotification('~y~Attachment removido: ' .. attachment.label)
            ShowAttachmentsMenu(weapon)
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function ShowWeaponStats(weapon)
    local attachments = json.decode(weapon.attachments or '[]')
    local stats = CalculateWeaponStats(weapon, attachments)
    
    local elements = {
        {label = '💥 Daño: ' .. stats.damage .. '%'},
        {label = '🎯 Precisión: ' .. stats.accuracy .. '%'},
        {label = '📏 Alcance: ' .. stats.range .. '%'},
        {label = '⚡ Cadencia: ' .. stats.fire_rate .. '%'},
        {label = '🏃 Movilidad: ' .. stats.mobility .. '%'},
        {label = '🎮 Control: ' .. stats.control .. '%'},
        {label = '🔧 Attachments Instalados: ' .. #attachments}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weapon_stats',
    {
        title = 'Estadísticas - ' .. GetWeaponLabel(weapon.weapon_model),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function CalculateWeaponStats(weapon, attachments)
    local baseStats = {
        damage = 50,
        accuracy = 50,
        range = 50,
        fire_rate = 50,
        mobility = 50,
        control = 50
    }
    
    for _, attachment in ipairs(attachments) do
        if attachment.stats then
            for stat, value in pairs(attachment.stats) do
                if baseStats[stat] then
                    baseStats[stat] = baseStats[stat] + value
                    baseStats[stat] = math.max(0, math.min(100, baseStats[stat]))
                end
            end
        end
    end
    
    return baseStats
end

function GetWeaponLabel(weaponModel)
    local labels = {
        pistol_9mm = 'Pistola 9mm',
        pistol_silenced = 'Pistola Silenciada'
    }
    return labels[weaponModel] or weaponModel
end

RegisterCommand('modificararmas', function()
    OpenModificationsMenu()
end, false)

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local sleep = 1000
        
        local legalWorkshop = vector3(840.52, -1027.55, 28.19)
        local distance = #(playerCoords - legalWorkshop)
        
        if distance < 10.0 then
            sleep = 0
            DrawMarker(1, legalWorkshop.x, legalWorkshop.y, legalWorkshop.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 150, 255, 100, false, true, 2, false, nil, nil, false)
            
            if distance < 1.5 then
                ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para modificar armas')
                if IsControlJustPressed(0, 38) then
                    OpenModificationsMenu()
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)