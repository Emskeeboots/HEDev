//::///////////////////////////////////////////////
//:: _s0_jump
//:://////////////////////////////////////////////
/*

Caster Level(s): Strength: 1, Wiz/Sor 1
Innate level: 1
School: Transmutation
Components: verbal, somatic
Range: touch
Area of effect: 1 creature
Duration: 1 minute / level
Save: None
Spell resistance: yes

Description:
The target's jump skill is significantly improved.

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
        WriteTimestampedLogEntry("ERR: _s0_jump - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = TurnsToSeconds(nDuration);


    // spell effect is a vfx and immunities
    effect vfxEnd   = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect jump     = EffectLinkEffects(vfxEnd, EffectSkillIncrease(SKILL_JUMP,30) );

    // apply effects to target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_JUMP, FALSE));

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, jump, spell.Target, fSeconds);
}
