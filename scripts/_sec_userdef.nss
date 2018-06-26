//::///////////////////////////////////////////////
//:: _sec_userdef
//:://////////////////////////////////////////////
/*
    Use: OnUserDef event of a trigger

Local String
    SECRET_DOOR  resref of placeable to use for secret door
    SECRET_DOOR_PAIRED tag of detect trigger at destination (if supplied, both doors will be found when one is used)

Local Int
    SECRET          a flag indicating that this object is SECRET
    SECRET_SKILL    index of the skill used in detection
    SECRET_SKILL_DC challenge rating for detection

Local Float
    SECRET_RESET    seconds until the item resets. If 1.0 or less, no reset.

Secret Doors can be locked
    SECRET_LOCK              - int  locked/unlocked
    SECRET_LOCK_DC           - difficulty to pick lock
    SECRET_LOCK_KEY          - string  key tag
    SECRET_LOCK_KEY_REQUIRED - int yes/no
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2014 mar 19)
//:: Modified:
//:://////////////////////////////////////////////


#include "x0_i0_secret"

void main()
{
    int nUser       = GetUserDefinedEventNumber();

    if(nUser==EVENT_SECRET_DETECTED)
    {
        string sDoor    = GetLocalString(OBJECT_SELF, "SECRET_DOOR");
        if(sDoor==""){sDoor = "door_sec_stone";}
        RevealSecretItem(sDoor);

        InitializeSecretDoor();
    }
    else if(nUser==EVENT_SECRET_REVEALED)
    {
        float fReset    = GetLocalFloat(OBJECT_SELF,"SECRET_RESET");
        if(fReset>1.0)
            DelayCommand(fReset, ResetSecretItem());
    }

}
