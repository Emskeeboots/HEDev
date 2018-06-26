//::///////////////////////////////////////////////
//:: _plc_mgck_user
//:://////////////////////////////////////////////
/*
    User D for magically created placeables
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 oct 18)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

// event from x2_inc_spellhook
//int X2_EVENT_CONCENTRATION_BROKEN = 12400;


void main()
{
    int nUser = GetUserDefinedEventNumber();

    if(nUser == X2_EVENT_CONCENTRATION_BROKEN)
    {
        string sDestroy = GetLocalString(OBJECT_SELF, "CONCENTRATION_SCRIPT");
        if(sDestroy!="")
            ExecuteScript(sDestroy,OBJECT_SELF);
        else
            DestroyObject(OBJECT_SELF, 1.0);
    }
/*
    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {

    }
    else if(nUser == EVENT_DIALOGUE) // ON DIALOGUE
    {

    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {

    }
    else if(nUser == EVENT_DAMAGED) // DAMAGED
    {

    }
    else if(nUser == 1007) // DEATH  - do not use for critical code, does not fire reliably all the time
    {

    }
    else if(nUser == EVENT_DISTURBED) // DISTURBED
    {

    }
*/
}
