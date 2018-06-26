#include "q_inc_traps"

void main()
{
    object oTrigger = GetLocalObject(OBJECT_SELF, "TRP_TRIGGER_OBJECT");
    object oTrap    = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    int nDC         = Trap_GetCustomDC(oTrigger);
    if(!nDC){nDC=20;}
    int nDamage     = Trap_GetCustomDamage(oTrigger);
    location lLoc   = GetLocation(oTrap);

    object oPC = GetEnteringObject();
    if(GetObjectType(oPC)==OBJECT_TYPE_CREATURE)
    {
        if(!ReflexSave(oPC, nDC, SAVING_THROW_TYPE_TRAP))
        {
            if (GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
            {
                nDamage /= 2;
            }
        }
        else if (GetHasFeat(FEAT_EVASION, oPC) || GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
        {
            nDamage = 0;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
        }
        else
        {
            nDamage /= 2;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
        }

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_BLOOD_CRT_RED), GetLocation(oPC));
        }
    }
}


