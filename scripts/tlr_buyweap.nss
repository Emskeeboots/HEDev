//::///////////////////////////////////////////////
//:: Tailor - Buy Weapon
//:: tlr_buyweap.nss
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Stacy L. Ropella
//:: from Mandragon's mil_tailor
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, OBJECT_SELF);

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
