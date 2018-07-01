//::///////////////////////////////////////////////
//:: _area_exit
//:://////////////////////////////////////////////
/*
    Put into: OnExit Event for Area


    Custom Modifications added:


*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 jan 4)
//:: Modified:
//:://////////////////////////////////////////////


//#include "v2_inc_housing"
#include "_inc_constants"
#include "_inc_util"

// NESS
//#include "spawn_functions"

void main()
{
    object oPC              = GetExitingObject();
    if(!GetIsObjectValid(oPC))
        return;
    object oPCScrier        = GetLocalObject(oPC, "SCRY_PC");
    int bPC = GetIsPC(oPC);
    string  sOnExitExecute  = GetLocalString (OBJECT_SELF, "AREA_SCRIPT_EXIT");
    int nPCs;

    // only do this for Human Controlled Characters
    if (bPC ||  GetIsPC(oPCScrier)) {
        nPCs    = GetLocalInt(OBJECT_SELF, "AREA_PC_COUNT")-1;
        if(nPCs<1)
            nPCs=0;
        // NESS pseudo heartbeat -- PCs or PCScriers only -- File: spawn_functions Fnc: Spawn_OnAreaEnter()
        if ( !GetLocalInt(OBJECT_SELF, "AREA_NESS_DISABLE") ) {
		ExecuteScript("spawn_smpl_onext", OBJECT_SELF);
		//Spawn_OnAreaExit();
	} else {
            SetLocalInt(OBJECT_SELF, "AREA_PC_COUNT", nPCs);// Maintain PC Count even when NESS disabled
	}
        /*
        // Housing System
        string sHouseTag    = GetLocalString(OBJECT_SELF, "HOUSE");
        if(sHouseTag!="")
            HousingOnAreaExit(sHouseTag, oPC);
        */
        // saving data
        //if(bPC && bGameOn)
        //    SavePCData(oPC);

    }

    // Any valid object will stimulate object fade
    ObjectsFade(OBJECT_SELF);

    // Run custom OnExit script on all exiting creatures
    if (sOnExitExecute != "")
    {
        SetLocalObject(oPC,"EXITING_AREA", OBJECT_SELF);
        ExecuteScript(sOnExitExecute, oPC);
        DeleteLocalObject(oPC,"EXITING_AREA");
    }

    DeleteLocalString(oPC,"IN_AREA"); // PC is no longer in an area
}
