// wp_arr_choose.nss
// On arrival the NPC chooses among configured vtags randomly
// Vtags are each specified on the WP with AWW_CHOOSE_PATH_0 ...
// Number must be contiguously defined and each is given equal weight.
// You my specify the same vtag more than once to modify the odds.
// Use the word "VTAG_SAME" for a choice to have the NPC just continue with
// the current tag.
//

#include "aww_inc_walkway"

void main() {
        object oNPC = OBJECT_SELF; // wp arrival scripts are excuted as the NPC. This just makes
                            // that clear and is less to type...

        object oWP = GetLocalObject(oNPC, "AWW_CURWP");
        int nCount = 0;
        int nIdx = 0;

        string sCur = GetLocalString(oWP, "AWW_CHOOSE_PATH_0");

        if (sCur == "") {
               aww_debug("Waypoint arrival choose - nothing to choose from at " + GetTag(oWP));
               return;
        }

        while (sCur != "") {
                nCount ++;
                nIdx ++;
                sCur = GetLocalString(oWP, "AWW_CHOOSE_PATH_" + IntToString(nIdx));
        }


        int nRand = Random(nCount);
        sCur = GetLocalString(oWP, "AWW_CHOOSE_PATH_" + IntToString(nRand));

       /* SendMessageToPC(GetFirstPC(), "wp_choose of " + IntToString(nCount) + " got " + IntToString(nRand)
        + " = " + sCur);
       */
        // Nothing todo here
        if (sCur == "VTAG_SAME") {
                return ;
        }

        aww_SetVTag(oNPC, sCur);
        aww_WalkWayPoints(); // call this here to make the NPC re-evaluate where to go
                                 // now that we've changed his vtag.
}
