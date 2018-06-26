//::///////////////////////////////////////////////
//:: _s2_magmiss
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Magic Missile
        Activated by a feat or item property bonus feat
        Number of missiles 1 + (HD/3) with no cap

        Number of casts per day comes from familiar's spell casting pool

    Original:   NW_S0_MagMiss -- Preston Watamaniuk (May 8, 2001)
        A missile of magical energy darts forth from your
        fingertip and unerringly strikes its target. The
        missile deals 1d4+1 points of damage.

        For every two extra levels of experience past 1st, you
        gain an additional missile.



*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 14)
//:: Modified:
//:://////////////////////////////////////////////

#include "NW_I0_SPELLS"
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
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_MAGIC_MISSILE);

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_SND_MAGIC_MISSILE), OBJECT_SELF);


    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    object oTarget = GetSpellTargetObject();
    int nCasterLvl = GetHitDice(OBJECT_SELF);
    int nDamage = 0;
    int nCnt;
    effect eMissile = EffectVisualEffect(VFX_IMP_MIRV);
    effect eVis = EffectVisualEffect(VFX_IMP_MAGBLUE);
    int nMissiles = 1 + (nCasterLvl/3);
    float fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
    float fDelay = fDist/(3.0 * log(fDist) + 2.0);
    float fDelay2, fTime;
    if(!GetIsReactionTypeFriendly(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FAMILIAR_MAGIC_MISSILE));

        //Make SR Check
        if (!MyResistSpell(OBJECT_SELF, oTarget, fDelay))
        {
            //Apply a single damage hit for each missile instead of as a single mass
            for (nCnt = 1; nCnt <= nMissiles; nCnt++)
            {
                //Roll damage
                int nDam = d4(1) + 1;
                //Enter Metamagic conditions
                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;

                //Set damage effect
                effect eDam = EffectDamage(nDam, DAMAGE_TYPE_MAGICAL);
                //Apply the MIRV and damage effect
                DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
                DelayCommand(fDelay2, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget));
             }
         }
         else
         {
            for (nCnt = 1; nCnt <= nMissiles; nCnt++)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
            }
         }
     }
}
