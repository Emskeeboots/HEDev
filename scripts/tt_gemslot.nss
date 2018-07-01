void main()
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


}


/*
// ** OnDisturbed handle of the container.//
// Note: You'll need to set two strings on the container (right click >
// variables): sItemTag and sDoorTag. This is to make the script generic
// enough that you can use it again in a similar situation. If you're not
// sure how to do this, see below:
//
// Example://
// Name: Type: Value:
// sItemTag string TAG_OF_MY_KEY_ITEMvoid main(){
// Check that an item has been added to the inventory,
// rather than removed or stolen:
void main()
{
if( GetInventoryDisturbType() != INVENTORY_DISTURB_TYPE_ADDED)

    {
        return;

    }

    object oItem = GetInventoryDisturbItem();

    // Check that its tag corresponds with the required key item:

if( GetTag( oItem) != GetLocalString( OBJECT_SELF, "sItemTag"))

    { return;

    // If these conditions are met...

    } else

        { object oDoor = GetObjectByTag( GetLocalString( OBJECT_SELF, "sDoorTag"));

        // ... then unlock and open the appropriate door and // destroy the key item:

            ActionDoCommand( DestroyObject(oItem));
            ActionDoCommand( SetLocked( oDoor, FALSE));
            ActionOpenDoor( oDoor);
         }

    }




void main()
{

object oPC = GetLastClosedBy();
if (!GetIsPC(oPC)) return;

object oTarget;
object oDoor = GetObjectByTag( GetLocalString( OBJECT_SELF, "sDoorTag"));

SetLocked(oTarget, FALSE);
AssignCommand(oTarget, ActionOpenDoor(oDoor));

}





void main()
{

object oPC = GetLastClosedBy();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = GetObjectByTag("tt_gemdoor");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}
*/
