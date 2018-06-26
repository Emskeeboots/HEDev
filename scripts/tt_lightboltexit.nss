/*void main()
{

object oPC = GetEnteringObject();

//if (!GetIsPC(oPC)) return;



if (GetTag(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC)) == "tt_scepter")
   return;

object oCaster;
oCaster = GetNearestObjectByTag("tt_magstone_001");

object oTarget;
oTarget = oPC;

if (GetLocalInt(oCaster, "Active")!= 1)
   return;

AssignCommand(oCaster, ActionCastSpellAtObject(SPELL_LIGHTNING_BOLT, oTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));

}


*/








//Put this script OnExit
void main()
{

object oPC = GetExitingObject();

//if (!GetIsPC(oPC)) return;

if (GetItemPossessedBy(oPC, "tt_scepter")== OBJECT_INVALID)
   return;

object oCaster;
oCaster = GetNearestObjectByTag("tt_magstone_001");

object oTarget;
oTarget = oPC;

if (GetLocalInt(oCaster, "Active")!= 1)
   return;

AssignCommand(oCaster, ActionCastSpellAtObject(SPELL_LIGHTNING_BOLT, oTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));

}
