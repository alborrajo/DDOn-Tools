#!/usr/bin/env zx

import { rm, writeFile } from "fs/promises";
import { basename } from "path";
import { $, cd, chalk, echo, fs, glob } from "zx";

/**
 * Map chunk file name format:
 * mapAAA_mBB_YYXX_ZZ00
 *  XX,YY:   Position of the map chunk (Groups 1 and 2)
 *  ZZ:      Layer (Group 3)
 */
const regex = /[a-z]+[0-9]{3}_m[0-9]{2}_([0-9]{2})([0-9]{2})_([0-9]{2})[0-9]{2}/g;

cd("tmp")
const maps = await $`find ./ -maxdepth 1 -type d -regex "\.\/[a-z]+[0-9]+_m[0-9]+"`.quiet()
for (const mapPath of maps.stdout.split("\n")) {
    const map = basename(mapPath);
    const matches = (await glob([`${map}_*_*`], {onlyDirectories: true}))
        .flatMap(layer => Array.from(layer.matchAll(regex)));
    
    const minX = Math.min(...matches.map(match => Number(match[2])))
    const maxX = Math.max(...matches.map(match => Number(match[2])))
    const minY = Math.min(...matches.map(match => Number(match[1])))
    const maxY = Math.max(...matches.map(match => Number(match[1])))
    const minLayer = Math.min(...matches.map(match => Number(match[3])))
    const maxLayer = Math.max(...matches.map(match => Number(match[3])))
    echo(`${map} (${minX}~${maxX}, ${minY}~${maxY}) - Layers: ${minLayer}~${maxLayer}`);

    for(let layer=minLayer; layer<=maxLayer; layer++) {
        const outputBasename = `${map}_l${layer}`;
        try {
            const images = [...(await getMapDDSForLayer(map, minX, maxX, minY, maxY, layer))];
            const imagesListFilePath = `${outputBasename}.txt`;
            await writeFile(imagesListFilePath, images.join('\n'));

            const outputPath = `../results/${outputBasename}.png`
            await spinner('Stitching...', () =>  $`magick montage @${imagesListFilePath} -background none -geometry 512x512+0+0! -tile ${maxX-minX+1}x${maxY-minY+1} ${outputPath}`.quiet()); // Command too long
            await rm(outputTmpPath);
            echo(chalk.green(outputBasename));
        } catch(err) {
            echo(chalk.red(outputBasename, JSON.stringify(err)));
        }
    }
}

async function getMapDDSForLayer(map, minX, maxX, minY, maxY, layer) {
    const ddsPaths = [];
    const warnings = [];
    echo('Layer ',layer);
    for(let y=minY; y<=maxY; y++) {
        for(let x=minX; x<=maxX; x++) {
            const fileBasenameGlobExpr = `${map}_${String(y).padStart(2, "0")}${String(x).padStart(2, "0")}_${String(layer).padStart(2, "0")}00*`;
            const pathGlobExpr = `${fileBasenameGlobExpr}/**/${fileBasenameGlobExpr}.dds`;
            const files = await glob([pathGlobExpr], {onlyFiles: true})
            if(files.length == 0) {
                // Leave empty space if not found
                ddsPaths.push("xc:none");
                process.stdout.write('░');
            } else {
                ddsPaths.push(files[0]);
                process.stdout.write('█');
                if(files.length > 1) {
                    warnings.push(`Multiple files found for (${x},${y}) of layer ${layer} of map ${map}. The first one will be used:\n${JSON.stringify(files, undefined, 2)}`);
                }
            }
        }
        process.stdout.write('\n');
    }

    for(let warning of warnings) {
        echo(chalk.yellow(warning));
    }

    return ddsPaths
}