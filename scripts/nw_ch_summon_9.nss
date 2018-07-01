//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

This must support the OC henchmen and all summoned/companion
creatures.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//:: Updated By: Georg Zoeller, 2003-08-20: Added variable check for spawn in animation
//:: Updated By: Henesua (2014 jan 17) pre and post spawn

#include "x0_inc_henai"
#include "x2_inc_switches"

#include "_inc_constants"
#include "_inc_util"

// Bioware
const int EVENT_USER_DEFINED_PRESPAWN       = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN      = 1511;

void main()
{
    object oMaster      = GetMaster();

    // User defined OnSpawn event requested?
    int nSpecEvent = GetLocalInt(OBJECT_SELF,"X2_USERDEFINED_ONSPAWN_EVENTS");
    // Pre Spawn Event requested
    if (nSpecEvent == 1  || nSpecEvent == 3  )
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_USER_DEFINED_PRESPAWN) );

     //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    //1.71: multisummoning feature
    if(GetModuleSwitchValue("71_UNLIMITED_SUMMONING"))
    {
        int maxSummon = GetModuleSwitchValue("71_UNLIMITED_SUMMONING");
        int numSummon,nTh = 1;
        location lTarget = GetLocation(OBJECT_SELF);
        object oSummon, oPC = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC,lTarget,nTh);
        while(GetIsObjectValid(oPC))
        {
            numSummon = 1;
            while(GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED,oPC,numSummon)))
            {
               numSummon++;
            }
            if(maxSummon == 1 || maxSummon >= numSummon)
            {
                oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED,oPC,1);
                AssignCommand(oSummon,SetIsDestroyable(FALSE,FALSE,FALSE));
                AssignCommand(oSummon,DelayCommand(0.01,SetIsDestroyable(TRUE,FALSE,FALSE)));
            }
            oPC = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC,lTarget,++nTh);
        }
    }

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    if (GetAssociate(ASSOCIATE_TYPE_HENCHMAN, GetMaster()) == OBJECT_SELF) {
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);//Shadooow: this doesn't work! master always invalid
    }

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL))
    {
        CreatureDoIncorporeal(OBJECT_SELF);
        /*
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal        = ExtraordinaryEffect(eConceal);
        effect eGhost   = EffectCutsceneGhost();
        eGhost          = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, OBJECT_SELF);
        */
    }

    // Stealth or detect mode ------------------
    if(GetSpawnInCondition(NW_FLAG_STEALTH))
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
    if(GetSpawnInCondition(NW_FLAG_SEARCH))
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);

    // Set starting location
    SetAssociateStartLocation();

    //Post Spawn event requeste
    if (nSpecEvent == 2 || nSpecEvent == 3)
        SignalEvent(OBJECT_SELF,EventUserDefined(EVENT_USER_DEFINED_POSTSPAWN));
}
