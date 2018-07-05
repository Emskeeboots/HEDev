// tb_pc_hourly
// Called as the PC every hour - first HB of every hour.
#include "_inc_xp"
#include "an_rp_monitor"

void main(){
    object oPC = OBJECT_SELF;

/* ------------ RP XP TICKING ---------------------    */

    // Run script for determining if RP tick XP can be awarded.
    SetIsRolePlaying(oPC);

    //DelayCommand(0.0, ExecuteScript("_rp_monitor", oPC));
    // Call routine for awarding RP XP.
    if (GetIsRolePlaying(oPC)) {
        XPRewardRolePlay (oPC);
    }

    // Finally, clear chat counter so that it is reset every hour.
    SetLocalInt(oPC, "CHAT_COUNT", 0);
}

/* --------------------------------------------------  */

