//::///////////////////////////////////////////////
//:: _s0_gaseous
//:://////////////////////////////////////////////
/*
Caster Level(s): Bard 3, Air 5, Wiz/Sor 4
Innate level: 4
School: Transformation
Components:  somatic
Range: Personal
Area of effect: Self
Duration: 10 minutes/ level
Save: None
Spell resistance: no

Description:
The recipient becomes an insubstantial cloud and gains the ability to fly, and pass through narrow cracks. In addition they are now vulnerable to strong winds, but well protected against most non-magical damage (DR 20/+1).

The character can not enter liquid, cast spells, or speak while in this form. Attacking is ineffectu
*/
//:://////////////////////////////////////////////
//:: Created: henesua (2017 feb 16)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
//#include "x0_i0_spells"

#include "_inc_util" // creature functions
#include "_inc_spells"

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell

    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_gaseous - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level*10;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = TurnsToSeconds(nDuration);

    // spell effect is a polymorph
    effect gaseous  = EffectPolymorph(215,TRUE);

    // apply effects to target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_GASEOUS_FORM, FALSE));

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, gaseous, spell.Target, fSeconds);

    // track polymorphed
    CreaturePolymorphed(spell.Target,TRUE);
}
