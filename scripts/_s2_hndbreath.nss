//::///////////////////////////////////////////////
//:: _s2_hndbreath
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Hell Hound Breath Weapon
        Activated by a feat or item property bonus feat

    Original:   NW_S1_hndbreath -- Preston Watamaniuk (May 14, 2001)
        A cone of fire eminates from the hound.


*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2015 sep 15)
//:: Modified:
//:://////////////////////////////////////////////

#include "x0_I0_SPELLS"
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
    //object oMaster  = GetLocalObject(OBJECT_SELF, "MASTER"); // TESTING might need in some circumstance
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
        // Although item property feats have unlimited use, regular feats do not.
        // They need to be incremented until the spell pool is exhausted
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_HOUND_BREATH);

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);


    // breath fire
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_CAST_HOUNDBREATH), OBJECT_SELF);

    //Declare major variables
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + (nHD/2);
    int nDamage;
    int nDice = 1+(nHD/4);
    float fDelay;
    location lTargetLocation = GetSpellTargetLocation();
    object oTarget;
    effect eCone;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);

    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget,SPELL_TARGET_STANDARDHOSTILE,OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FAMILIAR_HOUND_BREATH));
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamage = GetReflexAdjustedDamage(d6(nDice), oTarget, nDC, SAVING_THROW_TYPE_FIRE, OBJECT_SELF);
            if(nDamage > 0)
            {
                //Set damage effect
                eCone = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eCone, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}
