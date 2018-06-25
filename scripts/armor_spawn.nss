void main()
{
    SetLocalInt(OBJECT_SELF, "current_armor", 0);
    SetLocalInt(OBJECT_SELF, "current_helmet", 0);
    SetLocalInt(OBJECT_SELF, "current_shield", 0);
    SetLocalInt(OBJECT_SELF, "current_weapon", 0);


    // Yes, I'm sure there are better ways to do this, but for now
    // I'll just copy the items from a store and put it into the
    // armor stand's inventory for later equipping

    object oStore = GetObjectByTag("ArmorStandStore");
    object oItem = GetFirstItemInInventory(oStore);
    while(oItem != OBJECT_INVALID)
    {
        CopyObject(oItem, GetLocation(OBJECT_SELF), OBJECT_SELF);
        oItem = GetNextItemInInventory(oStore);
    }
}
