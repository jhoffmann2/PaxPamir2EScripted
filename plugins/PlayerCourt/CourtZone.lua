
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
  
  if dropped_object.type ~= 'Card' then
    return
  end

  -- wait for card to be set down
  Wait.time(
    function()
      -- make sure the card didn't snap to outside the zone
      for _, object in ipairs(owner.getObjects(true)) do
        if object == dropped_object then
          board = getObjectsWithAllTags({ 'PlayerBoard', shared.playerColor })[1]
          InvokeMethod('ExpandCourtZones', board)
        end
      end
    end,
    1
  )
end
