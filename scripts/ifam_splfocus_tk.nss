//::///////////////////////////////////////////////
//:: ifam_splfocus_tk
//:://////////////////////////////////////////////
/*
    The Magus' Innocuous Familiars Include

    Takes all spellfocuses from the familiar

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 23)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_spells"


void main()
{
    object oMaster  = GetPCSpeaker();

    object oItem    = GetFirstItemInInventory();
    while(oItem!=OBJECT_INVALID)
    {
        if(GetLocalInt(oItem,SPELLFOCUS_TYPE))
        {
            object oCopy   = CopyItem(oItem, oMaster, TRUE);
            DestroyObject(oItem, 0.1);
        }

        oItem       = GetNextItemInInventory();
    }
}
