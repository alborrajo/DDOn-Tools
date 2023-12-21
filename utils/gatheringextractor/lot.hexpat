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
    u32 AreaReleaseNo;
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
    u8 unk[6];
    cSetInfoCoord SetInfoCoord;
};

struct TODO_cSetInfo {
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

TODO_cSetInfo setInfoEnemy[setInfoEnemyCount] @ $;
TODO_cSetInfo setInfoNpc[setInfoNpcCount] @ $;
TODO_cSetInfo setInfoGeneralPoint[setInfoGeneralPointCount] @ $;
TODO_cSetInfo setInfoOm[setInfoOmCount] @ $;
TODO_cSetInfo setInfoOmBoard[setInfoOmBoardCount] @ $;
TODO_cSetInfo setInfoOmBowlOfLife[setInfoOmBowlOfLifeCount] @ $;
TODO_cSetInfo setInfoOmCtrl[setInfoOmCtrlCount] @ $;
TODO_cSetInfo setInfoOmDoor[setInfoOmDoorCount] @ $;
TODO_cSetInfo setInfoOmElfSW[setInfoOmElfSWCount] @ $;
TODO_cSetInfo setInfoOmFall[setInfoOmFallCount] @ $;
cSetInfoOmGather setInfoOmGather[setInfoOmGatherCount] @ $;
cSetInfoOmTreasureBox setInfoOmTreasureBox[setInfoOmTreasureBoxCount] @ $;
TODO_cSetInfo setInfoOmHakuryuu[setInfoOmHakuryuuCount] @ $;
TODO_cSetInfo setInfoOmHeal[setInfoOmHealCount] @ $;
TODO_cSetInfo setInfoOmLadder[setInfoOmLadderCount] @ $;
TODO_cSetInfo setInfoOmLever[setInfoOmLeverCount] @ $;
TODO_cSetInfo setInfoOmNav[setInfoOmNavCount] @ $;
TODO_cSetInfo setInfoOmRange[setInfoOmRangeCount] @ $;
TODO_cSetInfo setInfoOmText[setInfoOmTextCount] @ $;
TODO_cSetInfo setInfoOmWall[setInfoOmWallCount] @ $;
TODO_cSetInfo setInfoOmWarp[setInfoOmWarpCount] @ $;