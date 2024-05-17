#pragma array_limit 1000000000

// Taken from https://github.com/ddon-research/ddon-data/blob/main/research/02030004/rstagecustom-season2-pattern.txt

struct rStageCustom_Area
{
  s8 mAreaNo;
  u8 mFilterNo;
  s32 mGroupNo;
};

struct rStageCustom
{
  //rStageCustomParts mprParts;//*
  char PartsType[];
  char PartsPath[];

  u32 mArrayAreaNum;  
  rStageCustom_Area mpArrayArea[mArrayAreaNum];//*

};
rStageCustom rstagecustom_at_0x08 @ 0x08;