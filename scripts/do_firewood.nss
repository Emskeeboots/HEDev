//::///////////////////////////////////////////////
//:: firewood
//:://////////////////////////////////////////////
/*
    tag based script for using firewood / building a fire
*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2011 nov 3)
//:: Modified:  The Magus (2012 oct 24) fires now have two placeables. one is visible and usable, the other radiates late and has the sound effect and HB
//:://////////////////////////////////////////////

#include "x2_inc_switches"

#include "camp_include"

void main()
{
    int nEvent          = GetUserDefinedItemEventNumber();
    if (nEvent ==X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC          = GetItemActivator();
        object oFirewood    = GetItemActivated();
        location lCampsite  = GetItemActivatedTargetLocation();

        if(GetDistanceBetweenLocations(lCampsite, GetLocation(oPC))>2.0)
            AssignCommand(oPC, CamperMovesToCampsite(lCampsite, oFirewood, TRUE));
        else
            AssignCommand(oPC, CamperCreatesCampsite(lCampsite, oFirewood, TRUE));

    }
}
