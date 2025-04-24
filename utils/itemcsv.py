#!/usr/bin/env python3

import sys
import json

if len(sys.argv) != 2:
    print("Usage: python itemcsv.py <path/to/ddon-data>")
    print("Obtain ddon-data from here: https://github.com/ddon-research/ddon-data/")
    sys.exit(1)

path = sys.argv[1]

with open(f"{path}/client/03040008/base/etc/itemlist.ipa.json", "r", encoding="utf-8") as f:
    itemlist = json.load(f)

with open("items.csv", "w") as f:
    f.write("ItemId,QualityStars,IconNo,IconColNo,Price\n")

    for consumable in itemlist["ConsumableList"]:
        f.write(f"{consumable['ItemId']},0,{consumable['IconNo']},{consumable['IconColNo']},{consumable['Price']}\n")

    for material in itemlist["MaterialList"]:
        f.write(f"{material['ItemId']},0,{material['IconNo']},{material['IconColNo']},{material['Price']}\n")

    for key_item in itemlist["KeyItemList"]:
        f.write(f"{key_item['ItemId']},0,{key_item['IconNo']},{key_item['IconColNo']},0\n")

    for job_item in itemlist["JobItemList"]:
        f.write(f"{job_item['ItemId']},0,{job_item['IconNo']},{job_item['IconColNo']},{job_item['Price']}\n")

    for special_item in itemlist["SpecialItemList"]:
        f.write(f"{special_item['ItemId']},0,{special_item['IconNo']},{special_item['IconColNo']},0\n")

    for weapon in itemlist["WeaponList"]:
        base_item = itemlist["ItemEquipWeaponGroupList"][weapon["WeaponBaseId"]]
        f.write(f"{weapon['ItemId']},{weapon['QualityStars']},{base_item['IconNo']},{base_item['IconColNo']},{weapon['Price']}\n")

    for armor in itemlist["ArmorList"]:
        base_item = itemlist["ItemEquipProtectorGroupList"][armor["ArmorBaseId"]]
        f.write(f"{armor['ItemId']},{armor['QualityStars']},{base_item['IconNo']},{base_item['IconColNo']},{armor['Price']}\n")

    for jewelry in itemlist["JewelryList"]:
        f.write(f"{jewelry['ItemId']},0,{jewelry['IconNo']},{jewelry['IconColNo']},{jewelry['Price']}\n")