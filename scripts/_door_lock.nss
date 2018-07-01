//::///////////////////////////////////////////////
//:: _door_lock
//:://////////////////////////////////////////////
/*
    intended for use in a doors onLock event
*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2012 may 5)
//:://////////////////////////////////////////////

void main()
{
    if(GetObjectType(OBJECT_SELF)==OBJECT_TYPE_DOOR)
    {
        object oDest = GetTransitionTarget(OBJECT_SELF);
        int bDestDoor= GetObjectType(oDest)==OBJECT_TYPE_DOOR;
        if(!bDestDoor)
        {
            string sDestDoor    = GetLocalString(OBJECT_SELF,"DOOR_PAIRED_TAG");
            if(sDestDoor!="")
            {
                int nNth;
                oDest   = GetObjectByTag(sDestDoor,nNth);
                while(GetIsObjectValid(oDest))
                {
                    bDestDoor= GetObjectType(oDest)==OBJECT_TYPE_DOOR;
                    if(bDestDoor)
                    {
                        AssignCommand(oDest, PlayAnimation(ANIMATION_DOOR_CLOSE));
                        SetLocked(oDest,TRUE);
                        break;
                    }
                    oDest   = GetObjectByTag(sDestDoor,++nNth);
                }
            }
        }
    }
}
