//::///////////////////////////////////////////////
//:: do_shoulder
//:://////////////////////////////////////////////
/*
    Modified from qit_hshoulder001 by john hawkins (project q shoulders)
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
    int bShoulder       = GetSkinInt(oPC, "VFX_TYPE_"+IntToString(BODY_EFFECTS_PET));

    int nShoulder       = GetLocalInt(oItem, "VFX_INDEX");

    if(!nShoulder)
    {
        nShoulder = VFX_MASK_PLAIN_BLACK;
    }

    // if wearing a pet... remove it
    if(bShoulder)
    {
        SetCommandable(TRUE, oPC);
        AssignCommand(oPC, PlaySound(sSound) );
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD) ) ;

        RemovePersonalVFX(oPC, BODY_EFFECTS_PET);

    }
    // if wearing a helmet... we can not wear a shoulder
    else if(GetIsObjectValid(oHelm))
    {
        FloatingTextStringOnCreature(RED+"First remove your helmet.", oPC, FALSE);
    }
    // if we get this far... we can put on a shoulder
    else
    {
         // wear shoulder
        SetCommandable(TRUE, oPC);
        AssignCommand(oPC, PlaySound(sSound) );
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD) ) ;
        ApplyPersonalVFX(oPC, BODY_EFFECTS_PET, nShoulder);
    }

 }
 else if(nEvent == X2_ITEM_EVENT_UNACQUIRE)
 {
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
    string sSound   = "it_generictiny";
    object oHelm    = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    int bShoulder       = GetSkinInt(oPC, "VFX_TYPE_"+IntToString(BODY_EFFECTS_PET));

    int nShoulder       = GetLocalInt(oItem, "VFX_INDEX");

    if(!nShoulder)
    {
        nShoulder = VFX_MASK_PLAIN_BLACK;
    }

    if(bShoulder) // wearing shoulder?
    {
        RemovePersonalVFX(oPC, BODY_EFFECTS_PET);
    }
 }
}
