//::///////////////////////////////////////////////
//:: _ai_mg_attack
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    OnPhysicallyAttacked script

 */
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    if(GetSpawnInCondition(NW_FLAG_ATTACK_EVENT))
    {
        object oAttacker    = GetLastAttacker();
        SetLocalObject(OBJECT_SELF, "USERD_ATTACKER", oAttacker);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_ATTACKED));
    }
}
