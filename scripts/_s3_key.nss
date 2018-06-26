//::///////////////////////////////////////////////
//:: _s3_key
//:://////////////////////////////////////////////
/*
    USE: player activates a key using the "Key, use" property

    Door/Placeable:
    LocalVar: "KEY" string - identifies the tag of a second key which unlocks the door/placeable

*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 jan 8)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_util"
#include "_inc_color"

void main()
{
    object oPC      = OBJECT_SELF;
    object oTarget  = GetSpellTargetObject();
    //int nTargetType = GetObjectType(oTarget);
    object oKey     = GetSpellCastItem();
    if(!GetIsObjectValid(oKey))  // when this spell is called from _door_openfail
                                 // we need this work around
    {
           oKey     = GetLocalObject(oPC,"SPELL995_KEY");
           DeleteLocalObject(oPC,"SPELL995_KEY");
           if(!GetIsObjectValid(oKey)){return;} // oKey is still not valid so exit.
    }
    string sLockTag = GetLockKeyTag(oTarget);
    string sLockVar = GetLocalString(oTarget,"KEY");// local var on door or placeable
    string sKeyTag  = GetTag(oKey);
    int bSucceed    = FALSE;


    if(sLockTag=="" && sLockVar=="")
    {
        // the door could be a trap door in top of a targeted ladder or rope etc - see aa_ladder_use
        object oDoor    = GetObjectByTag(
                                    GetLocalString(
                                        GetWaypointByTag( GetLocalString(oTarget,"MOVE_DESTINATION") )
                                        , "DOOR"
                                    )
                                );
        if(oDoor==OBJECT_INVALID)
        {
            WriteTimestampedLogEntry("ERR: '_s3_key' Lock: in Area("+GetName(GetArea(oTarget))+") Tagged("+GetTag(oTarget)+") lacks KEY string");
        }
        else
        {
            // there is a door connected to the placeable
            sLockTag = GetLockKeyTag(oDoor);
            sLockVar = GetLocalString(oDoor,"KEY");
            oTarget  = oDoor;
        }
    }
    if(sKeyTag=="key_master" || sLockTag==sKeyTag || sLockVar==sKeyTag)
    {
        bSucceed = TRUE;
    }

    if(bSucceed)
    {
        SetLocalInt(oKey,GetTag(oTarget)+sLockTag+sLockVar,TRUE);
        // Success
        if(GetLocked(oTarget))
        {
            SetLocked(oTarget,FALSE);
            AssignCommand(oPC, PlaySound("gui_picklockopen"));
            FloatingTextStringOnCreature(GetName(oPC)+" unlocks the "+GetName(oTarget)+".", oPC);
        }
        else if(GetIsOpen(oTarget))
        {
            FloatingTextStringOnCreature(GetName(oPC)+" fumbles with a key at the "+GetName(oTarget)+".", oPC);
            SendMessageToPC(oPC,PINK+"Close the "+YELLOW+GetName(oTarget)+PINK+" first.");
        }
        else
        {
            SetLocked(oTarget,TRUE);
            AssignCommand(oPC, PlaySound("gui_picklockfail"));
            FloatingTextStringOnCreature(GetName(oPC)+" locks the "+GetName(oTarget)+".", oPC);
        }
    }
    else
    {
        //SendMessageToPC
        FloatingTextStringOnCreature(GetName(oPC)+" fumbles with a key at the "+GetName(oTarget)+".", oPC);
    }
}
