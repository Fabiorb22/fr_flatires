-------------------------------- FR_FLATIRES --------------------------------

-- Motor Roto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetEntityHealth(vehicle) <= 100 then
                SetVehicleUndriveable(vehicle, true)
            end
        end
    end
end)

-- Control de Pinchazo de Ruedas
local tyreStatus = {
    tyresPopped = 0,
    t0 = false,
    t1 = false,
    t4 = false,
    t5 = false
}

local speedLimits = {
    oneTyre = 83 / 3.6,  -- ~23 km/h
    twoTyres = 48 / 3.6, -- ~13 km/h
    threeTyres = 23 / 3.6 -- ~6 km/h
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        -- Reset tyres status
        tyreStatus.tyresPopped = 0
        tyreStatus.t0 = false
        tyreStatus.t1 = false
        tyreStatus.t4 = false
        tyreStatus.t5 = false

        -- Si el jugador está entrando a un vehículo
        if GetVehiclePedIsEntering(ped) ~= 0 then
            SetVehicleUndriveable(vehicle, false)
        end

        if DoesEntityExist(vehicle) then
            local defaultMaxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")

            -- Comprobamos las ruedas pinchadas
            if IsVehicleTyreBurst(vehicle, 0, true) and not tyreStatus.t0 then
                tyreStatus.t0 = true
                tyreStatus.tyresPopped = tyreStatus.tyresPopped + 1
            end
            if IsVehicleTyreBurst(vehicle, 1, true) and not tyreStatus.t1 then
                tyreStatus.t1 = true
                tyreStatus.tyresPopped = tyreStatus.tyresPopped + 1
            end
            if IsVehicleTyreBurst(vehicle, 4, true) and not tyreStatus.t4 then
                tyreStatus.t4 = true
                tyreStatus.tyresPopped = tyreStatus.tyresPopped + 1
            end
            if IsVehicleTyreBurst(vehicle, 5, true) and not tyreStatus.t5 then
                tyreStatus.t5 = true
                tyreStatus.tyresPopped = tyreStatus.tyresPopped + 1
            end

            -- Aplicamos límites de velocidad o deshabilitamos el vehículo
            if tyreStatus.tyresPopped == 1 then
                SetVehicleMaxSpeed(vehicle, speedLimits.oneTyre)
            elseif tyreStatus.tyresPopped == 2 then
                SetVehicleMaxSpeed(vehicle, speedLimits.twoTyres)
            elseif tyreStatus.tyresPopped == 3 then
                SetVehicleMaxSpeed(vehicle, speedLimits.threeTyres)
            elseif tyreStatus.tyresPopped >= 4 then
                SetVehicleUndriveable(vehicle, true)
            else
                SetVehicleMaxSpeed(vehicle, defaultMaxSpeed)
            end
        end
    end
end)