//::///////////////////////////////////////////////
//:: Shield
//:: x0_s0_shield.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Immune to magic Missile
    +4 general AC
    DIFFERENCES: should be +7 against one opponent
    but this cannot be done.
    Duration: 1 turn/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 15, 2002
//:://////////////////////////////////////////////
//:: Last Update By: Andrew Nobbs May 01, 2003
//:://////////////////////////////////////////////
//:: Modified: The Magus (2013 jan 14) INNOCUOUS FAMILIARS Added immunity for new spell: _s2_magmiss

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_constants"

// MAGUS - for constant: SPELL_FAMILIAR_MAGIC_MISSILE
#include "_inc_pets"

void main()
{
    // Spellcast Hook Code check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return; // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    // End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis     = EffectVisualEffect(VFX_IMP_AC_BONUS);

    effect eArmor   = EffectACIncrease(4, AC_DEFLECTION_BONUS);
    effect eSpell   = EffectLinkEffects(    EffectSpellImmunity(SPELL_MAGIC_MISSILE),           // MAGUS - linking
                                            EffectSpellImmunity(SPELL_FAMILIAR_MAGIC_MISSILE)   // MAGUS - a new spell immunity
                                       );
    effect eProt    = EffectDamageResistance(DAMAGE_TYPE_MAGICAL, 1);
    effect eDur     = EffectVisualEffect(VFX_DUR_GLOBE_MINOR);

    effect eLink    = EffectLinkEffects(eArmor, eDur);
           eLink    = EffectLinkEffects(eLink, eSpell);
           eLink    = EffectLinkEffects(eLink, eProt);

    int nDuration   = spell.Level; // * Duration 1 turn
    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
         nDuration  = nDuration * 2;

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, TurnsToSeconds(nDuration));
}
