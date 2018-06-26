//::///////////////////////////////////////////////
//:: _sec_exit
//:://////////////////////////////////////////////
/*
    Use: OnExit event of a trigger

Local String
    - SECRET_RESREF  resref of placeable to use for secret door

Local Int
    - SECRET_SKILL      index of the skill used in detection
    - SECRET_SKILL_DC   challenge rating for detection


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2014 jan 30)
//:: Modified:
//:://////////////////////////////////////////////


#include "x0_i0_secret"

void RemoveDoor()
{
    if(!GetLocalInt(OBJECT_SELF,"PC_COUNT"))
        ResetSecretItem();
}



void main()
{
    object oPC  = GetExitingObject();

    int nCount  = GetLocalInt(OBJECT_SELF,"PC_COUNT")-1;

    if(nCount<1)
    {
        DeleteLocalInt(OBJECT_SELF,"PC_COUNT");
        object oDoor    = GetLocalObject(OBJECT_SELF, sSecretItemVarname);
        AssignCommand(  oDoor, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE) );
        SetIsSecretItemOpen(oDoor, FALSE);
        DelayCommand(9.0, RemoveDoor() );
    }
    else
    {
        SetLocalInt(OBJECT_SELF,"PC_COUNT",nCount);
    }
}
