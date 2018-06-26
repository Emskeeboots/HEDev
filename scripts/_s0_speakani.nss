//::///////////////////////////////////////////////
//:: _s0_speakani
//:://////////////////////////////////////////////
/*
    Speak with Animals
    Caster Level(s): Animal 3, Druid 2, Ranger 1
    Innate Level: 4
    School: Divination
    Component(s): Verbal, Somatic
    Range: Personal
    Area of Effect / Target: Self
    Duration: 1 hour / Level
    Additional Counter Spells: None
    Save: None
    Spell Resistance: No

    For the duration of the spell, the caster is able to speak with and understand animals.

    Use: Chat. To change the spoken language, see the chat commands.
*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 17)
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
        WriteTimestampedLogEntry("ERR: _s0_speakani - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration       = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration *2;   //Duration is +100%

    effect vfxEnd       = EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL);
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELL_SPEAK_WITH_ANIMALS, FALSE));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, vfxEnd, OBJECT_SELF, HoursToSeconds(nDuration));
}
