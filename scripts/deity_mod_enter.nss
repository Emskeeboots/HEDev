///////////////////////////////////////////////////////////////////////////////
// A module's OnClientEnter event handler.
//
// A framework into which cleric/deity restrictions and favored weapons have
// been added. This should be suitable for adding other routines, including
// something to handle new PC's who are already in violation of the deity rules.
// (I don't know what should be done with these PC's. Sent to isolation?)
// (Favored weapons have been commented out.)
//
// For a simpler, minimal function that implements the deity restrictions,
// see on_cliententer0.
//
// Embellish as needed, but you probably want to rename this file. (At least
// drop the trailing digit.)
///////////////////////////////////////////////////////////////////////////////

#include "tb_inc_deity"

void main() {
        object oPC  = GetEnteringObject();  // The entering PC.
        int bNewPC  = GetLocalInt(oPC, "NEW_PC_FLAG");


    // DM's have a much shorter list of initializations.
        if (GetIsDM(oPC)) {
                if (bNewPC)
                        StandardizeDeityName(oPC);
                return;
        }
    
        // Is this PC new to this world?
        if (bNewPC) {
	    
	        // Before checking oPC, make sure oPC's deity is in standard form.
                StandardizeDeityName(oPC);

                int nDeity = GetDeityIndex(oPC);
            
                // No or invalid deity - 
                if (nDeity < 0) {
                        DelayCommand(4.0, SendMessageToPC(oPC, "You either follow no deity or a deity not of this realm. " 
                                + "You will want to select a deity to follow."
                                + "You will be able to do that in the lobby area."));
                } else if (!CheckDeityRestrictions(oPC)) {
		    // PC cannot serve or follow otherwise valid deity - clear it and make her choose a new one.
                        DelayCommand(4.0, SendMessageToPC(oPC, "You are not able to serve your currently selected deity. " 
                                + "You will want to select a new deity to serve."
                                + "You will be able to do that in the lobby area."));
                        SetDeity(oPC, "");

		    // For one thing, they will not be able to level if
		    // DeityRestrictionsPostLevel(oPC);
		    // is not called.
                } else {
                        // This initializes all the variables and sub systems
                        deitySetDeity(oPC, GetDeity(oPC));
		}

        } else {
	        // Initialize prayer tracking variables from persistent data.
                deityRestoreSavedData(oPC);
	        // In case the server's been reset, the PostLevel initializations need to be done.
                DeityRestrictionsPostLevel(oPC); 
                // Initialize Favored Weapons. (Done for all PC's in case the server reset.)
                DeityWeaponsPostLevel(oPC);
        }
}

