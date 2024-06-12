#pragma pattern_limit 1000000

// PS4 structs
struct PS4_rParam {
    u16 kindType;
    u16 param1;
    u16 param2;
    u16 param3;
};

struct rVsEnemyParam {
    u8 kindType;
    u16 param;
};

struct rEquipParamS8 {
    u8 kindType;
    u8 form;
    if (form == 0) {u8 value;}
    else if (form==1) {u8 value;}
    else if (form==2) {s16 value;}
    else if (form==3) {u16 value;}
};

struct rWeaponParam {
    u32 modelTagId;
    u32 powerRev;
    u32 chance;
    u32 defense;
    u32 magicDefense;
    u32 durability;
    u8 wepCategory;
    u32 attack;
    u32 magicAttack;
    u32 shieldStagger;
    u16 weight;
    u16 maxHpRev;
    u16 maxStRev;
    u8 colorNo;
    u8 sex;
    u8 modelParts;
    u8 eleSlot;
    u8 physicalType;
    u8 elementType;
    u8 equipParamS8Num;
    rEquipParamS8 equipParamS8[equipParamS8Num];
};

struct rProtectorParam {
    u32 modelTagId;
    u32 powerRev;
    u32 chance;
    u32 defense;
    u32 magicDefense;
    u32 durability;
    u32 attack;
    u32 magicAttack;
    u16 weight;
    u16 maxHpRev;
    u16 maxStRev;
    u8 colorNo;
    u8 sex;
    u8 modelParts;
    u8 eleSlot;
    u8 equipParamS8Num;
    rEquipParamS8 equipParamS8[equipParamS8Num];
};

struct rItemParam {
    u32 itemId;
    u32 nameId;
    u32 useCategory;
    u32 price;
    u32 sortNo;
    u32 nameSortNo;
    u32 attackStatus;
    u32 isUseJob;
    u16 flag;
    u16 iconNo;
    u16 isUseLv;
    u8 category;
    u8 stackMax;
    u8 rank;
    u8 grade;
    u8 iconColNo;
    
    u32 paramNum;
    PS4_rParam itemParamList[paramNum];
    
    u32 vsEmNum;
    rVsEnemyParam vsEnemyParamList[vsEmNum];
    
    if(category == 3) {
        if((equipCategory - 1) < 2) {
            rWeaponParam weaponParam;
        }
        if(equipCategory < 13 && 1 < (equipCategory - 1)) {
            rProtectorParam protectorParam;
        }
    }
};


// PC version
struct Param {
    u16 parameterId;
    u16 effectValue;
    u16 u2;
    u16 u3;
};

struct ItemInfo { // General item info?
    u32 itemId;
    u16 useTypeMaybe;
    u8 category;
    u32 nameId;
    u8 detailCategoryMaybe; // materialCategory if Material, jobItemCategory if Job Item...
};

struct Consumable {
    ItemInfo info;
    u16 iconId;
    u8 iconColorId;
    u32 sortNumber;
    u32 nameSortNumber;
    u16 price;
    u16 u5;
    u8 stackLimit;
    u8 u7;
    
    u8 paramsSize;
    Param params[paramsSize];
};

struct Material {
    ItemInfo info;
    u16 iconId;
    u8 iconColorId;
    u32 sortNumber;
    u32 nameSortNumber;
    u16 price;
    u16 u5;
    u8 stackLimit;
    
    u8 paramsSize;
    Param params[paramsSize];
};

struct KeyItem {
    ItemInfo info;
    u16 iconId;
    u8 iconColorId;
    u32 sortNumber;
    u32 nameSortNumber;
    u8 stackLimit;
};

struct JobItem {
    ItemInfo info;
    u16 iconId;
    u8 iconColorId;
    u32 sortNumber;
    u32 nameSortNumber;
    u16 price;
    u16 itemRankX4;
    u8 stackLimit;
    u8 usageLevel;
    u8 targetJob; // Its not JobId directly, maybe a set of flags?

    
    u8 paramsSize;
    Param params[paramsSize];
};

struct SpecialItem {
    ItemInfo info;
    u16 iconId;
    u8 iconColorId;
    u32 sortNumber;
    u32 nameSortNumber;
    u8 itemRank;
};

struct EquipParam {
    u8 nameIdMaybe;
    u8 parameterId;
    if (parameterId == 0) {u8 value;} // Signed?
    else if (parameterId==1) {u8 value;}
    else if (parameterId==2) {s16 value;}
    else if (parameterId==3) {u16 value;}
};

struct Weapon {
    u32 itemId;
    u16 useTypeMaybe;
    u8 category;
    u32 sortNumber;
    u32 nameSortNumber;
    u16 price;
    u16 itemRankX4;
    u16 atk;
    u16 matk;
    u16 weight;
    u8 u9;
    u16 u10;
    
    u8 equipParamsSize;
    EquipParam equipParams[equipParamsSize];    
};

struct rUnk9Unk0Unk0 {
    u32 u0;
    u8 u1;
    u8 colorId;
};

struct rUnk9Unk0 {
    rUnk9Unk0Unk0 u0;
    u32 u1;
    u16 u2;
    u16 u3;
    u16 u4;
    u8 u5;
    u8 u6;
    u8 u7;
};

struct rUnk9 {
    rUnk9Unk0 u0;
    u8 u1;
    u8 u2;
    u8 u3;
};

struct Armor {
    u32 itemId;
    u16 useTypeMaybe;
    u8 category;
    u32 sortNumber;
    u32 nameSortNumber;
    u16 price;
    u16 itemRankX4;
    u16 atk;
    u16 matk;
    u16 def;
    u16 mdef;
    u16 weight;
    u8 u11;
    u16 u12; // Two u8?
    
    u8 equipParamsSize;
    EquipParam equipParams[equipParamsSize];
};

struct rUnk11 {
    rUnk9Unk0 u0;
};

struct Jewelry {
    u32 itemId;
    u16 useTypeMaybe;
    u8 category;
    u32 sortNumber;
    u32 nameSortNumber;
    u16 price;
    u16 itemRankX4;
    u32 nameId;
    u16 iconId;
    u8 usageLevel;
    u8 unk8;
    u16 atk;
    u16 matk;
    u16 def;
    u16 mdef;
    u16 weight;
    u8 u14;
    u8 iconColorId;
    u8 crestNumber;
    
    u8 equipParamsSize;
    EquipParam equipParams[equipParamsSize];
};

struct NPCEquipment {
    u32 itemId;
    u16 u1;
    u8 category;
    rUnk9Unk0Unk0 u3;
    u32 nameId;
    u8 u5;
    u8 weaponCategoryMaybe;
};

u32 magicNum @ $;
u32 versionNum @ $;

// Sizes for buffers
u32 unk0 @ $;
u32 unk1 @ $;

// Actual list sizes
u32 unk2 @ $;
u32 consumablesSize @ $;
u32 materialsSize @ $;
u32 keyItemsSize @ $;
u32 jobItemsSize @ $;
u32 specialItemsSize @ $;
u32 weaponsSize @ $;
u32 unk9 @ $;
u32 armorsSize @ $;
u32 unk11 @ $;
u32 jewelriesSize @ $;
u32 npcEquipmentsSize @ $;

u32 unk2List[unk2] @ $;
Consumable consumables[consumablesSize] @ $;
Material materials[materialsSize] @ $;
KeyItem keyItems[keyItemsSize] @ $;
JobItem jobItems[jobItemsSize] @ $;
SpecialItem specialItems[specialItemsSize] @ $;
Weapon weapons[weaponsSize] @ $;
rUnk9 unk9List[unk9] @ $;
Armor armors[armorsSize] @ $;
rUnk11 unk11List[unk11] @ $;
Jewelry jewelries[jewelriesSize] @ $;
NPCEquipment npcEquipments[npcEquipmentsSize] @ $;