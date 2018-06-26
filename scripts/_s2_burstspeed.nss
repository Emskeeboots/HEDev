//::///////////////////////////////////////////////
//:: _s2_burstspeed
//:://////////////////////////////////////////////
/*
    Spell Script for feat Burst of Speed
        Increases movement rate by 150% with each use
        Extraordinary ability

    Original:   x0_s0_exretreat -- Brent Knowles (September 6, 2002)

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 25) Modified expeditious retreat into extraordinary ability: burst of speed

#include "NW_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;
    // End of Spell Cast Hook

    effect eFast    = EffectMovementSpeedIncrease(150);
           eFast    = ExtraordinaryEffect(eFast);

    int nDuration   = 5 + GetHitDice(OBJECT_SELF);
    float fDuration = RoundsToSeconds(nDuration);

    //Apply the effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFast, OBJECT_SELF, fDuration);
}
