function scaled_difficulty(n)
    if Tracker:ProviderCountForCode('scaled') == 0 then
        return 1
    end

    local char_count = get_char_count()
    local diff = tonumber(n)
    local has_second_board = Tracker:ProviderCountForCode('second_board') > 0
    if diff >= 7 then
        return char_count >= 6 and has_second_board
    end
    if diff >= 5 then
        return char_count >= 5 and has_second_board
    end
    if diff >= 4 then
        return char_count >= 4
    end
    if diff >= 3 then
        return char_count >= 3
    end
    return 1
end

function get_char_count()
    return Tracker:ProviderCountForCode('vaan') + Tracker:ProviderCountForCode('balthier') +
        Tracker:ProviderCountForCode('fran') + Tracker:ProviderCountForCode('basch') +
        Tracker:ProviderCountForCode('ashe') +
        Tracker:ProviderCountForCode('penelo') + Tracker:ProviderCountForCode('guest')
end

function ozmone_plain()
    return Tracker:ProviderCountForCode('access_key') >= 2 or Tracker:ProviderCountForCode('rainstone') > 0
end

function paramina_rift()
    return Tracker:ProviderCountForCode('access_key') >= 2 or
        (ozmone_plain() and Tracker:ProviderCountForCode('lentes_tear'))
end

function defeat_bergen()
    return paramina_rift() and Tracker:ProviderCountForCode('sword_of_kings') > 0
end

function earth_tyrant()
    return Tracker:ProviderCountForCode('wind_globe') > 0 and Tracker:ProviderCountForCode('windvane') > 0
end

function leviathan()
    return
        (Tracker:ProviderCountForCode('basch') > 0 or Tracker:ProviderCountForCode('goddess_magicite') > 0) and
        aero('bhu_aero')
end

function ghis()
    return Tracker:ProviderCountForCode('brig_key') > 0 and leviathan()
end

function sandseas()
    return Tracker:ProviderCountForCode('rainstone') > 0 or Tracker:ProviderCountForCode('access_key') > 0 or ghis()
end

function tchita_uplands()
    return defeat_bergen() or Tracker:ProviderCountForCode('cactus_flower') > 0 or earth_tyrant() or
        (Tracker:ProviderCountForCode('soul_ward_key') > 0 and aero('arc_aero')) or aero('bal_aero')
end

function hunt_club_start()
    return tchita_uplands()
end

function defeat_vossler()
    return Tracker:ProviderCountForCode('dawn_shard') > 0 and sandseas()
end
