
local globalData

local RelativePosition = Vector(-0.31, 2.00, -15.00) - Vector(-0.31, 0.96, -19.79)
local Scale = Vector(29.63, 2.20, 5.0)

local cardZoneScale = Vector(3.33, 3.00, 4.64)

local snapPointDistance = 2.43054628

function Callback.OnSetup()
  globalData = Shared(Global)
  SetPlayerColor()
  SetIsPlayingGame()
  
  if shared.isPlayingGame then
    shared.courtZones = {}
    Method.ExpandCourtZones()
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

function HasCard(container, optional_card)
  for _, object in ipairs(container.getObjects(true)) do
    if object.hasTag('CourtCard') then
      if optional_card == nil or optional_card.guid == object.guid then
        return true
      end
    end
  end
  return false
end

-- shift cards to fill gaps in the court
function Method.ShrinkCourtZones()
  
  function FindEmptyZone()
    if #shared.courtZones == 2 then
      if (not HasCard(shared.courtZones[2])) then
        return 2
      end
    end
    
    -- ignore first and last zone since those should be empty
    for i = 2, #shared.courtZones - 1 do
      if (not HasCard(shared.courtZones[i])) then
        return i
      end
    end
    return nil
  end

  -- continue removing empty zones until there are none
  while true do
    local index = FindEmptyZone()
    if index == nil then
      return
    end
    
    RemoveZone(index)
  end
  
end

function RemoveZone(index)
  local destinations = {}
  local averagePosition = Vector(0, 0, 0)
  for i = 1, #shared.courtZones - 1 do
    table.insert(destinations, shared.courtZones[i].getPosition())
    averagePosition = averagePosition + destinations[#destinations]
  end
  
  destroyObject(shared.courtZones[index])
  table.remove(shared.courtZones, index)
  
  averagePosition.x = averagePosition.x / #shared.courtZones
  averagePosition.y = averagePosition.y / #shared.courtZones
  averagePosition.z = averagePosition.z / #shared.courtZones
  local centerShift = Vector(shared.courtCenter) - averagePosition
  
  for i, courtZone in ipairs(shared.courtZones) do
    SmoothMoveZone(courtZone, destinations[i] + centerShift, false, false)
  end
end

-- if an edge slot in the court is filled, add a new slot after it and center the court
function Method.ExpandCourtZones()
  local bFixEvenCentering = true
  if #shared.courtZones == 0 then
    SpawnCourtZone(false, bFixEvenCentering)
    bFixEvenCentering = false
  else
    if HasCard(shared.courtZones[1]) then
      SpawnCourtZone(true, bFixEvenCentering)
      bFixEvenCentering = false
    end
    if HasCard(shared.courtZones[#shared.courtZones]) then
      SpawnCourtZone(false, bFixEvenCentering)
      bFixEvenCentering = false
    end
  end
  CenterCourtZone()
end

-- move zone and all it's contents
function SmoothMoveZone(zone, position, collide, fast)
  local moveVector = position - zone.getPosition();
  
  for _, object in ipairs(zone.getObjects(true)) do
    object.setPositionSmooth(object.getPosition() + moveVector, collide, fast)
  end
  zone.setPositionSmooth(position, collide, fast)
end

function CenterCourtZone()
  local averagePosition = Vector(0, 0, 0)
  for _, zone in ipairs(shared.courtZones) do
    averagePosition = averagePosition + zone.getPosition()
  end
  averagePosition.x = averagePosition.x / #shared.courtZones
  averagePosition.y = averagePosition.y / #shared.courtZones
  averagePosition.z = averagePosition.z / #shared.courtZones
  local moveVector = Vector(shared.courtCenter) - averagePosition
  
  for _, zone in ipairs(shared.courtZones) do
    SmoothMoveZone(zone, zone.getPosition() + moveVector, false, false)
  end
end

---@param bInsertBeginning boolean | nil
function SpawnCourtZone(bInsertBeginning, bFixEvenCentering)

  local rotation = owner.getRotation()
  rotation.y = rotation.y - 180
  
  local cardOffset = Vector(0, 0, 0)

  if #shared.courtZones > 0 then
    local count = math.ceil(#shared.courtZones / 2.0)
    if #shared.courtZones % 2 == 0 and bFixEvenCentering then
      count = count + 0.5
    end
    if bInsertBeginning then
      cardOffset.x = -(cardZoneScale.x) * count
    else
      cardOffset.x = cardZoneScale.x * count
    end
  end
  
  local translationVector = RelativePosition + cardOffset
  translationVector:rotateOver('y', rotation.y)
  local position = owner.getPosition() + translationVector

  -- slightly nudge red and orange zones so they fit
  if shared.playerColor == 'Red' or shared.playerColor == 'Orange' then
    position.z = position.z + 2.6
  end

  if #shared.courtZones == 0 then
    shared.courtCenter = position
  end
  
  ---@type tts__SpawnObjectDataParams
  local ObjectParameters = {
    position = position,
    rotation = rotation,
    scale = cardZoneScale * 0.9,

    data = {
      Name = "ScriptingTrigger",
      Transform = {posX = 0.0, posY = 0.0, posZ = 0.0, rotX = 0.0, rotY = 0.0, rotZ = 0.0, scaleX = 1.0, scaleY = 1.0, scaleZ = 1.0},
      Locked = true,
      AttachedSnapPoints = {
        {
          Position = { 0.00, -0.5, 0.00 },
          Rotation = { 0.00, 180.0, 0.00 },
          Tags = {"CourtCard"}
        }
      },
      Tags = {shared.playerColor, 'CourtZone'}
    }
  }
  if bInsertBeginning then
    table.insert(shared.courtZones, 1, spawnObjectData(ObjectParameters))
  else
    table.insert(shared.courtZones, spawnObjectData(ObjectParameters))
  end
  
end
