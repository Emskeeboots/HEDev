//::///////////////////////////////////////////////
//:: _mod_enter
//:://////////////////////////////////////////////
/*
    Use: OnEnter Module Event

    For the complete client enter system also see -- pw_mod_enter etc

  *SECURITY
    - this checks cdkey, playername etc... to determine if they are a valid match, if not --> BOOT
  *PETS
    MasterInitializePets()
    --> calls functions based on The Magus' Innocuous Familiars
        which initializes PCs that have familiars and animal companions. See MasterInitializeFamiliarData()

*/
//:://////////////////////////////////////////////
//:: Created:   Deva B. Winblood Dec 30th, 2007
//:: Modified:  April 21th, 2008
//:://////////////////////////////////////////////
//:: Modified:  henesua (2015 dec 30) PW setup

// HORSES
#include "x3_inc_horse"
#include "_inc_pw"

// CONSTANTS
const string REENTRY_FLAG   = "X3_MOD_ENTER_DONE";

void clearEntering(object oPC) {
        WriteTimestampedLogEntry("Clearing entry flag for " + GetName(oPC));
        DeleteLocalInt(oPC, "PC_IS_ENTERING");
        SetLocalInt(oPC, "PC_ENTERED", TRUE);
}

void main() {
    object oPC      = GetEnteringObject();
    int bNewPC  = GetXP(oPC) == 0;      // Test for a new PC.
    if (bNewPC) {
                WriteTimestampedLogEntry("New PC entry for " + GetName(oPC));
                SetLocalInt(oPC, "NEW_PC_FLAG", 1);
        }
    SetLocalInt(oPC, "IS_PC", 1);// This tracks that the object is a PC for GetIsPCSafe.
        SetLocalInt(oPC, "PC_IS_ENTERING", 1);

        if(GetIsDM(oPC)) {
        SetLocalInt(oPC, "IS_DM", 1);
    }

        SendMessageToPC(oPC, "Processing Client enter");
        WriteTimestampedLogEntry("Processng Client enter for " + GetName(oPC));

    // Check if PC is allowed to enter - this also sets PC ID
    if (!pw_doEntryCheck(oPC)) {
                // NWNEE
        BootPC(oPC, GetLocalString(oPC, "BOOTED_REASON"));
        return;
    }

    // DECLARE VARIABLES -------------------------------------------------------
    object oMod     = GetModule();
    int bReEntry    = GetLocalInt(oPC, REENTRY_FLAG);// Re-entry (between server resets) detection.
        // END VARIABLE DECLATIONS -------------------------------------------------

        dblvlstr(DEBUGLEVEL_PW,  "Client enter : PCID = " + GetPCID(oPC) + " stored HP = " + IntToString(Data_GetPCHitPoints(oPC)));
    WriteTimestampedLogEntry("Player " + GetLocalString(oPC, "PLAYER_ID") + " " +  GetPCPlayerName(oPC) + " CDKEY = " + GetPCPublicCDKey(oPC));
    WriteTimestampedLogEntry("Characrer " + GetName(oPC) + " ID " + GetPCID(oPC) + " logging in.");


    ExecuteScript("pw_mod_enter", oMod);

    // INTRODUCTORY MESSAGE ----------------------------------------------------
    SendMessageToPC(oPC, LIME+"Welcome to " + GREEN + GetModuleName() +"!");
    SendMessageToPC(oPC, LIME+"      "+GetDescription(oMod));
    SendMessageToPC(oPC, " ");
    // END INTRODUCTION --------------------------------------------------------


    // TODO - this wants to be ExecuteScripted...
    // START HORSE STUFF -------------------------------------------------------
    ExecuteScript("x3_mod_pre_enter",OBJECT_SELF); // Override for other skin systems
    if ((GetIsPC(oPC)||GetIsDM(oPC))&&!GetHasFeat(FEAT_HORSE_MENU,oPC))
    { // add horse menu
        HorseAddHorseMenu(oPC);
        if (GetLocalInt(oMod,"X3_ENABLE_MOUNT_DB"))
        { // restore PC horse status from database
            DelayCommand(2.0,HorseReloadFromDatabase(oPC,X3_HORSE_DATABASE));
        } // restore PC horse status from database
    } // add horse menu
    if (GetIsPC(oPC) && !GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))//1.71: fix for changing polymorph appearance
    { // more details
        // restore appearance in case you export your character in mounted form, etc.
        if (!GetSkinInt(oPC,"bX3_IS_MOUNTED")) HorseIfNotDefaultAppearanceChange(oPC);
        // pre-cache horse animations for player as attaching a tail to the model
        HorsePreloadAnimations(oPC);
        DelayCommand(3.0,HorseRestoreHenchmenLocations(oPC));
    } // more details
    // END HORSE STUFF ---------------------------------------------------------


    // PETS ------------------------------------------
    DeleteLocalInt(oPC, "pets_tmp_op");   // Op 0 paranoia
    ExecuteScript("pets_do_op", oPC);
    // END PETS --------------------------------------

    // Pantheon
    ExecuteScript("deity_mod_enter", OBJECT_SELF);

    // racial movement
    ExecuteScript("tb_do_moverate", oPC);

    // DMFI INIT ---------------------------------------------------------------
    DeleteLocalInt(oPC, "dmfi_do_op"); // op 0 delete it just to paranoid
    ExecuteScript("dmfi_do_op", oPC);
    // END DMFI INIT -----------------------------------------------------------

        SetLocalInt(oPC, REENTRY_FLAG, TRUE); // Re-entry (between server resets) detection.

//    effect eGhost = EffectCutsceneGhost();
//    eGhost = SupernaturalEffect( eGhost );
//    ApplyEffectToObject( DURATION_TYPE_PERMANENT, eGhost, oPC );


        // If this was a new PC make her "old"
        if (bNewPC) {
                GiveXPToCreature(oPC, 1);
        } else {
                ExecuteScript("_ex_logindeath", oPC);
        }

        // Make sure all the scripts got to run before clearing this just in case.
        //DelayCommand(15.0, DeleteLocalInt(oPC, "NEW_PC_FLAG"));
        DelayCommand(15.0, clearEntering(oPC));
}
