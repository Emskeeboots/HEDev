//::///////////////////////////////////////////////
//:: _inc_constants
//:://////////////////////////////////////////////
/*
    essential constants used in PW
    colors in _inc_colors

    Custom Script Systems incorporated:


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2015 dec 19)
//:: Modified:
//:://////////////////////////////////////////////


// Hill's Edge Includes
#include "_inc_color"


////////////////////////////////////////////////////////////////////////////////
// ESSENTIAL
//

// NAME OF THE CAMPAIGN -- persistence
// used by both NWNX and NBDE (BioDB) for data specific to a campaign (isolating it from character specific data)
const string CAMPAIGN_NAME      = "boots_edge";

// LOCAL VARIABLES SET ON MODULE (these are not actually constants)
// Shall the scripts provide verbose feedback?
int MODULE_DEBUG_MODE           = GetLocalInt(GetModule(), "DEBUG");
// Module in development mode? This is for special developer behavior
// testing character will be jumped to the developer's way point which you can move around
int MODULE_DEVELOPMENT_MODE     = GetLocalInt(GetModule(), "DEVELOPMENT");
// is NWNX active?
//int MODULE_NWNX_MODE            = (MODULE_DEVELOPMENT_MODE==0);

// prefix of tag based scripts
const string PREFIX                 = "do_";
// String data delimiter
const string DELIMIT                = "_";
// String CHAT special characters
const string CHAT_KEY               = " /*<>:.";
// seconds until a feedback string appears on entering module
//const float DELAY_DISPLAY_START = 3.0;

// Module wide special characters
string BR                       = GetLocalString(GetModule(), "LINEBREAK");
string Q                        = GetLocalString(GetModule(), "QUOTE");

// SPECIAL WAY POINT TAGS USED IN MODULE
// tag of waypoint for fall back start location in game
const string WP_DEFAULT_START   = "dst_start_default";
// tag of waypoint for fall back start location in game
const string WP_DEVELOPMENT     = "dst_development";
// tag of waypoint for persistent inventory mule
const string WP_INVENTORY       = "wp_inventory_persist";
//const string WP_INVENTORY       = "test_inventory";

// an item with this local string will turn into a placeable when dropped
// likewise a placeable with this can be picked up as an item
const string PLACEABLE_ITEM_RESREF  = "PLACEABLE_ITEM_RESREF";

//UNUSED
// Record names of time values tracked in campaign db.         * DO NOT TOUCH *
//const string CAMPAIGN_YEAR          = "iYear";          // int
//const string CAMPAIGN_MONTH         = "iMonth";         // int
//const string CAMPAIGN_DAY           = "iDay";           // int
//const string CAMPAIGN_HOUR          = "iHour";          // int
//const string CAMPAIGN_MINUTE        = "iMinute";        // int
// EPOCH - game time when the campaign is initialized
// these are established by module time at start of campaigns first module load event
// see NWNX_RestoreGameTime  in v2_inc_time
//int CAMPAIGN_YEAR_BASE          = GetLocalInt(GetModule(),"EPOCH_YEAR");
//int CAMPAIGN_MONTH_BASE         = GetLocalInt(GetModule(),"EPOCH_MONTH");
//int CAMPAIGN_DAY_BASE           = GetLocalInt(GetModule(),"EPOCH_DAY");
//int CAMPAIGN_HOUR_BASE          = GetLocalInt(GetModule(),"EPOCH_HOUR");

// LOOT ------------------------------------------------------------------------
//int LOOT_PERIOD_MINUTES         = GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")*60; // real life minutes is the second number
                                                             // period of time between loot respawns
// SILENT SHOUTS
const string SHOUT_ALERT                = "!ALERT!";
const string SHOUT_FLEE                 = "!FLEE!";
const string SHOUT_PLACEABLE_ATTACKED   = "!BASHED!";
const string SHOUT_PLACEABLE_DESTROYED  = "!DESTROYED!";
const string SHOUT_SUBDUAL_DEAD         = "!SUBDUED!";
const string SHOUT_SUBDUAL_ATTACK       = "!FUN BRAWL!";

// USER DEFINED EVENTS ---------------------------------------------------------
// Custom
const int EVENT_BARDSONG                    = 9875;
const int EVENT_SPELLCAST                   = 9876;
const int EVENT_BLOCKED                     = 9900;
const int EVENT_RESTED                      = 9901;
const int EVENT_ALERTED                     = 9902;
//const int EVENT_PREPARE                     = 9903;
const int EVENT_COMMIT_OBJECT_TO_DB         = 9904;
const int EVENT_GARBAGE_COLLECTION          = 9905;


// RACIAL TYPES
const int RACIAL_TYPE_PLANT     = 30;

// PHENOTYPES
const int PHENOTYPE_FLYING      = 46;

// POLYMORPHS
const int POLYMORPH_TYPE_WEREBOAR   = 200;

// SKILLS
const int SKILL_CRAFTING        = 22;
const int SKILL_JUMP            = 25;
const int SKILL_SWIM            = 26;
const int SKILL_CLIMB           = 28;
const int SKILL_ESCAPE_ARTIST   = 29;
const int SKILL_SENSE_MOTIVE    = 30;
const int SKILL_DECIPHER_SCRIPT = 31;
const int SKILL_FORGERY         = 32;
// FEATS
const int FEAT_TOOLS1           = 1106;
const int FEAT_TOOLS2           = 1113;
const int FEAT_DWARF_WEAPONS    = 2005;
const int FEAT_CONVERT          = 2006;
const int FEAT_TRACK            = 2008;
const int FEAT_SCENT            = 2009;
const int FEAT_JUMP             = 2010;
const int FEAT_SPIDER_CLIMB     = 2011;
const int FEAT_FLIGHT           = 2012;
const int FEAT_PASS_DOOR        = 2013;
const int FEAT_SPELL_TARGET     = 2015;
const int FEAT_BURST_SPEED      = 2023;
const int FEAT_WATER_BREATHING  = 2031;
const int FEAT_MONK_FALL        = 2032;
const int FEAT_MONK_JUMP        = 2033;
const int FEAT_MONK_TALK        = 2034;
const int FEAT_MONK_STEP        = 2035;

// These should be in _inc_terrain
// terrain impact type
const int IMPACT_MOVEMENT           = 1;
const int IMPACT_CONCEALMENT        = 2;
const int IMPACT_BREATHING          = 4;
const int IMPACT_SPEECH             = 8;
const int IMPACT_COMBAT             = 16;


// BASE ITEMS
const int BASE_ITEM_MASK            = 220;
const int BASE_ITEM_TORC            = 217;
const int BASE_ITEM_SCARF           = 221;
const int BASE_ITEM_HERBS           = 152;
const int BASE_ITEM_MAUL            = 318;

//void main(){}
