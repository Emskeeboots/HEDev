// wp_arr_dusk.nss
// On arrival at this WP play a random animation, pause for a little while and then move on.

#include "aww_inc_walkway"
int nAnim = ANIMATION_LOOPING_PAUSE_TIRED;

void checkForNight(object oNPC) {

    // Just in case...
    if (!GetIsObjectValid(oNPC))
        return;

    // not dusk so get moving again.
    if (!GetIsDusk()) {
        // In case we did a looping animation
        ClearAllActions();

        aww_SetWalkPaused(FALSE);
        aww_WalkWayPoints();
        return;
    }

    ActionPlayAnimation(nAnim, 1.0, 6.0);
    // Still dusk so check again in a bit
    DelayCommand(20.0, AssignCommand(oNPC, checkForNight(oNPC)));
}



void main()
{
    object oNPC = OBJECT_SELF;

    // if not dusk just keep going. This is done this way
    // in case we get here at dawn so we don't wait all day.
    // only wait if it is actually dusk.
    if (!GetIsDusk())
        return;

    aww_SetWalkPaused(TRUE, oNPC);
    ClearAllActions();
    ActionPlayAnimation(nAnim, 1.0, 6.0);
    DelayCommand(20.0, AssignCommand(oNPC, checkForNight(oNPC)));

}
