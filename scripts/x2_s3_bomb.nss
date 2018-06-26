//::///////////////////////////////////////////////
//:: Improved Grenade weapons script
//:: x2_s3_bomb
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    More powerful versions of the standard grenade weapons.
    They do 10d6 points of damage and create a persistant AOE effect for 5 rounds
        or
    Cast spells at the location of impact
        a custom script            : local string GRENADE_SCRIPT is a script which execute on impact
        OR a spell from spells.2da : local int GRENADE_SPELLID of 72 would cast greater spell breach

        GRENADE_SPLASH
        GRENADE_LEVEL

*/
//:://////////////////////////////////////////////
//:: Created: Georg Zoeller 2003-08-18
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 17) Added Spell grenades

#include "x0_i0_spells"
void main()
{
    int nSpell = GetSpellId();

    if(nSpell == 994) // spell grenade
    {
        object oPC      = GetItemActivator();
        object oGrenade = GetItemActivated();
        if(!GetIsObjectValid(oPC)||!GetIsObjectValid(oGrenade))
            return;
        object oTarget  = GetItemActivatedTarget();
        location lTarget= GetItemActivatedTargetLocation();

        int bSplash     = GetLocalInt(oGrenade,"GRENADE_SPLASH");
        string sScript  = GetLocalString(oGrenade,"GRENADE_SCRIPT");// nss script takes priority
        int nSpell; // index from spells.2da runs if sScript==""
        if(sScript=="")
            nSpell      = GetLocalInt(oGrenade,"GRENADE_SPELLID");
        int bHit;
        float fDist     = GetDistanceBetweenLocations(GetLocation(oPC),lTarget);
        float fPrefDist = StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oPC)))*2.0;

        if(GetIsObjectValid(oTarget))
        {
            int nAttack;
            if(fDist<=fPrefDist)
                nAttack     = TouchAttackMelee(oTarget);
            else
                nAttack     = TouchAttackRanged(oTarget);
            if(nAttack)
            {
                // direct hit
                bHit    = TRUE;
                if(sScript!="")
                    ExecuteScript(sScript, oTarget);
                else
                    AssignCommand(oGrenade,
                            ActionCastSpellAtObject(nSpell, oTarget, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)
                        );
            }
        }

        if(!bHit)
        {
            if(sScript=="")
            {
                oTarget = GetAreaFromLocation(lTarget);
                SetLocalInt(oTarget, "GRENADE_MISS", TRUE);
                SetLocalLocation(oTarget, "GRENADE_LOCATION", lTarget);
                ExecuteScript(sScript, oTarget);
            }
            else
            {
                AssignCommand(oGrenade,
                        ActionCastSpellAtLocation(nSpell, lTarget, METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)
                    );
            }
        }

        if(bSplash)
        {
            // potential splash
            int nIt;
            vector vPos         = GetPositionFromLocation(lTarget);
            object oBystander   = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lTarget, TRUE, OBJECT_TYPE_CREATURE, vPos);
            while(GetIsObjectValid(oBystander))
            {
                if(oBystander!=oTarget)
                {
                    SetLocalInt(oBystander,"GRENADE_SPLASH", ++nIt);
                    if(nSpell)
                    {
                        AssignCommand(oGrenade,
                                ActionCastSpellAtObject(nSpell, oBystander, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)
                            );
                    }
                    else
                    {
                        DelayCommand(0.1, ExecuteScript(sScript, oBystander) );
                    }
                }
                oBystander  = GetNextObjectInShape(SHAPE_SPHERE, 5.0, lTarget, TRUE, OBJECT_TYPE_CREATURE, vPos);
            }
        }
    }
    else if (nSpell == 745)  // acid bomb
    {
         DoGrenade(d6(10),1, VFX_IMP_ACID_L, VFX_FNF_LOS_NORMAL_30,DAMAGE_TYPE_ACID,RADIUS_SIZE_HUGE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
         ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(AOE_PER_FOGACID), GetSpellTargetLocation(), RoundsToSeconds(5));
    }
    else if (nSpell == 744) // fire bomb
    {
         DoGrenade(d6(10),1, VFX_IMP_FLAME_M, VFX_FNF_FIREBALL,DAMAGE_TYPE_FIRE,RADIUS_SIZE_HUGE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
         ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(AOE_PER_FOGFIRE), GetSpellTargetLocation(), RoundsToSeconds(5));
    }




}
