// _mod_cfg.nss
// configuration script for module. Settings are stored as variables on the module 
// This is called once at the start of the module load event.

#include "_inc_nwnx"

// Debug options

// Set to true to enable debugging. This allows the use of the debug chat commands and
// enables default debug messages. It can be turned on or off by chat as long as NO_DEBUG_MODE is not set.
// Module variable "DEBUG"
int DEBUG = FALSE; //TRUE;

// Set the debug level (see 00_debug for levels). This is a flags field so it can have multiple bits set.
// This can be controlled at runtime by the debug chat system.
// Module variable is "DEBUG_LEVEL"
int DEBUG_LEVEL = 0x00; //0x1; //8192; //0x0000; //0x1001; // rest and pw

// Set to TRUE to have any enabled debug messages go to the clientlog file as well.
// Module variable is "DEBUGLOG"
int DEBUGLOG   = TRUE;

// Set to TRUE to prevent the debug chat system from enabling DEBUG. It does not preclude DEBUG already being set.
// module variable "NO_DEBUG_MODE"
int NO_DEBUG_MODE = FALSE;

// Restrict debug commands to specific player CD keys. This should be set true for production
// module variable is DEBUGRESTRICT
int DEBUGRESTRICT = TRUE;

// Maximum number of henchpeople is set globally on the module
int HE_MAX_HENCHMEN = 50;


// this number is based on module time settings (duration of game hours in minutes)
// 30 for each game hour lasts 2 minutes
// 3 for each game hour lasts 20 minutes
// You do not need to change this.  Code should use GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")
int IGMINUTES_PER_RLMINUTE    = 3;

// module heartbeat counter modulo
// This controls when the MOD_HEARTBEAT_TICK counter wraps.
// This should not be set less than 2
int MOD_HB_TICK_MODULO  = 4;

// Use NWNX to set the TMI limit to this
// nwserver default is 131071
int MOD_TMI_LIMIT = 1000000;
                   
// AID examine/Look at nearby PCs
int AID_EXAMINE_PCS = TRUE;

// Development mode - no NWNX. If not set on the module you can control it here. 
// You can override it to be set here but if TRUE on the module that will be respected.
int DEVELOPMENT_MODE = FALSE;

// RESPAWN_PENALTY_LEVEL
// Characters with this number of hitdice or LESS will not be penalized on respawn.
int RESPAWN_PENALTY_LEVEL = 2;

// PC_CORPSE_LOOTABLE
// Set to true to allow PC corpses to be looted by other players.
int PC_CORPSE_LOOTABLE = FALSE;

// Enable Racial movement rates (mostly for PCs)
// module variable is RACIALMOVE
int USE_RACIAL_MOVEMENT = TRUE;


// seconds until a feedback string appears on entering module
// module variable is  DELAY_DISPLAY_START 
float DELAY_DISPLAY_START = 3.0;


// Set the given int variable on the module if it is not set already
// nDef is the value which determines if the variable is set already.
// If nVal == nDef and nothing will be set.
void setModuleIntVar(string sVar, int nVal, int nOver = -1);

// Set the given float variable on the module if it is not set already
// fOver is the value which determines if the variable is set already.
// If fVal == fOver and nothing will be set.
void setModuleFloatVar(string sVar, float fVal, float fOver = -1.0);

// Set the given int variable on the module if it is not set already
// nDef is the value which determines if the variable is set already.
// If nVal == nDef nothing will be set.
void setModuleStringVar(string sVar, string sVal, string sDef = "EMPTY_STRING");
 

void main () {
	if (!GetLocalInt(OBJECT_SELF, "he_mod_initialized")) {
                SetLocalInt(OBJECT_SELF,  "he_mod_initialized", 1);

                int nMin = FloatToInt(HoursToSeconds(1)/60);
                if (nMin <= 0) nMin = 1;
                IGMINUTES_PER_RLMINUTE = 60/nMin;
		if (IGMINUTES_PER_RLMINUTE <= 0) IGMINUTES_PER_RLMINUTE = 30; // nwn default fallback
                WriteTimestampedLogEntry("Module Init Time: " + IntToString(nMin) + " Minutes per hour so IGMINUTES_PER_RLMINUTE = " 
                        + IntToString(IGMINUTES_PER_RLMINUTE));
		setModuleIntVar("IGMINUTES_PER_RLMINUTE", IGMINUTES_PER_RLMINUTE);
		setModuleIntVar("MOD_HB_TICK_MODULO",  MOD_HB_TICK_MODULO);
		
		setModuleIntVar("DEBUG", DEBUG);
                setModuleIntVar("DEBUG_LEVEL", DEBUG_LEVEL); 
		setModuleIntVar("DEVELOPMENT", DEVELOPMENT_MODE); 
                setModuleIntVar("DEBUGLOG", DEBUGLOG); 
                setModuleIntVar("NO_DEBUG_MODE", NO_DEBUG_MODE);
                setModuleIntVar("DEBUGRESTRICT", DEBUGRESTRICT);
		setModuleIntVar("MAX_HENCHMEN", HE_MAX_HENCHMEN);
		SetMaxHenchmen(GetLocalInt(OBJECT_SELF,"MAX_HENCHMEN")); 
		
                //NWNX_SetTMILimit(MOD_TMI_LIMIT);

                setModuleIntVar("AID_EXAMINE_PCS", AID_EXAMINE_PCS);
                setModuleIntVar("RESPAWN_PENALTY_LEVEL", RESPAWN_PENALTY_LEVEL);
                setModuleIntVar("PC_CORPSE_LOOTABLE", PC_CORPSE_LOOTABLE);
                setModuleIntVar("RACIALMOVE", USE_RACIAL_MOVEMENT);  

		setModuleFloatVar("DELAY_DISPLAY_START", DELAY_DISPLAY_START);

                // set local vars on module
                // Quote makes sense here, why all this for \n?
		SetLocalString(OBJECT_SELF, "LINEBREAK", GetSubString(GetStringByStrRef(54),36,1));
		SetLocalString(OBJECT_SELF, "QUOTE", GetSubString(GetStringByStrRef(36),276,1));

                // LOOT ------------------------------------------------------------------------
                //int LOOT_PERIOD_MINUTES         = GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")*60; // real life minutes is the second number
                                                                                               // period of time between loot respawns
		setModuleIntVar("LOOT_PERIOD_MINUTES", GetLocalInt(OBJECT_SELF, "IGMINUTES_PER_RLMINUTE") * 60);
		
	}
}
// Set the given int variable on the module if it is not set already
// nDef is the value which determines if the variable is set already.
// If nVal == nDef and nothing will be set.
void setModuleIntVar(string sVar, int nVal, int nOver = -1) {
    object oModule = GetModule();
    int nCur = GetLocalInt(oModule, sVar);

    // Something was set on the module
    // so respect that
    if (nCur != 0) {
        // If the module variable is set to nOver
        // That means it should be 0. So clear it.
        if (nCur == nOver) {
            // Set nOver to 0
            DeleteLocalInt(oModule, sVar);
        }
        return;
    }

    // Otherwise - nothing was set on the module set it only if non-zero
    if (nVal != 0) {
        SetLocalInt(oModule, sVar, nVal);
    }
}

// Set the given float variable on the module if it is not set already
// fOver is the value which determines if the variable is set already.
// If fVal == fOver and nothing will be set.
void setModuleFloatVar(string sVar, float fVal, float fOver = -1.0) {
    object oModule = GetModule();
    float fCur = GetLocalFloat(oModule, sVar);

    // Something was set on the module
    // so respect that
    if (fCur != 0.0) {
        // If the module variable is set to nOver
        // That means it should be 0. So clear it.
        if (fCur == fOver) {
            DeleteLocalFloat(oModule, sVar);
        }
        return;
    }

    // Otherwise - nothing was set on the module set it only if non-zero
    if (fVal != 0.0) {
        SetLocalFloat(oModule, sVar, fVal);
    }
}

// Set the given int variable on the module if it is not set already
// nDef is the value which determines if the variable is set already.
// If nVal == nDef nothing will be set.
void setModuleStringVar(string sVar, string sVal, string sDef = "EMPTY_STRING") {
    object oModule = GetModule();
    string sCur = GetLocalString(oModule, sVar);

    // Something was set on the module
    // respect that setting
    if (sCur != "") {
        //if it was set to sDef that means it should be ""
        if (sCur == sDef) {
            DeleteLocalString(oModule, sVar);
        }
        return;
    }

    // Otherwise - nothing was set on the module so if not empty set the string
    if (sVal != "") {
        SetLocalString(oModule, sVar, sVal);
    }
}
