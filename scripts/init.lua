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

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/trophy_rares.json")
Tracker:AddItems("items/hunts.json")

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.json")
    -- Locations
    Tracker:AddLocations("locations/locations.json")
end

-- Layout
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")
