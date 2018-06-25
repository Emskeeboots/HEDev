//: DarkSorcerer's Scripts - Merchant OnClose Event (06/15/2018)
// =============================================================================
/*
    Resets the shop's inventory by clearing the current items (including any
    sold items from PCs); then copying over the original store set; lastly it
    clears the temp chest of its inventory.
*/
// destroys all items within oTarget's inventory
void ClearInventory(object oTarget);

// copies all items from oChest back into oSelf's inventory;
// then destroys oChest's inventory.
void TransferItems(object oSelf, object oChest);

// =============================================================================
                                /* CLEAN ~ SHOP */

void main()
{
    object oChest = GetObjectByTag("storage_" + GetTag(OBJECT_SELF));

    // Clear self inventory first
    ClearInventory(OBJECT_SELF);

    // copy back the original items
    DelayCommand(0.2, TransferItems(OBJECT_SELF, oChest));
}



//: Functions //////////////////////////////////////////////////////////////////
void ClearInventory(object oTarget)
{
    object oItem = GetFirstItemInInventory(oTarget);
    while (GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oTarget);
    }
}

void TransferItems(object oSelf, object oChest)
{
    if (!GetIsObjectValid(oSelf) || !GetIsObjectValid(oChest)) return;

    // transfer original items
    object oItem = GetFirstItemInInventory(oChest);
    while (GetIsObjectValid(oItem))
    {
        object oOriginal = CopyItem(oItem, oSelf);
        if (GetStringRight(GetName(oOriginal), 3) == "(I)")
        {
            SetName(oOriginal, "");
            SetInfiniteFlag(oOriginal, TRUE);
        }
        oItem = GetNextItemInInventory(oChest);
    }

    // clean out temp chest
    ClearInventory(oChest);
}
