/*
    Merricksdad's Gem Container Onspawn Script

    This script creates an invisible container linked with this creature's
    display item.
*/

void main()
{
    //get my location
    location myLocation = GetLocation(OBJECT_SELF);
    object myArea = GetAreaFromLocation(myLocation);
    vector myPosition = GetPositionFromLocation(myLocation);
    float myFacing = GetFacingFromLocation(myLocation);

    //ready the child position in relation to the parent
    float childOffsetZ = GetLocalFloat(OBJECT_SELF, "md_gemchild_z");
    if (childOffsetZ!=0.0f) {
        myPosition.z += childOffsetZ;
    } else {
        myPosition.z += 1.0f;
    }

    location boxLocation = Location(myArea, myPosition, myFacing);

    //create an invisible container at my location
    object myChild = CreateObject(OBJECT_TYPE_PLACEABLE,"md_gemslot01",boxLocation,FALSE,"");

    //remind the child I am its parent
    if (GetIsObjectValid(myChild)){
        SetLocalObject(myChild, "md_gemparent", OBJECT_SELF);

        //remember my child object
        SetLocalObject(OBJECT_SELF, "md_gemchild", myChild);

        //place any item equipped in my slot into my container child
        object myItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, OBJECT_SELF);
        if (GetIsObjectValid(myItem)){
            object childItem = CopyItem(myItem, myChild, TRUE);
        }

    }
}
