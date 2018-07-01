int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetGold(oPC) < 250) return FALSE;

return TRUE;
}
