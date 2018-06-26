// pw_mod_enter.nss
// Handle client entry for persistent world systems
// Called as the module from the main client enter script.

#include "_inc_pw"
#include "tb_inc_string"

void main() {
        object oPC = GetEnteringObject();
	
	// only run this script on player characters
	if (!GetIsPC(oPC) || GetIsDM(oPC))
		return;
	
	// ensure PCs are not in cutscenemode and are mortal
	SetCutsceneMode(oPC,FALSE);
	SetPlotFlag(oPC,FALSE);
	SetImmortal(oPC,FALSE);
	SetCommandable(TRUE, oPC);  // Conditions like fear should override this before
	// the player can do anything.
	
	// location to which we will jump the PC.
	location lDest;
	string sMSGAnnounceEnter;
	
        // Returning PCs ---
        if(!GetLocalInt(oPC, "NEW_PC_FLAG")) {
		sMSGAnnounceEnter   = YELLOWSERV+GetName(oPC)+" returns to play.";
		
		// PERSISTENT HP ---------------------------------------------------
		if(Data_GetPCHitPoints(oPC))
			DelayCommand(1.0, ExecuteScript("_ex_restorehp", oPC));
		else
			// act like we restored HP, and flag the PC as initialized
			SetLocalInt(oPC, "RESTORE_HP_INIT", TRUE);

		DelayCommand(0.2, pwLoadPCSpellsAndFeats(oPC));

	} else {
		// assume this is first time entry only
		sMSGAnnounceEnter   = YELLOWSERV+GetName(oPC)+" is a new character.";
		
                // Currently this just sets PC initialized.
		if(!NWNX_GetPCInitialized(oPC))
			AssignCommand(oPC, PCInitializedFirstTimeOnEntry());
		
		// Set this for new PCs.
		SetLocalInt(oPC, "RESTORE_HP_INIT", TRUE);
		// entry animation thingy
		// this needs work
		/*
		  SetCutsceneMode(oPC, TRUE);
		  AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM8));
		  DelayCommand(4.0, FadeToBlack(oPC, FADE_SPEED_SLOW));
		  //FadeToBlack(oPC, FADE_SPEED_SLOW);
		  SetCameraMode(oPC, CAMERA_MODE_CHASE_CAMERA);
		  lDest = GetLocation(GetWaypointByTag("dst_lobbyarrive"));
		  DelayCommand(7.0, AssignCommand(oPC, ActionJumpToLocation(lDest)));
		*/
		
	}

        string pcid = GetPCID(oPC);
        SetLocalObject(GetModule(), "PC_" + pcid, oPC);
        SetPersistentString(oPC, "PCID", pcid); // Write PCID to skin to make sure skin is present. 

	SetLocalString(oPC, "PC_FIRST_NAME", dlgTokenFirstName(oPC));
	SetLocalString(oPC, "PC_LAST_NAME", dlgTokenLastName(oPC));

	
	// Announce Arrival of PC
	SendMessageToAllDMs(sMSGAnnounceEnter);
	WriteTimestampedLogEntry(sMSGAnnounceEnter);

	// PREP FOR ALL ENTERING PCs
	AssignCommand(oPC, PCPreparesForEnteringHillsEdge());
}
