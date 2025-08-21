HUNT_MAPPING = {  -- IDs are zero-indexed, And the first 40 in order of appearance in the game
    [0] = "rogue_tomato",
    [1] = "thextera",
    [2] = "flowering_cactoid",
    [3] = "wraith",
    [4] = "nidhogg",
    [5] = "white_mousse",
    [6] = "ring_wyrm",
    [7] = "wyvern_lord",
    [8] = "marilith",
    [9] = "enkelados",
    [10] = "croakadile",
    [11] = "ixtab",
    [12] = "feral_retriever",
    [13] = "vorpal_bunny",
    [14] = "mindflayer",
    [15] = "bloodwing",
    [16] = "atomos",
    [17] = "roblon",
    [18] = "braegh",
    [19] = "darksteel",
    [20] = "vyraal",
    [21] = "lindwyrm",
    [22] = "overlord",
    [23] = "goliath",
    [24] = "deathscythe",
    [25] = "deathgaze",
    [26] = "diabolos",
    [27] = "piscodaemon",
    [28] = "wild_malboro",
    [29] = "catoblepas",
    [30] = "fafnir",
    [31] = "pylraster",
    [32] = "cluckatrice",
    [33] = "rocktoise",
    [34] = "orthros",
    [35] = "gil_snapper",
    [36] = "trickster",
    [37] = "antlion",
    [38] = "carrot",
    [39] = "gilgamesh",
    [40] = "behemoth_king",
    [41] = "ixion",
    [42] = "shadowseer",
    [43] = "yiazmat",
    [44] = "belito",
}

HUNT_STAGE_MAPPING = {  -- 200 means I haven't figured out where the kill is yet
    [0] = 50,
    [1] = 50,
    [2] = 70,
    [3] = 70,
    [4] = 70,
    [5] = 50,
    [6] = 90,
    [7] = 70,
    [8] = 70,
    [9] = 90,
    [10] = 90,
    [11] = 70,
    [12] = 70,
    [13] = 90,
    [14] = 200,
    [15] = 70,
    [16] = 200,
    [17] = 200,
    [18] = 200,
    [19] = 90,
    [20] = 200,
    [21] = 200,
    [22] = 200,
    [23] = 200,
    [24] = 200,
    [25] = 200,
    [26] = 200,
    [27] = 200,
    [28] = 200,
    [29] = 70,
    [30] = 200,
    [31] = 200,
    [32] = 200,
    [33] = 70,
    [34] = 70,
    [35] = 200,
    [36] = 200,
    [37] = 90,
    [38] = 200,
    [39] = 200,
    [40] = 200,
    [41] = 200,
    [42] = 200,
    [43] = 200,
    [44] = 2000
}
function on_hunt_updated(hunt_id, stage)
    
    local code = HUNT_MAPPING[tonumber(hunt_id)]
    local needed = HUNT_STAGE_MAPPING[tonumber(hunt_id)] or 0
    if stage >= needed then
        -- Mark the hunt as complete
        local object = Tracker:FindObjectForCode(code)
        if object then
            if code:sub(1, 1) == "@" then
                object.AvailableChestCount = object.AvailableChestCount - 1
            else
                object.Active = true
            end
        else
            print(string.format("onHuntUpdated: could not find object for hunt code %s", code))
        end
    else
        print(string.format("hunt %d: Stage %d/%d, %s", hunt_id, stage, needed, code))
    end
end
