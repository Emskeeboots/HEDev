//::///////////////////////////////////////////////
//:: v2_inc_craft
//:://////////////////////////////////////////////
/*
    special crafting functions unique to Arnheim mods
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 nov 12)
//:: Modified: The Magus (2012 jul 27) longcoats
//:: Modified: The Magus (2012 oct 29) many coats and color fix

//:://////////////////////////////////////////////

#include "_inc_constants"
#include "_inc_util"

#include "x2_inc_itemprop"

// CONSTANTS
const int ROBE_CASUAL   = 3;
const int ROBE_VESTMENT = 4;
const int ROBE_MAGI1    = 5;
const int ROBE_MAGI2    = 6;
const int ROBE_LONGCOAT1= 20;
const int ROBE_LONGCOAT2= 21;
const int ROBE_TRAVELER = 24;
const int ROBE_COWL     = 25;
const int ROBE_ALIEN    = 26;
const int ROBE_SKIRT    = 27;
const int ROBE_TUNIC1   = 29;
const int ROBE_SMOCK    = 38;
const int ROBE_TUNIC2   = 46;
const int ROBE_FCOAT    = 112;
const int ROBE_PARKA    = 121;

const int COLOR_LEATH1  = 1;
const int COLOR_LEATH2  = 2;
const int COLOR_CLOTH1  = 4;
const int COLOR_CLOTH2  = 8;
const int COLOR_METAL1  = 16;
const int COLOR_METAL2  = 32;

//DECLARATIONS

// Stores the part indexes on the Armor if they are not yet set
// [file: v2_inc_craft]
void InitializeArmorData(object oItem);

// Stores the robe index on the Armor if it is not yet set
// Intention is to enable the armor to be restored to its base robe appearance when a robe is removed.
// [file: v2_inc_craft]
void InitializeArmorRobe(object oItem, int bFirst=FALSE);

// Looks at robe index and determines whether it is a "coat"
// [file: v2_inc_craft]
int GetIsCoat(int nRobe);

// Determines whether nColor bit is set in local int ARMOR_COLOR_MASK
// nColor values are in constants COLOR_LEATH1, COLOR_LEATH2 etc...
// a true result means that the robe receives/presents the color - and thus masks the underlying armor
// [file: v2_inc_craft]
int GetIsMasked(object oArmor, int nColor);

// Creates the robe's color mask from its color tag (last 18 characters of tag)
// and sets the mask on the armor object as local int ARMOR_COLOR_MASK
// [file: v2_inc_craft]
void CreateMask(object oArmor, string sRef);

// Extracts the color value from the robe's color tag (last 18 characters of tag)
// [file: v2_inc_craft]
int GetRobeColor(string sTag, int nColor);

// Transfers Data from oOld to oNew (useful for custom/special armors)
// [file: v2_inc_craft]
void UpdateArmorData(object oNew, object oOld);

// Gets the robe appearance and creates a resref for the item
// [file: v2_inc_craft]
string CreateUsedRobeResRef(object oUsed);

// Gets the color from teh object and creates a color tag for it
// [file: v2_inc_craft]
string CreateUsedRobeColorTag(object oUsed);

// Gets the color from the armor and creates a color tag for the robe that was worn
// [file: v2_inc_craft]
string CreateAvailableRobeColorTag(object oArmor);

// Stores armor color in local variables (should only run during armor initialization)
// [file: v2_inc_craft]
void SetArmorColorData(object oArmor, int bFirst=FALSE);

// When putting on a robe apply the robe's colors.
// returns armor
// [file: v2_inc_craft]
object ApplyColorToArmor(object oArmor, string sColorTag="");

// When removing a robe restore the armor's color.
// returns armor
// [file: v2_inc_craft]
object RestoreArmorColor(object oArmor, object oPC);

// Finds armor on the PC matching the sRef
// if more than one is found it selects one by tag then destroys it
// otherwise it just destroys the armor matchng the resref
// [file: v2_inc_craft]
void DestroyArmor(object oPC,string sRef,string sTag);

// Returns a robe object used to add a robe to the new armor
// if it returns self, object identified by local string "ROBE_AVAILABLE" was used instead.
// [file: v2_inc_craft]
object GetRobeUsed(object oOld, object oPC, int nNewRobe);

// Returns armor with a default robe appearance.
// [file: v2_inc_craft]
object RemoveArmorRobe(object oOld, object oPC);

// Performs a special swap of armor (eg. woodsman to woodsman_parka)
// if nNewRobe==0, remove special robe
// [file: v2_inc_craft]
object CreateArmorSpecial(object oOld, object oPC, int nNewRobe=0);

// Returns armor with a robe of index nNewRobe.
// [file: v2_inc_craft]
object SwapArmorRobe(object oOld, object oPC, int nNewRobe);

// Given a robe index, copies the existing armor, adds the robe index, and returns the new armor item.
// [file: v2_inc_craft]
object CopyAndModifyRobe(object oArmor, int nRobeType);

// Sets the quality property on the item, mimicking iprp_quality.2da  - [FILE: v2_inc_craft]
void SetItemQuality(string sQuality, object oItem);

//IMPLEMENTATION ---------------------------------------------------------------

void InitializeArmorData(object oItem)
{
    int nInitialized    = GetLocalInt(oItem, "ARMOR_DATA_INITIALIZED");
    int nRobe           = GetLocalInt(oItem, "ARMOR_BASE"+IntToString(ITEM_APPR_ARMOR_MODEL_ROBE));
    // robe is a special case
    if(!nRobe || nRobe!=GetItemAppearance(oItem,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE))
        InitializeArmorRobe(oItem, (nInitialized==FALSE));

    // only do once
    if(nInitialized)
        return;

    int nModelType;
    int nOrig; int nCurrent;
    string sModelLabel;
    for(nModelType=0; nModelType<ITEM_APPR_ARMOR_MODEL_ROBE; nModelType++ )
    {
      if(nModelType!=ITEM_APPR_ARMOR_MODEL_NECK)
      {
        sModelLabel  = "ARMOR_BASE"+IntToString(nModelType);
        nOrig   = GetLocalInt(oItem,sModelLabel);
        if(!nOrig)
        {
            nCurrent    = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelType);
            SetLocalInt(oItem, sModelLabel,nCurrent);
        }
      }
    }

    // we have initialized the armor so set the flag
    SetLocalInt(oItem, "ARMOR_DATA_INITIALIZED", TRUE);
}

void InitializeArmorRobe(object oItem, int bFirst=FALSE)
{
    // Initialize Armor Data - store base robe appearance on item
    int nRobeCurrent= GetItemAppearance(oItem,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE);

    if(!GetIsCoat(nRobeCurrent))
    {
        if(bFirst)
            SetLocalInt(oItem, "ARMOR_BASE"+IntToString(ITEM_APPR_ARMOR_MODEL_ROBE), nRobeCurrent);
        SetLocalInt(oItem, "ARMOR_ROBE_APPEARANCE", nRobeCurrent);
    }
    else
    {
        //if(!GetLocalInt(oItem,"ARMOR_COLOR_MASK"))
        //{
            string sRefRobe = "robe";
            if(nRobeCurrent<100)
                sRefRobe+="0";
            if(nRobeCurrent<10)
                sRefRobe+="0";
            sRefRobe+=IntToString(nRobeCurrent);
            CreateMask(oItem,sRefRobe);
        //}
    }

    SetArmorColorData(oItem, bFirst);
}

int GetIsCoat(int nRobe)
{
    if(     nRobe == ROBE_CASUAL
        ||  nRobe == ROBE_VESTMENT
        ||  nRobe == ROBE_TRAVELER
        ||  nRobe == ROBE_COWL
        ||  nRobe == ROBE_PARKA
        ||  nRobe == ROBE_LONGCOAT1
        ||  nRobe == ROBE_LONGCOAT2
        ||  nRobe == ROBE_SMOCK
        ||  nRobe == ROBE_MAGI1
        ||  nRobe == ROBE_MAGI2
        ||  nRobe == ROBE_SKIRT
        ||  nRobe == ROBE_TUNIC1
        ||  nRobe == ROBE_TUNIC2
        ||  nRobe == ROBE_ALIEN
        ||  nRobe == ROBE_FCOAT
      )
        return TRUE;
    else
        return FALSE;
}

int GetIsMasked(object oArmor, int nColor)
{
    int nMask   = GetLocalInt(oArmor,"ARMOR_COLOR_MASK");
    if (nMask & nColor)
        return TRUE;
    else
        return FALSE;
}

void CreateMask(object oArmor, string sRef)
{
    int nMask;
    int nRobe = StringToInt(GetStringRight(sRef,3));

    if(     nRobe == ROBE_CASUAL
        ||  nRobe == ROBE_COWL
        ||  nRobe == ROBE_TUNIC2
      )
        nMask = 13;
    else if(    nRobe == ROBE_LONGCOAT1
            ||  nRobe == ROBE_LONGCOAT2
            ||  nRobe == ROBE_SMOCK
           )
        nMask = 1;
    else if(    nRobe == ROBE_VESTMENT
            ||  nRobe == ROBE_ALIEN
            ||  nRobe == ROBE_MAGI2
           )
        nMask = 63;
    else if(    nRobe == ROBE_PARKA
            ||  nRobe == ROBE_TUNIC1
           )
        nMask = 12;
    else if(    nRobe == ROBE_MAGI1 )
        nMask = 58;
    else if(nRobe == ROBE_SKIRT)
        nMask = 5;
    else if(nRobe == ROBE_FCOAT)
        nMask = 4;
    else if(nRobe == ROBE_TRAVELER)
        nMask = 15;
    else
        nMask = 0;
    SetLocalInt(oArmor, "ARMOR_COLOR_MASK", nMask);
}

void UpdateArmorData(object oNew, object oOld)
{
    // Store base robe appearance on item
    int nRobeCurrent= GetItemAppearance(oNew,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE);

    if(!GetIsCoat(nRobeCurrent))
        SetLocalInt(oNew, "ARMOR_ROBE_APPEARANCE", nRobeCurrent);
    else
    {
        SetLocalInt(oNew, "ARMOR_ROBE_APPEARANCE", GetLocalInt(oOld, "ARMOR_ROBE_APPEARANCE"));
        string sRefRobe = "robe";
        if(nRobeCurrent<100)
            sRefRobe+="0";
        if(nRobeCurrent<10)
            sRefRobe+="0";
        sRefRobe+=IntToString(nRobeCurrent);
        CreateMask(oNew,sRefRobe);
    }

    // Colors
    SetLocalInt(oNew,"ARMOR_COLOR_BASE_LEATH1", GetLocalInt(oOld,"ARMOR_COLOR_BASE_LEATH1") );
    SetLocalInt(oNew,"ARMOR_COLOR_MOD_LEATH1",  GetLocalInt(oOld,"ARMOR_COLOR_MOD_LEATH1") );
    SetLocalInt(oNew,"ARMOR_COLOR_BASE_LEATH2", GetLocalInt(oOld,"ARMOR_COLOR_BASE_LEATH2") );
    SetLocalInt(oNew,"ARMOR_COLOR_MOD_LEATH2",  GetLocalInt(oOld,"ARMOR_COLOR_MOD_LEATH2") );
    SetLocalInt(oNew,"ARMOR_COLOR_BASE_CLOTH1", GetLocalInt(oOld,"ARMOR_COLOR_BASE_CLOTH1") );
    SetLocalInt(oNew,"ARMOR_COLOR_MOD_CLOTH1",  GetLocalInt(oOld,"ARMOR_COLOR_MOD_CLOTH1") );
    SetLocalInt(oNew,"ARMOR_COLOR_BASE_CLOTH2", GetLocalInt(oOld,"ARMOR_COLOR_BASE_CLOTH2") );
    SetLocalInt(oNew,"ARMOR_COLOR_MOD_CLOTH2",  GetLocalInt(oOld,"ARMOR_COLOR_MOD_CLOTH2") );
    SetLocalInt(oNew,"ARMOR_COLOR_BASE_METAL1", GetLocalInt(oOld,"ARMOR_COLOR_BASE_METAL1") );
    SetLocalInt(oNew,"ARMOR_COLOR_MOD_METAL1",  GetLocalInt(oOld,"ARMOR_COLOR_MOD_METAL1") );
    SetLocalInt(oNew,"ARMOR_COLOR_BASE_METAL2", GetLocalInt(oOld,"ARMOR_COLOR_BASE_METAL2") );
    SetLocalInt(oNew,"ARMOR_COLOR_MOD_METAL2",  GetLocalInt(oOld,"ARMOR_COLOR_MOD_METAL2") );
}

string CreateUsedRobeResRef(object oUsed)
{
    int nRobe   = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE);

    // Error checking
    if(!GetIsObjectValid(oUsed) || !GetIsCoat(nRobe))
        return ""; // ERROR

    // Create ResRef
    string sRef = "robe";
    if(nRobe<100)
        sRef+= "0";
    if(nRobe<10)
        sRef+= "0";
    sRef+=IntToString(nRobe);

    return sRef;
}

string CreateUsedRobeColorTag(object oUsed)
{
    if(!GetIsObjectValid(oUsed))
        return "";

    string sColorTag;
    int nL1, nL2, nC1, nC2, nM1, nM2;
    nL1 = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_COLOR,ITEM_APPR_ARMOR_COLOR_LEATHER1)+176;
        sColorTag+=IntToString(nL1);
    nL2 = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_COLOR,ITEM_APPR_ARMOR_COLOR_LEATHER2)+176;
        sColorTag+=IntToString(nL2);
    nC1 = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_COLOR,ITEM_APPR_ARMOR_COLOR_CLOTH1)+176;
        sColorTag+=IntToString(nC1);
    nC2 = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_COLOR,ITEM_APPR_ARMOR_COLOR_CLOTH2)+176;
        sColorTag+=IntToString(nC2);
    nM1 = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_COLOR,ITEM_APPR_ARMOR_COLOR_METAL1)+176;
        sColorTag+=IntToString(nM1);
    nM2 = GetItemAppearance(oUsed,ITEM_APPR_TYPE_ARMOR_COLOR,ITEM_APPR_ARMOR_COLOR_METAL2)+176;
        sColorTag+=IntToString(nM2);

    return sColorTag;
}

string CreateAvailableRobeColorTag(object oArmor)
{
    string sColorTag;
    int nL1, nL2, nC1, nC2, nM1, nM2;
    nL1 = GetLocalInt(oArmor,"ARMOR_COLOR_MOD_LEATH1");
        sColorTag+=IntToString(nL1);
    nL2 = GetLocalInt(oArmor,"ARMOR_COLOR_MOD_LEATH2");
        sColorTag+=IntToString(nL2);
    nC1 = GetLocalInt(oArmor,"ARMOR_COLOR_MOD_CLOTH1");
        sColorTag+=IntToString(nC1);
    nC2 = GetLocalInt(oArmor,"ARMOR_COLOR_MOD_CLOTH2");
        sColorTag+=IntToString(nC2);
    nM1 = GetLocalInt(oArmor,"ARMOR_COLOR_MOD_METAL1");
        sColorTag+=IntToString(nM1);
    nM2 = GetLocalInt(oArmor,"ARMOR_COLOR_MOD_METAL2");
        sColorTag+=IntToString(nM2);

    return sColorTag;
}

int GetRobeColor(string sTag, int nColor)
{
    return StringToInt(GetSubString(sTag, nColor*3, 3));
}

void SetArmorColorData(object oArmor, int bFirst=FALSE)
{
    int bCoat   = GetIsCoat(GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE));

    int nLeath1 = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
    if(!bCoat || !GetIsMasked(oArmor, COLOR_LEATH1))
        SetLocalInt(oArmor,"ARMOR_COLOR_BASE_LEATH1",nLeath1+176);
    if(bFirst)
        SetLocalInt(oArmor,"ARMOR_COLOR_MOD_LEATH1",nLeath1+176);

    int nLeath2 = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
    if(!bCoat || !GetIsMasked(oArmor, COLOR_LEATH2))
        SetLocalInt(oArmor,"ARMOR_COLOR_BASE_LEATH2",nLeath2+176);
    if(bFirst)
        SetLocalInt(oArmor,"ARMOR_COLOR_MOD_LEATH2",nLeath2+176);

    int nCloth1 = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
    if(!bCoat || !GetIsMasked(oArmor, COLOR_CLOTH1))
        SetLocalInt(oArmor,"ARMOR_COLOR_BASE_CLOTH1",nCloth1+176);
    if(bFirst)
        SetLocalInt(oArmor,"ARMOR_COLOR_MOD_CLOTH1",nCloth1+176);

    int nCloth2 = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
    if(!bCoat || !GetIsMasked(oArmor, COLOR_CLOTH2))
        SetLocalInt(oArmor,"ARMOR_COLOR_BASE_CLOTH2",nCloth2+176);
    if(bFirst)
        SetLocalInt(oArmor,"ARMOR_COLOR_MOD_CLOTH2",nCloth2+176);

    int nMetal1 = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
    if(!bCoat || !GetIsMasked(oArmor, COLOR_METAL1))
        SetLocalInt(oArmor,"ARMOR_COLOR_BASE_METAL1",nMetal1+176);
    if(bFirst)
        SetLocalInt(oArmor,"ARMOR_COLOR_MOD_METAL1",nMetal1+176);

    int nMetal2 = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);
    if(!bCoat || !GetIsMasked(oArmor, COLOR_METAL2))
        SetLocalInt(oArmor,"ARMOR_COLOR_BASE_METAL2",nMetal2+176);
    if(bFirst)
        SetLocalInt(oArmor,"ARMOR_COLOR_MOD_METAL2",nMetal2+176);
}

object ApplyColorToArmor(object oArmor, string sTagColor="")
{
    int nL1, nL2, nC1, nC2, nM1, nM2, nTemp;
    object oTemp = oArmor;
    object oOrig = oTemp;

    if(sTagColor=="")
        sTagColor = GetStringRight(GetTag(oArmor),18);

    CreateMask(oArmor, CreateUsedRobeResRef(oArmor));

    if(GetIsMasked(oArmor, COLOR_LEATH1))
    {
        nTemp   = GetRobeColor(sTagColor, 0);
        nL1     = nTemp-176;
        if(nL1>-1)
        {
            oOrig = oTemp;
            oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, nL1, TRUE);
            SetLocalInt(oTemp,"ARMOR_COLOR_MOD_LEATH1",nTemp);
            DestroyObject(oOrig);
        }
    }
    if(GetIsMasked(oArmor, COLOR_LEATH2))
    {
        nTemp   = GetRobeColor(sTagColor, 1);
        nL2     = nTemp-176;
        if(nL2>-1)
        {
            oOrig = oTemp;
            oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, nL2, TRUE);
            SetLocalInt(oTemp,"ARMOR_COLOR_MOD_LEATH2",nTemp);
            DestroyObject(oOrig);
        }
    }
    if(GetIsMasked(oArmor, COLOR_CLOTH1))
    {
        nTemp   = GetRobeColor(sTagColor, 2);
        nC1     = nTemp-176;
        if(nC1>-1)
        {
            oOrig = oTemp;
            oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, nC1, TRUE);
            SetLocalInt(oTemp,"ARMOR_COLOR_MOD_CLOTH1",nTemp);
            DestroyObject(oOrig);
        }
    }
    if(GetIsMasked(oArmor, COLOR_CLOTH2))
    {
        nTemp   = GetRobeColor(sTagColor, 3);
        nC2     = nTemp-176;
        if(nC2>-1)
        {
            oOrig = oTemp;
            oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, nC2, TRUE);
            SetLocalInt(oTemp,"ARMOR_COLOR_MOD_CLOTH2",nTemp);
            DestroyObject(oOrig);
        }
    }
    if(GetIsMasked(oArmor, COLOR_METAL1))
    {
        nTemp   = GetRobeColor(sTagColor, 4);
        nM1     = nTemp-176;
        if(nM1>-1)
        {
            oOrig = oTemp;
            oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, nM1, TRUE);
            SetLocalInt(oTemp,"ARMOR_COLOR_MOD_METAL1",nTemp);
            DestroyObject(oOrig);
        }
    }
    if(GetIsMasked(oArmor, COLOR_METAL2))
    {
        nTemp   = GetRobeColor(sTagColor, 5);
        nM2     = nTemp-176;
        if(nM2>-1)
        {
            oOrig = oTemp;
            oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, nM2, TRUE);
            SetLocalInt(oTemp,"ARMOR_COLOR_MOD_METAL2",nTemp);
            DestroyObject(oOrig);
        }
    }

    // garbage collection for "coats" only. unneeded for armor
    if(oTemp!=oArmor && GetLocalInt(oArmor, "ARMOR_COAT"))
    {
        DestroyObject(oArmor,0.5);
    }
    return oTemp;
}

object RestoreArmorColor(object oArmor, object oPC)
{
    // initialize color data
    int nLeath1 = GetLocalInt(oArmor,"ARMOR_COLOR_BASE_LEATH1")-176;
    if(nLeath1==GetLocalInt(oArmor,"ARMOR_COLOR_MOD_LEATH1")-176) // if colors are same do nothing
        nLeath1=-1;
    int nLeath2 = GetLocalInt(oArmor,"ARMOR_COLOR_BASE_LEATH2")-176;
    if(nLeath2==GetLocalInt(oArmor,"ARMOR_COLOR_MOD_LEATH2")-176) // if colors are same do nothing
        nLeath2=-1;
    int nCloth1 = GetLocalInt(oArmor,"ARMOR_COLOR_BASE_CLOTH1")-176;
    if(nCloth1==GetLocalInt(oArmor,"ARMOR_COLOR_MOD_CLOTH1")-176) // if colors are same do nothing
        nCloth1=-1;
    int nCloth2 = GetLocalInt(oArmor,"ARMOR_COLOR_BASE_CLOTH2")-176;
    if(nCloth2==GetLocalInt(oArmor,"ARMOR_COLOR_MOD_CLOTH2")-176) // if colors are same do nothing
        nCloth2=-1;
    int nMetal1 = GetLocalInt(oArmor,"ARMOR_COLOR_BASE_METAL1")-176;
    if(nMetal1==GetLocalInt(oArmor,"ARMOR_COLOR_MOD_METAL1")-176) // if colors are same do nothing
        nMetal1=-1;
    int nMetal2 = GetLocalInt(oArmor,"ARMOR_COLOR_BASE_METAL2")-176;
    if(nMetal2==GetLocalInt(oArmor,"ARMOR_COLOR_MOD_METAL2")-176) // if colors are same do nothing
        nMetal2=-1;

    // alt armor object
    object oTemp = oArmor;
    object oOrig;

    // restore colors
    if(nLeath1>-1)
    {
        oOrig=oTemp;
        oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, nLeath1, TRUE);
        DestroyObject(oOrig);
    }
    if(nLeath2>-1)
    {
        oOrig=oTemp;
        oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, nLeath2, TRUE);
        DestroyObject(oOrig);
    }
    if(nCloth1>-1)
    {
        oOrig=oTemp;
        oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, nCloth1, TRUE);
        DestroyObject(oOrig);
    }
    if(nCloth2>-1)
    {
        oOrig=oTemp;
        oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, nCloth2, TRUE);
        DestroyObject(oOrig);
    }
    if(nMetal1>-1)
    {
        oOrig=oTemp;
        oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, nMetal1, TRUE);
        DestroyObject(oOrig);
    }
    if(nMetal2>-1)
    {
        oOrig=oTemp;
        oTemp=CopyItemAndModify(oOrig, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, nMetal2, TRUE);
        DestroyObject(oOrig);
    }

    return oTemp;
}

void DestroyArmor(object oPC,string sRef,string sTag)
{
    object oItem= GetFirstItemInInventory(oPC);
    object oFound = OBJECT_INVALID;
    while (GetIsObjectValid(oItem))
    {
        if( GetResRef(oItem)==sRef )
        {
            oFound = oItem;
            if(GetTag(oItem)==sTag)
                break;
        }
        oItem   = GetNextItemInInventory(oPC);
    }

    SetPlotFlag(oFound, FALSE);
    DestroyObject(oFound);
}


object GetRobeUsed(object oOld, object oPC, int nNewRobe)
{
    // Generate ResRef to look for
    string sRef = "robe";
    if(     nNewRobe==ROBE_LONGCOAT1
        ||  nNewRobe==ROBE_LONGCOAT2
      )
        sRef += "020";
    else
    {
        if(nNewRobe<100)
            sRef += "0";
        if(nNewRobe<10)
            sRef += "0";
        sRef += IntToString(nNewRobe);
    }

    string sUsed = GetLocalString(oPC, "ROBE_USED");
    string sAvail= GetLocalString(oPC, "ROBE_AVAILABLE");

    object oItem= GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if( GetResRef(oItem)==sRef && sUsed!=GetTag(oItem) )
            break;
        oItem   = GetNextItemInInventory(oPC);
    }

    // nothing in inventory BUT we were able to use what we had "available" - meaning what we had been wearing
    if(!GetIsObjectValid(oItem) && GetStringLeft(sAvail,7)==sRef )
    {
        // special case in which we reset everything back to the beginning
        DeleteLocalString(oPC, "ROBE_USED");
        DeleteLocalString(oPC, "ROBE_AVAILABLE");
        oItem=oOld;
    }

    return oItem;
}

object CreateArmorSpecial(object oOld, object oPC, int nNewRobe=0)
{
    string sRefOld  = GetResRef(oOld);
    object oNew     = oOld;

    if(nNewRobe>=1)
    {   // add a robe
        if(sRefOld=="woodsman")
        {
            if(nNewRobe==ROBE_PARKA)
            {
                oNew = CreateItemOnObject("woodsman_parka", oPC);
            }
        }
    }
    else
    {   // remove a robe
        string sTag     = GetTag(oOld);
        string sTagMin  = GetStringRight(sTag,GetStringLength(sTag)-7);
        if(sRefOld == "woodsman_parka")
        {
            oNew = CreateItemOnObject("woodsman", oPC);
            if(GetLocalString(oPC, "ROBE_AVAILABLE")=="" && GetLocalString(oPC, "ROBE_USED")=="")
                SetLocalString(oPC, "ROBE_AVAILABLE", "robe121"+sTagMin);
            else
                DeleteLocalString(oPC, "ROBE_USED");
        }
    }

    if (oNew!=oOld)
        UpdateArmorData(oNew, oOld);
    return oNew;
}

object RemoveArmorRobe(object oOld, object oPC)
{
    object oNew = CreateArmorSpecial(oOld, oPC, 0);

    if(oNew==oOld)
    {
        int nOldRobeBase    = GetLocalInt(oOld, "ARMOR_ROBE_APPEARANCE");
        if(nOldRobeBase==-1)
            nOldRobeBase==0;
        int nOldRobeCurrent = GetItemAppearance(oOld,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE);
        oNew    = CopyAndModifyRobe(oOld, nOldRobeBase);

        if(GetIsCoat(nOldRobeCurrent))
        {
            if(GetLocalString(oPC, "ROBE_AVAILABLE")=="" && GetLocalString(oPC, "ROBE_USED")=="")
            {
                string sTagAva = "robe";

              if(nOldRobeCurrent==ROBE_LONGCOAT1 || nOldRobeCurrent==ROBE_LONGCOAT2)
                sTagAva += "020"; //longcoats regardless of appearance always result in robe20 when removed
              else
              {
                if(nOldRobeCurrent<100)
                    sTagAva += "0";
                if(nOldRobeCurrent<10)
                    sTagAva += "0";
                sTagAva += IntToString(nOldRobeCurrent);
              }
                // need to add property tag to sTagAva! //
                // create color tag for this robe
                sTagAva += CreateAvailableRobeColorTag(oNew);

                SetLocalString(oPC, "ROBE_AVAILABLE", sTagAva);
            }
            else
            {
                DeleteLocalString(oPC, "ROBE_USED");
            }
        }
    }

    return RestoreArmorColor(oNew, oPC);
}

object SwapArmorRobe(object oOld, object oPC, int nNewRobe)
{
    object oUsed;
    int nOldRobeCurrent = GetItemAppearance(oOld,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE);
    int nOldRobeBase    = GetLocalInt(oOld, "ARMOR_ROBE_APPEARANCE");

    // special armor-robe check
    object oNew = CreateArmorSpecial(oOld, oPC, nNewRobe);
    if(oNew!=oOld)
    {
        oUsed   = GetRobeUsed(oOld, oPC, nNewRobe);
    }
    else
    {
        // handle other robe changes
        oNew    = CopyAndModifyRobe(oOld, nNewRobe);

        //did anything change?
        if(oNew!=oOld)
        {
            oUsed           = GetRobeUsed(oOld, oPC, nNewRobe);

            // do we need to remove a robe from the old armor?
            if(GetIsCoat(nOldRobeCurrent))
            {   // was this robe/coat worn at the beginning? (a robe not in inventory)
                if(GetLocalString(oPC, "ROBE_AVAILABLE")=="" && GetLocalString(oPC, "ROBE_USED")==""
                    && oUsed!=oOld
                  )
                {
                    // generate new tag for this robe
                    string sTagAva = "robe";
                  if(nOldRobeCurrent==ROBE_LONGCOAT1 || nOldRobeCurrent==ROBE_LONGCOAT2)
                    sTagAva += "020";
                  else
                  {
                    if(nOldRobeCurrent<100)
                        sTagAva += "0";
                    if(nOldRobeCurrent<10)
                        sTagAva += "0";
                    sTagAva += IntToString(nOldRobeCurrent);
                  }
                    // need to add property tag to sTagAva! //
                    // create color tag for this robe
                    //sTagAva += CreateAvailableRobeColorTag(oNew);
                    sTagAva += CreateAvailableRobeColorTag(oOld);
                    // ROBE_AVAILABLE is the robe worn at the beginning
                    SetLocalString(oPC, "ROBE_AVAILABLE", sTagAva);
                }
            }
        }
    }

    // update
    if(oUsed!=oOld)
    {
        // Create tag of robe used
        string sRef     = CreateUsedRobeResRef(oUsed); // ResRef
        /* need item properties tag generator */
        string sColorTag = CreateUsedRobeColorTag(oUsed); // Color

        SetLocalString(oPC, "ROBE_USED",GetTag(oUsed));

        // restore color
        oNew    = RestoreArmorColor(oNew, oPC);

        // apply mask to armor
        CreateMask(oNew, sRef);

        // update color appearance of armor
        oNew = ApplyColorToArmor(oNew, sColorTag);
    }

    return oNew;
}

object CopyAndModifyRobe(object oArmor, int nRobeType)
{
    // longcoats can have one of two appearances
    if(nRobeType==ROBE_LONGCOAT1 || nRobeType==ROBE_LONGCOAT2)
    {
        int nChest          = GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO);
        string sMaterial    = Get2DAString("parts_chest_x", "MATERIAL", nChest);
        if(     sMaterial=="chain"
            ||  sMaterial=="plate"
            ||  sMaterial=="scale"
          )
            nRobeType=ROBE_LONGCOAT2;
        else
            nRobeType=ROBE_LONGCOAT1;
    }

    object oRet = CopyItemAndModify(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_ROBE,nRobeType,TRUE);
    if (GetIsObjectValid(oRet))
    {
        return oRet;
    }
    else // safety net
    {
        return oArmor;
    }
}

void SetItemQuality(string sQuality, object oItem)
{
    int nQuality;
    sQuality    = GetStringLowerCase(sQuality);
    if(sQuality=="destroyed")
        nQuality = 1;
    else if(sQuality=="ruined")
        nQuality = 2;
    else if(sQuality=="very_poor" || sQuality=="verypoor")
        nQuality = 3;
    else if(sQuality=="poor")
        nQuality = 4;
    else if(sQuality=="below_average" || sQuality=="belowaverage")
        nQuality = 5;
    else if(sQuality=="average")
        nQuality = 6;
    else if(sQuality=="above_average" || sQuality=="aboveaverage")
        nQuality = 7;
    else if(sQuality=="good")
        nQuality = 8;
    else if(sQuality=="very_good" || sQuality=="verygood")
        nQuality = 9;
    else if(sQuality=="excellent")
        nQuality = 10;
    else if(sQuality=="masterwork")
        nQuality = 11;
    else if(sQuality=="godlike")
        nQuality = 12;
    else if(sQuality=="raw")
        nQuality = 13;
    else if(sQuality=="cut")
        nQuality = 14;
    else if(sQuality=="polished")
        nQuality = 15;

    if(nQuality)
    {
        itemproperty ip = ItemPropertyQuality(nQuality);
        IPSafeAddItemProperty(oItem, ip);
    }
}

//void main(){}
