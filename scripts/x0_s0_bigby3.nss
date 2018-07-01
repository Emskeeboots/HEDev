//::///////////////////////////////////////////////
//:: Bigby's Grasping Hand
//:: [x0_s0_bigby3]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    make an attack roll. If succesful target is held for 1 round/level


*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.70, fix by Shadooow

- stunning visual effect removed if the target is mind/paralyse immune
- added duration scaling per game difficulty
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14)   use actual grapple check GetIsGrappled
//::                                    incorporeal targets are immune

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    int nDuration   = spell.Level;
        nDuration   = GetScaledDuration(nDuration, spell.Target);
    //Check for metamagic extend
    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
         nDuration  = nDuration * 2;

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));

        // This spell no longer stacks. If there is one hand, that's enough
        if (GetHasSpellEffect(463,spell.Target) ||  GetHasSpellEffect(462,spell.Target)  )
        {
            FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
            return;
        }
        // incorporeal target is immune
        if(CreatureGetIsIncorporeal(spell.Target))
        {
            FloatingTextStringOnCreature(RED+"Incorporeal targets are immune to grapples.",spell.Caster,FALSE);
            return;
        }

        // Check spell resistance
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            // Check caster ability vs. target's AC

            int nCasterModifier = GetCasterAbilityModifier(spell.Caster) + spell.Level;
            int nCasterRoll = d20(1) + nCasterModifier + 10 + -1;

            int nTargetRoll = GetAC(spell.Target);

            // * grapple HIT succesful,
            if (nCasterRoll >= nTargetRoll)
            {
                // * now must make a GRAPPLE check to
                // * hold target for duration of spell
                // * check caster ability vs. target's size & strength or escape artist skill
                nCasterRoll = d20(1) + nCasterModifier + 10 + 4;

                /*
                nTargetRoll = d20(1)
                             + GetBaseAttackBonus(spell.Target)
                             + GetSizeModifier(spell.Target)
                             + GetAbilityModifier(ABILITY_STRENGTH, spell.Target);
                */

                //if (nCasterRoll >= nTargetRoll)
                if( GetIsGrappled(spell.Target, nCasterRoll) )
                {
                    // Hold the target paralyzed
                    effect eKnockdown = EffectParalyze();

                    // creatures immune to paralzation are still prevented from moving
                    if(     GetIsImmune(spell.Target, IMMUNITY_TYPE_PARALYSIS, spell.Caster)
                        ||  GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster)
                      )
                    {
                        eKnockdown = EffectCutsceneImmobilize();
                    }
                    else
                    {
                        eKnockdown = EffectLinkEffects(eVis, eKnockdown);
                    }

                    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                    effect eHand = EffectVisualEffect(VFX_DUR_BIGBYS_GRASPING_HAND);
                    effect eLink = EffectLinkEffects(eKnockdown, eDur);
                    eLink = EffectLinkEffects(eHand, eLink);

                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                                        eLink, spell.Target,
                                        RoundsToSeconds(nDuration));

//                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
//                                        eVis, oTarget,RoundsToSeconds(nDuration));
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
