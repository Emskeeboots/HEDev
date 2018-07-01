//::///////////////////////////////////////////////
//:: _s2_invisib
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Invisibility
        Activated by a feat or item property bonus feat

        Number of casts per day comes from familiar's spell casting pool

    Original:   NW_S0_Invisib -- Preston Watamaniuk (Jan 7, 2002)
        Target creature becomes invisibility

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 14)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

// THE MAGUS' INNOCUOUS FAMILIARS
#include "_inc_pets"

void main()
{
// Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;
// End of Spell Cast Hook

    // Spell-like Ability Spell Pool
    object oMaster  = GetMaster();
    int nPool   = GetLocalInt(oMaster, FAMILIAR_SPELL_POOL)-1;

    // Feedback describing remaining Spell Pool capacity
    FamiliarDisplaySpellPool(nPool);

    if(nPool<0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPELLPOOL_DEPLETION), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE), OBJECT_SELF, 0.25);
        return;
    }
    else
    {
        // Although item property feats have unlimited use, regular feats do not.
        // They need to be incremented until the spell pool is exhausted
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_INVISIBILITY);
    }

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_SND_INVISIBILITY), OBJECT_SELF);


    //Declare major variables
    effect eInvis   = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink    = EffectLinkEffects(eInvis, eDur);

    int nDuration   = GetHitDice(OBJECT_SELF);
    float fDuration = TurnsToSeconds(nDuration);

    //Fire cast spell at event for the specified target
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELL_INVISIBILITY, FALSE));

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, fDuration);
}

