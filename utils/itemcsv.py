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
    f.write("ItemId,IconNo,IconColNo\n")

    for consumable in itemlist["ConsumableList"]:
        f.write(f"{consumable['ItemId']},{consumable['IconNo']},{consumable['IconColNo']}\n")

    for material in itemlist["MaterialList"]:
        f.write(f"{material['ItemId']},{material['IconNo']},{material['IconColNo']}\n")

    for key_item in itemlist["KeyItemList"]:
        f.write(f"{key_item['ItemId']},{key_item['IconNo']},{key_item['IconColNo']}\n")

    for job_item in itemlist["JobItemList"]:
        f.write(f"{job_item['ItemId']},{job_item['IconNo']},{job_item['IconColNo']}\n")

    for special_item in itemlist["SpecialItemList"]:
        f.write(f"{special_item['ItemId']},{special_item['IconNo']},{special_item['IconColNo']}\n")

    for weapon in itemlist["WeaponList"]:
        base_item = itemlist["WeaponBaseList"][weapon["WeaponBaseId"]]
        f.write(f"{weapon['ItemId']},{base_item['IconNo']},{base_item['IconColNo']}\n")

    for armor in itemlist["ArmorList"]:
        base_item = itemlist["ArmorBaseList"][armor["ArmorBaseId"]]
        f.write(f"{armor['ItemId']},{base_item['IconNo']},{base_item['IconColNo']}\n")

    for jewelry in itemlist["JewelryList"]:
        f.write(f"{jewelry['ItemId']},{jewelry['IconNo']},{jewelry['IconColNo']}\n")