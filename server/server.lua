if Config.QBCore then
    local QBCore = exports['qb-core']:GetCoreObject()
else -- qbcore-change
    --add your frameworks export or getobject
end

function GetFuelType(vehicle,plate)
    local fueltype =  Config.FuelTypes[1]
    MySQL.query('SELECT * FROM player_vehicles WHERE plate = ?',{plate}, function(result) -- qbcore-change possibly??
        if result[1] then
            for i = 1,#Config.FuelTypes,1 do
                if Config.FuelTypes[i] == table.unpack(result).fueltype then
                    fueltype = table.unpack(result).fueltype
                end
            end
        end
        return fueltype
    end)
end

function GetOverflowTank(fuelamount,currentfuel,capacity) -- heard esx doesnt pass item info through ox inventory so good luck! u might just have the items only fill up all the way when u purchase them and when u use each one have it fill up the car X amount of gas
    local getneg = (fuel + currentfuel) - capacity
    if getneg > 0 then
        return getneg
    else 
        return false
    end
end

if Config.QBCore then

    function GiveCan(capacity)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local info = {
            capacity = capacity,
            filled = 0,
            type = 0
        }
        Player.Functions.AddItem('gascan', 1, false, info)
    end
    
    function SetCanLevel(item,fuel,fueltype)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local slot = item.info.slot
        local capacity = item.info.capacity
        local name = item.name
        if Player.Functions.RemoveItem(name, 1, slot) then
            local info = {
                capacity = capacity,
                filled = fuel,
                type = fueltype
            }
            Player.Functions.AddItem(name, 1, slot, info)
        end
    end

    function PayFuel(cost,paytype)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if paytype == 'cash' then
            if Player.Functions.RemoveMoney('cash', cost) then
                return true
            else
                TriggerClientEvent('k-fuel:notify', src, Config.Notifications['cashless'], 'error', 5000)
                return false
            end
        elseif paytype == 'bank' then
            local item = Player.Functions.GetItemByName('mastercard')
            local item2 = Player.Functions.GetItemByName('visa')
            if item ~= nil or item2 ~= nil then
                if Player.PlayerData.money.bank >= cost then
                    if Player.Functions.RemoveMoney('bank', cost) then
                        return true
                    else
                        TriggerClientEvent('k-fuel:notify', src, Config.Notifications['bankless'], 'error', 5000)
                        return false
                    end
                else
                    TriggerClientEvent('k-fuel:notify', src, Config.Notifications['bankless'], 'error', 5000)
                    return false
                end
            else
                TriggerClientEvent('k-fuel:notify', src, Config.Notifications['cardless'], 'error', 5000)
                return false
            end
        elseif paytype == 'credit' then
            local item = Player.Functions.GetItemByName('creditcard')
            if item ~= nil then
                if exports['k-credit']:ChargeCard(item.info.cardnumber,cost) then
                    return true
                else
                    TriggerClientEvent('k-fuel:notify', src, Config.Notifications['creditless'], 'error', 5000)
                    return false
                end
            else
                TriggerClientEvent('k-fuel:notify', src, Config.Notifications['cardless'], 'error', 5000)
                return false
            end
        end
    end

    function GetCan(src)
        local Player = QBCore.Functions.GetPlayer(src)
        local item = Player.Functions.GetItemByName('gascan')
        if item ~= nil then
            return item
        else 
            return false
        end
    end

    function GetOverflowState(fuel)
        local src = source
        local item = GetCan(src)
        local capacity = item.info.capacity
        local holding = item.info.filled
        local getneg = (fuel + holding) - capacity
        if getneg > 0 then
            return getneg
        else 
            return false
        end
    end  

    RegisterNetEvent('k-fuel:setcanlevel', function(item,level)
        SetCanLevel(item,level)
    end)

    RegisterServerEvent('k-fuel:payforcan', function(data)
        if data.paytype == 'cash' then

        elseif data.paytype == 'debit' then

        elseif data.paytype == 'credit' then

        end
    end)

    QBCore.Functions.CreateUsableItem('gascan', function(source, item)
        local amount = item.info.filled
        local fueltype = item.info.type
        TriggerClientEvent('k-fuel:usecan', source, amount, fueltype, item)
    end)

else -- qbcore-change
    function GiveCan(capacity)
        -- local src = source
        -- local Player = QBCore.Functions.GetPlayer(src)
        -- local info = {
        --     capacity = capacity,
        --     filled = 0,
        --     type = 0
        -- }
        -- Player.Functions.AddItem('gascan', 1, false, info)
    end
    
    function SetCanLevel(item,fuel,fueltype)
        -- local src = source
        -- local Player = QBCore.Functions.GetPlayer(src)
        -- local slot = item.info.slot
        -- local capacity = item.info.capacity
        -- local name = item.name
        -- if Player.Functions.RemoveItem(name, 1, slot) then
        --     local info = {
        --         capacity = capacity,
        --         filled = fuel,
        --         type = fueltype
        --     }
        --     Player.Functions.AddItem(name, 1, slot, info)
        -- end
    end

    function PayFuel(cost,paytype) 
        --ADD UR FRAMEWORKS MONEY PASSING OR ITEM PASSING HERE!
        --if takemoney then return true end  -- replace take money with the function that takes that money type
        return false
    end

    
    function GetCan(src)
        --get info for gascan if your inventory passes item info
        if item ~= nil then
            return item
        else 
            return false
        end
    end

    function GetOverflowState(fuel) -- heard esx doesnt pass item info through ox inventory so good luck! u might just have the items only fill up all the way when u purchase them and when u use each one have it fill up the car X amount of gas
        local getneg = (fuel + currentlyholding) - capacity
        if getneg > 0 then
            return getneg
        else 
            return false
        end
    end

    -- create usable items for the gascan

end

RegisterServerEvent('k-fuel:fuelinfocan', function(vehicle,plate,amount,fueltype,item,currentfuel,tanksize)  
    local fuel = GetFuelType(vehicle,plate) 
    local newfuel = false
    if fuel == fueltype then
        newfuel = false 
    else
        newfuel = true
    end
    local over = GetOverflowTank(amount,currentfuel,tanksize)
    if over ~= false then
        amount = amount - over
        --set spill when ready
    end
    TriggerClientEvent('k-fuel:refuelvehicle', source, amount, newfuel)
    SetCanLevel(item,0,0)
end)

RegisterServerEvent('k-fuel:fuelinfo', function(data,vehicle,plate)  
    local fuel = GetFuelType(vehicle,plate)
    TriggerClientEvent('k-fuel:fueltypemenu', source, data, fuel)
end)

RegisterServerEvent('k-fuel:getfueltype', function(vehicle,plate)  
    local fuel = GetFuelType(vehicle,plate)
    TriggerClientEvent('k-fuel:fuelreductioncycle', source, vehicle, fuel, plate)
end)

RegisterServerEvent('k-fuel:purchasefuel', function(amount,amounttype,paytype,fueltype,ClosestFuel,newfuel,fillobject,currentfuel,tanksize)
    local src = source
    if amounttype == "gallons" then
        cost = amount * Config.Locations[ClosestFuel]['pricing'].refuel
        if fillobject == 'gascan' then
            local item = GetCan(src) 
            if item ~= nil then
                local over = GetOverflowState(amount)
                if over ~= false then
                    cost = cost - (over * Config.Locations[ClosestFuel]['pricing'].refuel)
                end 
                if PayFuel(cost,paytype) then
                    if item.info.type == fueltype then -- qb-core change  there are a couple calls for the  for item data which esx doesnt handle atm you may have to change this event around a bit
                        newfuel = false
                    else
                        newfuel = true
                    end
                    TriggerClientEvent('k-fuel:refuelcan', src, amount, fueltype, newfuel, item)
                end   
            else
                TriggerClientEvent('k-fuel:notify', src, Config.Notifications['nocan'], 'error', 5000)    
            end
        else
            local over = GetOverflowTank(amount,currentfuel,tanksize)
            if over ~= false then
                cost = cost - (over * Config.Locations[ClosestFuel]['pricing'].refuel)
            end
            if PayFuel(cost,paytype) then
                TriggerClientEvent('k-fuel:refuelvehicle', src, amount, fueltype, newfuel)
            end
        end
    else
        fuelamount = amount/Config.Locations[ClosestFuel]['pricing'].refuel 
        if fillobject == 'gascan' then
            local item = GetCan(src)
            if item ~= nil then
                local over = GetOverflowState(fuelamount)
                if over ~= false then
                    amount = amount - (over * Config.Locations[ClosestFuel]['pricing'].refuel)
                end
                if PayFuel(cost,paytype) then
                    if item.info.type == fueltype then
                        newfuel = false
                    else
                        newfuel = true
                    end
                    TriggerClientEvent('k-fuel:refuelcan', src, amount, fueltype, newfuel, item)
                end   
            else
                TriggerClientEvent('k-fuel:notify', src, Config.Notifications['nocan'], 'error', 5000)    
            end
            local over = GetOverflowState(fuelamount)
            if over ~= false then
                amount = amount - (over * Config.Locations[ClosestFuel]['pricing'].refuel)
            end
            if item.info.type == fueltype then
                newfuel = false
            else
                newfuel = true
            end
            if PayFuel(amount,paytype) then
                TriggerClientEvent('k-fuel:refuelcan', src, amount, fueltype, newfuel)
            end
        else
            local over = GetOverflowTank(fuelamount,currentfuel,tanksize) -- set this to look for vehicle fuel level
            if over ~= false then
                amount = amount - (over * Config.Locations[ClosestFuel]['pricing'].refuel)
            end
            if PayFuel(amount,paytype) then
                TriggerClientEvent('k-fuel:refuelvehicle', src, amount, fueltype, newfuel)
            end
        end
    end
end)