//::///////////////////////////////////////////////
//:: Name _ai_dm_hb
//:://////////////////////////////////////////////
/*
    heartbeat event for dm possessed creature
*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2014 may 20)

#include "_inc_util"

void main()
{
    /*
    // was polymorphed... but now no longer
    if(     GetLocalInt(OBJECT_SELF, "POLYMORPHED")
        &&  !GetHasEffect(EFFECT_TYPE_POLYMORPH)
      )
    {
        RestoreCreaturePolymorphed();
    }
    */

    TrackDMPossession(GetMaster(),OBJECT_SELF);
}
