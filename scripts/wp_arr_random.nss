// wp_arr_random.nss
// On arrival at this WP play a random animation, pause for a little while and then move on.

#include "aww_inc_walkway"

void restart() {

    // In case we did a looping animation
    ClearAllActions();
    aww_SetWalkPaused(FALSE);
    aww_WalkWayPoints();
}


void main()
{
    object oNPC = OBJECT_SELF;

    int nRand = Random(5);

    int nAnim;
    switch (nRand) {
        case 0: nAnim = ANIMATION_FIREFORGET_PAUSE_BORED; break;
        case 1: nAnim = ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD; break;
        case 2: nAnim = ANIMATION_LOOPING_LOOK_FAR; break;
        case 3: nAnim = ANIMATION_LOOPING_PAUSE_TIRED; break;
        case 4: nAnim = ANIMATION_FIREFORGET_HEAD_TURN_LEFT; break;
    }

    aww_SetWalkPaused(TRUE, oNPC);
    ClearAllActions();
    ActionPlayAnimation(nAnim, 1.0, 4.0);
    DelayCommand(5.0, AssignCommand(oNPC, restart()));

}
