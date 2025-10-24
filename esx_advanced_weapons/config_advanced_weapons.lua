-- Configuración expandida para armas futuristas y avanzadas
Config.AdvancedWeapons = {
    energyWeapons = {
        enabled = true,
        requiredJob = {'swat', 'military', 'specialops'},
        craftingLocation = vector3(-2200.0, 3230.0, 32.0),
        
        weapons = {
            {
                name = 'rdo7_energy_sidearm',
                label = 'RDO7 Energy Sidearm',
                model = 'WEAPON_RAYPISTOL',
                components = {
                    {item = 'energy_core', amount = 1},
                    {item = 'laser_emitter', amount = 1},
                    {item = 'power_cell', amount = 3},
                    {item = 'advanced_circuit', amount = 2}
                },
                craftTime = 60000,
                price = 1800,
                stats = {damage = 80, accuracy = 90, fire_rate = 95, energy_cost = 15}
            },
            {
                name = 'tx_p1_energy_pistol', 
                label = 'TX-P1 Energy Pistol',
                model = 'WEAPON_RAYPISTOL',
                components = {
                    {item = 'micro_energy_core', amount = 1},
                    {item = 'grip_module', amount = 1},
                    {item = 'display_interface', amount = 1},
                    {item = 'energy_emitter', amount = 1}
                },
                craftTime = 45000,
                price = 1600,
                stats = {damage = 70, accuracy = 85, fire_rate = 80, energy_cost = 10}
            },
            {
                name = 'xz_74_energy_rifle',
                label = 'XZ-74 Energy Rifle', 
                model = 'WEAPON_RAYCARBINE',
                components = {
                    {item = 'advanced_energy_core', amount = 1},
                    {item = 'hud_optic', amount = 1},
                    {item = 'suppressor_module', amount = 1},
                    {item = 'rail_interface', amount = 1},
                    {item = 'forward_grip', amount = 1}
                },
                craftTime = 90000,
                price = 3000,
                stats = {damage = 95, accuracy = 88, fire_rate = 75, energy_cost = 25}
            }
        }
    },

    customAttachments = {
        magazine_extensions = {
            {
                name = 'hyve_mag_extension',
                label = 'Hyve Mag Extension',
                price = 250,
                compatibleWeapons = {'pistol_9mm', 'pistol_silenced'},
                stats = {fire_rate = 10, control = -5, magazine_size = 5}
            }
        },

        advanced_optics = {
            {
                name = 'red_dot_optic',
                label = 'Red Dot Optic',
                price = 250,
                compatibleWeapons = {'all'},
                stats = {accuracy = 15, control = 8}
            },
            {
                name = 'hud_optic_sight',
                label = 'HUD Optic Sight',
                price = 1350,
                compatibleWeapons = {'xz_74_energy_rifle', 'rdo7_energy_sidearm'},
                stats = {accuracy = 25, range = 15, special_effect = 'hud_display'}
            }
        },

        custom_components = {
            {
                name = 'custom_slide',
                label = 'Custom Slide Extension',
                price = 250,
                compatibleWeapons = {'pistol_9mm', 'pistol_silenced'},
                stats = {accuracy = 8, fire_rate = 5, mobility = -3}
            },
            {
                name = 'vented_compensator',
                label = 'Vented Custom Compensator',
                price = 4050,
                compatibleWeapons = {'custom_rifle', 'xz_74_energy_rifle'},
                stats = {accuracy = 20, control = 15, damage = -5}
            },
            {
                name = 'aluminum_frame',
                label = 'Red Aluminum Frame',
                price = 1350,
                compatibleWeapons = {'pistol_9mm', 'pistol_silenced'},
                stats = {mobility = 10, control = 12, durability = 15}
            }
        },

        laser_systems = {
            {
                name = 'integrated_laser',
                label = 'Integrated Laser Sight',
                price = 1750,
                compatibleWeapons = {'rdo7_energy_sidearm', 'tx_p1_energy_pistol'},
                stats = {accuracy = 18, range = 10, special_effect = 'laser_pointer'}
            }
        }
    },

    tacticalGear = {
        holsters = {
            {
                name = 'kydx_iwb_holster',
                label = 'KYDX IWB Holster',
                price = 250,
                effect = 'faster_draw_time'
            }
        },

        energySystems = {
            {
                name = 'micro_energy_core',
                label = 'Micro Energy Core',
                price = 2000,
                description = 'Fuente de energía avanzada para armas futuristas'
            },
            {
                name = 'energy_cell',
                label = '8mm Energy Cell',
                price = 1800,
                description = 'Celda de energía de alto rendimiento'
            }
        }
    },

    -- Sistema de cargadores de tambor
    DrumMagazines = {
        enabled = true,
        
        magazines = {
            {
                name = 'drum_mag_xt1',
                label = 'Drum Mag XT-1',
                price = 2500,
                compatibleWeapons = {'assaultrifle', 'assaultrifle_mk2', 'compactrifle'},
                stats = {
                    magazine_size = 100,
                    reload_speed = -20,
                    mobility = -15,
                    control = -10
                },
                components = {
                    {item = 'reinforced_housing', amount = 1},
                    {item = 'spring_mechanism', amount = 2},
                    {item = 'quick_release_latch', amount = 4},
                    {item = 'metal', amount = 8}
                }
            },
            {
                name = 'dual_drum_mag_dp01', 
                label = 'Dual-Drum Mag DP-01',
                price = 3840,
                compatibleWeapons = {'machinegun', 'combatmg', 'combatmg_mk2'},
                stats = {
                    magazine_size = 200,
                    reload_speed = -35,
                    mobility = -25,
                    control = -20,
                    fire_rate = 10
                },
                components = {
                    {item = 'dual_housing', amount = 1},
                    {item = 'advanced_spring', amount = 4},
                    {item = 'reinforced_tower', amount = 2},
                    {item = 'high_grade_metal', amount = 12}
                }
            }
        }
    }
}
