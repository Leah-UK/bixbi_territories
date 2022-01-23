ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local dbTerritory = {}
local territoryCount = {}
local playerInfo = {}

-- ESX.RegisterCommand('drugtake', 'user', function(xPlayer, args, showError)
--     local source = xPlayer.playerId
-- 	if (territories[args.zone] == nil) then
--         TriggerClientEvent('bixbi_core:Notify', source, 'error', 'This isn\'t a territory.')
--     else
--         local territory = territories[args.zone]
--         if (territory.gang == xPlayer.job.name) then
--             if (xPlayer.job.grade ~= 4) then
--                 TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You are not the leader of your gang.')
--             else
--                 TriggerEvent('bixbi_territories:UpdateTake', args.zone, ESX.Math.Round(args.percent, 2))
--             end
--         else
--             TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You do not lead this zone.')
--         end
--     end
-- end, true, {help = 'Save a player to the database', validate = true, arguments = {
-- 	{name = 'zone', help = 'Zone Name, can get using /territory', type = 'string'},
--     {name = 'percent', help = 'Percentage (10 = 10%)', type = 'number'}
-- }})

RegisterServerEvent('bixbi_territories:sv_Sale')
AddEventHandler('bixbi_territories:sv_Sale', function(src, zone, type, amount, item, count)
    if (type == 'illegalgoods') then
        IllegalGoodsSale(src, zone, amount, item, count)
    elseif (type == 'moneywash') then
        MoneyWashSale(src, zone)
    end
end)

function IllegalGoodsSale(source, zone, amount, item, count)
    local territory, confZone = dbTerritory[zone], Config.Territories[zone]
    if (confZone == nil or confZone.illegalitems == nil or territory == nil) then return end
    if (exports.bixbi_core:sv_itemCount(source, item) < count) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You don\'t have enough of this item.', 8000)
        return 
    end

    local gangCut = tonumber(amount * (territory.itemstake / 100))
    local payment = tonumber(amount - gangCut)
    if (exports.bixbi_core:addItem(source, Config.IllegalCurrency, payment)) then
        exports.bixbi_core:removeItem(source, item, count)
        TriggerEvent('bixbi_territories:StashDeposit', zone, Config.IllegalCurrency, gangCut)
        TriggerClientEvent('bixbi_core:Notify', source, '', 'You have received $' .. payment .. ' and the controlling gang has taken a ' .. territory.itemstake .. '% cut.', 10000)
    end
end

function MoneyWashSale(source, zone)
    local territory, confZone = dbTerritory[zone], Config.Territories[zone]
    if (confZone == nil or confZone.washzone == nil or territory == nil) then return end

    local currencyCount = exports.bixbi_core:sv_itemCount(source, Config.IllegalCurrency)
    if (currencyCount <= 0) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You don\'t have enough illegal currency.', 8000)
        return 
    end

    local gangCut = tonumber(currencyCount * (territory.washtake / 100))
    local payment = tonumber(currencyCount - gangCut)
    if (exports.bixbi_core:addItem(source, Config.LegalCurrency, payment)) then
        exports.bixbi_core:removeItem(source, Config.IllegalCurrency, currencyCount)
        TriggerEvent('bixbi_territories:StashDeposit', zone, Config.InProcessCurrency, gangCut)
    TriggerClientEvent('bixbi_core:Notify', source, '', 'You have received $' .. payment .. ' and the controlling gang has taken a ' .. territory.washtake .. '% cut.', 10000)
    end
end

ESX.RegisterServerCallback('bixbi_territories:locationCheck', function(source, cb, location)
    if (dbTerritory[location] ~= nil) then
        local territory = Config.Territories[location]
        local parentTerritory = Config.Territories[territory.parent]

        if (territory.parent ~= nil) then 
            local result = {
                location = location,
                illegalitems = territory.illegalitems,
                washzone = territory.washzone,
                gang = dbTerritory[territory.parent].gang, 
                label = territory.label,
                parent = parentTerritory.label,
                itemstake = dbTerritory[territory.parent].itemstake,
                washtake = dbTerritory[territory.parent].washtake,
                capture = parentTerritory.capture
            }
            cb(result)
        else
            local result = {
                location = location,
                illegalitems = territory.illegalitems,
                washzone =territory.washzone, 
                gang = dbTerritory[location].gang, 
                label = territory.label,
                itemstake = dbTerritory[location].itemstake,
                washtake = dbTerritory[location].washtake,
                capture = territory.capture
            }
            cb(result)
        end
    else
        cb(false)
    end
end)

RegisterServerEvent('bixbi_territories:UpdateGang')
AddEventHandler('bixbi_territories:UpdateGang', function(name)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (territoryCount[dbTerritory[name].gang] ~= nil and dbTerritory[name] ~= nil) then
        territoryCount[dbTerritory[name].gang].count = territoryCount[dbTerritory[name].gang].count - 1
        dbTerritory[name].gang = xPlayer.job.name

        if (territoryCount[xPlayer.job.name] ~= nil) then
            territoryCount[xPlayer.job.name] = territoryCount[xPlayer.job.name].count + 1
        else
            territoryCount[xPlayer.job.name] = {}
            territoryCount[xPlayer.job.name].count = 1
        end

        TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {"[TERRITORY] ", xPlayer.job.label .. ' has captured ' .. Config.Territories[name].label}})
        exports.oxmysql:execute('UPDATE bixbi_territories SET gang = @gang WHERE name = @name', {		
            ['@name'] = name,
            ['@gang'] = xPlayer.job.name
        }) 
    end
end)

RegisterServerEvent('bixbi_territories:CaptureStart')
AddEventHandler('bixbi_territories:CaptureStart', function(name)
    if (not Config.CaptureEnabled or not Config.Territories[name].capture.enabled or dbTerritory[name] == nil) then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    if (Config.BlacklistedJobs[xPlayer.job.name] ~= nil) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You cannot capture a territory as this job.')
        return
    elseif (dbTerritory[name].gang == xPlayer.job.name) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You already own this territory')
        return
    elseif (territoryCount[xPlayer.job.name] ~= nil and territoryCount[xPlayer.job.name].count >= Config.MaxTerritories) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'Your gang holds the max amount of territories allowed.')
        return
    elseif (dbTerritory[name].capturing) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'This area is already under an attempted claim.')
        return
    end

    dbTerritory[name].capturing = true
    playerInfo[source] = name
    TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {"[TERRITORY] ", xPlayer.job.label .. ' has begun the capture of ' .. Config.Territories[name].label}})
    TriggerClientEvent('bixbi_territories:Capture', source)
    TriggerEvent('bixbi_dispatch:Add', source, 'police', '', 'There\'s a gang trying to claim a territory.', Config.Territories[name].captureBlip)

    -- for k, v in pairs(ESX.GetExtendedPlayers('job', dbTerritory[name].gang)) do
    --     TriggerClientEvent('bixbi_territories:NotifyCaptureAttempt', k, false, mugshot, mugshotStr)
    -- end
end)

RegisterServerEvent('bixbi_territories:CaptureFailed')
AddEventHandler('bixbi_territories:CaptureFailed', function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local label = Config.Territories[name].label
    dbTerritory[name].capturing = false

    if (xPlayer == nil) then
        TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {"[TERRITORY] ", 'The capture of ' .. label .. ' has failed'}})
    else
        TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {"[TERRITORY] ", xPlayer.job.label .. ' failed the capture of ' .. label}})
    end
    
end)

RegisterServerEvent('bixbi_territories:CaptureHalfWay')
AddEventHandler('bixbi_territories:CaptureHalfWay', function(label)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {"[TERRITORY] ", xPlayer.job.label .. ' is half way until the capture of ' .. label}})
end)

RegisterServerEvent('bixbi_territories:sv_UpdateTake')
AddEventHandler('bixbi_territories:sv_UpdateTake', function(name, percentage, type)
    if (percentage > Config.MaxPercentage) then percentage = Config.MaxPercentage end
    if (type == 'itemstake') then
        exports.oxmysql:execute('UPDATE bixbi_territories SET itemstake = @itemstake WHERE name = @name', {		
            ['@name'] = name,
            ['@itemstake'] = percentage
        })
        dbTerritory[name].itemstake = percentage
    elseif (type == 'washtake') then
        exports.oxmysql:execute('UPDATE bixbi_territories SET washtake = @washtake WHERE name = @name', {		
            ['@name'] = name,
            ['@washtake'] = percentage
        })
        dbTerritory[name].washtake = percentage
    end
    
    TriggerClientEvent('bixbi_core:Notify', source, '', 'You have updated the percentage.')
end)

RegisterServerEvent('bixbi_territories:OpenStash')
AddEventHandler('bixbi_territories:OpenStash', function(name)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (dbTerritory[name].gang == xPlayer.job.name) then
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', string.lower(name) .. '-territory')
        return
    end
    TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You don\'t have access to this stash.')
end)

RegisterServerEvent('bixbi_territories:OpenStashForce')
AddEventHandler('bixbi_territories:OpenStashForce', function(name)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer.getInventoryItem(Config.HackItem).count > 0) then
        xPlayer.removeInventoryItem(Config.HackItem, 1)
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', string.lower(name) .. '-territory')
        
        for k, v in pairs(ESX.GetExtendedPlayers('job', dbTerritory[name].gang)) do
            TriggerClientEvent('bixbi_core:Notify', k, 'error', 'Someone has broken into the ' .. string.upper(name) .. ' stash!', 8000)
        end
        return
    end
    TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You don\'t have the required item.')
end)

-- RegisterServerEvent('bixbi_territories:StashDeposit')
AddEventHandler('bixbi_territories:StashDeposit', function(name, item, count)
    local Inventory = exports.ox_inventory:Inventory()
    Inventory.AddItem(string.lower(name) .. '-territory', item, math.floor(count))
end)

--[[--------------------------------------------------
Setup
--]]--------------------------------------------------
AddEventHandler("playerDropped", function()
    if (playerInfo[source] ~= nil) then
	    TriggerEvent('bixbi_territories:CaptureFailed', playerInfo[source])
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetResourceState('bixbi_core') ~= 'started' ) then
        print('Bixbi_Territories - ERROR: Bixbi_Core hasn\'t been found! This could cause errors!')
    end

    if (GetCurrentResourceName() == resourceName) then 
        Citizen.Wait(2000)
        exports.oxmysql:query('SELECT * FROM bixbi_territories', {}, function(result)
            for k,v in pairs(result) do
                if (v.itemstake > Config.MaxPercentage) then v.itemstake = Config.MaxPercentage end
                dbTerritory[v.name] = {
                    gang = v.gang,
                    itemstake = v.itemstake,
                    washtake = v.washtake,
                    capturing = false
                }
                
                if (territoryCount[v.gang] ~= nil) then
                    territoryCount[v.gang].count = territoryCount[v.gang].count + 1
                else
                    territoryCount[v.gang] = {}
                    territoryCount[v.gang].count = 1
                end
            end
        end)

        for k, v in pairs(Config.Territories) do
            if (v.capture ~= nil) then
                exports.ox_inventory:RegisterStash(string.lower(k) .. '-territory', 'Territory Stash', 20, 99999)
            end
        end
    end
end)