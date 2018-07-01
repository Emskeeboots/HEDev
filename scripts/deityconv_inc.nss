///////////////////////////////////////////////////////////////////////////////
// deityconv_inc.nss
//
// Created by: The Krit
// Date: 11/08/06
///////////////////////////////////////////////////////////////////////////////
//
// This file is used by the sample conversation (deity_list) that describes the
// pantheon of this module. The conversation and its associated scripts (all
// of whose names begin with "deityconv_") are intended as a starting point
// and an example, but could also be used as-is.
//
// (Some general advice: if you intend to modify the conversation or scripts,
// make copies so you have a reference in case you get lost.)
//
///////////////////////////////////////////////////////////////////////////////
//
// Call SetupDeityConversationTokens() in the middle of a conversation to
// define tokens used to talk about the deities.
//
// Call SetupDeityListTokens() in the middle of a conversation to define
// tokens used to list the deities a PC could reasonably follow.
//
///////////////////////////////////////////////////////////////////////////////
//
// Uses custom tokens #420 through 430 and 433 through 439.
//
//  CUSTOM420 is the deity's name.
//  CUSTOM421 is "He" or "She" (or name), based on the deity's gender.
//  CUSTOM422 is the deity's alignment.
//  CUSTOM423 is " of " + the deity's portfolio (or empty).
//  CUSTOM424 is the deity's title (or "god", "goddess", or "deity").
//  CUSTOM425 is ", also known as " + the deity's alternate titles (or empty).
//  CUSTOM426 is " " + allowed alignments (or empty).
//  CUSTOM427 is the list of allowed domains.
//  CUSTOM428 is " " + allowed races (or empty)  (or " and" if no races but both alignments and subraces).
//  CUSTOM429 is " of the " + required subrace + " subrace" (or empty).
//  CUSTOM430 is ", and he/she favors the <weapon>" if the deity has a favored weapon.
//  CUSTOM431 is " Clerics of " + sName + " must be fe/male." or ""

//  CUSTOM433 through CUSTOM439 hold deity names.
//  This range (433 through 439) can be changed via the following lines:
const int TOKENLIST_START = 433;
const int TOKENLIST_LENGTH = 7;
//
///////////////////////////////////////////////////////////////////////////////


// Includes.
#include "deity_include"



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Defines tokens to allow conversations to refer to the deities.
void SetupDeityConversationTokens(int nDeity, int bUseVars = FALSE);

// Defines the list of deities that oPC can follow, and defines conversation
// tokens for the first six or seven.
//
// This will list "Lolth" for male non-clerics, even though they cannot be her
// clerics. Otherwise, for non-clerics, "can follow" means "meets all clerical
// requirements but domains". For clerics, it means "meets all clerical
// requirements".
void SetupDeityListTokens(object oPC);

// Defines conversation tokens for the next six or seven deities that the PC
// speaker can follow.
void ContinueDeityListTokens();

// Defines conversation tokens for the previous six or seven deities that the PC
// speaker can follow.
void BackupDeityListTokens();

void ClearDeityConversationVariables(object oNPC = OBJECT_SELF);

///////////////////////////////////////////////////////////////////////////////
// UTILITY PROTOTYPES
///////////////////////////////////////////////////////////////////////////////


// Converts an alignment pair to a string description.
// Invalid input is treated as ALIGNMENT_NEUTRAL.
//
// Note: When I last checked, 0 was the definition of ALIGNMENT_ALL.
string AlignmentToString(int nLawChaos, int nGoodEvil);

// Converts a domain code to a string description.
// Invalid input results in "unknown".
string DomainToString(int nDomain);

// Converts a race code to a plural string description.
// Invalid input results in "unknown".
string RaceToString(int nRace);

// Converts a weapon code to a string description.
// Most descriptions begins with "the".
// Invalid input results in "an unknown weapon".
string WeaponToString(int nWeapon);

// Converts an list of alignment codes to text, as in "lawful-good or true neutral".
string ListToStringAlign(string sList);

// Converts an list of domain codes to text, as in "animal and plant".
string ListToStringDomain(string sList);

// Converts an list of race codes to text, as in "dwarves or elves".
string ListToStringRace(string sList);



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// SetupDeityConversationTokens()
//
// Defines tokens to allow conversations to refer to the deities.
void SetupDeityConversationTokens(int nDeity, int bUseVars = FALSE) {
    string sToken = ""; // Used to build each token string. (Adds readability.)
    string sPronoun = ""; // Used to store "he", "she", or "it" for later tokens.

    // Token 420 is the deity's name.
    sToken = GetDeityName(nDeity);
    string sName = sToken;

    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_name", sToken);
    else SetCustomToken(420, sToken);

    // Token 421 is "He" or "She" (or name), based on the deity's gender.
    switch ( GetDeityGender(nDeity) )
    {
        case GENDER_MALE:   sToken = "He";  sPronoun = "he";  break;
        case GENDER_FEMALE: sToken = "She"; sPronoun = "she"; break;
        default: sToken = GetDeityName(nDeity); sPronoun = "it"; break;
    }
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_gender", sToken);
    else SetCustomToken(421, sToken);

    // Token 422 is the deity's alignment.
    sToken = AlignmentToString(GetDeityAlignmentLC(nDeity), GetDeityAlignmentGE(nDeity));
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_align", sToken);
    else SetCustomToken(422, sToken);

    // Token 423 is " of " + the deity's portfolio (or empty).
    sToken = GetDeityPortfolio(nDeity);
    if ( sToken != "" )
        sToken = " of " + sToken;
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_portfolio", sToken);
    else SetCustomToken(423, sToken);

    // Token 424 is the deity's title (or "god", "goddess", or "deity").
    sToken = GetDeityTitle(nDeity);
    // See if a default title is needed.
    if ( sToken == "" )
        switch ( GetDeityGender(nDeity) )
        {
            case GENDER_FEMALE: sToken = "goddess"; break;
            case GENDER_MALE:   sToken = "god";     break;
            default:            sToken = "deity";   break;
        }
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_title", sToken);
    else SetCustomToken(424, sToken);

    // Token 425 ", also known as " + the deity's alternate titles + "," (or empty).
    sToken = GetDeityTitleAlternates(nDeity);
    // Check that the deity has alternate titles.
    if ( sToken != "" )
        sToken = ", also known as " + sToken;
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_altnames", sToken);
    else SetCustomToken(425, sToken);

    // Token 426 is " " + allowed alignments (or empty).
    sToken = ListToStringAlign(
        GetLocalString(GetModule(), CLERIC_ALIGNMENT + IntToHexString(nDeity)));
    // Add the space if not an empty string.
    if ( sToken != "" )
        sToken = " " + sToken;
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_req_align", sToken);
    else SetCustomToken(426, sToken);

    // Token 427 is the list of allowed domains.
    sToken = ListToStringDomain(
        GetLocalString(GetModule(), CLERIC_DOMAIN + IntToHexString(nDeity)));
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_domains", sToken);
    else SetCustomToken(427, sToken);

    // Token 428 is " " + allowed races (or empty) (or " and" if no races but both alignments and subraces).
    sToken = ListToStringRace(
                GetLocalString(GetModule(), CLERIC_RACE + IntToHexString(nDeity)));
    // Add the space if not an empty string.
    if ( sToken != "" )
        sToken = " " + sToken;

    // If there are alignment and subrace requirements, do not set an empty string...
    else if ( "" != GetLocalString(GetModule(), CLERIC_DOMAIN + IntToHexString(nDeity))
              &&  "" != GetClericSubrace(nDeity) )
        /// ... set " and" instead.
        sToken = " and";

    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_req_race", sToken);
    else SetCustomToken(428, sToken);

    // Token 429 is " of the " + required subrace + " subrace" (or empty).
    sToken = GetClericSubrace(nDeity);
    // Add the text if not an empty string.
    if ( sToken != "" )
        sToken = " of the " + sToken + " subrace";
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_req_subrace", sToken);
    else SetCustomToken(429, sToken);

    // Token 430 is ", and she/he favors the <weapon>" (or empty).
    sToken = "";
    if ( GetDeityWeapon(nDeity) != WEAPON_NONE )
    {
        // Fill in blurb about the favored weapon.
        //sToken = ", and " + sPronoun + " favors " + WeaponToString(GetDeityWeapon(nDeity));
        sToken = sPronoun + " favors " + WeaponToString(GetDeityWeapon(nDeity));
        // Check for a second weapon.
        if ( GetDeityWeaponAlternate(nDeity) != WEAPON_NONE )
            // Add the second favored weapon.
            sToken = sToken + " and " + WeaponToString(GetDeityWeaponAlternate(nDeity));
    }
    else if ( GetDeityWeaponAlternate(nDeity) != WEAPON_NONE )
        // Fill in blurb about the favored weapon.
        //sToken = ", and " + sPronoun + " favors " + WeaponToString(GetDeityWeaponAlternate(nDeity));
        sToken = sPronoun + " favors " + WeaponToString(GetDeityWeaponAlternate(nDeity));
    // Set the token.
    if (bUseVars)  SetLocalString(OBJECT_SELF, "_cur_deity_weaps", sToken);
    sToken = ", and " + sToken;

    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_weapon", sToken);
    else SetCustomToken(430, sToken);

    // Token 431 is the gender restriction if any
    // " Clerics of
    sToken = "";
    int nGend =  GetClericGender(nDeity);
    db("Got gender " , nGend , "for " + GetDeityName(nDeity) + " idx " , nDeity);
    if (nGend == GENDER_MALE) {
        sToken = " All clerics of " + sName + " are male.";
    } else if (nGend == GENDER_FEMALE) {
        sToken = " All clerics of " + sName + " are female.";
    }
    db("setting gender token to : " + sToken);
    // Set the token.
    if (bUseVars) SetLocalString(OBJECT_SELF, "_cur_deity_req_gender", sToken);
    else SetCustomToken(431, sToken);

}

// This is used to clean up all the variables for a single deity on the speaking NPC
// As setup by  SetupDeityConversationTokens with useVars = TRUE.
void ClearDeityConversationVariables(object oNPC = OBJECT_SELF) {

    DeleteLocalString(oNPC, "_cur_deity_name");
    DeleteLocalString(oNPC, "_cur_deity_gender");
    DeleteLocalString(oNPC, "_cur_deity_align");
    DeleteLocalString(oNPC, "_cur_deity_portfolio");
    DeleteLocalString(oNPC, "_cur_deity_title");
    DeleteLocalString(oNPC, "_cur_deity_altnames");
    DeleteLocalString(oNPC, "_cur_deity_req_align");
    DeleteLocalString(oNPC, "_cur_deity_domains");
    DeleteLocalString(oNPC, "_cur_deity_req_race");
    DeleteLocalString(oNPC, "_cur_deity_req_subrace");
    DeleteLocalString(oNPC, "_cur_deity_weapon");
    DeleteLocalString(oNPC, "_cur_deity_req_gender");

}

///////////////////////////////////////////////////////////////////////////////
// SetupDeityListTokens()
//
// Defines the list of deities that oPC can follow, and defines conversation
// tokens for the first six or seven.
//
// This will list gender resticted deities non-clerics, even though they can't be a cleric.
// Otherwise, for non-clerics, "can follow" means "meets all clerical
// requirements but domains and gender". For clerics, it means "meets all clerical
// requirements".
void SetupDeityListTokens(object oPC)
{
    int nTotalDeities = GetDeityCount();    // Size of pantheon.
    int nDeity = 0;             // The current deity being checked.
    int nListedDeities = 0;     // The number of deities to list.
    int bAccept = FALSE;        // To simplify the coding of acceptance conditions.

    // Loop through the pantheon.
    while ( nDeity < nTotalDeities ) {

        // If oPC is a cleric, perform additional checks.
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0)
        // Clerics need to have the right domains and gender
        bAccept =  DeityCheckCanServe(oPC, nDeity);
    else
        bAccept = DeityCheckCanFollow(oPC, nDeity);

        // Is oPC accepted?
        if ( bAccept ) {
            // Record this deity in the list.
            SetLocalInt(OBJECT_SELF, "DeityList_" + IntToString(nListedDeities),
                        nDeity);
            // Record this deity's name in a token, if more are left.
            if ( nListedDeities < TOKENLIST_LENGTH )
                SetCustomToken(TOKENLIST_START + nListedDeities, GetDeityName(nDeity));
            // Increment the count.
            nListedDeities++;
        }

        // Next deity.
        nDeity++;
    }

    // Record the beginning of the list for this batch of tokens.
    SetLocalInt(OBJECT_SELF, "DeityList_Begin", 0);
    // Record the length of the list.
    SetLocalInt(OBJECT_SELF, "DeityList_Count", nListedDeities);
    // Record the number of tokens with data.
    if ( nListedDeities <= TOKENLIST_LENGTH )
        SetLocalInt(OBJECT_SELF, "DeityList_LastToken", nListedDeities);
    else
        // Subtract one to make room for the "More" option.
        SetLocalInt(OBJECT_SELF, "DeityList_LastToken", TOKENLIST_LENGTH - 1);

    // Empty any remaining tokens (just in case they show up somewhere).
    while ( nListedDeities < TOKENLIST_LENGTH )
        SetCustomToken(TOKENLIST_START + nListedDeities++, "");
}


///////////////////////////////////////////////////////////////////////////////
// ContinueDeityListTokens()
//
// Defines conversation tokens for the next six or seven deities that the PC
// speaker can follow.
void ContinueDeityListTokens()
{
    int nStartEntry = GetLocalInt(OBJECT_SELF, "DeityList_Begin") +
                      GetLocalInt(OBJECT_SELF, "DeityList_LastToken");
    int nStopToken = GetLocalInt(OBJECT_SELF, "DeityList_Count") - nStartEntry;
    int nCurrentToken = 0;

    // Cap the stop token.
    if ( nStopToken > TOKENLIST_LENGTH )
        nStopToken = TOKENLIST_LENGTH - 1;
        // Subtract one to make room for the "More" option.

    // Loop through the list.
    while ( nCurrentToken < nStopToken )
    {
        // Record the next deity's name in a token.
        SetCustomToken(TOKENLIST_START + nCurrentToken, GetDeityName(
            GetLocalInt(OBJECT_SELF, "DeityList_" + IntToString(nStartEntry + nCurrentToken)) ));

        // Next token.
        nCurrentToken++;
    }

    // Record the beginning of the list for this batch of tokens.
    SetLocalInt(OBJECT_SELF, "DeityList_Begin", nStartEntry);
    // Record the number of tokens with data.
    SetLocalInt(OBJECT_SELF, "DeityList_LastToken", nStopToken);

    // Empty any remaining tokens (just in case they show up somewhere).
    while ( nCurrentToken < TOKENLIST_LENGTH )
        SetCustomToken(TOKENLIST_START + nCurrentToken++, "");
}


///////////////////////////////////////////////////////////////////////////////
// BackupDeityListTokens()
//
// Defines conversation tokens for the previous six or seven deities that the PC
// speaker can follow.
void BackupDeityListTokens()
{
    int nStartEntry = GetLocalInt(OBJECT_SELF, "DeityList_Begin") - (TOKENLIST_LENGTH - 1);
    // One was subtracted to make room for the "More" option.
    // Don't start negative.
    if ( nStartEntry < 0 )
        nStartEntry = 0;

    int nStopToken = GetLocalInt(OBJECT_SELF, "DeityList_Count") - nStartEntry;
    int nCurrentToken = 0;

    // Cap the stop token.
    if ( nStopToken > TOKENLIST_LENGTH )
        nStopToken = TOKENLIST_LENGTH - 1;
        // Subtract one to make room for the "More" option.

    // Loop through the list.
    while ( nCurrentToken < nStopToken )
    {
        // Record the next deity's name in a token.
        SetCustomToken(TOKENLIST_START + nCurrentToken, GetDeityName(
            GetLocalInt(OBJECT_SELF, "DeityList_" + IntToString(nStartEntry + nCurrentToken)) ));

        // Next token.
        nCurrentToken++;
    }

    // Record the beginning of the list for this batch of tokens.
    SetLocalInt(OBJECT_SELF, "DeityList_Begin", nStartEntry);
    // Record the number of tokens with data.
    SetLocalInt(OBJECT_SELF, "DeityList_LastToken", nStopToken);

    // Empty any remaining tokens (just in case they show up somewhere).
    while ( nCurrentToken < TOKENLIST_LENGTH )
        SetCustomToken(TOKENLIST_START + nCurrentToken++, "");
}


///////////////////////////////////////////////////////////////////////////////
// UTILITIES
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// AlignmentToString()
//
// Converts an alignment pair to a string description.
//
// Invalid input is treated as ALIGNMENT_NEUTRAL.
//
// Note: When I last checked, 0 was the definition of ALIGNMENT_ALL.
string AlignmentToString(int nLawChaos, int nGoodEvil)
{
    string sAlignment = "";

    // Start with the law/chaos descriptor.
    switch ( nLawChaos )
    {
        case ALIGNMENT_LAWFUL:  sAlignment = "lawful-";  break;
        case ALIGNMENT_CHAOTIC: sAlignment = "chaotic-"; break;
        default:                sAlignment = "neutral-";
    }

    // Add the good/evil descriptor.
    switch ( nGoodEvil )
    {
        case ALIGNMENT_GOOD: sAlignment += "good";  break;
        case ALIGNMENT_EVIL: sAlignment += "evil"; break;
        default:             sAlignment += "neutral";
    }

    // Change "neutral-neutral" to "true neutral".
    if ( sAlignment == "neutral-neutral" )
        sAlignment = "true neutral";

    // Done.
    return sAlignment;
}


///////////////////////////////////////////////////////////////////////////////
// DomainToString()
//
// Converts a domain code to a string description.
//
// Invalid input results in "unknown".
string DomainFeatToString(int nDomain)
{
    switch ( nDomain )
    {
        case FEAT_AIR_DOMAIN_POWER:         return "air";
        case FEAT_ANIMAL_DOMAIN_POWER:      return "animal";
        case FEAT_CHAOS_DOMAIN_POWER:       return "chaos";
        case 2000:                          return "darkness"; 
        case FEAT_DEATH_DOMAIN_POWER:       return "death";
        case FEAT_DESTRUCTION_DOMAIN_POWER: return "destruction";
        case FEAT_EARTH_DOMAIN_POWER:       return "earth";
        case FEAT_EVIL_DOMAIN_POWER:        return "evil";
        case FEAT_FIRE_DOMAIN_POWER:        return "fire";
        case FEAT_GOOD_DOMAIN_POWER:        return "good";
        case FEAT_HEALING_DOMAIN_POWER:     return "healing";
        case FEAT_KNOWLEDGE_DOMAIN_POWER:   return "knowledge";
        case FEAT_LAW_DOMAIN_POWER:         return "law";
        case FEAT_LUCK_DOMAIN_POWER:        return "luck";
        case FEAT_MAGIC_DOMAIN_POWER:       return "magic";
        case FEAT_PLANT_DOMAIN_POWER:       return "plant";
        case FEAT_PROTECTION_DOMAIN_POWER:  return "protection";
        case FEAT_STRENGTH_DOMAIN_POWER:    return "strength";
        case FEAT_SUN_DOMAIN_POWER:         return "sun";
        case FEAT_TRAVEL_DOMAIN_POWER:      return "travel";
        case FEAT_TRICKERY_DOMAIN_POWER:    return "trickery";
        case FEAT_WAR_DOMAIN_POWER:         return "war";
        case FEAT_WATER_DOMAIN_POWER:       return "water";
    }

    // Default.
    return "unknown";
}

string DomainToString(int nDom) {
        int nFeat = StringToInt(Get2DAString("domains", "GrantedFeat", nDom));
        return DomainFeatToString(nFeat);
}

///////////////////////////////////////////////////////////////////////////////
// RaceToString()
//
// Converts a race code to a plural string description.
//
// Invalid input results in "unknown".
string RaceToString(int nRace)
{
    switch ( nRace )
    {
        case RACIAL_TYPE_ABERRATION:         return "aberrations";
        case RACIAL_TYPE_ANIMAL:             return "animals";
        case RACIAL_TYPE_BEAST:              return "beasts";
        case RACIAL_TYPE_CONSTRUCT:          return "constructs";
        case RACIAL_TYPE_DRAGON:             return "dragons";
        case RACIAL_TYPE_DWARF:              return "dwarves";
        case RACIAL_TYPE_ELEMENTAL:          return "elementals";
        case RACIAL_TYPE_ELF:                return "elves";
        case RACIAL_TYPE_FEY:                return "fey";
        case RACIAL_TYPE_GIANT:              return "giants";
        case RACIAL_TYPE_GNOME:              return "gnomes";
        case RACIAL_TYPE_HALFELF:            return "half-elves";
        case RACIAL_TYPE_HALFLING:           return "halflings";
        case RACIAL_TYPE_HALFORC:            return "half-orcs";
        case RACIAL_TYPE_HUMAN:              return "humans";
        case RACIAL_TYPE_HUMANOID_GOBLINOID: return "goblinoids";
        case RACIAL_TYPE_HUMANOID_MONSTROUS: return "monstrous humanoids";
        case RACIAL_TYPE_HUMANOID_ORC:       return "orcs";
        case RACIAL_TYPE_HUMANOID_REPTILIAN: return "reptilian humanoids";
        case RACIAL_TYPE_MAGICAL_BEAST:      return "magical beasts";
        case RACIAL_TYPE_OOZE:               return "oozes";
        case RACIAL_TYPE_OUTSIDER:           return "outsiders";
        case RACIAL_TYPE_SHAPECHANGER:       return "shapechangers";
        case RACIAL_TYPE_UNDEAD:             return "undead";
        case RACIAL_TYPE_VERMIN:             return "vermin";
    }

    // Default.
    return "unknown";
}


///////////////////////////////////////////////////////////////////////////////
// WeaponToString()
//
// Converts a weapon code to a string description.
// Most descriptions begins with "the".
//
// Invalid input results in "an unknown weapon".
string WeaponToString(int nWeapon)
{
    switch ( nWeapon )
    {
        case WEAPON_BASTARDSWORD:   return "the bastard sword";
        case WEAPON_BATTLEAXE:      return "the battleaxe";
        case WEAPON_CLUB:           return "the club";
        case WEAPON_DAGGER:         return "the dagger";
        case WEAPON_DART:           return "darts";
        case WEAPON_DIREMACE:       return "the dire mace";
        case WEAPON_DOUBLEAXE:      return "the double axe";
        case WEAPON_DWARVENWARAXE:  return "the dwarven waraxe";
        case WEAPON_GREATAXE:       return "the greataxe";
        case WEAPON_GREATSWORD:     return "the greatsword";
        case WEAPON_HALBERD:        return "the halberd";
        case WEAPON_HANDAXE:        return "the handaxe";
        case WEAPON_HEAVYCROSSBOW:  return "the heavy crossbow";
        case WEAPON_HEAVYFLAIL:     return "the heavy flail";
        case WEAPON_KAMA:           return "the kama";
        case WEAPON_KATANA:         return "the katana";
        case WEAPON_KUKRI:          return "the kukri";
        case WEAPON_LIGHTCROSSBOW:  return "the light crossbow";
        case WEAPON_LIGHTFLAIL:     return "the light flail";
        case WEAPON_LIGHTHAMMER:    return "the light hammer";
        case WEAPON_MACE:           return "the mace";
        case WEAPON_LONGBOW:        return "the longbow";
        case WEAPON_LONGSWORD:      return "the longsword";
        case WEAPON_MAGICSTAFF:     return "the magic staff";
        case WEAPON_MORNINGSTAR:    return "the morningstar";
        case WEAPON_QUARTERSTAFF:   return "the quarterstaff";
        case WEAPON_RAPIER:         return "the rapier";
        case WEAPON_SCIMITAR:       return "the scimitar";
        case WEAPON_SCYTHE:         return "the scythe";
        case WEAPON_SHORTBOW:       return "the shortbow";
        case WEAPON_SPEAR:          return "the spear";
        case WEAPON_SHORTSWORD:     return "the short sword";
        case WEAPON_SHURIKEN:       return "shurikens";
        case WEAPON_SICKLE:         return "the sickle";
        case WEAPON_SLING:          return "the sling";
        case WEAPON_THROWINGAXE:    return "throwing axes";
        case WEAPON_TRIDENT:        return "the trident";
        case WEAPON_TWOBLADEDSWORD: return "the two-bladed sword";
        case WEAPON_UNARMEDSTRIKE:  return "unarmed fighting";
        case WEAPON_WARHAMMER:      return "the warhammer";
        case WEAPON_WHIP:           return "the whip";

        // CEP Weapons
        case WEAPON_DOUBLESCIMITAR: return "the double scimitar";
        case WEAPON_FALCHION:       return "the falchion";
        case WEAPON_GOAD:           return "the goad";
        case WEAPON_HEAVYMACE:      return "the heavy mace";
        case WEAPON_HEAVYPICK:      return "the heavy pick";
        case WEAPON_KATAR:          return "the katar";
        case WEAPON_LIGHTPICK:      return "the light pick";
        case WEAPON_MAUL:           return "the maul";
        case WEAPON_NUNCHAKU:       return "the nunchaku";
        case WEAPON_SAI:            return "the sai";
        case WEAPON_SAP:            return "the sap";
        case WEAPON_WINDFIREWHEEL:  return "the wind-fire wheel";
    }

    // Default.
    return "an unknown weapon";
}


///////////////////////////////////////////////////////////////////////////////
// ListToStringAlign()
//
// Converts an list of alignment codes to text, as in "lawful-good or true neutral".
string ListToStringAlign(string sList)
{
    string sText = "";      // The text to be returned.
    string sCurrent = "";   // Holds the text for a single entry as we go through the list.

    // Check for no list entries.
    if ( sList == "" )
        // No list means no text.
        return "";

    // Convert the first list entry.
    sText = AlignmentToString( StringToInt(GetStringLeft(sList, 10)),
                               StringToInt(GetSubString(sList, 10, 10)) );

    // Advance to the next list entry.
    sList = GetStringRight(sList, GetStringLength(sList) - 20);

    // Check for no second list entry.
    if ( sList == "" )
        // Return what we have.
        return sText;

    // Convert the second list entry.
    sCurrent = AlignmentToString( StringToInt(GetStringLeft(sList, 10)),
                                  StringToInt(GetSubString(sList, 10, 10)) );

    // Advance to the next list entry.
    sList = GetStringRight(sList, GetStringLength(sList) - 20);

    // Check for more list entries.
    if ( sList != "" )
        // This list needs commas.
        sText += ",";

    // Loop through remaining list entries.
    while ( sList != "" )
    {
        // Append the most recent entry to sText.
        sText += " " + sCurrent + ",";

        // Convert the next list entry.
        sCurrent = AlignmentToString( StringToInt(GetStringLeft(sList, 10)),
                                      StringToInt(GetSubString(sList, 10, 10)) );

        // Advance to the next list entry.
        sList = GetStringRight(sList, GetStringLength(sList) - 20);
    }

    // Add the conjunction and return.
    return sText + " or " + sCurrent;
}


///////////////////////////////////////////////////////////////////////////////
// ListToStringDomain()
//
// Converts an list of domain codes to text, as in "animal and plant".
string ListToStringDomain(string sList)
{
    string sText = "";      // The text to be returned.
    string sCurrent = "";   // Holds the text for a single entry as we go through the list.

    // Check for no list entries.
    if ( sList == "" )
        // No list means no text.
        return "";

    // Convert the first list entry.
    sText = DomainFeatToString( StringToInt(GetStringLeft(sList, 10)) );

    // Advance to the next list entry.
    sList = GetStringRight(sList, GetStringLength(sList) - 10);

    // Check for no second list entry.
    if ( sList == "" )
        // Return what we have.
        return sText;

    // Convert the second list entry.
    sCurrent = DomainFeatToString( StringToInt(GetStringLeft(sList, 10)) );
    // Check for a doubled domain. (Often done when a deity only has one NWN domain.)
    if ( sCurrent == sText )
        sCurrent = "any single other domain";

    // Advance to the next list entry.
    sList = GetStringRight(sList, GetStringLength(sList) - 10);

    // Check for more list entries.
    if ( sList != "" )
        // This list needs commas.
        sText += ",";

    // Loop through remaining list entries.
    while ( sList != "" )
    {
        // Append the most recent entry to sText.
        sText += " " + sCurrent + ",";

        // Convert the next list entry.
        sCurrent = DomainFeatToString( StringToInt(GetStringLeft(sList, 10)) );

        // Advance to the next list entry.
        sList = GetStringRight(sList, GetStringLength(sList) - 10);
    }

    // Add the conjunction and return.
    return sText + " and " + sCurrent;
}


///////////////////////////////////////////////////////////////////////////////
// ListToStringRace()
//
// Converts an list of race codes to text, as in "dwarves or elves".
string ListToStringRace(string sList)
{
    string sText = "";      // The text to be returned.
    string sCurrent = "";   // Holds the text for a single entry as we go through the list.

    // Check for no list entries.
    if ( sList == "" )
        // No list means no text.
        return "";

    // Convert the first list entry.
    sText = RaceToString( StringToInt(GetStringLeft(sList, 10)) );

    // Advance to the next list entry.
    sList = GetStringRight(sList, GetStringLength(sList) - 10);

    // Check for no second list entry.
    if ( sList == "" )
        // Return what we have.
        return sText;

    // Convert the second list entry.
    sCurrent = RaceToString( StringToInt(GetStringLeft(sList, 10)) );

    // Advance to the next list entry.
    sList = GetStringRight(sList, GetStringLength(sList) - 10);

    // Check for more list entries.
    if ( sList != "" )
        // This list needs commas.
        sText += ",";

    // Loop through remaining list entries.
    while ( sList != "" )
    {
        // Append the most recent entry to sText.
        sText += " " + sCurrent + ",";

        // Convert the next list entry.
        sCurrent = RaceToString( StringToInt(GetStringLeft(sList, 10)) );

        // Advance to the next list entry.
        sList = GetStringRight(sList, GetStringLength(sList) - 10);
    }

    // Add the conjunction and return.
    return sText + " or " + sCurrent;
}

