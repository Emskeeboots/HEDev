#include "q_inc_traps"

void doTrap(object oTrap)
{
    int nDC     = Trap_GetCustomDC(oTrap);
    if(!nDC){nDC=15;}
    int nDamage = Trap_GetCustomDamage(oTrap);
    if(!nDamage)
        nDamage = d4()+2;


    int nN; int nDamTmp; int nTot;
    object oPC = GetEnteringObject();
    for(nN=0;nN<4;nN++)
    {
        nDamTmp = nDamage;

        nDamTmp = TrapSave(oPC, nDC, nDamTmp);

        if(nDamTmp>0)
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamTmp, DAMAGE_TYPE_BLUDGEONING), oPC));

        nTot+=nDamTmp;
    }
    if(nTot>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
        AssignCommand(oPC,PlaySound("cb_ht_metblleth2"));
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    }
    else
       AssignCommand(oPC,PlaySound("cb_sw_blunt2"));
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
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"crushingwallpcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));

    DelayCommand(1.0,doTrap(oTrap));
}


