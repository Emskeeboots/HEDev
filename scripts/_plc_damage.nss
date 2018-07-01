//::///////////////////////////////////////////////
//:: _plc_damage
//:://////////////////////////////////////////////
/*
    Use: onDamaged event of a placeable (or door)

    Purpose: only certain tools or weapons can be used to dismantle or hack up

Local Int
    - VULNERABLE_SLASHING  if true, item requires slashing weapons to damage(which includes axes and knives)
    - VULNERABLE_AXE       if true, item requires axes to damage
    - VULNERABLE_HAMMER    if true item requires hammers to damage
    - VULNERABLE_FIRE      if true item requires fire to damage

*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2012 apr 14)
//::
//:://////////////////////////////////////////////

#include "_inc_color"
#include "_inc_util"

void main()
{
    object oDamager = GetLastDamager();
    if(!GetIsObjectValid(oDamager))
        return;
    /*
    int bAxe        = GetLocalInt(OBJECT_SELF, "VULNERABLE_AXE");
    int bHammer     = GetLocalInt(OBJECT_SELF, "VULNERABLE_HAMMER");
    int bMagic      = GetLocalInt(OBJECT_SELF, "VULNERABLE_MAGIC");
    int bSlash      = GetLocalInt(OBJECT_SELF, "VULNERABLE_SLASHING");
    int bFire       = GetLocalInt(OBJECT_SELF, "VULNERABLE_FIRE");


    int bNeedsAxe, bNeedsHammer, bNeedsSlash, bHasFire;

    int nTotal      = GetTotalDamageDealt();

    int nPierce     = GetDamageDealtByType(DAMAGE_TYPE_PIERCING);
    int nBludge     = GetDamageDealtByType(DAMAGE_TYPE_BLUDGEONING);
    int nSlashing   = GetDamageDealtByType(DAMAGE_TYPE_SLASHING);
    int nMagic      = GetDamageDealtByType(DAMAGE_TYPE_MAGICAL);
    int nFire       = GetDamageDealtByType(DAMAGE_TYPE_FIRE);
    int nElec       = GetDamageDealtByType(DAMAGE_TYPE_ELECTRICAL);
    int nAcid       = GetDamageDealtByType(DAMAGE_TYPE_ACID);
    int nCold       = GetDamageDealtByType(DAMAGE_TYPE_COLD);

    if(bFire)
    {

    }
    */

        // Some placeables spawn monsters. Damage to them will cause the spawn. see v2_plcspawn
    if(GetLocalString(OBJECT_SELF, "SPAWN")!="" && !GetLocalInt(OBJECT_SELF, "SPAWNED"))
    {
        SetLocalInt(OBJECT_SELF, "SPAWNED", TRUE);
        SetLocalObject(OBJECT_SELF, "DISTURBER", oDamager);
        ExecuteScript("_plcspawn_ent", OBJECT_SELF);
    }

}
