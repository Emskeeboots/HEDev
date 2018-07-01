//::///////////////////////////////////////////////
//:: _door_unlock
//:://////////////////////////////////////////////
/*
    intended for use in a door's onUnLock event
*/
//:://////////////////////////////////////////////
//:: Created: henesua (2016 jan 5)
//:://////////////////////////////////////////////

#include "_inc_util"
#include "_inc_xp"

void main()
{
    object oActor   = GetLastUnlocked();
    if(!GetIsPC(oActor)||GetIsDM(oActor))
        return;
    // initialize vars
    string sLockTag = GetLockKeyTag(OBJECT_SELF);
    string sLockVar = GetLocalString(OBJECT_SELF,"KEY");
    string sTag     = GetTag(OBJECT_SELF);

    // Set an Integer that the door is unlocked
    SetLocalInt(OBJECT_SELF, "autolock", 1);

    // look for a possible key
    object oKey     = GetItemPossessedBy(oActor, sLockTag);
    if(!GetIsObjectValid(oKey))
        oKey = GetItemPossessedBy(oActor, sLockVar);

    // does the person have the key in their inventory?
    int pc_has_key  = FALSE;
    if(GetIsObjectValid(oKey))
        pc_has_key  = TRUE;

    // assume that they have not used it
    int pc_used_key = FALSE;

    // has the key in possession

    // is the key unidentified?
    if(     pc_has_key
        &&  !GetIdentified(oKey)
      )
    {
        DeleteLocalInt(oKey, sTag+sLockTag+sLockVar);
        SetLocalInt(oActor, "KEY_UNIDENTIFIED", GetTimeCumulative(TIME_SECONDS));
    }
    else if(                // OLDER CODE
                            // this uses  _s3_key   which is from the "Key, use" spell
                            // has the key in possession been successfully used on this lock?
                            //GetLocalInt(oKey,sTag+sLockTag+sLockVar)

             // NEWER CODE
             // Instead of relying on the key's use ability (Key, use),
             // we check for an identified key
                pc_has_key
           )
    {
        pc_used_key = TRUE;
    }

/*
    // if the PC has hands, and DID NOT use the key
    // reward them for picking the lock
    if( CreatureGetHasHands(oActor) && !pc_used_key )
    {
        // PC picked lock
        XPRewardPickLock(oActor, OBJECT_SELF);
    }
*/
}
