//::///////////////////////////////////////////////
//:: Amplify
//:: x0_s0_amplify.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster or target is able to hear sounds better.
    Listen skill increases by 20.
    DURATION: 1 round/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 30, 2002
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14) duration 10 t + 2t/lvl. Bonus +10 listen

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);

    effect eHide = EffectSkillIncrease(SKILL_LISTEN, 10);

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eHide, eDur);

    int nDuration = 10 + (2*spell.Level);
    if (spell.Meta == METAMAGIC_EXTEND)    //Duration is +100%
         nDuration = nDuration * 2;

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
}
