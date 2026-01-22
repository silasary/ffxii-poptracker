import glob
import os
import sys
import jsoncomment
import from_lambda
import re

json = jsoncomment.JsonComment()
sys.path.append("D:\\source\\repos\\Archipelago.worktrees\\ff12_openworld")

without_parentheses_re = re.compile(r'^(.*?)\s*\((\d*)\)\s*$')

def main() -> None:
    from worlds.ff12_open_world.Locations import location_data_table
    from worlds.ff12_open_world.Rules import rule_data_table

    with open("./locations/locations.json", 'r') as loc_file:
        pt_locations = json.load(loc_file)

    with open("./mapping_generator/lambda_to_access_rule.json", 'r') as f:
        lambda_to_access_rule = json.load(f)

    regions = {v['name']: v for v in pt_locations[0]['children']}
    all_locations = {}
    all_names = []
    for region in pt_locations[0]['children']:
        for section in region['sections']:
            all_locations[section['name']] = region['name']
    todays_treasures = None
    warned_regions = set()

    for name, loc in location_data_table.items():
        region_name = loc.region
        shortname = get_shortname(name, region_name)


        if match := without_parentheses_re.match(shortname):
            shortname = match.group(1)

        shortername = shortname
        if shortname.endswith(" Reward"):
            shortername = shortname[:-7]

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
            else:
                if not warned_regions:
                    print(f"WARNING: No matching location for {name} in region {region_name} in locations.json")
                continue

        access_rule: str | None = None

        difficulty = loc.difficulty
        rule = rule_data_table.get(name)
        rulep = from_lambda.parse_lambda(rule)
        rule_str = from_lambda.to_str(rulep)
        access_rule = lambda_to_access_rule.setdefault(rule_str, None)
        if access_rule is not None and difficulty:
            access_rule += f',[$scaled_difficulty|{difficulty}]'
            access_rule = access_rule.strip(',')

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

    for region in pt_locations[0]['children']:
        for section in region['sections']:
            all_names.append("Main/" + region['name'] + "/" + section['name'])
        pass

    with open("./mapping_generator/lambda_to_access_rule.json", 'w') as f:
        json.dump(lambda_to_access_rule, f, indent=4)
        f.write('\n')
    with open("./locations/locations.json", 'w') as loc_file:
        json.dump(pt_locations, loc_file, indent=2)
        loc_file.write('\n')
    validate(all_names)

def validate(all_names):
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
                    else:
                        print(f'WARNING: Reference {pt_loc["ref"]} not found in locations!')


            if 'children' in pt_loc:
                queue.extend(pt_loc['children'].copy())
            if 'sections' in pt_loc:
                queue.extend(pt_loc['sections'].copy())

        if changed:
            with open(os.path.join("locations", file), 'w') as loc_file:
                json.dump(ref_locations, loc_file, indent=2)
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
