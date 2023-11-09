
function onLoad()
  SetPlayerColor()
end

function SetPlayerColor()
  for _, color in ipairs(Player.getColors()) do
    if owner.hasTag(color) then
      shared.playerColor = color
    end
  end
end

function Method.OnDrop_Zone(dropped_object, player_color)
  
  if not dropped_object.hasTag('CourtCard') then
    return
  end

  -- wait for card to be set down
  Wait.time(
    function()
      -- make sure the card didn't snap to outside the zone
      for _, object in ipairs(owner.getObjects(true)) do
        if object == dropped_object then
          OnCourtCardPlaced(object)
        end
      end
    end,
    0.3
  )
end

local discardPosition = {10.75, 2.0, 22.39}
local discardRotation = {0.00, 180.00, 0.00}

---@param card tts__Card
function OnCourtCardPlaced(card)
  
  local board = getObjectsWithAllTags({ 'PlayerBoard', shared.playerColor })[1]
  InvokeMethod('ExpandCourtZones', board)

  Wait.time(
    function()
      local rotation = card.getRotation()
      rotation.z = 0.0 -- make card face up
      card.setRotation(rotation)
      card.locked = true
      card.clearContextMenu()
      card.addContextMenuItem('Discard', OnDiscardCard)
    end,
    0.3
  )
end

---@param card tts__Card
function OnDiscardCard(player_color, position, card)
  card.setPositionSmooth(discardPosition, false, true);
  card.setRotationSmooth(discardRotation, false, true);
  Wait.time(
    function()
      card.locked = false
      card.clearContextMenu()
      local board = getObjectsWithAllTags({ 'PlayerBoard', shared.playerColor })[1]
      InvokeMethod('ShrinkCourtZones', board)
    end,
    0.3
  )
end