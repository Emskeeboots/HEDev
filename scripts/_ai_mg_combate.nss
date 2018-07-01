//::///////////////////////////////////////////////
//:: _ai_mg_combate
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef
*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "NW_I0_GENERIC"
#include "_inc_constants"

void main()
{
    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_END_COMBAT_ROUND));
    }
}
