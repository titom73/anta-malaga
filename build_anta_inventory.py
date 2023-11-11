#!/usr/bin/env python3

import yaml

with open("atd-inventory/inventory.yml", "r") as f:
    inventory = yaml.safe_load(f)

anta_inventory = {
    "anta_inventory": {
        "hosts": list()
    }
}

avd_host_list = list()

for host_name, host in inventory['all']['children']['ATD_LAB']['children']['ATD_FABRIC']['children']['ATD_SPINES']['hosts'].items():
    avd_host_list.append({
        'name': host_name,
        'host': host['ansible_host'],
        'tags': ['fabric', 'spine', host_name]
    })

for pod, pod_members in inventory['all']['children']['ATD_LAB']['children']['ATD_FABRIC']['children']['ATD_LEAFS']['children'].items():
    for host_name, host in pod_members['hosts'].items():
        avd_host_list.append({
            'name': host_name,
            'host': host['ansible_host'],
            'tags': ['fabric', 'leaf', host_name]
        })

with open("anta-inventory.yml", "w") as f:
    yaml.dump(
        {
            "anta_inventory": {
                "hosts": avd_host_list
            }
        }, f
    )
