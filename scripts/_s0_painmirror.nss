//::///////////////////////////////////////////////
//:: _s0_painmirror
//:://////////////////////////////////////////////
/*



*/
//:://////////////////////////////////////////////
//:: Created:   Rubies and Pearls (2013 jan -- ccc spells and spellcrafting)
//:: Modified:  Henesua (2013 sept 28)  integrated with community patch
//::                                    single script for both sub-spells, scaling duration
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
    int nDamType, nVFX;
    int nDuration   = spell.Level;
    if(spell.Meta==METAMAGIC_EXTEND)
        nDuration   *=2;
    float fDuration = RoundsToSeconds(nDuration);

    if(spell.Id==895)// piercing mirror
    {
        nDamType    = DAMAGE_TYPE_PIERCING;
        nVFX        = 1673;
    }
    else
    {
        nDamType    = DAMAGE_TYPE_SLASHING;
        nVFX        = 1674;
    }


    effect eDS = EffectDamageShield(d6(1), DAMAGE_BONUS_4, nDamType);
    effect eVis = EffectVisualEffect(nVFX);
    effect eEffect = EffectLinkEffects(eDS, eVis);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_AC_BONUS), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, OBJECT_SELF, fDuration);
}
