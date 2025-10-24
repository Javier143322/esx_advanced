function CheckPlayerLicenses()
    ESX.TriggerServerCallback('esx_advanced_weapons:getPlayerLicenses', function(licenses)
        if #licenses > 0 then
            ESX.ShowNotification('~g~Tienes ' .. #licenses .. ' licencias de armas activas')
        else
            ESX.ShowNotification('~y~No tienes licencias de armas activas')
        end
    end)
end

RegisterCommand('verlicencias', function()
    CheckPlayerLicenses()
end, false)

RegisterNetEvent('esx_advanced_weapons:policeNotification')
AddEventHandler('esx_advanced_weapons:policeNotification', function(message)
    local playerJob = ESX.GetPlayerData().job.name
    if playerJob == 'police' then
        ESX.ShowNotification('~b~ALERTA POLICIAL: ~w~' .. message)
    end
end)

RegisterNetEvent('esx_advanced_weapons:policeAlert')
AddEventHandler('esx_advanced_weapons:policeAlert', function(coords)
    local playerJob = ESX.GetPlayerData().job.name
    if playerJob == 'police' then
        SetNewWaypoint(coords.x, coords.y)
        ESX.ShowNotification('~r~ALERTA: ~w~Actividad ilegal de armas detectada - Waypoint marcado')
        
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 432)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 255)
        SetBlipScale(blip, 1.2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Actividad Ilegal")
        EndTextCommandSetBlipName(blip)
        
        Citizen.SetTimeout(120000, function()
            RemoveBlip(blip)
        end)
    end
end)
