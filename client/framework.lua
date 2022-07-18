if Config.QBCore then
    local QBCore = exports['qb-core']:GetCoreObject()
    local testtab = {}
    local notify = false

    local function Listen4Control(k,pump)
        CreateThread(function()
            listen = true
            while listen do
                if IsControlJustPressed(0, 38) then -- E
                    exports["qb-core"]:KeyPressed()
                    local data = {
                        station = k
                    }
                    if pump then
                        TriggerEvent("k-fuel:vehicleinfo", data)
                    else
                        TriggerEvent("k-fuel:canmenu", data)
                    end
                    listen = false
                    break
                end
                Wait(1)
            end
        end)
    end

    CreateThread(function()
        if not Config.Target['active'] then
            for k,v in pairs(Config.Locations) do
                local pumps = Config.Locations[k]['pumps']
                for i = 1,#pumps,1 do
                    local zone = BoxZone:Create(Config.Locations[k]['pumps'][i], 2, 2, {
                        debugPoly = false,
                        name = k,
                        minZ = Config.Locations[k]['pumps'][i].z - 5.0,
                        maxZ = Config.Locations[k]['pumps'][i].z + 5.0
                    })
                    zone:onPlayerInOut(function(isPointInside, _, zone)
                        if isPointInside then
                            exports["qb-core"]:DrawText("[E] "..Config.Locations[k]['Label'])
                            Listen4Control(k,true)
                        else
                            exports["qb-core"]:HideText()
                            listen = false
                        end
                    end)
                end
            end
            for k,v in pairs(Config.Locations) do
                local zone = BoxZone:Create(Config.Locations[k]['blip'], 2, 2, {
                    debugPoly = false,
                    name = k,
                    minZ = Config.Locations[k]['blip'].z - 5.0,
                    maxZ = Config.Locations[k]['blip'].z + 5.0
                })
                zone:onPlayerInOut(function(isPointInside, _, zone)
                    if isPointInside then
                        exports["qb-core"]:DrawText("[E] Buy Gas Cans")
                        Listen4Control(k,false)
                    else
                        exports["qb-core"]:HideText()
                        listen2 = false
                    end
                end)
            end
        else
            for k,v in pairs(Config.Locations) do
                local pumps = Config.Locations[k]['pumps']
                for i = 1,#pumps,1 do
                    exports['qb-target']:AddBoxZone(k, Config.Locations[k]['pumps'][i], 2, 2, {
                        name=k,
                        minZ = Config.Locations[k]['pumps'][i].z - 5.0,
                        maxZ = Config.Locations[k]['pumps'][i].z + 5.0
                        --debugPoly=true
                        }, {
                        options = {
                            {
                                event = "k-fuel:vehicleinfo",
                                icon = Config.Target['icon'].refuel,
                                label = Config.Locations[k]['Label'],
                                station = k
                            },
                        },
                        distance = 2.5
                    })
                end
            end
            for k,v in pairs(Config.Locations) do
                local pumps = Config.Locations[k]['blip']
                exports['qb-target']:AddBoxZone(k, Config.Locations[k]['blip'], 2, 2, {
                    name=k,
                    minZ = Config.Locations[k]['blip'].z - 5.0,
                    maxZ = Config.Locations[k]['blip'].z + 5.0
                    --debugPoly=true
                    }, {
                    options = {
                        {
                            event = "k-fuel:canmenu",
                            icon = Config.Target['icon'].refuel,
                            label = 'Buy Gas Cans',
                            station = k
                        },
                    },
                    distance = 2.5
                })
            end
        end
    end)

    RegisterNetEvent('k-fuel:vehicleinfo', function(data)        
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('k-fuel:fuelinfo', data, vehicle, plate)
    end)

    RegisterNetEvent('k-fuel:notify', function(txt,type,duration)
        QBCore.Functions.Notify(txt,type,duration) -- edit what handles ur notifications// type is error or success
    end)

    RegisterNetEvent('k-fuel:canmenu', function(data)
        local shop = data.k -- not used atm but may be useful in future ;) when i connect it to stocks and possibly ownable shops
        local Canoptions = {}
        Canoptions = {
            {
                header = "| Purchase Cans |",
                txt = Config.Locations[shop]['Label'], 
                isMenuHeader = true
            }
        }
        for k,v in pairs(Config.GasCan) do
                Canoptions[#Canoptions+1] = {
                    header = v.label,
                    txt = "$"..v.price,
                    params = {
                        event = 'k-fuel:paytype',
                        args = {
                            name = k,
                            price = v.price,
                            size = v.size
                        }
                    }
                }
            end
        end
        exports['qb-menu']:openMenu(Canoptions)
    end)

    RegisterNetEvent('k-fuel:paytype', function(data)
        local name = data.name
        local price = data.price
        local size = data.size
        local paytype = {}
        paytype = {
            {
                header = "| Pay Type |",
                isMenuHeader = true
            },
            {
                header = "Cash",
                txt = "$"..price,
                params = {
                    event = 'k-fuel:paytype',
                    args = {
                        name = name,
                        price = price,
                        size = size,
                        paytype = 'cash'
                    }
                }
            },
            {
                header = "Debit",
                txt = "$"..price,
                params = {
                    event = 'k-fuel:paytype',
                    args = {
                        name = name,
                        price = price,
                        size = size,
                        paytype = 'bank'
                    }
                }
            }
        }            
        paytype[#paytype+1] = {
            header = "Credit",
            txt = "$"..price,
            params = {
                event = 'k-fuel:paytype',
                args = {
                    name = name,
                    price = price,
                    size = size,
                    paytype = 'credit'
                }
            }
        }
        exports['qb-menu']:openMenu(paytype)
    end)

    RegisterNetEvent('k-fuel:buycan', function(data)
        TriggerServerEvent('k-fuel:payforcan', data)
    end)

    RegisterNetEvent('k-fuel:fueltypemenu', function(data,fuel)
        local Buyoptions = {}
        Buyoptions = {
            {
                header = "| Purchase Fuel |",
                txt = "If you change fuel types it will drain your tank.",
                isMenuHeader = true
            }
        }
        for k,v in pairs(Config.Locations[data.station]['fueltypes']) do
                Buyoptions[#Buyoptions+1] = {
                    header = v,
                    txt = "$"..Config.Locations[data.station]['pricing'].refuel.."/gallon Unleaded",
                    params = {
                        event = 'k-fuel:pumpmenu',
                        args = {
                            station = data.station,
                            currentfuel = fuel,
                            type = v
                        }
                    }
                }
            end
        end
        exports['qb-menu']:openMenu(Buyoptions)
    end)
    
    RegisterNetEvent('k-fuel:pumpmenu', function(data)
        local dialog = nil
        --[[if not notify then -- will only let them know this the first time they fill up before tsunami
            notify = true
            TriggerEvent('k-fuel:notify', Config.Notifications['newfuel'], 'success', 5000)
        end]]
        local fueltypes = {}
        for k,v in pairs(Config.Locations[data.station]['fueltypes']) do
            fueltypes[#fueltypes+1] = {
                { value = k, text = Config.FuelTypes[k].label } 
            }
        end
        if Config.kcredit then
            dialog = exports['qb-input']:ShowInput({
                header = "| Pump Options | Fuel: "..data.currentfuel.." |",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Amount", 
                        name = "gasamount", 
                        type = "number", 
                        isRequired = true, 
                    },
                    {
                        text = "Amount Type", 
                        name = "amounttype", 
                        type = "radio", 
                        options = { 
                            { value = "gallons", text = "Gallons" }, 
                            { value = "money", text = "Dollars" } 
                        },
                    },
                    {
                        text = "Payment Type", 
                        name = "paytype", 
                        type = "radio", 
                        options = { 
                            { value = "cash", text = "Cash" }, 
                            { value = "credt", text = "Credit" }, 
                            { value = "debit", text = "Debit" }  
                        },
                    },
                    {
                        text = "Fuel Type", 
                        name = "fueltype", 
                        type = "radio", 
                        options = fueltypes,
                    },
                    {
                        text = "What to Fill?", 
                        name = "whattofill", 
                        type = "radio", 
                        options = { 
                            { value = "car", text = "Car" }, 
                            { value = "gascan", text = "Gas_Can" } 
                        },
                    },
                },
            })
        else
            dialog = exports['qb-input']:ShowInput({
                header = "| Pump Options | Fuel: "..data.currentfuel.." |",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Amount", 
                        name = "gasamount", 
                        type = "number", 
                        isRequired = true, 
                    },
                    {
                        text = "Amount Type", 
                        name = "amounttype", 
                        type = "radio", 
                        options = { 
                            { value = "gallons", text = "Gallons" }, 
                            { value = "money", text = "Dollars" } 
                        },
                    },
                    {
                        text = "Payment Type", 
                        name = "paytype", 
                        type = "radio", 
                        options = { 
                            { value = "cash", text = "Cash" }, 
                            { value = "debit", text = "Debit" }  
                        },
                    },
                    {
                        text = "Fuel Type", 
                        name = "fueltype", 
                        type = "radio", 
                        options = fueltypes,
                    },
                    {
                        text = "What to Fill?", 
                        name = "whattofill", 
                        type = "radio", 
                        options = { 
                            { value = "car", text = "Car" }, 
                            { value = "gascan", text = "Gas_Can" } 
                        },
                    },
                },
            })
        end
        if dialog ~= nil then
            local amount = tonumber(dialog['gasamount'])
            local paytype = dialog['paytype']
            local amounttype = dialog['amounttype']
            local fillobject = dialog['whattofill']
            local fueltype = dialog['fueltype']
            local ClosestFuel = data.station
            local tanksize = 60.0
            local currentfuel = 0
            if fillobject == 'car' then 
                for k,v in pairs(QBCore.Shared.Vehicles) do
                    if GetEntityModel(vehicle) == GetHashKey(v['hash']) then
                        tanksize = v['fueltank']
                        if tanksize == nil then
                            tanksize = 60.0
                        end
                    end
                end 
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                currentfuel = (GetVehicleFuelLevel(vehicle)/100) * tanksize
                if data.type == data.fueltype then
                    TriggerServerEvent('k-fuel:purchasefuel', amount, amounttype, paytype, fueltype, ClosestFuel, false, fillobject, currentfuel, tanksize)
                else
                    TriggerServerEvent('k-fuel:purchasefuel', amount, amounttype, paytype, fueltype, ClosestFuel, true, fillobject, currentfuel, tanksize)
                    TriggerEvent('k-fuel:notify', Config.Notifications['fuelchange'], 'error', 5000)
                end
            else
                currentfuel = false
                tanksize = false                
                TriggerServerEvent('k-fuel:purchasefuel', amount, amounttype, paytype, fueltype, ClosestFuel, false, fillobject, currentfuel, tanksize)
            end
        end
    end)
    
    RegisterNetEvent('k-fuel:usecan', function(amount,fueltype,item)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        local plate = GetVehicleNumberPlateText(vehicle)
        local tanksize = 60.0
        for k,v in pairs(QBCore.Shared.Vehicles) do
            if GetEntityModel(vehicle) == GetHashKey(v['hash']) then
                tanksize = v['fueltank']
                if tanksize == nil then
                    tanksize = 60.0
                end
            end
        end      
        local currentfuel = (GetVehicleFuelLevel(vehicle)/100) * tanksize
        TriggerServerEvent('k-fuel:fuelinfocan', vehicle, plate, amount, fueltype, item, currentfuel, tanksize)
    end)

    RegisterNetEvent('k-fuel:refuelvehicle', function(fuelamount,newfuel)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        local tanksize = 60.0
        for k,v in pairs(QBCore.Shared.Vehicles) do
            if GetEntityModel(vehicle) == GetHashKey(v['hash']) then
                tanksize = v['fueltank']
                if tanksize == nil then
                    tanksize = 60.0
                end
            end
        end        
        TaskTurnPedToFaceEntity(PlayerPedId(), vehicle, 2500)
        Wait(0)
        QBCore.Functions.Progressbar("refuel_vehicle", Config.Notifications['progressbar']['station'].label, Config.Notifications['progressbar']['station'].duartion * fuelamount, false, false, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = Config.Notifications['progressbar']['station'].animDict,
                anim = Config.Notifications['progressbar']['station'].anim,
                flags = 9,
            },  {
                model = Config.Notifications['progressbar']['station'].prop,
                bone = Config.Notifications['progressbar']['station'].bone,
                coords = Config.Notifications['progressbar']['station'].coords,
                rotation = Config.Notifications['progressbar']['station'].rotation,
                }, {}, function() -- Done
            if not newfuel then
                local currentfuel = (GetVehicleFuelLevel(vehicle)/100) * tanksize
                local freshfuel = math.floor(currentfuel + (fuelamount/100 * tanksize))
                SetFuel(vehicle, freshfuel)
                TriggerEvent('k-fuel:notify', Config.Notifications['refueled'], 'success', 5000)
            else
                SetFuel(vehicle, fuelamount)
                TriggerEvent('k-fuel:notify', Config.Notifications['refueled'], 'success', 5000)
            end
        end)
    end)

    RegisterNetEvent('k-fuel:refuelcan', function(fuelamount,newfuel,item)
        -- spawn gascan offset from ped 90* then have ped turn and fill it
        --TaskTurnPedToFaceEntity(PlayerPedId(), prop, 2500)
        Wait(0)
        QBCore.Functions.Progressbar("refuel_vehicle", Config.Notifications['progressbar']['stationcan'].label, Config.Notifications['progressbar']['station'].duartion * fuelamount, false, false, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = Config.Notifications['progressbar']['stationcan'].animDict,
                anim = Config.Notifications['progressbar']['stationcan'].anim,
                flags = 9,
            },  {
                model = Config.Notifications['progressbar']['stationcan'].prop,
                bone = Config.Notifications['progressbar']['stationcan'].bone,
                coords = Config.Notifications['progressbar']['stationcan'].coords,
                rotation = Config.Notifications['progressbar']['stationcan'].rotation,
                }, {}, function() -- Done
            if not newfuel then
                local currentfuel = item.info.filled
                local freshfuel = math.floor(currentfuel + fuelamount)
                SetFuel(vehicle, freshfuel)
                TriggerServerEvent('k-fuel:setcanlevel', item, freshfuel)
                TriggerEvent('k-fuel:notify', Config.Notifications['refueled'], 'success', 5000)
            else
                TriggerServerEvent('k-fuel:setcanlevel', item, fuelamount)
                TriggerEvent('k-fuel:notify', Config.Notifications['refueled'], 'success', 5000)
            end
        end)
    end)

    RegisterNetEvent('k-fuel:lowfuel', function()
    --trigger hud
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, "car_chime", 0.7)
    end)

else -- qbcore-change
    --if you have a different core add your getobject stuff here 

    RegisterNetEvent('k-fuel:notify', function(txt,type,duration)

    end)
    
    RegisterNetEvent('k-fuel:vehicleinfo', function(data)        
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('k-fuel:fuelinfo', data, vehicle, plate)
    end)
    
    RegisterNetEvent('k-fuel:pumpmenu', function(data)
        --put ur menu or input options here
        
        if fueltype == data.fueltype then
            TriggerServerEvent('k-fuel:purchasefuel', amount, amounttype, paytype, fueltype, ClosestFuel, false, fillobject, tanksize)
        else
            TriggerServerEvent('k-fuel:purchasefuel', amount, amounttype, paytype, fueltype, ClosestFuel, true, fillobject, tanksize)
            TriggerEvent('k-fuel:notify', Config.Notifications['fuelchange'], 'error', 5000)
        end
    end)
    
    RegisterNetEvent('k-fuel:lowfuel', function()
        -- trigger sound
        --trigger hud
    end)

    RegisterNetEvent('k-fuel:refuelvehicle', function(fuelamount,newfuel)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        local tanksize = 60.0  -- qbcore-change
        tanksize = ReturnTank(GetEntityModel(vehicle)) -- see commonexports to change this
        TaskTurnPedToFaceEntity(PlayerPedId(), vehicle, 2500)    
        -- animation and progressbar
        if not newfuel then
            local currentfuel = (GetVehicleFuelLevel(vehicle)/100) * tanksize
            local freshfuel = math.floor(currentfuel + (fuelamount/100 * tanksize))
            SetFuel(vehicle, freshfuel)
            TriggerEvent('k-fuel:notify', Config.Notifications['refueled'], 'success', 5000)
        else
            SetFuel(vehicle, amount)
            TriggerEvent('k-fuel:notify', Config.Notifications['refueled'], 'success', 5000)
        end
    end)
end