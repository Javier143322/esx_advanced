
local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_advanced_weapons:checkEnergyComponents', function(source, cb, requiredComponents)
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

RegisterServerEvent('esx_advanced_weapons:finishEnergyWeapon')
AddEventHandler('esx_advanced_weapons:finishEnergyWeapon', function(weaponName)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local weaponConfig = nil
    for _, weapon in ipairs(Config.AdvancedWeapons.energyWeapons.weapons) do
        if weapon.name == weaponName then
            weaponConfig = weapon
            break
        end
    end
    
    if not weaponConfig then return end
    
    local hasAllComponents = true
    for _, component in ipairs(weaponConfig.components) do
        local item = xPlayer.getInventoryItem(component.item)
        if item == nil or item.count < component.amount then
            hasAllComponents = false
            break
        end
    end
    
    if not hasAllComponents then
        xPlayer.showNotification('~r~Error: Componentes insuficientes')
        return
    end
    
    for _, component in ipairs(weaponConfig.components) do
        xPlayer.removeInventoryItem(component.item, component.amount)
    end
    
    local weaponItemName = "energy_" .. weaponName
    xPlayer.addInventoryItem(weaponItemName, 1)
    
    MySQL.Async.execute('INSERT INTO custom_weapons (owner, serial_number, weapon_model, weapon_type, components) VALUES (@owner, @serial, @model, @type, @components)', {
        ['@owner'] = xPlayer.identifier,
        ['@serial'] = 'ENE-' .. os.date('%y%m') .. '-' .. math.random(100000, 999999),
        ['@model'] = weaponName,
        ['@type'] = 'energy',
        ['@components'] = json.encode(weaponConfig.components)
    })
    
    xPlayer.showNotification('~b~Arma de energía fabricada: ' .. weaponConfig.label)
end)

ESX.RegisterServerCallback('esx_advanced_weapons:hasEnergyCell', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local energyCell = xPlayer.getInventoryItem('energy_cell')
    cb(energyCell ~= nil and energyCell.count > 0)
end)

RegisterServerEvent('esx_advanced_weapons:useEnergyCell')
AddEventHandler('esx_advanced_weapons:useEnergyCell', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('energy_cell', 1)
end)

MySQL.ready(function()
    local energyItems = {
        {name = 'energy_core', label = 'Núcleo de Energía', weight = 1.5, rare = 1},
        {name = 'laser_emitter', label = 'Emisor Láser', weight = 0.5, rare = 1},
        {name = 'power_cell', label = 'Celda de Potencia', weight = 0.8, rare = 0},
        {name = 'advanced_circuit', label = 'Circuito Avanzado', weight = 0.3, rare = 1},
        {name = 'micro_energy_core', label = 'Micro Núcleo de Energía', weight = 1.0, rare = 1},
        {name = 'grip_module', label = 'Módulo de Empuñadura', weight = 0.4, rare = 0},
        {name = 'display_interface', label = 'Interfaz de Pantalla', weight = 0.6, rare = 1},
        {name = 'energy_emitter', label = 'Emisor de Energía', weight = 0.7, rare = 1},
        {name = 'advanced_energy_core', label = 'Núcleo de Energía Avanzado', weight = 2.0, rare = 1},
        {name = 'hud_optic', label = 'Mira HUD', weight = 0.9, rare = 1},
        {name = 'suppressor_module', label = 'Módulo Supresor', weight = 1.2, rare = 1},
        {name = 'rail_interface', label = 'Interfaz de Riél', weight = 0.5, rare = 0},
        {name = 'forward_grip', label = 'Empuñadura Delantera', weight = 0.6, rare = 0},
        {name = 'energy_cell', label = 'Celda de Energía 8mm', weight = 0.3, rare = 0},
        {name = 'reinforced_housing', label = 'Housing Reforzado', weight = 1.2, rare = 0},
        {name = 'spring_mechanism', label = 'Mecanismo de Resorte', weight = 0.4, rare = 0},
        {name = 'quick_release_latch', label = 'Cierre de Liberación Rápida', weight = 0.2, rare = 0},
        {name = 'dual_housing', label = 'Housing Dual', weight = 2.0, rare = 1},
        {name = 'advanced_spring', label = 'Resorte Avanzado', weight = 0.6, rare = 1},
        {name = 'reinforced_tower', label = 'Torre Reforzada', weight = 0.8, rare = 1},
        {name = 'high_grade_metal', label = 'Metal de Alto Grado', weight = 0.5, rare = 0},
        {name = 'drum_mag_xt1', label = 'Cargador Tambor XT-1', weight = 2.5, rare = 0},
        {name = 'dual_drum_mag_dp01', label = 'Cargador Tambor Dual DP-01', weight = 4.0, rare = 1}
    }
    
    for _, item in ipairs(energyItems) do
        MySQL.Async.execute('INSERT IGNORE INTO items (name, label, weight, rare, can_remove) VALUES (@name, @label, @weight, @rare, 1)', {
            ['@name'] = item.name,
            ['@label'] = item.label,
            ['@weight'] = item.weight,
            ['@rare'] = item.rare
        })
    end
end)