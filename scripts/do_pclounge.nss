//::///////////////////////////////////////////////
//:: do_pclounge
//:://////////////////////////////////////////////
/*
    script for lounge command
*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2011 nov 5)
//:: Modified:  Henesua (2013 oct 21) modifications for Vives
//:://////////////////////////////////////////////

#include "x0_i0_enemy"
#include "_inc_constants"
#include "_inc_util"
#include "_inc_data"

void StripOOCGear(object oPC)
{
    object oItem= GetFirstItemInInventory(oPC);
    int bOnce   = FALSE;
    int nIt     = 1;

    while (GetIsObjectValid(oItem) && nIt < 100)
    {
        if(GetLocalInt(oItem,"OUT_OF_CHARACTER"))
        {
            if(!bOnce)
            {
                bOnce = TRUE;
                FloatingTextStringOnCreature(RED+"Items that belong in the lounge will be stripped from your inventory!", oPC, FALSE);
            }
            DestroyObject(oItem);
        }
        GetNextItemInInventory(oPC);
        ++nIt;
    }
}

void main()
{
    int nState = GetIsObjectValid( GetLocalObject(OBJECT_SELF, "LYCANTHROPY_BEAST") );
    if(!nState)
        nState = GetIsPossessedFamiliar(OBJECT_SELF);
    if(!nState)
        nState = GetLocalInt(OBJECT_SELF, "SCRYING");

    object oPC = OBJECT_SELF;
    string sTag= GetTag(GetArea(OBJECT_SELF));

    if(NBDE_GetCampaignInt(CAMPAIGN_NAME, "isolation", OBJECT_SELF))
    {
        FloatingTextStringOnCreature(RED+"FAIL: That command does not function for illegal characters!", OBJECT_SELF, FALSE);
        return;
    }
    else if(GetIsInCombat(OBJECT_SELF))
    {
        FloatingTextStringOnCreature(RED+"FAIL: You may not use the "+Q+YELLOW+"/lounge"+RED+Q+" command in combat!", OBJECT_SELF, FALSE);
        return;
    }
    else if(GetArea(GetNearestEnemy(OBJECT_SELF))==GetArea(OBJECT_SELF))
    {
        FloatingTextStringOnCreature(RED+"FAIL: You may not use the "+Q+YELLOW+"/lounge"+RED+Q+" command near hostiles!", OBJECT_SELF, FALSE);
        return;
    }
    else if(nState)
    {
        FloatingTextStringOnCreature(RED+"FAIL: You may not use the "+Q+YELLOW+"/lounge"+RED+Q+" command in your present state!", OBJECT_SELF, FALSE);
        return;
    }
    else if(sTag=="ooc_lounge")
    {
        ClearAllActions(TRUE);
        // strip of ooc items
        StripOOCGear(OBJECT_SELF);

        // return to last location
        effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);
        DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF));
        location lLast = Data_GetLocation("LAST", OBJECT_SELF);
        // area of location is invalid so get a trusted backup location
        if(!GetIsObjectValid(GetAreaFromLocation(lLast)))
                 lLast = Data_GetPCBackupLocation(OBJECT_SELF);

        DelayCommand(0.25, ActionJumpToLocation(lLast));
        DelayCommand(0.5, ExecuteScript("_ex_restorehp", oPC));
    }
    else if(IsOOC(OBJECT_SELF))
    {
        FloatingTextStringOnCreature(RED+"FAIL: You may not use the "+Q+YELLOW+"/lounge"+RED+Q+" command in this area!", OBJECT_SELF, FALSE);
        return;
    }
    else
    {
        Data_SavePC(OBJECT_SELF, TRUE); // commit data and position

        effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);
        DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF));
        object oDest = GetWaypointByTag("dst_ooclounge");
        DelayCommand(1.00, ActionJumpToObject(oDest,FALSE));
    }
    /*
    else
    {
        FloatingTextStringOnCreature(RED+"FAIL: You may not use the "+QUOTE+YELLOW+"/lounge"+RED+QUOTE+" command at this time. Try again later.", OBJECT_SELF, FALSE);
        return;
    }
    */
}
