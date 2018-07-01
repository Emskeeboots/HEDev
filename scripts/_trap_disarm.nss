//::///////////////////////////////////////////////
//:: _trap_disarm
//:://////////////////////////////////////////////
/*
    Runs in OnDisarm event of a trap
*/
//:://////////////////////////////////////////////
//:: Created By: henesua (2016 jan 5)
//:: Modified:
//:://////////////////////////////////////////////


#include "_inc_util"
#include "_inc_xp"

void main()
{
    object oPC  = GetLastDisarmed();

    if(MODULE_DEBUG_MODE)
        SendMessageToPC(oPC, "SUCCESSFUL DISARM TRAP!");
/*
    // reward XP for traps if the trap is dangerous
    if( !GetFactionEqual(oPC) )
        XPRewardDisarmTrap(oPC, OBJECT_SELF);
*/
    // TRAPPORIUM BEGIN
    object oPlcbl = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    if(GetIsObjectValid(oPlcbl))
    {
        object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT,oPlcbl);
        if(GetAreaOfEffectCreator(oAOE)==OBJECT_SELF)
            DestroyObject(oAOE);

        if(GetIsObjectValid(oPlcbl))
        {
            AssignCommand(oPlcbl, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
            if(GetTag(oPlcbl)=="RazorWire")
                DestroyObject(oPlcbl);
        }

        DeleteLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW");
        DeleteLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
        DeleteLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
    }
    // TRAPPORIUM END
}
