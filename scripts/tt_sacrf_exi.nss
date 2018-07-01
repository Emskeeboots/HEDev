void main()
{

object oNPC = GetExitingObject();

if ((GetRacialType(oNPC)==RACIAL_TYPE_UNDEAD))
   return;

int nInt;
nInt = GetLocalInt(oNPC, "int_sacrifice_tri");

nInt -= 1;

SetLocalInt(oNPC, "int_sacrifice_tri", nInt);

}




