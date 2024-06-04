ESPERS = {
    "belias",
    "chaos",
    "zalera",
    "zeromus",
    "hashmal",
    "ultima",
    "exodus",
    "cuchulainn",
    "shemhazai",
    "adrammelech",
    "famfrit",
    "mateus",
    "zodiark"
}

function espers_controlled(n)
    local controlled = 0
    for _, esper in ipairs(ESPERS) do
        controlled = controlled + Tracker:ProviderCountForCode(esper)
    end
    return controlled >= tonumber(n)
end