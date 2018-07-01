// _inc_death.nss
// Death system routines

#include "_inc_data"
#include "_inc_util"

// DEFAULT DEATH RULES ---------------------------------------------------------
// Respawn after death as default behavior?
const int RESPAWN_BUTTON        = TRUE;
// Default multiplayer: show wait for help button?
const int HELP_BUTTON           = TRUE;
// Default explanation of death rules
const string DEATH_RULES        = "Respawning will send you to the Fugue plane while your body and gear are left where you died.";



// DEATH -----
// Garbage collection of killer data,   [File: _inc_util]
void WipeKillerDataFromVictim(object victim);
// Record the killer on the victim when dying starts,   [File: _inc_util]
void StoreKillerDataOnVictim(object victim, object killer);
// status can be integer of game day of death, "0" for alive,   [File: _inc_util]
// "RAISED", or "RESURRECTED" indicate the process of being raised
string GetPCDeathStatus(string pcid);
// records the full death event, and sets "status" of death to current game day,   [File: _inc_util]
void RecordPCDeath(object oPC);
// cancels a death with a status of 0 for alive   [File: _inc_util]
// RAISED and RESURRECTED can be used to indicate the PC will be raised or resurrected on next log in
void ClearPCDeath(string pcid, string status="0");
// PC's bonus to stabilize while dying - [FILE: _inc_util]
// MAGUS DEATH SYSTEM
int GetStabilizeBonus(object oPC);
//Drops items held by oCreature - [FILE: _inc_util]
void DropItems(object oCreature);

const int DEATH_DEBUG = TRUE;

void deathDebug(string sMsg, object oPC = OBJECT_INVALID) {
        if (DEATH_DEBUG) {
                dbstr(sMsg, oPC);
        }
}


// IMPLEMENTATION
int GetStabilizeBonus(object oPC)
{
    int StabilizeBonus = 0;

    StabilizeBonus  += GetAbilityModifier(ABILITY_CONSTITUTION, oPC);
    StabilizeBonus  += GetHasFeat(FEAT_STRONGSOUL, oPC);
    StabilizeBonus  += GetHasFeat(FEAT_GREAT_FORTITUDE, oPC);
    StabilizeBonus  += GetHasFeat(FEAT_EPIC_FORTITUDE, oPC);
    StabilizeBonus  += GetHasFeat(FEAT_LUCK_OF_HEROES, oPC);
    StabilizeBonus  += GetHasFeat(FEAT_DEATHLESS_VIGOR, oPC);
    StabilizeBonus  += GetHasFeat(FEAT_DIVINE_GRACE, oPC);

    return StabilizeBonus;
}
void WipeKillerDataFromVictim(object victim)
{
    DeleteLocalObject(victim,"KILLER");
    DeleteLocalString(victim,"KILLER_TYPE");
    DeleteLocalString(victim,"KILLER_NAME");
    DeleteLocalString(victim,"KILLER_ID");
    DeleteLocalString(victim,"SCRIPT_PC_DEATH");
}

void StoreKillerDataOnVictim(object victim, object killer)
{
    SetLocalObject(victim,"KILLER",killer);

    SetLocalString(victim,"SCRIPT_PC_DEATH",GetLocalString(killer, "SCRIPT_PC_DEATH"));

    int b_fam   = FALSE;
    string killer_type  = "NPC";
    if(GetIsPC(killer))
    {
        if(killer==victim)
            killer_type = "SELF";
        if(GetIsDM(killer))
            killer_type = "DM";
        else if(GetIsDMPossessed(killer))
            killer_type = "DM";
        else if(GetIsPossessedFamiliar(killer))
        {
            b_fam       = TRUE;
            killer_type = "PC";
        }
        else
            killer_type = "PC";
    }
    SetLocalString(victim,"KILLER_TYPE",killer_type);

    string killer_name  = GetName(killer);
    string killer_id    = GetPCID(killer);
    if(!StringToInt(killer_id))
    {
        if(b_fam)
        {
            killer_name  = "FAMILIAR_"+killer_name;
            killer_id    = GetPCID(GetMaster(killer));
        }
        if(!StringToInt(killer_id))
        {
            killer_id    = "0";
        }
    }
    SetLocalString(victim,"KILLER_NAME",killer_name);
    SetLocalString(victim,"KILLER_ID", killer_id);
}

string GetPCDeathStatus(string pcid)
{
    return Data_GetCampaignString("DEAD", OBJECT_INVALID, pcid);
}

void RecordPCDeath(object oPC)
{
    // if not a character in the DB... exit
    if(!StringToInt(GetPCID(oPC)))
        return;

    // first mark the PC as dead in the DB
    Data_SetCampaignString("DEAD", IntToString(GetTimeCumulative(TIME_DAYS)), oPC);

    // record the record of the death in the DB
    if(MODULE_NWNX_MODE)
    {
        // Get all the information about the death
        string character_id = GetPCID(oPC);
        string killer_id    = GetLocalString(oPC, "KILLER_ID");//GetPCID(oKiller);
        string killer_name  = GetLocalString(oPC, "KILLER_NAME");//GetName(oKiller);

	// Don't need this with SQL Prepared
        //killer_id   = EncodeSpecialChars(killer_id);
        //killer_name = EncodeSpecialChars(killer_name);
        string killer_type  = GetLocalString(oPC, "KILLER_TYPE");

        object oArea        = GetArea(oPC);
        string area_name    = GetName(oArea);
        string area_id      = GetIDFromArea(oArea);

        // death record
        // id, timestamp, campaign, killed (id), killer (id,name,type), area (id, name)
	string sQuery = "INSERT INTO character_deaths (campaign_id, character_id, killer_type, killer_id, killer_name, area_id, area_name) "
		+"VALUES("+NWNX_GetCampaignID()+","+character_id+",'"+killer_type+"',?,?,?,?);";
	NWNX_SqlExecPrepared(sQuery, killer_id,killer_name,area_id,area_name);
    }
}

void ClearPCDeath(string pcid, string status="0")
{
    // if this is not an int... this is not a character stored in the db
    if(!StringToInt(pcid))
        return;

    // status can be
    // RAISED       --> raise with 1 hit point
    // RESURRECTED  --> raise with full hitpoints
    // 0            --> alive. not dead.

    // PC dead flag set to 0 in DB
    Data_SetCampaignString("DEAD", status, OBJECT_INVALID, pcid);

}
void DropItems(object oCreature)
{
    object oItemLeft    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oCreature);
    object oItemRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oCreature);
    object oItemHead    = GetItemInSlot(INVENTORY_SLOT_HEAD,oCreature);
    float fDir          = GetFacing(oCreature);
    location lLocLeft   = GenerateNewLocation(oCreature,
                                DISTANCE_TINY,
                                GetHalfLeftDirection(fDir),
                                fDir);
    location lLocRight  = GenerateNewLocation(oCreature,
                                DISTANCE_TINY,
                                GetHalfRightDirection(fDir),
                                fDir);
    location lLocHead   = GenerateNewLocation(oCreature,
                                DISTANCE_TINY,
                                GetOppositeDirection(fDir),
                                fDir);
    AssignCommand(oCreature, ActionUnequipItem(oItemLeft));
    AssignCommand(oCreature, ActionUnequipItem(oItemRight));
    AssignCommand(oCreature, ActionUnequipItem(oItemHead));

    // TODO This is broken if there are variables on items...
    CopyObject(oItemLeft,lLocLeft);
    CopyObject(oItemRight,lLocRight);
    CopyObject(oItemHead,lLocHead);
    DestroyObject(oItemLeft);
    DestroyObject(oItemRight);
    DestroyObject(oItemHead);
}

