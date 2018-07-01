//::///////////////////////////////////////////////
//:: Remove Curse
//:: NW_S0_RmvCurse.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Goes through the effects on a character and removes
    all curse effects.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 7, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001
//:://////////////////////////////////////////////
//:: Modified: The Magus (2011 dec 5) lycanthropy cure and spell hook

#include "x2_inc_spellhook"

#include "_inc_color"
//#include "v2_inc_lycan"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    object oCaster = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();
    object oMod     = GetModule();
    int nMoonPhase  = GetLocalInt(oMod, "MOON_PHASE");
    int nMoonUp     = GetLocalInt(oMod, "MOON_UP");
    int bValid;

    effect eVis = EffectVisualEffect(VFX_IMP_REMOVE_CONDITION);
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_REMOVE_CURSE, FALSE));

    // check for lycanthropy cure
    /*
    if(GetHasLycanthropy(oTarget))
    {
        if(nMoonPhase==MOON_FULL && nMoonUp)
        {
            if(WillSave(oTarget, 20))
            {
                SetHasLycanthropy(oTarget,0,FALSE);
                SendMessageToPC(oCaster,LIGHTBLUE+"Lycanthropy affliction removed from "+GetName(oTarget)+".");
                bValid = TRUE;
            }
            else
                SendMessageToPC(oCaster,RED+GetName(oTarget)+" failed to throw off their curse of lycanthropy.");
        }
        else
            SendMessageToPC(oCaster,RED+"Removing the curse of lycanthropy can only be accomplished on the night of a full moon.");
    }
    */
    effect eRemove = GetFirstEffect(oTarget);
    //Get the first effect on the target
    while(GetIsEffectValid(eRemove))
    {
        //Check if the current effect is of correct type
        if (GetEffectType(eRemove) == EFFECT_TYPE_CURSE)
        {
            //Remove the effect and apply VFX impact
            RemoveEffect(oTarget, eRemove);
            bValid = TRUE;
        }
        //Get the next effect on the target
        GetNextEffect(oTarget);
    }
    if (bValid)
    {
        //Apply VFX Impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}
