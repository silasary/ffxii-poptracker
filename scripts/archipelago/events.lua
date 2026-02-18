QUEST_MAPPING = {
    [53] = {
        [20] = { "earth_tyrant_rimzat" },
        [30] = { "earth_tyrant_cotze"},
        [40] = { "earth_tyrant_northon" },
        [50] = { "earth_tyrant_cactus" },
        [60] = { "earth_tyrant_complete" },
    },
    [57] = {
        [50] = { "medallion_started" },
    },
    [58] = {
        [10] = { "bravery_rohkenmou"},
        [150] = { "bravery_all_fragments"},
    },
    [59] = {
        [10] = { "love_rohkenmu" },
        [20] = { "love_otto" },
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
        [10] = {"cluckatrice_started"},
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
    [0x0A0B] = "vinuskar",
    [0x0A0C] = "ahriman",
    [0x0A0D] = "rafflesia",

    [0x0A11] = "elder_wyrm",

    [0x0A14] = "demon_wall_1",
    [0x0A15] = "demon_wall_2",
    [0x0A16] = "king_bomb",

    [0x0A23] = "defeat_exodus",

    [0x0A28] = "judge_ghis",
    [0x0A3C] = "judge_bergan",
}

bool_flags = {
    [0x05AF] = "letter_rab_nal",
    [0x05B0] = "letter_rab_bhu",
    [0x05B1] = "letter_rab_arc",
    [0x05B2] = "letter_nal_arc",
    [0x05B3] = "letter_nal_bal",
    [0x05B4] = "letter_bhu_bal",
    [0x05B5] = "letter_arc_bal",
    [0x0999] = "giza_tree_throne",
    [0x099A] = "giza_tree_village",
    [0x099B] = "giza_tree_northbank",
    [0x099C] = "giza_tree_toam",
    [0x099D] = "giza_tree_starfall",
    [0x099E] = "giza_tree_glade",
}

bitwise_flags = {
    [0x0919] = {
        -- [1] = "shrine_of_northeast_wind",
        -- [2] = "shrine_of_east_wind",
        -- [4] = "shrine_of_southeast_wind",
        [8] = "shrine_of_south_wind",
        [16] = "shrine_of_west_wind",
        [32] = "shrine_of_northwest_wind",
        [64] = "weathered_rock_babbling_vale",
        -- [128] = "weathered_rock_skyflung_stone",
    }
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
    code = bool_flags[offset]
    if code then
        print(string.format("Bool flag %s updated to %d", code[1], value))
        if value == 1 then
            local object = Tracker:FindObjectForCode(code)
            if object then
                object.Active = true
            else
                print(string.format("onEventUpdated: could not find object for bool code %s", code))
            end
        end
        return
    end
    local flags = bitwise_flags[offset]
    if flags then
        for bit, code in pairs(flags) do
            local object = Tracker:FindObjectForCode(code)
            local f = value & bit
            if object then
                object.Active = f == bit
            else
                print(string.format("onEventUpdated: could not find object for bitwise code %s (%s)", code, f == bit))
            end
        end
        return
    end
    if offset == 0x0408 then
        -- Ktjn Location
        move_ktjn(value)
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
        [1] = "grimy_rohkenmou",
        [2] = "grimy_filo",
        [3] = "grimy_woman",
        [4] = "grimy_bangaa",
        [5] = "grimy_imperial",
        [6] = "grimy_filo2",
        [7] = "grimy_quest_complete",
    }
    for index, code in pairs(stages) do
        local progress = Tracker:FindObjectForCode(code)
        ---@cast progress JsonItem
        if progress then
            progress.Active = stage >= index
        else
            print(string.format("grimy_questline: could not find object for stage %d", index))
        end
    end
end

function move_ktjn(value)
    local ktjn = Tracker:FindObjectForCode("@Rabanastre/Ktjn")
    print(string.format("Moving Ktjn to location %d", value))
end
