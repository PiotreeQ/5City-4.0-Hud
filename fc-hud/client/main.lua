local hudData = {
    ['health'] = 100, ['hunger'] = 100, ['thirst'] = 100,
    ['voice'] = {
        ['mode'] = 2,
        ['isTalking'] = false
    }
}
local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
local hudState = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    Wait(2500)
    SetupHud()
end)

Citizen.CreateThread(function()
    RequestStreamedTextureDict("map", false)
    while not HasStreamedTextureDictLoaded("map") do
        Citizen.Wait(0)
    end

    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "map", "radarmasksm")
    SetBlipAlpha(GetNorthRadarBlip(), 0.0)
    SetBlipScale(GetMainPlayerBlipId(), 0.7)
    SetMinimapClipType(1)

    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(1000)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

function SetupHud()
    DisplayRadar(false)
    SetRadarBigmapEnabled(true, false)
    Wait(100)
    SetRadarBigmapEnabled(false, false)
    SendNUIMessage({action = 'ToggleHud', state = true})
    hudState = true
end

function ToggleHUD()
    print(hudState)
    SendNUIMessage({action = 'ToggleHud', state = not hudState})
    hudState = not hudState
end

RegisterCommand("togglehud", function()
    ToggleHUD()
end)

RegisterKeyMapping("togglehud", "Przełącz HUD", "mouse_button", "MOUSE_MIDDLE")

AddEventHandler('esx_status:onTick', function(data)
    local updateStatus = false
    for i = 1, #data, 1 do
        local status = data[i]
        if status.name == 'hunger' then
            local newHunger = math.floor(status.percent)
            if hudData.hunger ~= newHunger then
                updateStatus = true
                hudData.hunger = newHunger
            end
        elseif status.name == 'thirst' then
            local newThirst = math.floor(status.percent)
            if hudData.thirst ~= newThirst then
                updateStatus = true
                hudData.thirst = newThirst
            end
        end
    end

    local newHealth = LocalPlayer.state.isDead and 0 or math.floor(GetEntityHealth(cache.ped) / 2)
    if newHealth ~= hudData.health then
        updateStatus = true
        hudData.health = newHealth
    end

    if updateStatus then
        SendNUIMessage({
            action = 'UpdateMainHud',
            hud = hudData
        })
    end
end)

AddEventHandler('pma-voice:setTalkingMode', function(data)
    if data ~= hudData['voice']['mode'] then
        hudData['voice']['mode'] = data
        SendNUIMessage({
            action = 'UpdateMainHud',
            hud = hudData
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        local isTalking = NetworkIsPlayerTalking(PlayerId())
        if type(isTalking) == 'number' and isTalking == 1 then
            isTalking = true
        end

        if hudData['voice']['isTalking'] ~= isTalking then
            hudData['voice']['isTalking'] = isTalking
            SendNUIMessage({
                action = 'UpdateMainHud',
                hud = hudData
            })
        end
        Wait(1000)
    end
end)

local inVeh = false
lib.onCache('vehicle', function(value)
    inVeh = value and true or false
    DisplayRadar(inVeh)
    SendNUIMessage({action = 'ToggleCarHud', state = inVeh})
    Citizen.CreateThread(function()
        while inVeh do
            local heading = 360.0 - ((GetGameplayCamRot(0).z + 360.0) % 360.0)
            local coords = GetEntityCoords(value)
            local carHud = {
                speed = math.floor(GetEntitySpeed(value) * 3.6),
                direction = directions[(math.floor((heading / 45) + 0.5) % 8) + 1],
                street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)),
                fuel = GetVehicleFuelLevel(value),
                engine = GetIsVehicleEngineRunning(value),
                belt = true -- export for seat belt
            }
            SendNUIMessage({
                action = 'UpdateCarHud',
                hud = carHud
            })
            Citizen.Wait(100)
        end
    end)
end)

AddEventHandler('esx:pauseMenuActive', function(isActive)
    hudState = not isActive
    SendNUIMessage({action = 'ToggleHud', state = not isActive})
end)

function SendNotification(data)
    SendNUIMessage({
        action = 'ShowNotification',
        data = data
    })
end

exports('SendNotification', SendNotification)

-- RegisterCommand('test_notify1', function()
--     SendNotification({
--         label = 'Testowa notyfikacja',
--         duration = 5000,
--         type = 'warning'
--     })
-- end)

-- RegisterCommand('test_notify2', function()
--     SendNotification({
--         label = 'Testowa notyfikacja',
--         duration = 7000,
--         type = 'info'
--     })
-- end)

-- RegisterCommand('test_notify3', function()
--     SendNotification({
--         label = 'Testowa notyfikacja',
--         duration = 6000,
--         type = 'success'
--     })
-- end)