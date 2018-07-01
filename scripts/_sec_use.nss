//::///////////////////////////////////////////////
//:: _sec_use
//:://////////////////////////////////////////////
/*
    Use: OnUse event of a placeable (secret door)

    Tag of destination waypoint: loc_<tag of detect trigger>


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2014 jan 30)
//:: Modified:
//:://////////////////////////////////////////////


#include "x0_i0_secret"

#include "_inc_util"

void main()
{
    object oUser = GetLastUsedBy();

    int bIncorp = CreatureGetIsIncorporeal(oUser);

    // Allow for traps and locks
    if(GetIsTrapped(OBJECT_SELF)){return;}

    if( GetLocked(OBJECT_SELF) && (!bIncorp||GetLockKeyRequired(OBJECT_SELF)) )
    {
        // See if we have the key and unlock if so
        string sKey = GetTrapKeyTag(OBJECT_SELF);
        object oKey = GetItemPossessedBy(oUser, sKey);
        if(sKey != "" && GetIsObjectValid(oKey))
        {
            SendMessageToPC(oUser, GetStringByStrRef(7945));
            SetLocked(OBJECT_SELF, FALSE);
        }
        else
        {
            // Print '*locked*' message and play sound
            DelayCommand(0.1, PlaySound("as_dr_locked2"));
            FloatingTextStringOnCreature("*"
                                         + GetStringByStrRef(8307)
                                         + "*",
                                         oUser);
            SendMessageToPC(oUser, GetStringByStrRef(8296));
            return;
        }
    }

    // is this a two way door?
    object oDestTrigger = OBJECT_INVALID;
    string sTagDest     = GetLocalString(GetLocalObject(OBJECT_SELF,sDetectTriggerVarname), "SECRET_DOOR_PAIRED");
    if(sTagDest!="")
    {
        oDestTrigger    = GetObjectByTag(sTagDest);
    }


    // Handle opening/closing
    if (!GetIsSecretItemOpen(OBJECT_SELF)&&!bIncorp)
    {
        // play animation of user opening it
        AssignCommand(oUser, ActionPlayAnimation(ANIMATION_LOOPING_GET_MID));
        DelayCommand(1.0, ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN));
        SetIsSecretItemOpen(OBJECT_SELF, TRUE);
    }
    else
    {
        // reveal and initialize destination door if necessary
        if(oDestTrigger!=OBJECT_INVALID)
        {
            SetLocalInt(oUser, sFoundPrefix + ObjectToString(oDestTrigger), TRUE);

            string sDoor    = GetLocalString(oDestTrigger, "SECRET_DOOR");
            if(sDoor==""){sDoor = "door_sec_stone";}
            RevealSecretItem(sDoor, oDestTrigger);

            InitializeSecretDoor(oDestTrigger);

            // door opens
            object oDestDoor    = GetLocalObject(oDestTrigger,sSecretItemVarname);
            AssignCommand(oDestDoor, ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN));
            SetIsSecretItemOpen(oDestDoor, TRUE);
        }

        // it's open -- go through
        UseSecretTransport(oUser);
    }
}
