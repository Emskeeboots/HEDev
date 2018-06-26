void main()
{

object oTarget;
object oSpawn;
location lTarget;

oTarget = GetWaypointByTag("WP_crypt_trapdoor");

lTarget = GetLocation(oTarget);

oSpawn = CreateObject(OBJECT_TYPE_PLACEABLE, "tt_wi_trapdoor", lTarget);

}






