//::///////////////////////////////////////////////
//:: _s0_waterbreath
//:://////////////////////////////////////////////
/*

Caster Level(s): Cleric 3, Druid 3, Ranger 1, Wiz/Sor 3
Innate level: 3
School: transmutation
Components: somatic
Range: touch
Area of effect: 1 creature per level
Duration: 1 hour / level
Save: None
Spell resistance: yes

Description:
Recipients of the spell are able to breathe in water without drowning.

*/
//:://////////////////////////////////////////////
//:: Created: henesua (2016 aug 3)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "nw_i0_spells"

#include "_inc_spells"

void waterbreathing_effects(object target, float duration, effect watbreath)
{
    SignalEvent(target, EventSpellCastAt(target, SPELL_WATER_BREATHING, FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1603), target); // magic resistance blue
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1617), target); // magic protection sound
    DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_COLD), target) );

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, watbreath, target, duration);
}

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell

    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_waterbreath - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int num_targets = spell.Level;
    int temp        = 1;
    int nDuration   = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = HoursToSeconds(nDuration);


    // spell effect is a vfx and immunities
    effect vfxEnd       = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect watbreath    = EffectLinkEffects(vfxEnd, EffectSpellImmunity(SPELL_DROWN) );
           watbreath    = EffectLinkEffects(watbreath, EffectSpellImmunity(SPELLABILITY_PULSE_DROWN) );

    // apply effects to target
    waterbreathing_effects(spell.Target, fSeconds, watbreath);

    if(num_targets <= temp)
        return;

    object oCreature    = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, spell.Loc);
    while(GetIsObjectValid(oCreature))
    {
        //Fire spell cast at event for target
        if(GetIsReactionTypeFriendly(oCreature) || GetFactionEqual(oCreature))
        {
            temp++;
            DelayCommand(GetRandomDelay(0.2, 1.1), waterbreathing_effects(oCreature, fSeconds, watbreath));
            if(num_targets <= temp)
                return;
        }

        //Get the next target in the specified area around the target
        oCreature = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, spell.Loc);
    }
}
