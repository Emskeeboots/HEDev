// deity_post_level
// Handle post level clean up for PC when successfully leveling.
// Called by module on level handler after all checks pass.
// Executed as the PC.

#include "deity_onlevel"

void main () {
	object oPC = OBJECT_SELF;
	
	// Prepare for possible future restrictions.
	DeityRestrictionsPostLevel(oPC);	
	// Initialize Favored Weapons.
	DeityWeaponsPostLevel(oPC);
}
