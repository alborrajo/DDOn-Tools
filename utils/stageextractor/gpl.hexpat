#pragma array_limit 10000000000

struct cGroupParam_cID {
    u32 stageNo;
    u32 groupNo;
    u32 u2;
    u32 u3;
};

struct MtVector3 {
    // PS4
    float x;
    float y;
    float z;
    float pad_;
};

struct ShapeInfoArea {
    // PS4
    float u0;
    u8 u1;
    float u2;
    float u3;
    MtVector3 vertex[4];
    MtVector3 concaveCrossPos;
    u8 flgConvex;
    u32 concaveStatus;
};

struct AreaHitShape {
    // PS4
    char name[];
    float checkAngle;
    float checkRange;
    float checkToward;
    u8 angleFlag;
    u8 towardFlag;
    s32 type;
    
    // Here it depends on type
    ShapeInfoArea shape;
};

struct LifeArea {
    u32 shapeListLength;
    AreaHitShape shapeList[shapeListLength];
};

struct cGroupParam {
    u32 dataCommon;
    
    u32 layoutIdLength;
    cGroupParam_cID layoutId[layoutIdLength];
    
    u32 loadCondition;
    u32 dataLogFlag;
    u32 loadCondition2;
    u32 QuestNo;
    u32 LayoutFlagNo;
    u32 LoadCondition3;
    u8 unk2;
    u32 unk3;
    u32 loadCondition4;
    u32 loadCondition5;
    u32 LoadStageNo;
    u32 SetCondition1;
    
    u32 areaHitShapeLength;
    AreaHitShape AreaHitShapeList[areaHitShapeLength];
  
    u32 SetCondition2;
    u32 SetCondition3;
    u32 DeleteCondition;
    u32 DeleteCondition2;
    u32 DeleteCondition3;
    
    u32 lifeAreaArrayLength;
    LifeArea lifeAreaArray[lifeAreaArrayLength];;
    
    s32 killAreaType;
    u32 killAreaShapeLength;
    AreaHitShape killAreaShapeList[killAreaShapeLength];
};

u32 magic @ $;
u32 version @ $;

u32 groupListSize @ $;
// These numbers seem a sequence + a flag in the most significant bit
// MSBit = 1: Used, = 0: Unused?
u32 groupList[groupListSize] @ $;

u32 groupNum @ $;

u32 idElements @ $;
u32 lifeAreaElements @ $;
u32 areaHitShapeElements @ $;
u32 shapeInfoAreaElements @ $;
u32 shapeInfoSphereElements @ $;
u32 shapeInfoCylinderElements @ $;
u32 shapeInfoConeElements @ $;
u32 shapeInfoAABBElements @ $;
u32 shapeInfoOBBElements @ $;

cGroupParam groupParams[groupNum] @ $;