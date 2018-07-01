//::///////////////////////////////////////////////
//:: Ironguts
//:: X2_S0_Ironguts
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: When touched the target creature gains a +4
//:: circumstance bonus on Fortitude saves against
//:: all poisons.
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 22, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg 19/10/2003
//:: Modified: Henesua (2013 sept 14) duration to 10 + 2 turns/lvl

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
    effect eSave;
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEAD_ACID);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

   //Stacking Spellpass, 2003-07-07, Georg
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    int nBonus      = 4; //Saving throw bonus to be applied
    int nDuration   = 10 + (2*spell.Level); // Turns
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration * 2;

    //Set the bonus save effect
    eSave = EffectSavingThrowIncrease(SAVING_THROW_FORT, nBonus, SAVING_THROW_TYPE_POISON);
    effect eLink = EffectLinkEffects(eSave, eDur);

    //Apply the bonus effect and VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
    DelayCommand(0.3,ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
}
