//::///////////////////////////////////////////////
//:: _ai_mg_disturb
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    OnDisturbed event handler
 */
//:://////////////////////////////////////////////////
//:: Created: Henesua (2012 sept 21)
//:://////////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    // Send the disturbed flag if appropriate.
    if(GetSpawnInCondition(NW_FLAG_DISTURBED_EVENT))
    {
        object oTarget = GetLastDisturbed();
        SetLocalObject(OBJECT_SELF, "USERD_LAST_DISTURBED", oTarget);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DISTURBED));
    }
}
