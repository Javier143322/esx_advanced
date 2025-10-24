
local currentEnergyWeapon = nil
local energyLevel = 100
local hudEnabled = false

function OpenEnergyWeaponsMenu()
    local playerJob = ESX.GetPlayerData().job.name
    
    local hasAccess = false
    for _, job in ipairs(Config.AdvancedWeapons.energyWeapons.requiredJob) do
        if playerJob == job then
            hasAccess = true
            break
        end
    end
    
    if not hasAccess then
        ESX.ShowNotification('~r~Acceso denegado: Solo unidades especiales')
        return
    end
    
    ShowEnergyWeaponsSelection()
end

function ShowEnergyWeaponsSelection()
    local elements = {}
    
    for _, weapon in ipairs(Config.AdvancedWeapons.energyWeapons.weapons) do
        table.insert(elements, {
            label = string.format('%s - $%d | Daño: %d | Energía: %d', 
                weapon.label, weapon.price, weapon.stats.damage, weapon.stats.energy_cost),
            value = weapon.name,
            weapon = weapon
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'energy_weapons_menu',
    {
        title = 'Armas de Energía - Unidades Especiales',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local weapon = data.current.weapon
        CheckEnergyComponents(weapon)
    end, function(data, menu)
        menu.close()
    end)
end

function CheckEnergyComponents(weapon)
    ESX.TriggerServerCallback('esx_advanced_weapons:checkEnergyComponents', function(hasComponents, missingComponents)
        if hasComponents then
            StartEnergyWeaponCrafting(weapon)
        else
            ShowMissingEnergyComponents(missingComponents)
        end
    end, weapon.components)
end

function StartEnergyWeaponCrafting(weapon)
    ESX.ShowNotification('~b~Iniciando fabricación de arma de energía...')
    
    ESX.Progressbar("Fabricando " .. weapon.label, weapon.craftTime, {
        FreezePlayer = true,
        Animation = {
            type = "anim",
            dict = "anim@heists@prison_heiststation@cop_reactions",
            lib = "cop_b_idle"
        },
        onFinish = function()
            TriggerServerEvent('esx_advanced_weapons:finishEnergyWeapon', weapon.name)
            ESX.ShowNotification('~g~Arma de energía fabricada exitosamente!')
        end,
        onCancel = function()
            ESX.ShowNotification('~r~Fabricación cancelada')
        end
    })
end

function EnableEnergyWeaponHUD(weaponData)
    currentEnergyWeapon = weaponData
    energyLevel = 100
    hudEnabled = true
    
    Citizen.CreateThread(function()
        while hudEnabled and currentEnergyWeapon do
            local playerPed = PlayerPedId()
            
            if GetSelectedPedWeapon(playerPed) ~= -1569615261 then
                DrawEnergyWeaponHUD(weaponData)
                
                if IsPedShooting(playerPed) then
                    energyLevel = math.max(0, energyLevel - weaponData.stats.energy_cost)
                    
                    if energyLevel <= 0 then
                        ESX.ShowNotification('~r~¡Energía agotada! Recarga necesaria.')
                        SetPedInfiniteAmmo(playerPed, false, GetSelectedPedWeapon(playerPed))
                    end
                end
            end
            
            Citizen.Wait(0)
        end
    end)
end

function DrawEnergyWeaponHUD(weaponData)
    SetTextFont(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    
    local energyPercent = energyLevel / 100
    local barWidth = 150
    local barHeight = 20
    local x = 0.02
    local y = 0.96
    
    DrawRect(x + (barWidth/2)/1920, y, barWidth/1920, barHeight/1080, 50, 50, 50, 150)
    
    local r, g, b = 0, 255, 0
    if energyPercent < 0.3 then r, g, b = 255, 0, 0 end
    if energyPercent < 0.6 then r, g, b = 255, 255, 0 end
    
    DrawRect(x + ((barWidth * energyPercent)/2)/1920, y, (barWidth * energyPercent)/1920, barHeight/1080, r, g, b, 200)
    
    SetTextEntry("STRING")
    AddTextComponentString("ENERGÍA: " .. math.floor(energyLevel) .. "%")
    DrawText(x, y - 0.02)
    
    SetTextEntry("STRING")
    AddTextComponentString("ARMA: " .. weaponData.label)
    DrawText(x, y - 0.05)
end

function RechargeEnergyWeapon()
    if currentEnergyWeapon then
        ESX.TriggerServerCallback('esx_advanced_weapons:hasEnergyCell', function(hasCell)
            if hasCell then
                energyLevel = 100
                ESX.ShowNotification('~g~Energía recargada al 100%')
                TriggerServerEvent('esx_advanced_weapons:useEnergyCell')
            else
                ESX.ShowNotification('~r~No tienes celdas de energía')
            end
        end)
    else
        ESX.ShowNotification('~y~No tienes un arma de energía equipada')
    end
end

RegisterCommand('recargarenergia', function()
    RechargeEnergyWeapon()
end, false)

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local sleep = 1000
        
        local labLocation = Config.AdvancedWeapons.energyWeapons.craftingLocation
        local distance = #(playerCoords - labLocation)
        
        if distance < 15.0 then
            sleep = 0
            DrawMarker(1, labLocation.x, labLocation.y, labLocation.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 200, 255, 100, false, true, 2, false, nil, nil, false)
            
            if distance < 1.5 then
                ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para acceder al laboratorio de armas de energía')
                if IsControlJustPressed(0, 38) then
                    OpenEnergyWeaponsMenu()
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)