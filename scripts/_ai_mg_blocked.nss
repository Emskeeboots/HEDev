//::///////////////////////////////////////////////
//:: _ai_mg_blocked
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "_inc_constants"

void main()
{
    if(GetLocalInt(OBJECT_SELF, "USERDEF_BLOCKED"))
    {
        object oDoor = GetBlockingDoor();
        SetLocalObject(OBJECT_SELF, "USERD_BLOCKING_DOOR", oDoor);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_BLOCKED));
    }
}
