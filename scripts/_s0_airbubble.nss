//::///////////////////////////////////////////////
//:: _s0_airbubble
//:://////////////////////////////////////////////
/*

Caster Level(s): Druid 2, Wiz/Sor 2
Innate level: 2
School: evocation
Components: verbal
Range: touch
Area of effect: 1 creature
Duration: 1 minute / level
Save: None
Spell resistance: yes

Description:
A self replenishing bubble of fresh air forms around the head of the target,
enabling the target to safely breathe underwater or in clouds of noxious gas.
The air bubble also enables the target to speak clearly when submerged in a fluid.

*/
//:://////////////////////////////////////////////
//:: Created: henesua (2016 aug 3)
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
        WriteTimestampedLogEntry("ERR: _s0_airbubble - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = TurnsToSeconds(nDuration);


    // spell effect is a vfx and immunities
    effect vfxEnd       = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect airbubble    = EffectLinkEffects(vfxEnd, EffectVisualEffect(1676) );
           airbubble    = EffectLinkEffects(EffectSpellImmunity(SPELL_STINKING_CLOUD), airbubble );
           airbubble    = EffectLinkEffects(EffectSpellImmunity(SPELLABILITY_TYRANT_FOG_MIST), airbubble );
           airbubble    = EffectLinkEffects(EffectSpellImmunity(SPELL_CLOUD_OF_BEWILDERMENT), airbubble );

    SignalEvent(spell.Target, EventSpellCastAt(spell.Target, SPELL_AIR_BUBBLE, FALSE));

    // spell effects - so that it appears something happened
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1638), spell.Target); // ability score boost sound
    DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_COLD), spell.Target) );


    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, airbubble, spell.Target, fSeconds);
}
