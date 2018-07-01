//::///////////////////////////////////////////////
//:: _s0_abjshield
//:://////////////////////////////////////////////
/*



*/
//:://////////////////////////////////////////////
//:: Created:   Rubies and Pearls (2013 jan -- ccc spells and spellcrafting)
//:: Modified:  Henesua (2013 sept 28)  integrated with community patch
//::                                    duration scales, target is a touched creature
//::                                    both version use same script
//:://////////////////////////////////////////////

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
    int nMax; // maximum level spell to resist
    int nVFX; // spell duration VFX

    int nDuration   = spell.Level;
    if(spell.Meta==METAMAGIC_EXTEND)
        nDuration   *=2;
    float fDuration = RoundsToSeconds(nDuration);

    SignalEvent(spell.Target, EventSpellCastAt(OBJECT_SELF, spell.Id, FALSE));

    if(spell.Id==905)   // minor abjuring shield
    {
        nMax    = 2;
        nVFX    = 1141;
    }
    else                // major abjuring shield
    {
        nMax    = 4;
        nVFX    = 1142;
    }


    effect eRes     = EffectSpellLevelAbsorption(nMax, -1, SPELL_SCHOOL_GENERAL);
    effect eVis     = EffectVisualEffect(nVFX);
    effect eEffect  = EffectLinkEffects(eRes, eVis);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_PROTECTION), spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, spell.Target, fDuration);
}
