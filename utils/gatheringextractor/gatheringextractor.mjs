#!/usr/bin/env zx
import { cp, mkdir, readFile, rm, writeFile } from "fs/promises";
import path, { basename } from "path";
import JSON5 from 'json5';

/**
 * _p rLayout file name format:
 * stXXXX_00m00n_pYY
 *  XXXX:   StageNo
 *  YY:     GroupNo
 */
const regex = /[a-z]+([0-9]{4})_[0-9]{2}m[0-9]{2}n_p([0-9]+)/;

mkdir('tmp', {recursive: true});
if(argv._.length < 2) {
    echo("Usage: ./gatheringextractor.mjs \"/path/to/ARCtool\" \"/path/to/Dragon's Dogma Online\"");
    echo("To use this you must have ImHex installed in your PATH");
    await $`exit 1`.quiet();
}

const arcToolPath = argv._[0];
const ddonPath = argv._[1];

const stageNoAndGatheringSpots = new Map();

const arcPaths = (await $`find ${ddonPath} -path "*/lot/*" -type f -name "*.arc"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);

if(arcPaths.length == 0) {
    echo(`No fitting ARC files found in ${ddonPath}`);
    await $`exit 1`.quiet();
}

cd('tmp');
for (const arcPath of arcPaths) {
    const parsedArcPath = path.parse(arcPath);
    
    echo(`Copying ${parsedArcPath.base}`);
    await cp(arcPath, parsedArcPath.base);
    
    echo(`Unarchiving ${parsedArcPath.base}`);
    await $`${arcToolPath} -ddo -pc -tex -v 7 ${parsedArcPath.base}`.quiet();

    const pLayoutPaths = (await $`find ${parsedArcPath.name} -type f -name "${parsedArcPath.name}_p*.15302EF4"`.quiet()).stdout.split('\n').filter(filename => filename.trim().length > 0);
    if (pLayoutPaths.length == 0) {
        echo(`No _p rLayout files in ${parsedArcPath.name}, skipping.`)
    } else {
        for(const pLayoutPath of pLayoutPaths) {
            const [stageNo, groupNo] = basename(pLayoutPath).match(regex).slice(1).map(Number);
            echo(`Extracting gathering spots from ${pLayoutPath} (StageNo ${stageNo}, GroupNo ${groupNo})`);
            await $`imhex --pl format --pattern ../lot.hexpat --input ${pLayoutPath} --output tmp.json`.quiet();
            const lot = JSON5.parse(String(await readFile("tmp.json", {encoding: "utf-8"})))
            await rm("tmp.json");
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
cd('..');

await writeFile('gatheringSpots.json', JSON.stringify(Object.fromEntries(stageNoAndGatheringSpots)));
echo("Done. All extracted data written to gatheringSpots.json");