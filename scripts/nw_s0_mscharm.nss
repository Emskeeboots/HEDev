//::///////////////////////////////////////////////
//:: [Mass Charm]
//:: [NW_S0_MsCharm.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster attempts to charm a group of individuals
    who's HD can be no more than his level combined.
    The spell starts checking the area and those that
    fail a will save are charmed.  The affected persons
    are Charmed for 1 round per 2 caster levels.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
Patch 1.71, fix by Shadooow

- was doing charm effect even for players (replaced for daze in this case)
- HD pool check corrected (if found target with HD matching HD pool)
- HD pool decreased also in case of spell being resisted
- added scaling by difficulty into duration
- added delay into SR and saving throw's VFX
- extended duration corrected to calculate twice of normal duration as usual
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 Sept 9) added reputation system. adjust duration

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

//#include "v2_inc_util"
#include "_inc_util"
// Vendalus's Personal Reputation and Reaction System
//#include "_prr_main"

// MAIN ------------------------------------------------------------------------
void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    spellsDeclareMajorVariables();
    effect eCharm   = EffectCharmed();
    effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eImpact  = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink    = EffectLinkEffects(eMind, eDur);
    effect eVis     = EffectVisualEffect(VFX_IMP_CHARM);
    int nDuration   = spell.Level;
    //Check for metamagic extend
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2;

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    float fDelay;
    effect scaledEffect;
    int scaledDuration;

    int nAmount     = spell.Level * 2;
    object oTarget  = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, spell.Loc);
    while (GetIsObjectValid(oTarget) && nAmount > 0)
    {
        if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
        {
            fDelay = GetRandomDelay();
            //Check that the target is humanoid
            if(CreatureGetIsHumanoid(oTarget) && nAmount >= GetHitDice(oTarget))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Make an SR check
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    //Make a Will save to negate
                    if (!MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                    {
                        scaledEffect    = GetScaledEffect(eCharm, oTarget);
                        scaledEffect    = EffectLinkEffects(eLink, scaledEffect);
                        scaledDuration  = GetScaledDuration(nDuration, oTarget);

                        //Apply the linked effects and the VFX impact
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, TurnsToSeconds(scaledDuration)));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));

                        // Personal Reputation and Reaction System
                        //PRR_CHARM_AffectTarget(spell.Target, OBJECT_SELF, nDuration);
                    }
                    else
                    {
                        // Reputation
                        //  - Unimplemented
                        // Caster's reputation should suffer when a target makes a save
                        // and realizes that a charm spell was cast

                    }
                    //Add the creatures HD to the count of affected creatures
                    //nCnt = nCnt + GetHitDice(oTarget);
                }
                nAmount = nAmount - GetHitDice(oTarget);
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, spell.Loc);
    }
}
