//::///////////////////////////////////////////////
//:: wyld_storeopen
//:://////////////////////////////////////////////
/*
    executes in an store open event
    destroys all items without the infinite flag
*/
//:://////////////////////////////////////////////
//:: Created:  Wyldhunt - bioware social network
//:: Modified: The Magus (2012 oct 29) - added check to destroy non-infinite items in a starting store
//:://////////////////////////////////////////////


void main()
{
    if (!GetLocalInt(OBJECT_SELF, "InfiniteItemCheck"))
    {
        object oItem = GetFirstItemInInventory(OBJECT_SELF);
        string sTemplate;
        string sTag;
        while (GetIsObjectValid(oItem))
        {

            if (GetInfiniteFlag(oItem))
            {
                sTemplate = GetResRef(oItem);
                sTag = GetTag(oItem);
                SetLocalInt(OBJECT_SELF, sTemplate+"Infinite", TRUE);
                SetLocalString(OBJECT_SELF, sTemplate+"Tag", sTag);
            }

            oItem = GetNextItemInInventory(OBJECT_SELF);
        }
        SetLocalInt(OBJECT_SELF, "InfiniteItemCheck", TRUE);
    }
    // Magus - if this is a starting store, clear it of Non-infinite items
    else if(GetLocalInt(OBJECT_SELF, "STORE_START"))
    {
        object oItem = GetFirstItemInInventory(OBJECT_SELF);

        while (GetIsObjectValid(oItem))
        {
            if (!GetInfiniteFlag(oItem))
                DestroyObject(oItem);

            oItem = GetNextItemInInventory(OBJECT_SELF);
        }
    }

}
