Tracker.AllowDeferredLogicUpdate = true

-- FF12 Brain
ScriptHost:LoadScript("scripts/aeropass.lua")
ScriptHost:LoadScript("scripts/esper.lua")
ScriptHost:LoadScript("scripts/huntclub.lua")
ScriptHost:LoadScript("scripts/hunts.lua")
ScriptHost:LoadScript("scripts/items.lua")
ScriptHost:LoadScript("scripts/layouts.lua")
ScriptHost:LoadScript("scripts/locations.lua")
ScriptHost:LoadScript("scripts/logic.lua")
ScriptHost:LoadScript("scripts/archipelago/autotracking.lua")

Tracker:AddMaps("maps/maps.json")


-- Add all maps
Tracker:AddMaps("maps/maps.json")

-- Init item tracking
initialize_watch_items()


-- Archipelago Auto Tracking

if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/archipelago/archipelago.lua")
end
