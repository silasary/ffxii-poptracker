Tracker.AllowDeferredLogicUpdate = true

-- get current variant
local variant = Tracker.ActiveVariantUID
-- check variant info
IS_ITEMS_ONLY = variant:find("itemsonly")

print("-- FFXII Tracker --")
print("Loaded variant: ", variant)

-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")
ScriptHost:LoadScript("scripts/logic/aeropass.lua")
ScriptHost:LoadScript("scripts/logic/huntclub.lua")
ScriptHost:LoadScript("scripts/logic/hunts.lua")
ScriptHost:LoadScript("scripts/logic/esper.lua")
ScriptHost:LoadScript("scripts/logic/treasures.lua")
ScriptHost:LoadScript("scripts/locations.lua")

-- Items
ScriptHost:LoadScript("scripts/items.lua")

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.json")
    -- Locations
    Tracker:AddLocations("locations/locations.json")
end

-- Layout
ScriptHost:LoadScript("scripts/layouts.lua")

-- Archipelago Auto Tracking
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/archipelago/autotracking.lua")
end
