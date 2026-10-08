from collections import Counter
import glob
import os
import sys
import re
from typing import Any

sys.path.append("C:\\Users\\Clock\\projects\\Archipelago_ff12_openworld")
import ModuleUpdate
ModuleUpdate.requirements_files.add(os.path.join(os.path.dirname(__file__), "requirements.txt"))
# ModuleUpdate.update()

import jsoncomment
import from_lambda
import lua_tools
from rule_builder.rules import Rule, And, Or, Has, CanReachRegion, True_, False_

json = jsoncomment.JsonComment()

without_parentheses_re = re.compile(r'^(.*?)\s*\((\d*)\)\s*$')
pt_items = []

class ItemNotFound(ValueError):
    def __init__(self, item_name: str, *args: Any) -> None:
        self.item_name = item_name
        super().__init__(*args)



def main() -> None:
    from worlds.ff12_open_world.Locations import location_data_table
    from worlds.ff12_open_world.Items import item_data_table
    from worlds.ff12_open_world.Events import event_data_table
    from worlds.ff12_open_world.Rules import rule_data_table

    event_items = [e.item for e in event_data_table.values()]


    os.chdir(os.path.dirname(os.path.dirname(__file__)))

    with open("./scripts/archipelago/location_mapping.lua", 'r', encoding='utf-8') as lua_file:
        location_mapping = lua_tools.lua_to_dict("./scripts/archipelago/location_mapping.lua")


    with open("./locations/locations.json", 'r') as loc_file:
        pt_locations = json.load(loc_file)

    for file in glob.glob("./items/*.json"):
        with open(file, 'r') as f:
            pt_items.extend(json.load(f))

    with open("./mapping_generator/lambda_to_access_rule.json", 'r') as f:
        lambda_to_access_rule_full = json.load(f)

    lambda_to_access_rule = lambda_to_access_rule_full.get("needed", {}) | lambda_to_access_rule_full.get("inactive", {}) |  lambda_to_access_rule_full.get("active", {})
    lambda_counter: Counter[str] = Counter()
    partials: dict[str, str | None] = lambda_to_access_rule_full.get("partials", {}) | lambda_to_access_rule_full.get("needed_partials", {})

    regions = {v['name']: v for v in pt_locations[0]['children']}
    all_locations = {}
    all_names = []
    hosted_items: dict[str, dict] = {}

    for region in pt_locations[0]['children']:
        for section in region.setdefault('sections', []):
            all_locations[section['name']] = region['name']
            if 'hosted_item' in section:
                hosted_items[section['hosted_item']] = section

    todays_treasures = None
    warned_regions = set()
    check_counter: Counter[str] = Counter()

    for name, loc in location_data_table.items():
        region_name = loc.region
        shortname = get_shortname(name, region_name)

        if match := without_parentheses_re.match(shortname):
            shortname = match.group(1)

        shortername = shortname
        if shortname.endswith(" Reward"):
            shortername = shortname[:-7]
        if shortname == "Clan Boss: Daedulus":
            # BAAARTZ!
            shortname = "Clan Boss: Daedalus"

        region = regions.get(region_name)
        if not region:
            if region_name not in warned_regions:
                print(f"WARNING: No matching region for {region_name} in locations.json")
                warned_regions.add(region_name)
            continue
        pt_loc = None
        for section in region['sections']:
            if section['name'] in [name, shortname, shortername]:
                pt_loc = section
                break

        if not pt_loc:
            if shortname in all_locations:
                found_region = all_locations[shortname]
                print(f"WARNING: Location {shortname} found in region {found_region}, expected {region_name}")
                pt_loc = next(section for section in regions[found_region]['sections'] if section['name'] == shortname)
                regions[found_region]['sections'].remove(pt_loc)
                region['sections'].append(pt_loc)
            elif "Treasure" in shortname and todays_treasures in [region_name, None]:
                pt_loc = {
                    "name": shortname,
                    "visibility_rules": [f"$chest_visibility|{name}"],
                    "access_rules": [],
                }
                region['sections'].append(pt_loc)
                todays_treasures = region_name
            elif loc.address in location_mapping:
                pt_name = location_mapping[loc.address]
                print(f"{shortname} is mapped to {pt_name}")
                continue
            else:
                if 'Starting Items' in shortname:
                    continue
                if 'Pinewood Chop' in shortname:
                    continue
                if 'Black Orb' in shortname:
                    continue
                if name.endswith((" (2)", " (3)")):
                    continue
                if not warned_regions:
                    print(f"WARNING: No matching location for {name} in region {region_name} in locations.json")
                if todays_treasures in [region_name, None]:
                    pt_loc = {
                        "name": shortname,
                        "access_rules": [],
                    }
                    region['sections'].append(pt_loc)
                    todays_treasures = region_name
                    print(f"Creating @Main/{region_name}/{shortname}")
                continue

        access_rule: str | None = None
        existing_rules = pt_loc.get('access_rules', [""])
        if existing_rules:
            existing_rule = existing_rules[0]
        else:
            existing_rule = ""
        events = [i.strip() for i in existing_rule.split(',') if i in hosted_items]
        event_reqs = []
        for e in events:
            e_loc = hosted_items[e]
            e_rules = e_loc.get('access_rules', [])
            for er in e_rules:
                event_reqs.extend(er.split(','))

        events = sorted(set(events))
        event_reqs = sorted(set(event_reqs))

        difficulty = loc.difficulty
        rule = rule_data_table.get(name)
        if isinstance(rule, Rule):
            rule_str = str(rule)
        else:
            rulep = from_lambda.parse_lambda(rule)
            rule_str = from_lambda.to_str(rulep)
        lambda_counter[rule_str] += 1
        access_rule = lambda_to_access_rule.setdefault(rule_str, None)
        if access_rule is None and isinstance(rule, Rule):
            try:
                access_rule = rb_to_access_rule(rule, partials, lambda_counter)
                lambda_to_access_rule[rule_str] = access_rule
            except ItemNotFound as e:
                if e.item_name in item_data_table:
                    print(f"Item not found for rule {rule}: {e}")
                    event = False
                elif e.item_name in event_items:
                    print(f"Event not found for rule {rule}: {e}")
                    event = True
                else:
                    print(f"Wat not found for rule {rule}: {e}")

                pass

        if access_rule is not None and difficulty:
            access_rule += f',[$scaled_difficulty|{difficulty}]'
            access_rule = access_rule.strip(',')

        if access_rule and len(region.get('access_rules', [])) == 1:
            region_reqs = region['access_rules'][0].split(',')
            access_rule_reqs = access_rule.split(',')
            pruned_reqs = [req for req in access_rule_reqs if req not in region_reqs]
            access_rule = ','.join(pruned_reqs)
        pruned_events = [req for req in events if req not in access_rule.split(',')] if access_rule else events
        if access_rule and pruned_events:
            pruned_reqs = [req for req in access_rule.split(',') if req not in event_reqs]
            access_rule = ','.join(pruned_reqs + pruned_events)
        if access_rule is not None:
            if pt_loc.get('access_rules', []):
                if pt_loc['access_rules'][0] != access_rule:
                    print(f'Updating access rule for {name} from "{pt_loc["access_rules"][0]}" to "{access_rule}"')
                    pt_loc['access_rules'][0] = access_rule
            else:
                pt_loc['access_rules'] = [access_rule]
        if " Treasure " in name:
            visibility_rule = f"$chest_visibility|{name}"
            py_visibility_rules = pt_loc.setdefault('visibility_rules', [])
            if visibility_rule not in py_visibility_rules:
                py_visibility_rules.append(visibility_rule)
        mapping = location_mapping.get(loc.address)
        ref = "@Main/" + region_name + "/" + pt_loc['name']
        if mapping:
            mapping[0] = ref
        else:
            location_mapping[loc.address] = [ref]
        check_counter[ref] += 1
        # if check_counter[ref] != 1:
        #     pt_loc['item_count'] = check_counter[ref]
        pass


    for region in pt_locations[0]['children']:
        for section in region['sections']:
            all_names.append("Main/" + region['name'] + "/" + section['name'])
        pass

    lambda_to_access_rule_full = {
        "partials": {},
        "active": {},
        "needed": {},
        "inactive": {},
        "needed_partials": {},
    }
    for rule_str, access_rule in lambda_to_access_rule.items():
        count = lambda_counter[rule_str]
        if count > 0 and access_rule is not None:
            lambda_to_access_rule_full["active"][rule_str] = access_rule
        elif count > 0:
            lambda_to_access_rule_full["needed"][rule_str] = access_rule
        elif access_rule is not None:
            lambda_to_access_rule_full["inactive"][rule_str] = access_rule

    for partial, access_rule in partials.items():
        count = lambda_counter.get(partial, 0)
        if access_rule is not None:
            lambda_to_access_rule_full["partials"][partial] = access_rule
        elif count > 0:
            lambda_to_access_rule_full["needed_partials"][partial] = access_rule

    with open("./mapping_generator/lambda_to_access_rule.json", 'w') as f:
        json.dump(lambda_to_access_rule_full, f, indent=4, sort_keys=True)
        f.write('\n')

    location_mapping = {int(k): v for k, v in sorted(location_mapping.items(), key=lambda item: item[0])}
    with open("./scripts/archipelago/location_mapping.lua", 'w', encoding='utf-8') as lua_file:
        lua_file.write("return {\n")
        for address, mapping in location_mapping.items():
            lua_file.write(f"\t[{address}] = ")
            lua_file.write("{")
            lua_file.write(", ".join(f'"{m}"' for m in mapping))
            lua_file.write("},\n")
        lua_file.write("}\n")

    validate(all_names, hosted_items)

    event_items = []
    with open('./items/event_items.json') as f:
        event_items.extend(json.load(f))
    with open('./items/hunts.json') as f:
        event_items.extend(json.load(f))

    for event in event_items:
        if event['codes'] not in hosted_items.keys():
            print(f"{event['codes']} is not hosted")
            regions['Initial']['sections'].append(
                {
                    "name": event['name'],
                    "access_rules": [],
                    # "visibility_rules": [],
                    "hosted_item": event['codes'],
                }
            )
    with open("./locations/locations.json", 'w') as loc_file:
        json.dump(pt_locations, loc_file, indent=2)
        loc_file.write('\n')

def find_item_code(name: str) -> str:
    for item in pt_items:
        if item['name'] == name:
            return item['codes']

    raise ItemNotFound(name, f"Item with name '{name}' not found")


def rb_to_access_rule(rule: Rule, partials: dict[str, str | None], lambda_counter: Counter[str]) -> str | None:
    # if partials.get(str(rule)):
    #     return partials[str(rule)]
    if isinstance(rule, Has):
        assert isinstance(rule.item_name, str)
        assert isinstance(rule.count, int)
        if rule.count == 1:
            try:
                access_rule = find_item_code(rule.item_name)
            except ItemNotFound as e:
                p = partials.setdefault(str(rule), None)
                lambda_counter[str(rule)] += 1
                if p:
                    return p
                raise
            return access_rule
        elif rule.count > 1:
            func_partial_key = f"Has({rule.item_name}, count={{COUNT}})"
            lambda_counter[func_partial_key] += 1
            func_partial = partials.setdefault(func_partial_key, None)
            if func_partial:
                return func_partial.replace("{COUNT}", str(rule.count))



    if isinstance(rule, True_):
        return ""

    if isinstance(rule, And):
        resolved = [rb_to_access_rule(subrule, partials, lambda_counter) for subrule in rule.children]
        if any(r is None for r in resolved):
            return None
        return ",".join(filter(None, resolved))

    partial = partials.setdefault(str(rule), None)
    lambda_counter[str(rule)] += 1
    if partial is not None:
        return partial

    return None

def validate(all_names, hosted_items):
    referenced = {}
    add_to_world_map = []
    add_to_map_select = []
    remove_from_map_select = []

    for file in glob.glob("*.json", root_dir="locations"):
        if file == "locations.json":
            continue
        with open(os.path.join("locations", file), 'r') as loc_file:
            ref_locations = json.load(loc_file)
        changed = False
        queue = ref_locations.copy()
        while queue:
            pt_loc = queue.pop()
            if "ref" in pt_loc:
                if pt_loc['ref'] not in all_names:
                    shortname = pt_loc['ref'].split('/')[-1]
                    found = next((name for name in all_names if name.endswith('/' + shortname)), None)
                    if found:
                        old = pt_loc['ref']
                        pt_loc['ref'] = found
                        print(f'Updated reference {old} to {found} in {file}')
                        changed = True
                    elif file == "map_select.json":
                        remove_from_map_select.append(pt_loc['ref'])
                    else:
                        print(f'WARNING: Reference {pt_loc["ref"]} not found in locations!')
                else:
                    referenced.setdefault(pt_loc['ref'], []).append(file)
            elif "hosted_item" in pt_loc:
                hosted_items.setdefault(pt_loc['hosted_item'], pt_loc)

            if 'children' in pt_loc:
                queue.extend(pt_loc['children'].copy())
            if 'sections' in pt_loc:
                queue.extend(pt_loc['sections'].copy())

        if changed:
            with open(os.path.join("locations", file), 'w') as loc_file:
                json.dump(ref_locations, loc_file, indent=2)
                loc_file.write('\n')

    for name in all_names:
        if "world_map.json" not in referenced.get(name, []):
            add_to_world_map.append(name)
        elif len(referenced[name]) != len(set(referenced[name])):
            # print(f'WARNING: Location {name} referenced in {referenced[name]}')
            pass
        elif len(referenced[name]) == 1 and '/Clan Hall/' not in name:
            add_to_map_select.append(name)
        elif len(referenced[name]) == 0:
            print(f'WARNING: Location {name} not referenced anywhere')
        elif len(referenced[name]) > 2 and "map_select.json" in referenced[name]:
            remove_from_map_select.append(name)
        elif len(referenced[name]) == 2 and "map_select.json" in referenced[name] and '/Clan Hall/' in name:
            remove_from_map_select.append(name)

    if add_to_world_map:
        with open(os.path.join("locations", "world_map.json"), 'r') as loc_file:
            world_map = json.load(loc_file)
        world_map_sections = {loc['name']: loc.setdefault('sections',[]) for loc in world_map}
        default_section = world_map_sections.get("World Map", [])
        for name in add_to_world_map:
            name_parts = name.split('/')
            shortname = name_parts[-1]
            print(f'Adding {name} as {shortname} to world_map.json')
            sections = world_map_sections.get(name_parts[1], default_section)
            sections.append({
                "name": shortname,
                "ref": name,
            })
        with open(os.path.join("locations", "world_map.json"), 'w') as loc_file:
            json.dump(world_map, loc_file, indent=2)
            loc_file.write('\n')

    if add_to_map_select:
        with open(os.path.join("locations", "map_select.json"), 'r') as loc_file:
            map_select = json.load(loc_file)
        map_select_sections = map_select[0].setdefault('sections', [])
        for name in add_to_map_select:
            shortname = name.split('/')[-1]
            print(f'Adding {name} as {shortname} to map_select.json')
            map_select_sections.append({
                "name": shortname,
                "ref": name,
            })
        with open(os.path.join("locations", "map_select.json"), 'w') as loc_file:
            json.dump(map_select, loc_file, indent=2)
            loc_file.write('\n')

    if remove_from_map_select:
        with open(os.path.join("locations", "map_select.json"), 'r') as loc_file:
            map_select = json.load(loc_file)
        map_select_sections = map_select[0].setdefault('sections', [])
        changed = False
        for name in remove_from_map_select:
            shortname = name.split('/')[-1]
            for sections in map_select_sections:
                if sections['ref'] == name:
                    print(f'Removing {name} from map_select.json')
                    map_select_sections.remove(sections)
                    changed = True
                    break
        if changed:
            with open(os.path.join("locations", "map_select.json"), 'w') as loc_file:
                json.dump(map_select, loc_file, indent=2)
                loc_file.write('\n')


def get_shortname(name, region_name):
    shortname = name
    if name.startswith(f'{region_name} - '):
        shortname = name[len(region_name) + 3 :]
    if name.startswith("Rabanastre - Tomaj"):
        shortname = "Tomaj"
    return shortname

if __name__ == "__main__":
    main()
