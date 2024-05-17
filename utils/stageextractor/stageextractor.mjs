#!/usr/bin/env zx
import { cp, mkdir, readFile, rm, writeFile } from "fs/promises";
import path, { basename } from "path";
import JSON5 from 'json5';
import { $, cd, chalk, echo } from "zx";

/**
 * Target rLayout file name format:
 * stXXXX_00m00n_pYY
 *  XXXX:   StageNo
 *  YY:     GroupNo
 */
const regex = /[a-z]+([0-9]{4})_[0-9]{2}m[0-9]{2}n_.([0-9]+)/;

if(argv._.length < 2) {
    echo("Usage: ./stageextractor.mjs \"/path/to/ARCtool\" \"/path/to/Dragon's Dogma Online\"");
    echo("To use this you must have ImHex installed in your PATH");
    await $`exit 1`.quiet();
}

const arcToolPath = argv._[0];
const ddonPath = argv._[1];

mkdir('tmp', {recursive: true});
cd('tmp');

// Find gathering spots
const stageNoAndGatheringSpots = new Map();
const stLotArcPaths = (await $`find ${ddonPath} -path "*/lot/*" -type f -name "*.arc"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
for (const arcPath of stLotArcPaths) {
    const parsedArcPath = path.parse(arcPath);
    
    echo(`Copying ${parsedArcPath.base}`);
    await cp(arcPath, parsedArcPath.base);
    
    echo(`Unarchiving ${parsedArcPath.base}`);
    await $`${arcToolPath} -ddo -pc -tex -v 7 ${parsedArcPath.base}`.quiet();

    const pLayoutPaths = (await $`find ${parsedArcPath.name} -type f -name "${parsedArcPath.name}_p*.15302EF4"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
    if (pLayoutPaths.length == 0) {
        echo(`No _p rLayout files in ${parsedArcPath.name}`)
    } else {
        for(const pLayoutPath of pLayoutPaths) {
            const [stageNo, groupNo, lot] = await readLayout(pLayoutPath);
            const gatheringSpots = [
                ...lot.setInfoOmGather, 
                ...lot.setInfoOmTreasureBox.map(x => x.super_cSetInfoOmGather)
            ];
            for(const gatheringSpot of gatheringSpots) {
                if(!stageNoAndGatheringSpots.has(stageNo)) {
                    stageNoAndGatheringSpots.set(stageNo, new Array());
                }
                stageNoAndGatheringSpots.get(stageNo).push({
                    GroupNo: groupNo,
                    PosId: Number(gatheringSpot.ItemListID),
                    Position: {
                        x: Number(gatheringSpot.SetInfoOm.SetInfoCoord.Position.x),
                        y: Number(gatheringSpot.SetInfoOm.SetInfoCoord.Position.y),
                        z: Number(gatheringSpot.SetInfoOm.SetInfoCoord.Position.z)
                    }
                });
            }
        }
    }

    echo(`Cleaning up ${parsedArcPath.base}`);
    await rm(parsedArcPath.base);
    await rm(parsedArcPath.name, { recursive: true });
}

await writeFile('gatheringSpots.json', JSON.stringify(Object.fromEntries(stageNoAndGatheringSpots)));
echo("All extracted p rLayout data written to gatheringSpots.json");

// Find stage parts
const stageNoAndParts = new Map();
const stArcPaths = (await $`find ${ddonPath} -path "*/nativePC/rom/stage/st*" -type f -name "st????.arc"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
for (const arcPath of stArcPaths) {
    const parsedArcPath = path.parse(arcPath);
    echo(`Copying ${parsedArcPath.base}`);
    await cp(arcPath, parsedArcPath.base);
    echo(`Unarchiving ${parsedArcPath.base} ${arcToolPath} -ddo -tex -alwayscomp -pc -txt -v 7 ${parsedArcPath.base}`);
    await $`${arcToolPath} -ddo -tex -alwayscomp -pc -txt -v 7 ${parsedArcPath.base}`.quiet();

    const stageCustomPaths = (await $`find ${parsedArcPath.name} -type f -name "st????.59F75535"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
    if (stageCustomPaths.length == 0) {
        echo(`No rStageCustom files in ${parsedArcPath.name}`)
    } else {
        const stageNo = Number(basename(parsedArcPath.base).match(/st([0-9]{4})/)[1]);
        if (stageCustomPaths.length > 1) {
            echo(chalk.yellow(`More than one rStageCustom file in ${parsedArcPath.name}. Reading only the first one`))
        }
        const stageCustomPath = stageCustomPaths[0];
        const parsedStageCustom = await readStageCustom(stageCustomPath);
        stageNoAndParts.set(stageNo, parsedStageCustom);
    }

    echo(`Cleaning up ${parsedArcPath.base}`);
    await rm(parsedArcPath.base);
    await rm(parsedArcPath.name, { recursive: true });
}

await writeFile('stageCustom.json', JSON.stringify(Object.fromEntries(stageNoAndParts)));
echo("All extracted rStageCustom data written to stageCustom.json");

echo("Done");


async function readLayout(layoutPath) {
    const [stageNo, groupNo] = basename(layoutPath).match(regex).slice(1).map(Number);
    echo(`Reading ${layoutPath} (StageNo ${stageNo}, GroupNo ${groupNo})`);
    await $`imhex --pl format --pattern ../lot.hexpat --input ${layoutPath} --output tmp.json`.quiet();
    const lot = JSON5.parse(String(await readFile("tmp.json", {encoding: "utf-8"})))
    await rm("tmp.json");
    return [stageNo, groupNo, lot];
}

async function readStageCustom(stageCustomPath) {
    echo(`Reading ${stageCustomPath}`);
    await $`imhex --pl format --pattern ../rstagecustom-season2-pattern.hexpat --input ${stageCustomPath} --output tmp.json`.quiet();
    const stageCustomEx = JSON5.parse(String(await readFile("tmp.json", {encoding: "utf-8"})))
    await rm("tmp.json");
    return stageCustomEx;
}