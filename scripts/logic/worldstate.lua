function show_shrine_of_south_wind()
    return Tracker:ProviderCountForCode('weathered_rock_babbling_vale') == 0
end

function show_shrine_of_northwest_wind()
    return Tracker:ProviderCountForCode('weathered_rock_babbling_vale') == 1
end

function at_map_id(id)
    if Tracker:FindObjectForCode('map_id').AcquiredCount == tonumber(id) then
        return true
    end
    return false
end

function blue()
    -- Silly little rule to make things ^$blue
    return AccessibilityLevel.Inspect
end
