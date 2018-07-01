// deity_do_onlevel
// Handle the level up checks for the deity system
// This script is called with ExecuteScriptAndReturnInt();
// It returns X2_EXECUTE_SCRIPT_END (or 1 or TRUE) if the PC
// Failed to level. If it returns 0 normal onlevel handling can proceed.
// Caller is responsible for unleveling if this returns TRUE.

#include "x2_inc_switches"
#include "deity_onlevel"


void main () {
	object oPC = OBJECT_SELF;
	
	
	// Set the Deity_Not_Required local variable on a PC (to any nonzero integer)
	// to disable the cleric/deity checks for that PC.
	if ( GetLocalInt(oPC, "Deity_Not_Required"))
                return;
	
	// Is the level rejected?
	if (!CheckDeityRestrictions(oPC)) {
		SetExecutedScriptReturnValue(TRUE);
		return;
	} 
}
