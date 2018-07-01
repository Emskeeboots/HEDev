int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetGold(oPC) < 80) return FALSE;

return TRUE;
}
