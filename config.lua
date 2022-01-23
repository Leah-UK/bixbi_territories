Config = {}

Config.Debug = true -- Allows live-restarting of the script.

Config.MenuKeybind = nil -- To enable set to something like 'o'.
Config.MenuCommand = 'territorymenu'

Config.MaxPercentage = 15 -- max cut the gang can set the territory to be. In percent (%).
Config.CaptureEnabled = true -- Allows parent territories to be captured.
Config.MaxTerritories = 2 -- how many zones a gang can own at any given time.
Config.TerritoryObject = { objModel = 'v_serv_abox_g1', targetModel = `v_serv_abox_g1` } -- Where to go to collect items / capture territory.
Config.BlacklistedJobs = { unemployed = {}, police = {}, ambulance = {}, mechanic = {} } -- These jobs are unable to start the capture of areas.
Config.HackItem = 'usb_territoryhack' -- Item needed to brute force into a stash.

Config.IllegalCurrency = 'black_money' -- Used for the selling of illegal goods.
Config.InProcessCurrency = 'uncut_money' -- Used for moneywash system.
Config.LegalCurrency = 'money'

Config.MenuType = 'zf' -- esx, zf

Config.Territories = {
    -- You can find the name of a territory by using the command "/territory".
    SKID = {
        label = "Skidrow",
        washzone = false,
        illegalitems = { 'processed_weed' },
        capture = { enabled = true, -- Capturable?
            objHeading = 100.0, location = vector3(427.99, -979.01, 30.7),
            captureTime = 1 -- minutes.
        }
    },
    zonetwo = {
        label = "Zone Two",
        parent = 'SKID', -- This means that when the parent is captured this will also be captured.
        washzone = false,
        illegalitems = { 'processed_weed', 'cocaine' }
    },
    CYPRE = {
        label = "Cypress Flats",
        washzone = true,
        capture = { enabled = true,
            objHeading = 100.0, location = vector3(858.83, -2362.57, 30.34),
            captureTime = 5
        }
    }
}