HUNT_MAPPING = {
    [0] = "Defeat Rogue Tomato",
    [1] = "Defeat Thextera",
    [2] = "Defeat Flowering Cactoid",
    [3] = "Defeat Wraith",
    [4] = "Defeat Nidhogg",
    [5] = "Defeat White Mousse",
    [6] = "Defeat Ring Wyrm",
    [7] = "Defeat Wyvern Lord",
    [8] = "Defeat Marilith",
    [9] = "Defeat Enkelados",
    [10] = "Defeat Croakadile",
    [11] = "Defeat Ixtab",
    [12] = "Defeat Feral Retriever",
    [13] = "Defeat Vorpal Bunny",
    [14] = "Defeat Mindflayer",
    [15] = "Defeat Bloodwing",
    [16] = "Defeat Atomos",
    [17] = "Defeat Roblon",
    [18] = "Defeat Orthros",
    [19] = "Defeat Darksteel",
    [20] = "Defeat Vyraal",
    [21] = "Defeat Lindwyrm",
    [22] = "Defeat Overlord",
    [23] = "Defeat Gil Snapper",
    [24] = "Defeat Deathscythe",
    [25] = "Defeat Diabolos",
    [26] = "Defeat Piscodaemon",
    [27] = "Defeat Wild Malboro",
    [28] = "Defeat Catoblepas",
    [29] = "Defeat Carrot",
    [30] = "Defeat Gilgamesh",
    [31] = "Defeat Behemoth King",
    [32] = "Defeat Trickster",
    [33] = "Defeat Rocktoise",
    [34] = "Defeat Antlion",
    [35] = "Defeat Myath",
    [36] = "Defeat Braegh",
    [37] = "Defeat Antlion",
    [38] = "Defeat Fafnir",
    [39] = "Defeat Crystal Knight",
    [40] = "Defeat Omega Mark XII",
    [41] = "Defeat Yiazmat",
}

HUNT_STAGE_MAPPING = {
    [0] = 50,
    [1] = 70,
    [2] = 50,
    [3] = 50,
    [4] = 70,
    [5] = 50,
    [6] = 70,
    [7] = 70,
    [8] = 70,
    [9] = 70,
    [10] = 70,
    [11] = 70,
    [12] = 70,
    [13] = 70,
    [14] = 70,
    [15] = 70,
    [16] = 70,
    [17] = 70,
    [18] = 100,
    [19] = 70,
    [20] = 70,
    [21] = 70,
    [22] = 70,
    [23] = 70,
    [24] = 70,
    [25] = 70,
    [26] = 70,
    [27] = 70,
    [28] = 70,
    [29] = 70,
    [30] = 70,
    [31] = 70,
    [32] = 70,
    [33] = 70,
    [34] = 90,
    [35] = 70,
    [36] = 70,
    [37] = 90,
    [38] = 70,
    [39] = 70,
    [40] = 100,
    [41] = 100,
}
function on_hunt_updated(hunt_id, stage)
    -- IDs are zero-indexed, but are mostly in order of appearance in the game
    
    -- hunt 4: Stage 70, Niddhogg dead
    -- hunt 5: Stage 50, White Mousse dead
    -- hunt 6: Stage 70, Ring Wyrm dead
    -- hunt 11 Stage 70, Ixtab dead
    -- hunt 12 Stage 70, Feral Retriever dead
    -- hunt 15 Stage 70, Bloodwing dead
    -- hunt 19 Stage 100, Darksteel dead
    -- hunt 33 Stage 70, Rocktoise dead
    -- hunt 34 Stage 70, Orthros dead
    -- hunt 37 Stage 90, Antlion dead

end