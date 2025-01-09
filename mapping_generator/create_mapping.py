import json

class DataPackage:
    location_name_to_id: dict[str, int]
    item_name_to_id: dict[str, int]

# ff12 AP datapackage
with open("./mapping_generator/ff12_datapackage.json") as dp_file:
    datapackage: DataPackage = json.load(dp_file)
# location defs
with open("./locations/locations.json") as loc_defs_file:
    loc_defs = json.load(loc_defs_file)
# party 'starting inventory' locations
with open("./mapping_generator/party_loc.json") as party_loc_file:
    party_locations: list[dict[str,str]] = json.load(party_loc_file)

### ITEM HANDLING ###

# list of key items (i.e. items the tracker cares about)
with open("./mapping_generator/key_items.json") as key_map_file:
    key_items: list[str] = json.load(key_map_file)
# tracker's items.json
with open("./items/items.json") as item_data_file:
    item_data: list[dict] = json.load(item_data_file)
# 'override' file - for items whose tracker name and AP name don't match
with open("./mapping_generator/item_overrides.json") as override_file:
    item_overrides: dict[str,str] = json.load(override_file)

# get tracker code and type (consumable, toggle) for a given AP item name
def get_codetype_from_name(name: str) -> tuple[str, str]:
    override = item_overrides.get(name)
    # if there's an override, use it
    truename = override if override is not None else name
    # find poptracker code from display name
    item_def = next((x for x in item_data if x['name'] == truename), {})
    item_code = item_def.get('codes')
    item_type = item_def.get('type')
    if item_code is not None:
        return item_code, item_type
    print(f"""DATA PROBLEM: No matching code for "{name}" in items/items.json :( """)
    if override is not None:
        print(f"""\tname overridden to {override} by mapping_generator/item_overrides.json""")
    return "BAD_DATA", "BAD_DATA"

with open("./scripts/archipelago/item_mapping.lua", 'w') as item_out:

    item_out.write("return {\n")

    for item in key_items:
        item_code, item_type = get_codetype_from_name(item)
        item_id = datapackage['item_name_to_id'][item]
        item_out.write(f"""\t[{item_id}] = {{"{item_code}", "{item_type}"}},\n""")

    item_out.write("}")

### PARTY LOCATION HANDLING ###
# basically party members aren't items, so we gotta handle them by
# noticing when their starting items get sent

with open("./scripts/archipelago/loc_mapping_chars.lua", 'w') as loc_out:

    loc_out.write("return {\n")

    for loc in party_locations:
        loc_id = datapackage['location_name_to_id'][loc['name']]
        loc_code = loc["code"]
        loc_out.write(f"""\t[{loc_id}] = {{"{loc_code}", "toggle"}},\n""")

    loc_out.write("}")

### LOCATION HANDLING ###
with open("./mapping_generator/location_overrides.json") as loc_override_file:
    loc_overrides: dict[str,str] = json.load(loc_override_file)

with open("./locations/locations.json") as loc_data_file:
    loc_data = json.load(loc_data_file)

with open("./scripts/archipelago/location_mapping.lua", 'w') as loc_out:

    def write_location(loc_name, truename):
        loc_id = datapackage['location_name_to_id'].get(truename) or datapackage['location_name_to_id'].get(f'{truename} (1)')
        if not loc_id:
            print(f"WARNING: No matching location for {loc_name} in locations.json")
            return

        loc_out.write(f"""\t[{loc_id}] = {{"{path}/{shortname}"}},\n""")      

    loc_out.write("return {\n")
    names = {}
    for area in loc_data:
        area_name = area['name']
        for child in area['children']:
            child_name = child['name']
            for loc in child['sections']:
                loc_name = f'@{area_name}/{child_name}/{loc["name"]}'
                count = loc.get('item_count', 1)
                names[loc_name] = count
    
    for loc_name, count in names.items():
        shortname = loc_name.split('/')[-1]
        path = '/'.join(loc_name.split('/')[0:-1])
        if count > 1:
            for i in range(1, count + 1):
                truename = loc_overrides.get(shortname, shortname)
                truename = f"{truename} {i}"
                write_location(loc_name, truename)
        else:
            truename = loc_overrides.get(shortname, shortname)
            write_location(loc_name, truename)

    loc_out.write("}")
