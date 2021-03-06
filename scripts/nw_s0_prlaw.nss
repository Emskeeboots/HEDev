//::///////////////////////////////////////////////
//:: Protection from Law
//:: NW_S0_PrLaw.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Add basic protection from law effects to
    entering allies.
*/
//:://////////////////////////////////////////////
//:: Created: Shadooow (March 29, 2012)
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 12) duration - hours to turns

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode())
        return;

    int nAlign          = ALIGNMENT_LAWFUL;

    effect eAC          = EffectACIncrease(2, AC_DEFLECTION_BONUS);
           eAC          = VersusAlignmentEffect(eAC, nAlign, ALIGNMENT_ALL);
    effect eSave        = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2);
           eSave        = VersusAlignmentEffect(eSave, nAlign, ALIGNMENT_ALL);
    effect eImmune      = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
           eImmune      = VersusAlignmentEffect(eImmune, nAlign, ALIGNMENT_ALL);
    effect eDur         = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
    effect eDur2        = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink        = EffectLinkEffects(eImmune, eSave);
           eLink        = EffectLinkEffects(eLink, eAC);
           eLink        = EffectLinkEffects(eLink, eDur);
           eLink        = EffectLinkEffects(eLink, eDur2);

    int nDuration = 5 + spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
       nDuration = nDuration *2;    //Duration is +100%


    //Apply the VFX impact and effects
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
}
