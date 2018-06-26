//::///////////////////////////////////////////////
//:: _plc_attacked
//:://////////////////////////////////////////////
/*
    Use: onAttacked event of a placeable (or door)

    Purpose: only certain tools or weapons can be used to dismantle or hack up

Local Int
    - VULNERABLE_SLASHING  if true, damage to object requires a slashing weapon (which includes axes and knives)
    - VULNERABLE_AXE       if true, damage to object requires an axe-like weapon
    - VULNERABLE_HAMMER    if true, damage to object requires a hammer-like weapon
    - VULNERABLE_KNIFE     if true, damage to object requires a knife-like weapon
    - VULNERABLE_FIRE      if true, object is damaged by weapon if PC wields fire (regardless of weapon wielded)
    - VULNERABLE_MAGIC     if true, magic is required to damage the door (weapons won't work)

*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2012 mar 7)
//:: Modified: The Magus (2012 may 5) added a silent shout when bashed
//:://////////////////////////////////////////////

#include "_inc_constants"
#include "_inc_util"

void main()
{
    object oAttacker= GetLastAttacker();
    if(!GetIsObjectValid(oAttacker))
        return;
    int bAxe        = GetLocalInt(OBJECT_SELF, "VULNERABLE_AXE");
    int bHammer     = GetLocalInt(OBJECT_SELF, "VULNERABLE_HAMMER");
    int bKnife      = GetLocalInt(OBJECT_SELF, "VULNERABLE_KNIFE");
    int bMagic      = GetLocalInt(OBJECT_SELF, "VULNERABLE_MAGIC");
    int bSlash      = GetLocalInt(OBJECT_SELF, "VULNERABLE_SLASHING");
    int bFire       = GetLocalInt(OBJECT_SELF, "VULNERABLE_FIRE");

    // Alert "owner" faction - requires that "owner" hears this and is set up to respond
    SpeakString(SHOUT_PLACEABLE_ATTACKED, TALKVOLUME_SILENT_SHOUT);
    SetLocalObject(OBJECT_SELF,SHOUT_PLACEABLE_ATTACKED,oAttacker);

    if( !bAxe && !bHammer && !bMagic && !bSlash && !bFire && !bKnife)
        return;

    int bNeedsAxe, bNeedsHammer, bNeedsSlash, bNeedsKnife, bHasFire;

    string sResponse;

    if( bFire )
    {
        if(GetIsWieldingFlame(oAttacker))
            bHasFire = TRUE;
    }

    if( bSlash )
    {
        if(!GetIsWieldingSlashingWeapon(oAttacker)&&!GetIsWieldingKnife(oAttacker))
        {
            bNeedsSlash = TRUE;
            sResponse   = PINK+"You need a "+YELLOW+"slashing weapon";
        }
    }
    else if( bAxe )
    {
        if(!GetIsWieldingAxe(oAttacker))
        {
            bNeedsAxe   = TRUE;
            sResponse   = PINK+"You need an "+YELLOW+"axe";
        }
    }

    if( bHammer )
    {
        if(!GetIsWieldingHammer(oAttacker))
        {
            bNeedsHammer    = TRUE;
            if(sResponse=="")
                sResponse   = PINK+"You need a "+YELLOW+"hammer";
            else
                sResponse   +=PINK+" or a "+YELLOW+"hammer";
        }
    }

    if( bMagic )
    {
        sResponse   =YELLOW+GetName(OBJECT_SELF)+PINK+" appears impervious to your weapon.";
        SetPlotFlag(OBJECT_SELF, TRUE);
        FloatingTextStringOnCreature(sResponse, oAttacker, FALSE);
        // clear the plot flag so the next attacker won't get "weapon not effective"
        DelayCommand(1.0, SetPlotFlag(OBJECT_SELF, FALSE));
    }
    else if(    ( bNeedsHammer && (bNeedsAxe || bNeedsSlash || (!bAxe && !bSlash)) )
            ||  ( !bHammer && (bNeedsAxe || bNeedsSlash) )
           )
    {
        sResponse   +=PINK+" to damage the "+YELLOW+GetName(OBJECT_SELF)+PINK+".";

        // if the door is flamable, flamable weapons should enable bashing
        if( bFire )
        {
            if(!bHasFire)
            {
                SetPlotFlag(OBJECT_SELF, TRUE);
                // clear the plot flag so the next attacker won't get "weapon not effective"
                DelayCommand(1.0, SetPlotFlag(OBJECT_SELF, FALSE));
            }
            else
                sResponse += " But as you've discovered, the "+YELLOW+GetName(OBJECT_SELF)+PINK+" also "+YELLOW+"burns"+PINK+".";
        }
        else
        {
            SetPlotFlag(OBJECT_SELF, TRUE);
            DelayCommand(1.0, SetPlotFlag(OBJECT_SELF, FALSE));
        }
        FloatingTextStringOnCreature(sResponse, oAttacker, FALSE);
    }

    if(bFire && bHasFire)
    {
        // This would be a good place to ignite oil thrown upon it
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_S), OBJECT_SELF);
    }

    // Some placeables spawn monsters. Attacking them will cause the spawn. see v2_plcspawn
    if(GetLocalString(OBJECT_SELF, "SPAWN")!="" && !GetLocalInt(OBJECT_SELF, "SPAWNED"))
    {
        SetLocalInt(OBJECT_SELF, "SPAWNED", TRUE);
        SetLocalObject(OBJECT_SELF, "DISTURBER", oAttacker);
        ExecuteScript("_plcspawn_ent", OBJECT_SELF);
    }
}
