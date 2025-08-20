local ITEM_MAPPING = require "archipelago.item_mapping"
local CHAR_MAPPING = require "archipelago.loc_mapping_chars"
local LOCATION_MAPPING = require "archipelago.location_mapping"
local OPTION_MAPPING = require "archipelago.option_mapping"
local CHAR_ITEMS = { 'vaan', 'ashe', 'fran', 'balthier', 'basch', 'penelo', 'guest' }
require "archipelago.hunts"
require "archipelago.tab_mapping"

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
    -- Load options from slot_data
    -- {
    -- 'characters': [0, 2, 1, 4, 3, 5],
    -- 'options': {
    --     'shuffle_main_party': 1,
    --     'character_progression_scaling': 1,
    --     'include_treasures': 0,
    --     'include_chops': 0,
    --     'include_black_orbs': 0,
    --     'include_trophy_rare_games': 0,
    --     'include_hunt_rewards': 0,
    --     'include_clan_hall_rewards': 0,
    --     'allow_seitengrat': 0,
    --     'bahamut_unlock': 0
    --   }
    -- }

    HuntKey = string.format("ffxiiow_hunts_%s_%s", Archipelago.TeamNumber, Archipelago.PlayerNumber)

    Archipelago:SetNotify({ HuntKey })
    Archipelago:Get({ HuntKey })

    local options = slot_data.options
    for key, mapped in pairs(OPTION_MAPPING) do
        local on = options[key] == 1
        if type(mapped) == "table" then
            for _, code in ipairs(mapped) do
                local obj = Tracker:FindObjectForCode(code)
                if obj then obj.Active = on end
            end
        else
            local obj = Tracker:FindObjectForCode(mapped)
            if obj then obj.Active = on end
        end
    end


    local function set_toggle(code, state)
        local obj = Tracker:FindObjectForCode(code)
        if obj then
            obj.Active = state
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(("Option code missing in tracker: %s"):format(tostring(code)))
        end
    end

    local function truthy(v)
        -- Accept 1/true/"1"
        if v == true or v == 1 or v == "1" then return true end
        return false
    end

    for opt_key, mapped in pairs(OPTION_MAPPING) do
        local state = truthy(options[opt_key])
        if type(mapped) == "table" then
            for _, code in ipairs(mapped) do
                set_toggle(code, state)
            end
        else
            set_toggle(mapped, state)
        end
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        for k, v in pairs(options) do
            print(("AP slot option %s = %s"):format(k, tostring(v)))
        end
    end

    
    PARTY_MAPPING = {}
    local characters = slot_data.characters
    -- characters is a mapping of vanilla character ID to shuffled ID.
    -- so Characters[0] is the character who you'd get when you usually get Vaan
    PARTY_MAPPING[CHAR_ITEMS[characters[1] + 1]] = "@Main/Rabanastre/Party Member (Vaan)"
    PARTY_MAPPING[CHAR_ITEMS[characters[2] + 1]] = "@Main/Dreadnought Leviathan/Party Member (Ashe)"
    PARTY_MAPPING[CHAR_ITEMS[characters[3] + 1]] = "@Main/Garamsythe Waterway/Party Members (Balthier, Fran, Guest)"
    PARTY_MAPPING[CHAR_ITEMS[characters[4] + 1]] = "@Main/Garamsythe Waterway/Party Members (Balthier, Fran, Guest)"
    PARTY_MAPPING[CHAR_ITEMS[characters[5] + 1]] = "@Main/Lowtown/Party Member (Basch)"
    PARTY_MAPPING[CHAR_ITEMS[characters[6] + 1]] = "@Main/Giza Plains Dry/Party Member (Penelo)"
end

Archipelago:AddClearHandler("clearItems", ClearItems)

-- Item Received

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


-- Location Checked
function OnLocation(location_id, location_name)
    -- is this a character starting items location?
    -- if g >= 3 helps to make sure we don't get false positives
    local v = CHAR_MAPPING[location_id]
    if v then
        local code = v[1]
        local obj  = Tracker:FindObjectForCode(code)
        if obj then
            -- keep a tiny counter per character
            _G._char_hits = _G._char_hits or {}
            _G._char_hits[code] = (_G._char_hits[code] or 0) + 1

            if _G._char_hits[code] >= 3 then -- require two separate checks
                obj.Active = true
                tobj = Tracker:FindObjectForCode(PARTY_MAPPING[code])
                if tobj then
                    tobj.AvailableChestCount = tobj.AvailableChestCount - 1
                end
            end
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

-- Hunt stages

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

function OnReply(key, value, old_value)
    print("OnReply %s", key)
    if starts_with(key, "ffxiiow_hunts") then
        local hunt_data = value
        for i, v in pairs(hunt_data) do
            local hunt_id = i
            local stage = v
            on_hunt_updated(hunt_id, stage)
        end
    end
end

Archipelago:AddSetReplyHandler("ds handler", OnReply)
Archipelago:AddRetrievedHandler("ds handler", OnReply)

-- Auto-tabbing --

function onBounce(json)  
    local data = json["data"]
    if data then
        if data["type"] == "MapUpdate" then
            updateMap(data["mapId"])
        end
    end
end

function updateMap(map_id)
    local tabs = TAB_MAPPING[map_id]
    --   if Tracker:FindObjectForCode("tab_switch").CurrentStage == 1 then
    if true then
        if tabs then
            for _, tab in ipairs(tabs) do
                Tracker:UiHint("ActivateTab", tab)
            end
        else
            print(string.format("No tab mapping found for map_id %s", map_id))
        end
    end
end

Archipelago:AddBouncedHandler("bounce handler", onBounce)
