//::///////////////////////////////////////////////
//:: Mage Armor
//:: [NW_S0_MageArm.nss]
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the target +4 AC Bonus to Armor Enchantment
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
bugfix by Kovi 2002.07.23
- dodge bonus was stacking

Patch 1.70, fix by ILKAY
- fixed stacking the shadow conjuration variant with itself
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 Sept 9) Duration to turns. Enhancement is purely as armor bonus.

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code - If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if(!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
//    int nDuration = GetCasterLevel(OBJECT_SELF);
    int nDuration = 10 + (spell.Level*2);
    //Check for metamagic extend
    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
         nDuration = nDuration * 2;

    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);
    effect eAC1 = EffectACIncrease(4, AC_ARMOUR_ENCHANTMENT_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAC1, eDur);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    // remove prior effects from same spell
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply the armor bonuses and the VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
