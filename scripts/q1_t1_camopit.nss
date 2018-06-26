#include "q_inc_traps"

void main()
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);

    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    TrapPlayAnim(oTrap);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(52),GetLocation(oTrap),HoursToSeconds(200));
    object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT,oTrap);
    SetLocalObject(oAOE, "TRP_TRIGGER_OBJECT",OBJECT_SELF);
    SetLocalObject(oAOE, "TRP_PLCBL_OBJ", oTrap);

    SetLocalObject(oAOE,"TRAP_TRIGGERER_EXECUTE", GetEnteringObject());
    DelayCommand(0.01,ExecuteScript("q1_t0_camopita",oAOE));
}
