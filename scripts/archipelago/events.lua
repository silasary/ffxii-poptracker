QUEST_MAPPING = {
    [57] = {
        [50] = { "medallion_makleou" },
        [75] = { "medallion_makleou_2" },
        [100] = { "medallion_complete" },
    },
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
    },
    [138] = {
        [50] = {"croakadile"},
    },
    [139] = {
        [70] = {"ixtab"},
    },
    [140] = {
        [70] = {"feral_retriever"},
    },
    [141] = {
        [50] = {"vorpal_bunny"},
    },
    [142] = {
        [70] = {"mindflayer"},
    },
    [143] = {
        [70] = {"bloodwing"},
    },
    [144] = {
        [30] = {"atomos"},
    },
    [145] = {
        [30] = {"roblon"},
    },
    [146] = {
        [50] = {"braegh"},
    },
    [147] = {
        [100] = {"darksteel"},
    },
    [148] = {
        [100] = {"vyraal"},
    },
    [149] = {
        [100] = {"lindwyrm"},
    },
    [150] = {
        [100] = {"overlord"},
    },
    [151] = {
        [30] = {"goliath"},
    },
    [152] = {
        [30] = {"deathscythe"},
    },
    [153] = {
        [70] = {"deathgaze"},
    },
    [154] = {
        [70] = {"diabolos"},
    },
    [155] = {
        [70] = {"piscodaemon"},
    },
    [156] = {
        [50] = {"wild_malboro"},
    },
    [157] = {
        [70] = {"catoblepas"},
    },
    [158] = {
        [70] = {"fafnir"},
    },
    [159] = {
        [100] = {"pylraster"},
    },
    [160] = {
        [50] = {"cluckatrice"},
    },
    [161] = {
        [70] = {"rocktoise"},
    },
    [162] = {
        [70] = {"orthros"},
    },
    [163] = {
        [70] = {"gil_snapper"},
    },
    [164] = {
        [70] = {"trickster"},
    },
    [165] = {
        [90] = {"antlion"},
    },
    [166] = {
        [30] = {"carrot"},
    },
    [167] = {
        [50] = {"gilgamesh1"},
        [100] = {"gilgamesh2"},
    },
    [168] = {
        [70] = {"behemoth_king"},
    },
    [169] = {
        [100] = {"ixion"},
    },
    [170] = {
        [70] = {"shadowseer"},
    },
    [171] = {
        [70] = {"yiazmat"},
    },
    [172] = {
        [70] = {"belito"},
    },
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

    [0x0A14] = "demon_wall_1",
    [0x0A15] = "demon_wall_2",
}

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
    if offset == 0x0416 then
        print(string.format("Grimy questline updated to stage %d", value))
        grimy_questline(value)
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
    end
    -- print(string.format("Event %x updated to %s", offset, value))
end

function grimy_questline(stage)
    local stages = {
        [0] = "grimy_not_started",
        [1] = "grimy_rohkenmou",
        [2] = "grimy_filo",
        [3] = "grimy_woman",
        [4] = "grimy_bangaa",
        [5] = "grimy_imperial",
        [6] = "grimy_filo2",
        [7] = "grimy_quest_complete",
    }
    local progress = Tracker:FindObjectForCode(stages[stage])
    ---@cast progress JsonItem
    if progress then
        progress.Active = true
    else
        print(string.format("grimy_questline: could not find object for stage %d", stage))
    end
end
