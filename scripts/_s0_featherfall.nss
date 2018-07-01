//::///////////////////////////////////////////////
//:: _s0_featherfall
//:://////////////////////////////////////////////
/*
Caster Level(s): Bard 1, Wiz/Sor 1
Innate level: 1
School: Transmutation
Components: verbal
Range: personal
Area of effect: 1 ally per level within 5 meters.
Duration: 1 round/ level
Save: None
Spell resistance: yes

Description:
The recipient suffers no damage from a fall.

Note:
Wizards use this spell automatically during a fall if the spell was prepared.

*/
//:://////////////////////////////////////////////
//:: Created: henesua (2017 feb 16)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x0_i0_spells"

#include "_inc_spells"

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell

    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_featherfall - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = RoundsToSeconds(nDuration);


    // spell effect is a vfx
    effect feather  = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect vfxImp   = EffectVisualEffect(VFX_FNF_DECK);


    location l_spell  = GetLocation(spell.Caster);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_PULSE_WIND),l_spell);
    object target   = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, l_spell);
    while(GetIsObjectValid(target))
    {
        if(spellsIsTarget(target,SPELL_TARGET_ALLALLIES,spell.Caster))
        {
            SignalEvent(target, EventSpellCastAt(spell.Caster, SPELL_FEATHER_FALL, FALSE));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, feather, target, fSeconds);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,vfxImp,target);
        }
        target  = GetNextObjectInShape(SHAPE_SPHERE, 5.0, l_spell);
    }

}
