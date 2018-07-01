//::///////////////////////////////////////////////
//:: do_Crown
//:://////////////////////////////////////////////
/*
    Modified from qit_hCrown001 by john hawkins (project q Crowns)
        to use v2_inc_vfx
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2010 nov 3)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_vfx"
#include "_inc_color"

#include "x2_inc_switches"

void main()
{

    int nEvent      = GetUserDefinedItemEventNumber();

 if (nEvent ==X2_ITEM_EVENT_ACTIVATE)
 {
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
    string sSound   = "it_generictiny";
    object oHelm    = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    int bCrown       = GetSkinInt(oPC, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_CROWN));

    int nCrown       = GetLocalInt(oItem, "VFX_INDEX");

    if(!nCrown)
    {
        nCrown = VFX_MASK_PLAIN_BLACK;
    }

    // if wearing a Crown... remove it
    if(bCrown)
    {
        SetCommandable(TRUE, oPC);
        AssignCommand(oPC, PlaySound(sSound) );
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD) ) ;

        RemovePersonalVFX(oPC, HEAD_EFFECTS_CROWN);

    }
    // if wearing a helmet... we can not wear a Crown
    else if(GetIsObjectValid(oHelm))
    {
        FloatingTextStringOnCreature(RED+"First remove your helmet.", oPC, FALSE);
    }
    // if we get this far... we can put on a Crown
    else
    {
         // wear Crown
        SetCommandable(TRUE, oPC);
        AssignCommand(oPC, PlaySound(sSound) );
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD) ) ;
        ApplyPersonalVFX(oPC, HEAD_EFFECTS_CROWN, nCrown);
    }

 }
 else if(nEvent == X2_ITEM_EVENT_UNACQUIRE)
 {
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
    string sSound   = "it_generictiny";
    object oHelm    = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    int bCrown       = GetSkinInt(oPC, "VFX_TYPE_"+IntToString(HEAD_EFFECTS_CROWN));

    int nCrown       = GetLocalInt(oItem, "VFX_INDEX");

    if(!nCrown)
    {
        nCrown = VFX_MASK_PLAIN_BLACK;
    }

    if(bCrown) // wearing Crown?
    {
        RemovePersonalVFX(oPC, HEAD_EFFECTS_CROWN);
    }
 }
}
