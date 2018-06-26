int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetItemPossessedBy(oPC, "tt_greengem002") == OBJECT_INVALID) return FALSE;

return TRUE;
}

