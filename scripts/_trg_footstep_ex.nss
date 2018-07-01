//::///////////////////////////////////////////////
//:: _trg_footstep_ex
//:://////////////////////////////////////////////
/*
    intended for use in a trigger's onexit event
    restores default footfalls on trigger ext

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 apr 5)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_terrain"

void main()
{
 object oCreature = GetExitingObject();

 RestoreFootsteps(oCreature);

}
