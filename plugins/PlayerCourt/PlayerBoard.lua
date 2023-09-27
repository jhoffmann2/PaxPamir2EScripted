local RelativePosition = Vector(-0.31, 2.00, -15.24) - Vector(-0.31, 0.96, -19.79)
local Scale = Vector(29.63, 2.20, 5.0)
local globalData

function Callback.OnSetup()
  globalData = Shared(Global)
  SetPlayerColor()
  SetIsPlayingGame()
  
  if shared.isPlayingGame then
    SpawnCourtZone()
  end
end

function SetPlayerColor()
  for _, color in ipairs(Player.getColors()) do
    if owner.hasTag(color) then
      shared.playerColor = color
    end
  end
end

function SetIsPlayingGame()
  shared.isPlayingGame = false
  local seatedColors = {}
  local seatedPlayerCount = 0
  for _, player in ipairs(Player.getPlayers()) do
    if player.seated then
      seatedColors[player.color] = true
      seatedPlayerCount = seatedPlayerCount + 1
    end
  end
  
  local colorPriority = {'Blue', 'White', 'Green', 'Red', 'Orange'}
  if (seatedPlayerCount > globalData.gamePlayerCount) then
    local IncludedCount = 0
    for _, color in ipairs(colorPriority) do
      if (IncludedCount == globalData.gamePlayerCount) then
        break
      end

      if seatedColors[color] then
        IncludedCount = IncludedCount + 1
        if (color == shared.playerColor) then
          shared.isPlayingGame = true
          break
        end
      end
    end
  elseif (seatedPlayerCount < globalData.gamePlayerCount) then
    if seatedColors[shared.playerColor] then
      shared.isPlayingGame = true
    else
      -- not enough players seated. assign more seats.
      local IncludedCount = seatedPlayerCount
      for _, color in ipairs(colorPriority) do
        if (IncludedCount == globalData.gamePlayerCount) then
          break
        end

        if not seatedColors[color] then
          IncludedCount = IncludedCount + 1
          if (color == shared.playerColor) then
            shared.isPlayingGame = true
            break
          end
        end
      end
    end
    
  else
    shared.isPlayingGame = seatedColors[shared.playerColor]
  end
  
  
end

function SpawnCourtZone()
  local rotation = owner.getRotation()
  rotation.y = rotation.y - 180
  local TranslationVector = RelativePosition
  TranslationVector:rotateOver('y', rotation.y)
  local position = owner.getPosition() + TranslationVector
  
  -- slightly nudge red and orange zones so they fit
  if shared.playerColor == 'Red' or shared.playerColor == 'Orange' then
    position.z = position.z + 2.6
  end

  local ObjectParameters = {
    position = position,
    rotation = rotation,
    scale = Scale,
    json = [[{
      "Name": "LayoutZone",
      "Transform": {"posX": 0.0, "posY": 0.0, "posZ": 0.0, "rotX": 0.0, "rotY": 0.0, "rotZ": 0.0, "scaleX": 1.0, "scaleY": 1.0, "scaleZ": 1.0},
      "Locked": true,
      "LayoutZone": {
        "Options": {
          "Direction": 0,
          "MeldDirection": 0,
          "NewObjectFacing": 1,
          "TriggerForFaceUp": true,
          "TriggerForFaceDown": true,
          "TriggerForNonCards": false,
          "AllowSwapping": true,
          "MaxObjectsPerNewGroup": 1,
          "MaxObjectsPerGroup": 1,
          "MeldSort": 1,
          "MeldReverseSort": false,
          "MeldSortExisting": false,
          "StickyCards": false,
          "HorizontalSpread": 0.6,
          "VerticalSpread": 0.0,
          "HorizontalGroupPadding": 0.0,
          "VerticalGroupPadding": 0.0,
          "SplitAddedDecks": true,
          "CombineIntoDecks": false,
          "CardsPerDeck": 0,
          "AlternateDirection": false,
          "Randomize": false,
          "InstantRefill": false,
          "ManualOnly": false
        },
        "GroupsInZone": [
          []
        ]
      }
    }]]
  }
  shared.courtZone = spawnObjectJSON(ObjectParameters)
end
