//::///////////////////////////////////////////////
//:: _inc_vfx
//:://////////////////////////////////////////////
/*
    Modified from Aligned Head Visual Effects package
        and expanded to include Q masks and Project Q's 2da
    Tile Magic also included
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 27)
//:: Modified:
//:://////////////////////////////////////////////

#include "x3_inc_skin"
#include "x2_inc_toollib"
#include "sj_tilemagic_i"

// Visual Effect constants
const int HEAD_EFFECTS_NONE     = 0;

const int HEAD_EFFECTS_HAIR     = 1;// burning hair, halos
const int HEAD_EFFECTS_EYES     = 2;// eyes, eye patches
const int HEAD_EFFECTS_HORNS    = 4;// horns, helms
const int HEAD_EFFECTS_MASK     = 8;// masks, veils
const int HEAD_EFFECTS_CROWN    = 16;// crown, hat

const int HEAD_EFFECTS_ALL      = 127;


const int BODY_EFFECTS_QUIVER   = 128;
const int BODY_EFFECTS_ARROWS   = 256;
const int BODY_EFFECTS_NECK     = 512;
const int BODY_EFFECTS_SHOULDERS= 1024; // scarf
const int BODY_EFFECTS_PET      = 2048; // mounted familiars and pirate parrots
const int BODY_EFFECTS_TOOL     = 4096; // musical instruments or anything else in hand

const int BODY_EFFECTS_ALL      = 8064;

const int PERSONAL_EFFECTS_ALL  = 8192;






// HEAD ALIGNED VFX
// Eyes:
const int VFX_EYES_BLUE     = 324;
const int VFX_EYES_RED      = 360;
const int VFX_EYES_YELLOW   = 373;
const int VFX_EYES_ORANGE   = 386;
const int VFX_EYES_GREEN    = 567;
const int VFX_EYES_PURPLE   = 580;
const int VFX_EYES_CYAN     = 593;
const int VFX_EYES_WHITE    = 606;
const int VFX_EYES_BURNTOUT = 682;
// Horns:
const int VFX_HORNS_MEPH    = 1005;
const int VFX_HORNS_OX      = 1017;
const int VFX_HORNS_ROTHE   = 1029;
const int VFX_HORNS_BALOR   = 1041;
const int VFX_HORNS_ANTLERS = 1053;
const int VFX_HORNS_DRAGON  = 1065;
const int VFX_HORNS_RAM     = 1077;
const int VFX_HORNS_DEMON   = 1089;
// Helms:
const int VFX_HELM_05 = 2444;
const int VFX_HELM_08 = 2456;
const int VFX_HELM_09 = 2468;
const int VFX_HELM_12 = 2480;
const int VFX_HELM_13 = 2492;
const int VFX_HELM_14 = 2504;
const int VFX_HELM_16 = 2516;
const int VFX_HELM_17 = 2528;
const int VFX_HELM_20 = 2540;
const int VFX_HELM_24 = 2552;
const int VFX_HELM_28 = 2564;
const int VFX_HELM_29 = 2576;
const int VFX_HELM_30 = 2588;
const int VFX_HELM_32 = 2600;
// Hair:
const int VFX_HAIR_FIRE     = 1113;
// Masks:
const int VFX_MASK_PLAIN_BLACK  = 814;



// BODY ALIGNED VFX
// Neck
const int NECK_TORC_00          = 2000;
const int NECK_TORC_01          = 2012;
const int NECK_TORC_02          = 2024;
// Quiver and arrows
const int BODY_QUIVER           = 1700;
const int BODY_ARROWS           = 1832;

// Shoulder animals:
const int PET_SPIRIT            = 2084;
const int PET_RAVEN             = 2096;
const int PET_PARROT            = 2108;
const int PET_BAT               = 2120;
const int PET_CROW              = 2132;
const int PET_SEAGULL           = 2144;
const int PET_FALCON            = 2156;
const int PET_PARROT_RED        = 2168;
const int PET_PARROT_GREEN      = 2180;

// Tools:
const int TOOL_BANJO            = 2312;
const int TOOL_GUITAR           = 2324;
const int TOOL_LUTE             = 2336;

// Values for nVFXColor
// Grey    0   // quiver only
// Brown   1
// White   2
// Black   3
// Red     4
// Yellow  5
// Green   6
// Aqua    7
// Blue    8
// Purple  9
// Orange  10  //arrows only
int GetArrowColorFromTag(string sTag);
// - [FILE: _inc_vfx]
// Constants for nVFXIndex  BODY_QUIVER or BODY_ARROWS
// Values for nColor
// Grey    0   // quiver only
// Brown   1
// White   2
// Black   3
// Red     4
// Yellow  5
// Green   6
// Aqua    7
// Blue    8
// Purple  9
// Orange  10  //arrows only
int getArrowColorEffect(int nVFXIndex, int nColor);
// - [FILE: _inc_vfx]
// Provides a modifier to the VFX index for race and gender
int getVFXModifier(int nVFXType, object oTarget);
// - [FILE: _inc_vfx]
// for any kind of personal VFX that persist on a creature
// color is for arrows or quivers. see getArrowColorEffect()
// stores the VFX in data
void ApplyPersonalVFX(object oTarget, int nVFXType, int nVFXIndex, int nColor=1);
// - [FILE: _inc_vfx]
// Restores personal vfx after an object's visual effects are removed
// Called by module's rest and respawn scripts
void RestorePersonalVFX(object oTarget);
// - [FILE: _inc_vfx]
// This function removes personal VFX from oTarget by type
// PERSONAL_EFFECTS_ALL removes all effects
// HEAD_EFFECTS_ALL removes only head effects
// BODY_EFFECTS_ALL removes only body effects
// specific effect types: HEAD_EFFECTS_HAIR, HEAD_EFFECTS_EYES, HEAD_EFFECTS_HORNS, HEAD_EFFECTS_MASK
// BODY_EFFECTS_PET, BODY_EFFECTS_NECK, BODY_EFFECTS_QUIVER, BODY_EFFECTS_ARROWS
void RemovePersonalVFX(object oTarget, int nVFXType = PERSONAL_EFFECTS_ALL);

// returns the Z height of the ground for the tileset of oArea - [FILE: _inc_vfx]
float GetTilesetZOffset(object oArea=OBJECT_SELF);
// handles all area tilemagic set on area as local variables - [FILE: _inc_vfx]
// Must be executed by an area
void DoAreaTilesetMagic(int bReset=FALSE);


int GetArrowColorFromTag(string sTag)
{
    sTag    = GetStringLowerCase(sTag);
    if(FindSubString(sTag, "brown")!=-1)
        return 1;
    else if(FindSubString(sTag, "white")!=-1)
        return 2;
    else if(FindSubString(sTag, "black")!=-1)
        return 3;
    else if(FindSubString(sTag, "red")!=-1)
        return 4;
    else if(FindSubString(sTag, "yellow")!=-1)
        return 5;
    else if(FindSubString(sTag, "green")!=-1)
        return 6;
    else if(FindSubString(sTag, "aqua")!=-1)
        return 7;
    else if(FindSubString(sTag, "blue")!=-1)
        return 8;
    else if(FindSubString(sTag, "purple")!=-1)
        return 9;
    else if(FindSubString(sTag, "orange")!=-1)
        return 10;

    return 0;
}
int getArrowColorEffect(int nVFXIndex, int nColor)
{
    return (nVFXIndex + (nColor*12));
}

int getVFXModifier(int nVFXType, object oTarget)
{
    int PCRace = GetRacialType(oTarget);
    int PCGender = GetGender(oTarget);
    int raceMod, genderMod, nEffectMod;

 if(nVFXType==HEAD_EFFECTS_EYES)
 {
    if(PCRace == RACIAL_TYPE_HUMAN || PCRace == RACIAL_TYPE_HALFELF)
        raceMod = 0;
    else if(PCRace == RACIAL_TYPE_DWARF)
        raceMod = 1;
    else if(PCRace == RACIAL_TYPE_ELF)
        raceMod = 2;
    else if(PCRace == RACIAL_TYPE_GNOME)
        raceMod = 3;
    else if(PCRace == RACIAL_TYPE_HALFLING)
        raceMod = 4;
    else if(PCRace == RACIAL_TYPE_HALFORC)
        raceMod = 5;
    else
    {
        SendMessageToPC(oTarget, "Warning: you are not a supported race. Only human, elf, dwarf, halfling, gnome, half-elf and half-orc characters are supported.");
        raceMod = 1;
    }

    if(PCGender == GENDER_FEMALE)
        genderMod = 1;
    else if(PCGender == GENDER_MALE)
        genderMod = 0;
    else
    {
        SendMessageToPC(oTarget, "Warning: you are not a supported gender. Only female and male characters are supported.");
        genderMod = 0;
    }
    nEffectMod = (2*raceMod)+genderMod;
 }
 else
 {
    if(PCRace == RACIAL_TYPE_HUMAN || PCRace == RACIAL_TYPE_HALFELF)
        raceMod = 4;
    else if(PCRace == RACIAL_TYPE_HALFLING)
        raceMod = 0;
    else if(PCRace == RACIAL_TYPE_DWARF)
        raceMod = 1;
    else if(PCRace == RACIAL_TYPE_ELF)
        raceMod = 2;
    else if(PCRace == RACIAL_TYPE_GNOME)
        raceMod = 3;
    else if(PCRace == RACIAL_TYPE_HALFORC)
        raceMod = 5;
    else
    {
        SendMessageToPC(oTarget, "Warning: you are not a supported race. Only human, elf, dwarf, halfling, gnome, half-elf and half-orc characters are supported.");
        raceMod = 5;
    }

    if(PCGender == GENDER_FEMALE)
        genderMod = 1;
    else if(PCGender == GENDER_MALE)
        genderMod = 0;
    else
    {
        SendMessageToPC(oTarget, "Warning: you are not a supported gender. Only female and male characters are supported.");
        genderMod = 0;
    }
    nEffectMod = (2*raceMod)+genderMod;
 }

    return nEffectMod;
}

void ApplyPersonalVFX(object oTarget, int nVFXType, int nVFXIndex, int nColor=1)
{
    string sVFXType = "ERROR";

    if( nVFXType==BODY_EFFECTS_QUIVER )
    {
        sVFXType    = "VFX_TYPE_"+IntToString(nVFXType);
        nVFXIndex   = getArrowColorEffect(nVFXIndex, nColor);
    }
    else if( nVFXType==BODY_EFFECTS_ARROWS )
    {
        sVFXType    = "VFX_TYPE_"+IntToString(nVFXType);
        nVFXIndex   = getArrowColorEffect(nVFXIndex, nColor);
    }
    else if(    nVFXType==HEAD_EFFECTS_HAIR
            ||  nVFXType==HEAD_EFFECTS_EYES
            ||  nVFXType==HEAD_EFFECTS_HORNS
            ||  nVFXType==HEAD_EFFECTS_MASK
            ||  nVFXType==HEAD_EFFECTS_CROWN

            ||  nVFXType==BODY_EFFECTS_NECK
            ||  nVFXType==BODY_EFFECTS_SHOULDERS
            ||  nVFXType==BODY_EFFECTS_PET
            ||  nVFXType==BODY_EFFECTS_TOOL
           )
    {
        sVFXType    = "VFX_TYPE_"+IntToString(nVFXType);
    }

    if (sVFXType == "ERROR")
    {
        WriteTimestampedLogEntry("ERR: applyPersonalVFX(). nVFXIndex("+IntToString(nVFXIndex)+") is not a valid index");
    }
    else
    {
        nVFXIndex       = nVFXIndex + getVFXModifier(nVFXType, oTarget);
        effect eEffect  = EffectVisualEffect(nVFXIndex);
               eEffect  = SupernaturalEffect(eEffect);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
        SetSkinInt(oTarget, sVFXType, nVFXIndex);
    }
}


// Restores personal vfx after an object's visual effects are removed
// Called by module's rest and respawn scripts
void RestorePersonalVFX(object oTarget)
{
    int nVFXType = 1;
    int nVFXIndex = 0;
    effect eVFXrestored;

    while (nVFXType < PERSONAL_EFFECTS_ALL)
    {
        nVFXIndex = GetSkinInt(oTarget, "VFX_TYPE_"+IntToString(nVFXType) );

        if(nVFXIndex)
        {
            eVFXrestored    = EffectVisualEffect(nVFXIndex);
            eVFXrestored    = SupernaturalEffect(eVFXrestored);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVFXrestored, oTarget);
        }

        nVFXType   *= 2; // double to reach the next bit (each type is a bit)
    }
}

void RemovePersonalVFX(object oTarget, int nVFXType = PERSONAL_EFFECTS_ALL)
{
    // remove all VFX
    effect eLoop=GetFirstEffect(oTarget);
    while (GetIsEffectValid(eLoop))
    {
         if(    GetEffectType(eLoop) == EFFECT_TYPE_VISUALEFFECT
            &&  GetEffectSpellId(eLoop) == -1
           )
            RemoveEffect(oTarget, eLoop);
        eLoop=GetNextEffect(oTarget);
    }

    // selectively delete the data of the VFX we are removing
    if(nVFXType & HEAD_EFFECTS_HAIR)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_HAIR));
    if(nVFXType & HEAD_EFFECTS_EYES)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_EYES));
    if(nVFXType & HEAD_EFFECTS_HORNS)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_HORNS));
    if(nVFXType & HEAD_EFFECTS_MASK)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_MASK));
    if(nVFXType & HEAD_EFFECTS_CROWN)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_CROWN));
    if(nVFXType & BODY_EFFECTS_PET)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(BODY_EFFECTS_PET));
    if(nVFXType & BODY_EFFECTS_NECK)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(BODY_EFFECTS_NECK));
    if(nVFXType & BODY_EFFECTS_SHOULDERS)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(BODY_EFFECTS_SHOULDERS));
    if(nVFXType & BODY_EFFECTS_QUIVER)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(BODY_EFFECTS_QUIVER));
    if(nVFXType & BODY_EFFECTS_ARROWS)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(BODY_EFFECTS_ARROWS));
    if(nVFXType & BODY_EFFECTS_TOOL)
        DeleteSkinInt(oTarget, "VFX_TYPE_"+IntToString(BODY_EFFECTS_TOOL));
    // restore VFX for which we still have data
    RestorePersonalVFX(oTarget);
}

////////////////////////////////////////////////////////////////////////
// TILESET MAGIC ---------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
float GetTilesetZOffset(object oArea=OBJECT_SELF)
{
    float ZTileAdjust;
    string sTileRef = GetTilesetResRef(oArea);

    if(sTileRef=="tbw01") // Barrows
        ZTileAdjust  = 5.00;

    return ZTileAdjust;
}

void DoAreaTilesetMagic(int bReset=FALSE)
{
    if(bReset)
        SJ_TileMagic_ClearArea(OBJECT_SELF);

    // check "do once" flag
    if(GetLocalInt(OBJECT_SELF, "sj_tilemagic_done"))
        return;

    // water tiles
    if(GetLocalInt(OBJECT_SELF, "AREA_WATER"))
    {
        float fZ    =  GetLocalFloat(OBJECT_SELF, "AREA_WATER_HEIGHT")+GetTilesetZOffset();
        string sRef = GetLocalString(OBJECT_SELF, "AREA_WATER_PLACE");
        int bMist   = GetLocalInt(OBJECT_SELF, "AREA_WATER_MIST");
        if(sRef=="")sRef=SJ_RES_INVISIBLE_OBJECT;
        int nVFX    = GetLocalInt(OBJECT_SELF, "AREA_WATER_EFFECT");
        int nRot    = GetLocalInt(OBJECT_SELF, "AREA_WATER_ROTATION");
        int bNormal;
        if(sRef!="") bNormal = TRUE;

        AssignCommand(  OBJECT_SELF,
                        SJ_TileMagic_CoverArea( OBJECT_SELF, nVFX, fZ, bNormal, nRot, sRef, "water", bMist )
                      );
    }

    // fog tiles
    if(GetLocalInt(OBJECT_SELF, "AREA_FOG"))
    {
        float fZ    =  GetLocalFloat(OBJECT_SELF, "AREA_FOG_HEIGHT")+GetTilesetZOffset();
        string sRef = GetLocalString(OBJECT_SELF, "AREA_FOG_PLACE");
        int bMist   = GetLocalInt(OBJECT_SELF, "AREA_FOG_MIST");
        if(sRef=="")sRef=SJ_RES_INVISIBLE_OBJECT;
        int nVFX    = GetLocalInt(OBJECT_SELF, "AREA_FOG_EFFECT");
        int nRot    = GetLocalInt(OBJECT_SELF, "AREA_FOG_ROTATION");
        int bNormal;
        if(sRef!="") bNormal = TRUE;

        AssignCommand(  OBJECT_SELF,
                        SJ_TileMagic_CoverArea( OBJECT_SELF, nVFX, fZ, bNormal, nRot, sRef, "fog", bMist)
                      );
    }

    // sweep area and convert all markers
    object oObject = GetFirstObjectInArea(OBJECT_SELF);
    while(oObject!=OBJECT_INVALID)
    {
        if(GetTag(oObject)==SJ_TAG_TILEMAGIC_MARKER)
        {
            // markers found: convert
            // NOTE: use AssignCommand avoid the risk of a TMI
            AssignCommand(OBJECT_SELF, SJ_TileMagic_ConvertObjectToTile(oObject, FALSE));
        }
        oObject = GetNextObjectInArea(OBJECT_SELF);
    }

    // raise "do once" flag
    SetLocalInt(OBJECT_SELF, "sj_tilemagic_done", TRUE);
}

//void main() {}
