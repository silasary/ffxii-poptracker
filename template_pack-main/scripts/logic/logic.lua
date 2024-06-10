function scaled_difficulty(n)
    if Tracker:ProviderCountForCode('character_scaled_depth') == 0 then
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

function defeat_bergan()
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
    return defeat_bergan() or Tracker:ProviderCountForCode('cactus_flower') > 0 or earth_tyrant() or
        (Tracker:ProviderCountForCode('soul_ward_key') > 0 and aero('arc_aero')) or aero('bal_aero')
end

function hunt_club_start()
    return tchita_uplands() and Tracker:ProviderCountForCode('shelled_trophy') > 0
end

function defeat_vossler()
    return Tracker:ProviderCountForCode('dawn_shard') > 0 and sandseas()
end

function archades()
    return aero('arc_aero') or (Tracker:ProviderCountForCode('soul_ward_key') > 0 and sochen_cave_palace())
end

function sochen_cave_palace()
    return Tracker:ProviderCountForCode('soul_ward_key') > 0 and (tchita_uplands() or archades())
end

function draklor_laboratory()
    return (Tracker:ProviderCountForCode('pw_chop') >= 3 or Tracker:ProviderCountForCode('sw_chop') > 0) and archades()
end

function has_n_chops(n)
    return Tracker:ProviderCountForCode('pw_chop') >= tonumber(n)
end

function has_n_system_access_keys(n)
    return Tracker:ProviderCountForCode('access_key') >= tonumber(n)
end

function has_n_black_orbs(n)
    return Tracker:ProviderCountForCode('black_orb') >= tonumber(n)
end

function all_fragments()
    return Tracker:ProviderCountForCode('fragments') == 3
end

function cid2()
    local swordCount = Tracker:ProviderCountForCode('sword_of_kings') + Tracker:ProviderCountForCode('treaty_blade')
    local stoneCount = Tracker:ProviderCountForCode('goddess_magicite') + Tracker:ProviderCountForCode('nethicite') +
        Tracker:ProviderCountForCode('dawn_shard')

    return swordCount >= 1 and stoneCount >= 2
end

function defeat_cid()
    return draklor_laboratory() and Tracker:ProviderCountForCode('lab_access_card') > 0
end
