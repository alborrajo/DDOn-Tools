struct cMaterialData {
    u32 ItemId;
    u32 Num;
    bool IsSp;
};

struct rCraftRecipe {
    u32 RecipeId;
    u32 ItemId;
    u32 CreateTime;
    u8 CreateNum;
    u32 Gold;
    u32 Exp;
    u32 Rank;
    u32 NpcAction;
    u32 MaterialDataListNum;
    cMaterialData MaterialDataList[MaterialDataListNum];
};

u32 magic @$;
u32 version @$;

u32 recipeNum @$;
rCraftRecipe craftRecipes[recipeNum] @$;