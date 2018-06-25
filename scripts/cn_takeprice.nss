#include "nw_i0_tool"
void main()
{
    object oPC = GetPCSpeaker();
    int iPrice = GetLocalInt(OBJECT_SELF, "PRICE");

    TakeGold(iPrice, oPC, TRUE);
}
