#include "q_inc_traps"

void main()
{
    object oTrap = GetNearestObjectByTag("BH_Trap");

    int nDC     = Trap_GetCustomDC(oTrap);
    if(!nDC){nDC=15;}
    int nDamage = Trap_GetCustomDamage(oTrap);
    if(!nDamage)
        nDamage = d4(2);


    int nTot = 0;
    int nN, nDamTmp;
    object oPC = GetEnteringObject();
    for(nN=0;nN<8;nN++)
    {
        nDamTmp = nDamage;

        nDamTmp = TrapSave(oPC, nDC, nDamTmp);

        if(nDamTmp>0)
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamTmp, DAMAGE_TYPE_PIERCING, DAMAGE_POWER_NORMAL), oPC));

        nTot+=nDamTmp;
    }
    if(nTot>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
        AssignCommand(oPC,PlaySound("cb_ht_metblleth2"));
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    }
    else
       AssignCommand(oPC,PlaySound("cb_sw_blade2"));
}
