#pragma array_limit 1000000000
//PS4
struct V3 {
    float x;
    float y;
    float z;
};

struct cSetInfoCoord {
    char Name[];
    s32 UnitId;
    V3 Position;
    V3 Angle;
    V3 Scale;
    s32 AreaHitNo;
    
};

struct cSetInfoOm {
    bool DisableEffect;
    bool DisableOnlyEffect;
    u8 OpenFlag;
    bool EnableSyncLight;
    bool EnableZone;
    u32 InitMtnNo;
    u32 AreaMasterNo;
    u16 AreaReleaseNo;
    u8 AreaReleaseON;
    u8 AreaReleaseOFF;
    u32 WarpPointId;
    u32 KeyNo;
    bool IsBreakLink;
    bool IsBreakQuest;
    u16 BreakKind;
    u16 BreakGroup;
    u16 BreakID;
    u32 QuestFlag;
    bool IsNoSbc;
    bool IsMyQuest;
    cSetInfoCoord SetInfoCoord;
};

struct cSetInfoOmGather {
    u32 ItemListID;
    u32 GatheringType;
    bool IsGatherEnemy;
    cSetInfoOm SetInfoOm;
};

struct cSetInfoOmTreasureBox {
    cSetInfoOmGather super_cSetInfoOmGather;
};

struct cSetInfoOmSealedTreasureBox {
    bool u0;
    u16 u1;
    u16 u2;
    s32 u3;
    s32 u4;
    s32 u5;
    bool u6;
    cSetInfoOm SetInfoOm;
};

struct cSetInfoOmEnemy {
    u32 u0;
    u32 u1;
    u32 u2;
    u32 u3;
    u32 u4;
    u8 u5;
    cSetInfoCoord SetInfoCoord;
};

struct TODO_cSetInfo {
};

struct Wrapper_cSetInfo {
    s32 id;
    s32 type;
    match (type) {
        (0): TODO_cSetInfo info; // cSetInfoOm
        (1): cSetInfoOmEnemy info; // cSetInfoEnemy
        (2): TODO_cSetInfo info; // cSetInfoNpc
        (3): TODO_cSetInfo info; // cSetInfoGeneralPoint
        (4): cSetInfoOmGather info; // cSetInfoOmGather
        (5): TODO_cSetInfo info; // cSetInfoOmLadder
        (6): TODO_cSetInfo info; // cSetInfoOmWarp
        (7): cSetInfoOmTreasureBox info; // cSetInfoOmTreasureBox
        (8): TODO_cSetInfo info; // cSetInfoOmBoard
        (9): TODO_cSetInfo info; // cSetInfoOmCtrl
        (10): TODO_cSetInfo info; // cSetInfoOmElfSW
        (11): TODO_cSetInfo info; // cSetInfoOmFall
        (12): TODO_cSetInfo info; // cSetInfoOmLever
        (13): TODO_cSetInfo info; // cSetInfoOmRange
        (14): TODO_cSetInfo info; // cSetInfoOmText
        (15): TODO_cSetInfo info; // cSetInfoOmWall
        (16): TODO_cSetInfo info; // cSetInfoOmHakuryuu
        (17): TODO_cSetInfo info; // cSetInfoOmDoor
        (18): TODO_cSetInfo info; // cSetInfoOmBowlOfLife
        (19): TODO_cSetInfo info; // cSetInfoOmNav
        (20): TODO_cSetInfo info; // cSetInfoOmHeal
        (21): TODO_cSetInfo info; // cSetInfoOmBadStatus
        (22): TODO_cSetInfo info; // cSetInfoOmBlock
        (23): TODO_cSetInfo info; // cSetInfoOmEx
        (24): TODO_cSetInfo info; // cSetInfoOmOldDoor
        (25): TODO_cSetInfo info; // cSetInfoOmOneWay
        (26): TODO_cSetInfo info; // cSetInfoOmBreakTarget
        (27): TODO_cSetInfo info; // cSetInfoOmUnknown27
        (28): TODO_cSetInfo info; // cSetInfoOmUnknown28
        (29): TODO_cSetInfo info; // cSetInfoOmWarpNew
        (30): TODO_cSetInfo info; // cSetInfoOmUnknown30
        (31): TODO_cSetInfo info; // cSetInfoOmUnknown31
        (32): TODO_cSetInfo info; // cSetInfoOmUnknown32
        (33): TODO_cSetInfo info; // cSetInfoOmUnknown33
        (34): TODO_cSetInfo info; // cSetInfoOmUnknown34
        (40): TODO_cSetInfo info; // cSetInfoOmOld
        (42): cSetInfoOmSealedTreasureBox info; // cSetInfoOmUnknown42
        (43): TODO_cSetInfo info; // cSetInfoOmWarpNewV3
        (45): TODO_cSetInfo info; // cSetInfoOmUnknown45
        (46): TODO_cSetInfo info; // cSetInfoOmUnknown46
        (47): TODO_cSetInfo info; // cSetInfoOmUnknown47
        (48): TODO_cSetInfo info; // cSetInfoOmUnknown48
        (49): TODO_cSetInfo info; // cSetInfoOmUnknown49
        (50): TODO_cSetInfo info; // cSetInfoOmUnknown50
        (51): TODO_cSetInfo info; // cSetInfoOmUnknown51
        (52): TODO_cSetInfo info; // cSetInfoOmUnknown52
        (53): TODO_cSetInfo info; // cSetInfoOmUnknown53
        (54): TODO_cSetInfo info; // cSetInfoOmWarpNewV2
        (55): TODO_cSetInfo info; // cSetInfoOmUnknown55
        (200): TODO_cSetInfo info; // cSetInfoEnemyV2
    }
};

u32 magic @ $;
u32 version @ $;

u32 setInfoEnemyCount @ $;
u32 setInfoNpcCount @ $;
u32 setInfoGeneralPointCount @ $;
u32 setInfoOmCount @ $;
u32 setInfoOmBoardCount @ $;
u32 setInfoOmBowlOfLifeCount @ $;
u32 setInfoOmCtrlCount @ $;
u32 setInfoOmDoorCount @ $;
u32 setInfoOmElfSWCount @ $;
u32 setInfoOmFallCount @ $;
u32 setInfoOmGatherCount @ $;
u32 setInfoOmTreasureBoxCount @ $;
u32 setInfoOmHakuryuuCount @ $;
u32 setInfoOmHealCount @ $;
u32 setInfoOmLadderCount @ $;
u32 setInfoOmLeverCount @ $;
u32 setInfoOmNavCount @ $;
u32 setInfoOmRangeCount @ $;
u32 setInfoOmTextCount @ $;
u32 setInfoOmWallCount @ $;
u32 setInfoOmWarpCount @ $;
u32 _readButNotUsed @ $;

u32 setInfoCount @ $;
Wrapper_cSetInfo setInfo[setInfoCount] @ $;