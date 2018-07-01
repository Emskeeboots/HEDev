//::///////////////////////////////////////////////
//:: Name _ai_mg_death
//::///////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

*/
//:://////////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://///////////////////////////////////////////////

#include "x0_i0_spawncond"
//#include "x3_inc_horse"

#include "_inc_util"
#include "_inc_spells"
#include "_inc_xp"
//#include "_inc_loot"

void main()
{
    if (GetLocalInt(OBJECT_SELF, "bDEAD"))
        return; // we have already processed death once
    SetLocalInt(OBJECT_SELF, "bDEAD", TRUE);

    // Declase VARS --------------------------------------------
    object oKiller = GetLastKiller();


    // Shouts --------------------------------------------------
    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);


    // Mount Handling ------------------------------------------
    /*
    if(
        GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB")
            &&
        GetIsObjectValid(GetMaster(OBJECT_SELF))
      )
        SetLocalInt(GetMaster(OBJECT_SELF),"bX3_STORE_MOUNT_INFO",TRUE);
    */


    // Handle death of SCRY OBJECTS ----------------------------
    int nScrySpell  = GetLocalInt(OBJECT_SELF, "SCRY_SPELL");
    if(nScrySpell == SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE )
        ClairaudienceEnd(GetLocalObject(OBJECT_SELF, "CREATOR"));



    // Loot Drop and XP ----------------------------------------
    if(GetIsPC(oKiller))
    {
        //LootCreatureDeath(oKiller, OBJECT_SELF); // item drop
        XPRewardCombat(oKiller, OBJECT_SELF); // special XP based on Vives' system
    }

    // simple spawn. tracking deaths and spawns
    /*
    struct NPC Dead = GetCreatureData(OBJECT_SELF);
    if(GetIsObjectValid(Dead.oData))
    {
        SetLocalInt(Dead.oData, "nHP", 0);
        SetLocalInt(Dead.oData, "nDeaths", GetLocalInt(Dead.oData, "nDeaths")+1 );
        SetLocalInt(Dead.oData, "nSpawned", GetLocalInt(Dead.oData, "nSpawned")-1 );
    }
    */

    SetLocalInt( OBJECT_SELF, "bDEAD", TRUE );
}
