//::///////////////////////////////////////////////
//:: _mod_levelup
//:://////////////////////////////////////////////
/*
    Use: OnLevelUp Module Event

    // See _inc_pets for this code...
    THE MAGUS' INNOCUOUS FAMILIARS

    On Level Up:
        - familiar's persistent damage is cleared
        - familiar's death flag is cleared
        - if the familiar was changed or was dead, reinitialize the familiar
    //

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2013 jan 4)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_switches"


void ResetLevel(object oPC) {
    int iXP = GetXP(oPC);           // XP to restore to.
    int iLevel = GetHitDice(oPC);   // Level to drop below.
    int iXPLastLevel = (iLevel * (iLevel - 1)) / 2 * 1000 - 1;  // XP for current level minus 1.

    // Remove the most recent leveling, and restore it.
    SetXP(oPC, iXPLastLevel);
    DelayCommand(0.5, SetXP(oPC, iXP)); // Delayed so the GUI reacts properly.
}

void main()
{
    object  oPC =   GetPCLevellingUp(); // The PC who just leveled up.

    /// Check this ...
    //if (ExecuteScriptAndReturnInt("70_mod_levelup", OBJECT_SELF)) {
    //    SendMessageToPC(oPC, "LEVEL UP FAILED - Character has too many or invalid feats.");
    //    ResetLevel(oPC);
    //    return;
    //}
 
    // Call the deity code and make sure the level up is okay
    if (ExecuteScriptAndReturnInt("deity_do_onlevel", oPC)) {
             // deity onlevel provides feedback.
            //SendMessageToPC(oPC, "LEVEL UP FAILED - DIETY");
            ResetLevel(oPC);
            return;
    }

    // THE MAGUS' INNOCUOUS FAMILIARS ------------------------------------------
    // this should only be run IF it is determined the levelup will be successful
    // IF you have a check in this script which prevents levelup,
    // THEN place this code last, and only run it if the LevelUp is deemed to be successful
    SetLocalInt(oPC, "pest_tmp_op", 1);
    ExecuteScript("pets_do_op", oPC);
    // END THE MAGUS' INNOCUOUS FAMILIARS --------------------------------------  

    ExecuteScript("deity_post_level", oPC);
}
