
local currentCrafting = nil
local craftingInProgress = false

function ShowLegalWeaponsMenu()
    local elements = {}
    
    for _, weapon in ipairs(Config.CraftableWeapons.legal) do
        table.insert(elements, {
            label = string.format('%s - %s componentes', weapon.label, #weapon.components),
            value = weapon.name,
            weapon = weapon
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'legal_weapons_menu',
    {
        title = 'Fabricación Legal de Armas',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local weapon = data.current.weapon
        CheckComponentsAndCraft(weapon, 'legal')
    end, function(data, menu)
        menu.close()
    end)
end

function ShowIllegalWeaponsMenu(reputation)
    local elements = {}
    
    for _, weapon in ipairs(Config.CraftableWeapons.illegal) do
        if reputation >= (weapon.requiredReputation or 0) then
            table.insert(elements, {
                label = string.format('%s - Reputación: %s', weapon.label, weapon.requiredReputation or 0),
                value = weapon.name,
                weapon = weapon
            })
        else
            table.insert(elements, {
                label = string.format('~c~%s - Reputación: %s (Insuficiente)', weapon.label, weapon.requiredReputation or 0),
                value = weapon.name,
                disabled = true
            })
        end
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'illegal_weapons_menu',
    {
        title = 'Mercado Negro - Tu Reputación: ' .. reputation,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if not data.current.disabled then
            local weapon = data.current.weapon
            CheckComponentsAndCraft(weapon, 'illegal')
        end
    end, function(data, menu)
        menu.close()
    end)
end

function CheckComponentsAndCraft(weapon, weaponType)
    ESX.TriggerServerCallback('esx_advanced_weapons:checkComponents', function(hasComponents, missingComponents)
        if hasComponents then
            StartCraftingProcess(weapon, weaponType)
        else
            ShowMissingComponents(missingComponents)
        end
    end, weapon.components)
end

function ShowMissingComponents(missingComponents)
    local elements = {}
    
    for _, component in ipairs(missingComponents) do
        table.insert(elements, {
            label = string.format('~r~Falta: %s x%d', component.label, component.amount)
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'missing_components',
    {
        title = 'Componentes Faltantes',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function StartCraftingProcess(weapon, weaponType)
    if craftingInProgress then
        ESX.ShowNotification('~y~Ya estás fabricando un arma')
        return
    end
    
    craftingInProgress = true
    currentCrafting = weapon
    
    ESX.ShowNotification('~g~Comenzando fabricación: ' .. weapon.label)
    
    ESX.Progressbar("Fabricando " .. weapon.label, weapon.craftTime, {
        FreezePlayer = true,
        Animation = {
            type = "anim",
            dict = "amb@world_human_hammering@male@base",
            lib = "base"
        },
        onFinish = function()
            TriggerServerEvent('esx_advanced_weapons:finishCrafting', weapon.name, weaponType)
            craftingInProgress = false
            currentCrafting = nil
        end,
        onCancel = function()
            ESX.ShowNotification('~r~Fabricación cancelada')
            craftingInProgress = false
            currentCrafting = nil
        end
    })
end

function ShowLicenseMenu()
    local elements = {}
    
    for _, license in ipairs(Config.Legal.licenseTypes) do
        table.insert(elements, {
            label = string.format('%s - $%d', license.label, license.price),
            value = license.name,
            license = license
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'license_menu',
    {
        title = 'Licencias de Armas',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local license = data.current.license
        BuyLicense(license)
    end, function(data, menu)
        menu.close()
    end)
end

function BuyLicense(license)
    ESX.TriggerServerCallback('esx_advanced_weapons:buyLicense', function(success)
        if success then
            ESX.ShowNotification('~g~Licencia comprada: ' .. license.label)
            OpenLegalCraftingMenu()
        else
            ESX.ShowNotification('~r~No tienes suficiente dinero')
        end
    end, license.name)
end