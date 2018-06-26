//::///////////////////////////////////////////////
//:: _ai_mg_percept
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    OnPerceived script

 */
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT))
    {
        object oPercep  = GetLastPerceived();
        if(!GetIsObjectValid(oPercep))
            return;
        SetLocalObject(OBJECT_SELF, "USERD_PERCEIVED", oPercep);
        SetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_SEEN", GetLastPerceptionSeen());
        SetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_HEARD", GetLastPerceptionHeard());
        SetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_VANISHED", GetLastPerceptionVanished());
        SetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_INAUDIBLE", GetLastPerceptionInaudible());
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_PERCEIVE));
    }
}
