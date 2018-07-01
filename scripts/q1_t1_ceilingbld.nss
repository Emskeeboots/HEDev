#include "q_inc_traps"

void doTrap(object oTrap)
{
    int nDC     = Trap_GetCustomDC(oTrap);
    if(!nDC){nDC=20;}
    int nDamage = Trap_GetCustomDamage(oTrap);
    if(!nDamage)
        nDamage = d12();

    object oTriggerer = GetEnteringObject();

    int nDamTmp = TrapSave(oTriggerer, nDC, nDamage);
    if(nDamTmp>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamTmp, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oTriggerer));
    }

    int nN=1;
    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamTmp = nDamage;

        nDamTmp = TrapSave(oPC, nDC, nDamTmp);

        if(nDamTmp>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamTmp, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC));
        }

        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, ++nN);
    }
}

void main()
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);


    object oTrap;

    if(GetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW")==0)
    {
        location lPlcbl = GetLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
        SetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW",1);
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"swingbladepcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));
}
