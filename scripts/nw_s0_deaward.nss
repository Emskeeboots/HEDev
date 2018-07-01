//::///////////////////////////////////////////////
//:: Death Ward
//:: NW_S0_DeaWard.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature is protected from the instant
    death effects for the duration of the spell
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 27, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 27, 2001
//:: Modified: Henesua (2013 sept 9) duration adjusted to turns from hours

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}


    //Declare major variables
    spellsDeclareMajorVariables();
    effect eDeath = EffectImmunity(IMMUNITY_TYPE_DEATH);
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eDeath, eDur);


    int nDuration = 5 + spell.Level;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Apply VFX impact and death immunity effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

