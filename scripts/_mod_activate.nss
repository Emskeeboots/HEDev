//::///////////////////////////////////////////////
//:: v2_mod_activate
//:://////////////////////////////////////////////
/*
    Put into: OnItemActivate Event

    Modified XP2 OnActivate Script: x2_mod_def_act
    (c) 2003 Bioware Corp.

    Custom Modifications added:


*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller (2003-07-16)
//:: Modified: The Magus (2011 apr 10) for setting up Goblin Boy
//:://////////////////////////////////////////////

// Bioware Includes
#include "x2_inc_switches"

#include "_inc_constants"
#include "_inc_util"

void main()
{
     object oItem       = GetItemActivated();
     object oActivator  = GetItemActivator();
     string sTag        = GetTag(oItem);

// Bioware Begin ---------------------------------------------------------------
     // * Generic Item Script Execution Code
     // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
     // * it will execute a script that has the same name as the item's tag
     // * inside this script you can manage scripts for all events by checking against
     // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
    SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACTIVATE);
    string sScript;
    string sPre = GetTagPrefix(sTag);
    if(sPre!="")
        sScript = PREFIX + sPre;
    else
        sScript = GetUserDefinedItemEventScriptName(oItem);

    ExecuteScript(sScript, OBJECT_SELF);
    /*
    int nRet =   ExecuteScriptAndReturnInt(sScript,OBJECT_SELF);
    if (nRet == X2_EXECUTE_SCRIPT_END)
    {
        return;
    }
    */
// End Bioware -----------------------------------------------------------------
}
