//::///////////////////////////////////////////////
//:: _area_login
//:://////////////////////////////////////////////
/*
    Put into: OnEnter Event for Login Area
    This script handles the jump to saved area or start location


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2016 dec 19)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_data"

void main() {
    object oPC = GetEnteringObject();

    // only run this script on player characters
    if (!GetIsPC(oPC))
	    return;

    // location to which we will jump the PC.
    location lDest;

    // Returning PCs ---
    if(!GetLocalInt(oPC, "NEW_PC_FLAG")) {
         // PERSISTENT LOCATION ---------------------------------------------
        if(MODULE_DEVELOPMENT_MODE) {
		int nth = 0;
		object dev_wp;
		object temp = GetObjectByTag(WP_DEVELOPMENT, nth++);
		while(GetIsObjectValid(temp)) {
			dev_wp  = temp;
			temp    = GetObjectByTag(WP_DEVELOPMENT, nth++);
		}		
		lDest   = GetLocation(dev_wp);
        } else {
		// find last location in DB - will return a backup location if this one is invalid
		lDest   = Data_GetLocation("LAST", oPC);
		if(!GetIsObjectValid(GetAreaFromLocation(lDest)))
			lDest = Data_GetPCBackupLocation(OBJECT_SELF);
        }

        // in case PC is sent to default start - provide warning
        if(lDest==GetLocation(GetWaypointByTag(WP_DEFAULT_START))) {
		string sMsg = RED+"ERR "+YELLOW+GetName(oPC)+PINK+" has no persistent location stored, so they well be sent on to "+YELLOW+GetName(GetAreaFromLocation(lDest))+PINK+".";

		SendMessageToAllDMs(sMsg);
		WriteTimestampedLogEntry(sMsg);
	}

	dblvlstr(DEBUGLEVEL_PW, "LOGIN: " + GetName(oPC) + " sent to " + GetName(GetAreaFromLocation(lDest))); 
         // Send PC on from LOGIN area
         // TODO - should be forcejump 
	DelayCommand(0.3, AssignCommand(oPC, ActionJumpToLocation(lDest) ) );
    } else {
	    // nothing else to do here.
	    DelayCommand(5.0, DeleteLocalInt(oPC, "NEW_PC_FLAG"));
    }
}
