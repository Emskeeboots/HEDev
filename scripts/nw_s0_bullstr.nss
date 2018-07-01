//::///////////////////////////////////////////////
//:: nw_s0_bullstr
//:://////////////////////////////////////////////
/*
    Vives 2 Version of Bull's Strength Spell (nw_s0_bullstr)

    Utilizing Communty Patch
    Patch 1.70, fix by Shadooow
    - empower metamagic fixed

    Vives Modifications:
        Name Change: Ursine Strength
        Duration Changed to 5 Turns + 1 Turn/level


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 8)
//:: Modified:

// INCLUDES --------------------------------------------------------------------

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eStr;
    effect eVis     = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    int nModify     = MaximizeOrEmpower(4,1,spell.Meta,1);
    float fDuration = TurnsToSeconds(5 + spell.Level);

    //Signal the spell cast at event
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        fDuration = fDuration * 2.0;    //Duration is +100%
    }


    // This code was there to prevent stacking issues, but programming says thats handled in code...
/*    if (GetHasSpellEffect(SPELL_GREATER_BULLS_STRENGTH))
    {
        return;
    }

    //Apply effects and VFX to target
    RemoveSpellEffects(SPELL_BULLS_STRENGTH, OBJECT_SELF, oTarget);
    RemoveSpellEffects(SPELLABILITY_BG_BULLS_STRENGTH, OBJECT_SELF, oTarget);
*/

    //Create the Ability Bonus effect with the correct modifier
            eStr    = EffectAbilityIncrease(ABILITY_STRENGTH,nModify);
    effect eLink    = EffectLinkEffects(eStr, eDur);

    //Apply visual and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
}
