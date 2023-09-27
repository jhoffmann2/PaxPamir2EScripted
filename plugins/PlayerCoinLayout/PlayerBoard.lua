local RelativePosition = Vector(-0.31, 2.00, -22.70) - Vector(-0.31, 0.96, -19.79)
local Scale = Vector(11.67, 2.20, 3.08)
local coinBankGUID = '012e1e'
local globalData

function Callback.OnSetup()
  globalData = Shared(Global)
  SetPlayerColor()
  SetIsPlayingGame()
  
  if shared.isPlayingGame then
    SpawnCoinZone()
    GiveStartingCoins()
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

function SpawnCoinZone()
  local rotation = owner.getRotation()
  rotation.y = rotation.y - 180
  local TranslationVector = RelativePosition
  TranslationVector:rotateOver('y', rotation.y)

  local ObjectParameters = {
    position = owner.getPosition() + TranslationVector,
    rotation = rotation,
    scale = Scale,
    json = [[{
      "Name": "LayoutZone",
      "Transform": {"posX": 0.0, "posY": 0.0, "posZ": 0.0, "rotX": 0.0, "rotY": 0.0, "rotZ": 0.0, "scaleX": 1.0, "scaleY": 1.0, "scaleZ": 1.0},
      "Locked": true,
      "Tags": ["UseCoinLayoutZone"],
      "LayoutZone": {
        "Options": {
          "Direction": 0,
          "MeldDirection": 0,
          "NewObjectFacing": 1,
          "TriggerForFaceUp": true,
          "TriggerForFaceDown": true,
          "TriggerForNonCards": true,
          "AllowSwapping": true,
          "MaxObjectsPerNewGroup": 18,
          "MaxObjectsPerGroup": 18,
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
  shared.coinZone = spawnObjectJSON(ObjectParameters)
end

function GiveStartingCoins()
  ---@type tts__Bag
  local coinBank = getObjectFromGUID(coinBankGUID)
  for i = 1, 4 do
    coinBank.takeObject({position = shared.coinZone.getPosition()})
  end
  Wait.time(
    function()
      shared.coinZone.layoutZone.layout()
    end, 1
  )
end
