//::///////////////////////////////////////////////
//:: Stone Bones
//:: X2_S0_StnBones
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the target +3 AC Bonus to Natural Armor.
    Only if target creature is undead.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
/*
Patch 1.71, by Shadooow

- spell work only for corporeal undeads now, as incorporeal doesn't have bones
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14) duration to hours

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration   = spell.Level;
    int nRacial     = GetRacialType(spell.Target);
    effect eVis     = EffectVisualEffect(VFX_IMP_AC_BONUS);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
         nDuration  = nDuration * 2;

    //Set the one unique armor bonuses
    effect eAC1     = EffectACIncrease(3, AC_NATURAL_BONUS);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink    = EffectLinkEffects(eAC1, eDur);

    //Stacking Spellpass, 2003-07-07, Georg
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply the armor bonuses and the VFX impact
    if(nRacial == RACIAL_TYPE_UNDEAD && !CreatureGetIsIncorporeal(spell.Target))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, HoursToSeconds(nDuration));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    }
    else
    {
        FloatingTextStrRefOnCreature(85390, spell.Caster); // only affects undead;
    }
}
