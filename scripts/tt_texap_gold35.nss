int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetGold(oPC) < 35) return FALSE;

return TRUE;
}
