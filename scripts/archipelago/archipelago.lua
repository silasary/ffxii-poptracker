local ITEM_MAPPING = require "archipelago.item_mapping"
local CHAR_MAPPING = require "archipelago.loc_mapping_chars"
local LOCATION_MAPPING = require "archipelago.location_mapping"
local CHAR_ITEMS = { 'vaan', 'ashe', 'fran', 'balthier', 'basch', 'penelo', 'guest' }
AP_INDEX = -1

function ClearItem(code, type)
    local item = Tracker:FindObjectForCode(code)
    if type == "toggle" then
        item.Active = false
    elseif type == "consumable" then
        item.AcquiredCount = 0
    end
end

function ClearItems(slot_data)
    -- todo: handle 'guest'
    AP_INDEX = -1
    for _, v in pairs(ITEM_MAPPING) do
        ClearItem(v[1], v[2])
    end
    for _, v in pairs(CHAR_ITEMS) do
        ClearItem(v, 'toggle')
    end
end

Archipelago:AddClearHandler("clearItems", ClearItems)

function OnItem(index, item_id, item_name, player_number)
    if index <= AP_INDEX then
        return
    else
        AP_INDEX = index
    end

    local item_map = ITEM_MAPPING[item_id]
    if not (item_map and item_map[1]) then
        return
    end

    local obj = Tracker:FindObjectForCode(item_map[1])

    if obj then
        if item_map[2] == "toggle" then
            obj.Active = true
        else
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        end
    end
end

Archipelago:AddItemHandler("item handler", OnItem)

function OnLocation(location_id, location_name)
    -- is this a character starting items location?
    local v = CHAR_MAPPING[location_id]
    if not not v then
        local obj = Tracker:FindObjectForCode(v[1])
        if not not obj then
            obj.Active = true
        end
    end

    local value = LOCATION_MAPPING[location_id]
    if not value then
      if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
      end
      return
    end
    for _, code in pairs(value) do
      local object = Tracker:FindObjectForCode(code)
      if object then
        if code:sub(1, 1) == "@" then
          object.AvailableChestCount = object.AvailableChestCount - 1
        else
          object.Active = true
        end
      elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
          print(string.format("onLocation: could not find object for code %s", code))
      end
    end 
end

Archipelago:AddLocationHandler("location handler", OnLocation)
