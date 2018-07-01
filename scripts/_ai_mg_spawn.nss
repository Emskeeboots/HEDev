//::///////////////////////////////////////////////
//:: Name _ai_mg_spawn
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
    On Spawn script

    See the template: v2_ai_mg_userdef
    Make a copy of v2_ai_mg_userdef and rename
    for your spell crafted creature

    Use "X2_USERDEFINED_ONSPAWN_EVENTS"
    to specify pre and post spawn functions in your custom userdef script
    1 - Fire Userdefined Event 1510 (pre spawn)
    2 - Fire Userdefined Event 1511 (post spawn)
    3 - Fire both events

    You will need to set other custom user defined events
    in the post spawn event of your custom userdef script
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "x0_i0_spawncond"
#include "x2_inc_switches"

#include "_inc_constants"
#include "_inc_util"

const int EVENT_USER_DEFINED_PRESPAWN = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN = 1511;

void main()
{
    string sTag;
    object oNPC;
    // User defined OnSpawn event requested?
    int nSpecEvent = GetLocalInt(OBJECT_SELF,"X2_USERDEFINED_ONSPAWN_EVENTS");

    // Pre Spawn Event requested
    if (nSpecEvent == 1  || nSpecEvent == 3  )
        SignalEvent(OBJECT_SELF,EventUserDefined(EVENT_USER_DEFINED_PRESPAWN ));

    // Execute default OnSpawn script.
    // ***** Spawn-In Conditions ***** //
    // * the NPC will appear using the "EffectAppear" animation instead of fading in,
    // * this seems appropriate for a magically created creature
    // * if we don't like this, we can change it.
    SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);

    // * Goes through and sets up which shouts the NPC will listen to.
    SetListeningPatterns();

    // * If Incorporeal, apply changes
    if(GetCreatureFlag(OBJECT_SELF,CREATURE_VAR_IS_INCORPOREAL))
        CreatureDoIncorporeal(OBJECT_SELF);

    // Creature Naming ------------------------- // Henesua - markshire script reworked
    //ExecuteScript("v2_name_gen",OBJECT_SELF);

    //Post Spawn event requested?
    if (nSpecEvent == 2 || nSpecEvent == 3)
        SignalEvent(OBJECT_SELF,EventUserDefined(EVENT_USER_DEFINED_POSTSPAWN));
}
