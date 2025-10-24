local ESX = nil
local currentLocation = nil
local inCraftingZone = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
    
    CreateCraftingZones()
end)

function CreateCraftingZones()
    Citizen.CreateThread(function()
        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local sleep = 1000
            
            for _, location in ipairs(Config.Legal.craftingLocations) do
                local distance = #(playerCoords - location)
                
                if distance < 10.0 then
                    sleep = 0
                    DrawMarker(1, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                    
                    if distance < 1.5 then
                        ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para fabricar armas legales')
                        if IsControlJustPressed(0, 38) then
                            OpenLegalCraftingMenu()
                        end
                    end
                end
            end
            
            for _, location in ipairs(Config.Illegal.craftingLocations) do
                local distance = #(playerCoords - location)
                
                if distance < 10.0 then
                    sleep = 0
                    DrawMarker(1, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                    
                    if distance < 1.5 then
                        ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para fabricar armas ilegales')
                        if IsControlJustPressed(0, 38) then
                            OpenIllegalCraftingMenu()
                        end
                    end
                end
            end
            
            Citizen.Wait(sleep)
        end
    end)
end

function OpenLegalCraftingMenu()
    ESX.TriggerServerCallback('esx_advanced_weapons:checkLegalAccess', function(hasAccess, hasLicense)
        if not hasAccess then
            ESX.ShowNotification('~r~No tienes acceso a esta armería legal')
            return
        end
        
        if not hasLicense then
            ESX.ShowNotification('~y~Necesitas una licencia de armas para fabricar')
            ShowLicenseMenu()
            return
        end
        
        ShowLegalWeaponsMenu()
    end)
end

function OpenIllegalCraftingMenu()
    ESX.TriggerServerCallback('esx_advanced_weapons:checkIllegalAccess', function(hasAccess, reputation)
        if not hasAccess then
            ESX.ShowNotification('~r~No eres bienvenido aquí')
            return
        end
        
        ShowIllegalWeaponsMenu(reputation)
    end)
end
