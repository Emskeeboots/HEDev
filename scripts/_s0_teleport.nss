//::///////////////////////////////////////////////
//:: _s0_teleport
//:://////////////////////////////////////////////
/*
    Spell Script for Dimension Hop and teleport

    Transports the caster to the targeted space
    Original creator of this script is unknown to me. This script adapted from Vives PW.
*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2011 oct 16) (taken from Vives)
//:: Modified:  The Magus (2013 jan 24) adapted for Magus Spell Focus
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

#include "_inc_spells"


void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    // Disable in areas with area "AREA_NO_TELEPORT" set
    if ( GetLocalInt(GetArea(OBJECT_SELF), "AREA_NO_TELEPORT") )
    {
        SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILED. You cannot teleport in this area.");
        return;
    }

    location lDest  = GetSpellTargetLocation();
    int spell_id    = GetSpellId();

    // SPECIAL TARGETTING - accepts "Spell Focus"- see _s2_marktarget and spellfocus_inc
    if(GetLocalInt(OBJECT_SELF, SPELLFOCUS_USE))
    {
        object oFocus   = GetLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        //garbage collection
        DeleteLocalInt(OBJECT_SELF, SPELLFOCUS_USE);
        DeleteLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);


        // Focus Data
        int nFocusType  = GetLocalInt(oFocus, SPELLFOCUS_TYPE);
        if(nFocusType==1)
            lDest       = GetSpellFocusLocation(oFocus);
        else if(nFocusType==2 || nFocusType==3)
            lDest       = GetLocation(GetLocalObject(oFocus, SPELLFOCUS_CREATURE));

        object oAreaAlt = GetAreaFromLocation(lDest);
        if(     GetArea(OBJECT_SELF)==oAreaAlt
            ||  spell_id==SPELL_TELEPORT
          )
        {
            // SUCCESS !
            //SendMessageToPC(OBJECT_SELF, DMBLUE+"Success: Portal created in alternate location.");
            if(SPELLFOCUS_ONE_USE)
                DestroyObject(oFocus, 0.5);
        }
        else
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: Destination must be in the same area.");
            return;
        }
    }
    // END SPECIAL TARGETTING --------------------------------------------------

    SetLocalLocation(OBJECT_SELF,"DESTINATION",lDest);
    SetLocalObject(OBJECT_SELF,"PORTAL",OBJECT_SELF);
    ExecuteScript("_s1_dimdo_jump",OBJECT_SELF);
}
