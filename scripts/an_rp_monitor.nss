/* _rpmonitor  author: Andrei

Functions for monitoring a PC's text assisted RP for purposes of determining
PC's elligabilty for RP XP tick reward.

*/

/////////////////// FUNCTIONS DECLARED ///////////////////////
// Returns 1 if PC is deemed to be acitvely roleplaying, 0 if not.
int GetIsRolePlaying (object oPC);

void SetIsRolePlaying (object oPC);

/////////////////// END DECLARATIONS /////////////////////////

////////////////// FUNCTIONS IMPLEMENTED ////////////////////

int GetIsRolePlaying (object oPC) {
    return GetLocalInt(oPC, "IS_ROLEPLAYING");
}


void SetIsRolePlaying (object oPC) {
    SetLocalInt(oPC, "IS_ROLEPLAYING", 0);

    // If PC did not use the chat channel within the previous hour, the reward is zero.
    if (GetTimeHour()- GetLocalInt(oPC, "LAST_CHAT_TIME_PC") > 1) {
        SetLocalInt(oPC, "IS_ROLEPLAYING", 0);
    }
    else {
        SetLocalInt(oPC, "IS_ROLEPLAYING", 1);
    }
}
/////////////////// END IMPLENTATIONS //////////////////////













///////////////////////// MAIN //////////////////////////////


/*void main()
{
    object oPC = OBJECT_SELF;
    SetLocalInt(oPC, "IS_ROLEPLAYING", 0);

    if (GetTimeHour()- GetLocalInt(oPC, "LAST_CHAT_TIME_PC") > 1) {
        SendMessageToPC(oPC, "DEBUG: _rp_monitor: IS_ROLEPLAYING is evaluated to FALSE");
        SendMessageToPC(oPC, "DEBUG: _rp_monitor: LAST_CHAT_TIME: "+IntToString(GetLocalInt(oPC, "LAST_CHAT_TIME_PC")));
        SetLocalInt(oPC, "IS_ROLEPLAYING", 0);
    }
    else {
        SendMessageToPC(oPC, "DEBUG: _rp_monitor: IS_ROLEPLAYING is evaluated to TRUE");
        SendMessageToPC(oPC, "DEBUG: _rp_monitor: LAST_CHAT_TIME: "+IntToString(GetLocalInt(oPC, "LAST_CHAT_TIME_PC")));
        SetLocalInt(oPC, "IS_ROLEPLAYING", 1);
    }
}
*/
// END MAIN

