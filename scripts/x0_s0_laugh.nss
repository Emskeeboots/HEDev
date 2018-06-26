//::///////////////////////////////////////////////
//:: Tasha's Hideous Laughter
//:: [x0_s0_laugh.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target is held, laughing for the duration
    of the spell (1d3 rounds)

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70, fix by ILKAY

- alignment immune creatures were ommited
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14) duration fixed

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    spellsDeclareMajorVariables();
    int nDamage = 0;
    int nCnt;
    effect eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);

    int nDuration = d3();
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2; //Duration is +100%

    // * creatures of different race find different things funny
    int nModifier = 0;
    if (GetRacialType(spell.Target) != GetRacialType(spell.Caster))
        nModifier = 4;

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        if (spellsIsMindless(spell.Target) == FALSE)
        {
            if (!MyResistSpell(spell.Caster, spell.Target) && !MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC-nModifier, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
                if (!GetIsImmune(spell.Target,IMMUNITY_TYPE_MIND_SPELLS,spell.Caster))
                {
                    effect eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                    float fDur = RoundsToSeconds(nDuration);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spell.Target, fDur);

                /*    string szLaughMale = "as_pl_laughingm2";
                    string szLaughFemale = "as_pl_laughingf3";

                    if (GetGender(oTarget) == GENDER_FEMALE)
                    {
                        PlaySound(szLaughFemale);
                    }
                    else
                    {
                        PlaySound(szLaughMale);
                    }      */
                    AssignCommand(spell.Target, ClearAllActions());
                    AssignCommand(spell.Target, PlayVoiceChat(VOICE_CHAT_LAUGH));
                    AssignCommand(spell.Target, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING));
                    effect eLaugh = EffectKnockdown();
                    DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLaugh, spell.Target, fDur));
                }
            }
        }
    }
}
