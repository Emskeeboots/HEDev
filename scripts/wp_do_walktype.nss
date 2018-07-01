//wp_do_walktype.nss
// Use as a WP arrival script (Set as AWW_WP_SCRIPT on the waypoint)
// to set the walker's walktype to the value specified in
// AWW_WP_WALKTYPE variable. Use the AWW_WALK_TYPE_* constants.

#include "aww_inc_walkway"

void main() {
        object oNPC = OBJECT_SELF;

        object oWP = GetLocalObject(oNPC, "AWW_CURWP");
        int nType = GetLocalInt(oWP, "AWW_WP_WALK_TYPE");

        if (nType < AWW_WALK_TYPE_NORMAL || nType > AWW_WALK_TYPE_CIRCREV)
            return;

        aww_debug("Setting walk type to " + IntToString(nType));

        switch (nType) {
            case  AWW_WALK_TYPE_NORMAL:
                    SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, FALSE);
                    SetWalkCondition(AWW_WALK_FLAG_RANDOM, FALSE);
                    SetWalkCondition(AWW_WALK_FLAG_CIRCREV, FALSE);
                    break;
            case AWW_WALK_TYPE_CIRCULAR:
                    SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, TRUE);
                    SetWalkCondition(AWW_WALK_FLAG_RANDOM, FALSE);
                    SetWalkCondition(AWW_WALK_FLAG_CIRCREV, FALSE);
                    break;
            case AWW_WALK_TYPE_RANDOM:
                    SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, FALSE);
                    SetWalkCondition(AWW_WALK_FLAG_RANDOM, TRUE);
                    SetWalkCondition(AWW_WALK_FLAG_CIRCREV, FALSE);
                    break;
            case AWW_WALK_TYPE_CIRCREV:
                   SetWalkCondition(AWW_WALK_FLAG_CIRCULAR, FALSE);
                   SetWalkCondition(AWW_WALK_FLAG_RANDOM, FALSE);
                   SetWalkCondition(AWW_WALK_FLAG_CIRCREV, TRUE);
                   break;
           // This is not really needed...
           default:
                return;
        }
        aww_WalkWayPoints();
}
