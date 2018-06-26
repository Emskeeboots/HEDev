//::///////////////////////////////////////////////
//:: Tailor - Buy Outfit
//:: tlr_buyoutfit.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: March 8, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();
    object oItem;

    if(GetLocalInt(OBJECT_SELF, "IsCloakModel") == 1)
    {
        oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, OBJECT_SELF);
    }
    else
    {
        oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
    }

    //-- int iCost = GetGoldPieceValue(oItem) * 2;
    int iCost = GetLocalInt(OBJECT_SELF, "CURRENTPRICE");
/*
    if (GetGold(oPC) < iCost) {
        SendMessageToPC(oPC, "This outfit costs" + IntToString(iCost) + " gold!");
        return;
    }
*/

    TakeGoldFromCreature(iCost, oPC, TRUE);

    object oPCCopy = CopyItem(oItem, oPC, TRUE);

    string sName = GetLocalString(OBJECT_SELF, "CUSTOMNAME");
    if(sName != "")
    {  SetName(oPCCopy, sName);  }
}
