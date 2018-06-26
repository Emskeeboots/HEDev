int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetGold(oPC) < 200) return FALSE;

return TRUE;
}
