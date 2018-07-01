//::///////////////////////////////////////////////
//:: ifam_splfocus_ck
//:://////////////////////////////////////////////
/*
    The Magus' Innocuous Familiars Include

    Checks to see if the familiar has a spellfocus

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 23)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_spells"

int StartingConditional()
{
    SetCustomToken(11010, "");
    int nCount;
    object oItem    = GetFirstItemInInventory();
    while(oItem!=OBJECT_INVALID)
    {
        if(GetLocalInt(oItem,SPELLFOCUS_TYPE))
            ++nCount;

        oItem       = GetNextItemInInventory();
    }

    if(!nCount)
        return FALSE;
    else if(nCount==1)
    {
        SetCustomToken(11010, "Retrieve a Spell Focus from your familiar.");
        return TRUE;
    }
    else
    {
        SetCustomToken(11010, "Retrieve all Spell Focuses from your familiar.");
        return TRUE;
    }
}
