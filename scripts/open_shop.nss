//: DarkSorcerer's Scripts - Merchant OnOpen Event (06/15/2018)
// =============================================================================
/*
    Uses a temporary chest system to "Backup" the store's inventory
    Usage: Merchant's OnOpen event
     - Place in the area a placeable with the tag: "storage_" + the tag of
       the shop(merchant object)
*/
// =============================================================================
                                /* OPEN ~ SHOP */

void main()
{
    object oPC = GetLastUsedBy();
    object oArea = GetArea(OBJECT_SELF);
    object oChest = GetObjectByTag("storage_" + GetTag(OBJECT_SELF));
    if (GetArea(oChest) != oArea)
    {
        SendMessageToPC(oPC, "Error::Storage Chest not found - please contact the admin with these details: \n" +
                             "Area: " + GetName(oArea) + "\n" +
                             "Store: " + GetTag(OBJECT_SELF));
        return;
    }

    // Copy all items to temp chest
    object oItem = GetFirstItemInInventory();
    while (GetIsObjectValid(oItem))
    {
        // Don't copy plot items (anti-cheat)
        if (GetPlotFlag(oItem)) DestroyObject(oItem);

        object oNewItem = CopyItem(oItem, oChest);
        if (GetInfiniteFlag(oItem))
        {
            SetInfiniteFlag(oNewItem, FALSE);
            SetName(oNewItem, GetName(oNewItem) + "(I)");
        }
        oItem = GetNextItemInInventory();
    }
}
