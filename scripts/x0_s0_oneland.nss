//::///////////////////////////////////////////////
//:: One with the Land
//:: x0_s0_oneland.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 bonus +4: animal empathy, move silently, search, hide
 Duration: 1 hour/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 19, 2002
//:://////////////////////////////////////////////
//:: Last Update By: Andrew Nobbs May 01, 2003
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14) duration to turns, skills changed

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis         = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);

    effect eSkillAnimal = EffectSkillIncrease(SKILL_ANIMAL_EMPATHY, 4);
    effect eSearch      = EffectSkillIncrease(SKILL_SEARCH, 4);
    effect eClimb       = EffectSkillIncrease(24, 4); // climb
    effect eSwim        = EffectSkillIncrease(25, 4); // swim

    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink        = EffectLinkEffects(eSkillAnimal, eSearch);
           eLink        = EffectLinkEffects(eLink, eClimb);
           eLink        = EffectLinkEffects(eLink, eSwim);
           eLink        = EffectLinkEffects(eLink, eDur);

    int nDuration       = 10 + (spell.Level*2); // * Duration Turns 10 + 2 per level
    if (spell.Meta == METAMAGIC_EXTEND)    //Duration is +100%
         nDuration = nDuration * 2;

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
}
