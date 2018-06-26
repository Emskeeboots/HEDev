// wp_arr_despawn
// Despawn the the arriving NPC at this waypoint using NESS.
// Put this on a WP in the variable AWW_WP_SCRIPT

#include "aww_inc_walkway"


void main()
{
     object oNPC = OBJECT_SELF; // these are run as the NPC doing the walking.

    // There's no need to include anything to do this, it's just setting a named
    // variable.
     ActionDoCommand(SetLocalInt(oNPC, "ForceDespawn", TRUE));
     aww_SetWalkPaused(TRUE, oNPC); // pause to keep him from starting to walk back
                                   // while waiting to be despawned.
}
