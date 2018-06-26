//::///////////////////////////////////////////////
//:: Magic Circle Against Good
//:: NW_S0_CircGood.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 18, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71, fix by Shadooow

- disabled aura stacking
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
*/
//:://////////////////////////////////////////////
//:: Modified:  Henesua (2013 sept 12) duration to turns

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "nw_i0_spells"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();

    effect eAOE = EffectAreaOfEffect(AOE_MOB_CIRCEVIL);
    effect eVis = EffectVisualEffect(VFX_DUR_AURA_ODD);
    effect eLink = CreateProtectionFromAlignmentLink(ALIGNMENT_GOOD);

    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eAOE);

    int nDuration = 5 + spell.Level;

    //Check Extend metamagic feat.
    if (spell.Meta == METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }

    //prevent stacking
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    eVis = EffectVisualEffect(VFX_IMP_EVIL_HELP);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
    spellsSetupNewAOE("VFX_MOB_CIRCEVIL");
}
