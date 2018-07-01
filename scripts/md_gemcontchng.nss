/*
    Merricksdad's Gem Container Onclose Script

    This script activates when a linked container is closed, replacing
    the item held by the parent object.
*/

void main()
{



    //get the object that this container is linked with
    object myParent = GetLocalObject(OBJECT_SELF,"md_gemparent");

    //get the item equipped by the parent
    if (GetIsObjectValid(myParent))
        {
            object parentItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, myParent);

            //destroy the object because it is a clone we don't need
            if (GetIsObjectValid(parentItem))
                {
                DestroyObject(parentItem, 0.1f);
                }

            //determine if we have a new object to insert in the parent
            object myItem = GetFirstItemInInventory(OBJECT_SELF);

            //clone that item to my parent
            if (GetIsObjectValid(myItem))
                {
                    parentItem = CopyItem(myItem, myParent, TRUE);

                    //make the parent equip the item
                    if (GetIsObjectValid(parentItem))

                        {
                        AssignCommand(myParent, ActionEquipItem(parentItem,INVENTORY_SLOT_LEFTHAND));
                        }
                }
         }
     {

    object oItem = GetFirstItemInInventory(OBJECT_SELF);while(GetIsObjectValid(oItem))



        {

            if( GetTag( oItem) == GetLocalString( OBJECT_SELF, "sItemTag_1"))
                {

                object oDoor = GetObjectByTag( GetLocalString( OBJECT_SELF, "sDoorTag_1"));
                object oSelf;
                oSelf = GetArea(OBJECT_SELF);
                if(GetArea(oSelf) == GetArea(oDoor))
                    {
                    //DelayCommand(15.0, DestroyObject(oItem));
                    SetLocked( oDoor, FALSE);
                    AssignCommand(oDoor, PlayAnimation(ANIMATION_DOOR_OPEN1));
                    ActionSpeakString("You place the gem in the slot and the door opens.");
                    return;
                    }

                else
                    {
                    ActionSpeakString("You place the gem in the slot");
                    //oItem = GetNextItemInInventory(OBJECT_SELF);
                    return;
                    }
                }

            else if( GetTag( oItem) == GetLocalString( OBJECT_SELF, "sItemTag_2"))
                {
                object oDoor = GetObjectByTag( GetLocalString( OBJECT_SELF, "sDoorTag_2"));
                object oSelf;
                oSelf = GetArea(OBJECT_SELF);
                if(GetArea(oSelf) == GetArea(oDoor))
                    {
                    DelayCommand(20.0, DestroyObject(oItem));
                    DelayCommand(15.0, ActionSpeakString("The Crystal Skull starts to wither."));
                    SetLocked( oDoor, FALSE);
                    AssignCommand(oDoor, PlayAnimation(ANIMATION_DOOR_OPEN1));
                    //ActionOpenDoor( oDoor);
                    ActionSpeakString("You place the gem in the slot and the door opens.");
                    return;
                    }
                else
                    {
                    ActionSpeakString("You place the gem in the slot");
                    //oItem = GetNextItemInInventory(OBJECT_SELF);
                    return;
                    }
                }

            else
                {
                ActionSpeakString("You place the gem in the slot");
                oItem = GetNextItemInInventory(OBJECT_SELF);
                return;
                }
        }
  }


}






/*

{
 {
    object oItem = GetFirstItemInInventory(OBJECT_SELF);while(GetIsObjectValid(oItem))

        {

            if( GetTag( oItem) == GetLocalString( OBJECT_SELF, "sItemTag"))
                {
                object oDoor = GetObjectByTag( GetLocalString( OBJECT_SELF, "sDoorTag"));
                DestroyObject(oItem);
                SetLocked( oDoor, FALSE);
                AssignCommand(oDoor, PlayAnimation(ANIMATION_DOOR_OPEN1));
                //ActionOpenDoor( oDoor);
                ActionSpeakString("You place the gem and the door opens");
                return;

                }
           else
                {

                ActionSpeakString("Nothing Happens");
                oItem = GetNextItemInInventory(OBJECT_SELF);
                return;
                }
        }
  }



