Config = {}

Config.Stables = {
    { coords = vector3(2420.0, 1400.0, 45.5), heading = 90.0, label = "Valentine Stable Ranch" },
}

Config.InteractionDistance = 1.5

Config.HorseBreeds = {
    { model = `A_C_Horse_Kentuckysaddle_BlackOvero`, name = "Kentucky Saddler",     basePrice = 150 },
    { model = `A_C_Horse_Missourifoxtrotter_Silver`,  name = "Missouri Fox Trotter", basePrice = 200 },
    { model = `A_C_Horse_Thoroughbred_Black`,         name = "Thoroughbred",         basePrice = 350 },
    { model = `A_C_Horse_Andalusian_Perlino`,         name = "Andalusian",           basePrice = 500 },
}

-- Stat ranges are 0-100
Config.BaseStatVariance = 15    -- +/- roll applied when breeding/buying
Config.TrainingGainMin = 2
Config.TrainingGainMax = 6
Config.TrainingStaminaCost = 15 -- condition cost per training session
Config.TrainingCooldownMinutes = 5

Config.BreedingFee = 100
Config.SellPriceMultiplier = 4  -- sell price = multiplier * avg(stats)/100 * 100

-- Hook these into your framework. 'standalone' keeps a simple in-memory wallet
-- and a JSON file for horse data so the script works out of the box.
Config.Framework = 'standalone' -- 'vorp', 'rsg', or 'standalone'
