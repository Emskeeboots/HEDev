//::///////////////////////////////////////////////
//:: _sec_udef_natr
//:://////////////////////////////////////////////
/*
    Use: OnUserDef event of a natural resource placeable

Local String
    SECRET_PLACEABLE resref of a placeable
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
        object oDetector    = GetLocalObject(OBJECT_SELF, "SECRET_DETECTOR");

        if(!GetLocalInt(OBJECT_SELF,"HINT"+ObjectToString(oDetector)))
        {
            SetLocalInt(OBJECT_SELF,"HINT"+ObjectToString(oDetector),TRUE);
            // HINT TEXT
            SendMessageToPC(oDetector,
                            DMBLUE+"To investigate the "+GetName(OBJECT_SELF)+" further, "
                            +PALEBLUE+"*examine "+GetTag(OBJECT_SELF)+"*"
                            +DMBLUE+", which is accomplished by entering "
                            +PALEBLUE+"*examine "+GetTag(OBJECT_SELF)+"* into your chatbar."
                           );
        }
        DeleteLocalObject(OBJECT_SELF,"SECRET_DETECTOR"); // garbage collection

        string sRef = GetLocalString(OBJECT_SELF,"SECRET_PLACEABLE");
        if(sRef!="")
        {
            object oPLC  = CreateObject(OBJECT_TYPE_PLACEABLE,sRef,GetLocation(OBJECT_SELF),TRUE);
            DestroyObject(oPLC,3.0);
        }

    }
    else if(nUser==EVENT_SECRET_REVEALED)
    {

    }
}
