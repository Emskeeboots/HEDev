//::///////////////////////////////////////////////
//:: Bigby's Crushing Hand
//:: [x0_s0_bigby5]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Similar to Bigby's Grasping Hand.
    If Grapple succesful then will hold the opponent and do 2d6 + 12 points
    of damage EACH round for 1 round/level


   // Mark B's famous advice:
   // Note:  if the target is dead during one of these second-long heartbeats,
   // the DelayCommand doesn't get run again, and the whole package goes away.
   // Do NOT attempt to put more than two parameters on the delay command.  They
   // may all end up on the stack, and that's all bad.  60 x 2 = 120.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.71, by Shadooow

- added duration scaling per game difficulty
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14)   use actual grapple check GetIsGrappled
//::                                    incorporeal targets are immune

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"

#include "_inc_util"

void RunHandImpact(object oTarget, object oCaster, int nSpellID, int nMeta)
{

    //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if (GZGetDelayedSpellEffectsExpired(nSpellID,oTarget,oCaster))
    {
        return;
    }

    int nDam = MaximizeOrEmpower(6,2,nMeta, 12);
    effect eDam = EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING);
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_L);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    DelayCommand(6.0,RunHandImpact(oTarget,oCaster,nSpellID,nMeta));
}

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    // This spell no longer stacks. If there is one hand, that's enough
    if (GetHasSpellEffect(spell.Id,spell.Target) ||  GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST,spell.Target))
    {
        FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
        return;
    }

    int nDuration   = spell.Level;
        nDuration   = GetScaledDuration(nDuration, spell.Target);
    //Check for metamagic extend
    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
         nDuration  = nDuration * 2;

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));

        // incorporeal target is immune
        if(CreatureGetIsIncorporeal(spell.Target))
        {
            FloatingTextStringOnCreature(RED+"Incorporeal targets are immune to grapples.",spell.Caster,FALSE);
            return;
        }

        //SR
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            int nCasterModifier = GetCasterAbilityModifier(spell.Caster)+ spell.Level;
            int nCasterRoll = d20(1) + nCasterModifier + 12 + -1;
            int nTargetRoll = GetAC(spell.Target);

            // * grapple HIT succesful,
            if (nCasterRoll >= nTargetRoll)
            {
                // * now must make a GRAPPLE check
                // * hold target for duration of spell

                nCasterRoll = d20(1) + nCasterModifier + 12 + 4;

                /*
                nTargetRoll = d20(1)
                             + GetBaseAttackBonus(spell.Target)
                             + GetSizeModifier(spell.Target)
                             + GetAbilityModifier(ABILITY_STRENGTH, spell.Target);
                */

                //if (nCasterRoll >= nTargetRoll)
                if( GetIsGrappled(spell.Target, nCasterRoll) )
                {
                    effect eKnockdown = EffectParalyze();

                    // creatures immune to paralzation are still prevented from moving
                    if (GetIsImmune(spell.Target, IMMUNITY_TYPE_PARALYSIS, spell.Caster) ||
                        GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
                    {
                        eKnockdown = EffectCutsceneImmobilize();
                    }

                    effect eHand = EffectVisualEffect(VFX_DUR_BIGBYS_CRUSHING_HAND);
                    effect eLink = EffectLinkEffects(eKnockdown, eHand);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                                        eLink, spell.Target,
                                        RoundsToSeconds(nDuration));

                    RunHandImpact(spell.Target, spell.Caster, spell.Id, spell.Meta);
                    FloatingTextStrRefOnCreature(2478, spell.Caster);
                }
                else
                {
                    FloatingTextStrRefOnCreature(83309, spell.Caster);
                }
            }
        }
    }
}
