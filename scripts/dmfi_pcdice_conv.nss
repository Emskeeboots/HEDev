void main()
{
    object oPC = GetPCSpeaker();
    DeleteLocalInt(oPC, "Tens");
    SetLocalInt(oPC, "dmfi_univ_offset", 8);

    if (GetLocalInt(oPC, "dmfi_dicebag")==0)
        SetCustomToken(20681, "Private");
    else  if (GetLocalInt(oPC, "dmfi_dicebag")==1)
        SetCustomToken(20681, "Global");
    else if (GetLocalInt(oPC, "dmfi_dicebag")==2)
        SetCustomToken(20681, "Local");
    else if (GetLocalInt(oPC, "dmfi_dicebag")==3)
        SetCustomToken(20681, "DM Only");
}
