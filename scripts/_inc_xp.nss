// _inc_xp.nss
// XP system routines

#include "_inc_util"
#include "tb_inc_util"

// TAG PREFIXES
const string TAG_QUEST          = "QUEST_";
const string TAG_ENTRY          = "ENTRY_";
const string TAG_CRAFT          = "CRAFT_";
const string TAG_SKILL          = "SKILL_";
const string TAG_KILLS          = "KILLS_";
const string TAG_MAGIC          = "MAGIC_";
const string TAG_XP             = "XP_";

// XP TYPES -- meant to correspond with the enumerated types in the DB's XP table
const int XP_TYPE_QUEST     = 1;
const int XP_TYPE_AREA      = 2;
const int XP_TYPE_DISCOVERY = 3;
const int XP_TYPE_ROLEPLAY  = 4;
const int XP_TYPE_CRAFT     = 5;
const int XP_TYPE_ABILITY   = 6;
const int XP_TYPE_COMBAT    = 7;
const int XP_TYPE_MAGIC     = 8;
const int XP_TYPE_ADJUSTMENT= 9;




// Returns the XP needed by PC to gain a level - [FILE: _inc_util]
// in bNext = FALSE, returns how much total XP is needed for PC's current level
int XPGetPCNeedsToLevel(object oPC, int bNext = TRUE);
// Returns a string name for the type (usable in the mysql DB) - [FILE: _inc_util]
string XPGetTypeName(int nXPType);
// Set XP Modifiers for PC based on class. Taken from Vives. - [FILE: _inc_util]
void XPSetTypeModifier(object oPC, int bDisplayForPlayer=TRUE);
// Get the PC's XP total from the database. - [FILE: v2_inc_util]
// if nType is specified then only the XP for that type is returned
// if campaign_id is specified then only the XP earned for that campaign is returned
int XPRetrieveByType(object oPC, int nType=0, string campaign_id="ANY");
// Record to DB the PC's XP (this can be a penalty or award). - [FILE: _inc_util]
// if nXP is a negative integer this will record a penalty
// it is best to store adjustments to XP (like penalties) using XP_TYPE_ADJUSTMENT
void XPStoreByType(object oPC, int nXP, int nType=XP_TYPE_ADJUSTMENT);
// Give PC an XP penalty - [FILE: _inc_util]
void XPPenalty(object oPC, int nAmount, string sFeedback="", int nType=XP_TYPE_ADJUSTMENT);
// Reward PC with XP - [FILE: _inc_util]
void XPRewardByType(string sRewardTag, object oPC, int iXPReward, int iExperienceType, string sDescription="");
// Reward PC for disarming a trap - [FILE: _inc_util]
void XPRewardDisarmTrap(object oPC, object oTrap);
// Reward PC for picking lock - [FILE: _inc_util]
void XPRewardPickLock(object oPC, object oLocked);
// Reward PC for defeating an adversary in combat - [FILE: _inc_util]
void XPRewardCombat( object oKiller, object oDead, int nCRMod=0 );



int XPGetPCNeedsToLevel(object oPC, int bNext = TRUE)
{
    int nXP;
    int nLevel  = GetHitDice(oPC);
    if(!bNext){--nLevel;}

    switch (nLevel)
    {
        case 0:  nXP=     0; break;
        case 1:  nXP=  1000; break;
        case 2:  nXP=  3000; break;
        case 3:  nXP=  6000; break;
        case 4:  nXP= 10000; break;
        case 5:  nXP= 15000; break;
        case 6:  nXP= 21000; break;
        case 7:  nXP= 28000; break;
        case 8:  nXP= 36000; break;
        case 9:  nXP= 45000; break;
        case 10: nXP= 55000; break;
        case 11: nXP= 66000; break;
        case 12: nXP= 78000; break;
        case 13: nXP= 91000; break;
        case 14: nXP=105000; break;
        case 15: nXP=120000; break;
        case 16: nXP=136000; break;
        case 17: nXP=153000; break;
        case 18: nXP=171000; break;
        case 19: nXP=190000; break;
        case 20: nXP=210000; break;
    }

    if(bNext)
        nXP = nXP - GetXP(oPC);

    return nXP;
}

string XPGetTypeName(int nXPType)
{
    switch(nXPType)
    {
        case XP_TYPE_QUEST:
            return "QUEST";
        case XP_TYPE_AREA:
            return "AREA";
        case XP_TYPE_DISCOVERY:
            return "DISCOVERY";
        case XP_TYPE_ROLEPLAY:
            return "ROLEPLAY";
        case XP_TYPE_CRAFT:
            return "CRAFT";
        case XP_TYPE_ABILITY:
            return "ABILITY";
        case XP_TYPE_COMBAT:
            return "COMBAT";
        case XP_TYPE_MAGIC:
            return "MAGIC";
        case XP_TYPE_ADJUSTMENT:
            return "ADJUSTMENT";
        default:
            return "ADJUSTMENT";
        break;
    }

    return "ADJUSTMENT";
}

// Calculate Differential XP Ratios based on class.
// Originaly scripted by Aria C. Velasco for Vives, 16.02.03
// Cleaned up by Q (the maker of QNX at Vives)
void XPSetTypeModifier(object oPC, int bDisplayForPlayer=TRUE)
{
    //float fQuestPerc = 100.0;// all classes get 100% quest and roleplay XP
    float fCombatPerc = 0.0;
    float fDiscoveryPerc = 0.0;
    float fAbilityPerc = 0.0;
    float fCraftPerc = 0.0;
    float fMagicPerc = 0.0;

    float fCharLevel = 0.0;

    int i;
    for(i=1; i<=3; i++)
    {
        int Class = GetClassByPosition(i, oPC);
        if (CLASS_TYPE_INVALID != Class)
        {
            float Level = IntToFloat(GetLevelByClass(Class, oPC));
            fCharLevel += Level;
            if (Class == CLASS_TYPE_BARBARIAN)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_BARD)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_CLERIC)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_DRUID)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_FIGHTER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_MONK)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_PALADIN)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_RANGER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_ROGUE)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_SORCERER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_WIZARD)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_ARCANE_ARCHER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_ASSASSIN)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_BLACKGUARD)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_HARPER)
            {
                  fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_SHADOWDANCER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_DIVINECHAMPION)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_DRAGONDISCIPLE)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_DWARVENDEFENDER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_PALEMASTER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_SHIFTER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
            else if (Class == CLASS_TYPE_WEAPON_MASTER)
            {
                fCombatPerc += 00 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 0 * Level;
                fCraftPerc += 0 * Level;
                fMagicPerc += 0 * Level;
            }
/*
            float Level = IntToFloat(GetLevelByClass(Class, oPC));
            fCharLevel += Level;

            if (Class == CLASS_TYPE_BARBARIAN)
            {
                fCombatPerc += 100 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 60 * Level;
                fCraftPerc += 50 * Level;
                fMagicPerc += 5 * Level;
            }
            else if (Class == CLASS_TYPE_BARD)
            {
                fCombatPerc += 50 * Level;
                fDiscoveryPerc += 90 * Level;
                fAbilityPerc += 90 * Level;
                fCraftPerc += 70 * Level;
                fMagicPerc += 60 * Level;
            }
            else if (Class == CLASS_TYPE_CLERIC)
            {
                fCombatPerc += 45 * Level;
                fDiscoveryPerc += 50 * Level;
                fAbilityPerc += 30 * Level;
                fCraftPerc += 30 * Level;
                fMagicPerc += 70 * Level;
            }
            else if (Class == CLASS_TYPE_DRUID)
            {
                fCombatPerc += 35 * Level;
                fDiscoveryPerc += 80 * Level;
                fAbilityPerc += 70 * Level;
                fCraftPerc += 30 * Level;
                fMagicPerc += 70 * Level;
            }
            else if (Class == CLASS_TYPE_FIGHTER)
            {
                fCombatPerc += 100 * Level;
                fDiscoveryPerc += 30 * Level;
                fAbilityPerc += 30 * Level;
                fCraftPerc += 60 * Level;
                fMagicPerc += 70 * Level;
            }
            else if (Class == CLASS_TYPE_MONK)
            {
                fCombatPerc += 80 * Level;
                fDiscoveryPerc += 70 * Level;
                fAbilityPerc += 90 * Level;
                fCraftPerc += 5 * Level;
                fMagicPerc += 5 * Level;
            }
            else if (Class == CLASS_TYPE_PALADIN)
            {
                fCombatPerc += 80 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 40 * Level;
                fCraftPerc += 30 * Level;
                fMagicPerc += 60 * Level;
            }
            else if (Class == CLASS_TYPE_RANGER)
            {
                fCombatPerc += 75 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 70 * Level;
                fCraftPerc += 70 * Level;
                fMagicPerc += 40 * Level;
            }
            else if (Class == CLASS_TYPE_ROGUE)
            {
                fCombatPerc += 50 * Level;
                fDiscoveryPerc += 85 * Level;
                fAbilityPerc += 100 * Level;
                fCraftPerc += 90 * Level;
                fMagicPerc += 5 * Level;
            }
            else if (Class == CLASS_TYPE_SORCERER)
            {
                fCombatPerc += 30 * Level;
                fDiscoveryPerc += 80 * Level;
                fAbilityPerc += 90 * Level;
                fCraftPerc += 30 * Level;
                fMagicPerc += 100 * Level;
            }
            else if (Class == CLASS_TYPE_WIZARD)
            {
                fCombatPerc += 20 * Level;
                fDiscoveryPerc += 50 * Level;
                fAbilityPerc += 30 * Level;
                fCraftPerc += 100 * Level;
                fMagicPerc += 100 * Level;
            }
            else if (Class == CLASS_TYPE_ARCANE_ARCHER)
            {
                fCombatPerc += 75 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 50 * Level;
                fCraftPerc += 75 * Level;
                fMagicPerc += 40 * Level;
            }
            else if (Class == CLASS_TYPE_ASSASSIN)
            {
                fCombatPerc += 60 * Level;
                fDiscoveryPerc += 70 * Level;
                fAbilityPerc += 100 * Level;
                fCraftPerc += 75 * Level;
                fMagicPerc += 25 * Level;
            }
            else if (Class == CLASS_TYPE_BLACKGUARD)
            {
                fCombatPerc += 70 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 50 * Level;
                fCraftPerc += 60 * Level;
                fMagicPerc += 30 * Level;
            }
            else if (Class == CLASS_TYPE_HARPER)
            {
                fCombatPerc += 50 * Level;
                fDiscoveryPerc += 100 * Level;
                fAbilityPerc += 100 * Level;
                fCraftPerc += 80 * Level;
                fMagicPerc += 40 * Level;
            }
            else if (Class == CLASS_TYPE_SHADOWDANCER)
            {
                fCombatPerc += 65 * Level;
                fDiscoveryPerc += 75 * Level;
                fAbilityPerc += 100 * Level;
                fCraftPerc += 75 * Level;
                fMagicPerc += 25 * Level;
            }
            else if (Class == CLASS_TYPE_DIVINECHAMPION)
            {
                fCombatPerc += 75 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 50 * Level;
                fCraftPerc += 60 * Level;
                fMagicPerc += 25 * Level;
            }
            else if (Class == CLASS_TYPE_DRAGONDISCIPLE)
            {
                fCombatPerc += 45 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 80 * Level;
                fCraftPerc += 50 * Level;
                fMagicPerc += 90 * Level;
            }
            else if (Class == CLASS_TYPE_DWARVENDEFENDER)
            {
                fCombatPerc += 100 * Level;
                fDiscoveryPerc += 25 * Level;
                fAbilityPerc += 30 * Level;
                fCraftPerc += 50 * Level;
                fMagicPerc += 5 * Level;
            }
            else if (Class == CLASS_TYPE_PALEMASTER)
            {
                fCombatPerc += 40 * Level;
                fDiscoveryPerc += 60 * Level;
                fAbilityPerc += 100 * Level;
                fCraftPerc += 80 * Level;
                fMagicPerc += 70 * Level;
            }
            else if (Class == CLASS_TYPE_SHIFTER)
            {
                fCombatPerc += 65 * Level;
                fDiscoveryPerc += 90 * Level;
                fAbilityPerc += 70 * Level;
                fCraftPerc += 50 * Level;
                fMagicPerc += 50 * Level;
            }
            else if (Class == CLASS_TYPE_WEAPON_MASTER)
            {
                fCombatPerc += 100 * Level;
                fDiscoveryPerc += 30 * Level;
                fAbilityPerc += 25* Level;
                fCraftPerc += 45 * Level;
                fMagicPerc += 5 * Level;
            }
*/
        }
    }

    fCombatPerc     = fCombatPerc / fCharLevel;
    fDiscoveryPerc  = fDiscoveryPerc / fCharLevel;
    fAbilityPerc    = fAbilityPerc / fCharLevel;
    fCraftPerc      = fCraftPerc / fCharLevel;
    fMagicPerc      = fMagicPerc / fCharLevel;

    //SetLocalFloat(oPC, "XP_MODIFIER_QUEST", fQuestPerc);
    SetLocalFloat(oPC, "XP_MODIFIER_COMBAT", fCombatPerc);
    SetLocalFloat(oPC, "XP_MODIFIER_DISCOVERY", fDiscoveryPerc);
   // SetLocalFloat(oPC, "XP_MODIFIER_SKILL", fAbilityPerc);
    //SetLocalFloat(oPC, "XP_MODIFIER_CRAFT", fCraftPerc);
    //SetLocalFloat(oPC, "XP_MODIFIER_MAGIC", fMagicPerc);
/*
    if(bDisplayForPlayer)
    {
         float fDelay =  GetLocalFloat(GetModule(), "DELAY_DISPLAY_START");
        DelayCommand(fDelay+0.010,SendMessageToPC(oPC, " "));
        DelayCommand(fDelay+0.011,SendMessageToPC(oPC, DARKRED+"Experience Modifiers:"));
        DelayCommand(fDelay+0.012,SendMessageToPC(oPC, PINK+"Questing: 100%"));
        DelayCommand(fDelay+0.013,SendMessageToPC(oPC, PINK+"Roleplaying: 100%"));
        DelayCommand(fDelay+0.014,SendMessageToPC(oPC, PINK+"Combat: " + IntToString(FloatToInt(fCombatPerc)) +"%"));
        DelayCommand(fDelay+0.015,SendMessageToPC(oPC, PINK+"Discovery: " + IntToString(FloatToInt(fDiscoveryPerc)) +"%"));
        DelayCommand(fDelay+0.016,SendMessageToPC(oPC, PINK+"Skills: " + IntToString(FloatToInt(fAbilityPerc)) +"%"));
        DelayCommand(fDelay+0.017,SendMessageToPC(oPC, PINK+"Spells: " + IntToString(FloatToInt(fMagicPerc)) +"%"));
        DelayCommand(fDelay+0.018,SendMessageToPC(oPC, PINK+"Crafting: " + IntToString(FloatToInt(fCraftPerc)) +"%"));
    }
*/
}

int XPRetrieveByType(object oPC, int nType=0, string campaign_id="ANY")
{
    int nXP;

    if(!nType)
    {
        if(MODULE_NWNX_MODE)
            nXP = NWNX_RetrieveCharacterXP(GetPCID(oPC),"ALL", campaign_id);
        else
            nXP = NBDE_GetCampaignInt(CHARACTER_DATA, "PC_XP_TOTAL",oPC);
    }
    else
    {
        if(MODULE_NWNX_MODE)
            nXP = NWNX_RetrieveCharacterXP(GetPCID(oPC), XPGetTypeName(nType), campaign_id);
        else
            nXP = NBDE_GetCampaignInt(CHARACTER_DATA, "PC_XP_CATEGORY"+IntToString(nType),oPC);
    }

    return nXP;
}

void XPStoreByType(object oPC, int nXP, int nType=XP_TYPE_ADJUSTMENT)
{
    int nXPDB;
    string CharID,CmpnID; // needed for NWNX in this scope
    if(MODULE_NWNX_MODE)
    {
        CharID= GetPCID(oPC); CmpnID= NWNX_GetCampaignID(); // only define if using NWNX
        nXPDB = NWNX_RetrieveCharacterXP(CharID);
    }
    else
    {
        nXPDB = NBDE_GetCampaignInt(CHARACTER_DATA, "PC_XP_TOTAL",oPC);
    }
    int nXPCurrent  = GetXP(oPC);
    if(nXPDB<nXPCurrent)
    {
        if(MODULE_NWNX_MODE)
        {
            NWNX_StoreCharacterXP((nXPCurrent-nXPDB), CharID, "ADJUSTMENT", CmpnID);
        }
        else
        {
            NBDE_SetCampaignInt(CHARACTER_DATA,
                            "PC_XP_CATEGORY"+IntToString(-1),
                            NBDE_GetCampaignInt(CHARACTER_DATA, "PC_XP_CATEGORY"+IntToString(-1),oPC)+(nXPCurrent-nXPDB),
                            oPC
                           );
        }
        nXPDB   = nXPCurrent;
    }

    if(MODULE_NWNX_MODE)
        NWNX_StoreCharacterXP(nXP, CharID, XPGetTypeName(nType), CmpnID);
    else
    {
        // total XP for PC.
        NBDE_SetCampaignInt(CHARACTER_DATA,
                        "PC_XP_TOTAL",
                        nXPDB+nXP,
                        oPC
                       );
        // total XP in special category for PC
        NBDE_SetCampaignInt(CHARACTER_DATA,
                        "PC_XP_CATEGORY"+IntToString(nType),
                        NBDE_GetCampaignInt(CHARACTER_DATA, "PC_XP_CATEGORY"+IntToString(nType),oPC)+nXP,
                        oPC
                       );
    }
}

void XPPenalty(object oPC, int nAmount, string sFeedback="", int nType=XP_TYPE_ADJUSTMENT)
{
    int nPenalty    = 0 - nAmount;
    int nFinalXP    = GetXP(oPC) + nPenalty;
    if(nFinalXP<0){nFinalXP = 0;}
    sFeedback   += " (lost "+YELLOW+IntToString(nAmount)+RED+" XP)";


    //Play Sound
    AssignCommand(oPC, PlaySound("gui_spell_erase"));
    //Send Penalty Message
    FloatingTextStringOnCreature(RED+sFeedback, oPC, FALSE);

    // the business end of this function
    XPStoreByType(oPC, nPenalty, nType); // tracking XP in the database (and by campaign)
    SetXP(oPC, nFinalXP);

    if(MODULE_DEBUG_MODE)
        SendMessageToPC(oPC,"XP("+IntToString(nFinalXP)+")");
}

void XPRewardByType(string sRewardTag, object oPC, int iXPReward, int iExperienceType, string sDescription="")
{
    if(IsOOC(oPC)&&sRewardTag!="startingxp")
        return; // no xp when out of character

    // Modify XP granted based on Class and specific category of XP award.
    float fDiscoveryPerc    = GetLocalFloat(oPC, "XP_MODIFIER_DISCOVERY");
//    float fAbilityPerc      = GetLocalFloat(oPC, "XP_MODIFIER_SKILL");
//    float fCraftPerc        = GetLocalFloat(oPC, "XP_MODIFIER_CRAFT");
//    float fCombatPerc       = GetLocalFloat(oPC, "XP_MODIFIER_COMBAT");
//    float fMagicPerc        = GetLocalFloat(oPC, "XP_MODIFIER_MAGIC");

    string sExperienceFeedback;
    int iFinalXP    = iXPReward;
    int nRewardCnt  = 0;
    int bDecaying   = FALSE;
    // add XP tag prefix to sRewardTag
    if(sRewardTag!="")
    {
        if(MODULE_NWNX_MODE)
            nRewardCnt = StringToInt( NWNX_RetrieveCampaignValue( TAG_XP+sRewardTag, NWNX_GetCampaignID(), GetPCID(oPC) ) );
        else
            nRewardCnt = NBDE_GetCampaignInt(CAMPAIGN_NAME, TAG_XP+sRewardTag, oPC);
    }

    if(iExperienceType==XP_TYPE_QUEST)         /* Questing */
    {
        //iFinalXP = iXPReward;
        sExperienceFeedback = "You Furthered the Story...";
    }
    else if(iExperienceType==XP_TYPE_AREA)    /* Area Discovery */
    {
        if (fDiscoveryPerc > 0.0) {
                iFinalXP = FloatToInt(IntToFloat(iXPReward) * (fDiscoveryPerc)/100.0);
        }
        sExperienceFeedback = "You are rewarded for discovering a new area.";
    }
    else if(iExperienceType==XP_TYPE_DISCOVERY)    /* Learned Something New */
    {
        if (fDiscoveryPerc > 0.0) {
                iFinalXP = FloatToInt(IntToFloat(iXPReward) * (fDiscoveryPerc)/100.0);
        }
        sExperienceFeedback = "You are rewarded for discovering something new.";
    }
    else if(iExperienceType==XP_TYPE_ROLEPLAY)    /* Role-playing */
    {
        //iFinalXP = iXPReward;
        sExperienceFeedback = "You are rewarded for role-playing your character.";
    }

/*
    else if(iExperienceType==XP_TYPE_CRAFT)    /* Crafting Improvement
    {
        if (fCraftPerc > 0.0) {
                iFinalXP            = FloatToInt(IntToFloat(iXPReward) * (fCraftPerc)/100.0);
        }
        sExperienceFeedback = "You are rewarded for practicing your craft.";
        bDecaying           = TRUE;
    }
    else if(iExperienceType==XP_TYPE_ABILITY)    /* Ability/Skill Use
    {
        iXPReward = iXPReward/(nRewardCnt + 1);
        if (fAbilityPerc > 0.0) {
                iFinalXP            = FloatToInt(IntToFloat(iXPReward) * (fAbilityPerc)/100.0);
        }
        sExperienceFeedback = "You are rewarded for fruitful use of your abilities.";
        bDecaying           = TRUE;
    }
    else if(iExperienceType==XP_TYPE_COMBAT)    /* Combat
    {
        if (fCombatPerc > 0.0) {
                iFinalXP            = FloatToInt(IntToFloat(iXPReward) * (fCombatPerc)/100.0);
        }
        sExperienceFeedback = "You are rewarded for defeating an adversary.";
        bDecaying           = TRUE;
    }
    else if(iExperienceType==XP_TYPE_MAGIC)    /* Magic-Related
    {
        // determine how many times the caster has been rewarded for casting this spell
        // amount awarded degrades based on number of casts
        iXPReward = iXPReward/(nRewardCnt + 1);
        if (fMagicPerc > 0.0) {
                iFinalXP            = FloatToInt(IntToFloat(iXPReward) * (fMagicPerc)/100.0);
        }
        sExperienceFeedback = "You are rewarded for honing your magical powers.";
        bDecaying           = TRUE;
    }
*/
    //If this is a decaying reward OR the first time it has been rewarded
    if( bDecaying || nRewardCnt==0 )
    {
        //Minimum XP
        if(iFinalXP<1)
            iFinalXP = 1; // 1 xp is the minimum reward

        //Play Sound
        AssignCommand(oPC, PlaySound("gui_spell_mem"));
        //Send Special Description
        if(sDescription != "")
            FloatingTextStringOnCreature(LIGHTBLUE+sDescription, oPC, FALSE);
        //Send Reward Message
        SendMessageToPC(oPC, PINK+sExperienceFeedback);

        XPStoreByType(oPC, iFinalXP, iExperienceType); // tracking XP in the database (and by campaign)
        GiveXPToCreature(oPC, iFinalXP); // the business end of this function

        if(MODULE_DEBUG_MODE)
            SendMessageToPC(oPC,"XP("+IntToString(iFinalXP)+")");

        //Flag player as having now received this XP Reward.
        if(sRewardTag!="")
        {
            if(MODULE_NWNX_MODE)
                NWNX_StoreCampaignValue(TAG_XP+sRewardTag, IntToString(nRewardCnt+1), NWNX_GetCampaignID(), GetPCID(oPC));
            else
                NBDE_SetCampaignInt(CAMPAIGN_NAME, TAG_XP+sRewardTag, (nRewardCnt+1), oPC);
        }
    }
}

void XPRewardDisarmTrap(object oPC, object oTrap)
{
    string sRewardTag = "TRAP_"+GetTag(oTrap)+GetTrapKeyTag(oTrap);

    //Factors of reward are trap's DC, whether PC is in combat, whether or not the trap is a one shot
    int nXPReward;
    int DC  = GetTrapDisarmDC(oTrap);
    int multiplier  = 30;
    if(GetTrapOneShot(oTrap))
        multiplier  = 15;

    if(GetIsInCombat(oPC))
        nXPReward = (DC-9)*multiplier;
    else
        nXPReward = (DC-20)*multiplier;

    if(nXPReward<10)
        nXPReward   = 10;

    // Adjust XP based on number of times the lock has been picked
    int nDisarmCount;
    if(MODULE_NWNX_MODE)
        nDisarmCount = StringToInt(NWNX_RetrieveCampaignValue(TAG_XP+sRewardTag,NWNX_GetCampaignID(),GetPCID(oPC)))+1;
    else
        nDisarmCount = NBDE_GetCampaignInt(CAMPAIGN_NAME, TAG_XP+sRewardTag, oPC)+1;

    nXPReward = nXPReward/nDisarmCount;
    if(nXPReward<5)
        nXPReward = 5;


    XPRewardByType(sRewardTag, oPC, nXPReward, XP_TYPE_ABILITY, "You succeeded in disarming the trap!");
}

void XPRewardPickLock(object oPC, object oLocked)
{
    string id   = "xp_lock_last_"+ ObjectToString(oPC);
    int last    = GetLocalInt(oLocked, id);
    int now     = GetTimeCumulative();

    // only give XP every 90 RL minutes for pick lock, per lock
    if (!last || (now-last)>(10*GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")))
    {
        string sLockTag = GetLockKeyTag(oLocked)+GetTag(oLocked);

        SetLocalInt(oLocked, id, now);
        string sRewardTag   = "LOCK_"+sLockTag;

        //The amount of experience given will depend on DC of the lock and whether PC was in combat
        int DC        = GetLockUnlockDC(oLocked);
        int nXPReward;
        if(GetIsInCombat(oPC))
            nXPReward = (DC-9)*15;
        else
            nXPReward = (DC-20)*10;
        if(nXPReward<0)
            nXPReward = 10;

        // Adjust XP based on number of times the lock has been picked
        int nPicksCount;
        if(MODULE_NWNX_MODE)
            nPicksCount = StringToInt(NWNX_RetrieveCampaignValue(TAG_XP+sRewardTag,NWNX_GetCampaignID(),GetPCID(oPC)))+1;
        else
            nPicksCount = NBDE_GetCampaignInt(CAMPAIGN_NAME, TAG_XP+sRewardTag, oPC)+1;

        nXPReward = nXPReward/nPicksCount;
        if(nXPReward<3)
            nXPReward = 3;

        XPRewardByType(sRewardTag, oPC, nXPReward, XP_TYPE_ABILITY, "You succeeded in picking the lock!");
    }

    //CheckAlignmentForOpenLocks(oPC);
}

int GetDeservesXPShare(object oPC,object oKiller,object oDead)
{
//    int nCurrentMinute = GetTimeCumulative();
//    int nTime   = GetLocalInt(oDead, "COMBATANT_"+ObjectToString(oPC));
//    if(nTime&&(nTime+TIME_WINDOW)>=nCurrentMinute) return TRUE;//If you participated in the kill, you get a share even if you aren't partied.

    if(GetArea(oPC)==GetArea(oKiller)|GetArea(oPC)==GetArea(oDead))
    {
        if(GetFactionLeader(oPC)==GetFactionLeader(oKiller)) return TRUE;
    }
    return FALSE;
}

void XPRewardCombat( object oKiller, object oDead, int nCRMod=0 )
{
    // Custom DMG EXP Script (varies slightly on bonuses and penalties)
    // Concept and Original Code By Helznicht
    // Syntax Clean-Up and Area Check Award by Mmealman
    // Major bug rennovation by David Bills.  1-9-03
    // Basic experience for creatures is around Bioware 3%.
    // To adjust this, modify the polynomial equation below.

    if( GetLocalInt(oDead, "IS_DEAD") || IsOOC(oKiller) )
        return; // no xp in ooc areas / only run the process once

    float Experience_Slider = 0.10; // This is the percentage that can be adjusted.
                                    // This value matches the Bioware slider.

    object oMod = GetModule();
    // First get all the members of the party
    float   LowestLevelMember   = 1000.0;
    float   HighestLevelMember  = -10.0;
    float   PartyShares         = 0.0;
    float   fLevel              = 0.0;
    int     nTotalMembers       = 0;
    string  sRewardTag          = TAG_KILLS;
    object  oMaster, oHighest, oLowest;
    int     bOld;
    string sRef                 = GetResRef(oDead);
    string sTag                 = GetTag(oDead);

    sRewardTag                 += sRef;
    if(sTag!=sRef)
        sRewardTag += sTag; // unique individual

    int nCurrentMinute = GetTimeCumulative();
    int nTime;
    int TIME_WINDOW = GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")*2;
    // every character that attacked or cast a spell on the monster should be included
    // edit monster ai
    SetLocalInt(oDead, "COMBATANT_"+ObjectToString(oKiller),nCurrentMinute);
    object oPC  = GetFirstPC();
    while(oPC!=OBJECT_INVALID)
    {
        if(GetDeservesXPShare(oPC,oKiller,oDead))
        {
            nTotalMembers++;

            if( GetIsPC( oPC ) )
                fLevel = IntToFloat( GetHitDice(oPC) );
            else
                fLevel = GetChallengeRating(oPC);

            if( LowestLevelMember > fLevel )
            {
                LowestLevelMember = fLevel;
                oLowest = oPC;
            }

            if( HighestLevelMember < fLevel )
            {
                HighestLevelMember = fLevel;
                oHighest = oPC;
            }
        }

        oPC = GetNextPC();
    }

    // Now we need to test for the Really low level creatures.
    // They need to be scaled as negative level to function properly.
    float fChallenge = GetChallengeRating( oDead );
    if ( fChallenge < 1.0 ) fChallenge =  1.0 - (( 1.0 - fChallenge ) * 5.0);

    if ( MODULE_DEBUG_MODE )
        SendMessageToParty( oKiller, "Enemy CR("+FloatToString( fChallenge )+") Highest Member("+GetName( oHighest )+")" );

    // This is the level difference of the dead to the highest
    fLevel = fChallenge - HighestLevelMember;

    fLevel += nCRMod;  // Add the adjusted level to the creature.

    // This limitation sets the highest level available for death experience.
    if ( fLevel >= 8.0 ) fLevel = 8.0;

    //Calculate basic value of kill
    float FinalMonValue = 84.0 * HighestLevelMember + 750;
    float fSharePercent;

    // This is the exponential function to match the 3e rules.
    // There is some adjustment here to allow for smooth transitions.
    if ( fLevel < 0.0 )
        FinalMonValue = FinalMonValue * pow( 1.55, fLevel ) ;
    else
        FinalMonValue = FinalMonValue * pow( 1.20, fLevel ) ;

    // This is the general experience scaling operation.  A value here of 0.04
    // corresponds to a 4% scale of experience from the Bioware system.
    FinalMonValue = FinalMonValue * Experience_Slider;

    if ( FinalMonValue < 0.0 )
        FinalMonValue = 0.0 ;

    if ( MODULE_DEBUG_MODE )
        SendMessageToParty( oKiller, "Base Xp: "+FloatToString( FinalMonValue ) );

    /* Now determine shares based upon the lowest party member. */
    oPC  = GetFirstPC();
    while(oPC!=OBJECT_INVALID)
    {
        if(GetDeservesXPShare(oPC,oKiller,oDead))
        {
            fLevel = IntToFloat( GetHitDice( oPC ) );
            fLevel = fLevel - LowestLevelMember;
            fSharePercent = pow( 1.10 , fLevel );

            if( MODULE_DEBUG_MODE )
                SendMessageToParty( oKiller,  GetName(oPC)+" Share="+FloatToString(fSharePercent) );

            /* Adjusting the differential for level variance here */
            PartyShares += fSharePercent;
        }

        oPC = GetNextPC();
    }

    if ( MODULE_DEBUG_MODE )
        SendMessageToParty( oKiller,  "Total Shares="+FloatToString(PartyShares) );

    int nPenalty;

    if( PartyShares > 0.0 )
    {
        //Determine the value of the Split EXP
        // This is based on shares compared to the lowest member to the heighest.
        int nXPReward;
        float fXPReward;
        int nKills;
        float fKillModifier;
        float fKillModMin = 0.05;
        string campaign_id  = NWNX_GetCampaignID();
        /* Now determine shares based upon the lowest party member. */
        oPC  = GetFirstPC();
        while(oPC!=OBJECT_INVALID)
        {
            if(GetDeservesXPShare(oPC,oKiller,oDead))
            {
                fLevel = IntToFloat( GetHitDice( oPC ) );
                fLevel = fLevel - LowestLevelMember;

                // The share system here is used because a 20th level character
                // is MANY times more powerful than a 10th level character.  And
                // the experience shares should not simply be based upon straight
                // level values.
                // Use the formula:  your share = (your level - lowest level) ^ 1.10
                fSharePercent = pow( 1.10 , fLevel ) / PartyShares;

                // The following modification improves experience for groups.
                // It is not needed for a flat experience system, but then most
                // people would not group.  What it normally does is similar to
                // two people of equal levels in a group each get 0.75 of the total
                // experience, instead of an equal split of 0.50.

                // Use the formula:  Your fraction = 2 * share - share ^ 2
                fSharePercent = 2*fSharePercent - (fSharePercent * fSharePercent );

                if ( MODULE_DEBUG_MODE )
                    SendMessageToParty( oPC,  "Party Percent " + GetName( oPC ) +": "+ FloatToString(fSharePercent*100.0)+"%" );

                // Calculate share of XP for player
                fXPReward = fSharePercent * FinalMonValue;

                // Adjust XP based on number of kills

    /*
                float expscale(float p, float alpha, int kills)

                  {

                         return p * pow(alpha, kills);

                   }
    */

                if(MODULE_NWNX_MODE)
                    nKills  = StringToInt(NWNX_RetrieveCampaignValue(TAG_XP+sRewardTag,campaign_id,GetPCID(oPC)))+1;
                else
                    nKills  = NBDE_GetCampaignInt(CAMPAIGN_NAME, TAG_XP+sRewardTag, oPC)+1;

                fKillModifier = 1.0/IntToFloat(nKills);
                if (fKillModifier<fKillModMin)
                    fKillModifier = fKillModMin;
                fXPReward = fXPReward*fKillModifier;
                nXPReward = FloatToInt(fXPReward);

                if(MODULE_DEBUG_MODE)
                    SendMessageToPC( oPC, GetName( oPC )+" Reward: "+IntToString(nXPReward)+" Kills: "+IntToString(nKills));

                XPRewardByType(sRewardTag, oPC, nXPReward, XP_TYPE_COMBAT);
            }
            oPC = GetNextPC();
        }

    }

    // This line is needed to stop looping on death.
    SetLocalInt( oDead, "IS_DEAD", TRUE );
}

// XP Pool system.
// This creates a limit of kill XP per PC per day.  Once the pool is drained for a day
// further XP awards will will limited to a max XP (likely 1).
// The pool is tracked on the PC persistenly with 2 variables:
// XP_POOL_TOTAL - this is the filled pool which is drained as XP are awarded
// XP_POOL_DAY - This is the day timestamp of the last time the PC's pool was refilled.
// For simplicity (so as not to have to do things on client enter and what not) the system is
// designed to have a single entry point.  This will take the PC and the amount of XP the system
// would like to give and returns the amount the system should give.
const int XP_POOL_PER_LEVEL = 500;
const int XP_POOL_MIN = 1000;

int XPGetPoolRefill(object oPC) {

    return XP_POOL_MIN;
/*
        int nLevel = GetHitDice(oPC);
        int nRet = XP_POOL_PER_LEVEL * nLevel;
        if (nRet < XP_POOL_MIN) return XP_POOL_MIN;
        return nRet;
*/
}


int XPPoolGetXPAward(object oPC, int nAmount) {

        if (!GetIsPC(oPC)) return nAmount;
        if (nAmount <= 0) return 0;  // just in case.

        // check for a new day
        int nDay = GetPersistentInt(oPC, "XP_POOL_DAY");
        int nNow = CurrentDay();
        int nPool;
         // nDay could be 0 if not initialized. But this catches that too because nNow will always be > 0.
        if (nNow > nDay) {
                // Okay to refill
                nPool = XPGetPoolRefill(oPC);
                SetPersistentInt(oPC, "XP_POOL_TOTAL", nPool);
                SetPersistentInt(oPC,  "XP_POOL_DAY", nNow);
        } else {
                nPool = GetPersistentInt(oPC, "XP_POOL_TOTAL");
        }

        // check if nAmount is < pool.  If so then we can just do it.
        if (nAmount <= nPool) {
                SetPersistentInt(oPC, "XP_POOL_TOTAL", nPool - nAmount);
                return nAmount;
        }

        // Here pool is less than amount. Use up any remainder and set pool to 0
        if (nPool > 0) {
                nAmount = nPool;
                SetPersistentInt(oPC, "XP_POOL_TOTAL", 0);
                return nAmount;
        }

        // Here we have already exhausted to pool so return puny amount.
        // We don't track this.

        // Could send feedback here.
        return 1;  // XPGetMinXP(oPC);
}
// END XP ......................................................................
