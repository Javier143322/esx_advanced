local currentCustomWeapon = nil
local weaponStats = {}

RegisterNetEvent('esx_advanced_weapons:useCustomWeapon')
AddEventHandler('esx_advanced_weapons:useCustomWeapon', function(weaponData)
    local playerPed = PlayerPedId()
    
    weaponStats = CalculateWeaponStats(weaponData, json.decode(weaponData.attachments or '[]'))
    currentCustomWeapon = weaponData
    
    ESX.ShowNotification(string.format('~g~%s equipada~n~~w~Daño: %s%% | Precisión: %s%%', 
        GetWeaponLabel(weaponData.weapon_model), 
        weaponStats.damage, 
        weaponStats.accuracy
    ))
end)

function ApplyWeaponStats(weaponModel, stats)
    Citizen.CreateThread(function()
        while currentCustomWeapon do
            local playerPed = PlayerPedId()
            
            if GetSelectedPedWeapon(playerPed) ~= -1569615261 then
                if stats.control > 70 then
                    SetGameplayCamShakeAmplitude(0.1)
                end
            end
            
            Citizen.Wait(100)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        if currentCustomWeapon then
            local playerPed = PlayerPedId()
            
            if IsPedShooting(playerPed) then
                ReduceWeaponDurability(0.1)
            end
            
            if GetEntityHealth(playerPed) < GetEntityMaxHealth(playerPed) then
                ReduceWeaponDurability(0.05)
            end
        end
        Citizen.Wait(1000)
    end
end)

function ReduceWeaponDurability(amount)
    if currentCustomWeapon then
        weaponStats.durability = (weaponStats.durability or 100) - amount
        
        if weaponStats.durability <= 0 then
            ESX.ShowNotification('~r~¡Tu arma se ha roto! Necesitas repararla.')
            currentCustomWeapon = nil
        elseif weaponStats.durability <= 20 then
            ESX.ShowNotification('~y~¡Cuidado! Tu arma está a punto de romperse')
        end
    end
end

RegisterNetEvent('esx_advanced_weapons:showWeaponsCheck')
AddEventHandler('esx_advanced_weapons:showWeaponsCheck', function(targetId)
    ESX.TriggerServerCallback('esx_advanced_weapons:checkPlayerWeapons', function(success, data, errorMsg)
        if not success then
            ESX.ShowNotification('~r~' .. errorMsg)
            return
        end
        
        ShowPoliceWeaponsCheckMenu(data, targetId)
    end, targetId)
end)

function ShowPoliceWeaponsCheckMenu(data, targetId)
    local elements = {
        {label = '👤 Jugador: ' .. data.playerName, value = 'header'}
    }
    
    if #data.licenses > 0 then
        table.insert(elements, {label = '--- 📜 LICENCIAS ACTIVAS ---', value = 'license_header'})
        for _, license in ipairs(data.licenses) do
            table.insert(elements, {
                label = string.format('✓ %s - Vence: %s', 
                    GetLicenseLabel(license.license_type),
                    license.expiry_date
                ),
                value = 'license_' .. license.id
            })
        end
    else
        table.insert(elements, {label = '❌ Sin licencias de armas activas', value = 'no_licenses'})
    end
    
    if #data.weapons > 0 then
        table.insert(elements, {label = '--- 🔫 ARMAS REGISTRADAS ---', value = 'weapons_header'})
        for _, weapon in ipairs(data.weapons) do
            local attachments = json.decode(weapon.attachments or '[]')
            local status = weapon.weapon_type == 'legal' and '~g~LEGAL' or '~r~ILEGAL'
            
            table.insert(elements, {
                label = string.format('%s %s (Serial: %s) - %d attachments', 
                    status, 
                    GetWeaponLabel(weapon.weapon_model),
                    weapon.serial_number,
                    #attachments
                ),
                value = 'weapon_' .. weapon.id,
                weapon = weapon
            })
        end
    else
        table.insert(elements, {label = '✅ No tiene armas registradas', value = 'no_weapons'})
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'police_weapons_check',
    {
        title = 'Revisión de Armas - Policía',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value and string.find(data.current.value, 'weapon_') and data.current.weapon then
            if data.current.weapon.weapon_type == 'illegal' then
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confiscate_weapon',
                {
                    title = 'Confiscar Arma Ilegal',
                    align = 'top-left',
                    elements = {
                        {label = '✅ Sí, confiscar arma ilegal', value = 'yes'},
                        {label = '❌ Cancelar', value = 'no'}
                    }
                }, function(data2, menu2)
                    if data2.current.value == 'yes' then
                        TriggerServerEvent('esx_advanced_weapons:confiscateWeapon', data.current.weapon.id, targetId)
                        menu2.close()
                        menu.close()
                    else
                        menu2.close()
                    end
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('esx_advanced_weapons:checkNearestPlayer')
AddEventHandler('esx_advanced_weapons:checkNearestPlayer', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local players = ESX.Game.GetPlayersInArea(playerCoords, 3.0)
    
    local closestPlayer, closestDistance = nil, 3.0
    
    for _, player in ipairs(players) do
        if player ~= PlayerId() then
            local targetCoords = GetEntityCoords(GetPlayerPed(player))
            local distance = #(playerCoords - targetCoords)
            
            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end
    
    if closestPlayer then
        TriggerEvent('esx_advanced_weapons:showWeaponsCheck', GetPlayerServerId(closestPlayer))
    else
        ESX.ShowNotification('~y~No hay jugadores cercanos para revisar')
    end
end)

RegisterNetEvent('esx_advanced_weapons:policeRaid')
AddEventHandler('esx_advanced_weapons:policeRaid', function(location)
    local playerJob = ESX.GetPlayerData().job.name
    
    if playerJob ~= 'police' then
        SetPlayerWantedLevel(PlayerId(), 2, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        
        ESX.ShowNotification('~r~¡REDADA POLICIAL!~n~~w~Abandona el área inmediatamente')
        
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 487)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 255)
        SetBlipScale(blip, 1.5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("REDADA POLICIAL")
        EndTextCommandSetBlipName(blip)
        
        Citizen.SetTimeout(300000, function()
            RemoveBlip(blip)
        end)
    end
end)

function GetLicenseLabel(licenseType)
    local labels = {
        firearm_basic = 'Porte Básico',
        concealed_carry = 'Porte Oculta',
        automatic_weapons = 'Armas Automáticas'
    }
    return labels[licenseType] or licenseType
end
