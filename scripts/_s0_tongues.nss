//::///////////////////////////////////////////////
//:: _s0_tongues
//:://////////////////////////////////////////////
/*

Caster Level(s): Bard 2, Cleric 4, Wiz/Sor 3
Innate level: 3
School: Divination
Components: verbal
Range: Touch
Area of effect: 1 Creature
Duration: 10 minutes/ level
Save: None
Spell resistance: no

Description:
The recipient understands and speaks languages.
*/
//:://////////////////////////////////////////////
//:: Created: henesua (2017 feb 16)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_spells"

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell

    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_tongues - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level*10;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = TurnsToSeconds(nDuration);


    // spell effect is a vfx and immunities
    effect vfxEnd   = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    // apply effects to target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_COMPREHEND, FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_HEAD_MIND), spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, vfxEnd, spell.Target, fSeconds);
}
