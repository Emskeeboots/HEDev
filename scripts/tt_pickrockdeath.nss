void main()
{

object oPC = GetLastKiller();
//object oBlocker;

while (GetIsObjectValid(GetMaster(oPC)))
   {
   oPC=GetMaster(oPC);
   }

if (!GetIsPC(oPC)) return;

int nNth = 0;
object oTarget = GetObjectByTag("tt_cavebould", nNth);

while (GetIsObjectValid(oTarget))
{
//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

   int nInt;
   nInt = GetObjectType(oTarget);

   if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM),     oTarget);
   else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), GetLocation(oTarget));

   DestroyObject(oTarget, 2.0);
   nNth++;
   oTarget = GetObjectByTag("tt_cavebould", nNth);
  }

     SendMessageToPC(oPC, "You manage to clear a path through the boulders!");
 //    DestroyObject(oBlocker, 2.0);

}








