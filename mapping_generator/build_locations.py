import sys
import jsoncomment
import dis
import from_lambda

json = jsoncomment.JsonComment()
sys.path.append("D:\\source\\repos\\Archipelago.worktrees\\ff12_openworld")



def main():
    from worlds.ff12_open_world.Locations import location_data_table
    from worlds.ff12_open_world.Rules import rule_data_table

    with open("./locations/locations.json", 'r') as loc_file:
        pt_locations = json.load(loc_file)

    with open("./mapping_generator/lambda_to_access_rule.json", 'r') as f:
        lambda_to_access_rule = json.load(f)

    regions = {v['name']: v for v in pt_locations[0]['children']}
    pass
    for name, loc in location_data_table.items():
        region_name = loc.region
        shortname = name
        if name.startswith(f'{region_name} - '):
            shortname = name[len(region_name) + 3 :]
        region = regions.get(region_name)
        if not region:
            print(f"WARNING: No matching region for {region_name} in locations.json")
            continue
        pt_loc = None
        for section in region['sections']:
            if section['name'] in [name, shortname]:
                pt_loc = section
                break

        if not pt_loc:
            print(f"WARNING: No matching location for {name} in region {region_name} in locations.json")
            continue
        access_rule = None

        difficulty = loc.difficulty
        rule = rule_data_table.get(name)
        rulep = from_lambda.parse_lambda(rule)
        rule_str = from_lambda.to_str(rulep)
        if lambda_to_access_rule.setdefault(rule_str, ""):
            access_rule = lambda_to_access_rule[rule_str]
            if difficulty:
                 access_rule += f',[$scaled_difficulty|{difficulty}]'

        if access_rule is not None:
            if pt_loc['access_rules']:
                if pt_loc['access_rules'][0] != access_rule:
                    print(f'Updating access rule for {name} from "{pt_loc["access_rules"][0]}" to "{access_rule}"')
                    pt_loc['access_rules'][0] = access_rule
        pass

    with open("./mapping_generator/lambda_to_access_rule.json", 'w') as f:
        json.dump(lambda_to_access_rule, f, indent=4)

main()
