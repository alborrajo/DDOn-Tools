const fs = require('fs');
const itemlist = require('../resources/itemlist.json');

const csvHeader = ['#ItemId','Category','Price','StackLimit'];

const csvData = [
    ...itemlist.consumables.map(c => [c.info.itemId, c.info.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.materials.map(c => [c.info.itemId, c.info.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.keyItems.map(c => [c.info.itemId, c.info.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.jobItems.map(c => [c.info.itemId, c.info.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.specialItems.map(c => [c.info.itemId, c.info.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.weapons.map(c => [c.itemId, c.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.armors.map(c => [c.itemId, c.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.jewelries.map(c => [c.itemId, c.category, c.price ?? 0, c.stackLimit ?? 1]),
    ...itemlist.npcEquipments.map(c => [c.itemId, c.category, c.price ?? 0, c.stackLimit ?? 1])];

const csvLines = [csvHeader.join(','), ...csvData.map(line => line.join(','))];
const serialized = csvLines.join('\n');

fs.writeFileSync('itemlist.csv', serialized);