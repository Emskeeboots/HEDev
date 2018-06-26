//::///////////////////////////////////////////////
//:: _s2_dispel
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Dispel Spell Ability
        Activated by a feat or item property bonus feat
        Caster level is capped at 20.

        Number of casts per day comes from familiar's spell casting pool

    Original:   NW_S0_dismagic -- Preston Watamaniuk (Jan 7, 2002)
        //:: Attempts to dispel all magic on a targeted
        //:: object, or simply the most powerful that it
        //:: can on every object in an area if no target
        //:: specified.

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
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_DISPEL_MAGIC);

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);


    effect    eVis         = EffectVisualEffect(VFX_IMP_BREACH);
    effect    eImpact      = EffectVisualEffect(VFX_FNF_DISPEL);
    object    oTarget      = GetSpellTargetObject();
    location  lLocal       = GetSpellTargetLocation();
    int       nCasterLevel = GetHitDice(OBJECT_SELF);

    if(nCasterLevel>20)
        nCasterLevel = 20; // max caster level

    if (GetIsObjectValid(oTarget))
    {
        //----------------------------------------------------------------------
        // Targeted Dispel - Dispel all
        //----------------------------------------------------------------------
         spellsDispelMagic(oTarget, nCasterLevel, eVis, eImpact);
    }
    else
    {
        //----------------------------------------------------------------------
        // Area of Effect - Only dispel best effect
        //----------------------------------------------------------------------

        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetSpellTargetLocation());
        oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLocal, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE );
        while (GetIsObjectValid(oTarget))
        {
            if(GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
            {
                //--------------------------------------------------------------
                // Handle Area of Effects
                //--------------------------------------------------------------
                spellsDispelAoE(oTarget, OBJECT_SELF, nCasterLevel);
            }
            else if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
            {
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            }
            else
            {
                spellsDispelMagic(oTarget, nCasterLevel, eVis, eImpact, FALSE);
            }

           oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE,lLocal, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
        }
    }
}
