//::///////////////////////////////////////////////
//:: _s1_dimdo_use
//:://////////////////////////////////////////////
/*
    On Use Script for Dimensional Door

    Jumps User from one portal to the other

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2011 oct 16)
//:: Modified: henesua (2016 jan 18) added better feedback for when the dimdo collapses
//:://////////////////////////////////////////////

#include "_inc_color"

void main()
{
    object oDest    = GetLocalObject(OBJECT_SELF,"DESTINATION");
    object oCreator = GetLocalObject(OBJECT_SELF,"CREATOR");
    int bDestroy    = GetLocalInt(OBJECT_SELF,"bDESTROY");
    object oUser    = GetLastUsedBy();

    if(!GetIsObjectValid(oUser))
        return;
    else if(bDestroy)
    {
        string sResult;
        int nHP         = GetCurrentHitPoints(oUser);
        effect eLink    = EffectLinkEffects(
                            EffectVisualEffect(VFX_IMP_BREACH),
                            EffectDamage(FloatToInt((nHP*0.25)+0.1))
                            );
        int bSucceed       = TRUE;
        if(oUser == oCreator || !ReflexSave(oUser, 20, SAVING_THROW_TYPE_TRAP))
        {
            bSucceed    = FALSE;
            sResult     = RED+"The portal grates your flesh as it collapses in upon itself!";
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oUser);
        }
        else
        {
            sResult     = WHITE+"You manage to slip through before the portal collapses upon itself!";
        }

        FloatingTextStringOnCreature(sResult, oUser, FALSE);
        if(!bSucceed)
            return;
    }
    else if (oUser == oCreator)
    {
        AssignCommand(OBJECT_SELF, SpeakString("*shudders*") );
        DelayCommand(1.0, AssignCommand(oDest,SpeakString("*shudders*")) );
        DelayCommand(4.0, AssignCommand(OBJECT_SELF,SpeakString("*collapses*")) );
        DelayCommand(5.0, AssignCommand(oDest,SpeakString("*collapses*")) );
        DelayCommand(4.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), OBJECT_SELF));
        DelayCommand(5.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), oDest));
        DelayCommand(0.1, SetLocalInt(OBJECT_SELF,"bDESTROY", TRUE));
        DelayCommand(1.1, SetLocalInt(oDest,"bDESTROY", TRUE));
        DestroyObject(OBJECT_SELF, 6.0);
        DestroyObject(oDest, 6.0);
    }

    SetLocalLocation(oUser,"DESTINATION", GetLocation(oDest));
    SetLocalObject(oUser,"PORTAL",OBJECT_SELF);
    ExecuteScript("_s1_dimdo_jump", oUser);
}
