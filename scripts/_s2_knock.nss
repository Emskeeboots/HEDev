//::///////////////////////////////////////////////
//:: _s2_knock
//:://////////////////////////////////////////////
/*
    Spell Script for Familiar's Knock Spell Ability
        Activated by a feat or item property bonus feat


        Number of casts per day comes from familiar's spell casting pool

    Original:   NW_S0_knock -- Preston Watamaniuk (Nov 29, 2001)
        Opens doors not locked by magical means.
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
        IncrementRemainingFeatUses(OBJECT_SELF, FEAT_FAMILIAR_KNOCK);

    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, nPool);


    location lTarget= GetSpellTargetLocation();
    effect eVis     = EffectVisualEffect(VFX_IMP_KNOCK);
    float fDelay; int nResist;
    object oTarget  = GetFirstObjectInShape(SHAPE_SPHERE, 50.0, lTarget, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(oTarget))
    {
        SignalEvent(oTarget,EventSpellCastAt(OBJECT_SELF,SPELL_FAMILIAR_KNOCK));
        fDelay      = GetRandomDelay(0.5, 2.5);
        if(!GetPlotFlag(oTarget) && GetLocked(oTarget))
        {
            nResist = GetDoorFlag(oTarget,DOOR_FLAG_RESIST_KNOCK);
            if(nResist==0)
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                AssignCommand(oTarget, ActionUnlockObject(oTarget));
            }
            else if(nResist==1)
            {
                FloatingTextStrRefOnCreature(83887,OBJECT_SELF);
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 50.0, lTarget, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
