---@diagnostic disable: lowercase-global

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

function cerobi_access()	-- Why does this function exist?
    return tchita_uplands() or aero('bal_aero')
end

function ozmone_plain()
    return Tracker:ProviderCountForCode('access_key') >= 2 or Tracker:ProviderCountForCode('rainstone') > 0
end

function henne_mines()
    return ozmone_plain()
end

function paramina_rift()
    if Tracker:ProviderCountForCode('access_key') >= 2 or
        (ozmone_plain() and Tracker:ProviderCountForCode('lentes_tear') > 0) or
        (henne_mines() and espers_controlled(10) and scaled_difficulty(8)) then
        return AccessibilityLevel.Normal
    end
    if henne_mines() and espers_controlled(10) then
        return AccessibilityLevel.SequenceBreak
    end
end

function defeat_bergan()
    if paramina_rift() and Tracker:ProviderCountForCode('sword_of_kings') > 0 and scaled_difficulty(3) then
		return AccessibilityLevel.Normal
	end
	if paramina_rift() and Tracker:ProviderCountForCode('sword_of_kings') > 0 then
		return AccessibilityLevel.SequenceBreak
	end
end

function earth_tyrant()
    if Tracker:ProviderCountForCode('wind_globe') > 0 and Tracker:ProviderCountForCode('windvane') > 0 and defeat_vossler() then
        if  scaled_difficulty(4) then
            return AccessibilityLevel.Normal
        else
            return AccessibilityLevel.SequenceBreak
        end
    end
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
    if Tracker:ProviderCountForCode('access_key') > 0 or ghis() or (Tracker:ProviderCountForCode('rainstone') > 0 and scaled_difficulty(3)) then
        return AccessibilityLevel.Normal
    end
    if Tracker:ProviderCountForCode('rainstone') > 0 then
        return AccessibilityLevel.SequenceBreak
    end
end

function tchita_uplands()
    if defeat_bergan() == AccessibilityLevel.Normal or 
        (Tracker:ProviderCountForCode('cactus_flower') > 0 and defeat_vossler() == AccessibilityLevel.Normal) or 
        earth_tyrant() == AccessibilityLevel.Normal or
        (Tracker:ProviderCountForCode('soul_ward_key') > 0 and aero('arc_aero') and scaled_difficulty(4)) or
        cid2() == AccessibilityLevel.Normal or
        (aero('bal_aero') and scaled_difficulty(5)) then
		    return AccessibilityLevel.Normal
    end
    if (Tracker:ProviderCountForCode('cactus_flower') > 0 and defeat_vossler() == AccessibilityLevel.SequenceBreak) or
		(Tracker:ProviderCountForCode('soul_ward_key') > 0 and aero('arc_aero')) or
		earth_tyrant() == AccessibilityLevel.SequenceBreak or
		defeat_bergan() == AccessibilityLevel.SequenceBreak  or
        cid2() == AccessibilityLevel.SequenceBreak or
        aero('bal_aero') then 
			return AccessibilityLevel.SequenceBreak
	end
end

function hunt_club_start()
    if tchita_uplands() == AccessibilityLevel.Normal and Tracker:ProviderCountForCode('shelled_trophy') > 0 and scaled_difficulty(6) then
		return AccessibilityLevel.Normal
	end
	if tchita_uplands() and Tracker:ProviderCountForCode('shelled_trophy') > 0 then
		return AccessibilityLevel.SequenceBreak
	end
end

function defeat_vossler()
    return sandseas()
end

function dawn_shard()  -- Why is this a function?
    return Tracker:ProviderCountForCode('dawn_shard') > 0
end

function archades()
    if aero('arc_aero') or (Tracker:ProviderCountForCode('soul_ward_key') > 0 and sochen_cave_palace() == AccessibilityLevel.Normal) then
        return AccessibilityLevel.Normal
    end
    if sochen_cave_palace() == AccessibilityLevel.SequenceBreak then
		return AccessibilityLevel.SequenceBreak
	end
end

function sochen_cave_palace()
    if Tracker:ProviderCountForCode('soul_ward_key') > 0 and (tchita_uplands() == AccessibilityLevel.Normal or aero('arc_aero')) and scaled_difficulty(4) then
        return AccessibilityLevel.Normal 
    end
    if Tracker:ProviderCountForCode('soul_ward_key') > 0 and (tchita_uplands() == AccessibilityLevel.SequenceBreak or aero('arc_aero')) then
		return AccessibilityLevel.SequenceBreak
	end
end

function draklor_laboratory()
	if (Tracker:ProviderCountForCode('pw_chop') >= 3 or Tracker:ProviderCountForCode('sw_chop') > 0) then
		if archades() == AccessibilityLevel.SequenceBreak then
			return AccessibilityLevel.SequenceBreak
		elseif archades() then
			return AccessibilityLevel.Normal
		end
	end
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

    if swordCount >= 1 and stoneCount >= 2 and has_n_system_access_keys(2) and has_n_black_orbs(3) then
	    if scaled_difficulty(7) then
            return AccessibilityLevel.Normal
        else
            return AccessibilityLevel.SequenceBreak
        end
    end
end

function defeat_cid()
    return draklor_laboratory() and Tracker:ProviderCountForCode('lab_access_card') > 0
end
