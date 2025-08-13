HUNTS = {
    'rogue_tomato',
    'thextera',
    'flowering_cactoid',
    'wraith',
    'nidhogg',
    'white_mousse',
    'ring_wyrm',
    'wyvern_lord',
    'marilith',
    'enkelados',
    'croakadile',
    'ixtab',
    'feral_retriever',
    'vorpal_bunny',
    'mindflayer',
    'bloodwing',
    'atomos',
    'roblon',
    'braegh',
    'darksteel',
    'vyraal',
    'lindwyrm',
    'overlord',
    'goliath',
    'deathscythe',
    'deathgaze',
    'diabolos',
    'piscodaemon',
    'wild_malboro',
    'catoblepas',
    'fafnir',
    'pylraster',
    'cluckatrice',
    'rocktoise',
    'orthros',
    'gil_snapper',
    'trickster',
    'antlion',
    'carrot',
    'gilgamesh',
    'belito',
    'behemoth_king',
    'ixion',
    'shadowseer',
    'yiazmat'
}

function hunts_defeated(n)
    local killcount = 0
    for _, huntName in ipairs(HUNTS) do
        killcount = killcount + Tracker:ProviderCountForCode(huntName)
        if killcount >= tonumber(n) then
            return true
        end
    end
    return false
end