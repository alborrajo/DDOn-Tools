#!/usr/bin/env zx
import { cp, mkdir, readFile, rm, writeFile } from "fs/promises";
import path, { basename } from "path";
import JSON5 from 'json5';
import { $, cd, chalk, echo } from "zx";
import { exit } from "process";

const gatheringSpotOmTypes = [
    4, // cSetInfoOmGather
    7, // cSetInfoOmTreasureBox
    42 // SetInfoOmTreasureBoxG
];

/**
 * Target rLayout file name format:
 * stXXXX_00m00n_pYY
 *  XXXX:   StageNo
 *  YY:     GroupNo
 */
const regex = /[a-z]+([0-9]{4})_[0-9]{2}m[0-9]{2}n_.([0-9]+)/;

if(argv._.length < 1) {
    echo("Usage: ./stageextractor.mjs \"/path/to/ddon-data\"");
    echo("Obtain ddon-data from here: https://github.com/ddon-research/ddon-data/");
    echo("To use this you must have ImHex installed in your PATH");
    exit(1);
}

const ddonDataPath = argv._[0];

mkdir('out', {recursive: true});
cd('out');

// Find gathering spots
echo("Looking for stage layout files...");
const stageNoAndGatheringSpots = new Map();
const stLotPaths = (await $`find ${ddonDataPath}/client/03040008 -type f -name "st*_p*.lot.json"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
for (const stLotPath of stLotPaths) {
    echo(`Reading layout ${stLotPath}`);
    const [stageNo, groupNo, lot] = await readLayout(stLotPath);
    echo(`\t(StageNo ${stageNo}, GroupNo ${groupNo})`);
    const gatheringSpots = [];
    for (let index = 0; index < lot.Array.length; index++) {
        const setInfo = lot.Array[index];
        if(gatheringSpotOmTypes.includes(setInfo.Type)) {
            gatheringSpots.push({
                GroupNo: groupNo,
                PosId: Number(setInfo.Id),
                GatheringType: setInfo.Info.GatheringType,
                UnitId: setInfo.Info.InfoOm.InfoCoord.UnitID,
                Position: {
                    x: Number(setInfo.Info.InfoOm.InfoCoord.Position.X),
                    y: Number(setInfo.Info.InfoOm.InfoCoord.Position.Y),
                    z: Number(setInfo.Info.InfoOm.InfoCoord.Position.Z)
                }
            });
        }
    }
    echo(`\tFound ${gatheringSpots.length} gathering spots`);
    if(gatheringSpots.length > 0) {
        if(!stageNoAndGatheringSpots.has(stageNo)) {
            stageNoAndGatheringSpots.set(stageNo, new Array());
        }
        stageNoAndGatheringSpots.get(stageNo).push(...gatheringSpots);
    }
}
await writeFile('gatheringSpots.json', JSON.stringify(Object.fromEntries(stageNoAndGatheringSpots)));
echo("All extracted p rLayout data written to gatheringSpots.json");

// Find stage parts
echo("Looking for stage parts files...");
const stageNoAndParts = new Map();
const stageCustomPaths = (await $`find ${ddonDataPath}/client/03040008 -type f -name "st????.sca.json"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
for (const stageCustomPath of stageCustomPaths) {
    echo(`Reading ${stageCustomPath}`);
    const parsedStageCustomPath = path.parse(stageCustomPath);
    const stageNo = Number(basename(parsedStageCustomPath.base).match(/st([0-9]{4})/)[1]);
    const parsedStageCustom = await readStageCustom(stageCustomPath);
    if(stageNoAndParts.has(stageNo)) {
        echo(chalk.yellow(`Warning: Found more than one rStageCustom file for stage ${stageNo}. Ignoring`));
    } else {
        stageNoAndParts.set(stageNo, {
            PartsPath: parsedStageCustom.PartsPath,
            ArrayArea: parsedStageCustom.ArrayArea.map(area => area.AreaNo)
        });
    }
}
await writeFile('stageCustom.json', JSON.stringify(Object.fromEntries(stageNoAndParts)));
echo("All extracted rStageCustom data written to stageCustom.json");

echo("Done");


async function readLayout(layoutPath) {
    const [stageNo, groupNo] = basename(layoutPath).match(regex).slice(1).map(Number);
    const lot = JSON5.parse(String(await readFile(layoutPath, {encoding: "utf-8"})));
    return [stageNo, groupNo, lot];
}

async function readStageCustom(stageCustomPath) {
    return JSON5.parse(String(await readFile(stageCustomPath, {encoding: "utf-8"})))
}