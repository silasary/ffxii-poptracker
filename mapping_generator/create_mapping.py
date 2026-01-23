# /// script
# dependencies = [
#   "jsoncomment",
#   "luaparser",
# ]
# ///

import jsoncomment
from lua_tools import lua_to_dict

json = jsoncomment.JsonComment()

class DataPackage:
    location_name_to_id: dict[str, int]
    item_name_to_id: dict[str, int]

# ff12 AP datapackage
with open("./mapping_generator/ff12_datapackage.json") as dp_file:
    datapackage: DataPackage = json.load(dp_file)
# location defs
with open("./locations/locations.json", encoding='utf-8') as loc_defs_file:
    loc_defs = json.load(loc_defs_file)
# party 'starting inventory' locations
with open("./mapping_generator/party_loc.json", encoding='utf-8') as party_loc_file:
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
        loc_id = datapackage['location_name_to_id'].get(loc['name'])
        if loc_id is None:
            print(f"WARNING: No matching location for {loc['name']} in location_name_to_id")
            continue
        loc_code = loc["code"]
        loc_out.write(f"""\t[{loc_id}] = {{"{loc_code}", "toggle"}},\n""")

    loc_out.write("}\n")

### LOCATION HANDLING ###
with open("./mapping_generator/location_overrides.json") as loc_override_file:
    loc_overrides: dict[str,str] = json.load(loc_override_file)

with open("./locations/locations.json") as loc_data_file:
    loc_data = json.load(loc_data_file)

with open("./scripts/archipelago/location_mapping.lua", 'w') as loc_out:

    def write_location(loc_name, truename) -> bool:
        loc_id = datapackage['location_name_to_id'].get(truename) or datapackage['location_name_to_id'].get(f'{truename} (1)')
        if not loc_id:
            name = loc_name if shortname == truename else f"{loc_name} [{truename}]"
            print(f"WARNING: No matching location for {name} in locations.json")
            return False

        loc_out.write(f"""\t[{loc_id}] = {{"{path}/{shortname}"}},\n""")
        return True

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
        found = False
        if count > 1:
            for i in range(1, count + 1):
                truename = loc_overrides.get(shortname, shortname)
                truename = f"{truename} {i}"
                write_location(loc_name, truename)
        else:
            truename = loc_overrides.get(shortname, shortname)
            write_location(loc_name, truename)

    loc_out.write("}\n")

treasure_map = {}
for loc_name, loc_id in datapackage['location_name_to_id'].items():
    if "Treasure" in loc_name:
        region, name = loc_name.split(' - ', 1)
        new_name = '{ "' + f'@Main/{region}/{name}' + '" }'
        treasure_map.setdefault(loc_id, new_name)

with open("./scripts/archipelago/treasure_mapping.lua", 'w') as treasure_out:
    treasure_out.write("return {\n")
    for treasure_id, treasure_name in treasure_map.items():
        treasure_out.write(f"""\t[{treasure_id}] = {treasure_name},\n""")
    treasure_out.write("}\n")
