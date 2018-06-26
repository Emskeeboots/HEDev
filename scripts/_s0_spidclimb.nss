//::///////////////////////////////////////////////
//:: _s0_spidclimb
//:://////////////////////////////////////////////
/*

Caster Level(s): Wiz/Sor 2, Druid 2, Vermin 1
Innate Level: 2
School: Transmutation
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature
Duration: 1 minute / level
Additional Counter Spells:
Save: None
Spell Resistance: No

Enables the target to climb as well as a spider on walls or even across a ceiling.
This results in automatic success for climbing checks, and grants the ability to cross
impassable terrain (such as pits, chasms or water) indoors.
The later ability is available in your radial class menu, target a location with
the spider climb ability.

*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2014 jan 7)
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
        WriteTimestampedLogEntry("ERR: _s0_spidclimb - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%
    float fSeconds  = TurnsToSeconds(nDuration);


    // Bonus Feat Item Property
    object oSkin    = SkinGetSkin(spell.Target);
    itemproperty ipSpiderClimb  = ItemPropertyBonusFeat(199); // spider climb bonus feat
    IPSafeAddItemProperty(oSkin, ipSpiderClimb, fSeconds, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE);

    // temporarily alter AI for NPCs so that they take advantage of their new spider climb ability
    if( !GetIsPC(spell.Target)
        && GetLocalString(spell.Target, "X2_SPECIAL_COMBAT_AI_SCRIPT")==""
      )
    {
        SetLocalString(spell.Target, "X2_SPECIAL_COMBAT_AI_SCRIPT", "_ai_jump_spec");
        DelayCommand(fSeconds, DeleteLocalString(spell.Target, "X2_SPECIAL_COMBAT_AI_SCRIPT") );
    }


    effect vfxEnd       = EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL);
    SignalEvent(spell.Target, EventSpellCastAt(spell.Target, SPELL_SPIDER_CLIMB, FALSE));

    // spell effects - so that it appears something happened
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1634), spell.Target); // ability score boost b
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1638), spell.Target); // ability score boost sound
    DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_NATURE), spell.Target) );


    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, vfxEnd, spell.Target, fSeconds);
}
