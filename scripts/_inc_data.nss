//::///////////////////////////////////////////////
//:: _inc_data
//:://////////////////////////////////////////////
/*
    functions related to persistent storage
    this is a master include including all DB related scripts

*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2015 dec 19)
//::
//:://////////////////////////////////////////////

/* 
#
# Hills edge database setup script  
# for use with NWNX:EE
#
# use  mysql -u <user> -p < ./nwnee_hillsedge_db.sql
# NOTE: This is for starting over completely. It will clear all saved data in the hillsedge database!
# This is the new version in development. For testing. 

CREATE DATABASE IF NOT EXISTS hillsedge;

USE hillsedgeee;

###############################
#campaign tables

#      campaigns  (campaign_id, name)
DROP TABLE IF EXISTS campaigns;
CREATE TABLE campaigns (
        campaign_id int(11) UNSIGNED UNIQUE KEY AUTO_INCREMENT,	
	name varchar(64) default '',
	time_game varchar(64) default '',
	epoch_game varchar(64) default '',
	UNIQUE KEY idx (name)
) ENGINE=MyISAM;

# guess at campaign_data
DROP TABLE IF EXISTS campaign_data;
CREATE TABLE campaign_data (
  character_id int(11) UNSIGNED not NULL,
  campaign_id int(11) UNSIGNED, 
  tag  varchar(64) default "-",
  label varchar(64) default '',
  value text,
  expire int(11) default '0',
  time_real timestamp NOT NULL default CURRENT_TIMESTAMP,
  UNIQUE KEY idx (character_id, campaign_id, tag, label)
) ENGINE=MyISAM;


# guess at campaign_object
DROP TABLE IF EXISTS campaign_object;
CREATE TABLE campaign_object (
  character_id int(11) UNSIGNED not NULL,
  campaign_id int(11) UNSIGNED,  
  tag  varchar(64) default "-",
  label varchar(64) default '',
  object blob,
  expire int(11) default '0',
  time_real timestamp NOT NULL default CURRENT_TIMESTAMP,
  UNIQUE KEY idx (character_id, campaign_id, tag, label)
) ENGINE=MyISAM;

#      campaign_characters (character_id, campaign_id,lastlog_time_real)
DROP TABLE IF EXISTS campaign_characters;
CREATE TABLE campaign_characters (
  character_id int(11) UNSIGNED not NULL,
  campaign_id int(11) UNSIGNED, 
  lastlog_time_real timestamp NOT NULL default CURRENT_TIMESTAMP,
  UNIQUE KEY idx (character_id, campaign_id)
) ENGINE=MyISAM;

#      campaign_locations (character_id, campaign_id, type, area_id, position, facing)
DROP TABLE IF EXISTS campaign_locations;
CREATE TABLE campaign_locations (
  character_id int(11) UNSIGNED not NULL,
  campaign_id int(11) UNSIGNED, 
  type  varchar(16) default "",
  area_id varchar(64) default '',
  position varchar(64) default '', 
  facing varchar(64) default '',	  
  UNIQUE KEY idx (character_id, campaign_id)
) ENGINE=MyISAM;


#################################
# player tables  - changed to use a unique int key for player_id?
# guess at players (player_id, name, banned)
DROP TABLE IF EXISTS players;
CREATE TABLE players (
  player_id int(11) UNSIGNED UNIQUE KEY not NULL AUTO_INCREMENT,
  name varchar(64) default '',
  banned int(11) default '0',
  last timestamp NOT NULL default CURRENT_TIMESTAMP,
  UNIQUE KEY idx (name),
  PRIMARY KEY (player_id)
) ENGINE=MyISAM;


# guess at player_cdkeys (player_id, cdkey_public)
# Key is not unique because players are allowed multiple rows. 
DROP TABLE IF EXISTS player_cdkeys;
CREATE TABLE player_cdkeys (
  player_id int(11) UNSIGNED,
  cdkey_public varchar(64) default '',
  KEY idx (player_id)
) ENGINE=MyISAM;

# guess at player_misc (player_id,label,value)
# used for extra player keys.
DROP TABLE IF EXISTS player_misc;
CREATE TABLE player_misc (
  player_id int(11) UNSIGNED,
  label varchar(64) default '',
  value text, 
  last timestamp NOT NULL default CURRENT_TIMESTAMP,	    
  UNIQUE KEY idx (player_id,label)
) ENGINE=MyISAM;


##################
# character tables 

# characters defines the unique index for that character  - seems to be by name? 
#      characters     (character_id, name, type)
DROP TABLE IF EXISTS characters;
CREATE TABLE characters (
  character_id int(11) UNSIGNED UNIQUE KEY not NULL AUTO_INCREMENT,
  name varchar(64) default '', 
  type varchar(64) default '',
  initialized boolean not null default 0,	
  UNIQUE KEY idx (name),
  PRIMARY KEY (character_id)
) ENGINE=MyISAM;

#      characters_dm  (character_id, player_id)
DROP TABLE IF EXISTS characters_dm;
CREATE TABLE characters_dm (
  character_id int(11) UNSIGNED not NULL, 
  player_id int(11) UNSIGNED not NULL,
  KEY idx (character_id)
) ENGINE=MyISAM;


#      characters_pc  (character_id, player_id, filename)
DROP TABLE IF EXISTS characters_pc;
CREATE TABLE characters_pc (
  character_id int(11) UNSIGNED not NULL, 
  player_id int(11) UNSIGNED not NULL,
  filename varchar(64) default '',
  UNIQUE KEY idx (character_id, player_id)
) ENGINE=MyISAM;


# these are campaign dependent
# TODO - not sure how this one is used 
#      characters_npc (character_id, campaign_id, resref, tag, plot, dead, hitpoints)
DROP TABLE IF EXISTS characters_npc;
CREATE TABLE characters_npc (
  character_id int(11) UNSIGNED not NULL, 
  campaign_id int(11) UNSIGNED not NULL default 0,
  resref varchar(64) default '',
  tag varchar(64) default '',
  plot boolean not null default 0,
  dead boolean not null default 0,
  hitpoints int(11) default 1,
  UNIQUE KEY idx (character_id, campaign_id)
) ENGINE=MyISAM;


#      character_xp (character_id, campaign_id, type, value)
DROP TABLE IF EXISTS character_xp;
CREATE TABLE character_xp (
  character_id int(11) not NULL, 
  campaign_id int(11) not NULL default 0,
  type varchar(64) default '',
  value int(11) default 0,
  KEY idx (character_id, campaign_id)
) ENGINE=MyISAM;

#      character_deaths (campaign_id, character_id, killer_type, killer_id, killer_name, area_id, area_name) 
DROP TABLE IF EXISTS character_deaths;
CREATE TABLE character_deaths ( 
  campaign_id int(11) not NULL default 0,
  character_id int(11), 
  killer_type varchar(64) default '',  
  killer_id varchar(64) default '',  
  killer_name varchar(64) default '', 
  area_id varchar(64) default '',  
  area_name varchar(64) default '',  
  KEY idx (character_id, campaign_id)
) ENGINE=MyISAM;

# --------------------------------------------------------

# END SQL SETUP 

*/

// INCLUDES --------------------------------------------------------------------
#include "00_debug"

#include "_inc_constants"
// used for generate new location
#include "X0_I0_POSITION"
// persistent vars on pc's skin
#include "x3_inc_skin"

#include "_inc_utils"
//#include "nwnx"

#include "nwnx_sql"
#include "nwnx_object"
// Natural Bioware Database Extension
#include "nbde_inc"

// CONSTANTS -------------------------------------------------------------------
const int SQL_ERROR     = 0;
const int SQL_SUCCESS   = 1;
const string SQL_DELIM  = "¬";
//const string APS_STR_TYPE = "-str-";  // this one is not used since string is the default type
const string APS_INT_TYPE = "-int-";
const string APS_FLOAT_TYPE = "-flt-";
const string APS_LOC_TYPE = "-loc-";
const string APS_VECTOR_TYPE = "-vec-";
const string APS_OBJECT_TYPE = "-obj-";

const string SQL_DATA_TABLE = "campaign_data";
const string SQL_OBJECT_TABLE = "campaign_object"; 
// When set to TRUE the persistence system will use skin variables for string, int and float
// if the target of the operation is a PC. 
// It will do this even in single player (i.e. DEVELOPMENT_MODE).
const int PERSIST_USE_SKIN = TRUE;

// is NWNX active?
int MODULE_NWNX_MODE            = !GetLocalInt(GetModule(), "DEVELOPMENT");

// This is the primary interface other scripts should use for persistence.
// -- INTERFACE --
void SetPersistentString(object oObject, string sVarName, string sValue, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
void SetPersistentInt(object oObject, string sVarName, int nValue, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
void SetPersistentFloat(object oObject, string sVarName, float fValue, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
string GetPersistentString(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
int GetPersistentInt(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
float GetPersistentFloat(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
void DeletePersistentString(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
void DeletePersistentInt(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
void DeletePersistentFloat(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE);
void SetPersistentLocation(object oObject, string sVarName, location lLocation, string sTable = SQL_DATA_TABLE);
void SetPersistentVector(object oObject, string sVarName, vector vVector, string sTable = SQL_DATA_TABLE);
void SetPersistentObject(object oObject, string sVarName, object oValue, string sPCID = "", string sTable = SQL_OBJECT_TABLE);
location GetPersistentLocation(object oObject, string sVarName, string sTable = SQL_DATA_TABLE);
vector GetPersistentVector(object oObject, string sVarName, string sTable = SQL_DATA_TABLE);
object GetPersistentObject(object oObject, string sVarName, object oOwner = OBJECT_INVALID, string sPCID = "", int object_type = OBJECT_TYPE_CREATURE,  string sTable = SQL_OBJECT_TABLE);
void DeletePersistentLocation(object oObject, string sVarName, string sTable = SQL_DATA_TABLE);
void DeletePersistentVector(object oObject, string sVarName, string sTable = SQL_DATA_TABLE);
void DeletePersistentObject(object oObject, string sVarName, string sTable = SQL_OBJECT_TABLE);

// Creates a creature which will store source_inventory's inventory in the DB - [FILE: _inc_util]
// clones the inventory of source_inventory
void CreatePersistentInventory(string inventory_tag, object source_inventory, string pcid="TBD", int store_in_db=TRUE, int clone_inventory=TRUE);
// finds or retrieves from DB persistent inventory holder - [FILE: _inc_util]
// establishes connection between holder and target, and clones inventory from holder to target
void RetrievePersistentInventory(string inventory_tag, object target_inventory, string pcid="0");
// returns the inventory object, even if it must spawn and recall it from DB - [FILE: _inc_util]
object GetPersistentInventory(string inventory_tag, string pcid="0");
// an ability check. if bVerbose=TRUE, ability check is broadcast - [FILE: _inc_util]

// -- INTERFACE -- 
// Commits PC state to Data (typically on heartbeat) - [FILE: _inc_data]
void Data_SavePC(object oPC, int export_characters_now=FALSE);
// Returns last stored HP total for PC. - [FILE: _inc_data]
int Data_GetPCHitPoints(object oPC);
// Stores current HP total for PC. - [FILE: _inc_data]
void Data_SetPCHitPoints(object oPC);
// Returns a backup location for the PC when LastLocation fails. - [FILE: _inc_data]
location Data_GetPCBackupLocation(object oPC, string pcid="-1");
// Returns last saved location of the PC. - [FILE: _inc_data]
location Data_GetLocation(string sType, object oPC=OBJECT_INVALID, string pcid="-1");
// Stores a location in the DB for the PC. - [FILE: _inc_data]
void Data_SetLocation(string sType, location lLoc, object oPC=OBJECT_INVALID, string pcid="-1");
// Stores a NPC object to the database - [FILE: _inc_data]
void Data_SaveNPC(object oObject);
// Retrieves an NPC object from the database - [FILE: _inc_data]
object Data_RetrieveNPC(string character_id, location lLoc);

// These should not be used.
// Stores a campaign object to the database - [FILE: _inc_data]
void Data_SaveCampaignObject(object oObject, object oPC=OBJECT_INVALID,string tag = "MODULE");
// Retrieves a campaign object from the database - [FILE: _inc_data]
object Data_RetrieveCampaignObject(string sLabel, location lLoc, object oOwner = OBJECT_INVALID, object oPC=OBJECT_INVALID, string character_id="-1", string tag = "MODULE");
// Deletes a stored campaing object from database (only NWNX - no analogue in Bio DB) - [FILE: _inc_data]
object Data_DeleteCampaignObject(string sLabel, object oOwner = OBJECT_INVALID, object oPC=OBJECT_INVALID, string character_id="-1", string tag = "MODULE");
// Stores a campaign string to the database - [FILE: _inc_data]
void Data_SetCampaignString(string sLabel, string sValue, object character=OBJECT_INVALID, string character_id="-1");
// Retrieves a campaign string to the database - [FILE: _inc_data]
string Data_GetCampaignString(string sLabel, object character=OBJECT_INVALID, string character_id="-1");

// -- COMMON utility functions ---
// init database
void persistInitDB();

int GetIsPCSafe(object oPC);

// Returns PC Object if PC is in game. PCID is a unique string identifier. - [FILE: _inc_util]
object GetPCByPCID(string PCID);

// Returns a unique string identifying the PC - [FILE: _inc_util]
string GetPCID(object oPC);
// utility - return the area object with sAreaID    - [FILE: _inc_data]
object GetAreaFromID(string sAreaID);
// utility - return the area_id from oArea          - [FILE: _inc_data]
string GetIDFromArea(object oArea=OBJECT_SELF);
// replaces ' with ~                                - [FILE: _inc_data]
// the character ' will create problems for SQL
string EncodeSpecialChars(string sString);
// replaces ~ with '                                - [FILE: _inc_data]
string DecodeSpecialChars(string sString);

// Save and re-load PC feat and spell uses
void pwSavePCSpellsAndFeats(object oPC);
void pwLoadPCSpellsAndFeats(object oPC);


// -- SPECIALIZED NWNX calls ---

// get the index of the campaign from DB (nwnx_odbc2)           - [FILE: _inc_data]
// returns a string which is an integer ranging from 1 and greater
string NWNX_GetCampaignID();

// get the index of the player from DB (nwnx_odbc2)             - [FILE: _inc_data]
// returns a string which is an integer ranging from 1 and greater
// it returns "BANNED" if the player is banned
string NWNX_GetPlayerID(object oPC);

// get the index of the player from DB (nwnx_odbc2)             - [FILE: _inc_data]
string NWNX_GetCharacterID(object oCharacter);

// return index of NPC from DB using NPCID string (nwnx_odbc2)  - [FILE: _inc_data]
// see GetPCIdentifier in v2_inc_util for makeup of NPCID string
string NWNX_ConvertNPCIDtoCharacterID(string sNPCID);

// get the filename of oPC (nwnx_funcs)                         - [FILE: _inc_data]
string NWNX_GetPCFilename(object oPC);

// store the character's location in DB (nwnx_odbc2)            - [FILE: _inc_data]
void NWNX_StoreLocation(string sType, location lLoc, string character_id);

// retrieve the character's location from DB (nwnx_odbc2)       - [FILE: _inc_data]
location NWNX_RetrieveLocation(string type, string character_id);

// delete the stored locaiton of given type   (nwnx_odbc2)      - [FILE: _inc_data]             
void NWNX_DeleteLocation(string sType, string pcid);

// returns the sum of the character's XP from DB (nwnx_odbc2) - [FILE: _inc_data]
// type: ALL QUEST AREA DISCOVERY ROLEPLAY CRAFT ABILITY COMBAT MAGIC PENALTY
// campaign_id: refers to which campaign, if "ANY" look up XP from all campaigns
int NWNX_RetrieveCharacterXP(string character_id, string type="ALL", string campaign_id="ANY");

// records XP to the DB (nwnx_odbc2) - [FILE: _inc_data]
// amount of XP stored is total + the addition of nXP
void NWNX_StoreCharacterXP(int nXP, string character_id, string type, string campaign_id);

// returns value - keyed to label, campaign_id, character_id (nwnx_odbc2) - [FILE: _inc_data]
string NWNX_RetrieveCampaignValue(string label, string campaign_id, string character_id="0", string tag = "MODULE", string table="campaign_data");

// records value - keyed to label, campaign_id, character_id (nwnx_odbc2) - [FILE: _inc_data]
void NWNX_StoreCampaignValue(string label, string value, string campaign_id, string character_id="0", string tag = "MODULE", string table="campaign_data");

// remove a value keyed by label, campaign_id, character_id and tag   - [FILE: _inc_data]
void NWNX_DeleteCampaignValue(string label, string campaign_id, string character_id="0", string tag = "MODULE", string table="campaign_data");

// -- BASE SQL functions through NWNX --
// NWNX_ODBC2

// Execute SQL statement                            - [FILE: _inc_data]
void NWNX_SqlExecDirect(string sSQL);

// Prepare and execute the given query. Variable substitutions should be set to "?",       -  [FILE: _inc_data]
// Arg0 must be non-empty before arg1, etc. 
// Arguments must be strings but using prepared means the do not need to be encoded for special characters. 
int NWNX_SqlExecPrepared(string query, string arg0 = "", string arg1 = "", string arg2 = "", string arg3 = "");

// Push obj to the DB                               - [FILE: _inc_data]
// example query ---->  "insert into " + table + " (data) values(?);"
void NWNX_StoreObject(string query, object obj, object owner=OBJECT_INVALID, string arg1 = "", string arg2 = "");
// returns an object found in the DB                - [FILE: _inc_data]
// where is the location to spawn the object
// owner -- for an item put in inventory of owner
// Location must be valid if owner is not.
// example query ---->  "select data from " + table + " where id = " + id + ";"
object NWNX_RetrieveObject(string query, location where, object owner = OBJECT_INVALID, string arg0 = "", string arg1 = "");
// See nwnx_sql.nss for routines to fetch data from rows.


// IMPLEMENTATIONS -------------------------------------------------------------

// -- INTERFACE --
int GetIsPCSafe(object oPC) {
        return (GetIsPC(oPC) || GetLocalInt(oPC, "IS_PC"));        
}


void Data_SavePC(object oPC, int export_characters_now=FALSE)
{
    // do not record critical PC data in out of character areas or if we have isolated the PC
    if(GetIsDM(oPC)
	    ||  (GetLocalInt(GetArea(oPC),"OUT_OF_CHARACTER") || GetLocalInt(oPC,"OUT_OF_CHARACTER"))) {
	    // do nothing
    } else {
            // branches between NWNX and NDBE
	    // SavePC is called on exit now so area may be invalid. 
	    if (GetIsObjectValid(GetArea(oPC))) {
		    dblvlstr(DEBUGLEVEL_PW, "SAVE PC: Loc("+LocationToString(GetLocation(oPC))+")", GetModule());
		    Data_SetLocation("LAST", GetLocation(oPC), oPC);
	    }

            // Pesistant GP
            //SetSkinInt(oPC, PC_GP, GetGold(oPC));

	    //db("SAVE PC: " + GetName(oPC) + " RESTORE_HP=",  GetLocalInt(oPC,"RESTORE_HP"),
	    //   " RESTORE_HP_INIT = " , GetLocalInt(oPC,"RESTORE_HP_INIT"));
	    //db(" saving hp = " + IntToString(GetCurrentHitPoints(oPC)));
	    // Pesistant HP
	    if(!GetLocalInt(oPC,"RESTORE_HP") && GetLocalInt(oPC,"RESTORE_HP_INIT")) {
		    Data_SetPCHitPoints(oPC);
	    }
            pwSavePCSpellsAndFeats(oPC);

            SetLocalInt(oPC, "deity_tmp_op", 1);
            ExecuteScript("deity_do_op", oPC);

	    if(export_characters_now)
		    ExecuteScript("fox_export_chars",oPC);
    }
}

int Data_GetPCHitPoints(object oPC) {
	string sData = Data_GetCampaignString("HIT_POINTS", oPC, GetPCID(oPC));
	//db("GET PC HITPOINTS: " + GetName(oPC) + " RESTORE_HP=",  GetLocalInt(oPC,"RESTORE_HP"), " got '" + sData + "'");
	return StringToInt(sData);
}

void Data_SetPCHitPoints(object oPC) {
	int nHP = GetCurrentHitPoints(oPC);	
	//db("SET PC HITPOINTS:  " + GetName(oPC) + " RESTORE_HP=",  GetLocalInt(oPC,"RESTORE_HP"), " setting HP = " +  IntToString(nHP));
	Data_SetCampaignString("HIT_POINTS", IntToString(nHP), oPC, GetPCID(oPC));
}

void Data_StorePCHitPoints(string sPCID, int nHP) {
        //dbstr("Store PC HITPOINTS: pcid = " + sPCID + " setting HP = " + IntToString(nHP));
        Data_SetCampaignString("HIT_POINTS", IntToString(nHP), OBJECT_INVALID, sPCID);
}

location Data_GetPCBackupLocation(object oPC, string pcid="-1")
{
    // value to return
    location lLocation;

    // home
    lLocation   = Data_GetLocation("HOME", oPC, pcid);

    // else look up last known region for PC ... and start them at a safe place there

    // when all else fails, PC returns to the default starting way point
    if(!GetIsObjectValid(GetAreaFromLocation(lLocation)))
        lLocation   = GetLocation(GetWaypointByTag(WP_DEFAULT_START));

    return lLocation;
}

location Data_GetLocation(string sType, object oPC=OBJECT_INVALID, string pcid="-1")
{
    // value to return
    location lLocation;

    // NWNX
    if(MODULE_NWNX_MODE)
    {
        if(pcid=="-1")
        {
            if(GetIsObjectValid(oPC))
            {
                pcid = GetPCID(oPC);
                if(!StringToInt(pcid))
                    return lLocation; // we do not store locations for non persistent characters
            }
            else
                pcid = "0";
        }
        lLocation   = NWNX_RetrieveLocation(sType, pcid);
    }
    // non- ---
    else
    {
        // adjust the label for the pc
        string loc_label;
        if(pcid=="-1")
        {
            if(GetIsObjectValid(oPC))
                pcid = GetPCID(oPC);
            else
                pcid = "0";
        }
        if(pcid!="0")
            loc_label   = pcid+sType;

        // location string in database
        string sLoc     = NBDE_GetCampaignString(CAMPAIGN_NAME, loc_label, OBJECT_INVALID);

        // convert location string to location
        object oArea    = GetAreaFromID(GetStringRight(sLoc,48));
        vector vVec;
               vVec.x   = StringToFloat(GetStringLeft(sLoc,5)) / 100;
               vVec.y   = StringToFloat(GetSubString(sLoc,5,5)) / 100;
               vVec.z   = StringToFloat(GetSubString(sLoc,10,5)) / 100;
        lLocation       = Location(oArea, vVec, StringToFloat(GetSubString(sLoc,15,5)) / 100);
    }

    return lLocation;
}

void Data_SetLocation(string sType, location lLoc, object oPC=OBJECT_INVALID, string pcid="-1")
{
    // NWNX
    if(MODULE_NWNX_MODE)
    {
        if(pcid=="-1")
        {
            if(GetIsObjectValid(oPC))
            {
                pcid = GetPCID(oPC);
                if(!StringToInt(pcid))
                    return; // we do not store locations for non persistent characters
            }
            else
                pcid = "0";
        }
        NWNX_StoreLocation(sType, lLoc, pcid);
    }
    // non-nwnx
    else
    {
        // adjust the label for the pc
        string loc_label;
        if(pcid=="-1")
        {
            if(GetIsObjectValid(oPC))
                pcid = GetPCID(oPC);
            else
                pcid = "0";
        }
        if(pcid!="0")
            loc_label   = pcid+sType;

        object oArea    = GetAreaFromLocation(lLoc);
        vector vPos     = GetPositionFromLocation(lLoc);
        float fFacing   = GetFacingFromLocation(lLoc);
        string sLoc; // the value stored in the DB
        //set X pos
        sLoc    = IntToString(FloatToInt(vPos.x*100));
        sLoc    = (GetStringLength(sLoc) < 5)  ? sLoc + GetStringLeft("     ", 5-GetStringLength(sLoc))  : GetStringLeft(sLoc,5);
        //set Y pos
        sLoc   += IntToString(FloatToInt(vPos.y*100));
        sLoc    = (GetStringLength(sLoc) < 10) ? sLoc + GetStringLeft("     ", 10-GetStringLength(sLoc)) : GetStringLeft(sLoc,10);
        //set Z pos
        sLoc   += IntToString(FloatToInt(vPos.z*100));
        sLoc    = (GetStringLength(sLoc) < 15) ? sLoc + GetStringLeft("     ", 15-GetStringLength(sLoc)) : GetStringLeft(sLoc,15);
        //set facing
        sLoc   += IntToString(FloatToInt(fFacing*100));
        sLoc    = (GetStringLength(sLoc) < 20) ? sLoc + GetStringLeft("     ", 20-GetStringLength(sLoc)) : GetStringLeft(sLoc,20);
        //set area id
        sLoc   += GetIDFromArea(oArea);

        NBDE_SetCampaignString(CAMPAIGN_NAME, loc_label, sLoc, oPC);
    }
}

void Data_DeleteLocation(string sType, object oPC=OBJECT_INVALID, string pcid="-1") {
    // NWNX
        if(MODULE_NWNX_MODE) {
                if(pcid=="-1") {
                        if(GetIsObjectValid(oPC)) {
                                pcid = GetPCID(oPC);
                                if(!StringToInt(pcid)) return; 
                        } else {
                                pcid = "0";
                        }
                }
                NWNX_DeleteLocation(sType, pcid);
        } else {
        // adjust the label for the pc
                string loc_label;
                if(pcid=="-1") {
                        if(GetIsObjectValid(oPC)) {
                               pcid = GetPCID(oPC);
                        } else {
                                pcid = "0";
                        }
                }
                if(pcid!="0") loc_label = pcid+sType;
                NBDE_DeleteCampaignString(CAMPAIGN_NAME, loc_label, OBJECT_INVALID);
        }
}

void Data_SaveCampaignObject(object oObject, object oPC=OBJECT_INVALID, string tag = "MODULE") {
    // ctored campaign objects need unique tags
    string sLabel       = GetTag(oObject);

    if(MODULE_NWNX_MODE)
    {
        string sCharID;
        if(GetIsObjectValid(oPC))
            sCharID = GetPCID(oPC);
        else
            sCharID = GetLocalString(oObject, "OWNER_PCID");

        //This should only happen if this object is the module?    
        if (sCharID == "") {
                sCharID = "0";
        }

        string campaign_id  = NWNX_GetCampaignID();

        // insert OBJECT
        // TODO - do a query here first and skip the insert if not needed. 
        string sQuery = "SELECT character_id FROM campaign_object WHERE character_id=? AND campaign_id=? AND label=? AND tag=?;";
        NWNX_SqlExecPrepared(sQuery, sCharID, campaign_id, sLabel, tag);
        if (!NWNX_SQL_ReadyToReadNextRow()) {
                sQuery = "INSERT INTO campaign_object (character_id,campaign_id,label, tag) VALUES (?,?,?,?);" ;
                NWNX_SqlExecPrepared(sQuery, sCharID, campaign_id, sLabel, tag);
        }

        sQuery = "UPDATE campaign_object SET object=? WHERE character_id="+sCharID+" AND campaign_id="
                           +campaign_id+" AND label=? AND tag=?;";
        NWNX_StoreObject(sQuery, oObject, OBJECT_INVALID, sLabel, tag);
    }
    else
    {
        StoreCampaignObject(CAMPAIGN_NAME, sLabel, oObject, oPC);
    }
}

object Data_RetrieveCampaignObject(string sLabel, location lLoc, object oOwner = OBJECT_INVALID, 
        object oPC=OBJECT_INVALID, string character_id="-1", string tag = "MODULE") {
        object campaign_object;

        if(MODULE_NWNX_MODE) {
                string campaign_id  = NWNX_GetCampaignID();
                if(character_id=="-1") {
                        character_id = GetPCID(oPC);
                }
                string query = "SELECT object FROM campaign_object WHERE character_id="+character_id+" AND campaign_id="
                        +campaign_id+" AND label='"+sLabel+"' AND tag='" + tag + "';";
		dbstr("RetrieveCampaignObject query = " + query);
                campaign_object = NWNX_RetrieveObject(query, lLoc, oOwner);                      
        } else {
                campaign_object = RetrieveCampaignObject(CAMPAIGN_NAME, sLabel, lLoc, oOwner, oPC);
        }
        return campaign_object;
}

object Data_DeleteCampaignObject(string sLabel, object oOwner = OBJECT_INVALID, object oPC=OBJECT_INVALID, 
        string character_id="-1", string tag = "MODULE") {
    
    object campaign_object;

    if(MODULE_NWNX_MODE)
    {
        string campaign_id  = NWNX_GetCampaignID();
        if(character_id=="-1") {
                character_id = GetPCID(oPC);
        }
        string query = "DELETE FROM campaign_object WHERE character_id=? AND campaign_id=? AND label=? AND tag=?;";
        dbstr("Delete OBJECT: " + query + "(" +character_id + "," + campaign_id + "," +  sLabel + "," + tag + ")");
        NWNX_SqlExecPrepared(query, character_id, campaign_id, sLabel, tag);
    }
    else
    {
        // no delete campaign object in bioware/nbde 
    }

    return campaign_object;
}
void Data_SetCampaignString(string sLabel, string sValue, object character=OBJECT_INVALID, string character_id="-1") {
        if(MODULE_NWNX_MODE) {
                if(character_id=="-1") {
                        character_id = GetPCID(character);
                }

                //db("SetCampaignString " + sLabel + "," + sValue + "," + NWNX_GetCampaignID() + "," + character_id);
                NWNX_StoreCampaignValue(sLabel, sValue, NWNX_GetCampaignID(), character_id);
        } else {
                NBDE_SetCampaignString(CAMPAIGN_NAME, sLabel, sValue, character);
        }
}

string Data_GetCampaignString(string sLabel, object character=OBJECT_INVALID, string character_id="-1") {
        string sValue;
        if(MODULE_NWNX_MODE) {
                if(character_id=="-1") {
                        character_id = GetPCID(character);
                }
                sValue = NWNX_RetrieveCampaignValue(sLabel, NWNX_GetCampaignID(), character_id);
        } else {
                sValue = NBDE_GetCampaignString(CAMPAIGN_NAME, sLabel, character);
        }
        return sValue;
}

void Data_SaveNPC(object oCharacter)
{
    // only unique NPCs
    if(GetIsPC(oCharacter) || !GetLocalInt(oCharacter,"UNIQUE"))
        return;

    string character_id = GetPCID(oCharacter);

    if(MODULE_NWNX_MODE)
    {
	string campaign_id  = NWNX_GetCampaignID();
        // insertion happens when we get the character_id for the first time
        // update OBJECT
        string sQuery = "UPDATE characters_npc SET object=? WHERE character_id="+character_id+" AND campaign_id="+campaign_id+";";
        NWNX_StoreObject(sQuery, oCharacter);
        //NWNX_StoreObject("UPDATE characters_npc SET object=%s WHERE character_id="+character_id+" AND campaign_id="+campaign_id+";", oCharacter);
    }
    else
    {
        StoreCampaignObject(CAMPAIGN_NAME, character_id, oCharacter);
    }
}

object Data_RetrieveNPC(string character_id, location lLoc)
{
    object oCharacter;

    if(MODULE_NWNX_MODE)
    {
	string campaign_id  = NWNX_GetCampaignID();
        string query = "SELECT object FROM characters_npc WHERE character_id="+character_id+" AND campaign_id="+campaign_id+";";
        oCharacter = NWNX_RetrieveObject(query, lLoc);
    }
    else
    {
        oCharacter = RetrieveCampaignObject(CAMPAIGN_NAME, character_id, lLoc);
    }

    return oCharacter;
}



// -- COMMON utility functions ---

string GetPCID(object oPC) { 

        if (!GetIsObjectValid(oPC)) {
                return "0";
        }

        if (GetObjectType(oPC) != OBJECT_TYPE_CREATURE) {
                WriteTimestampedLogEntry("ERROR: GetPCID called for non creature '" + GetTag(oPC) + "'");
                return "0";
        }

        string pcid    = GetLocalString(oPC, "CHARACTER_ID");
        if(pcid!="") return pcid; 
        // Module is character_id 0        
        if (GetModule() == oPC) {
                SetLocalString(oPC, "CHARACTER_ID", "0");
                return "0";
        }

        // If not PC and no unique use "0" and don't store in DB
        if (!GetIsPCSafe(oPC)  && !GetLocalInt(oPC, "UNIQUE")) {
                SetLocalString(oPC, "CHARACTER_ID", "0");
                return "0";   
        }


        if(MODULE_NWNX_MODE) {
                pcid = NWNX_GetCharacterID(oPC);
        } else {
                if(GetIsPC(oPC))
                        pcid = IntToString( NBDE_Hash(GetPCPlayerName(oPC)+"_"+GetName(oPC)) );   
                else
                        pcid = IntToString( NBDE_Hash(GetResRef(oPC)+"_"+GetTag(oPC)+"_"+GetName(oPC)) );
        }

        SetLocalString(oPC, "CHARACTER_ID", pcid);
        return pcid;
}

// This is tracked on the module by enter and exit events.
object GetPCByPCID(string PCID) {
	object oPC = GetLocalObject(GetModule(), "PC_" + PCID);
	return oPC;
}



string GetIDFromArea(object oArea=OBJECT_SELF)
{
    if(!GetIsObjectValid(oArea)){return "";}

    string sAreaID = GetLocalString(oArea,"AREA_ID");
    if(sAreaID!=""){return sAreaID;}

    string sRef = GetResRef(oArea);
    string sTag = GetTag(oArea);
        // set area tag
    sAreaID +=(GetStringLength(sTag) < 32) ? sTag + GetStringLeft("                                ", 32-GetStringLength(sTag)) : sTag;
    // set area reref
    sAreaID +=(GetStringLength(sRef) < 16) ? sRef + GetStringLeft("                                ", 16-GetStringLength(sRef)) : sRef;

    SetLocalString(oArea,"AREA_ID",sAreaID);

    return sAreaID;
}

object GetAreaFromID(string sAreaID)
{
    string sRef = GetStringRight(sAreaID,16);
    int nPos    = FindSubString(sRef," ");
    if(nPos>0)
        sRef    = GetStringLeft(sRef,nPos);

    string sTag = GetStringLeft(sAreaID,32);
        nPos    = FindSubString(sTag," ");
    if(nPos>0)
        sTag    = GetStringLeft(sTag,nPos);

    int nNth    = 0;
    object oArea= OBJECT_INVALID;
    object oTmp = GetObjectByTag(sTag,nNth);
    while(GetIsObjectValid(oTmp))
    {
        oArea   = oTmp;
        if(GetResRef(oTmp)==sRef)
            break;
        oTmp    = GetObjectByTag(sTag,++nNth);
    }

    return oArea;
}



// This is not supposed to be needed with NWNEE:
string EncodeSpecialChars(string sString)
{
        //return sString;

    if (FindSubString(sString, "'") == -1) // not found
        return sString;

    int i;
    string sReturn = "";
    string sChar;
    string Q = GetLocalString(GetModule(), "QUOTE");
    // Loop over every character and replace special characters
    for (i = 0; i < GetStringLength(sString); i++)
    {
        sChar = GetSubString(sString, i, 1);
        if (sChar == "'" || sChar == "`" || sChar == Q) // || sChar == "\")    // "
            sReturn += "~";
        else
            sReturn += sChar;
    }
    return sReturn;
}

string DecodeSpecialChars(string sString)
{

        //return sString; 
    if (FindSubString(sString, "~") == -1) // not found
        return sString;

    int i;
    string sReturn = "";
    string sChar;

    // Loop over every character and replace special characters
    for (i = 0; i < GetStringLength(sString); i++)
    {
        sChar = GetSubString(sString, i, 1);
        if (sChar == "~")
            sReturn += "'";
        else
            sReturn += sChar;
    }
    return sReturn;
}

string Data_VectorToString(vector vVector)
{
    return "#POSITION_X#" + FloatToString(vVector.x) + "#POSITION_Y#" + FloatToString(vVector.y) +
        "#POSITION_Z#" + FloatToString(vVector.z) + "#END#";
}

vector Data_StringToVector(string sVector)
{
    float fX, fY, fZ;
    int iPos, iCount;
    int iLen = GetStringLength(sVector);

    if (iLen > 0)
    {
        iPos = FindSubString(sVector, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sVector, iPos, iCount));

        iPos = FindSubString(sVector, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sVector, iPos, iCount));

        iPos = FindSubString(sVector, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sVector, iPos, iCount));
    }

    return Vector(fX, fY, fZ);
}

string Data_LocationToString(location lLocation)
{
    object oArea = GetAreaFromLocation(lLocation);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fOrientation = GetFacingFromLocation(lLocation);
    string sReturnValue;

    if (GetIsObjectValid(oArea))
        sReturnValue =
            "#AREA#" + GetTag(oArea) + "#POSITION_X#" + FloatToString(vPosition.x) +
            "#POSITION_Y#" + FloatToString(vPosition.y) + "#POSITION_Z#" +
            FloatToString(vPosition.z) + "#ORIENTATION#" + FloatToString(fOrientation) + "#END#";

    return sReturnValue;
}

location Data_StringToLocation(string sLocation)
{
    location lReturnValue;
    object oArea;
    vector vPosition;
    float fOrientation, fX, fY, fZ;

    int iPos, iCount;
    int iLen = GetStringLength(sLocation);

    if (iLen > 0)
    {
        iPos = FindSubString(sLocation, "#AREA#") + 6;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        oArea = GetObjectByTag(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sLocation, iPos, iCount));

        vPosition = Vector(fX, fY, fZ);

        iPos = FindSubString(sLocation, "#ORIENTATION#") + 13;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fOrientation = StringToFloat(GetSubString(sLocation, iPos, iCount));

        lReturnValue = Location(oArea, vPosition, fOrientation);
    }

    return lReturnValue;
}

void _SetPersistentString(object oObject, string sVarName, string sValue, string sTable = SQL_DATA_TABLE) {
        string sCharId;
        string sTag;
        if (MODULE_NWNX_MODE) {
                sCharId = GetPCID(oObject);
                if (GetIsPCSafe(oObject)) {
                        sTag = GetName(oObject); // took out encodespecialchars here
                } else {
                        sTag = GetTag(oObject);
                } 
                //sVarName = EncodeSpecialChars(sVarName);
                //sValue = EncodeSpecialChars(sValue);
                //db("SetCampaignString " + sVarName + "," + sValue + "," + NWNX_GetCampaignID() + "," + sCharId + " tag = " + sTag);
                NWNX_StoreCampaignValue(sVarName, sValue, NWNX_GetCampaignID(), sCharId, sTag, sTable);
        } else {
                // Do the NDBE call
                NBDE_SetCampaignString(CAMPAIGN_NAME, sVarName, sValue, oObject);
        }
}

void SetPersistentString(object oObject, string sVarName, string sValue, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {     
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                SetSkinString(oObject, sVarName, sValue);
        } else {
                _SetPersistentString(oObject, sVarName, sValue, sTable);
        }
}

void SetPersistentInt(object oObject, string sVarName, int nValue, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                SetSkinInt(oObject, sVarName, nValue);
        } else { 
                _SetPersistentString(oObject,  APS_INT_TYPE + sVarName, IntToString(nValue), sTable);  
        }
}
void SetPersistentFloat(object oObject, string sVarName, float fValue, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE){
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                SetSkinFloat(oObject, sVarName, fValue);
        } else { 
                _SetPersistentString(oObject,  APS_FLOAT_TYPE + sVarName, FloatToString(fValue), sTable);  
        }
}

string _GetPersistentString(object oObject, string sVarName, string sTable = SQL_DATA_TABLE) {
        string sCharId;
        string sTag;
        if (MODULE_NWNX_MODE) {
                sCharId = GetPCID(oObject);
                if (GetIsPCSafe(oObject)) {
                        sTag = GetName(oObject); // took out encodespecialchars here
                } else {
                        sTag = GetTag(oObject);
                }                         
                //sVarName = EncodeSpecialChars(sVarName);
                //return DecodeSpecialChars(NWNX_RetrieveCampaignValue(sVarName, NWNX_GetCampaignID(), sCharId, sTag));
                return NWNX_RetrieveCampaignValue(sVarName, NWNX_GetCampaignID(), sCharId, sTag, sTable);
        } else {
                return NBDE_GetCampaignString(CAMPAIGN_NAME, sVarName, oObject);
        }
        return "";
}

string GetPersistentString(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                return GetSkinString(oObject, sVarName);
        } else {
                return _GetPersistentString(oObject, sVarName, sTable);
        }
        return "";
}
int GetPersistentInt(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                return GetSkinInt(oObject, sVarName);
        } else {
                string sRet = _GetPersistentString(oObject, APS_INT_TYPE + sVarName, sTable);
                return StringToInt(sRet);
        }
}
float GetPersistentFloat(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                return GetSkinFloat(oObject, sVarName);
        } else {
                string sRet = _GetPersistentString(oObject, APS_FLOAT_TYPE + sVarName, sTable);
                return StringToFloat(sRet);
        }
}
void _DeletePersistentVariable(object oObject, string sVarName, string sTable = SQL_DATA_TABLE) {
        string sCharId;
        string sTag;
        if (MODULE_NWNX_MODE) {
                sCharId = GetPCID(oObject);
                if (GetIsPCSafe(oObject)) {
                        sTag = GetName(oObject); // Took out encodespecialchars here
                } else {
                        sTag = GetTag(oObject);
                } 
                //sVarName = EncodeSpecialChars(sVarName);
                //db("DeleteCampaignString " + sVarName + "," + NWNX_GetCampaignID() + "," + sCharId + " tag = " + sTag);
                NWNX_DeleteCampaignValue(sVarName, NWNX_GetCampaignID(), sCharId, sTag, sTable);
        } else {
                // Do the NDBE call
                NBDE_DeleteCampaignString(CAMPAIGN_NAME, sVarName, oObject);
        }

}
void DeletePersistentString(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                DeleteSkinString(oObject, sVarName);
        } else {
                _DeletePersistentVariable(oObject, sVarName, sTable);
        }
}

void DeletePersistentInt(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE) {
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                DeleteSkinInt(oObject, sVarName);
        } else {
                _DeletePersistentVariable(oObject, APS_INT_TYPE + sVarName, sTable);
        }
}
void DeletePersistentFloat(object oObject, string sVarName, string sTable = SQL_DATA_TABLE, int bUseSkin = TRUE){
        if (PERSIST_USE_SKIN && GetIsPCSafe(oObject) && bUseSkin) {
                DeleteSkinFloat(oObject, sVarName);
        } else {
                _DeletePersistentVariable(oObject, APS_FLOAT_TYPE + sVarName, sTable);
        }
}
void SetPersistentLocation(object oObject, string sVarName, location lLocation, string sTable = SQL_DATA_TABLE){
        _SetPersistentString(oObject, APS_LOC_TYPE + sVarName, Data_LocationToString(lLocation), sTable);
}
void SetPersistentVector(object oObject, string sVarName, vector vVector, string sTable = SQL_DATA_TABLE) {
        _SetPersistentString(oObject, APS_VECTOR_TYPE + sVarName, Data_VectorToString(vVector), sTable);
}
void SetPersistentObject(object oObject, string sVarName, object oValue, string sPCID = "", string sTable = SQL_OBJECT_TABLE) {

        if(MODULE_NWNX_MODE) {
                string campaign_id  = NWNX_GetCampaignID();
                string sCharID;

		if (sPCID != "") sCharID = sPCID;
		else sCharID = GetPCID(oObject);

                string sTag;
                if (GetIsPCSafe(oObject)) {
                        sTag = GetName(oObject);
                } else {
                        sTag = GetTag(oObject);
                }                         
                // if charid is still empty...
                if (sCharID == "") sCharID = "0";

                //sVarName = EncodeSpecialChars(sVarName);

                // insert OBJECT
                string sQuery = "SELECT character_id FROM campaign_object WHERE character_id=? AND campaign_id=? AND label=? AND tag=?;";
                NWNX_SqlExecPrepared(sQuery, sCharID, campaign_id, sVarName, sTag);
                if (!NWNX_SQL_ReadyToReadNextRow()) {
                        sQuery = "INSERT INTO campaign_object (character_id,campaign_id,label, tag) VALUES (?,?,?,?);" ;
                        //db(sQuery);
                        NWNX_SqlExecPrepared(sQuery, sCharID, campaign_id, sVarName, sTag);
                }
                //string sQuery = "INSERT INTO campaign_object (character_id,campaign_id,label,tag) VALUES (?,?,?,?)" 
                //+ " ON DUPLICATE KEY UPDATE character_id=VALUES(character_id);" ;
		//db(sQuery);
                //NWNX_SqlExecPrepared(sQuery, sCharID, campaign_id, sVarName, sTag);
  
                sQuery = "UPDATE campaign_object SET object=? WHERE character_id="+sCharID+" AND campaign_id="
                         +campaign_id+" AND label=? AND tag=?;";
		//db(sQuery);
                NWNX_StoreObject(sQuery, oValue, oObject, sVarName, sTag);
        } else {
                StoreCampaignObject(CAMPAIGN_NAME, sVarName, oValue, oObject);
        }
}

location GetPersistentLocation(object oObject, string sVarName, string sTable = SQL_DATA_TABLE) { 
        string sRet = _GetPersistentString(oObject, APS_LOC_TYPE + sVarName, sTable);
        return Data_StringToLocation(sRet);
}
vector GetPersistentVector(object oObject, string sVarName, string sTable = SQL_DATA_TABLE){ 
        string sRet = _GetPersistentString(oObject, APS_VECTOR_TYPE + sVarName, sTable);
        return Data_StringToVector(sRet);
}

object GetPersistentObjectLoc(object oObject, string sVarName, location lLoc, object oOwner = OBJECT_INVALID, string sPCID = "", int object_type = OBJECT_TYPE_CREATURE, string sTable = SQL_OBJECT_TABLE) {
        object campaign_object;
      
        if(MODULE_NWNX_MODE) {
                string campaign_id  = NWNX_GetCampaignID();
                string character_id;
		if (sPCID != "")
			character_id = sPCID;
		else
			character_id =  GetPCID(oObject);
                
		string sTag;
                if (GetIsPCSafe(oObject)) {
                        sTag = GetName(oObject); // removed encoodespecialchars
                } else {
                        sTag = GetTag(oObject);
                }                         
                //sVarName = EncodeSpecialChars(sVarName);
                string query = "SELECT object FROM campaign_object WHERE character_id="+character_id+" AND campaign_id="
                +campaign_id+" AND label=? AND tag=?;";
		//db(query);
                campaign_object = NWNX_RetrieveObject(query, lLoc, oOwner, sVarName, sTag);
        } else {
                campaign_object = RetrieveCampaignObject(CAMPAIGN_NAME, sVarName, lLoc, oOwner, OBJECT_INVALID);
        }

        return campaign_object;
}

object GetPersistentObject(object oObject, string sVarName, object oOwner = OBJECT_INVALID, string sPCID = "", int object_type = OBJECT_TYPE_CREATURE, string sTable = SQL_OBJECT_TABLE) {
        object campaign_object;
        location lLoc;
        if (GetIsObjectValid(oOwner)) {
                lLoc = GetLocation(oOwner);
        } else {
                lLoc = GetLocation(oObject);
                //oOwner = oObject;
        }
	return  GetPersistentObjectLoc(oObject, sVarName, lLoc, oOwner, sPCID, object_type, sTable);
}

void DeletePersistentLocation(object oObject, string sVarName, string sTable = SQL_DATA_TABLE) {
        _DeletePersistentVariable(oObject, APS_LOC_TYPE + sVarName, sTable);
}
void DeletePersistentVector(object oObject, string sVarName, string sTable = SQL_DATA_TABLE) {
        _DeletePersistentVariable(oObject, APS_VECTOR_TYPE + sVarName, sTable);
}
void DeletePersistentObject(object oObject, string sVarName, string sTable = SQL_OBJECT_TABLE);

void CreatePersistentInventory(string inventory_tag, object source_inventory, string pcid="TBD", int store_in_db=TRUE, int clone_inventory=TRUE)
{

    db("DATA: CreatePersistentInventory called for  " + GetName(source_inventory) + " pcid = " + pcid);
    if(!GetHasInventory(source_inventory)) {
        db("DATA: CreatePersistent - no inventory!");
        return;
    }

    int is_creature = (GetObjectType(source_inventory)==OBJECT_TYPE_CREATURE);

    location lLoc   = GetLocation(GetWaypointByTag(WP_INVENTORY));
    if(pcid=="TBD")
    {
        if( is_creature )
        {
            pcid = GetPCID(source_inventory);
            if(!StringToInt(pcid))
                pcid = "0";
        }
        else
            pcid = "0";
    }

    object oInventory   = CreateObject( OBJECT_TYPE_CREATURE,
                                        "inventory",
                                        lLoc,
                                        FALSE,
                                        inventory_tag
                                      );
    SetLocalString(oInventory,"OWNER_PCID",pcid);
    SetLocalObject(source_inventory,"PERSISTENT_INVENTORY", oInventory);
    SetLocalInt(oInventory,"STORE_IN_DB", store_in_db);

    db("DATA: CreatePersistentInventory inventory got " + GetName(oInventory) + " for " + pcid);

    if(clone_inventory) //------------------ clone the inventory
    {
        if(is_creature)
            MoveEquippedItems(source_inventory, oInventory, TRUE);
        MoveInventory(source_inventory, oInventory, TRUE);
    }
    // let the creature know that it should save itself in the next minute
    // No... this needs to be pretty much right now otherwise with logout and/or crash PC loses everything
    SignalEvent(oInventory, EventUserDefined(EVENT_COMMIT_OBJECT_TO_DB));
}

void RetrievePersistentInventory(string inventory_tag, object target_inventory, string pcid="0")
{
    if(!GetHasInventory(target_inventory))
        return;

    //location lLoc   = GetLocation(GetWaypointByTag(WP_INVENTORY));

    object oInventory   = GetPersistentInventory(inventory_tag, pcid);
    db("DATA: RetreivePersistentInventory got '" + GetName(oInventory) + "' ('" + GetTag(oInventory) + "') for " + pcid);
    if(GetIsObjectValid(oInventory))
    {
        SetLocalObject(target_inventory,"PERSISTENT_INVENTORY", oInventory);
        // clone the inventory
        MoveEquippedItems(oInventory, target_inventory, TRUE);
        MoveInventory(oInventory, target_inventory, TRUE);

        // this is necessary for tracking when gold is taken from the target
        SetLocalInt(target_inventory, "INVENTORY_GOLD", GetGold(target_inventory));
    } else {
        err("RetrievePersistentInventory: Failed to find " + inventory_tag);
    }
}

object GetPersistentInventory(string inventory_tag, string pcid="0")
{
    object oInventory   = GetObjectByTag(inventory_tag);
    db("DATA: GetPersistentInventory got '" + GetName(oInventory) + "' ('" + GetTag(oInventory) + "') for " + pcid);
    if(!GetIsObjectValid(oInventory))
    {
        location lLoc= GetLocation(GetWaypointByTag(WP_INVENTORY));
        //oInventory = Data_RetrieveCampaignObject(inventory_tag, lLoc, OBJECT_INVALID, OBJECT_INVALID, pcid);
	oInventory = GetPersistentObjectLoc(GetModule(), "inventory", lLoc, OBJECT_INVALID, pcid);
        db("DATA: GetPersistentInventory got '" + GetName(oInventory) + "' ('" + GetTag(oInventory) + "') for " + pcid);
        if(GetIsObjectValid(oInventory))
        {
            SetLocalInt(oInventory,"STORE_IN_DB",TRUE);
            SetLocalString(oInventory,"OWNER_PCID",pcid);
        }
    }
    SetLocalInt(oInventory, "CANCEL_CLEANUP", TRUE);

    return oInventory;
}

// check spells 0..MAX_SPELLS
// These should match the 2da files
const int MAX_SPELLS = 1079; //spells.2da
const int MAX_FEATS = 2035;  // feat.2da

void pwSavePCSpellsAndFeats(object oPC) {

        if (!GetIsPCSafe(oPC)) {
                WriteTimestampedLogEntry("PW pwSavePCSpellsAndFeats player does not have PC set anymore?");
                return;
        }

        object oMod = GetModule();
        //int nId = GetPlayerId(oPC);
        string sId = GetPCID(oPC);

        // TODO - NWNX can make this more efficient.
 // Spells - store only the spells we know (e.g.  13:2 15:1 )
        int nSpell;
        int nNumSpell;
        string sSpellList = " ";
        for(nSpell = 0; nSpell < MAX_SPELLS; nSpell++) {
                if (nNumSpell = GetHasSpell(nSpell,oPC)) {
                        sSpellList += IntToString(nSpell) + ":" + IntToString(nNumSpell) + " ";
                }
        }

        SetLocalString(oMod, "PC_SPELL_LIST_" + sId, sSpellList);
        SetPersistentString(oPC, "SPELL_LIST", sSpellList, "spells_feats", FALSE);
        //SetPersistentString(oMod, "SPELL_LIST_" + sId, sSpellList);


        // Feats - store counts of feats we know
        int nFeat;
        int nNumFeat;
        string sFeatList = " ";
        for(nFeat = 0; nFeat < MAX_FEATS; nFeat++) {
                if (nNumFeat = GetHasFeat(nFeat,oPC)) {
                        sFeatList += IntToString(nFeat) + ":" + IntToString(nNumFeat) + " ";
                }
        }
        SetLocalString(oMod, "PC_FEAT_LIST_" + sId, sFeatList);
        SetPersistentString(oPC, "FEAT_LIST", sFeatList, "spells_feats", FALSE);
        //SetPersistentString(oMod, "FEAT_LIST_" + sId, sFeatList);


  // debug
        if (GetLocalInt(oMod, "DBEUG_LEVEL") & (0x10)) { // PW_DEBUG...
                string sName = GetName(oPC);
                PrintString( sName + " exiting with spell list: " + sSpellList);
                PrintString(sName + " exiting with feat list: " + sFeatList);
        }
}

void pwLoadPCSpellsAndFeats(object oPC) {
        object oMod = GetModule();
        //int nId = GetPlayerId(oPC);
        string sId = GetPCID(oPC);
         // spells
        int nNumSpell;
        int nSpell;

        string sOldSpellList = GetLocalString(oMod,"PC_SPELL_LIST_" + sId);
        if (sOldSpellList == "" || sOldSpellList == " ") { // try DB
                sOldSpellList = GetPersistentString(oPC,"SPELL_LIST", "spells_feats", FALSE);
                //sOldSpellList = GetPersistentString(oMod,"SPELL_LIST_" + sId);
        }
        // Still nothing then we're done. 
        if (sOldSpellList == "" || sOldSpellList == " ") {
                return;
        }

        // TODO - this could be done more efficiently? But then we'd miss clearing spells not listed in the DB.
        for(nSpell=0; nSpell < MAX_SPELLS; nSpell++) {
                if (nNumSpell = GetHasSpell(nSpell,oPC)) {
                        string sLookfor = " " + IntToString(nSpell) + ":";
                        int nStart = FindSubString(sOldSpellList,sLookfor);
                        if (nStart >= 0) {
                                while (GetSubString(sOldSpellList,nStart,1) != ":") nStart++;
                                int nEnd = nStart+1;
                                while (GetSubString(sOldSpellList,nEnd,1) != " ") nEnd++;
                                string sSub = GetSubString(sOldSpellList,nStart+1,nEnd-nStart);
                                int nOldNumSpell= StringToInt( sSub);
                                int nSpellDiff = nNumSpell - nOldNumSpell;
                                int nUses;
                                for (nUses=0; nUses<nSpellDiff; nUses++) {
                                        DecrementRemainingSpellUses(oPC,nSpell);
                                }
         // check to see if it worked
                                int nNewNumSpell = GetHasSpell(nSpell,oPC);
                                if (nNewNumSpell != nOldNumSpell) {
                                       PrintString("PWH anticheat - could not restore spell #" + sLookfor + " old:" + sSub
                                                + ",new:" + IntToString(nNewNumSpell));
                                //SendMessageToPC(oPC,"Debug - can't restore spell #"+sLookfor+" old="+
                                //       sSub+" new="+IntToString(nNewNumSpell));
                               }
                        } else {
                                // wipe all uses
                                int nUses;
                                for (nUses = 0; nUses < nNumSpell; nUses++) {
                                        DecrementRemainingSpellUses(oPC, nSpell);
                                }
                        }

                }
        }

        string sOldFeatList = GetLocalString(oMod, "PC_FEAT_LIST_" + sId);
        if (sOldFeatList == "") { // try DB
                sOldFeatList = GetPersistentString(oPC,"FEAT_LIST", "spells_feats", FALSE);
                //sOldFeatList = GetPersistentString(oMod,"FEAT_LIST_" + sId);
        }
        int nFeat;
        int nNumFeat;
        for(nFeat = 0; nFeat < MAX_FEATS; nFeat++) {
                if (nNumFeat = GetHasFeat(nFeat, oPC)) {
                        string sLookfor = " "+IntToString(nFeat)+":";
                        int nStart = FindSubString(sOldFeatList,sLookfor);
                        if (nStart >= 0) {
                                while (GetSubString(sOldFeatList,nStart,1) != ":") nStart++;
                                int nEnd = nStart+1;
                                while (GetSubString(sOldFeatList,nEnd,1) != " ") nEnd++;
                                string sSub = GetSubString(sOldFeatList,nStart+1,nEnd-nStart);
                                int nOldNumFeat= StringToInt( sSub);
                                int nFeatDiff = nNumFeat - nOldNumFeat;
                                int nUses;
                                for (nUses=0;nUses<nFeatDiff;nUses++) {
                                        DecrementRemainingFeatUses(oPC,nFeat);
                                }
         // check to see if it worked
                                int nNewNumFeat = GetHasFeat(nFeat,oPC);
                                if (nNewNumFeat != nOldNumFeat) {
                                       PrintString("PWH anticheat - could not restore feat #" + sLookfor + " old:" + sSub
                                               + ",new:"+IntToString(nNewNumFeat));
                                  //SendMessageToPC(oPC,"Debug - can't restore feat #"+sLookfor+" old="+
                                  //       sSub+" new="+IntToString(nNewNumFeat));
                                }
                        } else {
        // wipe all uses
                                int nUses;
                                for (nUses=0;nUses<nNumFeat;nUses++) {
                                        DecrementRemainingFeatUses(oPC,nFeat);
                                }
                        }

                }
        }
}


// -- SPECIALIZED NWNX calls ---

string NWNX_GetCampaignID() {
        object oModule = GetModule();
        string campaign_id  = GetLocalString(oModule, "CAMPAIGN_ID");
        if(campaign_id!=""){ return campaign_id;}

        if (MODULE_NWNX_MODE) {
                // INITIALIZE CAMPAIGN BEGIN ----
                NWNX_SqlExecPrepared("SELECT campaign_id FROM campaigns WHERE name=?;", CAMPAIGN_NAME);
                if(!NWNX_SQL_ReadyToReadNextRow()) {
                // campaign is missing from DB?
                 //CREATE CAMPAIGN BEGIN

                        // store the campaign in the campaigns table
                        NWNX_SqlExecPrepared("INSERT INTO campaigns (name) VALUES (?);", CAMPAIGN_NAME);
                        NWNX_SqlExecDirect("SELECT LAST_INSERT_ID();"); // get the index

                //CREATE CAMPAIGN END
                }
                NWNX_SQL_ReadNextRow();
                campaign_id = NWNX_SQL_ReadDataInActiveRow(0);
        } else {
                campaign_id = "1";
        } 
        SetLocalString(oModule, "CAMPAIGN_ID", campaign_id);// complete initialization
        // INITIALIZE CAMPAIGN END ----
        return campaign_id;
}

// New NWNEE code where player id is tied to cdkey not name.
// This only deals with the unique player_id to cdkey mapping. 
// Does not put the player by name into the players table. That needs to be 
// handled in the validation code. 
string NWNX_GetPlayerID(object oPC)
{
    string sPlayerID    = GetLocalString(oPC, "PLAYER_ID");

    if(sPlayerID!="")
        return sPlayerID;

    // INITIALIZE PLAYER OBJECT BEGIN ----
    string sPlayerName  = GetPCPlayerName(oPC);  
    string sCDKey   = GetPCPublicCDKey(oPC);

    NWNX_SqlExecPrepared("SELECT player_id, banned FROM player_cdkeys WHERE cdkey_public=?;", sCDKey);

    // player is missing from DB?
    if(!NWNX_SQL_ReadyToReadNextRow())
    {
        //INSERT PLAYER IN DB BEGIN ----
        // store the cd key for adding later
        sCDKey   = GetPCPublicCDKey(oPC);
        // add player to DB
        NWNX_SqlExecPrepared("INSERT INTO player_cdkeys (cdkey_public) VALUES (?);", sCDKey);
        //INSERT PLAYER IN DB END ----

        // re-query for player
        NWNX_SqlExecPrepared("SELECT player_id, banned FROM player_cdkeys WHERE cdkey_public=?;", sCDKey);
    }
    // Assuming we're ready to read here
    NWNX_SQL_ReadNextRow();

    sPlayerID           = NWNX_SQL_ReadDataInActiveRow(0);
    int bBanned         = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));

    // is the player banned?
    if(bBanned) {
        sPlayerID = "BANNED";
    } 
    // complete initialization
    SetLocalString(oPC,"PLAYER_ID",sPlayerID);
    // INITIALIZE PLAYER OBJECT END ----

    return sPlayerID;
}

// Original code 
string NWNX_GetPlayerID0(object oPC)
{
    string sPlayerID    = GetLocalString(oPC, "PLAYER_ID");

    if(sPlayerID!="")
        return sPlayerID;

    // INITIALIZE PLAYER OBJECT BEGIN ----
    string sPlayerName  = GetPCPlayerName(oPC); 
    NWNX_SqlExecPrepared("SELECT player_id, banned FROM players WHERE name=?;", sPlayerName);

    // we may need to store the CD Key if we INSERT the player in the database
    string sCDKey   = "";

    // player is missing from DB?
    if(!NWNX_SQL_ReadyToReadNextRow())
    {
        //INSERT PLAYER IN DB BEGIN ----
        // store the cd key for adding later
        sCDKey   = GetPCPublicCDKey(oPC);
        // add player to DB
        NWNX_SqlExecPrepared("INSERT INTO players (name) VALUES (?);", sPlayerName);
        //INSERT PLAYER IN DB END ----

        // re-query for player
        NWNX_SqlExecPrepared("SELECT player_id, banned FROM players WHERE name=?;", sPlayerName);
    }
    // Assuming we're ready to read here
    NWNX_SQL_ReadNextRow();

    sPlayerID           = NWNX_SQL_ReadDataInActiveRow(0);
    int bBanned         = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));

    // is the player banned?
    if(bBanned) {
        sPlayerID = "BANNED";
    } else if(sCDKey!="") {
        // add cdkey to DB
        NWNX_SqlExecPrepared("INSERT INTO player_cdkeys (player_id,cdkey_public) VALUES (?,?);", sPlayerID, sCDKey);
    }
    // complete initialization
    SetLocalString(oPC,"PLAYER_ID",sPlayerID);
    // INITIALIZE PLAYER OBJECT END ----

    return sPlayerID;
}

// This should not be called directly by clients
string NWNX_GetCharacterID(object oCharacter) { 
        string sCharID;
        if(GetIsPCSafe(oCharacter) && (!GetIsPossessedFamiliar(oCharacter) && !GetIsDMPossessed(oCharacter))) {
                int is_dm           = GetIsDM(oCharacter);
                string type         = "PC";
                if(is_dm){  type    = "DM"; }
                //name and player ID are needed
                string sPlayerID    = NWNX_GetPlayerID(oCharacter);
                string sCharName    = GetName(oCharacter);

                NWNX_SqlExecPrepared("SELECT a.character_id FROM characters as a JOIN characters_"+GetStringLowerCase(type)+" as b USING (character_id) " 
                        + " WHERE a.name=? AND b.player_id=?", sCharName, sPlayerID);
                if(NWNX_SQL_ReadyToReadNextRow()) {
                        NWNX_SQL_ReadNextRow();
                        sCharID = NWNX_SQL_ReadDataInActiveRow(0);
                } else {  
                        // not found so commit to DB
                        // need to commit this PC/DM to the DB and then get the result
                        // first commit to character table
                        NWNX_SqlExecPrepared("INSERT INTO characters (name,type) VALUES (?,?);", sCharName, type);
                        NWNX_SqlExecDirect("SELECT LAST_INSERT_ID();");
                        // next commit to the PC/DM table if we created a new character successfuly
                        if(NWNX_SQL_ReadyToReadNextRow()) {
                                NWNX_SQL_ReadNextRow();
                                sCharID = NWNX_SQL_ReadDataInActiveRow(0);
                                if(sCharID == "") return "";
                        // we  now have the row number from characters table to use in further inserts
                        // insert DM
                                if(is_dm) {
                                        NWNX_SqlExecPrepared("INSERT INTO characters_dm (character_id,player_id) VALUES (?,?);", sCharID, sPlayerID);
                                } else {
                                        string sFilename    = NWNX_GetPCFilename(oCharacter); // get the filename
                                        NWNX_SqlExecPrepared("INSERT INTO characters_pc (character_id,player_id,filename) VALUES (?,?,?);", sCharID, sPlayerID, sFilename);
                                }
                        } else {
                                return "";
                        }
                }
        }  else {
                // NPCS, Possessed familiars, and DM Possessed characters
                if(GetIsPossessedFamiliar(oCharacter)) {
                        // need to use the associate table too
                        // but not ready for this
                } else { // regular NPCs and DM possessed
                        //name, resref, and tag are needed
                        string sCharName    = GetName(oCharacter);
                        string sResRef      = GetResRef(oCharacter);
                        string sTag         = GetTag(oCharacter);
                        string campaign_id  = NWNX_GetCampaignID();

                        NWNX_SqlExecPrepared("SELECT a.character_id FROM characters as a"
                          +" JOIN characters_npc as b USING (character_id)"
                          +" WHERE a.name=? AND a.type='NPC' AND b.campaign_id=? AND b.resref=? AND b.tag=?;",
                          sCharName, campaign_id, sResRef, sTag);
                        if(NWNX_SQL_ReadyToReadNextRow()) {
                                NWNX_SQL_ReadNextRow();
                                sCharID =  NWNX_SQL_ReadDataInActiveRow(0); 
                        } else {// not found so commit to DB
                                // first commit to character table
                                NWNX_SqlExecPrepared("INSERT INTO characters (name,type) VALUES (?,'NPC');", sCharName);
                                NWNX_SqlExecDirect("SELECT LAST_INSERT_ID();");
                // next commit to the NPC table if we created a new character successfuly
                                if(NWNX_SQL_ReadyToReadNextRow()) {
                                        NWNX_SQL_ReadNextRow();
                                        sCharID =  NWNX_SQL_ReadDataInActiveRow(0); 
                                        if(sCharID == "") return "";
                                        // we  now have the row number from characters table to use in further inserts
                                        // insert NPC
                                        NWNX_SqlExecPrepared( "INSERT INTO characters_npc (character_id,campaign_id,resref,tag)"
                                               +" VALUES (?,?,?,?);", sCharID, campaign_id, sResRef, sTag);
                                        if(GetLocalInt(oCharacter,"UNIQUE") ||  GetPlotFlag(oCharacter)) {
                                                NWNX_SqlExecPrepared("UPDATE characters_npc SET plot=1, dead=?," 
                                                        + " hitpoints=? WHERE character_id=? AND campaign_id=?;",
                                                        IntToString(GetIsDead(oCharacter)), 
                                                        IntToString(GetCurrentHitPoints(oCharacter)),
                                                        sCharID, 
                                                        campaign_id);
                                               
                                                // campaign_id and sCharID never have special characters
                                                string sQuery = "INSERT INTO campaign_object (campaign_id,character_id,label,object)"
                                                        +" VALUES ("+campaign_id+","+sCharID+",'NPC',?);";
                                                NWNX_StoreObject(sQuery, oCharacter);
                                        }
                                } else {
                                       // error
                                       return "";
                                }
                        }
                }
        }

        if(StringToInt(sCharID)) {
                // keep association of which campaign the character is used in
                string campaign_id  = NWNX_GetCampaignID();
                NWNX_SqlExecPrepared("INSERT INTO campaign_characters (character_id,campaign_id,lastlog_time_real) VALUES (?, ?, NOW())"
                      +" ON DUPLICATE KEY UPDATE lastlog_time_real=VALUES(lastlog_time_real);", sCharID, campaign_id);
        }

        // Don't need to see this here - caller (GetPCID) will set it. 
        //SetLocalString(oCharacter,"CHARACTER_ID",sCharID);
        return sCharID;
}

string NWNX_ConvertNPCIDtoCharacterID(string sNPCID)
{
    // reverse engineer character_id
    int nPos1   = FindSubString(sNPCID,"¤")+1;
    int nPos2   = FindSubString(sNPCID,"¤",nPos1);
    string sCharName    = GetStringLeft(sNPCID,nPos1);
    string sResRef      = GetSubString(sNPCID,nPos1,nPos2-nPos1);
    string sTag         = GetStringRight(sNPCID, GetStringLength(sNPCID)-(nPos2+1));

    NWNX_SqlExecPrepared("SELECT a.character_id FROM characters as a"
                      +" JOIN characters_npc as b USING (character_id)"
                      +" WHERE a.name=? AND a.type='NPC' AND b.campaign_id=? AND b.resref=? AND b.tag=?;",
                      sCharName, NWNX_GetCampaignID(), sResRef, sTag);
    if(NWNX_SQL_ReadyToReadNextRow()) {
        NWNX_SQL_ReadNextRow();
        return NWNX_SQL_ReadDataInActiveRow(0);
    } else
        return "";
}

string NWNX_GetPCFilename(object oPC)
{
    if(!GetIsPC(oPC)||GetIsDM(oPC))
        return "";
    if(GetLocalString(oPC,"CHARACTER_FILENAME")!="")
        return GetLocalString(oPC,"CHARACTER_FILENAME");

        // Not implemented in nwnx:ee
    //SetLocalString(oPC, "NWNX!FUNCS!GETPCFILENAME", "                    ");
    //string sFilename    = GetLocalString(oPC, "NWNX!FUNCS!GETPCFILENAME");

    // TODO - remove spaces and special chars
    string sFilename = GetStringLowerCase(GetName(oPC));

    SetLocalString(oPC,"CHARACTER_FILENAME",sFilename);
    return sFilename;
}

void NWNX_StoreLocation(string type, location lLoc, string character_id )
{
    if(!StringToInt(character_id))
        return; // error

    object oArea        = GetAreaFromLocation(lLoc);
    string area_id      = GetIDFromArea(oArea); // DB value

    vector vPos         = GetPositionFromLocation(lLoc);
    string xpos     = IntToString(FloatToInt(vPos.x*100));
           xpos     = (GetStringLength(xpos) < 5)  ? GetStringLeft("00000", 5-GetStringLength(xpos))+xpos   : GetStringLeft(xpos,5);
    string ypos     = IntToString(FloatToInt(vPos.y*100));
           ypos     = (GetStringLength(ypos) < 5)  ? GetStringLeft("00000", 5-GetStringLength(ypos))+ypos   : GetStringLeft(ypos,5);
    string zpos     = IntToString(FloatToInt(vPos.z*100));
           zpos     = (GetStringLength(zpos) < 5)  ? GetStringLeft("00000", 5-GetStringLength(zpos))+ypos   : GetStringLeft(zpos,5);
    string position = xpos+ypos+zpos;// DB value

    float fFacing   = GetFacingFromLocation(lLoc);
    string facing   = IntToString(FloatToInt(fFacing*100)); // DB value
           facing   = (GetStringLength(facing) < 5)  ?  GetStringLeft("00000", 5-GetStringLength(facing))+facing : GetStringLeft(facing,5);

    // commit to DB
    string sQuery = "INSERT INTO campaign_locations (character_id, campaign_id, type, area_id, position, facing) "
                 +"VALUES("+character_id+","+NWNX_GetCampaignID()+",'"+type+"','"+area_id+"','"+position+"','"+facing+"') "
                 +"ON DUPLICATE KEY UPDATE area_id=VALUES(area_id), position=VALUES(position), facing=VALUES(facing);";
    NWNX_SqlExecDirect(sQuery);
}

location NWNX_RetrieveLocation(string type, string character_id)
{
    location return_location;
    string sLocation    = "";

    // retrieve from DB
    string sSQL = "SELECT area_id, position, facing FROM campaign_locations"
                 +" WHERE character_id=? AND type=? AND campaign_id=?;";
                 //+" ORDER BY time_real DESC LIMIT 1"// this is only necessary if we eliminate the unique keys
                 
    NWNX_SqlExecPrepared(sSQL, character_id, type, NWNX_GetCampaignID());

    if(NWNX_SQL_ReadyToReadNextRow()) {
        NWNX_SQL_ReadNextRow();
        // area from area_id
        object area     = GetAreaFromID(NWNX_SQL_ReadDataInActiveRow(0));

        // build position vector
        string sPos = NWNX_SQL_ReadDataInActiveRow(1);
        vector position = Vector((StringToFloat(GetSubString(sPos, 0,5))/100.0), // x
                                 (StringToFloat(GetSubString(sPos, 5,5))/100.0),// y
                                 (StringToFloat(GetSubString(sPos, 10,5))/100.0)// z
                                 );
        // convert to float
        string sFace    = NWNX_SQL_ReadDataInActiveRow(2);
        float facing    = StringToFloat(sFace)/100.0f;

        // reassemble all the pieces
        return_location = Location(area,position,facing);
    }

    return return_location;
}

void NWNX_DeleteLocation(string type, string character_id)
{
    // retrieve from DB
    string sSQL = "DELETE FROM campaign_locations WHERE character_id=? AND type=? AND campaign_id=?;";
                 //+" ORDER BY time_real DESC LIMIT 1"// this is only necessary if we eliminate the unique keys
                 
    NWNX_SqlExecPrepared(sSQL, character_id, type, NWNX_GetCampaignID());
}

int NWNX_RetrieveCharacterXP(string character_id, string types="ALL", string campaign_id="ANY")
{
    int nXP = 0; // value to return on error

    // assemble sql query
    string sQuery = "SELECT SUM(value) FROM character_xp WHERE character_id="+character_id;
    if(campaign_id!="ANY")
        sQuery += " AND campaign_id="+campaign_id;
    if(types!="ALL")
    {
        int nPos   = FindSubString(types," ");
        if(nPos==-1)
            sQuery += " AND type='"+types+"'";
        // parse types as a series: type type type
        // this feature allows the script to receive a space separated list of types
        else
        {
            sQuery += " AND (";
            string sSubQuery;
            while(nPos>-1)
            {
                if(sSubQuery!="")
                    sSubQuery   += " OR ";
                sSubQuery   += "type = '"+GetStringLeft(types,nPos)+"'";
                types  = GetStringRight(types,GetStringLength(types)-(nPos+1));
                nPos   = FindSubString(types," ");
                if(nPos==-1)
                {
                    sSubQuery   += " OR type = '"+types+"'";
                    break;
                }
            }

            sQuery += sSubQuery+")";
        }
    }
    sQuery += ";";

    // This is left as a direct query due to the complex way the query is built.
    NWNX_SqlExecDirect(sQuery);

    if(NWNX_SQL_ReadyToReadNextRow()) {
        NWNX_SQL_ReadNextRow();
        nXP = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); 
        }
    return nXP;
}

void NWNX_StoreCharacterXP(int nXP, string character_id, string type, string campaign_id)
{
    // commit to DB
    string sXP    = IntToString(nXP);
    string sQuery = "INSERT INTO character_xp (character_id, campaign_id, type, value) "
                 +"VALUES("+character_id+","+campaign_id+",'"+type+"',"+sXP+") "
                 +"ON DUPLICATE KEY UPDATE value = value + "+sXP+";";

    NWNX_SqlExecDirect(sQuery);
}

string NWNX_RetrieveCampaignValue(string label, string campaign_id, string character_id="0", string tag = "MODULE", string table = "campaign_data")
{
    string sQuery = "SELECT value FROM campaign_data WHERE character_id=? AND campaign_id=? AND tag=? AND label=?;";

    //db("RetrieveCampaignValue '" + sQuery + "'");
    NWNX_SqlExecPrepared(sQuery, character_id, campaign_id, tag, label);
    if(NWNX_SQL_ReadyToReadNextRow()) {
	    NWNX_SQL_ReadNextRow();
	    return NWNX_SQL_ReadDataInActiveRow(0);
    } else {
	    //   db("RetrieveCampaignValue select failed");
	    return "";
    }
    
}

void NWNX_StoreCampaignValue(string label, string value, string campaign_id, string character_id="0", string tag = "MODULE", string table = "campaign_data") 
{
    string sQuery   = "INSERT INTO campaign_data (character_id, campaign_id, tag, label, value) "
                    + "VALUES("+character_id+","+campaign_id+", ?, ?, ?) ON DUPLICATE KEY UPDATE value = ?;";
    //db("StoreCampaignValue '" + sQuery + "'");
    NWNX_SqlExecPrepared(sQuery, tag, label, value, value);
}

void NWNX_DeleteCampaignValue(string label, string campaign_id, string character_id="0", string tag = "MODULE",string table = "campaign_data")  {
    string sQuery   = "DELETE FROM campaign_data WHERE character_id=? AND campaign_id=? AND tag=?;";
	 
    //db("DeleteCampaignValue '" + sQuery + "'");
    NWNX_SqlExecPrepared(sQuery, character_id, campaign_id, tag);
}

// Timestamps 
// UNUSED
string NWNX_GetTimeStampCreatedOf(string sEntity, string id)
{
    string creation_time;

    NWNX_SqlExecPrepared("SELECT creation_time_real FROM "+sEntity+"s WHERE "+sEntity+"_id=?;", id);
    if(NWNX_SQL_ReadyToReadNextRow()) {
        NWNX_SQL_ReadNextRow();
        creation_time = NWNX_SQL_ReadDataInActiveRow(0); 
    }

    return creation_time;
}

// UNUSED
string NWNX_GetTimeStampNow()
{
    string now;

    NWNX_SqlExecDirect("SELECT NOW();");
    if(NWNX_SQL_ReadyToReadNextRow()) {
        NWNX_SQL_ReadNextRow();
        now = NWNX_SQL_ReadDataInActiveRow(0);
    }
    return now;
}

int NWNX_GetTimeStampDifference(string now, string then, int TIME_TYPE=TIME_MINUTES)
{
    string sType;
    // calendar difference
    if(TIME_TYPE==TIME_YEARS)       // year difference
        sType   = "YEAR";
    else if(TIME_TYPE==TIME_MONTHS) // month difference
        sType   = "MONTH";
    else if(TIME_TYPE==TIME_DAYS)   // day difference
        sType   = "DAY";
    // time differences
    else if(TIME_TYPE==TIME_HOURS)  // hours difference
        sType   = "HOUR";
    else if(TIME_TYPE==TIME_MINUTES)// minutes difference
        sType   = "MINUTE";
    else if(TIME_TYPE==TIME_SECONDS)// seconds difference
        sType   = "SECOND";
    else
        return 0;

    NWNX_SqlExecPrepared("SELECT TIMESTAMPDIFF(?,?,?);", sType, then, now);
    if(NWNX_SQL_ReadyToReadNextRow()) {
           NWNX_SQL_ReadNextRow();
           return StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    return 0; // error
}

// -- BASE SQL functions through NWNX --
// NWNX_ODBC2
// converted to NWNX:EE
void NWNX_SqlExecDirect(string sSQL)
{
    //SetLocalString(GetModule(), "NWNX!ODBC2!EXEC", sSQL);
    if (!NWNX_SQL_ExecuteQuery(sSQL)) {
        WriteTimestampedLogEntry("FAILED SQL QUERY '" + sSQL + "'");
    }
}

// Prepare and execute the given query. Variable substitutions should be set to "?", 
// Arg0 must be non-empty before arg1, etc. 
// Arguments must be strings but using prepared means the do not need to be encoded for special characters. 
int NWNX_SqlExecPrepared(string query, string arg0 = "", string arg1 = "", string arg2 = "", string arg3 = "") {
	if (NWNX_SQL_PrepareQuery(query)) {
		if (arg0 != "") {
			NWNX_SQL_PreparedString(0, arg0);
			if (arg1 != "") {
				NWNX_SQL_PreparedString(1, arg1);
				if (arg2 != "") {
					NWNX_SQL_PreparedString(2, arg2);
					if (arg3 != "") {
						NWNX_SQL_PreparedString(3, arg3);
					}
				}
			}
		}
		if (!NWNX_SQL_ExecutePreparedQuery()) {
                        WriteTimestampedLogEntry("NWNX_SqlExecPrepared: Failed to execute query :'"  + query + "'");
			return FALSE;
                } else {
			return TRUE;
		}
	}
	
	WriteTimestampedLogEntry("NWNX_SqlExecPrepared: Failed to prepare query: '" + query + "'");
	return FALSE;
		
}


// NWNX:EE version. Query must have one variable to replace (using "?") firt. It may then have up to 2 string replacements.
// Owner is unused. 
void NWNX_StoreObject(string query, object obj, object owner=OBJECT_INVALID, string arg1 = "", string arg2 = "")
{

        if (NWNX_SQL_PrepareQuery(query)) {
                NWNX_SQL_PreparedObjectFull(0, obj);
                if (arg1 != "") {
                        NWNX_SQL_PreparedString(1, arg1);
                        if (arg2 != "") {
                                NWNX_SQL_PreparedString(2, arg2);
                        }
                }
                
                if (!NWNX_SQL_ExecutePreparedQuery()) {
                        WriteTimestampedLogEntry("NWNX_StoreObject: Failed to store object " 
                        + GetTag(obj) +  ":: '" + query + "'");
                }
        } else {
                WriteTimestampedLogEntry("NWNX_StoreObject: Failed to prepare query, object " 
                        + GetTag(obj) +  ":: '" + query + "'");
        }
}

// NWNX:EE Owner is target object and should be set (and have Inventory) if the object is an item. 
// Query may have up to two string arguments
// object_type is no longer used.   Location must be valid if owner is not 
object NWNX_RetrieveObject(string query, location where, object owner = OBJECT_INVALID, string arg0 = "", string arg1 = "")
{
        // NWNX:EE version
        object campaign_object = OBJECT_INVALID;// just to be clear we are relying on this being the case 
        if (!NWNX_SQL_PrepareQuery(query)) {
                WriteTimestampedLogEntry("NWNX_RetrieveObject: error preparing query '" + query + "'");
                return OBJECT_INVALID;
        }
        
        if (arg0 != "") {
                NWNX_SQL_PreparedString(0, arg0);
                if (arg1 != "") {
                        NWNX_SQL_PreparedString(1, arg1);
                }
        }

        if (NWNX_SQL_ExecutePreparedQuery()) {
                if (NWNX_SQL_ReadyToReadNextRow()) {
                        vector v = GetPositionFromLocation(where); 
			NWNX_SQL_ReadNextRow();
			if (owner == OBJECT_INVALID) {
				owner = GetAreaFromLocation(where);
			}
			campaign_object = NWNX_SQL_ReadFullObjectInActiveRow(0, owner, v.x, v.y, v.z);
			if (!GetIsObjectValid(campaign_object)) db ("Deserialize failed - object invalid.");
			int nType = GetObjectType(campaign_object);
			if(nType == OBJECT_TYPE_CREATURE) {
				// TODO - would prefer to use SetLocation here too.
				AssignCommand(campaign_object, JumpToLocation(where));
			} else if ( nType == OBJECT_TYPE_ITEM) {
				// Nothing ...
			}else {
				// TODO - use SetLocation when it exists.
				NWNX_Object_SetPosition(campaign_object, v);
				AssignCommand(campaign_object, SetFacing(GetFacingFromLocation(where)));
			}
                } else {
                        // Error no object  - this may not be an error - just that there is no object 
                        WriteTimestampedLogEntry("NWNX_RetrieveObject : Failed to find object for '" + query + "'");
                }
        } else {
                // error query failed 
                WriteTimestampedLogEntry("NWNX_RetrieveObject : Failed query: '" + query + "'");
        }
        return campaign_object;
}
