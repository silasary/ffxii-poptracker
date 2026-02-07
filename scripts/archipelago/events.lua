QUEST_MAPPING = {
    [128] = {
        [50] = {"rogue_tomato"},
    },
    [129] = {
        [50] = {"thextera"},
    },
    [130] = {
        [70] = {"flowering_cactoid"},
    },
    [131] = {
        [50] = {"wraith"},
    },
    [132] = {
        [70] = {"nidhogg"},
    },
    [133] = {
        [50] = {"white_mousse"},
    },
    [134] = {
        [70] = {"ring_wyrm"},
    },
    [135] = {
        [70] = {"wyvern_lord"},
    },
    [136] = {
        [70] = {"marilith"},
    },
    [137] = {
        [50] = {"enkelados"},
    }
}

KILL_FLAGS = {
    [0x0A03] = "earth_tyrant",
    [0x0A04] = "mimic_queen",
    [0x0A05] = "flans",
    [0x0A06] = "firemane",
    [0x0A07] = "hydro",
    [0x0A08] = "tiamat",
    [0x0A09] = "daedalus",
    [0x0A0A] = "tyrant",


}

HUNT_MAPPING = {  -- IDs are zero-indexed, And the first 40 in order of appearance in the game
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
    [10] = 50,
    [11] = 70,
    [12] = 70,
    [13] = 90,
    [14] = 200,
    [15] = 70,
    [16] = 30,
    [17] = 30,
    [18] = 50,
    [19] = 90,
    [20] = 100,
    [21] = 100,
    [22] = 200,
    [23] = 30,
    [24] = 30,
    [25] = 200,
    [26] = 70,
    [27] = 70,
    [28] = 50,
    [29] = 70,
    [30] = 70,
    [31] = 50,
    [32] = 50,  -- Cluckatrice
    [33] = 70,
    [34] = 70,
    [35] = 70,
    [36] = 70,
    [37] = 90,
    [38] = 200,
    [39] = 100,
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

function on_event_updated(offset, value)
    local code = KILL_FLAGS[offset]
    if code then
        print(string.format("Kill flag %s updated to %d", code, value))
        if value > 1 then
            local object = Tracker:FindObjectForCode(code)
            if object then
                object.Active = true
            else
                print(string.format("onEventUpdated: could not find object for kill code %s", code))
            end
        end
        return
    end
    if offset >= 0x1064 then
        local quest_id = offset - 0x1064
        -- print(string.format("Quest %d updated to stage %d", offset - 0x1064, value))
        if QUEST_MAPPING[quest_id] then
            for stage, codes in pairs(QUEST_MAPPING[quest_id]) do
                if value >= stage then
                    for _, code in pairs(codes) do
                        local object = Tracker:FindObjectForCode(code)
                        if object then
                            object.Active = true
                        else
                            print(string.format("onEventUpdated: could not find object for quest code %s", code))
                        end
                    end
                end
            end
            return
        else
            -- print(string.format("No quest data for quest %d", quest_id))
        end
        if quest_id >= 128 then
            on_hunt_updated(quest_id - 128, value)
            return
        end
    end
    -- print(string.format("Event %x updated to %s", offset, value))
end