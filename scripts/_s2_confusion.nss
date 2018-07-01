//::///////////////////////////////////////////////
//:: _s2_confusion
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Confusion Spell Ability
        Activated by a feat or item property bonus feat
        Number of rounds = Charisma Modifier + HD/2
                --> minimum of 8 round duration

        Number of casts per day comes from familiar's spell casting pool

    Original:   NW_S0_confusion -- Preston Watamaniuk (Jan 30, 2001)
        All creatures within a 15 foot radius must
        save or be confused for a number of rounds
        equal to the casters level.

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2015 sep 15)
//:: Modified:
//:://////////////////////////////////////////////

#include "X0_I0_SPELLS"
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
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_CONFUSION);

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);

    location lLoc   = GetSpellTargetLocation();
    int nCasterLvl  = GetHitDice(OBJECT_SELF);
    int nMod        = GetAbilityModifier(ABILITY_CHARISMA) + nCasterLvl/2;
    int nDC         = 11 + nMod;
    int nBaseDur    = nMod; if(nBaseDur<8){nBaseDur=8;}
    int nDuration;

    effect eVis     = EffectVisualEffect(VFX_IMP_CONFUSION_S);
    effect eImpact  = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eConfuse = EffectConfused();
    effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    float fDelay;
    //Link duration VFX and confusion effects

    effect eDur     = EffectLinkEffects(eMind, eConfuse);
           eDur     = EffectLinkEffects(eDur, EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lLoc);

    //Search through target area
    object oTarget  = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLoc);
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
           //Fire cast spell at event for the specified target
           SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FAMILIAR_CONFUSION));
           fDelay = GetRandomDelay();
           //Make SR Check and faction check
           if (!MyResistSpell(OBJECT_SELF, oTarget, fDelay))
           {
                //Make Will Save
                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay))
                {

                   nDuration = GetScaledDuration(nBaseDur, oTarget);

                   /*
                   //Perform metamagic checks
                   if (spell.Meta == METAMAGIC_EXTEND)
                   {
                        nDuration = nDuration * 2;
                   }
                   */
                   //Apply linked effect and VFX Impact
                   DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, RoundsToSeconds(nDuration)));
                   DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Get next target in the shape
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLoc);
    }
}
