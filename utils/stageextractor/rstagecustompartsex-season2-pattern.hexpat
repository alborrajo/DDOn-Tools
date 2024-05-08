#pragma array_limit 1000000000

// Taken from https://github.com/ddon-research/ddon-data/blob/main/research/02030004/rstagecustompartsex-season2-pattern.cpp

struct MtVector3
{
  float x;
  float y;
  float z;
};

struct MtVector4
{
  float x;
  float y;
  float z;
  float w;
};


struct MtColor
{
  u8 r;
  u8 g;
  u8 b;
  u8 a;
};

struct MtAABB
{
  MtVector3 minpos;
  MtVector3 maxpos;
};

struct MtMatrix
{
  MtVector4 m[4];
};

struct MtOBB
{
  MtMatrix coord;
  MtVector3 extent;
};

struct MtSphere
{
  MtVector3 pos;
  float r;
};

struct MtCylinder
{
  MtVector3 p0;
  MtVector3 p1;
  float r;
};

struct cDayNightColorFogParam
{
  float mHeightStart;
  float mHeightEnd;
  float mHeightDensity;
  
  MtVector3 mHeightColor;
  
  float mStart;
  float mEnd;
  float mDensity;
  
  MtVector3 mColor;
  
  float mDiffuseBlendFactor;
  //bool mIsEnable;
  //float mSupplementFrame;
  //s32 mId;
  //u32 mKind;
};

struct rStageCustomPartsEx_ColorFog
{
  cDayNightColorFogParam mBase;
  cDayNightColorFogParam mNight;
  //char mComment[];
};


struct rStageCustomPartsEx_HemiSphLight
{
  MtVector3 mLightColor;
  MtVector3 mRevColor;
  MtVector3 mNightColor;
  MtVector3 mNightRevColor;
  //char mComment[];
};

struct rStageCustomPartsEx_InfiLight
{
  MtVector3 mLightColor;
  MtVector3 mNightColor;
  //char mComment[];
};

struct rStageCustomPartsEx_Pattern
{
  s32 mColorFogNo;
  s32 mHemiSphLightNo;
  s32 mInfiLightNo;
  //char mComment[];
};

struct nZone_ShapeInfoBase
{
  float mDecay;
  //bool mIsNativeData;
};

struct nZone_ShapeInfoSphere : nZone_ShapeInfoBase
{
  MtSphere mSphere;
};

struct nZone_ShapeInfoOBB : nZone_ShapeInfoBase
{
  MtOBB mOBB;
  float mDecayY;
  float mDecayZ;
  bool mIsEnableExtendedDecay;
};

struct nZone_ShapeInfoAABB : nZone_ShapeInfoBase
{
  MtAABB mAABB;
  float mDecayY;
  float mDecayZ;
  bool mIsEnableExtendedDecay;
};

struct  nZone_ShapeInfoCone : nZone_ShapeInfoBase
{
  float mHeight;
  float mTopRadius;
  MtVector3 mPos;
  float mBottomRadius;
};

struct nZone_ShapeInfoCylinder : nZone_ShapeInfoBase
{
  MtCylinder mCylinder;
};

struct nZone_ShapeInfoArea : nZone_ShapeInfoBase
{
  float mHeight;
  float mBottom;
  u32 mConcaveStatus;
  bool mFlgConvex;
  MtVector3 mVertex[4];
  MtVector3 mConcaveCrossPos;
};


struct AreaHitShape
{
  char mName[];
  float mCheckAngle;
  float mCheckRange;
  float mCheckToward;
  bool mAngleFlag;
  bool mTowardFlag;
    
  //bool mIsDeleteZone;
  u8 type;
  
  if(type==0){
  //NOOP
  }
  else if(type==1){//area 
    nZone_ShapeInfoArea mpZone;
      MtAABB mZoneBoundingBox;
  }else if(type==2){//sphere  
      nZone_ShapeInfoSphere mpZBox;
        MtAABB mZoneBoundingBox;
  }else if(type==3){//cylinder 
    nZone_ShapeInfoCylinder mpZone;
      MtAABB mZoneBoundingBox;
  }else if(type==6){//cone 
    nZone_ShapeInfoCone mpZone;
      MtAABB mZoneBoundingBox;
  }else if(type==8){//AABB 
    nZone_ShapeInfoAABB mpZone;
    MtVector3 ke;
  }
  else if(type==9){// OBB 
    nZone_ShapeInfoOBB mpZone;
      MtAABB mZoneBoundingBox;
  } else{
    nZone_ShapeInfoBase mpZone;//*
      MtAABB mZoneBoundingBox;
  }


};

struct rStageCustomPartsEx_AreaParam
{
  bool mUseAllFilter;
  s32 mFilterNo;
  s32 mPatternNo;
  u32 num;
  AreaHitShape mAreaHitShapeList[num];
  //char mComment[];
};

struct rStageCustom_Area
{
  s8 mAreaNo;
  u8 mFilterNo;
  s32 mGroupNo;
};



struct rStageCustomPartsEx_InfoEx
{
  char mModel[];
  char mScrSbc1[];
  char mEffSbc1[];  
  char mScrSbc2[];
  char mEffSbc2[];  
  char mScrSbc3[];
  char mEffSbc3[];
  char mLight[];
  char mNaviMesh[];
  char mEpv[];
  char mOccluder[];
  
  u16 mAreaNo;
  u16 mType;
  u32 mSize;
  float mOffsetZ;
  s32 mEpvIndexAlways;
  s32 mEpvIndexDay;
  s32 mEpvIndexNight;
  MtColor mColor;

  u64 mEfcColorZone;
  u64 mEfcCtrlZone;
  u64 mIndoorZoneScr;
  u64 mIndoorZoneEfc;
  u64 mLightAndFogZone;
  u64 mSoundAreaInfo;
  u64 mZoneUnitCtrl[3];
  u64 mZoneStatus;
  
  char mComment[];
  
  u32 mAddVersion;
  if(mAddVersion>0){
    //u32 num;
    rStageCustomPartsEx_AreaParam mAreaParamList[mAddVersion];
  }
};

struct rStageCustomParts_Filter
{
  char mFilter[];
};

struct rStageCustomParts_Param
{
  float mDelta;
  float mOffsetY;
};

struct rStageCustomPartsEx
{
  rStageCustomParts_Param mParam;
  u32 mArrayInfoNum;  
  rStageCustomPartsEx_InfoEx mpArrayInfo[mArrayInfoNum];
  u32 mArrayFilterNum;
  rStageCustomParts_Filter mpArrayFilter[mArrayFilterNum];
  
  u32 mArrayColorFogNum;  
  rStageCustomPartsEx_ColorFog mpArrayColorFog[mArrayColorFogNum];
  u32 mArrayHemiSphLightNum;  
  rStageCustomPartsEx_HemiSphLight mpArrayHemiSphLight[mArrayHemiSphLightNum];
  u32 mArrayInfiLightNum;
  rStageCustomPartsEx_InfiLight mpArrayInfiLight[mArrayInfiLightNum];
  u32 mArrayPatternNum;
  rStageCustomPartsEx_Pattern mpArrayPattern[mArrayPatternNum];
};

rStageCustomPartsEx rstagecustomparts_at_0x08 @ 0x08;