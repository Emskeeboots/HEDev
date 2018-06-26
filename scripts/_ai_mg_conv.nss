//::///////////////////////////////////////////////
//:: _ai_mg_conv
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    OnConversation event handler
 */
//:://////////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        // Store what we just 'heard'
        object oShouter = GetLastSpeaker();
        int nMatch      = GetListenPatternNumber();
        string sMatch   = GetMatchedSubstring(0);
        SetLocalObject(OBJECT_SELF, "USERD_LAST_SHOUTER", oShouter);
        SetLocalInt(OBJECT_SELF, "USERD_LISTEN_PATTERN_NUMBER", nMatch);
        SetLocalString(OBJECT_SELF, "USERD_LISTEN_PATTERN_MATCH", sMatch);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}
