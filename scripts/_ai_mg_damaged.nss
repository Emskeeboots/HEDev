//::///////////////////////////////////////////////
//:: _ai_mg_damaged
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    OnDamaged script

 */
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    // Send the user-defined event signal
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        object oDamager = GetLastDamager();
        int nDamage     = GetTotalDamageDealt();
        SetLocalObject(OBJECT_SELF, "USERD_DAMAGER", oDamager);
        SetLocalInt(OBJECT_SELF, "USERD_DAMAGE", nDamage);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DAMAGED));
    }
}
