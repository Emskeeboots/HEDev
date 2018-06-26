//::///////////////////////////////////////////////
//:: Name Item Create
//:: FileName wyld_itemcreate
//:://////////////////////////////////////////////
/*
   This script runs after removing certain store bought items
   from stores to re-create the item with its variables intact.
   It requires a placeable with inventory somewhere in the module
   with the tag wyld_store_host.
*/
//:://////////////////////////////////////////////
//:: Created By: Wyldhunt
//:: Created On: 01/01/2012
//:://////////////////////////////////////////////


void ReplaceInfiniteItem(object oPC, string sTemplate, int nStack)
{
    if (sTemplate != "")
    {
        //object oNewItem = CreateItemOnObject(sTemplate, oPC);
        object oHost    = GetObjectByTag("wyld_store_host");
        object oNewItem = CreateItemOnObject(sTemplate, oHost);
        SetItemStackSize(oNewItem, nStack);
        AssignCommand(oHost, ClearAllActions());
        AssignCommand(oHost, ActionGiveItem(oNewItem, oPC));
        SetIdentified(oNewItem, TRUE);
    }
}

void CheckInfiniteItems(object oStore)
{
    object oItem = GetFirstItemInInventory(oStore);
    string sTemplate;
    string sTag;
    while (GetIsObjectValid(oItem))
    {
        if (GetInfiniteFlag(oItem))
        {
            sTemplate = GetResRef(oItem);
            sTag = GetTag(oItem);
            SetLocalInt(oStore, sTemplate+"Infinite", TRUE);
            SetLocalString(oStore, sTemplate+"Tag", sTag);
        }
        oItem = GetNextItemInInventory(oStore);
    }
    SetLocalInt(oStore, "InfiniteItemCheck", TRUE);
}

void main()
{
    //By default, infinite store-bought items have all of their variables erased.
    //We need to delete the empty infinite item and create a new one from the palette to
    //ensure that any required variables exist.
    //object oItem = GetModuleItemAcquired();
    //object oAcquiredBy = OBJECT_SELF;
    object oAcquiredFrom = GetLocalObject(OBJECT_SELF, "BaseStore");
    string sTemplate = GetLocalString(OBJECT_SELF, "ItemAcquired");
    int nStack = GetLocalInt(OBJECT_SELF, "ItemStack");
    if (GetObjectType(oAcquiredFrom) == OBJECT_TYPE_STORE)
    {
        // Player has purchased an item from a store.
        if (!GetLocalInt(oAcquiredFrom, "InfiniteItemCheck"))
        {

            CheckInfiniteItems(oAcquiredFrom);
        }
        else
        {
            DelayCommand(0.1, ReplaceInfiniteItem(OBJECT_SELF, sTemplate, nStack));
        }
    }
}
