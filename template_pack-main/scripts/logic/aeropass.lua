RABANASTRE = 'rab_aero'
NALBINA = 'nal_aero'
BHUJERBA = 'bhu_aero'
ARCHADES = 'arc_aero'
BALFONHEIM = 'bal_aero'

SYSTEMS_ACCESS_KEY = 'access_key'
SOUL_WARD_KEY = 'soul_ward_key'


DESTINATION_REQS = {
    [RABANASTRE] = function()
        return true
    end,
    [NALBINA] = function()
        return true
    end,
    [BHUJERBA] = function()
        return false
    end,
    [ARCHADES] = function()
        return Tracker:ProviderCountForCode(SOUL_WARD_KEY) > 0 and
            (defeat_bergan() or Tracker:ProviderCountForCode("cactus_flower") > 0 or earth_tyrant() or aero(BALFONHEIM))
    end,
    [BALFONHEIM] = function()
        return defeat_bergan() or Tracker:ProviderCountForCode("cactus_flower") > 0 or earth_tyrant() or
            (Tracker:ProviderCountForCode(SOUL_WARD_KEY) > 0 and aero(ARCHADES))
    end
}

DESTINATION_GRAPH = {
    [RABANASTRE] = { NALBINA, BHUJERBA, ARCHADES },
    [NALBINA] = { RABANASTRE, ARCHADES, BALFONHEIM },
    [BHUJERBA] = { RABANASTRE, BALFONHEIM },
    [ARCHADES] = { RABANASTRE, NALBINA, BALFONHEIM },
    [BALFONHEIM] = { NALBINA, ARCHADES, BHUJERBA }
}

DESTINATION_STRAHL_KEYS_NEEDED = {
    [RABANASTRE] = 1,
    [NALBINA] = 1,
    [BHUJERBA] = 1,
    [ARCHADES] = 3,
    [BALFONHEIM] = 3
}

function aero(dest, allowStrahl)
    if allowStrahl == nil then
        allowStrahl = true
    end
    if allowStrahl then
        return Tracker:ProviderCountForCode(SYSTEMS_ACCESS_KEY) >= DESTINATION_STRAHL_KEYS_NEEDED[dest]
    end

    if Tracker:ProviderCountForCode(dest) == 0 then
        return false
    end

    for i, origin in ipairs(DESTINATION_GRAPH[dest]) do
        if Tracker:ProviderCountForCode(origin) > 0 and isOriginAvailable(origin, allowStrahl) then
            return true
        end
    end

    return false
end

function isOriginAvailable(origin, allowStrahl)
    return DESTINATION_REQS[origin]() or aero(origin, allowStrahl)
end

function aeroNoStrahl(dest)
    return aero(dest, false)
end
