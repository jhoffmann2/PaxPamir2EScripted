

local globalData
local zonePositions = {
  [suitIds.Political] = Vector(-12.08, 0.97, -4.13),
  [suitIds.Intelligence] = Vector(-12.08, 0.97, -4.13),
  [suitIds.Economic] = Vector(-12.08, 0.97, -4.13),
  [suitIds.Military] = Vector(-12.08, 0.97, -4.13),
}

function onload(save_text)
  globalData = Shared(Global)
end

function onSave()
  save_data = {
    favoredSuitZones = shared.favoredSuitZones
  }
  return JSON.encode(save_data)
end

function Callback.OnSetup()
  shared.favoredSuitZones = {}
  for suit, position in pairs(zonePositions) do

    local objectParameters = {}
    objectParameters.type = 'ScriptingTrigger'
    objectParameters.position = { position }
    objectParameters.scale = { owner.getScale() }
    objectParameters.rotation = { 0,0,0 }
    shared.favoredSuitZones[suit] = spawnObject(objectParameters)
  end
end
