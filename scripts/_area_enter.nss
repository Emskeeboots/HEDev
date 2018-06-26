//::///////////////////////////////////////////////
//:: _area_enter
//:://////////////////////////////////////////////
/*
    USE: OnEnter Event for Area


    // LOCAL AREA VARIABLES used to control how the area works

    VARIABLE ON AREA

    string AREA_DESCRIPTION
    string AREA_DESCRIPTION_FIRST
    string AREA_DESCRIPTION_NIGHT

    string AREA_SCRIPT_ENTER
    string AREA_SCRIPT_EXIT

    int AREA_XP_DISCOVERY
    int AREA_NESS_DISABLE
    int AREA_MAP_EXPLORE
    int AREA_MAP_HIDE
    int AREA_TRACKING
    int AREA_NOTELEPORT

*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 jan 4)
//:: Modified:
//:://////////////////////////////////////////////

//#include "v2_inc_housing"
#include "_inc_vfx"
#include "_inc_data"
#include "_inc_util"
#include "_inc_xp"
#include "_inc_constants"


// NESS
//#include "spawn_functions"

void main()
{
    object  oPC             = GetEnteringObject();
    if(!GetIsObjectValid(oPC)){ return; }

    int bPC                 = GetIsPC(oPC);
    object oPCScrier        = GetLocalObject(oPC, "SCRY_PC");



    if (!GetLocalInt(OBJECT_SELF, "area_initialized")) {
        ExecuteScript("_area_init", OBJECT_SELF);
        SetLocalInt(OBJECT_SELF, "area_initialize", 1);
    }
    // BEGIN PCs, Possessed Familiars, and DMs ---------------------------------
    if (bPC || GetIsPC(oPCScrier)) {

        // COUNT PCS IN AREA
        int nPCs    = GetLocalInt(OBJECT_SELF, "AREA_PC_COUNT")+1;

        // NESS Spawns -- only works for PCs or PCScriers
        if ( GetLocalInt(OBJECT_SELF, "AREA_NESS_DISABLE") )
            SetLocalInt(OBJECT_SELF, "AREA_PC_COUNT", nPCs); // Maintain PC count even if NESS is disabled
        else {
		//Spawn_OnAreaEnter(); // File: spawn_functions  -- init NESS pseudo heartbeat
		ExecuteScript("spawn_smpl_onent", OBJECT_SELF);
	}

        int iAreaEntryCount;
        string sAreaID      = GetIDFromArea();
        string sAreaEntryTag= TAG_ENTRY + "AREA_"+sAreaID;
        // BEGIN OOC EXCLUSION
        if(!IsOOC(oPC))
        {

		iAreaEntryCount = GetPersistentInt(oPC, sAreaEntryTag) + 1;
		SetPersistentInt(oPC, sAreaEntryTag, iAreaEntryCount);
		//SendMessageToPC(oPC, "Got entry count = " + IntToString(iAreaEntryCount));

            // GIVE XP REWARD
            if(iAreaEntryCount==1) // only on first entry in area
            {
		    int nXp = GetLocalInt(OBJECT_SELF, "AREA_XP_DISCOVERY");
		    if (nXp > 0) {
			    DelayCommand(0.2,XPRewardByType( "AREA_"+sAreaID, oPC, nXp, XP_TYPE_AREA));
		    }
            }
        }// END OOC EXCLUSION


        // GIVE AREA DESCRIPTION
        //DelayCommand(0.1, SetCommandable(TRUE, oPC));
        DelayCommand(0.1, SendMessageToPC(oPC, GREEN+GetName(OBJECT_SELF)) );
        DelayCommand(0.11, SendMessageToPC(oPC, LIME+"   "+AreaGetDescription(oPC,OBJECT_SELF,TRUE,iAreaEntryCount)) );

        // If music is prepared for the area, and not currently playing: play music
        /*
        if(     GetLocalInt(OBJECT_SELF, "SONG_ID_01")
            &&  nPCs==1
            &&  !GetLocalInt(OBJECT_SELF, "SONG_ID_CURRENT")
          )
            ExecuteScript("_ex_music", OBJECT_SELF);
        */

        // If in Housing, Initialize oPC and the Housing
        /*
        string sHousingTag          = GetLocalString(OBJECT_SELF, "HOUSE");
        if(sHousingTag!="")
            HousingOnAreaEnter(sHousingTag,oPC);

        // If tidal action in area, set it up
        if(GetLocalInt(OBJECT_SELF, "TIDE"))
            AreaTideUpdate(GetTimeCumulative());
        */
        // Tile Magic
        DoAreaTilesetMagic(GetLocalInt(OBJECT_SELF,"TILEMAGIC_RESET"));


        // REVEAL MINI_MAP?
        if(     GetLocalInt(OBJECT_SELF, "AREA_MAP_EXPLORE")
            ||  AreaGetIsMappedByPC(oPC)
          )
            ExploreAreaForPlayer(OBJECT_SELF, oPC); // reveal map
        // HIDE MINI_MAP?
        else if(GetLocalInt(OBJECT_SELF, "AREA_MAP_HIDE"))
            ExploreAreaForPlayer(OBJECT_SELF, oPC, FALSE); // hide map

        // BEGIN DM ONLY
        if( GetIsDM(oPC) )
        {
            ExploreAreaForPlayer(OBJECT_SELF, oPC);
        }// END DM ONLY
        // BEGIN DM Exclusion
        else
        {
            // PCs and Familiars
            // ensure PCs are not in cutscenemode and are mortal
            SetCutsceneMode(oPC,FALSE);
            SetPlotFlag(oPC,FALSE);
            SetImmortal(oPC,FALSE);

            // BEGIN Familiar Exclusion
            /*
            if( !GetIsPossessedFamiliar(oPC) )
            {

            }// END Familiar Exclusion
            */
        }// END DM Exclusion
    } // END PCs, Possessed Familiars, and DMs ---------------------------------


    if(GetObjectType(oPC)==OBJECT_TYPE_CREATURE)
    {
        // DEBUG
        if(MODULE_DEBUG_MODE)SendMessageToPC(oPC,"ENTERING AREA"+ObjectToString(OBJECT_SELF));

        // Run custom OnEnter script on all entering Creatures
        string  sOnEnterExecute = GetLocalString (OBJECT_SELF, "AREA_SCRIPT_ENTER");
        if (sOnEnterExecute != "")
        {
            SetLocalObject(oPC, "ENTERING_AREA", OBJECT_SELF);
            ExecuteScript(sOnEnterExecute, oPC);
            DeleteLocalObject(oPC, "ENTERING_AREA");
        }
    }

    SetLocalString(oPC,"IN_AREA",ObjectToString(OBJECT_SELF)); // tracking whether Area Enter has finished and PC is in an area
}
