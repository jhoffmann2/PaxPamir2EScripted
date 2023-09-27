
local globalData

function onload()
  globalData = Shared(Global)
end

function Method.OnNumberTyped_Zone(_, player_color, number)
  local playerBoardData = Shared(getObjectsWithAllTags({"PlayerBoard", player_color})[1])
  local playerCoinZone = playerBoardData.coinZone

  if not PayForCard(playerCoinZone) then
    printToColor("You cannot afford this card!", player_color)
    return true
  end
  
  local objects = owner.getObjects(true)
  for _, object in ipairs(objects) do
    if object.type == 'Card' then
      object.deal(1, player_color)
    elseif not object.locked then
      --object.deal(1, player_color)
      object.setPositionSmooth(playerCoinZone.getPosition())
    end
  end
  
  Wait.condition(
    function()
      playerCoinZone.layoutZone.layout()
    end,
    function()
      for _, object in ipairs(objects) do
        if object.getPositionSmooth() ~= nil then
          return false
        end
      end
      return true
    end
  )
  
  return true
end

function GetMarketZone(row, column)
  local index = (6 * row) + column + 1
  return globalData.marketZones[index]
end

function ZoneHasCard(zone)
  for _, object in ipairs(zone.getObjects(true)) do
    if object.type == 'Card' then
      return true
    end
  end
end

function PayForCard(playerCoinZone)
  local Price = GetPrice()
  local playerCoins = playerCoinZone.getObjects()
  if Price > #playerCoins then
    return false
  end

  for column = 0, shared.marketColumn - 1 do
    local zoneToPay = GetMarketZone(shared.marketRow, column)
    if not ZoneHasCard(zoneToPay) then
      -- swap row for this payment
      zoneToPay = GetMarketZone((shared.marketRow + 1) % 2, column)
    end
    
    local payCount = 1
    if IsMilitaryFavored() then
      payCount = 2
    end
    for i = 0, payCount-1 do
      local position = zoneToPay.getPosition()
      position.x = position.x + (math.random() - 0.5) * 1.5
      position.z = position.z + (math.random() - 0.5) * 1.8
      playerCoins[(column + 1) + (shared.marketColumn * i)].setPositionSmooth(position)
    end
    
  end
  
  return true
end

function IsMilitaryFavored()
  for _, found in ipairs(globalData.favoredSuitZones[suitIds.Military].getObjects(true)) do
    if (found.getName() == 'Favored Suit Marker') then
      return true
    end
  end
  return false
end

function GetPrice()
  if (IsMilitaryFavored()) then
    return shared.marketColumn * 2
  end
  return shared.marketColumn
end


