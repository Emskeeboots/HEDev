//::///////////////////////////////////////////////
//:: _s0_comprehend
//:://////////////////////////////////////////////
/*

Caster Level(s): Cleric 1, Wiz/Sor 1
Innate level: 1
School: Divination
Components: verbal, somatic
Range: Personal
Area of effect: Self
Duration: 10 minutes/ level
Save: None
Spell resistance: yes

Description:
The recipient understands languages, but can not speak them. This spell also provides a bonus to decipher obscure writings.

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
        WriteTimestampedLogEntry("ERR: _s0_comprehend - invalid caster");
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
    effect comprehend= EffectLinkEffects(vfxEnd, EffectSkillIncrease(SKILL_DECIPHER_SCRIPT,30) );

    // apply effects to target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_COMPREHEND, FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_HEAD_MIND), spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, comprehend, spell.Target, fSeconds);
}
