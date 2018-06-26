//::///////////////////////////////////////////////
//:: _inc_util
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created : henesua (2015 dec 19)
//:://////////////////////////////////////////////

// INCLUDES

//#include "x0_i0_spawncond"
#include "x3_inc_string"

// dynamic conversations
#include "zdlg_include_i"
#include "q_inc_acp"

#include "_inc_constants"
#include "_inc_nwnx"
//#include "_inc_vfx"

// DECLARATIONS

//UNUSED
// returns TRUE if oPC has been flagged as a spell abuser - [FILE: _inc_util]
//int PCGetIsSpellAbuser(object oPC);
// sets the SPELL_ABUSER status of oPC as TRUE by default (but FALSE can be passed) - [FILE: _inc_util]
//void PCSetIsSpellAbuser(object oPC, int bSpellAbuser=TRUE);

// Used by _s2_playtool when a PC likes another PC's roleplay - [FILE: _inc_util]
void PCLikesTargetsRP(object oTarget, object oPC=OBJECT_SELF);
// sets oPC's current hitpoints to value of nHP - [FILE: _inc_util]
void SetHitPoints(object oPC, int nHP);
// Places pointer to DM on DM possessed Creature   - [FILE: _inc_util]
void TrackDMPossession(object oDM, object oCreature);

// an ability check. if bVerbose=TRUE, ability check is broadcast - [FILE: _inc_util]
int GetAbilityCheck(object oPC, int nAbility, int nDC, int bVerbose=FALSE);
// a skill check. if bVerbose=TRUE, ability check is broadcast - [FILE: _inc_util]
// return value is measure of success greater than DC +1. 0 = failure, 1 = minimal success, 2 = 1 greater than minimal etc...
int DoSkillCheck(object oPC, int nSkill, int nDC, int bVerbose=FALSE);
struct ENCUMBRANCE
{
    int low;
    int med;
    int high;
};
//returns a struct with low, med, high weight allowances in tenth pounds - [FILE: _inc_util]
struct ENCUMBRANCE GetWeightAllowance(object oCreature);
// returns a (negative) penalty based on how encumbered the creature is - [FILE: _inc_util]
int GetEncumbrancePenalty(object oCreature);
// applies a weight increase to an item - [FILE: _inc_util]
void ItemIncreaseWeight(int increase_weight, object oItem=OBJECT_SELF);
// returns a (negative) penalty based on the players equipped shield and armor. - [FILE: _inc_util]
// see armor.2da for armor check penalties.
int GetArmorCheckPenalty(object oCreature);
// determines whether the PC could be running   [File: _inc_util]
// checks - stealth, detection, encumbrance
int GetCanRun(object oPC);
// a grapple check. oTarget = creature defending, nDC = grapple difficulty - [FILE: _inc_util]
int GetIsGrappled(object oTarget, int nDC);
//returns oPC's favored enemy bonus versus oNPC - [FILE: _inc_util]
int GetFavoredEnemyBonus(object oPC, object oNPC, int nRace=RACIAL_TYPE_INVALID);

/*
// transfers variables expected on an NPC from oFrom to oTo - [FILE: _inc_util]
void SpawnTransferVariables(object oFrom, object oTo);
// sets up an NPC name on Spawn - [FILE: _inc_util]
void SpawnInitializeName(object npc=OBJECT_SELF);
// Returns the location state of the creature's stored in the database   [File: _inc_util]
int GetCreatureLocationState(string sNPCID,object oCreature=OBJECT_INVALID);
// Sets the location state of the creature's stored in the database   [File: _inc_util]
void SetCreatureLocationState(string sNPCID, int nState,object oCreature=OBJECT_INVALID);
// Returns the time stamp for when location state of the creature was last changed in the database   [File: _inc_util]
string GetCreatureLocationStateTimeStamp(string sNPCID,object oCreature=OBJECT_INVALID);
*/

// Returns number of meetings. - [FILE: _inc_util]
int GetMeetings(object oPC, object oNPC);
// Increases number of meetings by 1 - [FILE: _inc_util]
void CreaturesMeet(object oPC, object oMPC);
// Attempts to start a conversation   [File: _inc_util]
// If creature is DM Possesssed it will not start a convo   (return FALSE)
// if creature has a zdlg convo it will try that            (return TRUE)
// otherwise it tries ActionStartConversation               (return FALSE)
// oSpeaksWith = PC attempting to speak with oCreature
int DetermineConversation(object oCreature, object oSpeaksWith, int bPrivate=FALSE, int bPlayHello=FALSE, int bZoom=TRUE);

// CREATURES
// Returns the creature's natural phenotype  - [FILE: _inc_util]
int CreatureGetNaturalPhenoType(object oCreature);
// Returns the creature size modifier based on the size of oPC.  - [FILE: _inc_util]
// NOTE: Bioware hasn't fully implemented the CREATURE_SIZE_* constants so this is a reduced list.
int GetCreatureSizeModifier(object oCreature);
// Returns the creature's weight in pounds, using size and equipment  - [FILE: _inc_util]
int GetCreatureWeight(object oCreature);
// Returns the creature's height in feet, using appearance 2da  - [FILE: _inc_util]
int GetCreatureHeight(object oCreature, int bMeters=FALSE);
// Determines if the creature is incorporeal - [FILE: _inc_util]
// has the flag and is in cutscene ghost
int CreatureGetIsIncorporeal(object oCreature=OBJECT_SELF);
// returns TRUE if creature is polymorphed - [FILE: _inc_util]
int CreatureGetIsPolymorphed(object creature=OBJECT_SELF);
// Creature was polymorphed. handles polymorph tracking, and equipment - [FILE: _inc_util]
void CreaturePolymorphed(object creature=OBJECT_SELF, int merge_inventory=FALSE, int incorporeal=TRUE);
// restores creature after polymorph is cancelled - [FILE: _inc_util]
void CreatureRestoreFromPolymorph(object creature=OBJECT_SELF);
// TRUE Activates the flag and makes creature incorporeal.   [File: _inc_util]
// FALSE Deactivates the flag and remove cutscene ghost effects set by self
void CreatureSetIncorporeal(int incorporeal=TRUE, object oCreature=OBJECT_SELF);
// oCreature applies incorporeal effects to self. A duration of 0.0 is permanent.   [File: _inc_util]
void CreatureDoIncorporeal(object oCreature, float fDuration=0.0);
// Determines whether oCreature passes for animal. - [FILE: _inc_util]
int CreatureGetIsAnimal(object oCreature=OBJECT_SELF);
// Determines whether oCreature passes for humanoid. - [FILE: _inc_util]
int CreatureGetIsHumanoid(object oCreature=OBJECT_SELF);
// Determines if the creature qualifies as a spider - [FILE: _inc_util]
int CreatureGetIsSpider(object oCreature=OBJECT_SELF);
// Determines whether oCreature is a fungus creature. - [FILE: _inc_util]
int CreatureGetIsFungus(object oCreature=OBJECT_SELF);
// Returns TRUE if the creature has hands (based on appearance) - [FILE: _inc_util]
// this is useful in determining whether a creature can open/close object or manipulate devices
int CreatureGetHasHands(object oCreature=OBJECT_SELF);
// Determines if the creature is aquatic (breathes in water/swims) - [FILE: _inc_util]
int CreatureGetIsAquatic(object oCreature=OBJECT_SELF);
// Determines if the creature is softbodied (can fit through tiny openings) - [FILE: _inc_util]
int CreatureGetIsSoftBodied(object oCreature=OBJECT_SELF);
// Determines if the creature is currently flying - [FILE: _inc_util]
int CreatureGetIsFlying(object oCreature=OBJECT_SELF);
// Determines if the creature is a flier (but might not be flying) - [FILE: _inc_util]
// if bFly is TRUE and creature has an alt flying form it will fly
int CreatureGetIsFlier(object oCreature=OBJECT_SELF, int bFly=FALSE);
// Determines whether oCreature has basic wildcraft (can ID plants etc...). - [FILE: _inc_util]
int CreatureGetHasWildcraft(object oCreature=OBJECT_SELF);
// oCreature responds to someone sitting in their seat   [File: _inc_util]
// return value is the seat (to give the creature the opportunity to forget about it)
object CreatureGetResponseToSitterInSeat(object oCreature , object oSeat);
// Returns TRUE if the creature is executing an action or in conversation or combat - [FILE: _inc_util]
// The following actions are NOT considered "busy": ACTION_RANDOMWALK, ACTION_WAIT, ACTION_SIT
// Function will also accept one more action that it will ignore as busy with nIgnoreAction
int CreatureGetIsBusy(object oCreature=OBJECT_SELF, int nIgnoreAction=ACTION_INVALID, int nIgnoreCombat=FALSE, int nIgnoreConversation=FALSE);
// Standard Listening patterns for module   [File: _inc_util]
void CreatureSetCommonListeningPatterns(object oCreature = OBJECT_SELF);
// Determines if this is heard   [File: _inc_util]
int GetIsShoutHeard(object oShouter);
// Determines whether oCreature is civilized. - [FILE: _inc_util]
int CreatureGetIsCivilized(object oCreature=OBJECT_SELF);
// Determines whether oCreature is eaten by oPredator - [FILE: _inc_util]
int GetIsPrey(object oCreature, object oPredator=OBJECT_SELF);
// Range of oCreature's scent range - [FILE: _inc_util]
float GetScentRange(object oCreature);
// Friendly 2, Hostile 1, Neutral 0 - [FILE: _inc_util]
int GetReputationReactionType(object oTarget, object oSource=OBJECT_SELF, int bSharesGroup=FALSE);
// AREAS and SubAreas (triggers)

// Returns the area description as observed by oPC - [FILE: _inc_util]
string AreaGetDescription(object oPC, object oArea=OBJECT_SELF, int bEntry=FALSE, int nEntries=0);
// Returns true if oPC knows the entire area - [FILE: _inc_util]
int AreaGetIsMappedByPC(object oPC, object oArea=OBJECT_SELF);
// Returns TRUE if the trigger description can continue for oPC - [FILE: _inc_util]
int GetDescriptionCanContinue(object oPC, object oTrigger=OBJECT_SELF);

// Sets up object to fade in time. - [FILE: _inc_util]
void InitializeFade(object oObject);
// Fade objects in the area. - [FILE: _inc_util]
void ObjectsFade(object oArea);

// IMPLEMENTATIONS
/* These are not used
int PCGetIsSpellAbuser(object oPC)
{
    if(MODULE_NWNX_MODE)
        return StringToInt( NWNX_RetrieveCampaignValue( "SPELL_ABUSER", NWNX_GetCampaignID(), GetPCID(oPC) ) );
    else
        return NBDE_GetCampaignInt(CAMPAIGN_NAME, "SPELL_ABUSER", oPC);
}

void PCSetIsSpellAbuser(object oPC, int bSpellAbuser=TRUE)
{
    if(MODULE_NWNX_MODE)
        NWNX_StoreCampaignValue("SPELL_ABUSER", IntToString(bSpellAbuser), NWNX_GetCampaignID(), GetPCID(oPC));
    else
        NBDE_SetCampaignInt(CAMPAIGN_NAME, "SPELL_ABUSER", bSpellAbuser, oPC);
}
*/

void PCLikesTargetsRP(object oTarget, object oPC=OBJECT_SELF)
{
    // target is identified as a PC, is not a DM, and has chat recently
    int nNow        = GetTimeCumulative();
    int nRewardVal  = GetHitDice(oTarget)*10;    // 10 = 1% of total needed to level
    int nFrequency  = GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")*30; // rewards only happen once in a period (number is real world minutes)
    int nLastKudos = GetPersistentInt(oTarget, "PCLIKESROLEPLAY_LIKED_TIMESTAMP");

    // does the Targeted PC have an active "liked" flag?
    if(nLastKudos == 0 || ((nLastKudos+nFrequency)<=nNow)) {
            // give 2% of xp needed to level
            SetLocalInt(oTarget,"REWARD_ROLEPLAY_XP", nRewardVal );
            // time stamp the Targeted PC as having roleplayed well enough to get a like
	    SetPersistentInt(oTarget, "PCLIKESROLEPLAY_LIKED_TIMESTAMP", nNow);
    }
}

void SetHitPoints(object oPC, int nHP) {
	if(!GetIsObjectValid(oPC))
		return;
         int nCurrentHP  = GetCurrentHitPoints(oPC);
         int nChange     = (nHP  != nCurrentHP);
	 
	 WriteTimestampedLogEntry("SetHitpoints (" + GetTag(OBJECT_SELF) + ") " + GetName(oPC) + " hp = " + IntToString(nHP));
         if (nHP < 1) {
		 
        	// kill the PC. They logged out near death so they would be dead by now anyway 
		 WriteTimestampedLogEntry("SetHitpoints " + GetName(oPC) + " Should be dead - killing...");
        	int nDam =  GetMaxHitPoints(oPC) + 10;
       	        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY), oPC);
		return;
   	} else if (!nChange ) {
        	return; // don't need to do anything
        }
	NWNX_SetCurrentHitPoints(oPC,nHP);
}

void TrackDMPossession(object oDM, object oCreature)
{
    DeleteLocalObject(GetLocalObject(oCreature, "DM_POSSESSOR"),"POSSESSED_CREATURE");
    SetLocalObject(oDM,"POSSESSED_CREATURE", oCreature);
    SetLocalObject(oCreature, "DM_POSSESSOR", oDM);
}

int GetAbilityCheck(object oPC, int nAbility, int nDC, int bVerbose=FALSE)
{
    int bSuccess;
    int nBonus  = GetAbilityModifier(nAbility, oPC);

    int nRoll   = d20();
    if( (nRoll+nBonus)>=nDC)
        bSuccess = TRUE;

    if(bVerbose)
    {
        string sResponse, sAbility, sResult;
        switch(nAbility)
        {
            case ABILITY_CHARISMA: sAbility="Charisma"; break;
            case ABILITY_CONSTITUTION: sAbility="Constitution"; break;
            case ABILITY_DEXTERITY: sAbility="Dexterity"; break;
            case ABILITY_INTELLIGENCE: sAbility="Intelligence"; break;
            case ABILITY_STRENGTH: sAbility="Strength"; break;
            case ABILITY_WISDOM: sAbility="Wisdom"; break;
        }
        if(bSuccess)
            sResult = "Success";
        else
            sResult = "Failure";

        sResponse   = BLUE+sAbility+CYAN+" check "+BLUE+sResult+CYAN+"! (Roll: "
            +IntToString(nRoll)+" + "+IntToString(nBonus)+" = "+IntToString(nRoll+nBonus)+" DC: "+IntToString(nDC)+")";

        FloatingTextStringOnCreature(sResponse, oPC);
    }

    return bSuccess;
}

int DoSkillCheck(object oPC, int nSkill, int nDC, int bVerbose=FALSE)
{
    // This line ensures the Random function behaves randomly.
    int iRandomize = Random(Random(GetTimeMillisecond()));

    int bSuccess    = FALSE;
    int bUntrained  = StringToInt(Get2DAString("skills", "Untrained", nSkill));
    if(!bUntrained && GetSkillRank(nSkill, oPC, TRUE)<1)
        return FALSE;

    int nBonus  = GetSkillRank(nSkill, oPC);
    int nRoll   = Random(20)+1;

    /*  // need a method for determining take 10 and take 20 rules
    string sChk = "LAST_CHECK_"+IntToString(nSkill)+"_"+IntToString(nDC);
    if(!GetIsInCombat(oPC))
    {
        int nLast   = GetLocalInt(oPC, sChk);
        int nNow    = GetTimeCumulative(TIME_SECONDS);
        SetLocalInt(oPC, sChk, nNow);// record the check
        if(nLast)
        {
            if((nNow-nLast)<=20 && nRoll<10)
                nRoll   = 10; // take 10 if more than one check in 20 seconds
        }
    }
    else
        DeleteLocalInt(oPC, sChk);
    */

    if( (nRoll+nBonus)>=nDC)
        bSuccess = (nRoll+nBonus+1)-nDC;

    if(bVerbose)
    {

        string sResponse, sResult;
        string sSkill   = GetStringByStrRef(StringToInt(Get2DAString("skills","Name",nSkill)));

        if(bSuccess)
            sResult = "Success";
        else
            sResult = "Failure";

        sResponse   = BLUE+sSkill+CYAN+" check "+BLUE+sResult+CYAN+"! (Roll: "
            +IntToString(nRoll)+" + "+IntToString(nBonus)+" = "+IntToString(nRoll+nBonus)+" DC: "+IntToString(nDC)+")";

        FloatingTextStringOnCreature(sResponse, oPC);

    }

    return bSuccess;

}

struct ENCUMBRANCE GetWeightAllowance(object oCreature)
{
    struct ENCUMBRANCE Weight;
    int iLight, iMed, iHigh   = 0;
    int iStr    = GetAbilityScore(oCreature, ABILITY_STRENGTH);
    // Get the encumbrance ranges from the SRD Equipment Basics.
    switch(iStr)
    {
        case 0: iLight = 0; iMed = 0; iHigh = 0; break;
        case 1: iLight = 3; iMed = 6; iHigh = 10; break;
        case 2: iLight = 6; iMed = 13; iHigh = 20; break;
        case 3: iLight = 10; iMed = 20; iHigh = 30; break;
        case 4: iLight = 13; iMed = 26; iHigh = 40; break;
        case 5: iLight = 16; iMed = 33; iHigh = 50; break;
        case 6: iLight = 20; iMed = 40; iHigh = 60; break;
        case 7: iLight = 23; iMed = 46; iHigh = 70; break;
        case 8: iLight = 26; iMed = 53; iHigh = 80; break;
        case 9: iLight = 30; iMed = 60; iHigh = 90; break;
        case 10: iLight = 33; iMed = 66; iHigh = 100; break;
        case 11: iLight = 38; iMed = 76; iHigh = 115; break;
        case 12: iLight = 43; iMed = 86; iHigh = 130; break;
        case 13: iLight = 50; iMed = 10; iHigh = 150; break;
        case 14: iLight = 58; iMed = 116; iHigh = 175; break;
        case 15: iLight = 66; iMed = 133; iHigh = 200; break;
        case 16: iLight = 76; iMed = 153; iHigh = 230; break;
        case 17: iLight = 86; iMed = 173; iHigh = 260; break;
        case 18: iLight = 100; iMed = 200; iHigh = 300; break;
        case 19: iLight = 116; iMed = 233; iHigh = 350; break;
        case 20: iLight = 133; iMed = 266; iHigh = 400; break;
        case 21: iLight = 153; iMed = 306; iHigh = 460; break;
        case 22: iLight = 173; iMed = 346; iHigh = 520; break;
        case 23: iLight = 200; iMed = 400; iHigh = 600; break;
        case 24: iLight = 233; iMed = 466; iHigh = 700; break;
        case 25: iLight = 266; iMed = 533; iHigh = 800; break;
        case 26: iLight = 306; iMed = 613; iHigh = 920; break;
        case 27: iLight = 346; iMed = 693; iHigh = 1040; break;
        case 28: iLight = 400; iMed = 800; iHigh = 1200; break;
        case 29: iLight = 466; iMed = 933; iHigh = 1400; break;
        case 30: iLight = 532; iMed = 1074; iHigh = 1600; break;
        case 31: iLight = 612; iMed = 1224; iHigh = 1840; break;
        case 32: iLight = 692; iMed = 1384; iHigh = 2080; break;
        default:
            // Crap you must be giving your character too much wheaties.
            iLight  = FloatToInt((iStr-28)*4.0*466.0/10.0);
            iMed    = FloatToInt((iStr-28)*4.0*933.0/10.0);
            iHigh   = FloatToInt((iStr-28)*4.0*1400.0/10.0);
        break;
    }
    // convert to lb * 10 to reach parity with get weight
    Weight.low  = iLight*10;
    Weight.med  = iMed*10;
    Weight.high = iHigh*10;

    return Weight;
}

int GetEncumbrancePenalty(object oCreature)
{
    struct ENCUMBRANCE Weight = GetWeightAllowance(oCreature);
    // GetWeight returns the weight in lb * 10 (to handle fractional weights with an int).
    int iEncumbrance = GetWeight(oCreature);
    if (iEncumbrance <= Weight.low)
        return (0);
    else if (iEncumbrance <= Weight.med)
        return (-3);
    else if (iEncumbrance <= Weight.high)
        return (-6);
    else
        return (-50);// Character is immobolized.
}

// TODO - this could be removed...
void ItemIncreaseWeight(int increase_weight, object oItem=OBJECT_SELF) {   
        NWNX_SetItemWeight(oItem,increase_weight);
}

int GetArmorCheckPenalty(object oCreature)
{
    int iPenalty = 0;
    // Check for shield.
    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
    switch (GetBaseItemType(oItem))
    {
        case BASE_ITEM_SMALLSHIELD:
            iPenalty = -1;
        break;
        case BASE_ITEM_LARGESHIELD:
            iPenalty = -2;
        break;
        case BASE_ITEM_TOWERSHIELD:
            iPenalty = -10;
        break;
        default:
            iPenalty = 0;
        break;
    }

    // Check for Armor.
    oItem   = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
    // Get the ACCHECK Penalty from the 2da
    string sACPenalty   =  Get2DAString("armor", "ACCHECK", GetItemACValue(oItem));
    iPenalty            += StringToInt(sACPenalty);

    return (iPenalty);
}

int GetCanRun(object oPC)
{
    if(     (GetDetectMode(oPC)&&!GetHasFeat(FEAT_KEEN_SENSE,oPC))
        ||  GetStealthMode(oPC)
        ||  (GetEncumbrancePenalty(oPC)&&!CreatureGetIsIncorporeal(oPC))
      )
        return FALSE;
    else
        return TRUE;
}

int GetIsGrappled(object oTarget, int nDC)
{
    int bGrappled = FALSE; // is target grappled?

    // target's bonus against bullrush see: GetSizeModifier(object oCreature) file - x0_i0_spells
    int nSizeMod = 0;
    switch (GetCreatureSize(oTarget))
    {
        case CREATURE_SIZE_TINY: nSizeMod = -8;  break;
        case CREATURE_SIZE_SMALL: nSizeMod = -4; break;
        case CREATURE_SIZE_MEDIUM: nSizeMod = 0; break;
        case CREATURE_SIZE_LARGE: nSizeMod = 4;  break;
        case CREATURE_SIZE_HUGE: nSizeMod = 8;   break;
    }

    int nSynergy;   if(GetSkillRank(SKILL_TUMBLE, oTarget, TRUE)>=5){nSynergy=2;}// synergy bonus for tumble skill
    int nACPenalty  = GetArmorCheckPenalty(oTarget);
    int nGrapple    = GetBaseAttackBonus(oTarget)
                        + nSizeMod
                        + GetAbilityModifier(ABILITY_STRENGTH, oTarget);
    int nEscape     = GetSkillRank(SKILL_ESCAPE_ARTIST, oTarget)
                        + nACPenalty
                        - nSizeMod
                        + nSynergy;

    if(nGrapple>nEscape)
    {
        // Grapple vs Grapple
        if( nDC>(d20(1)+nGrapple) )
            bGrappled= TRUE;
    }
    else
    {
        // Grapple vs Escape Artist
        if( !GetIsSkillSuccessful(oTarget, SKILL_ESCAPE_ARTIST, nDC-nACPenalty-nSynergy+nSizeMod) )
            bGrappled= TRUE;
    }

    return bGrappled;
}

int GetFavoredEnemyBonus(object oPC, object oNPC, int nRace=RACIAL_TYPE_INVALID)
{
    int nLevel  = GetLevelByClass(CLASS_TYPE_RANGER ,oPC);
    if(nLevel < 1)
        return 0;

    int nFave   = FloatToInt((nLevel - (nLevel%5))/5.0)+1;
    if(nRace==RACIAL_TYPE_INVALID)
        nRace   = GetRacialType(oNPC);

    int bFeat = FALSE;
    switch (nRace)
    {
        case RACIAL_TYPE_DWARF:
            if(GetHasFeat(261, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_ELF:
            if(GetHasFeat(262, oPC) || GetHasFeat(278, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_GNOME:
            if(GetHasFeat(263, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HALFLING:
            if(GetHasFeat(264, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HALFELF:
            if(GetHasFeat(265, oPC) || GetHasFeat(278, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HALFORC:
            if(GetHasFeat(266, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HUMAN:
            if(GetHasFeat(267, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_ABERRATION:
            if(GetHasFeat(268, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_ANIMAL:
            if(GetHasFeat(269, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_BEAST:
            if(GetHasFeat(270, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_CONSTRUCT:
            if(GetHasFeat(271, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_DRAGON:
            if(GetHasFeat(272, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HUMANOID_GOBLINOID:
            if(GetHasFeat(273, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HUMANOID_MONSTROUS:
            if(GetHasFeat(274, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HUMANOID_ORC:
            if(GetHasFeat(275, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_HUMANOID_REPTILIAN:
            if(GetHasFeat(276, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_ELEMENTAL:
            if(GetHasFeat(277, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_FEY:
            if(GetHasFeat(278, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_GIANT:
            if(GetHasFeat(279, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_MAGICAL_BEAST:
            if(GetHasFeat(280, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_OUTSIDER:
            if(GetHasFeat(281, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_SHAPECHANGER:
            if(GetHasFeat(284, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_UNDEAD:
            if(GetHasFeat(285, oPC)){bFeat = TRUE;}
        break;
        case RACIAL_TYPE_VERMIN:
            if(GetHasFeat(286, oPC)){bFeat = TRUE;}
        break;
        default:
        bFeat = FALSE;
        break;
    }

    if (bFeat == TRUE)
        return nFave;
    else
        return 0;
}

// Returns number of meetings. bPersistent is a flag for checking the database.
int GetMeetings(object oPC, object oNPC) {
    int nCount;

    if(GetLocalInt(oNPC,"UNIQUE")) {
        string sRefMeetings = "NPC_MEET_COUNT_"+GetPCID(oNPC);
	nCount =  GetPersistentInt(oPC, sRefMeetings);
    } else {
        nCount  = GetLocalInt( oNPC, "NPC_MEET_COUNT_"+GetPCID(oPC));
    }

    return nCount;
}

void CreaturesMeet(object oPC, object oNPC) {
	int nCount = GetMeetings(oPC, oNPC)+1;
	
	if(GetLocalInt(oNPC,"UNIQUE")) {
		string sRefMeetings = "NPC_MEET_COUNT_"+GetPCID(oNPC);
		SetPersistentInt(oPC, sRefMeetings, nCount);
	} else {
		SetLocalInt( oNPC, "NPC_MEET_COUNT_"+GetPCID(oPC), nCount);
	}
}

int DetermineConversation(object oCreature, object oSpeaksWith, int bPrivate=FALSE, int bPlayHello=FALSE, int bZoom=TRUE)
{
    int bSuccess;
    if(GetIsDMPossessed(oCreature))
    {
        SendMessageToPC(oSpeaksWith,RED+"Please wait for the DM to respond.");
        SendMessageToPC(oCreature,PALEBLUE+GetName(oSpeaksWith)+DMBLUE+" is trying to speak with "+PALEBLUE+GetName(oCreature)+DMBLUE+".");
        bSuccess=TRUE;
    }
    else
    {
        // look for a Z-dialog script ..........................................
        string sDialog = GetLocalString(oCreature, "DIALOG_SCRIPT");
        if(sDialog!="")
        {
            StartDlg( oSpeaksWith, oCreature, sDialog, bPrivate, bPlayHello, bZoom);
            bSuccess=TRUE;
        }
    }

    if(!bSuccess)
    {
        AssignCommand(oCreature,
                ActionStartConversation(oSpeaksWith, "", bPrivate, bPlayHello)
            );
    }

    return bSuccess;
}

// ........  CREATURES......................................

int CreatureGetNaturalPhenoType(object oCreature)
{
    int nNaturalPhenoType = GetSkinInt(oCreature,"PHENOTYPE_NATURAL");

    if(!nNaturalPhenoType)
    {
        nNaturalPhenoType = GetPhenoType(oCreature);
        if(nNaturalPhenoType==PHENOTYPE_NORMAL || nNaturalPhenoType==PHENOTYPE_BIG)
            SetSkinInt(oCreature,"PHENOTYPE_NATURAL", nNaturalPhenoType+1000);
        else
            nNaturalPhenoType = 0; // fallback
    }
    else
        nNaturalPhenoType -= 1000;


    return nNaturalPhenoType;
}


int GetCreatureSizeModifier(object oCreature)
{
    switch(GetCreatureSize(oCreature))
    {
        case CREATURE_SIZE_TINY: return(2);
        case CREATURE_SIZE_SMALL: return(1);
        case CREATURE_SIZE_MEDIUM: return(0);
        case CREATURE_SIZE_LARGE: return(-1);
        case CREATURE_SIZE_HUGE: return(-2);
    }
    return(0);
}

int GetCreatureWeight(object oCreature)
{
    int nWeight;
    switch(GetCreatureSize(oCreature))
    {
        case CREATURE_SIZE_TINY:    nWeight=1; break;
        case CREATURE_SIZE_SMALL:   nWeight=25; break;
        case CREATURE_SIZE_MEDIUM:  nWeight=100; break;
        case CREATURE_SIZE_LARGE:   nWeight=300; break;
        case CREATURE_SIZE_HUGE:    nWeight=1500; break;
        default:                    nWeight=100; break;
    }
    return (FloatToInt(GetWeight(oCreature)/10.0)+nWeight);
}

int GetCreatureHeight(object oCreature, int bMeters=FALSE)
{
    if(GetObjectType(oCreature)!=OBJECT_TYPE_CREATURE){ return FALSE; } //Creatures only
    int nType       = GetAppearanceType(oCreature);
    string sHeight  = Get2DAString("appearance","HEIGHT",nType);
    float fMeters   = StringToFloat(sHeight);
    if(bMeters)
        return FloatToInt(fMeters);
    else
        return FloatToInt(fMeters*3.28);
}

int CreatureGetIsIncorporeal(object oCreature=OBJECT_SELF)
{
    return(     GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL)// GetLocalInt(oCreature,"X2_L_IS_INCORPOREAL")
            &&  GetHasEffect(EFFECT_TYPE_CUTSCENEGHOST, oCreature)
          );
}

int CreatureGetIsPolymorphed(object creature=OBJECT_SELF)
{
    int polymorphed = FALSE;

    if(GetIsPC(creature))
        polymorphed = GetSkinInt(creature, "POLYMORPHED");
    else
        polymorphed = GetLocalInt(creature, "POLYMORPHED");

    return polymorphed;
}

void CreaturePolymorphed(object creature=OBJECT_SELF, int merge_inventory=FALSE, int incorporeal=TRUE)
{
    if(GetIsPC(creature))
        SetSkinInt(creature, "POLYMORPHED", TRUE);
    else
        SetLocalInt(creature, "POLYMORPHED", TRUE);

    // any special code to run when someone polypmorphs?

    // handle inventory
    if(merge_inventory)
    {
        string pc_id            = GetPCID(creature);
        CreatePersistentInventory("polyinventory_"+pc_id,creature,pc_id,GetIsPC(creature),FALSE);
        object per_inventory    = GetLocalObject(creature,"PERSISTENT_INVENTORY");
        // only move unequipped items to persistent inventory.  this is not a copy.
        MoveInventory(creature,per_inventory);
    }

    // incorporeal form
    if(incorporeal)
    {
        SetLocalInt(creature,"POLYMORPH_INCORPOREAL",TRUE);
        CreatureSetIncorporeal(TRUE, creature);
    }
}

void CreatureRestoreFromPolymorph(object creature=OBJECT_SELF)
{
    if(GetIsPC(creature))
        SetSkinInt(creature, "POLYMORPHED", FALSE);
    else
        SetLocalInt(creature, "POLYMORPHED", FALSE);

    // restore
    DeleteLocalInt(creature, "vfx_tmp_op");
    ExecuteScript("_vfx_do_op", creature);

    string pc_id            = GetPCID(creature);
    object per_inventory    = GetPersistentInventory("polyinventory_"+pc_id, pc_id);
    if(GetIsObjectValid(per_inventory))
    {
        MoveInventory(per_inventory,creature);
    }

    // incorporeal
    if(GetLocalInt(creature,"POLYMORPH_INCORPOREAL"))
    {
        DeleteLocalInt(creature,"POLYMORPH_INCORPOREAL");
        CreatureSetIncorporeal(FALSE, creature);
    }
}

void CreatureSetIncorporeal(int incorporeal=TRUE, object oCreature=OBJECT_SELF)
{
    SetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL, incorporeal);

    if(incorporeal)
    {
        CreatureDoIncorporeal(oCreature);
    }
    else
    {
        effect eEffect = GetFirstEffect(oCreature);
        while(GetIsEffectValid(eEffect))
        {
            if(     GetEffectType(eEffect) == EFFECT_TYPE_CUTSCENEGHOST
                &&  GetEffectCreator(eEffect)==oCreature
                &&  GetEffectSpellId(eEffect)==-1
              )
                RemoveEffect(oCreature,eEffect);

            eEffect = GetNextEffect(oCreature);
        }
    }
}

void CreatureDoIncorporeal(object oCreature, float fDuration=0.0)
{
    effect eIncorporeal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
           eIncorporeal = EffectLinkEffects(EffectCutsceneGhost(), eIncorporeal);
           eIncorporeal = ExtraordinaryEffect(eIncorporeal);

    int nDurType;
    if(fDuration==0.0)
        nDurType    = DURATION_TYPE_PERMANENT;
    else
        nDurType    = DURATION_TYPE_TEMPORARY;

    AssignCommand(oCreature, ApplyEffectToObject(nDurType, eIncorporeal, oCreature, fDuration));
}

int CreatureGetIsAnimal(object oCreature=OBJECT_SELF)
{
    int nRacial = GetRacialType(oCreature);

    if(     nRacial==RACIAL_TYPE_ANIMAL
        ||(     GetAbilityScore(oCreature,ABILITY_INTELLIGENCE)<8
            &&  (nRacial==RACIAL_TYPE_BEAST || nRacial==23) // lycanthropes
          )
      )
        return TRUE;
    else
        return FALSE;
}

int CreatureGetIsHumanoid(object oCreature=OBJECT_SELF)
{
    int nRacial = GetRacialType(oCreature);

    if(     nRacial<=6  // player races
        ||  nRacial==12 // goblin
        //||  nRacial==14 // animorphs
        //||  nRacial==15 // scalykind (lizardfolk etc..)
        ||  nRacial==17 // fey
        //||  nRacial==18 // giant
       //||  nRacial==23 // lycanthropes
      )
        return TRUE;
    else
        return FALSE;
}

int CreatureGetIsSpider(object oCreature=OBJECT_SELF)
{
    int nAppType    = GetAppearanceType(oCreature);

    if(     (nAppType>=157 && nAppType<=162)
        ||  nAppType==406 ||  nAppType==407 ||  nAppType==446// driders
        ||  nAppType==422
        ||  nAppType==900
        ||  nAppType==965
        ||  (nAppType>=1061 && nAppType<=1065) //infensa spiders in Q
        ||  nAppType==1144 || nAppType==1145   // q driders
      /*||  (nAppType>=5101 && nAppType<=5102) // infensa spiders resized by Hene
        ||  (nAppType>=5158 && nAppType<=5165) // infensa spiders resized by Hene
        ||  (nAppType==5396 || nAppType==5397) // shadow spiders
        ||  (nAppType>=5502 && nAppType<=5504) // spider mounts
      */
      )
        return TRUE;
    else
        return FALSE;
}

int CreatureGetIsFungus(object oCreature=OBJECT_SELF)
{
    int nAppear = GetAppearanceType(oCreature);

    if(     (nAppear>=942 && nAppear<=944)      // myconids
        //||  (nAppear>=5010 && nAppear<=5014)    // vegepygmies
      )
        return TRUE;
    else
        return FALSE;

}

int CreatureGetHasHands(object oCreature=OBJECT_SELF)
{
    if(GetObjectType(oCreature)!=OBJECT_TYPE_CREATURE){ return FALSE; } //Creatures only
    //if(GetLocalInt(oCreature, "FORM_HASHANDS")){return TRUE;}

    int nType       = GetAppearanceType(oCreature);
    if(nType<7){ return TRUE; } // shortcut process for standard PC races
    string sHands   = Get2DAString("appearance_x","HASHANDS",nType);
    int bHands      = StringToInt(sHands);
    //if(bHands){SetLocalInt(oCreature, "FORM_HASHANDS", TRUE);}
    return bHands;
}

// Determines if the creature is aquatic (breathes in water/swims) - [FILE: v2_inc_creatures]
int CreatureGetIsAquatic(object oCreature=OBJECT_SELF)
{
    int bAquatic;

    /*
    bAquatic    = GetLocalInt(oCreature, "FORM_AQUATIC");
    if( bAquatic==1)
        return TRUE;
    else if(bAquatic==-1)
        return FALSE;
    */
    int nType       = GetAppearanceType(oCreature);
    string sAqua    = Get2DAString("appearance_x", "AQUATIC", nType);
        bAquatic    = StringToInt(sAqua);

    /*
    if(bAquatic)
        SetLocalInt(oCreature, "FORM_AQUATIC", 1);
    else
        SetLocalInt(oCreature, "FORM_AQUATIC", -1);
    */

    return bAquatic;
}

int CreatureGetIsSoftBodied(object oCreature=OBJECT_SELF)
{
    int bSoft;

    /*
    bSoft    = GetLocalInt(oCreature, "FORM_SOFTBODIED");
    if( bSoft==1)
        return TRUE;
    else if(bSoft==-1)
        return FALSE;
    */

    int nType       = GetAppearanceType(oCreature);
    string sSoft    = Get2DAString("appearance_x", "SOFTBODIED", nType);
        bSoft       = StringToInt(sSoft);

    /*
    if(bSoft)
        SetLocalInt(oCreature, "FORM_SOFTBODIED", 1);
    else
        SetLocalInt(oCreature, "FORM_SOFTBODIED", -1);
    */

    return bSoft;
}

int CreatureGetIsFlying(object oCreature=OBJECT_SELF)
{
    if(GetPhenoType(oCreature)==19) // ACP Arcane animations [see: q_inc_acp]
        return TRUE;

    string sFly = Get2DAString("appearance_x", "FLYING", GetAppearanceType(oCreature));
    int bFlying = StringToInt(sFly);

    return bFlying;
}


// Determines if the creature is a flier (but might not be flying) - [FILE: v2_inc_creatures]
// if bFly is TRUE and creature has an alt flying form it will fly
int CreatureGetIsFlier(object oCreature=OBJECT_SELF, int bFly=FALSE)
{
    /* // seems unnecessary if we give all fliers the flying feat (even temporarily).
    if( GetIsFlying(oCreature) )
        return TRUE;
    */
    int nFlier  = GetHasFeat(FEAT_FLIGHT, oCreature);
    if( nFlier && bFly )
    {
        int nAltFlier   = GetLocalInt(oCreature, "ALT_FLIER");
        if(nAltFlier==0)
        {
            int nForm   = GetAppearanceType(oCreature);
            if(     nForm==292 || nForm==1069
                ||  (nForm>=2047 && nForm<=2072)
            )
            {
                string sFlier   = Get2DAString("appearance_x", "ALT_FLIER", nForm);
                if(sFlier!="****" && sFlier !="")
                {
                    nAltFlier  = StringToInt(sFlier);
                    SetCreatureAppearanceType(oCreature, nAltFlier);
                    SetLocalInt(oCreature,"ALT_FLIER", nAltFlier);
                }
                else
                    SetLocalInt(oCreature,"ALT_FLIER", -1);
            }
        }
        else if( nAltFlier!=-1 )
            SetCreatureAppearanceType(oCreature, nAltFlier);

    }

    return nFlier;
}

int CreatureGetHasWildcraft(object oCreature=OBJECT_SELF)
{
    if(     GetLevelByClass(CLASS_TYPE_DRUID, oCreature)
        ||  GetLevelByClass(CLASS_TYPE_BARBARIAN, oCreature)
        ||  GetLevelByClass(CLASS_TYPE_RANGER, oCreature)
        //||  GetHasFeat(FEAT_WILD_AT_HEART,oCreature)
      )
        return TRUE;
    else
        return FALSE;
}

object CreatureGetResponseToSitterInSeat(object oCreature , object oSeat)
{
    object oSitter  = GetSittingCreature(oSeat);
    int nResponse   = FALSE;

    // relinquish claim on seat (no response)
    {
        DeleteLocalObject(oCreature,"SEAT_CLAIMED");
        DeleteLocalInt(oCreature,"SEAT_CLAIMED");
        if(GetLocalString(oSeat,"SEAT_CLAIMED")==ObjectToString(oCreature))
            DeleteLocalString(oSeat,"SEAT_CLAIMED");
        DeleteLocalInt(oCreature,"SEAT_SOCIAL");

        oSeat   = OBJECT_INVALID;
    }

    SetLocalInt(oCreature,"SEAT_RESPONSE", nResponse);

    return oSeat;
}

int CreatureGetIsBusy(object oCreature=OBJECT_SELF, int nIgnoreAction=ACTION_INVALID, int nIgnoreCombat=FALSE, int nIgnoreConversation=FALSE)
{
    if(     (!nIgnoreConversation && IsInConversation(oCreature))
        ||  (!nIgnoreCombat && GetIsInCombat(oCreature))
      )
        return TRUE;

    int nCurrent    = GetCurrentAction(oCreature);
    if(     nCurrent==ACTION_INVALID
        ||  nCurrent==nIgnoreAction
        ||  nCurrent==ACTION_WAIT
        ||  nCurrent==ACTION_SIT
        ||  nCurrent==ACTION_RANDOMWALK
      )
        return FALSE;
    else
        return TRUE;
}

void CreatureSetCommonListeningPatterns(object oCreature = OBJECT_SELF)
{
    //SetListening(OBJECT_SELF, TRUE);
    SetListenPattern(oCreature, SHOUT_PLACEABLE_ATTACKED+"**", 10);
    SetListenPattern(oCreature, SHOUT_PLACEABLE_DESTROYED+"**", 11);
    SetListenPattern(oCreature, SHOUT_ALERT+"**", 12);
    SetListenPattern(oCreature, SHOUT_FLEE+"**", 13);
    SetListenPattern(oCreature, SHOUT_SUBDUAL_DEAD+"**", 14);
    SetListenPattern(oCreature, SHOUT_SUBDUAL_ATTACK+"**", 15);
}

int GetIsShoutHeard(object oShouter)
{
    // telepathic or able to hear
    return(     GetLocalInt(oShouter, "AI_TELEPATHIC")
            ||  GetLocalInt(OBJECT_SELF, "AI_TELEPATHIC")
            ||(     !GetHasEffect(EFFECT_TYPE_DEAF)
                &&  !GetHasEffect(EFFECT_TYPE_SILENCE)
                &&  !GetHasEffect(EFFECT_TYPE_SILENCE, oShouter)
              )
          );
}

int CreatureGetIsCivilized(object oCreature=OBJECT_SELF)
{
    if(GetLocalInt(oCreature,"AI_CIVILIZED"))
        return TRUE;

    return FALSE;
}

int GetIsPrey(object oCreature, object oPredator=OBJECT_SELF)
{
    //if(!GetCreatureIsHungry(oPredator))
    //    return FALSE;

    string sPredID      = ObjectToString(oPredator);
    int bPrey           = GetLocalInt(oCreature,"PREY_OF_"+sPredID);
    if(bPrey==-1)
        return FALSE;
    else if(bPrey==TRUE)
        return TRUE;

    int nPreyRace       = GetRacialType(oCreature);
    int nPredRace       = GetRacialType(oPredator);
    int nPreyOnLarger   = GetLocalInt(oPredator, "AI_ATTACK_LARGER");
    int nPreySize       = GetCreatureSize(oCreature);
    int nPredSize       = GetCreatureSize(oPredator)+GetLocalInt(oPredator, "AI_SIZE_MODIFIER");

    if(     GetIsFriend(oCreature, oPredator)
        ||  GetFactionEqual(oCreature, oPredator)
        //||  GetSharesGroupMembership(oPredator,oCreature)
      )
    {
        SetLocalInt(oCreature,"PREY_OF_"+sPredID,-1);
        return FALSE;
    }
    else if(    nPredRace==RACIAL_TYPE_DRAGON
            ||( nPredRace==RACIAL_TYPE_UNDEAD
                &&(     nPreyRace!=RACIAL_TYPE_OOZE
                    &&  nPreyRace!=RACIAL_TYPE_ELEMENTAL
                    &&  nPreyRace!=RACIAL_TYPE_CONSTRUCT
                    &&  nPreyRace!=RACIAL_TYPE_OUTSIDER
                  )
              )
           )
    {
        SetLocalInt(oCreature,"PREY_OF_"+sPredID,1);
        return TRUE;
    }

    else if(     nPreyRace==RACIAL_TYPE_CONSTRUCT
            ||  nPreyRace==RACIAL_TYPE_ELEMENTAL
            ||  nPreyRace==RACIAL_TYPE_UNDEAD
            ||  nPreyRace==RACIAL_TYPE_DRAGON
            ||  CreatureGetIsIncorporeal(oCreature)
            ||( nPreySize>nPredSize && !nPreyOnLarger )
            ||( nPreyRace==RACIAL_TYPE_OOZE
                &&(     nPredRace!=RACIAL_TYPE_VERMIN
                    &&  nPredRace!=RACIAL_TYPE_OOZE
                    &&  nPredRace!=RACIAL_TYPE_ABERRATION
                    &&  nPredRace!=RACIAL_TYPE_ELEMENTAL
                  )
              )
           )
    {
        SetLocalInt(oCreature,"PREY_OF_"+sPredID,-1);
        return FALSE;
    }
    else if( CreatureGetIsFlying(oCreature)&&!CreatureGetIsFlier(oPredator) )
        return FALSE;

    if(GetLocalInt(oPredator, "AI_CARNIVORE") || GetLocalInt(oPredator, "AI_OMNIVORE"))
    {
        if(GetLocalInt(oCreature, "CREATURE_PLANT") && GetLocalInt(oPredator, "AI_CARNIVORE"))
        {
            SetLocalInt(oCreature,"PREY_OF_"+sPredID,-1);
            return FALSE;
        }

        if(GetIsNeutral(oCreature, oPredator))
        {
            if(GetLocalInt(oCreature, "AI_HERBIVORE"))
            {
                return TRUE;
            }
            else if(GetLocalInt(oCreature, "AI_OMNIVORE"))
            {
                if(     nPreySize<nPredSize
                    ||( GetLocalInt(oPredator,"AI_CARNIVORE")&&nPreyOnLarger )
                  )
                    return TRUE;
            }
            else if(GetLocalInt(oCreature, "AI_CARNIVORE"))
            {
                if(nPreySize<nPredSize)
                    return TRUE;
            }
            else
            {
                if(CreatureGetIsAnimal(oCreature))
                {
                    if(nPreySize<nPredSize||nPreyOnLarger)
                        return TRUE;
                }
                else
                {
                    if(GetLocalInt(oPredator, "AI_OMNIVORE"))
                    {
                        if(nPreySize<nPredSize||nPreyOnLarger)
                        {
                            if(d2()==1)
                                return TRUE;
                            else
                                return FALSE;
                        }
                        else
                            return FALSE;
                    }
                    else
                        return FALSE;
                }
            }
        }
        else if(GetIsEnemy(oCreature, oPredator))
        {
            if(GetLocalInt(oCreature, "AI_HERBIVORE")||GetLocalInt(oCreature, "AI_OMNIVORE"))
            {
                return TRUE;
            }
            else if(GetLocalInt(oCreature, "AI_CARNIVORE"))
            {
                if(nPreySize<nPredSize || nPreyOnLarger)
                    return TRUE;
            }
            else
            {
                if(nPreySize<nPredSize || nPreyOnLarger)
                    return TRUE;
            }
        }
    }
    else if(GetLocalInt(oPredator, "AI_HERBIVORE"))
    {
        if(GetLocalInt(oCreature, "CREATURE_PLANT"))
        {
            if(nPreySize<nPredSize || nPreyOnLarger)
            {
                SetLocalInt(oCreature,"PREY_OF_"+sPredID,1);
                return TRUE;
            }
        }
        else
        {
            SetLocalInt(oCreature,"PREY_OF_"+sPredID,-1);
            return FALSE;
        }
    }
    // predator lacks special animal behavior
    else
    {
        bPrey   = GetIsEnemy(oCreature, oPredator);
    }

    return bPrey;
}

float GetScentRange(object oCreature)
{
    int nRace   = GetRacialType(oCreature);
    if( GetHasFeat( FEAT_SCENT, oCreature) ) // scent feat
    {
        float fDist = GetLocalFloat(oCreature, "AI_DISTANCE_THREATENED");
        if(fDist==0.0)
            fDist   = 10.0;
        return fDist;
    }
    else
        return 0.0;
}

int GetReputationReactionType(object oTarget, object oSource=OBJECT_SELF, int bSharesGroup=FALSE)
{
    //string sPCID    = GetPCIdentifier(oTarget);

    //if(DEBUG && GetTag(oSource)=="aa_testcow")
    //   return 0;

    // Get current reputation
    int nRep    = GetReputation(oSource, oTarget);

    // adjust by historical record of combined penalties and bonuses
    /*
    if(GetLocalInt(oSource, "UNIQUE"))
        nRep    += PRR_GetHistoricalValue(oTarget, oSource);

    if(!GetIsCharmedBy(oTarget,oSource)&&PRR_CHARM_Check(oTarget,oSource))
        nRep    += 25;
    */

    if(nRep>89)
        return 2;
    else if(nRep<10 && !bSharesGroup) // group membership supresses hostility
        return 1;
    else
        return 0;
}

// ........  AREAS and subareas (triggers)......................................

string AreaGetDescription(object oPC, object oArea=OBJECT_SELF, int bEntry=FALSE, int nEntries=0)
{
    string sAreaDescription;

    // first entry
    if(bEntry && nEntries<=1)
    {
        if(GetIsNight())
            sAreaDescription    = GetLocalString(oArea, "AREA_DESCRIPTION_FIRST_NIGHT");
        if(sAreaDescription=="")
            sAreaDescription    = GetLocalString(oArea, "AREA_DESCRIPTION_FIRST");
    }

    // night description
    if(sAreaDescription=="" && GetIsNight())
        sAreaDescription    = GetLocalString(oArea, "AREA_DESCRIPTION_NIGHT");

    // default
    if(sAreaDescription=="")
        sAreaDescription    = GetLocalString(oArea, "AREA_DESCRIPTION");

    return sAreaDescription;
}

int AreaGetIsMappedByPC(object oPC, object oArea=OBJECT_SELF)
{
    // this is a place to check if oPC knows the entire area
    // intention is to have persistent knowledge of areas

    return FALSE;
}

int GetDescriptionCanContinue(object oPC, object oTrigger=OBJECT_SELF)
{
    // trigger only gives description when an object is present
    string sObject  = GetLocalString(oTrigger, "DESCRIPTION_OBJECT");
    if( sObject!="" )
    {
        int nNth=1;
        int bPresent;
        object oArea    = GetArea(oTrigger);
        object oNearest = GetNearestObjectByTag(sObject,oTrigger,nNth);
        while(      GetIsObjectValid(oNearest)
                &&  GetArea(oNearest)==oArea
             )
        {
            if(GetIsInSubArea(oNearest,oTrigger))
            {
                bPresent= TRUE;
                break;
            }

            oNearest    = GetNearestObjectByTag(sObject,oTrigger,++nNth);
        }

        if(!bPresent)
            return FALSE; // object to describe is not present.
    }

    // restricted time?
    int nHour       = GetTimeHour();
    int nHourStart  = GetLocalInt(oTrigger, "DESCRIPTION_HOUR_START");
    int nHourEnd    = GetLocalInt(oTrigger, "DESCRIPTION_HOUR_END");
    if(!nHourEnd) nHourEnd = 24;
    if(     (nHour<nHourStart||nHour>=nHourEnd)
        ||  (GetLocalInt(oTrigger, "DESCRIPTION_DAY") && !GetIsDay())
        ||  (GetLocalInt(oTrigger, "DESCRIPTION_NIGHT") && !GetIsNight())
      )
        return FALSE;

    // restricted to feat
    if(   //(GetLocalInt(oTrigger, "DESCRIPTION_TRACK") && !GetHasFeat(FEAT_TRACK, oPC)) ||
          //(GetLocalInt(oTrigger, "DESCRIPTION_SCENT") && !GetHasFeat(FEAT_SCENT, oPC)) ||
            (GetLocalInt(oTrigger, "DESCRIPTION_STONECUNNING") && !GetHasFeat(FEAT_STONECUNNING, oPC))
      )
        return FALSE;

    return TRUE;
}

void InitializeFade(object oObject)
{
    object oArea    = GetArea(oObject);
    int nFadeCnt    = GetLocalInt(oArea, "FADE_COUNT");
    int nIt         = 1;
    object oDummy   = GetLocalObject(oArea,"FADE_"+IntToString(nIt));
    while(GetIsObjectValid(oDummy))
        oDummy   = GetLocalObject(oArea,"FADE_"+IntToString(++nIt));
    if(nIt>nFadeCnt)
        SetLocalInt(oArea, "FADE_COUNT",nIt);
    // Store Object and Fade Time on oArea
    SetLocalObject(oArea, "FADE_"+IntToString(nIt), oObject);

    int nFadeTime   = GetLocalInt(oObject, "FADE_TIME");
    if(nFadeTime<1)
        nFadeTime   = 12;

    SetLocalInt(oArea, "FADE_"+IntToString(nIt), nFadeTime+GetTimeCumulative());
}

void ObjectsFade(object oArea)
{
    int nFadeCnt    = GetLocalInt(oArea, "FADE_COUNT");
    int nTime       = GetTimeCumulative();
    int nFade; string sFade; object oFade;
    int nIt         = nFadeCnt;
    int bDestroy;

    while(nIt>0)
    {
        sFade   = "FADE_"+IntToString(nIt);
        nFade   = GetLocalInt(oArea,sFade);
        if(nFade)
        {
            if(nFade<nTime)
            {
                if(nIt==nFadeCnt)
                    nFadeCnt--;
                bDestroy=1;
            }
        }
        else
            bDestroy=1;

        // Destroy Object
        if(bDestroy)
        {
            bDestroy= 0;
            oFade   = GetLocalObject(oArea, sFade);
            DeleteLocalObject(oArea,sFade); // garbage collection
            DeleteLocalInt(oArea,sFade); // garbage collection
            if(GetIsObjectValid(oFade))
                DestroyObject(oFade);
        }
        // continue countdown to 0
        nIt--;
    }

    if(nFadeCnt>0)
        SetLocalInt(oArea, "FADE_COUNT", nFadeCnt);
    else
        DeleteLocalInt(oArea, "FADE_COUNT");
}

// END TIME ....................................................................

// private function used in debuging XPRewardCombat - seems generally useful so leaving in util
void SendMessageToParty( object oMember, string sText )
{
  object oPartyMember = GetFirstPC();
  while( GetIsObjectValid(oPartyMember) )
  {
    if( GetFactionEqual( oPartyMember, oMember ) )
      SendMessageToPC( oPartyMember, sText );
    oPartyMember = GetNextPC();
  }
}

//void main(){}
