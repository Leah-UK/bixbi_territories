if (Config.MenuKeybind ~= nil) then RegisterKeyMapping(Config.MenuCommand, 'Territory Menu', 'keyboard', Config.MenuKeybind) end
RegisterCommand(Config.MenuCommand, function()
    TerritoryInfoMenu()
end, false)

AddEventHandler('bixbi_territories:TerritoryInfoMenu', function(data)
    TerritoryInfoMenu()
end)
function TerritoryInfoMenu()
    ESX.TriggerServerCallback('bixbi_territories:locationCheck', function(locationInfo)
        while (locationInfo == nil) do Citizen.Wait(100) end
        if (not locationInfo) then
            exports['bixbi_core']:Notify('error', 'Territory information not found.')
            return
        end

        if (string.lower(Config.MenuType) == 'zf') then
            ZFMenu(locationInfo)
        else
            ESXMenu(locationInfo)
        end
        
    end, GetNameOfZone(GetEntityCoords(PlayerPedId())))
end

function ZFMenu(locationInfo)
    local elements = {
        {
            id = 1,
            header = 'Territory - ' .. locationInfo.label,
            txt = ' '
        },
        {
            id = 2,
            header = ' ',
            txt = 'Controlling Gang: ' .. locationInfo.gang
        }
    }

    local idCount = 3
    if (locationInfo.illegalitems ~= nil) then
        if (string.lower(locationInfo.gang) == string.lower(ESX.PlayerData.job.name)) then
            table.insert(elements, { id = idCount, header = ' ', txt = '> Illegal Items Cut: ' .. locationInfo.itemstake .. '%', params = { event = 'bixbi_territories:ZFAction', args = { type = 'itemstake', locationInfo = locationInfo }}})
        else
            table.insert(elements, { id = idCount, header = ' ', txt = 'Illegal Items Cut: ' .. locationInfo.itemstake .. '%'})
        end

        idCount = idCount + 1
        table.insert(elements, { id = idCount, header = 'Sellable Items', txt = ' '})
        for k, v in pairs(locationInfo.illegalitems) do
            idCount = idCount + 1
            table.insert(elements, { id = idCount, header = ' ', txt = '- ' .. string.upper(v)})
        end
    end

    if (locationInfo.washzone ~= nil and locationInfo.washzone) then
        --ESX.PlayerData.job.grade == 4 and 
        if (string.lower(locationInfo.gang) == string.lower(ESX.PlayerData.job.name)) then
            table.insert(elements, { id = idCount, header = ' ', txt = '> Wash Cut: ' .. locationInfo.washtake .. '%', params = { event = 'bixbi_territories:ZFAction', args = { type = 'washtake', locationInfo = locationInfo }}})
        else
            table.insert(elements, { id = idCount, header = ' ', txt = 'Wash Cut: ' .. locationInfo.washtake .. '%'})
        end
    end

    if (locationInfo.parent ~= nil) then
        table.insert(elements, { id = idCount, header = ' ', txt = 'Parent Territory: ' .. locationInfo.parent})
    end

    exports['zf_context']:openMenu(elements)
end

AddEventHandler('bixbi_territories:ZFAction', function(data)
    UpdateTakePercent(data.type, data.locationInfo)
end)

function ESXMenu(locationInfo)
    local elements = {}
    table.insert(elements, { label = 'Territory Name: ' .. locationInfo.label, value = '' })
    table.insert(elements, { label = 'Controlling Gang: ' .. locationInfo.gang, value = '' })

    if (locationInfo.illegalitems ~= nil) then
        if (ESX.PlayerData.job.grade == 4 and string.lower(locationInfo.gang) == string.lower(ESX.PlayerData.job.name)) then
            table.insert(elements, { label = '> Drug Cut: ' .. locationInfo.itemstake .. '%', value = 'itemstake' })
        else
            table.insert(elements, { label = 'Drug Cut: ' .. locationInfo.itemstake .. '%', value = '' })
        end

        table.insert(elements, { label = '', value = '' })
        table.insert(elements, { label = 'Sellable Drugs: ', value = '' })
        for k, v in pairs(locationInfo.illegalitems) do
            table.insert(elements, { label = '- ' .. string.upper(v), value = '' })
        end
    end

    if (locationInfo.washzone ~= nil and locationInfo.washzone) then
        if (ESX.PlayerData.job.grade == 4 and string.lower(locationInfo.gang) == string.lower(ESX.PlayerData.job.name)) then
            table.insert(elements, { label = '> Wash Cut: ' .. locationInfo.washtake .. '%', value = 'washtake' })
        else
            table.insert(elements, { label = 'Wash Cut: ' .. locationInfo.washtake .. '%', value = '' })
        end
    end

    if (locationInfo.parent ~= nil) then
        table.insert(elements, { label = '', value = '' })
        table.insert(elements, { label = 'Parent Territory: ' .. locationInfo.parent, value = '' })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'territoryinfo', {
        title = 'Territory Information',
        align = 'right',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'itemstake' or data.current.value == 'washtake' then
            UpdateTakePercent(data.current.value, locationInfo)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function UpdateTakePercent(type, locationInfo)
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Change Percentage",
        rows = {{
            id = 0,
            txt = "Percentage: 15 = 15%"
        }}
    })
    if dialog ~= nil then
        if dialog[1].input == nil then return end
        local percentage = tonumber(dialog[1].input) or 5
        TriggerServerEvent('bixbi_territories:sv_UpdateTake', locationInfo.location, ESX.Math.Round(percentage, 2), type)
    end
end