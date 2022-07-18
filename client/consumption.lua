local alerted = false

local function FuelUsage(vehicle,fueltype,plate)
	if not DecorExistOn(vehicle, "_FUEL_LEVEL") then
		SetFuel(vehicle, math.random(200, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))
		fuelSynced = true
	end
	local ped = PlayerPedId()
    local usevarRPM = 1.0
    local usevar = 1.0
    local usevarclass = 1.0
	if IsVehicleEngineOn(vehicle) then
        local speed = GetEntitySpeed(vehicle) * 2.23694
        local rpm = math.floor(GetVehicleCurrentRpm(vehicle) * 1)
		if Config.Usage['active'].speed then
            local loopnum = 0
            for i = 1,#Config.Usage['speed'],1 do  --usevar = speed multiplier
                if loopnum == 0 then
                    loopnum = loopnum + 1
                    if speed > Config.Usage['speed'][i].speed and < Config.Usage['speed'][i + 1].speed then
                        usevar = Config.Usage['speed'][i].usage
                    end
                elseif loopnum == #Config.Usage['speed'] then
                    loopnum = loopnum + 1
                    if speed > Config.Usage['speed'][i].speed then
                        usevar = Config.Usage['speed'][i].usage
                    end
                elseif loopnum ~= 0 and loopnum ~= #Config.Usage['speed'] then
                    loopnum = loopnum + 1
                    if speed > Config.Usage['speed'][i].speed and < Config.Usage['speed'][i + 1].speed then
                        usevar = Config.Usage['speed'][i].usage
                    elseif speed < Config.Usage['speed'][i].speed and > Config.Usage['speed'][i - 1].speed then
                        usevar = Config.Usage['speed'][i - 1].usage
                    elseif speed > Config.Usage['speed'][i + 1].speed then
                        usevar = Config.Usage['speed'][i + 1].usage
                    else
                        usevar = 1.0
                    end
                end
            end
        end
        if Config.Usage['active'].rpm then
            local loopnum = 0
            for i = 1,#Config.Usage['rpm'],1 do  --usevarRPM = rpm multiplier
                if loopnum == 0 then
                    loopnum = loopnum + 1
                    if rpm > Config.Usage['rpm'][i].rpm and < Config.Usage['rpm'][i + 1].rpm then
                        usevarRPM = Config.Usage['rpm'][i].usage
                    end
                elseif loopnum == #Config.Usage['rpm'] then
                    loopnum = loopnum + 1
                    if rpm > Config.Usage['rpm'][i].rpm then
                        usevarRPM = Config.Usage['rpm'][i].usage
                    end
                elseif loopnum ~= 0 and loopnum ~= #Config.Usage['rpm'] then
                    loopnum = loopnum + 1
                    if rpm > Config.Usage['rpm'][i].rpm and < Config.Usage['rpm'][i + 1].rpm then
                        usevarRPM = Config.Usage['rpm'][i].usage
                    elseif rpm < Config.Usage['rpm'][i].rpm and > Config.Usage['rpm'][i - 1].rpm then
                        usevarRPM = Config.Usage['rpm'][i - 1].usage
                    elseif rpm > Config.Usage['rpm'][i + 1].rpm then
                        usevarRPM = Config.Usage['rpm'][i + 1].usage
                    else
                        usevarRPM = 1.0
                    end
                end
            end
        end
        if Config.Usage['active'].classes then
            usevarclass = Config.Usage['classes'][GetVehicleClass(vehicle)]
        end
        local tanksize = 60.0    
        if Config.QBCore then
            for k,v in pairs(QBCore.Shared.Vehicles) do
                if GetEntityModel(vehicle) == GetHashKey(v['hash']) then
                    tanksize = v['fueltank']
                    if tanksize == nil then
                        tanksize = 60.0
                    end
                end
            end
        else
            tanksize = ReturnTank(GetEntityModel(vehicle))
        end
        local burnrate = 1.0
        if Config.FuelTypes[fueltype].burnrate ~= nil then
            burnrate = Config.FuelTypes[fueltype].burnrate
        end
		local amount = usevarclass * usevarRPM * usevar * burnrate
        if Config.ktuning then
            local tune = exports['k-tuning']:GetTune(plate)
            if tune.fuelusage ~= nil and tune.fuelusage ~= 0 then
                amount = amount * tune.fuelusage
            end
        end
        local currentfuel = (GetVehicleFuelLevel(vehicle)/100) * tanksize
        local newfuel = math.floor(currentfuel - (amount/100 * tanksize))
		SetFuel(vehicle, newfuel)
		SetVehicleEngineOn(veh, true, true, true)
        if newfuel < 25 not alerted then
            alerted = true
            TriggerEvent('k-fuel:lowfuel')
        end
        if Config.kvehicles then
            local enginewear = Config.FuelTypes[fueltype].enginewear
            exports['k-vehicles']:PartWear('engine',enginewear)
        end
	end
end

CreateThread(function()
    for k,v in pairs(Config.Blip) do
        if v.active then
	        local blip = AddBlipForCoord(v.coords)
	        SetBlipSprite(blip, v.sprite)
	        SetBlipScale(blip, v.scale)
	        SetBlipColour(blip, v.color)
	        SetBlipDisplay(blip, 4)
	        SetBlipAsShortRange(blip, true)
	        BeginTextCommandSetBlipName("STRING")
	        AddTextComponentString(v.label)
	        EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
	DecorRegister("_FUEL_LEVEL", 1)
	while true do
		Wait(Config.Usage['active'].refresh * 1000)
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped, false)
            local plate = GetVehicleNumberPlateText(vehicle)
			if GetPedInVehicleSeat(vehicle, -1) == ped then
				TriggerServerEvent('k-fuel:getfueltype', vehicle, plate)
			end
		else
            alerted = false
			if fuelSynced then
				fuelSynced = false
			end
		end
	end
end)
