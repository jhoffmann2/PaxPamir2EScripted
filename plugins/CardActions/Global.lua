
local globalData;

function onLoad()
  globalData = Shared(Global)
end

local fullCardButtonWidth = 1075
local fullCardButtonHeight = 1500

local maxCardX = 1.1
local maxCardY = 1.53333

local actionTransforms = {
  [1] = {
    right = {
      {
        position = { x = 350.3, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
    centered = { 
      {
        position = { x = 0, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
    withSpecial = {
      {
        position = { x = 322, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
  },
  [2] = {
    right = {
      {
        position = { x = 76.3, y = 474 },
        scale = { width = 285, height = 285 },
      },
      {
        position = { x = 349, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
    centered = {
      {
        position = { x = -136.5, y = 474 },
        scale = { width = 285, height = 285 },
      },
      {
        position = { x = 136.5, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
  },
  [3] = {
    centered = {
      {
        position = { x = -273, y = 474 },
        scale = { width = 285, height = 285 },
      },
      {
        position = { x = 0, y = 474 },
        scale = { width = 285, height = 285 },
      },
      {
        position = { x = 273, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
    right = {
      {
        position = { x = -273, y = 474 },
        scale = { width = 285, height = 285 },
      },
      {
        position = { x = 0, y = 474 },
        scale = { width = 285, height = 285 },
      },
      {
        position = { x = 273, y = 474 },
        scale = { width = 285, height = 285 },
      },
    },
  },
}


---@param card tts__Card
function onObjectSpawn(card)
  if card.type ~= 'Card' then
    return
  end
  
  local cardId = card.getData().CardID
  if not cardId then
    return
  end
  
  local data = globalData.courtCards[cardId]
  if not data then
    return -- not a court card
  end
  
  local actionCount = #data.actions
  if actionCount == 0 then
    return
  end
  
  local transforms
  if data.special then
    transforms = actionTransforms[actionCount].withSpecial
  elseif data.centerActions then
    transforms = actionTransforms[actionCount].centered
  else
    transforms = actionTransforms[actionCount].right
  end

  for i, transform in ipairs(transforms) do

    positionX = (transform.position.x / (0.515 * fullCardButtonWidth)) * maxCardX
    positionY = (transform.position.y / (0.505 * fullCardButtonHeight)) * maxCardY
    
    params = {
      click_function = "OnActionButtonClicked"..tostring(i),
      function_owner = self,
      label          = '',
      position       = {positionX, 1, positionY},
      rotation       = {0, 0, 0},
      width          = transform.scale.width,
      height         = transform.scale.height,
      font_size      = 0,
      color          = {0,0,0,0},
      font_color     = {1, 1, 1},
      tooltip        = data.actions[i],
    }
    card.createButton(params)
  end
  
end

function OnActionButtonClicked1(card, color, alt_click)
  OnActionButtonClicked(0,card,color,alt_click)
end

function OnActionButtonClicked2(card, color, alt_click)
  OnActionButtonClicked(1,card,color,alt_click)
end

function OnActionButtonClicked3(card, color, alt_click)
  OnActionButtonClicked(2,card,color,alt_click)
end

function onPlayerTurn(player, previousPlayer)
  -- clear all the buttons
  for _, card in ipairs(getObjectsWithTag('CourtCard')) do

    local cardId = card.getData().CardID
    if cardId then
      local data = globalData.courtCards[cardId]
      if data then
        local actionCount = #data.actions

        for buttonIndex = 0, actionCount - 1 do
          card.editButton({ index = buttonIndex, color = { 0, 0, 0, 0}})
        end
      end
    end
  end
end

function OnActionButtonClicked(buttonIndex, card, color, alt_click)
  if alt_click then
    card.editButton({ index = buttonIndex, color = { 0, 0, 0, 0}})
    return
  end
  
  local cardId = card.getData().CardID
  local data = globalData.courtCards[cardId]
  local actionCount = #data.actions
  for i = 0, actionCount - 1 do
    if i == buttonIndex then
      card.editButton({ index = i, color = { 0, .7, .1, .7}})
    else
      card.editButton({ index = i, color = { 0, 0, 0, 0}})
    end
  end
  
end