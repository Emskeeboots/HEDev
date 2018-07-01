#include "q_inc_traps"
#include "_inc_constants"

void main()
{
    object oPC      = GetEnteringObject();
    if(!GetIsObjectValid(oPC))
    {
        oPC = GetLocalObject(OBJECT_SELF,"TRAP_TRIGGERER_EXECUTE");
        if(!GetIsObjectValid(oPC)){return;}
    }
    DeleteLocalObject(OBJECT_SELF,"TRAP_TRIGGERER_EXECUTE");

    AssignCommand(oPC,ClearAllActions(TRUE));
    object oTrigger = GetLocalObject(OBJECT_SELF, "TRP_TRIGGER_OBJECT");
    object oTrap    = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    // special
    string sDest    = GetLocalString(oTrigger, "TRAP_PIT_DESTINATION");

    //Now we make them fall in the hole.
    int nDC         = Trap_GetCustomDC(oTrigger);
    int nDamage     = Trap_GetCustomDamage(oTrigger);
    if(!nDamage)
        nDamage     = d6(1);
    if(GetTrapDetectedBy(oTrigger,oPC))
        nDC = 10;
    else if(!nDC)
        nDC = 25;



    if(ReflexSave(oPC, nDC, SAVING_THROW_TYPE_TRAP))
    {
        SendMessageToPC(oPC,"You jump to the side and avoid falling into the pit");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
        AssignCommand(oPC,ActionMoveAwayFromObject(oTrap,FALSE,5.0));
    }
    else
    {
        SendMessageToPC(oPC,"You fall into the pit!");

        object oDest;
        if(sDest!=""){oDest = GetWaypointByTag(sDest);}

        // special location
        if(GetIsObjectValid(oDest))
        {
            AssignCommand(oPC,PlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK));
            AssignCommand(oPC, JumpToObject(oDest));
            AssignCommand(oPC, DelayCommand(0.1, takePitDamage(nDamage,TRUE)));
        }
        // if no special location... paralyze and make invisible for 30 seconds
        else
        {
            // if holding a torch we need to get rid of it
            object oItem    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
            if(GetIsObjectValid(oItem))
                AssignCommand(oPC,ActionUnequipItem(oItem));
                   oItem    = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
            if(GetIsObjectValid(oItem))
                AssignCommand(oPC,ActionUnequipItem(oItem));
            AssignCommand(oPC,ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK));
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneGhost(), oPC, 31.0f));
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), oPC, 31.0f));
            DelayCommand(0.6, AssignCommand(oTrap,PlaySound("bf_med_flesh")));
            DelayCommand(1.0, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(oTrap)));
            if(GetCurrentHitPoints(oPC)-nDamage>0)
            {
                DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDisappearAppear(GetLocation(oPC)), oPC, 30.0f));
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneImmobilize(), oPC, 30.0f);
                DelayCommand(30.0,SendMessageToPC(oPC,"You finally climb out of the pit"));
            }

            AssignCommand(oPC, takePitDamage(nDamage));
        }
    }
}
