//::///////////////////////////////////////////////
//:: _s0_splwlmaj
//:://////////////////////////////////////////////
/*



*/
//:://////////////////////////////////////////////
//:: Created:   Rubies and Pearls (2013 jan -- ccc spells and spellcrafting)
//:: Modified:  Henesua (2013 sept 28)  integrated with community patch
//::                                    duration scales, target is a touched creature
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration   = spell.Level;
    if(spell.Meta==METAMAGIC_EXTEND)
        nDuration   *=2;
    float fDuration = RoundsToSeconds(nDuration);

    effect eRes = EffectSpellLevelAbsorption(4, -1, SPELL_SCHOOL_GENERAL);
    effect eVis = EffectVisualEffect(1670); // VERIFY VALUE
    effect eEffect = EffectLinkEffects(eRes, eVis);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GOOD_HELP), spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, spell.Target, fDuration);
}
