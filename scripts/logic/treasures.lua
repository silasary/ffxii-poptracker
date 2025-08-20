Treasures = {}

function chest_visibility(name)
    if Tracker:ProviderCountForCode('place_treasures') == 0 then
        return false
    end
    if #Treasures == 0 then
        return true
    end
    for _, treasure in ipairs(Treasures) do
        if treasure == name then
            return true
        end
    end
    return false
end