ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
  TriggerEvent('esx_service:activateService', 'driving', Config.MaxInService)
end

-- TriggerEvent('esx_phone:registerNumber', 'driving', _U('alert_driving'), true, true)
TriggerEvent('esx_society:registerSociety', 'driving', 'Driving', 'society_driving', 'society_driving', 'society_driving', {type = 'public'})



RegisterServerEvent('nwtv_autoecolejob:getStockItem')
AddEventHandler('nwtv_autoecolejob:getStockItem', function(itemName, count)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_driving', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('nwtv_autoecolejob:getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_driving', function(inventory)
    cb(inventory.items)
  end)

end)

RegisterServerEvent('nwtv_autoecolejob:putStockItems')
AddEventHandler('nwtv_autoecolejob:putStockItems', function(itemName, count)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_driving', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= 0 then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)

  end)

end)


ESX.RegisterServerCallback('nwtv_autoecolejob:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)

RegisterServerEvent('nwtv_autoecolejob:dutyoff')
AddEventHandler('nwtv_autoecolejob:dutyoff', function(job)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    
    if job == 'driving' then
        xPlayer.setJob('offdriving', grade)
    end

end)

RegisterServerEvent('nwtv_autoecolejob:dutyon')
AddEventHandler('nwtv_autoecolejob:dutyon', function(job)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    
    if job == 'offdriving' then
        xPlayer.setJob('driving', grade)
    end

end)
