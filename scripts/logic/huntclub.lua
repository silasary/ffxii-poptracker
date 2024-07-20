TROPHY_RARES = {
    'gavial',
    'ishteen',
    'kaiser_wolf',
    'terror_tyrant',
    'nazarnir',
    'alteci',
    'disma',
    'bull_chocobo',
    'victanir',
    'zombie_lord',
    'dheed',
    'rageclaw',
    'arioch',
    'vorres',
    'killbug',
    'melt',
    'biding_mantis',
    'dreadguard',
    'crystal_knight',
    'ancbolder',
    'myath',
    'skullash',
    'kris',
    'grimalkin',
    'wendice',
    'anubys',
    'bluesang',
    'aspidochelon',
    'abelisk',
    'avenger',
    'thalassinon'
}

function hunt_club_kills(n)
    local killcount = 0
    for i, rareName in ipairs(TROPHY_RARES) do
        killcount = killcount + Tracker:ProviderCountForCode(rareName)
    end
    return killcount >= tonumber(n)
end
