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
            (defeat_bergan() or ((Tracker:ProviderCountForCode("cactus_flower") > 0) and defeat_vossler()) or earth_tyrant() or aero(BALFONHEIM))
    end,
    [BALFONHEIM] = function()
        return defeat_bergan() or ((Tracker:ProviderCountForCode("cactus_flower") > 0) and defeat_vossler()) or
            earth_tyrant() or (Tracker:ProviderCountForCode(SOUL_WARD_KEY) > 0 and aero(ARCHADES))
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

function aero(dest, allowStrahl, checked)
    if allowStrahl == nil then
        allowStrahl = true
    end

    if allowStrahl and Tracker:ProviderCountForCode(SYSTEMS_ACCESS_KEY) >= DESTINATION_STRAHL_KEYS_NEEDED[dest] then
        return true
    end

    if Tracker:ProviderCountForCode(dest) == 0 then
        return false
    end

    for i, origin in ipairs(DESTINATION_GRAPH[dest]) do
        if Tracker:ProviderCountForCode(origin) > 0 and isOriginAvailable(origin, allowStrahl, checked) then
            return true
        end
    end

    return false
end

function isOriginAvailable(origin, allowStrahl, checked)
    checked = checked or {}
    if checked[origin] then
        return false
    end
    checked[origin] = true

    return DESTINATION_REQS[origin]() or aero(origin, allowStrahl, checked)
end

function aeroNoStrahl(dest)
    return aero(dest, false)
end
