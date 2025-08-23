function show_withered_trees()
    if Tracker:ProviderCountForCode('rainstone') > 0 and 
       Tracker:ProviderCountForCode('silent_urn') > 0 and 
       Tracker:ProviderCountForCode('clan_primer') > 0 and 
       Tracker:ProviderCountForCode('gil_snapper') == 0 then
        return true
    end
    return false
end