//::///////////////////////////////////////////////
//:: _ai_mg_rested
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    OnRested event handler
 */
//:://////////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////////

#include "nw_i0_generic"

#include "_inc_constants"

void main()
{
    // Send the disturbed flag if appropriate.
    if(GetSpawnInCondition(NW_FLAG_RESTED_EVENT))
    {
        int nRestEvent = GetLastRestEventType();
        SetLocalInt(OBJECT_SELF, "USERD_REST_TYPE", nRestEvent);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_RESTED));
    }
}
