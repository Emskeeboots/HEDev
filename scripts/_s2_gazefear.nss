//::///////////////////////////////////////////////
//:: _s2_gazefear
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Fear Gaze
        Activated by a feat or item property bonus feat

    Original:   NW_S1_gazefear -- Preston Watamaniuk (May 9, 2001)
        Cone shape that affects all within the AoE if they fail a Will Save.


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
    if( GZCanNotUseGazeAttackCheck(OBJECT_SELF))
    {
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_GAZE_FEAR);
        return;
    }

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
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_GAZE_FEAR);

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);


    // gaze
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_CAST_GAZEFEAR), OBJECT_SELF);

    //Declare major variables
    int nHD = GetHitDice(OBJECT_SELF);
    int nDuration = 1 + (nHD/3);
    int nDC = 10 + (nHD/2);
    location lTargetLocation = GetSpellTargetLocation();
    effect eGaze = EffectFrightened();
//    effect eVis = EffectVisualEffect(VFX_IMP_FEAR_S); //invalid vfx
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);

    effect eLink = EffectLinkEffects(eDur, eVisDur);
    effect scaledEffect;
    int scaledDuration;
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FAMILIAR_GAZE_FEAR));
            //Determine effect delay
            float fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            if(GetIsAbleToSee(oTarget) && !MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR, OBJECT_SELF, fDelay))
            {
                scaledDuration = GetScaledDuration(nDuration, oTarget);
                scaledEffect = GetScaledEffect(eGaze, oTarget);
                scaledEffect = EffectLinkEffects(eLink, scaledEffect);
                //Apply the VFX impact and effects
//                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, RoundsToSeconds(scaledDuration)));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}
