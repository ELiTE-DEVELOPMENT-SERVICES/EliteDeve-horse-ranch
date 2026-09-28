local uiOpen = false
local previewPed = nil

local function DrawPrompt(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function OpenStableUI()
    uiOpen = true
    SetNuiFocus(true, true)
    TriggerServerEvent('horse-ranch:server:requestData')
    SendNUIMessage({ action = 'open', breeds = Config.HorseBreeds })
end

local function CloseUI()
    uiOpen = false
    SetNuiFocus(false, false)
    if DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
        previewPed = nil
    end
    SendNUIMessage({ action = 'close' })
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, s in ipairs(Config.Stables) do
            local dist = #(coords - s.coords)
            if dist < 8.0 then
                sleep = 0
                if dist < Config.InteractionDistance then
                    DrawPrompt(("Press ~INPUT_CONTEXT~ to manage %s"):format(s.label))
                    if IsControlJustPressed(0, 0xE10469E7) and not uiOpen then -- INPUT_CONTEXT
                        OpenStableUI()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNUICallback('close', function(_, cb) CloseUI() cb('ok') end)

RegisterNUICallback('buyHorse', function(data, cb)
    TriggerServerEvent('horse-ranch:server:buyHorse', data.breedIndex)
    cb('ok')
end)

RegisterNUICallback('breedHorses', function(data, cb)
    TriggerServerEvent('horse-ranch:server:breedHorses', data.parentA, data.parentB)
    cb('ok')
end)

RegisterNUICallback('sellHorse', function(data, cb)
    TriggerServerEvent('horse-ranch:server:sellHorse', data.horseId)
    cb('ok')
end)

RegisterNUICallback('startTraining', function(data, cb)
    StartTrainingMinigame(data.horseId)
    cb('ok')
end)

function StartTrainingMinigame(horseId)
    local taps = 0
    local duration = 5000
    local startTime = GetGameTimer()

    SendNUIMessage({ action = 'trainingStart', duration = duration })

    CreateThread(function()
        while GetGameTimer() - startTime < duration do
            Wait(0)
            DisableControlAction(0, 0x8CC9CD42, true) -- swallow jump while "working" the horse
            if IsControlJustPressed(0, 0x8CC9CD42) then -- INPUT_JUMP used as the "work the horse" key
                taps = taps + 1
                SendNUIMessage({ action = 'trainingTap', taps = taps })
            end
        end
        TriggerServerEvent('horse-ranch:server:finishTraining', horseId, taps)
    end)
end

RegisterNetEvent('horse-ranch:client:updateBalance', function(amount)
    SendNUIMessage({ action = 'balance', amount = amount })
end)

RegisterNetEvent('horse-ranch:client:updateHorses', function(horses)
    SendNUIMessage({ action = 'horses', horses = horses })
end)

RegisterNetEvent('horse-ranch:client:notify', function(msg, type)
    SendNUIMessage({ action = 'notify', message = msg, type = type })
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if DoesEntityExist(previewPed) then DeleteEntity(previewPed) end
end)
