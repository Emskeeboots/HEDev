//::///////////////////////////////////////////////
//:: Shield of Faith
//:: x0_s0_ShieldFait.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 +2 deflection AC bonus, +1 every 6 levels (max +5)
 Duration: 1 turn/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.70, fix by Shadooow

- did signalized wrong spell ID
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 15) duration to rounds

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

    // Amount of protection
    int nValue      = 2 + (spell.Level)/6;
    if (nValue > 5)
        nValue      = 5; // * Max of 5

    // duration
    int nDuration   = 15 + (5*spell.Level);
    if (spell.Meta == METAMAGIC_EXTEND)    //Duration is +100%
        nDuration   = nDuration * 2;
    float fDuration = RoundsToSeconds(nDuration);

    // effects
    effect eVis     = EffectVisualEffect(VFX_IMP_AC_BONUS);
    effect eAC      = EffectACIncrease(nValue, AC_DEFLECTION_BONUS);
    effect eDur     = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
    effect eLink    = EffectLinkEffects(eAC, eDur);

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
}
