int StartingConditional()
{
    int nResult;
    object oPC = GetPCSpeaker();
    int iPrice = GetLocalInt(OBJECT_SELF, "PRICE");
    int iGold = GetGold(oPC);

    if(iGold >= iPrice)
        {
         nResult = 1;
        }
    else
        {
         nResult = 0;
        }
    return nResult;
}
