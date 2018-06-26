//::///////////////////////////////////////////////
//:: [Endurance]
//:: [NW_S0_Endurce.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Gives the target 1d4+1 Constitution.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70, fix by Shadooow

- empower metamagic fixed
*/
//:: Modified:  Henesua (2013 sept 9) duration changed to turns


#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //Set the ability bonus effect
    int nModify = MaximizeOrEmpower(4,1,spell.Meta,1);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION,nModify);
    effect eLink= EffectLinkEffects(eCon, eDur);
    // Duration
    int nDur    = 5 + spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDur *= 2;
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Appyly the VFX impact and ability bonus effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDur));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
