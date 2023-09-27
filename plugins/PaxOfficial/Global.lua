--
-- Pax Pamir 2nd Edition official scripted mod.
--
-- Created and maintained by AgentElrond.  Latest update:  2019
--


function onload()
  PAX_PAMIR_MOD_VERSION = "2.1.3"

  math.randomseed(os.time())
  -- Throw away a few numbers per the Lua documentation.  The first number may not be random.
  math.random()
  math.random()
  math.random()

  BLOCK_EFFECT_DEFAULT = 0
  BLOCK_EFFECT_ROAD = 1

  dealHeight = 4.5

  mainBoardGuid = 'e41f76'
  marketBoardGuid = 'b71a0d'
  deckBoardGuid = '83c87c'
  discardBoardGuid = '5cd596'
  blockBoardGuid = '233a2f'
  setupButtonHolderGuid = '625fe9'
  buttonHolderGuid = 'ac253b'
  loadingCoinGuid = '971340'
  militaryReminderTokenGuid = 'bb28f4'

  borderZones = {}
  shared.marketZones = {}
  deckParts = {}
  shared.deckZone = nil
  loadingCoin = nil
  militaryReminderToken = nil
  courtDeck = nil
  eventDeck = nil

  -- This value will be set during setup and can differ from the number of seated players due to disconnections and/or the AI player.
  shared.gamePlayerCount = 2

  loadedFromSave = false
  loadSyncSuccessful = false

  turnTimerEnabled = false
  turnLimitSeconds = 0
  turnTimerID = nil

  greenBlockGuids = { '564906', 'ccc45e', '7a381d', '4b5330',
                      'e045ec', '7b3127', '9d77da', '9902d9',
                      '169839', '248b3b', '5def58', 'b6168d' }
  greenBlocks = {}

  yellowBlockGuids = { '6e0716', '549805', '8abd00', 'f6a7ba',
                       '50eacc', 'fefaec', 'b33c35', 'bfb25f',
                       '375b99', '0c4dae', '632ee7', '5e7dcc' }
  yellowBlocks = {}

  pinkBlockGuids = { 'dddc08', '93a5d3', 'c0b6bb', '570ee3',
                     '80a27b', '6f19c8', 'dfe68f', '260a7f',
                     '098723', '5ff747', 'dc3ae9', '693a97' }
  pinkBlocks = {}

  shared.playerBoardGuids = {
    Red = "e5ed50",
    Blue = "21c38a",
    White = "c85046",
    Green = "f522f5",
    Orange = "57a6e3",
  }
  courtDeckGuid = 'fcb83b'
  eventDeckGuid = 'fdc6b4'
  dominanceCardGuids = { '7b066f', 'fe3abd', 'b33c4a', '0f2311' }
  dominanceCards = {}
  scoreMarkers = {}
  loyaltyHolders = {}
  curLoyalties = {}
  loyaltyHolderGuids = { 'cf61e5', '1686c1', '495a56', 'c1cfa5', '9a9e94' }
  scoreMarkerGuids = { '528030', 'a942d4', 'ec7352', '021452', '41932f' }

  rulerTokenGuids = { '761658', 'c4e8eb', 'f9cad5', '45c25c', '70f357', 'c6a1a3' }
  rulerTokenStartPositions = { { -7.08, 0.97, 4.11 },
                               { 3.92, 0.97, 3.78 },
                               { 10.55, 0.97, -0.05 },
                               { 5.37, 0.97, -3.54 },
                               { -1.75, 0.97, -2.17 },
                               { -8.37, 0.97, -3.37 } }
  rulerTokens = {}

  borderPositions = { { -8.060, 1.5, -0.855 },
                      { -3.446, 1.5, 0.193 },
                      { -5.146, 1.5, -3.992 },
                      { 0.068, 1.5, 0.213 },
                      { 1.648, 1.5, -4.068 },
                      { -1.286, 1.5, 2.797 },
                      { -1.118, 1.5, 5.389 },
                      { 3.225, 1.5, -1.043 },
                      { 6.168, 1.5, -0.893 },
                      { 7.978, 1.5, -4.033 },
                      { 8.319, 1.5, 1.098 },
                      { 9.722, 1.5, 4.392 } }

  borderRotations = { { 0.000, 5.998, 0.0 },
                      { 0.000, 322.000, 0.0 },
                      { 0.000, 269.869, 0.0 },
                      { 0.000, 35.819, 0.0 },
                      { 0.000, 98.000, 0.0 },
                      { 0.000, 275.700, 0.0 },
                      { 0.000, 270.000, 0.0 },
                      { 0.000, 180.000, 0.0 },
                      { 0.000, 168.155, 0.0 },
                      { 1.936, 254.219, 0.0 },
                      { 0.000, 115.000, 0.0 },
                      { 0.000, 110.000, 0.0 } }

  borderScales = { { 5.500, 3.500, 0.750 },
                   { 4.500, 3.500, 0.750 },
                   { 5.800, 3.500, 0.750 },
                   { 4.282, 3.500, 0.750 },
                   { 5.500, 3.500, 0.750 },
                   { 2.629, 3.500, 0.750 },
                   { 2.700, 3.500, 0.750 },
                   { 3.686, 3.500, 0.750 },
                   { 2.900, 3.500, 0.750 },
                   { 6.328, 3.500, 0.750 },
                   { 4.000, 3.500, 0.750 },
                   { 4.133, 3.500, 0.750 } }

  marketPositions = { { -12.260, -3.000, 19.160 },
                      { -8.720, -3.000, 19.160 },
                      { -5.200, -3.000, 19.160 },
                      { -1.690, -3.000, 19.160 },
                      { 1.820, -3.000, 19.160 },
                      { 5.330, -3.000, 19.160 },
                      { -12.260, -3.000, 14.360 },
                      { -8.720, -3.000, 14.360 },
                      { -5.200, -3.000, 14.360 },
                      { -1.690, -3.000, 14.360 },
                      { 1.820, -3.000, 14.360 },
                      { 5.330, -3.000, 14.360 } }

  deckPosition = { 10.75, -3.000, 14.11 }
  
  
  favoredSuitZonePositions = {
    [suitIds.Political] =     {-12.08, 0.97, 2.98},
    [suitIds.Intelligence] =  {-12.08, 0.97, 0.63},
    [suitIds.Economic] =      {-12.08, 0.97, -1.74},
    [suitIds.Military] =      {-12.08, 0.97, -4.13},
  }
  
  shared.favoredSuitZones = {
    [suitIds.Political] =     nil,
    [suitIds.Intelligence] =  nil,
    [suitIds.Economic] =      nil,
    [suitIds.Military] =      nil,
  }

  favoredSuitZoneRotation = { 0.000, 0.000, 0.000 }
  favoredSuitZoneScale = { 0.800, 4.000, 0.800 }

  militaryReminderHiddenPosition = { -47.190, -1.000, 32.330 }
  militaryReminderVisiblePosition = { -17.750, 0.960, 16.640 }

  tableSeatIndices = { Orange = 1, Green = 2, White = 3, Blue = 4, Red = 5 }

  -- Make certain elements uninteractable.

  mainBoard = getObjectFromGUID(mainBoardGuid)
  if mainBoard ~= nil then
    mainBoard.interactable = false
  end

  marketBoard = getObjectFromGUID(marketBoardGuid)
  if marketBoard ~= nil then
    marketBoard.interactable = false
  end

  deckBoard = getObjectFromGUID(deckBoardGuid)
  if deckBoard ~= nil then
    deckBoard.interactable = false
  end

  discardBoard = getObjectFromGUID(discardBoardGuid)
  if discardBoard ~= nil then
    discardBoard.interactable = false
  end

  blockBoard = getObjectFromGUID(blockBoardGuid)
  if blockBoard ~= nil then
    blockBoard.interactable = false
  end

  setupButtonHolder = getObjectFromGUID(setupButtonHolderGuid)
  if setupButtonHolder ~= nil then
    setupButtonHolder.interactable = false
  end

  buttonHolder = getObjectFromGUID(buttonHolderGuid)
  if buttonHolder ~= nil then
    buttonHolder.interactable = false
  end

  loadingCoin = getObjectFromGUID(loadingCoinGuid)
  if loadingCoin ~= nil then
    loadingCoin.interactable = false
  end

  militaryReminderToken = getObjectFromGUID(militaryReminderTokenGuid)
  if militaryReminderToken ~= nil then
    militaryReminderToken.interactable = false
  end

  -- Get references.

  for curSeatColor, curSeatIndex in pairs(tableSeatIndices) do
    loyaltyHolders[curSeatColor] = getObjectFromGUID(loyaltyHolderGuids[tableSeatIndices[curSeatColor]])
    curLoyalties[curSeatColor] = loyaltyHolders[curSeatColor].AssetBundle.getLoopingEffectIndex()

    scoreMarkers[curSeatColor] = getObjectFromGUID(scoreMarkerGuids[tableSeatIndices[curSeatColor]])
  end

  local curBlockIndex = 1
  for curBlockIndex = 1, 12 do
    greenBlocks[curBlockIndex] = getObjectFromGUID(greenBlockGuids[curBlockIndex])
    yellowBlocks[curBlockIndex] = getObjectFromGUID(yellowBlockGuids[curBlockIndex])
    pinkBlocks[curBlockIndex] = getObjectFromGUID(pinkBlockGuids[curBlockIndex])
  end

  for curRulerTokenIndex = 1, 6 do
    rulerTokens[curRulerTokenIndex] = getObjectFromGUID(rulerTokenGuids[curRulerTokenIndex])
  end

  courtDeck = getObjectFromGUID(courtDeckGuid)
  eventDeck = getObjectFromGUID(eventDeckGuid)
  for dominanceIndex = 1, 4 do
    dominanceCards[dominanceIndex] = getObjectFromGUID(dominanceCardGuids[dominanceIndex])
  end

  -- Create buttons.

  if setupButtonHolder ~= nil then
    setupButtonHolder.createButton({
      label = "2-Player\nSetup",
      click_function = "setup2Players",
      function_owner = self,
      position = { 24.8, 2.3, -2.4 },
      scale = { 4, 4, 4 },
      width = 700,
      height = 500,
      font_size = 144,
      color = { 1, 1, 1, 1 }
    })

    setupButtonHolder.createButton({
      label = "3-Player\nSetup",
      click_function = "setup3Players",
      function_owner = self,
      position = { 32.0, 2.3, -2.4 },
      scale = { 4, 4, 4 },
      width = 700,
      height = 500,
      font_size = 144,
      color = { 1, 1, 1, 1 }
    })
    setupButtonHolder.createButton({
      label = "4-Player\nSetup",
      click_function = "setup4Players",
      function_owner = self,
      position = { 24.8, 2.3, 3.4 },
      scale = { 4, 4, 4 },
      width = 700,
      height = 500,
      font_size = 144,
      color = { 1, 1, 1, 1 }
    })
    setupButtonHolder.createButton({
      label = "5-Player\nSetup",
      click_function = "setup5Players",
      function_owner = self,
      position = { 32.0, 2.3, 3.4 },
      scale = { 4, 4, 4 },
      width = 700,
      height = 500,
      font_size = 144,
      color = { 1, 1, 1, 1 }
    })
  else
    -- If the setup object is missing, a saved game must have been loaded.
    -- Search for the border scripting zones and the military zone.

    loadedFromSave = true
    loadSyncSuccessful = true

    local curObject = nil
    local curScale = 1
    local curBorderIndex = 1
    
    for _, curObject in ipairs(getObjectsWithAllTags('FavoredSuitZone')) do
      if curObject.getName() == suitIds.Political then
        shared.favoredSuitZones[suitIds.Political] = curObject
      elseif curObject.getName() == suitIds.Intelligence then
        shared.favoredSuitZones[suitIds.Intelligence] = curObject
      elseif curObject.getName() == suitIds.Economic then
        shared.favoredSuitZones[suitIds.Economic] = curObject
      elseif curObject.getName() == suitIds.Military then
        shared.favoredSuitZones[suitIds.Military] = curObject
      end
    end

    borderZones = getObjectsWithAllTags('BoarderZone')

    if ((#borderZones ~= 13) or 
      not shared.favoredSuitZones[suitIds.Political] or 
      not shared.favoredSuitZones[suitIds.Intelligence] or 
      not shared.favoredSuitZones[suitIds.Economic] or 
      not shared.favoredSuitZones[suitIds.Military]) then
      printToAll("Error, detected saved game, but failed to find expected scripting zones.", { 1, 1, 1 })
      loadSyncSuccessful = false
    end
  end

  if buttonHolder ~= nil then
    buttonHolder.createButton({
      label = "Reset Coalition\nBlocks",
      click_function = "confirmResetBoard",
      function_owner = self,
      position = { 68.8, 1.3, -0.71 },
      scale = { 4, 4, 4 },
      width = 1200,
      height = 600,
      font_size = 144,
      color = { 1, 1, 1, 1 }
    })

    -- TODO create market refill button to see if coins are a problem?  Maybe just move a fixed amount?  But, more logic would be needed for blank spaces, events, etc.

    -- Create loyalty buttons for players.

    local curLoyaltyHolder = nil
    for curSeatColor, curSeatIndex in pairs(tableSeatIndices) do
      curLoyaltyHolder = getObjectFromGUID(loyaltyHolderGuids[curSeatIndex])
      if curLoyaltyHolder ~= nil then
        -- Generate a callback function for each seat.
        _G[curSeatColor .. "Loyalty"] = function()
          -- Update loyalty.
          curLoyalties[curSeatColor] = ((curLoyalties[curSeatColor] + 1) % 3)

          -- Start the spin animation.
          loyaltyHolders[curSeatColor].AssetBundle.playTriggerEffect(curLoyalties[curSeatColor])

          -- When the spin animation is done, play the looping animation so state is maintained for save files and players leaving/joining.
          Wait.time(function()
            loyaltyHolders[curSeatColor].AssetBundle.playLoopingEffect(curLoyalties[curSeatColor])
          end, 0.25)
        end

        -- Create a button that calls the callback function.
        curLoyaltyHolder.createButton({
          tooltip = "Change Loyalty",
          click_function = (curSeatColor .. "Loyalty"),
          function_owner = self,
          position = { 0.00, 0.10, -0.57 },
          rotation = { 0, 0, 0 },
          scale = { 1, 1, 0.7 },
          width = 800,
          height = 500,
          color = { 0, 0, 0, 0 }
        })
      end
    end
  end

  -- Start periodic military zone timer check.
  militaryTimerWaitID = Wait.time(periodicMilitaryZoneCheck, 0.5, -1)

  -- Print welcome message.

  printToAll("", { 1, 1, 1 })
  printToAll("===========================================", { 1, 1, 1 })
  printToAll("Welcome to the official Pax Pamir mod.", { 1, 1, 1 })
  printToAll("", { 1, 1, 1 })
  printToAll("Mod version " .. PAX_PAMIR_MOD_VERSION, { 1, 1, 1 })
  printToAll("", { 1, 1, 1 })
  printToAll("Type \"!help\" in chat for a command list.", { 1, 1, 1 })
  printToAll("===========================================", { 1, 1, 1 })
  printToAll("", { 1, 1, 1 })

  if loadedFromSave then
    if loadSyncSuccessful then
      printToAll("Continuing saved game.", { 1, 1, 1 })
      printToAll("", { 1, 1, 1 })
    else
      printToAll("Warning, saved game may be corrupt.", { 1, 0, 0 })
      printToAll("", { 1, 1, 1 })
    end
  end
end

function onChat(message, chatPlayer)
  if string.sub(message, 1, 5) == "!help" then
    -- Note that the chat font is not necessarily fixed-width, so alignment is done manually.
    printToColor("", chatPlayer.color, { 1, 1, 1 })
    printToColor("Chat commands:", chatPlayer.color, { 1, 1, 1 })
    printToColor("==================", chatPlayer.color, { 1, 1, 1 })
    printToColor("!help                            Print this message", chatPlayer.color, { 1, 1, 1 })
    printToColor("", chatPlayer.color, { 1, 1, 1 })
    printToColor("!turntimer 30              Set the turn timer to 30 seconds (0 to disable)", chatPlayer.color, { 1, 1, 1 })
    printToColor("", chatPlayer.color, { 1, 1, 1 })
    printToColor("", chatPlayer.color, { 1, 1, 1 })
  elseif string.sub(message, 1, 10) == "!turntimer" then
    turnTimerString = string.sub(message, 12)
    turnLimitSeconds = tonumber(turnTimerString)

    if turnLimitSeconds > 0 then
      printToAll("Turn limit set to " .. turnLimitSeconds .. " seconds.", { 1, 1, 1 })
      turnTimerEnabled = true
      turnTimerID = Wait.time(turnTimerExpired, turnLimitSeconds)
    else
      printToAll("Turn timer disabled.", { 1, 1, 1 })
      turnTimerEnabled = false
      if turnTimerID ~= nil then
        Wait.stop(turnTimerID)
        turnTimerID = nil
      end
    end
  end
end

function onPlayerTurn(playerColor)
  if turnTimerID ~= nil then
    Wait.stop(turnTimerID)
  end

  if turnLimitSeconds > 0 then
    turnTimerID = Wait.time(turnTimerExpired, turnLimitSeconds)
  end
end

function turnTimerExpired()
  printToAll("", { 1, 0, 0 })
  broadcastToAll("*** TURN TIMER EXPIRED ***", { 1, 0, 0 })
  printToAll("", { 1, 0, 0 })
end

function periodicMilitaryZoneCheck()
  if shared.favoredSuitZones[suitIds.Military] ~= nil then
    local isInZone = false
    -- Prepare for box cast.
    local zonePosition = shared.favoredSuitZones[suitIds.Military].getPosition()
    local zoneRotation = shared.favoredSuitZones[suitIds.Military].getRotation()
    local zoneScale = shared.favoredSuitZones[suitIds.Military].getScale()
    local castParameters = { direction = { 0, 1, 0 },
                             origin = { zonePosition.x, 0, zonePosition.z },
                             orientation = { zoneRotation.x, zoneRotation.y, zoneRotation.z },
                             size = { zoneScale.x, zoneScale.y, zoneScale.z },
                             max_distance = 10,
                             type = 3 }

    local hitObjects = Physics.cast(castParameters)
    for hitIndex, curHit in ipairs(hitObjects) do
      if curHit.hit_object.getName() == "Favored Suit Marker" then
        -- Do not detect the marker if someone is holding it.
        if curHit.hit_object.held_by_color == nil then
          isInZone = true
          break
        end
      end
    end

    if isInZone == true then
      militaryReminderToken.setPosition({ militaryReminderVisiblePosition[1],
                                          militaryReminderVisiblePosition[2],
                                          militaryReminderVisiblePosition[3] })
    else
      militaryReminderToken.setPosition({ militaryReminderHiddenPosition[1],
                                          militaryReminderHiddenPosition[2],
                                          militaryReminderHiddenPosition[3] })
    end
  end
end

function commonSetup(nextSetupFunction)
  printToAll("Setting up...", { 1, 1, 1 })
  InvokeEvent("OnSetup")

  -- Create script zones under the table to avoid white flash(es).


  for borderIndex = 1, 12 do
    ---@type tts__SpawnObjectDataParams
    local objectParameters = {
      data = {
        Name = 'ScriptingTrigger',
        Transform = {
          posX = borderPositions[borderIndex][1],
          posY = borderPositions[borderIndex][2],
          posZ = borderPositions[borderIndex][3],
          rotX = borderRotations[borderIndex][1],
          rotY = borderRotations[borderIndex][2],
          rotZ = borderRotations[borderIndex][3],
          scaleX = borderScales[borderIndex][1],
          scaleY = borderScales[borderIndex][2],
          scaleZ = borderScales[borderIndex][3],
        },
        Locked = true,
        Tags = {'BoarderZone'},
      }
    }
    
    borderZones[borderIndex] = spawnObjectData(objectParameters)
  end

  for marketIndex = 1, 12 do
    ---@type tts__SpawnObjectDataParams
    local objectParameters = {
      data = {
        Name = 'ScriptingTrigger',
        Transform = {
          posX = marketPositions[marketIndex][1],
          posY = marketPositions[marketIndex][2],
          posZ = marketPositions[marketIndex][3],
          rotX = 0.00,
          rotY = 0.00,
          rotZ = 0.00,
          scaleX = 2.90,
          scaleY = 3.00,
          scaleZ = 4.20,
        },
        Locked = true,
        Tags = {'MarketZone'},
      }
    }

    shared.marketZones[marketIndex] = spawnObjectData(objectParameters)
    
    Shared(shared.marketZones[marketIndex]).marketRow = math.floor((marketIndex - 1) / 6)
    Shared(shared.marketZones[marketIndex]).marketColumn = (marketIndex - 1) % 6
  end

  ---@type tts__SpawnObjectDataParams
  local objectParameters = {
    data = {
      Name = 'ScriptingTrigger',
      Transform = {
        posX = deckPosition[1],
        posY = deckPosition[2],
        posZ = deckPosition[3],
        rotX = 0.00,
        rotY = 0.00,
        rotZ = 0.00,
        scaleX = 2.90,
        scaleY = 3.00,
        scaleZ = 4.20,
      },
      Locked = true,
    }
  }
  shared.deckZone = spawnObjectData(objectParameters)

  for _, suit in pairs(suitIds) do
    local objectParameters = {
      data = {
        Name = 'ScriptingTrigger',
        Transform = {
          posX = favoredSuitZonePositions[suit][1],
          posY = favoredSuitZonePositions[suit][2],
          posZ = favoredSuitZonePositions[suit][3],
          rotX = favoredSuitZoneRotation[1],
          rotY = favoredSuitZoneRotation[2],
          rotZ = favoredSuitZoneRotation[3],
          scaleX = favoredSuitZoneScale[1],
          scaleY = favoredSuitZoneScale[2],
          scaleZ = favoredSuitZoneScale[3],
        },
        Nickname = suit,
        Locked = true,
        Tags = {'FavoredSuitZone'},
      }
    }
    
    shared.favoredSuitZones[suit] = spawnObjectData(objectParameters)
  end
  

  pickRandomStartPlayer()

  -- After a short delay to avoid a white flash, move the scripting zones above the table.
  Wait.time(raiseScriptZones, 0.5)

  -- Shuffle both decks.
  Wait.time(function()
    courtDeck.shuffle()
  end, 0.2, 6)
  Wait.time(function()
    eventDeck.shuffle()
  end, 0.2, 6)

  -- Continue setup after a short delay.
  Wait.time(nextSetupFunction, 2.0)
end

function pickRandomStartPlayer()
  local seatedPlayers = getSeatedPlayers()
  local randomPlayerindex = math.random(1, #seatedPlayers)
  local startColor = seatedPlayers[randomPlayerindex]

  printToAll("\n\nThe " .. startColor .. " player was randomly chosen to go first.\n\n", startColor)
end

function setup2Players()
  shared.gamePlayerCount = 2
  setupNormalGame()
end

function setup3Players()
  shared.gamePlayerCount = 3
  setupNormalGame()
end

function setup4Players()
  shared.gamePlayerCount = 4
  setupNormalGame()
end

function setup5Players()
  shared.gamePlayerCount = 5
  setupNormalGame()
end

function setupNormalGame()
  setupButtonHolder.destruct()

  for dominanceIndex = 1, 4 do
    dominanceCards[dominanceIndex].setRotation({ 0, 180, 180 })
  end

  courtDeck.setRotation({ 0, 180, 180 })
  eventDeck.setRotation({ 0, 180, 180 })

  Wait.time(function()
    commonSetup(normalSetup2)
  end, 0.3)
end

function normalSetup2()
  local stackCourtCount = (5 + shared.gamePlayerCount)
  local curMarketPosition = nil

  for cardIndex = 1, stackCourtCount do
    for stackIndex = 1, 6 do
      curMarketPosition = marketPositions[6 + stackIndex]

      courtDeck.takeObject({ position = { curMarketPosition[1],
                                          (curMarketPosition[2] + dealHeight + (cardIndex * 0.3)),
                                          curMarketPosition[3] },
                             rotation = { 0, 180, 180 },
                             flip = false,
                             smooth = false })
    end
  end

  for stackIndex = 3, 6 do
    curMarketPosition = marketPositions[6 + stackIndex]

    -- Move without collision, and move fast.
    dominanceCards[stackIndex - 2].setPositionSmooth({ curMarketPosition[1],
                                                       (curMarketPosition[2] + dealHeight + 4),
                                                       curMarketPosition[3] },
      false,
      true)
  end

  Wait.time(normalSetup3, 1.5)
end

function normalSetup3()
  local curMarketPosition = nil

  for eventIndex = 1, 6 do
    -- Deal 2 cards in the second pile from the left, and 1 card in other piles.
    if eventIndex == 1 then
      curMarketPosition = marketPositions[6 + 2]
    else
      curMarketPosition = marketPositions[6 + eventIndex]
    end

    eventDeck.takeObject({ position = { curMarketPosition[1],
                                        (curMarketPosition[2] + dealHeight + (eventIndex * 0.3)),
                                        curMarketPosition[3] },
                           rotation = { 0, 180, 180 },
                           flip = false,
                           smooth = false })
  end

  Wait.time(normalSetup4, 1.0)
end

function normalSetup4()
  local scriptZoneObjects = nil

  eventDeck.destruct()
  courtDeck.destruct()

  for stackIndex = 1, 6 do
    scriptZoneObjects = shared.marketZones[6 + stackIndex].getObjects(true)

    for i, curObject in ipairs(scriptZoneObjects) do
      if curObject.type == "Deck" then
        deckParts[stackIndex] = curObject

        Wait.time(function()
          curObject.shuffle()
        end, 0.2, 3)
        break
      end
    end
  end

  Wait.time(normalSetup5, 1.4)
end

function normalSetup5()
  for deckPartIndex = 1, 6 do
    -- Move without collision, and move fast.
    deckParts[deckPartIndex].setPositionSmooth({ deckPosition[1],
                                                 (deckPosition[2] + dealHeight + (7 - (deckPartIndex * 1.0))),
                                                 deckPosition[3] },
      false,
      true)
  end

  Wait.time(function()
    InvokeEvent('OnDeckSetup')
  end, 1.6)
  
  Wait.time(function()
    dealStartingMarket("Normal setup complete.")
  end, 1.6)
end

function dealStartingMarket(finishedMessage)
  local curMarketPosition = nil
  local scriptZoneObjects = shared.deckZone.getObjects(true)
  local dealDeck = nil

  for i, curObject in ipairs(scriptZoneObjects) do
    if curObject.type == "Deck" then
      dealDeck = curObject
      break
    end
  end

  -- Deal column by column.
  for columnIndex = 1, 6 do
    for rowIndex = 1, 2 do
      curMarketPosition = marketPositions[(6 * (rowIndex - 1)) + columnIndex]

      dealDeck.takeObject({ position = { curMarketPosition[1],
                                         (curMarketPosition[2] + dealHeight + 1),
                                         curMarketPosition[3] },
                            rotation = { 0, 180, 0 },
                            flip = false,
                            smooth = true })
    end
  end

  Wait.time(function()
    printToAll(finishedMessage, { 1, 1, 1 })
  end, 0.75)
end

function raiseScriptZones()
  local borderIndex = 1
  local marketIndex = 1
  local curZone = nil
  local zonePosition = nil

  for borderIndex = 1, 12 do
    curZone = borderZones[borderIndex]

    if curZone ~= nil then
      zonePosition = curZone.getPosition()
      curZone.setPosition({ zonePosition.x, 1.500, zonePosition.z })
    end
  end

  for marketIndex = 1, 12 do
    curZone = shared.marketZones[marketIndex]

    if curZone ~= nil then
      zonePosition = curZone.getPosition()
      curZone.setPosition({ zonePosition.x, 1.500, zonePosition.z })
    end
  end

  if shared.deckZone ~= nil then
    zonePosition = shared.deckZone.getPosition()
    shared.deckZone.setPosition({ zonePosition.x, 1.500, zonePosition.z })
  end

  for suit, zone in pairs(shared.favoredSuitZones) do
    if zone ~= nil then
      zonePosition = zone.getPosition()
      zone.setPosition({ zonePosition.x, 1.500, zonePosition.z })
    end
  end
end

function onObjectDrop(playerColor, droppedObject)
  local borderIndex = 1
  local scriptZoneObjects = nil
  local zonePosition = nil
  local zoneRotation = nil
  local zoneScale = nil
  local isInZone = false
  local setAsRoad = false
  -- Prepare for box cast(s).
  local castParameters = { direction = { 0, 1, 0 }, max_distance = 10, type = 3 }
  local hitObjects = nil

  -- Add an extra military zone scan to make the update more responsive.
  periodicMilitaryZoneCheck()

  if droppedObject.getName() == "Coalition Block" then
    for borderIndex = 1, 12 do
      curZone = borderZones[borderIndex]

      if curZone ~= nil then
        zonePosition = curZone.getPosition()
        zoneRotation = curZone.getRotation()
        zoneScale = curZone.getScale()

        castParameters.origin = { zonePosition.x, 0, zonePosition.z }
        castParameters.orientation = { zoneRotation.x, zoneRotation.y, zoneRotation.z }
        castParameters.size = { zoneScale.x, zoneScale.y, zoneScale.z }

        local hitObjects = Physics.cast(castParameters)
        for hitIndex, curHit in ipairs(hitObjects) do
          if curHit.hit_object.guid == droppedObject.guid then
            isInZone = true
            setAsRoad = true
            break
          end
        end

        if isInZone == true then
          break
        end
      end
    end

    if setAsRoad == true then
      droppedObject.AssetBundle.playLoopingEffect(BLOCK_EFFECT_ROAD)
      
    else
      droppedObject.AssetBundle.playLoopingEffect(BLOCK_EFFECT_DEFAULT)
    end

    local objectPosition = droppedObject.getPosition()
    local isOverBlockBoard = false

    -- Perform a ray cast straight down from slightly above the object in case lift height is minimum.
    castParameters.type = 1
    castParameters.origin = { objectPosition.x, (1 + objectPosition.y), objectPosition.z }
    castParameters.direction = { 0, -20, 0 }
    castParameters.max_distance = 20

    local hitObjects = Physics.cast(castParameters)
    for hitIndex, curHit in ipairs(hitObjects) do
      if curHit.hit_object.guid == blockBoard.guid then
        isOverBlockBoard = true
        break
      end
    end

    if isOverBlockBoard == true then
      local greenStartPosition = { x = 14.82, y = 1.08, z = 23.06 }
      local yellowStartPosition = { x = 15.85, y = 1.08, z = 23.06 }
      local pinkStartPosition = { x = 16.89, y = 1.08, z = 23.06 }
      local zScale = 0.86
      local curBlockIndex = 1
      local blockStartPosition = nil
      local droppedObjectDescription = droppedObject.getDescription()

      if droppedObjectDescription == "Afghan" then
        blockStartPosition = greenStartPosition
      elseif droppedObjectDescription == "Russian" then
        blockStartPosition = yellowStartPosition
      elseif droppedObjectDescription == "British" then
        blockStartPosition = pinkStartPosition
      else
        -- This should never happen.
        printToAll("Error, invalid coalition block.", { 1, 0, 0 })
      end

      -- Find the lowest empty block position.
      local emptyBlockIndex = 1
      local spotFull = false
      local hitObjects = nil
      for curBlockIndex = 1, 12 do
        -- Perform a ray cast straight down.
        castParameters.type = 1
        castParameters.origin = { blockStartPosition.x, 4, (blockStartPosition.z - (curBlockIndex * zScale)) }
        castParameters.direction = { 0, -20, 0 }
        castParameters.max_distance = 20

        spotFull = false
        hitObjects = Physics.cast(castParameters)
        for hitIndex, curHit in ipairs(hitObjects) do
          -- If there is a block in this spot that is not the dropped block, the spot is full.
          if ((curHit.hit_object.getName() == "Coalition Block") and (curHit.hit_object.guid ~= droppedObject.guid)) then
            spotFull = true
            break
          end
        end

        if spotFull == false then
          droppedObject.setPosition({ blockStartPosition.x, blockStartPosition.y, (blockStartPosition.z - (curBlockIndex * zScale)) })
          break
        else
          emptyBlockIndex = (emptyBlockIndex + 1)
        end
      end

      if emptyBlockIndex == 13 then
        -- This should never happen.
        printToAll("Error, no room for coalition block.", { 1, 0, 0 })
      end
    end
  elseif droppedObject.getName() == "Ruler Marker" then
    local objectPosition = droppedObject.getPosition()
    local isOverMainBoard = false

    -- Perform a ray cast straight down from slightly above the object in case lift height is minimum.
    castParameters.type = 1
    castParameters.origin = { objectPosition.x, (1 + objectPosition.y), objectPosition.z }
    castParameters.direction = { 0, -20, 0 }
    castParameters.max_distance = 20

    local hitObjects = Physics.cast(castParameters)
    for hitIndex, curHit in ipairs(hitObjects) do
      if curHit.hit_object.guid == mainBoard.guid then
        isOverMainBoard = true
        break
      end
    end

    if isOverMainBoard == true then
      for curRulerTokenIndex = 1, 6 do
        if droppedObject.guid == rulerTokens[curRulerTokenIndex].guid then
          local snapPosition = rulerTokenStartPositions[curRulerTokenIndex]
          droppedObject.setPosition({ snapPosition[1], snapPosition[2], snapPosition[3] })
          break
        end
      end
    end
  else
    -- Nothing needs done.
  end
end

function confirmResetBoard(buttonObject, playerColor, altClick)
  if Player[playerColor].host == true then
    Global.UI.setAttribute("table_confirm_board_reset", "visibility", playerColor)
    Global.UI.setAttribute("table_confirm_board_reset", "active", true)
  else
    printToColor("\nSorry, only the host can reset the board.\n", playerColor, stringColorToRGB(playerColor))
  end
end

function cancelResetBoard()
  Global.UI.setAttribute("table_confirm_board_reset", "active", false)
end

function resetBoard()
  local greenStartPosition = { x = 14.82, y = 1.08, z = 23.06 }
  local yellowStartPosition = { x = 15.85, y = 1.08, z = 23.06 }
  local pinkStartPosition = { x = 16.89, y = 1.08, z = 23.06 }
  local zScale = 0.86
  local curBlockIndex = 1

  Global.UI.setAttribute("table_confirm_board_reset", "active", false)

  -- Reset the effects and remove all coalition blocks from the board.
  for curBlockIndex = 1, 12 do
    greenBlocks[curBlockIndex].AssetBundle.playLoopingEffect(BLOCK_EFFECT_DEFAULT)
    greenBlocks[curBlockIndex].setPosition({ greenStartPosition.x, greenStartPosition.y, (greenStartPosition.z - (curBlockIndex * zScale)) })
    greenBlocks[curBlockIndex].setRotation({ 0.00, 0.00, 0.00 })

    yellowBlocks[curBlockIndex].AssetBundle.playLoopingEffect(BLOCK_EFFECT_DEFAULT)
    yellowBlocks[curBlockIndex].setPosition({ yellowStartPosition.x, yellowStartPosition.y, (yellowStartPosition.z - (curBlockIndex * zScale)) })
    yellowBlocks[curBlockIndex].setRotation({ 0.00, 0.00, 0.00 })

    pinkBlocks[curBlockIndex].AssetBundle.playLoopingEffect(BLOCK_EFFECT_DEFAULT)
    pinkBlocks[curBlockIndex].setPosition({ pinkStartPosition.x, pinkStartPosition.y, (pinkStartPosition.z - (curBlockIndex * zScale)) })
    pinkBlocks[curBlockIndex].setRotation({ 0.00, 0.00, 0.00 })
  end

  -- Note that as of the latest rules, neither ruler tokens nor tribes are automatically reset.
  -- However, rulerships may be lost due to armies vanishing.
end