#!/usr/bin/env zx
import { cp, mkdir, readFile, rm, writeFile } from "fs/promises";
import path, { basename } from "path";
import JSON5 from "json5";
import { $, cd, chalk, echo } from "zx";
import { exit } from "process";

/**
 * Target rLayout file name format:
 * stXXXX_00m00n_pYY
 *  XXXX:   StageNo
 *  YY:     GroupNo
 */
const regex = /[a-z]+([0-9]{4})_[0-9]{2}m[0-9]{2}n_.([0-9]+)/;

if (argv._.length < 1) {
  echo('Usage: ./stageextractor.mjs "/path/to/ddon-data"');
  echo(
    "Obtain ddon-data from here: https://github.com/ddon-research/ddon-data/",
  );
  exit(1);
}

const ddonDataPath = argv._[0];

mkdir("out", { recursive: true });
cd("out");

// Find gathering spots
{
  const gatheringSpotOmTypes = [
    4, // cSetInfoOmGather
    7, // cSetInfoOmTreasureBox
    42, // SetInfoOmTreasureBoxG
  ];

  echo("Looking for gathering spots in stage layout files...");
  const stageNoAndGatheringSpots = new Map();
  const stLotPaths = (
    await $`find ${ddonDataPath}/client/03040008 -type f -name "st*_p*.lot.json"`.quiet()
  ).stdout
    .split("\n")
    .filter((filename) => filename.trim().length > 0);
  for (const stLotPath of stLotPaths) {
    echo(`Reading layout ${stLotPath}`);
    const [stageNo, groupNo, lot] = await readLayout(stLotPath);
    echo(`\t(StageNo ${stageNo}, GroupNo ${groupNo})`);
    const gatheringSpots = [];
    for (let index = 0; index < lot.Array.length; index++) {
      const setInfo = lot.Array[index];
      if (gatheringSpotOmTypes.includes(setInfo.Type)) {
        gatheringSpots.push({
          GroupNo: groupNo,
          PosId: Number(setInfo.Id),
          GatheringType: setInfo.Info.GatheringType,
          UnitId: setInfo.Info.InfoOm.InfoCoord.UnitID,
          Position: {
            x: Number(setInfo.Info.InfoOm.InfoCoord.Position.X),
            y: Number(setInfo.Info.InfoOm.InfoCoord.Position.Y),
            z: Number(setInfo.Info.InfoOm.InfoCoord.Position.Z),
          },
        });
      }
    }
    echo(`\tFound ${gatheringSpots.length} gathering spots`);
    if (gatheringSpots.length > 0) {
      if (!stageNoAndGatheringSpots.has(stageNo)) {
        stageNoAndGatheringSpots.set(stageNo, new Array());
      }
      stageNoAndGatheringSpots.get(stageNo).push(...gatheringSpots);
    }
  }
  await writeFile(
    "gatheringSpots.json",
    JSON.stringify(Object.fromEntries(stageNoAndGatheringSpots)),
  );
  echo("All extracted p rLayout data written to gatheringSpots.json");
}

// Find shops
{
  const shopInstitutionFunctionIds = [
    3, // FUNC_ID_SHOP_GENERAL
    4, // FUNC_ID_SHOP_ITEM
    5, // FUNC_ID_SHOP_EQUIP
    6, // FUNC_ID_SHOP_MATERIAL
    8, // FUNC_ID_SHOP_WEAPON
    9, // FUNC_ID_SHOP_ARMOR
    19, 
    20,
    57, // FUNC_ID_PP_SHOP
    70,
    74, // Adventure Pass Shop
    97
  ];

  echo("Looking for shop NPCs...");
  const npcIdAndShopInstitution = new Map();
  const npcLedgerList = JSON5.parse(
    String(
      await readFile(
        ddonDataPath + "/client/03040008/npc/npc_common/etc/npc/npc.nll.json",
        { encoding: "utf-8" },
      ),
    ),
  );
  for (const npc of npcLedgerList.NpcLedgerList) {
    for (const institution of npc.InstitutionList) {
      if (shopInstitutionFunctionIds.includes(institution.FunctionId)) {
        npcIdAndShopInstitution.set(npc.NpcId, institution);
        break;
      }
    }
  }

  echo("Looking for shops in stage layout files...");
  const stageNoAndShops = new Map();
  const stLotPaths = (
    await $`find ${ddonDataPath}/client/03040008 -type f -name "st*_n*.lot.json"`.quiet()
  ).stdout
    .split("\n")
    .filter((filename) => filename.trim().length > 0);
  for (const stLotPath of stLotPaths) {
    echo(`Reading layout ${stLotPath}`);
    const [stageNo, groupNo, lot] = await readLayout(stLotPath);
    echo(`\t(StageNo ${stageNo}, GroupNo ${groupNo})`);
    const shops = [];
    for (let index = 0; index < lot.Array.length; index++) {
      const setInfo = lot.Array[index];
      if (npcIdAndShopInstitution.has(setInfo.Info.NpcId)) {
        const shopInstitution = npcIdAndShopInstitution.get(setInfo.Info.NpcId);
        shops.push({
          NpcId: setInfo.Info.NpcId,
          InstitutionFunctionId: shopInstitution.FunctionId,
          ShopId: shopInstitution.FunctionParam,
          Position: {
            x: Number(setInfo.Info.InfoCharacter.Position.X),
            y: Number(setInfo.Info.InfoCharacter.Position.Y),
            z: Number(setInfo.Info.InfoCharacter.Position.Z),
          },
        });
      }
    }
    echo(`\tFound ${shops.length} shops`);
    if (shops.length > 0) {
      if (!stageNoAndShops.has(stageNo)) {
        stageNoAndShops.set(stageNo, new Array());
      }
      stageNoAndShops.get(stageNo).push(...shops);
    }
  }
  echo("Removing duplicate shops...");
  for (const [stageNo, shops] of stageNoAndShops) {
    const uniqueShops = [];
    for (const shop of shops) {
      if (!uniqueShops.some((s) => shopEquals(s, shop))) {
        uniqueShops.push(shop);
      }
    }
    stageNoAndShops.set(stageNo, uniqueShops);
  }
  await writeFile(
    "shops.json",
    JSON.stringify(Object.fromEntries(stageNoAndShops)),
  );
  echo("All extracted n rLayout data written to shops.json");
}

// Find stage parts
{
  echo("Looking for stage parts files...");
  const stageNoAndParts = new Map();
  const stageCustomPaths = (
    await $`find ${ddonDataPath}/client/03040008 -type f -name "st????.sca.json"`.quiet()
  ).stdout
    .split("\n")
    .filter((filename) => filename.trim().length > 0);
  for (const stageCustomPath of stageCustomPaths) {
    echo(`Reading ${stageCustomPath}`);
    const parsedStageCustomPath = path.parse(stageCustomPath);
    const stageNo = Number(
      basename(parsedStageCustomPath.base).match(/st([0-9]{4})/)[1],
    );
    const parsedStageCustom = await readStageCustom(stageCustomPath);
    if (stageNoAndParts.has(stageNo)) {
      echo(
        chalk.yellow(
          `Warning: Found more than one rStageCustom file for stage ${stageNo}. Ignoring`,
        ),
      );
    } else {
      stageNoAndParts.set(stageNo, {
        PartsPath: parsedStageCustom.PartsPath,
        ArrayArea: parsedStageCustom.ArrayArea.map((area) => area.AreaNo),
      });
    }
  }
  await writeFile(
    "stageCustom.json",
    JSON.stringify(Object.fromEntries(stageNoAndParts)),
  );
  echo("All extracted rStageCustom data written to stageCustom.json");
}

echo("Done");

async function readLayout(layoutPath) {
  const [stageNo, groupNo] = basename(layoutPath)
    .match(regex)
    .slice(1)
    .map(Number);
  const lot = JSON5.parse(
    String(await readFile(layoutPath, { encoding: "utf-8" })),
  );
  return [stageNo, groupNo, lot];
}

async function readStageCustom(stageCustomPath) {
  return JSON5.parse(
    String(await readFile(stageCustomPath, { encoding: "utf-8" })),
  );
}

function shopEquals(shop1, shop2) {
  return (
    shop1.NpcId === shop2.NpcId &&
    shop1.InstitutionFunctionId === shop2.InstitutionFunctionId &&
    shop1.ShopId === shop2.ShopId &&
    positionEquals(shop1.Position, shop2.Position)
  );
}

function positionEquals(pos1, pos2) {
  return (
    pos1.x === pos2.x && pos1.y === pos2.y && pos1.z === pos2.z
  );
}