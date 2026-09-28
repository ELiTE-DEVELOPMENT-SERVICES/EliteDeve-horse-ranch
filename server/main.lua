local Horses = {}       -- [identifier] = { [horseId] = {...} }
local PlayerMoney = {}  -- standalone fallback wallet
local lastTraining = {} -- [identifier][horseId] = os.time()

local function GetIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:match('license:') then return id end
    end
    return tostring(src)
end

local function LoadHorses()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'server/horses.json')
    if raw and raw ~= '' then
        Horses = json.decode(raw) or {}
    end
end

local function SaveHorses()
    SaveResourceFile(GetCurrentResourceName(), 'server/horses.json', json.encode(Horses), -1)
end

CreateThread(function() LoadHorses() end)

-- ===== Money bridge: replace this block with your framework's money functions =====
local function GetMoney(src)
    if Config.Framework == 'standalone' then
        PlayerMoney[src] = PlayerMoney[src] or 1000
        return PlayerMoney[src]
    end
    return 0
end

local function AddMoney(src, amount)
    if Config.Framework == 'standalone' then
        PlayerMoney[src] = (PlayerMoney[src] or 1000) + amount
        return
    end
end

local function RemoveMoney(src, amount)
    if Config.Framework == 'standalone' then
        PlayerMoney[src] = math.max(0, (PlayerMoney[src] or 1000) - amount)
        return
    end
end
-- ====================================================================================

local function RollStat(base)
    local roll = base + math.random(-Config.BaseStatVariance, Config.BaseStatVariance)
    return math.max(10, math.min(100, math.floor(roll)))
end

local function SendHorses(src)
    local id = GetIdentifier(src)
    TriggerClientEvent('horse-ranch:client:updateHorses', src, Horses[id] or {})
end

RegisterNetEvent('horse-ranch:server:requestData', function()
    local src = source
    TriggerClientEvent('horse-ranch:client:updateBalance', src, GetMoney(src))
    SendHorses(src)
end)

RegisterNetEvent('horse-ranch:server:buyHorse', function(breedIndex)
    local src = source
    local breed = Config.HorseBreeds[breedIndex]
    if not breed then return end
    if GetMoney(src) < breed.basePrice then
        TriggerClientEvent('horse-ranch:client:notify', src, "Not enough cash", "error")
        return
    end

    RemoveMoney(src, breed.basePrice)

    local id = GetIdentifier(src)
    Horses[id] = Horses[id] or {}
    local horseId = ("horse_%s_%s"):format(os.time(), math.random(1000, 9999))

    Horses[id][horseId] = {
        model = breed.model,
        name = breed.name,
        speed = RollStat(50),
        stamina = RollStat(50),
        temperament = RollStat(50),
        conditionStamina = 100,
    }

    SaveHorses()
    TriggerClientEvent('horse-ranch:client:updateBalance', src, GetMoney(src))
    SendHorses(src)
    TriggerClientEvent('horse-ranch:client:notify', src, ("Bought a new %s!"):format(breed.name), "success")
end)

RegisterNetEvent('horse-ranch:server:breedHorses', function(parentAId, parentBId)
    local src = source
    local id = GetIdentifier(src)
    local herd = Horses[id]
    if not herd or not herd[parentAId] or not herd[parentBId] or parentAId == parentBId then
        TriggerClientEvent('horse-ranch:client:notify', src, "Pick two different horses you own", "error")
        return
    end

    if GetMoney(src) < Config.BreedingFee then
        TriggerClientEvent('horse-ranch:client:notify', src, "Not enough cash to breed", "error")
        return
    end
    RemoveMoney(src, Config.BreedingFee)

    local a, b = herd[parentAId], herd[parentBId]
    local foalModel = math.random(1, 2) == 1 and a.model or b.model
    local horseId = ("horse_%s_%s"):format(os.time(), math.random(1000, 9999))

    herd[horseId] = {
        model = foalModel,
        name = ("%s x %s Foal"):format(a.name, b.name),
        speed = RollStat((a.speed + b.speed) / 2),
        stamina = RollStat((a.stamina + b.stamina) / 2),
        temperament = RollStat((a.temperament + b.temperament) / 2),
        conditionStamina = 100,
    }

    SaveHorses()
    TriggerClientEvent('horse-ranch:client:updateBalance', src, GetMoney(src))
    SendHorses(src)
    TriggerClientEvent('horse-ranch:client:notify', src, "A new foal was born!", "success")
end)

RegisterNetEvent('horse-ranch:server:finishTraining', function(horseId, taps)
    local src = source
    local id = GetIdentifier(src)
    local herd = Horses[id]
    if not herd or not herd[horseId] then return end
    local horse = herd[horseId]

    if (horse.conditionStamina or 100) < Config.TrainingStaminaCost then
        TriggerClientEvent('horse-ranch:client:notify', src, "This horse is too tired, let it rest", "error")
        return
    end

    local last = lastTraining[id] and lastTraining[id][horseId]
    if last and (os.time() - last) < (Config.TrainingCooldownMinutes * 60) then
        TriggerClientEvent('horse-ranch:client:notify', src, "This horse needs more rest before training again", "error")
        return
    end

    -- taps are client-reported; clamp to a sane server-trusted ceiling
    taps = math.min(tonumber(taps) or 0, 60)
    local performance = math.min(1, taps / 40)
    local gain = math.floor(Config.TrainingGainMin + (Config.TrainingGainMax - Config.TrainingGainMin) * performance)

    local stats = { 'speed', 'stamina', 'temperament' }
    local stat = stats[math.random(#stats)]
    horse[stat] = math.min(100, horse[stat] + gain)
    horse.conditionStamina = math.max(0, (horse.conditionStamina or 100) - Config.TrainingStaminaCost)

    lastTraining[id] = lastTraining[id] or {}
    lastTraining[id][horseId] = os.time()

    SaveHorses()
    SendHorses(src)
    TriggerClientEvent('horse-ranch:client:notify', src, ("Training complete! +%d %s"):format(gain, stat), "success")
end)

RegisterNetEvent('horse-ranch:server:sellHorse', function(horseId)
    local src = source
    local id = GetIdentifier(src)
    local herd = Horses[id]
    if not herd or not herd[horseId] then return end

    local horse = herd[horseId]
    local avgStat = (horse.speed + horse.stamina + horse.temperament) / 3
    local price = math.floor((avgStat / 100) * Config.SellPriceMultiplier * 100)

    herd[horseId] = nil
    AddMoney(src, price)
    SaveHorses()

    TriggerClientEvent('horse-ranch:client:updateBalance', src, GetMoney(src))
    SendHorses(src)
    TriggerClientEvent('horse-ranch:client:notify', src, ("Sold horse for $%d"):format(price), "success")
end)

-- slow passive stamina/condition recovery over time
CreateThread(function()
    while true do
        Wait(60000 * 5) -- every 5 minutes
        for _, herd in pairs(Horses) do
            for _, horse in pairs(herd) do
                horse.conditionStamina = math.min(100, (horse.conditionStamina or 100) + 10)
            end
        end
        SaveHorses()
    end
end)
