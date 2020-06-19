local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData              = {}
local GUI                     = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local TargetCoords            = nil
local Blips                   = {}

ESX                           = nil
GUI.Time                      = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function SetVehicleMaxMods(vehicle)
  local props = {
    modEngine = 0,
    modBrakes = 0,
    modTransmission = 0,
    modSuspension = 0,
    modTurbo = false,
  }
     ESX.Game.SetVehicleProperties(vehicle, props)
end


function OpenDrivingSchoolMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drivingschool', {
		title    = _U('driving_menu'),
		align    = 'top-left',
		elements = {
			{label = _U('give'), value = 'give'},
			{label = _U('retrieve'), value = 'remove'},
			{label = _U('billing'), value = 'bil'}
}}, function(data, menu)

if data.current.value == 'give' then
			local elements = {
                                  --{label = _U('traffic_give'), value = 'trg'}
				--{label = ('motor'), value = 'motg'},
				--{label = ('car'), value = 'carg'},
                                --{label = ('truck'), value = 'truckg'}
}
           if ESX.PlayerData.job.grade_name == 'examiner' then
				table.insert(elements, {label = _U('car_give'), value = 'carg'})
			end
			
			if ESX.PlayerData.job.grade_name == 'examiner' then
				table.insert(elements, {label = _U('motor_give'), value = 'motg'})
			end
			
			if ESX.PlayerData.job.grade_name == 'examiner' then
				table.insert(elements, {label = _U('truck_give'), value = 'truckg'})
			end

ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'give', {
				title    = _U('give'),
				align    = 'top-left',
				elements = elements
			}, function(data2, menu2)
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					local action = data2.current.value

		   if action == 'trg' then
                           TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'dmv')
                    elseif action == 'carg' then
			   TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'drive')
		   elseif action == 'motg' then
			   TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'drive_bike')
                    elseif action == 'truckg' then
                           TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'drive_truck')
                         end
                     else
                         ESX.ShowNotification(_U('no_players_nearby'))
                         end
                     end, function(data2, menu2)
				menu2.close()
	             end)
elseif data.current.value == 'remove' then
local elements = {
                                --{label = _U('traffic_remove'), value = 'trr'}
				--{label = _U('motor_remove'), value = 'motr'},
				--{label = _U('car_remove'), value = 'carr'},
                                --{label = _U('truck_remove'), value = 'truckr'}
}

            if ESX.PlayerData.job.grade_name == 'carinstr' or ESX.PlayerData.job.grade_name == 'examiner' then
				table.insert(elements, {label = _U('car_remove'), value = 'carr'})
			end
			
			if ESX.PlayerData.job.grade_name == 'motorinstr' or ESX.PlayerData.job.grade_name == 'examiner' then
				table.insert(elements, {label = _U('motor_remove'), value = 'motr'})
			end
			
			if ESX.PlayerData.job.grade_name == 'truckinstr' or ESX.PlayerData.job.grade_name == 'examiner' then
				table.insert(elements, {label = _U('truck_remove'), value = 'truckrr'})
			end

ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove', {
				title    = _U('retrieve'),
				align    = 'top-left',
				elements = elements
			}, function(data2, menu2)
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					local action = data2.current.value

					if action == 'trr' then
						TriggerServerEvent('esx_license:removeLicense',GetPlayerServerId(closestPlayer), 'dmv')
					elseif action == 'carr' then
						TriggerServerEvent('esx_license:removeLicense',GetPlayerServerId(closestPlayer),'drive')
					elseif action == 'motr' then
						TriggerServerEvent('esx_license:removeLicense',GetPlayerServerId(closestPlayer), 'drive_bike')
                    elseif action == 'truckr' then
                        TriggerServerEvent('esx_license:removeLicense',GetPlayerServerId(closestplayer), 'drive_truck')
                                end
                         else
                            ESX.ShowNotification(_U('no_players_nearby'))
                         end
                     end, function(data2, menu2)
				menu2.close()
	             end)
elseif data.current.value == 'bil' then
            OpenBillingMenu()
end
end, function(data, menu)
  menu.close()
end)
end


function OpenBillingMenu()
  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bil', {
      title = 'billing_amount'
    }, function(data, menu)
    
      local amount = tonumber(data.value)
      local player, distance = ESX.Game.GetClosestPlayer()

      if player ~= -1 and distance <= 3.0 then
        menu.close()

        if amount == nil then
            ESX.ShowNotification(_U('amount_invalid'))
        else
            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_driving', _U('billing'), amount)
        end
      else
        ESX.ShowNotification(_U('no_players_nearby'))
      end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenDrivingActionsMenu()

  local elements = {
    {label = _U('vehicle_list'), value = 'vehicle_list'},
    {label = _U('deposit_stock'), value = 'put_stock'},
    {label = _U('withdraw_stock'), value = 'get_stock'},
    {label = _U('cloakroom'), value = 'cloakroom'},
    {label = _U('cloakroom2'), value = 'cloakroom2'}
  }
  if Config.EnablePlayerManagement and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
    table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
  end

  ESX.UI.Menu.CloseAll()
  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'driving_actions',
    {
      title    = _U('vehicle_list'),
      elements = elements
    },
    function(data, menu)
      if data.current.value == 'vehicle_list' then

        if Config.EnableSocietyOwnedVehicles then

            local elements = {}

            ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)

              for i=1, #vehicles, 1 do
                table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']', value = vehicles[i]})
              end

              ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'vehicle_spawner',
                {
                  title    = _U('service_vehicle'),
                  align    = 'top-left',
                  elements = elements,
                },
                function(data, menu)

                  menu.close()

                  local vehicleProps = data.current.value

                  ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)
                    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
                    local playerPed = GetPlayerPed(-1)
                    TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
                  end)

                  TriggerServerEvent('esx_society:removeVehicleFromGarage', 'driving', vehicleProps)

                end,
                function(data, menu)
                  menu.close()
                end
              )

            end, 'driving')

          else

            local elements = {
			  --{label = 'Car', value = 'blista'},
              --{label = 'Motor', value = 'sanchez'},
              --{label = 'Truck', value = 'kart20'}
            }
			
			if ESX.PlayerData.job.grade_name == 'carinstr' then
				table.insert(elements, {label = _U('car'), value = 'issi2'})
			end
			
			if ESX.PlayerData.job.grade_name == 'motorinstr' then
				table.insert(elements, {label = _U('motor'), value = 'esskey'})
			end
			
			if ESX.PlayerData.job.grade_name == 'truckinstr' then
				table.insert(elements, {label = _U('truck'), value = 'packer'})
			end

            ESX.UI.Menu.CloseAll()

            ESX.UI.Menu.Open(
              'default', GetCurrentResourceName(), 'spawn_vehicle',
              {
                title    = _U('service_vehicle'),
                elements = elements
              },
              function(data, menu)
                for i=1, #elements, 1 do
                  if Config.MaxInService == -1 then
                    ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
                      local playerPed = GetPlayerPed(-1)
                      TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                    end)
                    break
                  else
                    ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
                      if canTakeService then
                        ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
                          local playerPed = GetPlayerPed(-1)
                          TaskWarpPedIntoVehicle(playerPed,  vehicle, -1)
                        end)
                      else
                        ESX.ShowNotification(_U('service_full') .. inServiceCount .. '/' .. maxInService)
                      end
                    end, 'driving')
                    break
                  end
                end
                menu.close()
              end,
              function(data, menu)
                menu.close()
                OpenDrivingActionsMenu()
              end
            )

          end
      end

		if data.current.value == 'cloakroom2' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerServerEvent('nwtv_autoecolejob:dutyoff')
				TriggerEvent("pNotify:SendNotification", {
					text = "Fin de service",
					type = "info",
					timeout = 10000,
					layout = "centerRight"
	})
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'cloakroom' then
			TriggerServerEvent('nwtv_autoecolejob:dutyon')
				TriggerEvent("pNotify:SendNotification", {
					text = "Prise de service",
					type = "info",
					timeout = 10000,
					layout = "centerRight"
	})
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end
			end)
		end

      if data.current.value == 'put_stock' then
        OpenPutStocksMenu()
      end

      if data.current.value == 'get_stock' then
        OpenGetStocksMenu()
      end

      if data.current.value == 'boss_actions' then
        TriggerEvent('esx_society:openBossMenu', 'driving', function(data, menu)
          menu.close()
        end)
      end

    end,
    function(data, menu)
      menu.close()
      CurrentAction     = 'driving_actions_menu'
      CurrentActionMsg  = _U('open_actions')
      CurrentActionData = {}
    end
  )
end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('nwtv_autoecolejob:getStockItems', function(items)

    print(json.encode(items))

    local elements = {}

    for i=1, #items, 1 do

      local item = items[i]

      if item.count > 0 then
        table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('stock'),
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('invalid_quantity'))
            else
              menu2.close()
              menu.close()
              OpenGetStocksMenu()

              TriggerServerEvent('nwtv_autoecolejob:getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutStocksMenu()

ESX.TriggerServerCallback('nwtv_autoecolejob:getPlayerInventory', function(inventory)

    local elements = {}

    for i=1, #inventory.items, 1 do

      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('inventory'),
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('invalid_quantity'))
            else
              menu2.close()
              menu.close()
              OpenPutStocksMenu()

              TriggerServerEvent('nwtv_autoecolejob:putStockItems', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

AddEventHandler('nwtv_autoecolejob:hasEnteredMarker', function(zone)

  if zone == 'DrivingActions' and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'driving' or ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'offdriving' then
    CurrentAction     = 'driving_actions_menu'
    CurrentActionMsg  = _U('open_actions')
    CurrentActionData = {}
  end

  if zone == 'VehicleDeleter' and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'driving' then

    local playerPed = GetPlayerPed(-1)

    if IsPedInAnyVehicle(playerPed,  false) then

      local vehicle = GetVehiclePedIsIn(playerPed,  false)

      CurrentAction     = 'delete_vehicle'
      CurrentActionMsg  = _U('veh_stored')
      CurrentActionData = {vehicle = vehicle}
    end
  end

end)

AddEventHandler('nwtv_autoecolejob:hasExitedMarker', function(zone)
  CurrentAction = nil
  ESX.UI.Menu.CloseAll()
end)

--Blip
Citizen.CreateThread(function()

  for k,v in pairs(Config.Blip) do

    local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

    SetBlipSprite (blip, v.Sprite)
    SetBlipDisplay(blip, v.Display)
    SetBlipScale  (blip, v.Scale)
    SetBlipColour (blip, v.Colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('map_blip'))
    EndTextCommandSetBlipName(blip)

  end

end)

-- -- Enter / Exit marker events / Display markers

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'driving' then
			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker, currentZone = false

			for k,v in pairs(Config.Zones) do
				local distance = GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true)

				if v.Type ~= -1 and distance < Config.DrawDistance then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, v.Rotate, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone = true, k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker, LastZone = true, currentZone
				TriggerEvent('nwtv_autoecolejob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('nwtv_autoecolejob:hasExitedMarker', LastZone)
			end
    elseif ESX.PlayerData.job and ESX.PlayerData.job.name == 'offdriving' then
			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker, currentZone = false

			for k,v in pairs(Config.Zones) do
				local distance = GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true)

				if v.Duty == 1 and v.Type ~= -1 and distance < Config.DrawDistance then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, v.Rotate, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone = true, k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker, LastZone = true, currentZone
				TriggerEvent('nwtv_autoecolejob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('nwtv_autoecolejob:hasExitedMarker', LastZone)
			end
		else
			Citizen.Wait(1000)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if CurrentAction ~= nil then

          SetTextComponentFormat('STRING')
          AddTextComponentString(CurrentActionMsg)
          DisplayHelpTextFromStringLabel(0, 0, 1, -1)

          if IsControlJustReleased(0, 38) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'offdriving' then

            if CurrentAction == 'driving_actions_menu' then
                OpenDrivingActionsMenu()
            end
			
			elseif IsControlJustReleased(0, 38) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'driving' then
			
            if CurrentAction == 'driving_actions_menu' then
                OpenDrivingActionsMenu()
            end

            if CurrentAction == 'delete_vehicle' then

              if Config.EnableSocietyOwnedVehicles then

                local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
                TriggerServerEvent('esx_society:putVehicleInGarage', 'driving', vehicleProps)

              else

                if
                  GetEntityModel(vehicle) == GetHashKey('blista') or
                  GetEntityModel(vehicle) == GetHashKey('sanchez')
                then
                  TriggerServerEvent('esx_service:disableService', 'driving')
                end

              end

              ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
            end

            CurrentAction = nil
          end
        end

        if IsControlJustReleased(0, Keys['F6']) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'driving' then
            OpenDrivingSchoolMenu()
        end        
    end
end)




			









