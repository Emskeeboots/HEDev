///////////////////////////////////////////////////////////////////////////////
// deity_include.nss
//
// Created by: The Krit
// Date: 11/06/06
///////////////////////////////////////////////////////////////////////////////
//
// This file includes deity_core and provides the means to store additional
// information about the deities of your module. If needed, add functions
// using the templates provided below.
//
// None of the functions in this file are needed for the core functionality
// of this deity system. Most of the examples provided are used in either the
// example conversation or the example scipts (deity_example.nss). A few are
// here just because they seemed like a good idea at the time. Add and delete
// functions to suit your needs.
//
///////////////////////////////////////////////////////////////////////////////
//
// Current examples:
//
// Call SetDeityAvatar() to record the creature that serves as the avatar of
// each deity, if needed. If this is not called, the default value is
// OBJECT_INVALID.
//
// Call SetDeityHolySymbol() to record the blueprint name for the holy symbol
// of each deity, if needed. If this is not called, the default value is "".
//
// Call SetDeityPortfolio() to record the portfolio of each deity, if needed.
// If this is not called, the default value is "".
//
// Call SetDeitySpawnLoc() to set the tag of the spawn location for followers
// of each deity, if needed. If this is not called, the default value is "".
//
// Call SetDeitySwear() to set the swear phrase used by followers of each
// deity, if desired. If this is not called, the default value is "".
//
// Call SetDeityTitle() to record each deity's title, if needed. If this is
// not called, the default value is "".
//
// Call SetDeityTitleAlternates() to record each deity's additional titles,
// if needed. If this is not called, the default value is "".
//
// Call GetDeityAvatar() to retrieve the avatar (creature) of a deity.
//
// Call GetDeityHolySymbol() to retrieve the blueprint for a deity's holy symbol.
//
// Call GetDeityPortfolio() to retrieve a deity's portfolio.
//
// Call GetDeitySpawnLoc() to retrieve the tag of the spawn location for
// followers of a deity.
//
// Call GetDeitySpawnLocator() to retrieve an object at the spawn location for
// followers of a deity.
//
// Call SetDeitySwear() to retrieve the swear phrase used by followers of a
// deity.
//
// Call GetDeityTitle() to retrieve a deity's title.
//
// Call GetDeityTitleAlternates() to retrieve a deity's additional titles,
//
///////////////////////////////////////////////////////////////////////////////
//
// Creating new functions:
//
// Here are function templates that can be used. In each template, replace the
// @ character with a suitable word to describe the data. You will also need
// to add a line like
// const string DEITY_@  = "TK_DEITY_@_";
// to the list of variable names.
// For consistency, match the capitalization of the examples. (Capitalize the
// replacement for @ most of the time, but use ALL CAPS for "DEITY_@".)
// Some variations are possible, if you know your scripting well enough.

/* TEMPLATE: Setting string data *
///////////////////////////////////////////////////////////////////////////////
// Call SetDeity@()
//
// Records s@ as the @ of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeity@(int nDeity, string s@)
{
    SetLocalString(GetModule(), DEITY_@ + IntToHexString(nDeity), s@);
}
*/

/* TEMPLATE: Retrieving string data *
///////////////////////////////////////////////////////////////////////////////
// GetDeity@()
//
// Returns the @ of deity nDeity.
//
string GetDeity@(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_@ + IntToHexString(nDeity));
}
*/

/* TEMPLATE: Setting integer data *
///////////////////////////////////////////////////////////////////////////////
// Call SetDeity@()
//
// Records n@ as the @ of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeity@(int nDeity, int n@)
{
    SetLocalInt(GetModule(), DEITY_@ + IntToHexString(nDeity), n@);
}
*/

/* TEMPLATE: Retrieving integer data *
///////////////////////////////////////////////////////////////////////////////
// GetDeity@()
//
// Returns the @ of deity nDeity.
//
int GetDeity@(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_@ + IntToHexString(nDeity));
}
*/

/* TEMPLATE: Setting effect data *
///////////////////////////////////////////////////////////////////////////////
// Call SetDeity@()
//
// Records the indicated effect as the @ of deity nDeity.
//
// nDeity should be a return value of AddDeity().
// nEffectType must be an EFFECT_TYPE_* constant.
// nParam? are the parameters passed to the corresponding effect constructor
//   (the Effect*() functions), in the order the constructor takes them, optional
//   parameters not required.
//
// For implementation details, see SetLocalEffect().
//
void SetDeity@(int nDeity, int nEffectType, int nParam1 = PARAMETER_INVALID, int nParam2 = PARAMETER_INVALID, int nParam3 = PARAMETER_INVALID, int nParam4 = PARAMETER_INVALID, int nParam5 = PARAMETER_INVALID, int nParam6 = PARAMETER_INVALID)
{
    SetLocalEffect(GetModule(), DEITY_@ + IntToHexString(nDeity), nEffectType, nParam1, nParam2, nParam3, nParam4, nParam5, nParam6);
}
*/

/* TEMPLATE: Creating an effect from data *
///////////////////////////////////////////////////////////////////////////////
// GetDeity@()
//
// Returns the @ of deity nDeity.
//
effect GetDeity@(int nDeity)
{
    return GetLocalEffect(GetModule(), DEITY_@ + IntToHexString(nDeity));
}
*/

///////////////////////////////////////////////////////////////////////////////
// And now, onto the actual code.
///////////////////////////////////////////////////////////////////////////////


// Include the core functions and constants.
#include "deity_core"
#include "tb_inc_util"

// The names of module variables used to track the deities.
// For reference, the constants in deity_core are:
//   const string DEITY_COUNTER    = "TK_DEITY_COUNTER";
//   const string DEITY_NAME       = "TK_DEITY_NAME_";
//   const string DEITY_ALIGNMENT  = "TK_DEITY_PRIMARY_ALIGNMENT_";
//   const string DEITY_GENDER     = "TK_DEITY_GENDER_";
//   const string CLERIC_ALIGNMENT = "TK_DEITY_ALIGNMENTS_";
//   const string CLERIC_DOMAIN    = "TK_DEITY_DOMAINS_";
//   const string CLERIC_RACE      = "TK_DEITY_RACES_";
//   const string CLERIC_GENDER    = "TK_DEITY_CLERIC_GENDER_";
//   const string CLERIC_SUBRACE   = "TK_DEITY_SUBRACE_";
//   const string DEITY_WEAPON     = "TK_DEITY_WEAPON_";
//   const string DEITY_WEAPON_ALT = "TK_DEITY_WEAPONALT_";
// Avoid using the same variable name twice. (That's both module and script
// variable names.)
// Ending the module variable names with an underscore is recommended.
const string DEITY_AVATAR       = "TK_DEITY_AVATAR_";
const string DEITY_PORTFOLIO    = "TK_DEITY_PORTFOLIO_";
const string DEITY_SPAWN        = "TK_DEITY_SPAWN_LOC_";
const string DEITY_SPAWNMARKER  = "TK_DEITY_SPAWN_LOCATOR_";
const string DEITY_SYMBOL       = "TK_DEITY_SYMBOL_";     // A cleric's holy symbol.
const string DEITY_SYMBOL_TAG   = "TK_DEITY_SYMBOL_TAG_";     // A cleric's holy symbol tag.
const string DEITY_SWEAR        = "TK_DEITY_SWEAR_";
const string DEITY_BLESSING     = "TK_DEITY_BLESSING_";
const string DEITY_TEMPLEEFFECT = "TK_DEITY_TEMPLE_EFFECT_";
const string DEITY_TITLE        = "TK_DEITY_TITLE_";
const string DEITY_TITLEAKA     = "TK_DEITY_TITLE_AKA_";  // Alternate titles.
const string DEITY_CHURCHNAME   = "TK_DEITY_CHURCH_NAME_";  // name of church - i.e. church, temple, shrine etc. - defaults to church.


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////
// (Prototyping is what causes the function to appear in the list of functions.)

// Records the creature serving as the avatar of deity nDeity.
// sTag should be the tag of the creature.
// nDeity should be a return value of AddDeity().
// The creature is determined when this function is called.
//
// I'm not sure if this function is actually useful. I really just wanted an
// example function that stored an object, even though non-scripters probably
// don't want to bother with such things.
void SetDeityAvatar(int nDeity, string sTag);

// Records sBlueprint as the holy symbol of deity nDeity.
// nDeity should be a return value of AddDeity().
// The tag of each holy symbol must be "HolySymbol" to work with HCR.
void SetDeityHolySymbol(int nDeity, string sBlueprint);

// Records sBlueprint as the holy symbol of deity nDeity.
// nDeity should be a return value of AddDeity().
// The tag of each holy symbol must be "HolySymbol" to work with HCR.
void SetDeityHolySymbolTag(int nDeity, string sTag = "HolySymbol");

// Records sSpecialty as the portfolio of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetDeityPortfolio(int nDeity, string sSpecialty);

// Records the tag of the spawn location for followers of deity nDeity.
// Also records an object with that tag. This is more efficient if you're
// writing your own scripts. (Some existing scripts expect a string.)
//
// sTag should be the tag of an object (probably a waypoint) whose location
// is the spawn location.
// nDeity should be a return value of AddDeity().
void SetDeitySpawnLoc(int nDeity, string sTag);

// Records sSwear as the swear phrase of followers of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetDeitySwear(int nDeity, string sSwear);

// Records sBlessing as the blessing phrase of followers of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetDeityBlessing(int nDeity, string sBlessing);

// Records the indicated effect as the effect of faithfully praying at a temple
// of deity nDeity.
// nDeity should be a return value of AddDeity().
// nEffectType must be an EFFECT_TYPE_* constant.
// nParam? are the parameters passed to the corresponding effect constructor
//   (the Effect*() functions), in the order the constructor takes them, optional
//   parameters not required.
// For implementation details, see SetLocalEffect().
//
// (This is an example of storing effect descriptions.)
void SetDeityTempleEffect(int nDeity, int nEffectType, int nParam1 = PARAMETER_INVALID, int nParam2 = PARAMETER_INVALID, int nParam3 = PARAMETER_INVALID, int nParam4 = PARAMETER_INVALID, int nParam5 = PARAMETER_INVALID, int nParam6 = PARAMETER_INVALID);

// Records sTitle as the title of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetDeityTitle(int nDeity, string sTitle);

// Records sTitles as the alternate titles of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetDeityTitleAlternates(int nDeity, string sTitles);

// Records sChurch as the name to call the church. e.g. church, temple, shrine, etc
// nDeity should be a return value of AddDeity().
// If unset "church" is used.
void SetDeityChurchName(int nDeity, string sChurch);

// Returns the creature serving as the avatar of deity nDeity.
//
// I'm not sure if this function is actually useful. I really just wanted an
// example function that stored an object, even though non-scripters probably
// don't want to bother with such things.
object GetDeityAvatar(int nDeity);

// Returns the blueprint of the holy symbol of deity nDeity.
string GetDeityHolySymbol(int nDeity);

// Returns the tag of the holy symbol of deity nDeity.
string GetDeityHolySymbolTag(int nDeity);

// Returns the portfolio of deity nDeity.
string GetDeityPortfolio(int nDeity);

// Returns the tag of the spawn location for followers of deity nDeity.
//
// To get from the tag (sTag) to the location (lLoc) in another script, use
// something like:
//    object oTarget = GetObjectByTag(sTag);
//    // Check for a valid object marking the spawn location.
//    if ( GetIsObjectValid(oTarget)  &&  GetIsObjectValid(GetAreaFromLocation(GetLocation(oTarget))) )
//        lLoc = GetLocation(oTarget);
//    else
//       lLoc = <default value, whatever you decide it shoud be>
string GetDeitySpawnLoc(int nDeity);

// Returns the object marking the spawn location for followers of deity nDeity.
// (Not the location because it's much easier to test for an invalid object
// than an invalid location, and getting the location from an object is not
// processor-intensive.)
//
// To get from the object (oTarget) to the location (lLoc) in another script,
// and you are careful not to cause your location markers to get invalid
// locations, use something like:
//    // Check for a valid object marking the spawn location.
//    if ( GetIsObjectValid(oTarget) )
//        lLoc = GetLocation(oTarget);
//    else
//       lLoc = <default value, whatever you decide it shoud be>
object GetDeitySpawnLocator(int nDeity);

// Returns the swear phrase of followers of deity nDeity.
string GetDeitySwear(int nDeity);

// Returns the blessing phrase of followers of deity nDeity.
string GetDeityBlessing(int nDeity);

// Returns the title of deity nDeity.
string GetDeityTitle(int nDeity);

// Returns the alternate titles of deity nDeity.
string GetDeityTitleAlternates(int nDeity);

// God, Goddess or Deity
string DeityGetGenderTitle(int nDeity);

// check if item is holy symbol and if so if the PC can equip it. 
// Force removes the object and returns TRUE if the PC cannot equip it. 
int deityHolysymbolEquip(object oPC, object oItem);


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// SetDeityAvatar()
//
// Records the creature serving as the avatar of deity nDeity.
//
// sTag should be the tag of the creature.
//
// nDeity should be a return value of AddDeity().
//
// The creature is determined when this function is called.
//
// I'm not sure if this function is actually useful. I really just wanted an
// example function that stored an object, even though non-scripters probably
// don't want to bother with such things.
//
void SetDeityAvatar(int nDeity, string sTag) {
    SetLocalObject(GetModule(), DEITY_AVATAR + IntToHexString(nDeity),
                   GetObjectByTag(sTag));
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityHolySymbol()
//
// Records sBlueprint as the holy symbol of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
// The tag of each holy symbol must be "HolySymbol" to work with HCR.
//
void SetDeityHolySymbol(int nDeity, string sBlueprint) {
    SetLocalString(GetModule(), DEITY_SYMBOL + IntToHexString(nDeity), sBlueprint);
}

///////////////////////////////////////////////////////////////////////////////
// SetDeityHolySymbolTag()
//
// Records sTag as the tag of holy symbol of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
// Don't use this if using HCR.
//
void SetDeityHolySymbolTag(int nDeity, string sTag) {
    SetLocalString(GetModule(), DEITY_SYMBOL_TAG + IntToHexString(nDeity), sTag);
}



///////////////////////////////////////////////////////////////////////////////
// SetDeityPortfolio()
//
// Records sSpecialty as the portfolio of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeityPortfolio(int nDeity, string sSpecialty)
{
    SetLocalString(GetModule(), DEITY_PORTFOLIO + IntToHexString(nDeity), sSpecialty);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeitySpawnLoc()
//
// Records the tag of the spawn location for followers of deity nDeity.
//
// Also records an object with that tag. This is more efficient if you're
// writing your own scripts. (Some existing scripts expect a string.)
//
// sTag should be the tag of an object (probably a waypoint) whose location
// is the spawn location.
//
// nDeity should be a return value of AddDeity().
//
void SetDeitySpawnLoc(int nDeity, string sTag) {
    SetLocalString(GetModule(), DEITY_SPAWN + IntToHexString(nDeity), sTag);
    SetLocalObject(GetModule(), DEITY_SPAWNMARKER + IntToHexString(nDeity),
                   GetObjectByTag(sTag));
}


///////////////////////////////////////////////////////////////////////////////
// SetDeitySwear()
//
// Records sSwear as the swear phrase of followers of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeitySwear(int nDeity, string sSwear)
{
    SetLocalString(GetModule(), DEITY_SWEAR + IntToHexString(nDeity), sSwear);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityBlessing()
//
// Records sBlessing as the blessing phrase of followers of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeityBlessing(int nDeity, string sBlessing) {
    SetLocalString(GetModule(), DEITY_BLESSING + IntToHexString(nDeity), sBlessing);
}


///////////////////////////////////////////////////////////////////////////////
// Call SetDeityTempleEffect()
//
// Records the indicated effect as the effect of faithfully praying at a temple
// of deity nDeity.
//
// nDeity should be a return value of AddDeity().
// nEffectType must be an EFFECT_TYPE_* constant.
// nParam? are the parameters passed to the corresponding effect constructor
//   (the Effect*() functions), in the order the constructor takes them, optional
//   parameters not required.
//
// For implementation details, see SetLocalEffect().
//
// (This is an example of storing effect descriptions.)
//
void SetDeityTempleEffect(int nDeity, int nEffectType, int nParam1 = PARAMETER_INVALID, int nParam2 = PARAMETER_INVALID, int nParam3 = PARAMETER_INVALID, int nParam4 = PARAMETER_INVALID, int nParam5 = PARAMETER_INVALID, int nParam6 = PARAMETER_INVALID)
{
    SetLocalEffect(GetModule(), DEITY_TEMPLEEFFECT + IntToHexString(nDeity), nEffectType, nParam1, nParam2, nParam3, nParam4, nParam5, nParam6);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityTitle()
//
// Records sTitle as the title of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeityTitle(int nDeity, string sTitle)
{
    SetLocalString(GetModule(), DEITY_TITLE + IntToHexString(nDeity), sTitle);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityTitleAlternates()
//
// Records sTitles as the alternate titles of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetDeityTitleAlternates(int nDeity, string sTitles) {
    SetLocalString(GetModule(), DEITY_TITLEAKA + IntToHexString(nDeity), sTitles);
}


// Records sChurch as the name to call the church. e.g. church, temple, shrine, etc
// nDeity should be a return value of AddDeity().
// If unset "church" is used.
void SetDeityChurchName(int nDeity, string sChurch) {
    if (sChurch == "church")
        DeleteLocalString(GetModule(), DEITY_CHURCHNAME + IntToHexString(nDeity));
    else
        SetLocalString(GetModule(), DEITY_CHURCHNAME + IntToHexString(nDeity), sChurch);
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityAvatar()
//
// Returns the creature serving as the avatar of deity nDeity.
//
// I'm not sure if this function is actually useful. I really just wanted an
// example function that stored an object, even though non-scripters probably
// don't want to bother with such things.
//
object GetDeityAvatar(int nDeity)
{
    return GetLocalObject(GetModule(), DEITY_AVATAR + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityHolySymbol()
//
// Returns the blueprint of the holy symbol of deity nDeity.
//
string GetDeityHolySymbol(int nDeity) {
        string sRef = GetLocalString(GetModule(), DEITY_SYMBOL + IntToHexString(nDeity));
        if (sRef == "")
               return "it_holysymbol";
        return sRef;
}

///////////////////////////////////////////////////////////////////////////////
// GetDeityHolySymbolTag()
//
// Returns the tag of the holy symbol of deity nDeity.
//
string GetDeityHolySymbolTag(int nDeity) {
    string sTag = GetLocalString(GetModule(), DEITY_SYMBOL + IntToHexString(nDeity));
    if (sTag == "")
        return "HolySymbol";
    return sTag;
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityPortfolio()
//
// Returns the portfolio of deity nDeity.
//
string GetDeityPortfolio(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_PORTFOLIO + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeitySpawnLoc()
//
// Returns the tag of the spawn location for followers of deity nDeity.
//
// To get from the tag (sTag) to the location (lLoc) in another script, use
// something like:
//    object oTarget = GetObjectByTag(sTag);
//    // Check for a valid object marking the spawn location.
//    if ( GetIsObjectValid(oTarget)  &&  GetIsObjectValid(GetAreaFromLocation(GetLocation(oTarget))) )
//        lLoc = GetLocation(oTarget);
//    else
//       lLoc = <default value, whatever you decide it shoud be>
//
string GetDeitySpawnLoc(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_SPAWN + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeitySpawnLocator()
//
// Returns the object marking the spawn location for followers of deity nDeity.
// (Not the location because it's much easier to test for an invalid object
// than an invalid location, and getting the location from an object is not
// processor-intensive.)
//
// To get from the object (oTarget) to the location (lLoc) in another script,
// and you are careful not to cause your location markers to get invalid
// locations, use something like:
//    // Check for a valid object marking the spawn location.
//    if ( GetIsObjectValid(oTarget) )
//        lLoc = GetLocation(oTarget);
//    else
//       lLoc = <default value, whatever you decide it shoud be>
//
object GetDeitySpawnLocator(int nDeity)
{
    return GetLocalObject(GetModule(), DEITY_SPAWNMARKER + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeitySwear()
//
// Returns the swear phrase of followers of deity nDeity.
//
string GetDeitySwear(int nDeity) {
    return GetLocalString(GetModule(), DEITY_SWEAR + IntToHexString(nDeity));
}

///////////////////////////////////////////////////////////////////////////////
// GetDeityBlessing()
//
// Returns the blessing phrase of followers of deity nDeity.
//
string GetDeityBlessing(int nDeity) {
    return GetLocalString(GetModule(), DEITY_BLESSING + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityTempleEffect()
//
// Returns the the effect of faithfully praying at a temple of deity nDeity.
//
effect GetDeityTempleEffect(int nDeity)
{
    return GetLocalEffect(GetModule(), DEITY_TEMPLEEFFECT + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityTitle()
//
// Returns the title of deity nDeity.
//
string GetDeityTitle(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_TITLE + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityTitleAlternates()
//
// Returns the alternate titles of deity nDeity.
//
string GetDeityTitleAlternates(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_TITLEAKA + IntToHexString(nDeity));
}

///////////////////////////////////////////////////////////////////////////////
// GetDeityChurchName()
//
// Returns the name to call the church of deity nDeity.
string GetDeityChurchName(int nDeity) {
    string sRet = GetLocalString(GetModule(), DEITY_CHURCHNAME + IntToHexString(nDeity));
    if (sRet == "")
        return DEFAULT_CHURCHNAME;

    return sRet;
}

// God, Goddess or Deity
string DeityGetGenderTitle(int nDeity) {
    string sToken = "god";
    switch ( GetDeityGender(nDeity) ){
    case GENDER_FEMALE: sToken = "goddess"; break;
    case GENDER_MALE:   sToken = "god";     break;
    default:            sToken = "deity";   break;
        }
    return sToken;
}

int deityGetIsHolySymbol(object oItem) {
        if (GetStringLeft(GetTag(oItem), 12) == "it_holysym_0")
                return TRUE;
        return FALSE;
}
 

// check if item is holy symbol and if so if the PC can equip it. 
// Force removes the object and returns TRUE if the PC cannot equip it. 
int deityHolysymbolEquip(object oPC, object oItem) {

        if (!deityGetIsHolySymbol(oItem))
                return FALSE;

        string sItemDeity = GetLocalString(oItem, "ITEM_DEITY");  
        if (sItemDeity == "") 
                return FALSE;

        if (GetDeity(oPC) != sItemDeity) { 
                ForceUnequip (oPC, oItem);                                                         
                SendMessageToPC(oPC, "You are not a follower of " + sItemDeity + ", and are unable to equip that item.");
                return TRUE;
        }                                                               
        return FALSE;
}
