
local globalData

function Callback.OnSetup()
  globalData = Shared(Global)
  
  -- PaxOfficial sets the market as non-interactable. override that so right click works
  owner.interactable = true
  
  owner.clearContextMenu()
  owner.addContextMenuItem('Fill Market', OnFillMarket)
end

function OnFillMarket()

  ---@type tts__ScriptingTrigger[]
  local TopZones = {}
  ---@type tts__ScriptingTrigger[]
  local BottomZones = {}
  
  for i, marketZone in ipairs(globalData.marketZones) do
    if i <= 6 then
      table.insert(TopZones, marketZone)
    else
      table.insert(BottomZones, marketZone)
    end
  end

  FillMarketRow(TopZones)
  FillMarketRow(BottomZones)
end

function FillMarketRow(RowZones)
  _RowZones = RowZones
  startLuaCoroutine(self, 'FillMarketRowCoroutine')
  
end

function FillMarketRowCoroutine()
  ---@type tts__ScriptingTrigger[]
  local RowZones = _RowZones
  while (true) do
    ---@type tts__Object[]
    local objectsToShift = {}
    local foundEmptySlot = false
    for i = #RowZones, 1, -1 do

      -- break out early if this zone doesn't have a card
      local foundCard = false
      for _, object in ipairs(RowZones[i].getObjects(true)) do
        if object.type == 'Card' then
          foundCard = true
          break
        end
      end
      if not foundCard then
        foundEmptySlot = true
        break
      end

      -- mark all the objects in this zone to get shifted to the left
      for _, object in ipairs(RowZones[i].getObjects(true)) do
        if object.guid ~= owner.guid then
          table.insert(objectsToShift, object)
        end
      end
    end

    local shiftVector = globalData.marketZones[1].getPosition() - globalData.marketZones[2].getPosition()
    if foundEmptySlot then
      for _, object in ipairs(objectsToShift) do
        object.setPositionSmooth(object.getPosition() + shiftVector, false, false)
      end

      -- wait until every object has finished moving to it's destination
      local finishedMoving = false
      while not finishedMoving do
        finishedMoving = true
        for _, object in ipairs(objectsToShift) do
          if object.getPositionSmooth() ~= nil then
            finishedMoving = false
            break
          end
        end
        if not finishedMoving then
          coroutine.yield(0)
        end
      end

      local deck = GetDeck()
      if deck and deck.type == 'Deck' then
        local finishedDrawingCard = false
        deck.takeObject({
          top = true,
          flip = true,
          position = RowZones[6].getPosition(),
          callback_function = function(object)
            finishedDrawingCard = true
          end
        })
        while not finishedDrawingCard do
          coroutine.yield(0)
        end
      elseif deck and deck.type == 'Card' then
        deck.setPositionSmooth(RowZones[6].getPosition(), false, false)
        local rotation = deck.getRotation()
        rotation.z = 0
        deck.setRotationSmooth(rotation, false, false)
        while deck.getPositionSmooth() or deck.getRotationSmooth() do
          coroutine.yield(0)
        end
      else
        -- TODO handle deck running out by spawning a placeholder card that's locked and invisible
        return 1
      end
      
    else
      return 1
    end
  end
end

---@return tts__Deck | tts__Card
function GetDeck()
  local foundCard = nil
  for _, object in ipairs(globalData.deckZone.getObjects(true)) do
    if object.type == 'Deck' then
      return object
    end
    if object.type == 'Card' then
      foundCard = object
    end
  end
  return foundCard
end
