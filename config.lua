Config = {}

Config.QBCore = true -- tried to make this resource easily convertable just check out the framework.lua and server.lua a search for -- qbcore-change will take you to all the locations to change
Config.GenFuelPrice = 2 -- dollars per gallon assuming 2 dollars it would take about 100 to fill a pickup you can set individual stations below as well
Config.GenDropoffPrice = 2 -- dollars per gallon assuming 2 dollars it would take about 100 to fill a pickup you can set individual stations below as well
Config.SpillChance = false -- not yet setup see table below for when it is change this to true and adjust can params.

-- My Interacting Resources--
Config.ktuning = false -- not out yet
Config.kvehicles = false -- also not yet released
Config.Kstocks = true -- falsifies a ,management table so people can buy stocks for fuel
Config.Kcredit = true -- option to use credit card at the pump
-----------------------------

--Fuel Tables--
Config.Target = {
    ['active'] = true,
    ['labels'] = {
        refuel = ,
        depositfuel =
    },
    ['icon'] = {
        refuel = ,
        depositfuel =
    }
}
Config.Blip = {    -- for any reason u could technically use this table to create any blip u wanted for anything
    ['fueljob'] = {
        active = true,
        coords = vector3(),
        sprite = ,
        scale = ,
        color = ,
        label = ,
        routecolor = 
    },
    ['gasstations'] = {
        active = true,-- can set individual station blips inactive as well
        sprite = ,
        scale = ,
        color = ,
        label = 
    },
}

Config.Spill = { -- if u have a gas can in your pocket chance to spill some
    ['amount'] = {
        max = 0.5,
        min = 0.1
    },
    ['refreshchance'] = 5 -- how often it runs the pocket check in minutes for the item
}
Config.GasCan = {
    ['10gallongascan'] = {
        price = 50, --price for empty can
        size = 10, -- gallons
        spillchance = 5, -- chance to spill some of the gas if it is in your pockets
        label = '10 Gallon Empty Can'
    },
    ['20gallongascan'] = {
        price = 80, --price for empty can
        size = 20, -- gallons
        spillchance = 20, -- chance to spill some of the gas if it is in your pockets
        label = '20 Gallon Empty Can'
    },
    ['50gallongascan'] = {
        price = 120, --price for empty can
        size = 50, -- gallons
        spillchance = 50, -- chance to spill some of the gas if it is in your pockets
        label = '50 Gallon Empty Barrel'
    }
}
-- to require an individual vehicle model to use a certain fueltype/fuelusage just go into qb-core/shared/vehicles.lua
-- under each vehicle you want to require a certain fuel put this line:
-- ['fueltype'] = 'diesel',  --or whatever you want the fueltype to be
-- ['fueltank'] = 60,  --or whatever you want the fuel tank size to be 2 in "gallons" u could say liters whatever u want to use but it goes off the sizes above if nothing is in this slot it will default to 60
-- ['fueluse'] = 1.0,  --or whatever you want the fueltype to be 2.0 means it uses 2x the fuel to go the same distance, 0.5 would use half the fuel of 1.0 to go the same distance
Config.Usage = {
    ['active'] = {
        refresh = 1, -- time in seconds to refresh the fuel amount and usage check
        speed = true,
        classes = true,
        rpm = true
    },
    ['speed'] = {-- add and remove numbers in this format as needed
        [1] = {
            speed = 120,
            usage = 1.2
        },
        [2] = {
            speed = 150,
            usage = 1.5
        },
        [3] = {
            speed = 170,
            usage = 1.7
        },
        [4] = {
            speed = 200,
            usage = 2.0
        }
    },
    ['rpm'] = {-- add and remove numbers in this format as needed
        [1] = {
            rpm = 1000,
            usage = 0.7
        },
        [2] = {
            rpm = 2000,
            usage = 0.8
        },
        [3] = {
            rpm = 3000,
            usage = 0.9
        },
        [4] = {
            rpm = 4000,
            usage = 1.0
        },
        [5] = {
            rpm = 5000,
            usage = 1.2
        },
        [6] = {
            rpm = 6000,
            usage = 1.4
        },
        [7] = {
            rpm = 7000,
            usage = 1.5
        },
        [8] = {
            rpm = 8000,
            usage = 1.7
        },
        [9] = {
            rpm = 9000,
            usage = 1.9
        },
        [10] = {
            rpm = 10000,
            usage = 2.0
        }
    },
    ['classes'] = {
        [0] = 0.6, -- Compacts
        [1] = 0.8, -- Sedans
        [2] = 1.4, -- SUVs
        [3] = 0.7, -- Coupes
        [4] = 1.2, -- Muscle
        [5] = 1.1, -- Sports Classics
        [6] = 1.1, -- Sports
        [7] = 1.2, -- Super
        [8] = 0.4, -- Motorcycles
        [9] = 1.2, -- Off-road
        [10] = 1.4, -- Industrial
        [11] = 1.4, -- Utility
        [12] = 1.2, -- Vans
        [13] = 0.0, -- Cycles
        [14] = 1.2, -- Boats
        [15] = 1.2, -- Helicopters
        [16] = 1.2, -- Planes
        [17] = 1.0, -- Service
        [18] = 1.0, -- Emergency
        [19] = 1.0, -- Military
        [20] = 1.2, -- Commercial
        [21] = 1.0, -- Trains
    }
}
Config.FuelTypes = {-- can make as many or as little as you would like if u want it to be simple like legacy or you can have it complex like irl
    ['87octane'] = { --if a car can take multiple octanes and someone selects a different one it will ask them if they want to drain the tank that is in the car 
        label = '87',
        pricemlt = 1.0, -- price multiplier of the above price
        priceadd = 0, -- price add to the above price per gallon
        burnrate = 1.1, -- how fast the fuel burns
        enginewear = 1.1, --used in conjunction with k-vehicles --a lot of people are racecar drivers well normally a racecar driver would tear the engine up not using different octanes
        classes = {0,1,2,3,4,5,6,7,8,9,12,13,14,17,18,19,20},
        requirements = {}, -- certain addon mods the vehicle must have (Made for my extensive tuning(not yet released)!)
    },
    ['89octane'] = {
        label = '89',
        pricemlt = 1.0, -- price multiplier of the above price
        priceadd = 1, -- price add to the above price per gallon
        burnrate = 1.0, -- how fast the fuel burns
        enginewear = 1.0, --used in conjunction with k-vehicles --a lot of people are racecar drivers well normally a racecar driver would tear the engine up not using different octanes
        classes = {0,1,2,3,4,5,6,7,8,9,12,13,14,17,18,19,20},
        requirements = {}, -- certain addon mods the vehicle must have (Made for my extensive tuning(not yet released)!)
    },
    ['93octane'] = {
        label = '93',
        pricemlt = 1.1, -- price multiplier of the above price
        priceadd = 1, -- price add to the above price per gallon
        burnrate = 0.8, -- how fast the fuel burns
        enginewear = 0.9, --used in conjunction with k-vehicles --a lot of people are racecar drivers well normally a racecar driver would tear the engine up not using different octanes
        classes = {0,1,2,3,4,5,6,7,8,9,12,13,14,17,18,19,20},
        requirements = {}, -- certain addon mods the vehicle must have (Made for my extensive tuning(not yet released)!)
    },
    ['e85'] = {
        label = 'e85',
        pricemlt = 0.75, -- price multiplier of the above price
        priceadd = 0, -- price add to the above price per gallon
        burnrate = 1.3, -- how fast the fuel burns
        enginewear = 0.6, --used in conjunction with k-vehicles --a lot of people are racecar drivers well normally a racecar driver would tear the engine up not using different octanes
        classes = {0,1,2,3,4,5,6,7,8,9,12,13,14,17,18,19,20},
        requirements = {['ethanol_kit'] = 1, ['ethanol_tune'] = 1}, -- certain addon mods the vehicle must have (Made for my extensive tuning(not yet released)!)
    },
    ['diesel'] = {
        label = 'diesel',
        pricemlt = 1.2, -- price multiplier of the above price
        priceadd = 2, -- price add to the above price per gallon
        burnrate = 0.5, -- how fast the fuel burns
        enginewear = 0.3, --used in conjunction with k-vehicles --a lot of people are racecar drivers well normally a racecar driver would tear the engine up not using different octanes
        classes = {9,10,11,17,18,19,20},
        requirements = {} -- certain addon mods the vehicle must have (Made for my extensive tuning(not yet released)!)
    }
}

Config.Locations = {
    ['esbltd'] = {
        ['Label'] = 'LTD Gas Station'
        ['blip'] = vector3(), -- make this the location of where the cans are purchased
        ['pumps'] = {
            [1] = vector3(),
            [2] = vector3(),
            [3] = vector3(),
            [4] = vector3()
        },
        ['hours'] = {
            alwaysopen = true,
            open = 1,
            close = 2359
        },
        ['fueltypes'] = {
            '87octane',
            '89octane',
            '93octane'
        },
        ['pricing'] = {
            refuel = Config.GenFuelPrice,
            dropoff = Config.GenDropoffPrice
        },
        ['fillup'] = {
            filllocation = vector3(),
            receiptlocation = vector4(),
            receiptped = ,
        }
    }
}

Config.Notifications = {
    ['newfuel'] = 'You\'re tank will empty prior to using a new type of fuel',
    ['nocan'] = 'You dont have a gas can with you',
    ['cashless'] = 'You don\'t have enough cash for this transaction.',
    ['bankless'] = 'You don\'t have enough bank funds for this transaction.',
    ['cardless'] = 'You don\'t have a card for this transaction.',
    ['creditless'] = 'You don\'t have enough credit left for this transaction.',
    ['fuelchange'] = 'You are changing fuel types.',
    ['refueled'] = 'You successfully refueled.',
    ['progressbar'] = {
        ['station'] ={
            duration = 1, -- seconds per gallon
            label = 'Refueling Vehicle',
            animDict = 'weapon@w_sp_jerrycan',
            anim = 'fire',
            prop = ,
            bone = ,
            coords = ,
            rotation = 
        },
    }
}
