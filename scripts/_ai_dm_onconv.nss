//::///////////////////////////////////////////////
//:: Name _ai_dm_onconv
//:://////////////////////////////////////////////
/*
    On Conversation event for dm possessed creature
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2014 may 20)
//:://////////////////////////////////////////////

#include "nw_i0_generic"
#include "_inc_util"

void main()
{
    // * if petrified or dead, exit directly.
    if(     GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF)
        ||  GetIsDead(OBJECT_SELF)
      )
        return;

    // See if what we just 'heard' matches any of our predefined patterns
    int nMatch      = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    object oDM      = GetMaster();

    // not a match -- thus it is probably a PC trying to start a convo
    if (nMatch == -1)
    {
        if(GetIsDMPossessed(OBJECT_SELF))
        {
            SendMessageToPC(oShouter,RED+"Please wait for the DM to respond.");
            SendMessageToPC(oDM,PALEBLUE+GetName(oShouter)+DMBLUE+" is trying to speak with "+PALEBLUE+GetName(OBJECT_SELF)+DMBLUE+".");
        }
        return;
    }
    // Respond to shouts from friendly non-PCs only
    else if(    GetIsObjectValid(oShouter)
            &&  !GetIsPC(oShouter)
            &&  (   GetIsFriend(oShouter)
                //||  GetSharesGroupMembership(oShouter)
                  || GetFactionEqual(oShouter)
                )
           )
    {
        object oIntruder = OBJECT_INVALID;
        // Determine the intruder if any
        if(nMatch==4)
        {
            oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
        }
        else if(nMatch==6)
        {
            oIntruder = GetLastHostileActor(oShouter);
            if(!GetIsObjectValid(oIntruder))
            {
                oIntruder = GetAttemptedAttackTarget();
                if(!GetIsObjectValid(oIntruder))
                {
                    oIntruder = GetAttemptedSpellTarget();
                    if(!GetIsObjectValid(oIntruder))
                    {
                        oIntruder = OBJECT_INVALID;
                    }
                }
            }
        }
        // FLEE SHOUT HEARD ---------------------
        else if( nMatch==13 )
        {
            // animals shouting to flee
            if( GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) )
            {
                if(     GetLocalInt(OBJECT_SELF, "AI_PACK")
                    //&&  GetSharesGroupMembership(oShouter)
                    &&  GetFactionEqual(oShouter)
                    &&  !GetLocalInt(OBJECT_SELF, "AI_MODE_FLEEING")
                   )
                {
                    SendMessageToPC(oDM,RED+"ALERT! "+PALEBLUE+GetName(oShouter)+DMBLUE+" shouts "+PALEBLUE+"FLEE!");
                    /*
                    ClearAllActions(TRUE);
                    ActionForceFollowObject(oShouter, 3.0);
                    SetLocalInt(OBJECT_SELF, "AI_MODE_FLEEING", TRUE);
                    DelayCommand(18.0, DeleteLocalInt(OBJECT_SELF, "AI_MODE_FLEEING"));
                    */
                }
            }
        }
        // ALARM SHOUT HEARD ---------------------
        else if(    nMatch==12
                &&  GetIsShoutHeard(oShouter)
               )
        {
            SendMessageToPC(oDM,RED+"ALERT! "+PALEBLUE+GetName(oShouter)+DMBLUE+" shouts "+PALEBLUE+"ALARM!");
            // is the NPC already in a state of alert?
            if( GetLocalInt(OBJECT_SELF, "AI_ALERTED"))
            {
                // what to do?
                // determine if this new alarm takes precedence?
                // ignore for now unless we introduce more functionality
            }
            // not in a state of alarm
            else
            {
                // gather pointer to the ALARM_SOURCE
                // the ALARM_SOURCE is the object which holds all data for the alarm
                object oAlarm  = GetLocalObject(oShouter, "ALARM_SOURCE");
                if(oAlarm==OBJECT_INVALID)
                       oAlarm  = oShouter;
                SetLocalObject(OBJECT_SELF, "ALARM_SOURCE", oAlarm);

                // signal EVENT_ALERTED
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_ALERTED));
            }
        }

        // Actually respond to the shout
        //RespondToShout(oShouter, nMatch, oIntruder);
    }

    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}
