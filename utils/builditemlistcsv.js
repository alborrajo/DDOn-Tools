const fs = require('fs');
const itemlist = require('../resources/itemlist.json');

const csvHeader = ['#ItemId','Category','Price'];

const csvData = [
    ...itemlist.consumables.map(c => [c.info.itemId, c.info.category, c.price ?? 0]),
    ...itemlist.materials.map(c => [c.info.itemId, c.info.category, c.price ?? 0]),
    ...itemlist.jobItems.map(c => [c.info.itemId, c.info.category, c.price ?? 0]),
    ...itemlist.jobItems.map(c => [c.info.itemId, c.info.category, c.price ?? 0]),
    ...itemlist.specialItems.map(c => [c.info.itemId, c.info.category, c.price ?? 0]),
    ...itemlist.weapons.map(c => [c.itemId, c.category, c.price ?? 0]),
    ...itemlist.armors.map(c => [c.itemId, c.category, c.price ?? 0]),
    ...itemlist.jewelries.map(c => [c.itemId, c.category, c.price ?? 0]),
    ...itemlist.npcEquipments.map(c => [c.itemId, c.category, c.price ?? 0])];

const csvLines = [csvHeader.join(','), ...csvData.map(line => line.join(','))];
const serialized = csvLines.join('\n');

fs.writeFileSync('itemlist.csv', serialized);