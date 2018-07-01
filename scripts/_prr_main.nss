//::///////////////////////////////////////////////
//:: _prr_main
//:://////////////////////////////////////////////
/*

    This is the Personal Reputation and Reaction system.
    This simple script is designed to be called by other
    scripts to give a more detailed and dynamic reputation
    system than the default reputation system for NWN. It
    uses the existing reputation system, optionally adds
    the differences in alignment, and finally adds in the
    PC's charisma bonus and a personal history variable
    that can be set and modified in an NPC's dialogue.

    To call the script, you must include "_prr_main".

    The value that is returned by GetPersonalReaction is
    an integer, and it can be a negative number. The
    value '50' is considered totally neutral, a value
    below '10' means the NPC hates the PC, and a value
    above '90' means the NPC really likes the PC. A
    series of scripts named "_prr_chk_*" should accompany
    this script and can be used to check the personal
    reaction of an NPC. These included scripts are also
    intented to be used as the basis for other custom scripts.

    Here is a complete list of the factors that determine
    the end reaction:
    - oPC's reaction to oNPC'S reputation (0 to 100)
    - oPC'S difference in alignment from oNPC (-10 to +10)
    - oPC's charisma adjustment (I think it's -8 to +20)
    - The historical reaction value for oPC, which is a variable
        held on oNPC (positive or negative number)

    The historical reaction variable can be set on an NPC like this:
        string sVarName = "prr_" + GetName(GetPCSpeaker());
        int nHistoricalReaction = GetLocalInt(OBJECT_SELF, sVarName);
        nHistoricalReaction--;
        SetLocalInt(OBJECT_SELF, sVarName, nHistoricalReaction);

    The above example reduces the NPC speaker's reaction to
    the PC by 1. The two scripts "_prr_insult" and "_prr_suckup"
    should be included with this script and can be used in
    dialogue to adjust the historical reaction. Like the
    other scripts that accompany this, these are also intended
    to be used as the basis for other custom scripts.

    Quick notes:
    - Alignment differences are considered by default. It is
        suggested that this be set to false when the NPC has
        not had a chance to really interact with the PC. For
        instance, if the NPC is a recluse that lives outside
        of the town the PC is opperating in, call this script
        with UseAling set to FALSE at first. Once the NPC has
        had a chance to see the true colors of the PC, you may
        want to call the script with UseAling set to TRUE.
    - Note that if the personal reaction value is below 10, NPCs
        may not be hostile to the PC. The global faction reputation
        needs to be 10 or less for the NPC to be hostile. Still,
        if the personal reaction value is less than 10, that NPC
        will probably not want to even talk to the PC.
    - This system also allows for PCs to lie about their alignment
        to an NPC, and for that falsehood to effect their
        interactions. Do this by adjusting the historical reputation
        variable on the NPC to compensate for the alignment adjustment.
        For instance, if a good PC lies and convinces an evil NPC that she
        wants to work for the evil side, you could adjust the historical
        reaction by enough to make it seem that the PC has gained the
        trust of the evil NPC.
    - I am releasing this script with the feedback lines uncommented
        so that you can check out how the math will work out in your module.
        I strongly suggest you comment the two feedback lines before
        letting anyone play it.
    - You can go as crazy as you want with the historical reaction values,
        but I suggest keeping the value between -50 or +50 for the most extreme
        cases. Looking at the math, this will give you a possible range in
        the end reaction value of roughly -68 to 180. This means you would
        be adjusting the faction's reputation value by about 70 or 80 points either
        way in extreme examples. A good guide for adjusting the values might be this:
            - Insulting or sucking up to an NPC is worth 1 point either way.
            - Performing some minor service (such as finding a ring) or
                hindering the life of an NPC (such as demanding more money
                through the use of force) might be woth 5 points either way.
            - Performing some great action (such as rescuing someone's child)
                or a terrible insult could be worth 10 or even 20 points.
        Of course, only you will know what's best for your module. I'm just
        trying to give you an idea of how the math works out. The main thing to
        remember is to not go too far in adjusting the historical reaction as
        this will take away from the significance of characters with a high
        charisma score. Remember, someone with god-like charisma (30) is only
        getting a +20 bonus. That means a peasant is going to feel the same
        about the most charasmatic person in the universe when she first meets
        him as she feels about that mundane guy who saved her life and
        the lives of her family.
    - Try and avoid allowing conversation loops that would let devious players
        abuse this system. Consider only allowing one time adjustments in an NPC's
        historical reaction per dialogue option using a local variable.

    If you use this system, please let me know how it works out for you. If you
    have any suggestions, gripes or bugs please contact me. Hope you enjoy it.

    Vendalus
    sbf5000us@yahoo.com

*/
//:://////////////////////////////////////////////
//:: Created By: Vendalus (October 12, 2002)
//:: Modified:  The Magus (2010 dec 31) adjusts to work with updated nbde
//:: Modified:  The Magus (2012 jun 17) PRR_LoadModule() caching factions as pseudo array on module
//:: Modified:  The Magus (2012 dec 5) changing data structure to use one database CAMPAIGN_NAME_PRR
//                                      thus the key to the data is Type_Prefix+sSourceKey+sTargetKey
//:://////////////////////////////////////////////

// Bioware
#include "nw_i0_plot"

// hill's edge
#include "_inc_constants"
#include "_inc_util"
#include "_inc_data"


//----------------------------------------------------------------
//prototypes
//----------------------------------------------------------------

// Gets oSource personal reaction and reputation feelings for oTarget      -[FILE: _prr_main]
// - UseAlign is an optional argument that is set to true by default
//      Set it to FALSE if you don't want to account for alignment differences.
int GetPersonalReaction(object oSource, object oTarget, int UseAlign = TRUE);

// Adjusts oSource's personal reaction and reputation feelings for oTarget      -[FILE: _prr_main]
// nLimit sets a limit beyond which this adjustment will do nothing (0 means no limit)
void AdjustPersonalReaction(object oSource, object oTarget, int nAdjustment, int nLimit=0);

// Returns oTarget's Reputation with oSource by nChange             -[FILE: _prr_main]
// the returned value is an adjustment to reputation, not the reputation itself
// sType    defines the type of reputation
//          "PERSONAL_" Personal reputation
//          "FACTION_"  Faction reputation
int PRR_GetHistoricalValue(object oTarget, object oSource, string sType="PERSONAL_");

// Adjusts oTarget's Reputation with oSource by nChange             -[FILE: _prr_main]
// nChange - defines the change to reputation, positive (like) or negative (dislike)
//              not the reputation itself
// sType - defines the type of reputation
//          "PERSONAL_" Personal reputation
//          "FACTION_"  Faction reputation
void PRR_AdjustHistoricalValue(object oTarget, object oSource, int nChange, string sType="PERSONAL_");

// Get the identity to use for this pc                              -[FILE: _prr_main]
string PRR_ConstructPCIdentity(object oPC);

//  PRR_AdjustPartyPRR
//  - Adjusts the PRR variable on this oNPC for each
//    member of oPC's party (faction) by nChange.
//    Meant to be used for when the party completes
//    a quest that would make the NPC feel better
//    about every member of the party.
//  - If you want to adjust for just one PC, use PRR_AdjustHistoricalValue
void PRR_AdjustPartyPRR(object oPC, object oNPC, int nChange);

// Adjusts all factions members reputation in relation to another faction.
// - oTargetCreature:
//     The creature whose faction members will be viewed differently by an entire faction.
// - oMemberOfSourceFaction:
//     The member of the faction that will have it's opinion changed.
// - nAdjustment:
//     The amount (positive or negative) that the factions opinion will change.
// - nOtherFactions:
//     Makes all the other factions that have Faction Focus placeables react to this change
void PRR_Adjust_Faction(object oTargetCreature, string sMemberOfSourceFaction, int nAdjustment, int nOtherFactions = FALSE);

// Adjusts all factions members reputation for a specific individual
// as a reaction to an adjustment to oMemberOfSourceFaction's faction.
// Useful for when you want a faction's enemies to get upset at a PC when
// they help the faction.
// - oTargetCreature:
//     The creature who will be viewed differently all the factions.
// - oMemberOfSourceFaction:
//     The member of the faction that will determine how much other factions will adjust.
// - nAdjustment:
//     The amount (positive or negative) that the factions opinion will change.
// See _prr_main for more information
void PRR_Adjust_Other_Factions(object oTargetCreature, object oMemberOfSourceFaction, int nAdjustment);

// Adjusts oEnemyFactions feelings for oSourceFaction by nAdjustment
// and all of oEnemyFaction's allies feelings for oSourceFaction by 1/2 that
// Good for when the party performs something that might start a war.
// The source is set with either oSourceFaction or sSourceFaction.
// Only one or the other should be used. The rule of thumb is:
//  - If you want to adjust how OBJECT_SELF's faction feels,
//    then use that and set sSourceFaction to "".
//  - If you want to adjust how a different faction feels, supply the name of the
//    faction creature (such as "FACTION_FOCUS_REDFANG") and use OBJECT_INVALID as the oSourceFaction
void PRR_Adjust_Enemy_Factions(object oSourceFaction, string sSourceFaction, string sEnemyFaction, int nAdjustment);

// PRR_AdjustReputation                                             -[FILE: _prr_main]
//  - Calls AdjustReputation
//  - Adds the adjustment to the historical value in the DB
//  - oMemberOfSourceFaction should be a FACTION_FOCUS creature (but this function can also find this creature)
//  - oTarget should NOT be a FACTION_FOCUS creature
void PRR_AdjustReputation(object oTarget, object oMemberOfSourceFaction, int nAdjustment);

// Finds the creature's Faction Focus                               -[FILE: _prr_main]
object PRR_GetFactionFocus(object oSource);

// Makes the charm effect happen. oSource casts a charm on oTarget  -[FILE: _prr_main]
void PRR_CHARM_AffectTarget(object oTarget, object oSource, int nDuration);

// Checks to see if a charm exists and if it has expired            -[FILE: _prr_main]
// look for a charm cast by oSource on oTarget
int PRR_CHARM_Check(object oTarget, object oSource);

// Clears away charm vars if expired                                -[FILE: _prr_main]
// removes persistency of a charm cast by oSource on oTarget
void PRR_CHARM_RemoveEffect(object oTarget, object oSource);

// Loads various info from the database into the module             -[FILE: _prr_main]
void PRR_LoadModule();

// Dumps everything into the campaign database                      -[FILE: _prr_main]
void PRR_FlushAll();

// Loads information for a pc                                       -[FILE: _prr_main]
void PRR_OnClientEnter(object oPC);

// Saves information and deletes the database object                -[FILE: _prr_main]
void PRR_OnClientLeave(object oPC);

// for testing                                                      -[FILE: _prr_main]
void PRR_Debug(string sMessage);

//----------------------------------------------------------------
// CONSTANTS
//----------------------------------------------------------------
/*
   SERIES_NAME
   - Change this to either the name of the PW or the name for the mod series
   TESTING_MODE
   - TRUE will offer a full range of debug messages for development
   - FALSE turns it off for when you are ready for release.

   ALIGN_ADJUST_TIMER
   - Number of seconds for alignment shifts due to stealing and bashing
     that must occur since the last shift before another can occur.
   - This is to keep a rogue in a room full of locked chests from
     totally screwing up the party's alignment.
   - Default is 5 minutes, which is meant to be one "instance" of chaotic action.
   - Set to 0 to disable this timer.
   - Set to -1 to turn off alignment shits entirely.
   - See the function PRR_ShiftAlignment in the _prr_pct file for more info.

*/
//const string SERIES_NAME = CAMPAIGN_NAME;
//const int TESTING_MODE = DEBUG;
const int ALIGN_ADJUST_TIMER = 300;

//----------------------------------------------------------------
//  FUNCTIONS
//----------------------------------------------------------------

/////////////////////////////////////////////////////
/*
  GetPersonalReaction
    Get's how oSource feels about oTarget using the full PRR system parameters
*/
/////////////////////////////////////////////////////
int GetPersonalReaction(object oSource, object oTarget, int UseAlign = TRUE)
{
    // first get the faction information
    int nReputation = GetReputation(oSource, oTarget);

    // Get the difference in alignments. Assume a difference of 100 is
    // the standard that gives no bonus or penalty, then divide by 10
    // so it's not so drastic
    int nAlignAdjustment = 0;
    if(UseAlign == TRUE)
    {
        int oPCLawChaos = GetLawChaosValue(oTarget);
        int oPCGoodEvil = GetGoodEvilValue(oTarget);
        int oNPCLawChaos = GetLawChaosValue(oSource);
        int oNPCGoodEvil = GetGoodEvilValue(oSource);
        int APB = abs(oNPCLawChaos - oPCLawChaos) + abs(oNPCGoodEvil - oPCGoodEvil);
        nAlignAdjustment = (APB - 100) / 10;
    }

    // Get the charisma modifier
    int nPCCharismaMod = GetAbilityModifier(ABILITY_CHARISMA, oTarget) * 2;

    // Get the stored historical reaction
    // string sVarName = "prr_" + GetName(oPC);
    // int nHistoricalReaction = GetLocalInt(oNPC, sVarName);
    int nHistoricalReaction = PRR_GetHistoricalValue(oTarget, oSource);

    // Check for charm
    if(     PRR_CHARM_Check(oSource, oTarget)
        //&&  !GetIsCharmedBy(oTarget,oSource)
      )
        nHistoricalReaction += 25;

    // get the final value
    int nReputationReaction = nReputation - nAlignAdjustment + nPCCharismaMod + nHistoricalReaction;

    // Give feedback for testing purposes
    string szMessage = "Checking "+GetName(oSource)+"'s reaction to "+GetName(oTarget)+": "+ IntToString(nReputation)  +   " - "  +  IntToString(nAlignAdjustment)  +  " + "  +  IntToString(nPCCharismaMod)  +  " + "   +  IntToString(nHistoricalReaction)  +  " = "   +  IntToString(nReputationReaction);
    PRR_Debug(szMessage);

    // return
    return nReputationReaction;
}

void AdjustPersonalReaction(object oSource, object oTarget, int nAdjustment, int nLimit=0)
{
    int nCurrentReaction    = GetReputation(oSource, oTarget);
    int nHistoricalReaction = PRR_GetHistoricalValue(oTarget, oSource);
    if(nLimit)
    {
        if(nAdjustment>0)
        {
            nLimit = nLimit - (nCurrentReaction+nHistoricalReaction);
            if(nLimit>0)
            {
                if(nLimit>=nAdjustment)
                    PRR_AdjustHistoricalValue(oTarget,oSource,nAdjustment);
                else
                    PRR_AdjustHistoricalValue(oTarget,oSource,nLimit);
            }
            else
                return;

        }
        else if(nAdjustment<0)
        {
            nLimit = nLimit-(nCurrentReaction+nHistoricalReaction);
            if(nLimit<0)
            {
                if(nLimit<=nAdjustment)
                    PRR_AdjustHistoricalValue(oTarget,oSource,nAdjustment);
                else
                    PRR_AdjustHistoricalValue(oTarget,oSource,nLimit);
            }
            else
                return;
        }
    }
    else
    {
        PRR_AdjustHistoricalValue(oTarget,oSource,nAdjustment);
    }
}

/////////////////////////////////////////////////////
/*
  PRR_GetHistoricalValue
    Gets the historical value from the database object
    in the vault.
*/
/////////////////////////////////////////////////////
int PRR_GetHistoricalValue(object oTarget, object oSource, string sType="PERSONAL_")
{
    if(sType=="FACTION_" && GetTag(oSource)!="FACTION_FOCUS")
        oSource   = PRR_GetFactionFocus(oSource);

    string sSourceKey = PRR_ConstructPCIdentity(oSource);
    string sTargetKey = PRR_ConstructPCIdentity(oTarget);
    int nHistoricalValue;
    if(sSourceKey!="" && sTargetKey!="")
        nHistoricalValue = NBDE_GetCampaignInt(CAMPAIGN_NAME+"_PRR", sType+sSourceKey+sTargetKey);

    return nHistoricalValue;
}

/////////////////////////////////////////////////////
/*
  PRR_AdjustHistoricalValue
    Adjusts the historical value in the vault.
*/
/////////////////////////////////////////////////////
void PRR_AdjustHistoricalValue(object oTarget, object oSource, int nChange, string sType="PERSONAL_")
{
    if(sType=="FACTION_" && GetTag(oSource)!="FACTION_FOCUS")
        oSource   = PRR_GetFactionFocus(oSource);

    int nOldValue       = PRR_GetHistoricalValue(oTarget, oSource, sType);
    int nNewValue       = nOldValue + nChange;
    string sSourceKey   = PRR_ConstructPCIdentity(oSource);
    string sTargetKey   = PRR_ConstructPCIdentity(oTarget);

    if(sSourceKey!="" && sTargetKey!="")
        NBDE_SetCampaignInt(CAMPAIGN_NAME+"_PRR", sType+sSourceKey+sTargetKey, nNewValue);
}

/////////////////////////////////////////////////////
/*
  SKS_AdjustPartyPRR
    Adjusts the PRR variable on this oNPC for each
    member of oPC's party (faction).
    Meant to be used for when the party completes
    a quest that would make the NPC feel better
    about every member of the party.
*/
/////////////////////////////////////////////////////
void SKS_AdjustPartyPRR(object oPC, object oNPC, int nChange)
{
    object oPartyMember = GetFirstFactionMember(oPC, TRUE);
    while(oPartyMember != OBJECT_INVALID)
    {
        PRR_AdjustHistoricalValue(oPC, oNPC, nChange);
        oPartyMember = GetNextFactionMember(oPC, TRUE);
    }
}


/////////////////////////////////////////////////////
/*
  PRR_ConstructPCIdentity
    Looks for the pcid saved on the pc, or creates one
    and saves it if not present.
    This way, you get a valid pcid when calling this
    during onClientLeave.
*/
/////////////////////////////////////////////////////
string PRR_ConstructPCIdentity(object oPC)
{
    string sPRRPCKey = GetLocalString(oPC, "PRR_PCKey");

    if(sPRRPCKey=="")
    {
        string sPRRPCKey  = GetPCID(oPC);// see _inc_util
        /*
        // we are hashing strings greater than 32 char in length because it is used as a DB name
        if( GetStringLength(sPRRPCKey)>(32-GetStringLength(CAMPAIGN_NAME_PRR)) )
            sPRRPCKey = IntToString(NBDE_Hash(sPRRPCKey));
        sPRRPCKey = CAMPAIGN_NAME_PRR+sPRRPCKey;
        */
        SetLocalString(oPC, "PRR_PCKey", sPRRPCKey);
    }

    return sPRRPCKey;
}

/////////////////////////////////////////////////////
/*
  PRR_Adjust_Faction
    - This subroutine adjusts the faction standing for each PC
      in the party. While this is a built in function in nwn,
      it was not working correctly for a while.
    - This version also allows for other factions to react to this
      adjustment with a call to PRR_Adjust_Other_Factions.
*/
/////////////////////////////////////////////////////
void PRR_Adjust_Faction(object oTargetCreature, string sMemberOfSourceFaction, int nAdjustment, int nOtherFactions = FALSE)
{
    // Get the faction object
    object oMemberOfSourceFaction;
    if(sMemberOfSourceFaction != "")
    {
        sMemberOfSourceFaction  = GetStringLowerCase(sMemberOfSourceFaction);
        int nNth = 0;
        object oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
        while(oFactionFocus != OBJECT_INVALID)
        {
            if(GetStringLowerCase(GetName(oFactionFocus)) == sMemberOfSourceFaction)
                oMemberOfSourceFaction = oFactionFocus;
            nNth++;
            oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
        }
    }
    else
    {
        oMemberOfSourceFaction = OBJECT_SELF;
    }
    // Now adjust the faction of each of the target faction's members
    object oFactionMember = GetFirstFactionMember(oTargetCreature, FALSE);
    while(GetIsObjectValid(oFactionMember)){
        PRR_AdjustReputation(oFactionMember, oMemberOfSourceFaction, nAdjustment);
        // If we are having the other factions react to this adjustment, then call it
        if(nOtherFactions == TRUE){
            PRR_Adjust_Other_Factions(oFactionMember, oMemberOfSourceFaction, nAdjustment);
        }
        oFactionMember = GetNextFactionMember(oTargetCreature, FALSE);
    }
}

/////////////////////////////////////////////////////
/*
  PRR_Adjust_Other_Factions
    Adjusts all factions members reputation for a specific individual
    as a reaction to an adjustment to oMemberOfSourceFaction's faction.
    Useful for when you want a faction's enemies to get upset at a PC when
    they help the faction.
     - oTargetCreature:
         The creature's faction who will be viewed differently all the factions.
     - oMemberOfSourceFaction:
         The member of the faction that will determine how much other factions will adjust.
     - nAdjustment:
         The amount (positive or negative) that the factions opinion will change.
    This script works by finding the object FACTION_FOCAL_POSITION and finding all
    placeables with the tag FACTION_FOCUS that are within 15'. Each FACTION_FOCUS's
    faction is retrieved, that factions feelings towards oMemberOfSourceFaction's
    faction is tested and a resulting adjustment in the feelings towards oTargetCreature
    is implemented.
*/
/////////////////////////////////////////////////////
void PRR_Adjust_Other_Factions(object oTargetCreature, object oMemberOfSourceFaction, int nAdjustment)
{
    int nMatch = 0;
    int nNth = 0;
    object oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    while(oFactionFocus != OBJECT_INVALID)
    {
        nMatch = GetFactionEqual(oFactionFocus, oMemberOfSourceFaction);
        if(!nMatch)
        {
            int nRep = GetReputation(oFactionFocus, oMemberOfSourceFaction);
            float nAdjustedReaction = nAdjustment * (((IntToFloat(nRep) - 50) / 100) * 2);
            PRR_AdjustReputation(oTargetCreature, oFactionFocus, FloatToInt(nAdjustedReaction));
                /* For testing purposes - uncomment to see how the faction standings are moving around
                PRR_Debug("-------------");
                PRR_Debug("PRR_Adjust_Other_Factions - Adjusting " + GetName(oFactionFocus) + "by " + IntToString(nAdjustment) + " *(((" + IntToString(nRep) + " - 50) *2) / 100) = " + FloatToString(nAdjustedReaction) + "(" + IntToString(FloatToInt(nAdjustedReaction)) + ")");
                float Var1 = IntToFloat(nRep) - 50;
                PRR_Debug("nRep - 50 = " + FloatToString(Var1));
                float Var2 = Var1 * 2;
                PRR_Debug("Var1 * 2 = " + FloatToString(Var2));
                float Var3 = Var2 / 100;
                PRR_Debug("Var2 / 100 = " + FloatToString(Var3));
                float Var4 = nAdjustment * Var3;
                PRR_Debug("nAdjustment * Var3 = " + FloatToString(Var4));
                */
        }
        nNth++;
        oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    }
}

/////////////////////////////////////////////////////
/*
  PRR_Adjust_Enemy_Factions

*/
/////////////////////////////////////////////////////
void PRR_Adjust_Enemy_Factions(object oSourceFaction, string sSourceFaction, string sEnemyFaction, int nAdjustment)
{
    PRR_Debug("--------");
    PRR_Debug("CALLING ADJUST ENEMY FACTIONS");

    // Set up some vars
    int nMatch = 0;
    int nNth = 0;
    object oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    object oEnemyFaction;

    // Get the right object for the enemy faction
    while(oFactionFocus != OBJECT_INVALID)
    {
        //PRR_Debug("Checking enemy focus object: " + GetName(oFactionFocus) + " vs " + sEnemyFaction);
        if(GetName(oFactionFocus) == sEnemyFaction)
        {
            oEnemyFaction = oFactionFocus;
            //PRR_Debug("Enemy focus set to " + GetName(oEnemyFaction));
        }
        // use the oSourceFaction's faction focus object instead
        if(GetFactionEqual(oSourceFaction, oFactionFocus) || sSourceFaction == GetName(oFactionFocus))
        {
            oSourceFaction = oFactionFocus;
            //PRR_Debug("Source focus set to " + GetName(oSourceFaction));
        }
        nNth++;
        oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    }

    // resest the counter so we can go through them again
    // go through the factions and adjust the reations
    nNth = 0;
    oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    while(oFactionFocus != OBJECT_INVALID)
    {
        nMatch = GetFactionEqual(oFactionFocus, oEnemyFaction);
        // if this is not the enemy faction
        // we do a less powerful shift
        // and only if a friend of the enemy
        if(!nMatch)
        {
            int nRep = GetReputation(oFactionFocus, oEnemyFaction);
            if(nRep >= 90)
            {
                float nAdjustedReaction = IntToFloat(nAdjustment) / 2;
                //PRR_AdjustReputation(oFactionFocus, oSourceFaction, FloatToInt(nAdjustedReaction));
                PRR_AdjustReputation(oSourceFaction, oFactionFocus, FloatToInt(nAdjustedReaction));
                //PRR_Debug("PRR_Adjust_Enemy_Factions (half for not enemy) - Adjusting how "+GetName(oSourceFaction)+"'s faction feels about "+GetName(oFactionFocus)+" by " + IntToString(FloatToInt(nAdjustedReaction)));
                PRR_Debug("PRR_Adjust_Enemy_Factions (half for not enemy) - Adjusting how "+GetName(oFactionFocus)+"'s faction feels about "+GetName(oSourceFaction)+" by " + IntToString(FloatToInt(nAdjustedReaction)));
            }
        // if it is the enemy action we full
        }
        else
        {
            float nAdjustedReaction = IntToFloat(nAdjustment);
            PRR_AdjustReputation(oSourceFaction, oFactionFocus, FloatToInt(nAdjustedReaction));
            //PRR_AdjustReputation(oFactionFocus, oSourceFaction, FloatToInt(nAdjustedReaction));
            PRR_Debug("PRR_Adjust_Enemy_Factions (full for is enemy) - Adjusting how "+GetName(oFactionFocus)+"'s faction feels about "+GetName(oSourceFaction)+" by " + IntToString(FloatToInt(nAdjustedReaction)));
            //PRR_Debug("PRR_Adjust_Enemy_Factions (full for is enemy) - Adjusting how "+GetName(oSourceFaction)+"'s faction feels about "+GetName(oFactionFocus)+" by " + IntToString(FloatToInt(nAdjustedReaction)));
        }
        nNth++;
        oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    }
    PRR_Debug("FINISHED WITH ADJUST ENEMY FACTIONS");
    PRR_Debug("--------");
}

//::///////////////////////////////////////////////
//::  PRR_AdjustReputation
//::     - Calls AdjustReputation  - which adjusts oTarget's reputation with oSource's entire faction
//::     - Adds the adjustment to the historical value in the DB
//::     - oMemberOfSourceFaction should be a FACTION_FOCUS creature.
//::     - oTarget should NOT be a FACTION_FOCUS creature
//::///////////////////////////////////////////////
void PRR_AdjustReputation(object oTarget, object oMemberOfSourceFaction, int nAdjustment)
{
    // find the Faction Focus if we need to
    if(GetTag(oMemberOfSourceFaction)!="FACTION_FOCUS")
        oMemberOfSourceFaction   = PRR_GetFactionFocus(oMemberOfSourceFaction);

    AdjustReputation(oTarget, oMemberOfSourceFaction, nAdjustment);

    // Debug string
    if(MODULE_DEBUG_MODE)
    {
        string sName    = GetName(oMemberOfSourceFaction);
        string sNameTar = GetName(oTarget);
        PRR_Debug("Adjusting how the "+sName+" faction feels about "+sNameTar+" by "+IntToString(nAdjustment)+".");
    }

    // Persistence
    PRR_AdjustHistoricalValue(oTarget, oMemberOfSourceFaction, nAdjustment, "FACTION_");
}

object PRR_GetFactionFocus(object oSource)
{
    object oMod             = GetModule();
    int nNth                = 1;
    object oFactionFocus    = GetLocalObject(oMod, "FACTION"+IntToString(nNth));
    while(oFactionFocus!=OBJECT_INVALID)
    {
        if(GetFactionEqual(oFactionFocus,oSource))
            return oFactionFocus;

        oFactionFocus    = GetLocalObject(oMod, "FACTION"+IntToString(++nNth));
    }
    return OBJECT_INVALID;
}

//::///////////////////////////////////////////////
//::  PRR_CHARM_AffectTarget
//::     - Creates a prr charm effect, which is just a
//::       prr historical adjustment
//::///////////////////////////////////////////////
void PRR_CHARM_AffectTarget(object oTarget, object oSource, int nDuration)
{
    // Calculate the day and hour the effect will expire
    int nCurHour    = GetTimeCumulative(TIME_HOURS);

    // Now save that expiration day and time
    string sSourceKey   = PRR_ConstructPCIdentity(oSource);
    string sTargetKey   = PRR_ConstructPCIdentity(oTarget);
    if(sSourceKey!=""&&sTargetKey!="")
        NBDE_SetCampaignInt(CAMPAIGN_NAME+"_PRR", "CHARMED_HOUR_"+sSourceKey+sTargetKey, nCurHour+nDuration);
}

//::///////////////////////////////////////////////
//::  PRR_CHARM_Check
//::     - Checks to see if there is a charm
//::     - and if so checks to see if it has expired
//::     - if it has, call PRR_CHARM_RemoveEffect
//::     - As of 2.1, the actual adjustment to the
//::       PRR value happens in GetPersonalReputation
//::///////////////////////////////////////////////
int PRR_CHARM_Check(object oTarget, object oSource)
{
    // Get the vars
    string sSourceKey   = PRR_ConstructPCIdentity(oSource);
    string sTargetKey   = PRR_ConstructPCIdentity(oTarget);
    int nExpireHour     = NBDE_GetCampaignInt(CAMPAIGN_NAME+"_PRR", "CHARMED_HOUR_"+sSourceKey+sTargetKey);
    if(!nExpireHour)
        return FALSE;
    // if the expiration is defined check the date then the hour
    // if expired, called the remove function. Otherwise return true.
    else if(nExpireHour>0 && nExpireHour<GetTimeCumulative(TIME_HOURS))
    {
        PRR_CHARM_RemoveEffect(oTarget, oSource);
        return FALSE;
    }

    return TRUE;
}

//::///////////////////////////////////////////////
//::  PRR_CHARM_RemoveEffect
//::     - With 2.1, this just cleans out the vars
//::///////////////////////////////////////////////
void PRR_CHARM_RemoveEffect(object oTarget, object oSource)
{
    string sSourceKey   = PRR_ConstructPCIdentity(oSource);
    string sTargetKey   = PRR_ConstructPCIdentity(oTarget);
    NBDE_DeleteCampaignInt(CAMPAIGN_NAME+"_PRR", "CHARMED_HOUR_"+sSourceKey+sTargetKey);
}

//::///////////////////////////////////////////////
//::  PRR_LoadModule
//::     - Loads various info from the database
//::     - Goes through each faction focus and
//::       recreates the faction relationships.
//::///////////////////////////////////////////////

void PRR_LoadModuleSub(object oTargetFocus)
{
    //string sFactionName;
    // Unique ID of Faction Holder
    int i = 0; float fDelay;

    object oFactionFocus = GetObjectByTag("FACTION_FOCUS", i);
    while(GetIsObjectValid(oFactionFocus))
    {
        //sFactionName  = GetName(oFactionFocus);

        if(!GetFactionEqual(oFactionFocus, oTargetFocus))
        {
            int nAdjustRep  = PRR_GetHistoricalValue(oTargetFocus, oFactionFocus, "FACTION_");
            fDelay         += 0.5;
            DelayCommand(fDelay, AdjustReputation(oTargetFocus, oFactionFocus, nAdjustRep));
            //PRR_Debug("Setting how "+sFactionName+" feels about "+GetName(oTargetFocus)+" to "+IntToString(nAdjustRep)+" = "+IntToString(nStoredRep));
        }

        i++;
        oFactionFocus   = GetObjectByTag("FACTION_FOCUS", i);
    }
}

void PRR_LoadModule()
{
    WriteTimestampedLogEntry("PRR_LoadModule(): Loading faction information...");

    object oMod     = GetModule();
    int nNth, i, nPlayerKey, nReturning;
    string sPlayerKey;
    // reputation variables
    int nCurrentRep, nStoredRep, nAdjustRep;
    string sFactionName, sTargetName, sModFactionID;

    object oTargetFocus = GetObjectByTag("FACTION_FOCUS", nNth);
    while(GetIsObjectValid(oTargetFocus))
    {
        nNth++;
        // store faction holder on module for later reference.
        // The name of the object has the name of the faction.
        sTargetName     = GetStringLowerCase(GetName(oTargetFocus));
        sModFactionID   = "FACTION"+IntToString(nNth);
        SetLocalString(oMod, sModFactionID, sTargetName);
        SetLocalObject(oMod, sModFactionID, oTargetFocus);
        SetLocalObject(oMod, sTargetName, oTargetFocus);

        WriteTimestampedLogEntry("PRR_LoadModule(): "+sModFactionID+" "+sTargetName  );

        // MAGUS
        DelayCommand(0.1, PRR_LoadModuleSub(oTargetFocus));

        oTargetFocus        = GetObjectByTag("FACTION_FOCUS", nNth);
    }
    // Record number of factions
    SetLocalInt(oMod, "FACTIONS", nNth);
    WriteTimestampedLogEntry("PRR_LoadModule(): Finished loading all factions.");
    //PRR_Debug("Finished loading all factions.");
}

//::///////////////////////////////////////////////
//::  PRR_FlushAll
//::     - Takes all database objects and puts them in the campaign database
//::///////////////////////////////////////////////
void PRR_FlushAll()
{
    WriteTimestampedLogEntry("PRR_FlushAll(): Flushing PRR databases...");

    NBDE_FlushCampaignDatabase(CAMPAIGN_NAME+"_PRR");

    /*
    // MAGUS
    // this was a mess of databases so I removed it, and packed everything reputation related in one database

    float fDelay = 0.0;
    string sPlayerKey;
    // flush all the current players
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        if(!GetIsDM(oPC))
        {
            sPlayerKey  = PRR_ConstructPCIdentity(oPC);
            DelayCommand(fDelay, NBDE_FlushCampaignDatabase(sPlayerKey));
            fDelay += 1.0;
        }
        oPC = GetNextPC();
    }
    //PRR_Debug("Finished flushing all players...");
    WriteTimestampedLogEntry("PRR_FlushAll(): Finished flushing PRR players...");

    // flush all the faction focus objects
    int nNth = 1;
    object oMod = GetModule();
    object oFactionFocus = GetLocalObject(oMod,"FACTION"+IntToString(nNth));
    while(GetIsObjectValid(oFactionFocus))
    {
        sPlayerKey      = PRR_ConstructPCIdentity(oFactionFocus);
        DelayCommand(fDelay, NBDE_FlushCampaignDatabase(sPlayerKey));
        fDelay += 1.0;
        nNth++;
        oFactionFocus   = GetLocalObject(oMod,"FACTION"+IntToString(nNth));
    }
    //PRR_Debug("Finished flushing all factions.");
    WriteTimestampedLogEntry("PRR_FlushAll(): Finished flushing PRR factions.");
    */
}

//::///////////////////////////////////////////////
//::  PRR_OnClientEnter
//::     -
//::///////////////////////////////////////////////
void PRR_OnClientEnter(object oPC)
{
    string sPCKey   = PRR_ConstructPCIdentity(oPC);
    int nReturning  = GetLocalInt(oPC, "PRR_RETURNING");
    SetLocalInt(oPC, "PRR_RETURNING", TRUE);

    if(!nReturning)
    {
        // Update all faction information to make it current.
        float fDelay;
        int nNth = 0;
        object oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
        while(GetIsObjectValid(oFactionFocus))
        {
            int nAdjustRep  = PRR_GetHistoricalValue(oPC, oFactionFocus, "FACTION_");
            fDelay += 0.5;
            DelayCommand(fDelay, AdjustReputation(oPC, oFactionFocus, nAdjustRep));

            nNth++;
            oFactionFocus = GetObjectByTag("FACTION_FOCUS", nNth);
        }
    }
}

//::///////////////////////////////////////////////
//::  PRR_OnClientLeave
//::     -
//::///////////////////////////////////////////////
//:: Modified: The Magus (2010 dec 31)
//::        - set up as a function call for on_client_leave script
//::          and adjusted the NBDE functions to work better with the latest version of NBDE
void PRR_OnClientLeave(object oPC)
{
    WriteTimestampedLogEntry("PRR_OnClientLeave(): Cleaning up for "+GetName(oPC));
    /*
    // no longer necessary as all PRR has been moved to one DB
    string sPlayerKey   = PRR_ConstructPCIdentity(oPC);
    if(sPlayerKey!="")
    {
        NBDE_FlushCampaignDatabase(sPlayerKey);
        NBDE_UnloadCampaignDatabase(sPlayerKey);
    }
    */
}

//::///////////////////////////////////////////////
//::  PRR_Debug
//::     - debug script
//::///////////////////////////////////////////////
void PRR_Debug(string sMessage)
{
     if(MODULE_DEBUG_MODE)
     {
         SendMessageToPC(GetFirstPC(), sMessage);
         SendMessageToAllDMs(sMessage);
         PrintString(sMessage);
     }
}

//void main(){}
