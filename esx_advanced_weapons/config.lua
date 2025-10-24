Config = {}

-- Sistema Legal
Config.Legal = {
    enabled = true,
    craftingLocations = {
        vector3(16.6, -1114.6, 29.8),
        vector3(253.63, -51.87, 69.94)
    },
    requiredJobs = {'gunsmith', 'police'},
    licenseTypes = {
        {
            name = 'firearm_basic',
            label = 'Porte de Armas Básico',
            price = 5000,
            requiredJob = nil
        },
        {
            name = 'concealed_carry', 
            label = 'Porte Oculta',
            price = 15000,
            requiredJob = nil
        }
    }
}

-- Sistema Ilegal
Config.Illegal = {
    enabled = true,
    craftingLocations = {
        vector3(1391.95, 3605.73, 38.94),
        vector3(2433.59, 4968.93, 42.35)
    },
    requiredJobs = {'mafia', 'cartel', 'vagos'},
    blackMarketZones = {
        vector3(2480.12, -418.56, 93.73)
    }
}

-- Armas fabricables
Config.CraftableWeapons = {
    legal = {
        {
            name = 'pistol_9mm',
            label = 'Pistola 9mm',
            components = {
                {item = 'weapon_frame', amount = 1},
                {item = 'pistol_barrel', amount = 1},
                {item = 'metal', amount = 3},
                {item = 'pistol_grip', amount = 1}
            },
            craftTime = 30000,
            requiredLicense = 'firearm_basic'
        }
    },
    illegal = {
        {
            name = 'pistol_silenced',
            label = 'Pistola Silenciada',
            components = {
                {item = 'stolen_frame', amount = 1},
                {item = 'illegal_barrel', amount = 1},
                {item = 'metal', amount = 2},
                {item = 'silencer', amount = 1}
            },
            craftTime = 15000,
            requiredReputation = 10
        }
    }
}

-- Items necesarios
Config.RequiredItems = {
    'weapon_frame',
    'pistol_barrel', 
    'metal',
    'pistol_grip',
    'stolen_frame',
    'illegal_barrel',
    'silencer'
}

-- Color de notificaciones
Config.Color = 'inform'
Config.Timeout = 100