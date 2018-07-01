//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Special Spawn Script for Custom Familiars, Animal Companions, and Summons

    THE MAGUS' INNOCUOUS FAMILIARS
    spawning handled in FamiliarSpawnEvent()
*/
//:://////////////////////////////////////////////
//:: CreatedPreston Watamaniuk (Nov 19, 2001)
//:: Modified: Deva Winblood (2007-12-31)
//:: Modified: The Magus (2013 jan 16) Innocuous Familiars - FamiliarSpawnEvent()
//:://////////////////////////////////////////////

// INCLUDES --------------------------------------------------------------------
#include "X0_INC_HENAI"
#include "x2_inc_switches"

#include "_inc_data"

// THE MAGUS' INNOCUOUS FAMILIARS
#include "_inc_pets"

// Bioware
const int EVENT_USER_DEFINED_PRESPAWN       = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN      = 1511;

// IMPLEMENTATION --------------------------------------------------------------
void main()
{
    // User defined OnSpawn event requested?
    int nSpecEvent = GetLocalInt(OBJECT_SELF,"X2_USERDEFINED_ONSPAWN_EVENTS");
    // Pre Spawn Event requested
    if (nSpecEvent == 1  || nSpecEvent == 3  )
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_USER_DEFINED_PRESPAWN ));

    SetAssociateListenPatterns();   //Sets up the special henchmen listening patterns
    bkSetListeningPatterns();       //Goes through and sets up which shouts the NPC will listen to.

    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50, FALSE);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, FALSE);
    SetAssociateState(NW_ASC_DISARM_TRAPS, FALSE);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE); //User ranged weapons by default if true.
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);

    int nType = GetAssociateType(OBJECT_SELF);
    switch (nType)
    {
        case ASSOCIATE_TYPE_FAMILIAR:
            // THE MAGUS' INNOCUOUS FAMILIARS
            FamiliarSpawnEvent(GetMaster());
        break;
        // Summoned monsters, and animal companions need to stay further back due to their size.
        case ASSOCIATE_TYPE_ANIMALCOMPANION:
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
            SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
        break;
        /* // not sure why this was missing, but uncomment if needed
        case ASSOCIATE_TYPE_HENCHMAN:
        break;
        */
        case ASSOCIATE_TYPE_DOMINATED:
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
            SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
        break;
        case ASSOCIATE_TYPE_SUMMONED:
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
            SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
        break;
        default:
        break;
    }

    // * Feb 2003: Set official campaign henchmen to have no inventory
    //SetLocalInt(oFamiliar, "X0_L_NOTALLOWEDTOHAVEINVENTORY", 10) ;

    SetAssociateStartLocation();
    // SPECIAL CONVERSATION SETTTINGS
    //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
    //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
            // This causes the creature to say a special greeting in their conversation file
            // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
            // greeting in order to designate it. As the creature is actually saying this to
            // himself, don't attach any player responses to the greeting.

    //Post Spawn event requeste
    if (nSpecEvent == 2 || nSpecEvent == 3)
        SignalEvent(OBJECT_SELF,EventUserDefined(EVENT_USER_DEFINED_POSTSPAWN));
}
