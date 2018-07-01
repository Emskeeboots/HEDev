//::///////////////////////////////////////////////
//:: FileName md_gemsopen
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 6/15/2014 2:38:49 PM
//:://////////////////////////////////////////////
#include "nw_i0_plot"

void main()
{

    //determine who is interacting with this object
    object oPC = GetPCSpeaker();

    ActionPauseConversation();

    //open the linked container
    if (GetIsObjectValid(oPC)) {
        object myChild = GetLocalObject(OBJECT_SELF, "md_gemchild");

        if (GetIsObjectValid(myChild)) {

            AssignCommand(oPC, ActionInteractObject(myChild));
        }
    }
}
