//::///////////////////////////////////////////////
//:: _door_close
//:://////////////////////////////////////////////
/*
    intended for use in a doors onClose event
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 may 5)
//:: Modified:
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
                        break;
                    }
                    oDest   = GetObjectByTag(sDestDoor,++nNth);
                }
            }
        }
    }
    // placeable
    else
    {
        if(GetLocalInt(OBJECT_SELF,"DESTROY_WHEN_EMPTY"))
        {
            if(GetFirstItemInInventory()==OBJECT_INVALID)
                DestroyObject(OBJECT_SELF, 0.1);
        }
    }

     //Autlock door
        object oDoor    = OBJECT_SELF;
        if (GetLocalInt(OBJECT_SELF, "autolock")== 1)
          {
           DelayCommand(1200.0, SetLocked(OBJECT_SELF, TRUE));
           SetLocked(oDoor, TRUE);
           SetLocalInt(OBJECT_SELF, "autolock", 0);
          }
}




