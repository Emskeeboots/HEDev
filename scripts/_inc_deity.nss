//::///////////////////////////////////////////////
//:: _inc_deity
//:://////////////////////////////////////////////
/*
    deity include for Vives (ripped from Arnheim)

    Custom Script Systems incorporated:
    DDPP

    To Do:

*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 12)
//:: Modified:
//:://////////////////////////////////////////////

#include "deity_include"

#include "_inc_data"

// CONSTANTS

const string CLERIC_PRIEST      = "TK_DEITY_PRIESTS__";
const string DEITY_PARENT       = "TK_DEITY_PARENT__";
const string DEITY_ENEMY        = "TK_DEITY_ENEMY__";
const string DEITY_CONVERT      = "TK_DEITY_CONVERT__";
const string DEITY_DESCRIPTION  = "TK_DEITY_DESCRIPTION__";

// DECLARATIONS

// returns the deity index of the GetDeity string - [FILE: v2_inc_deity]
int GetGodIndex(string sName);
// returns the deity index of the main religion of which this is an offshoot - [FILE: v2_inc_deity]
int GetDeityParent(int nDeity);
// determines whether the character's deity accepts any of their classes as a priest - [FILE: v2_inc_deity]
// setting nClassType - restricts the search for a specific class
int GetIsSupportedPriest(object oPC, int nClassType = CLASS_TYPE_INVALID);
// determines whether the deity supports a specific religious class - [FILE: v2_inc_deity]
int CheckDeityPriest(int nDeity, int nClassType);
// returns TRUE if religion nEnemy is an Enemy of nDeity - [FILE: v2_inc_deity]
int CheckDeityEnemy(int nDeity, int nEnemy);
// sets the parent religion of nDeity to nParent (which is a deity index) - [FILE: v2_inc_deity]
void AddDeityParent(int nDeity, int nParent);
// sets the classtype as a priest supported by the deity - [FILE: v2_inc_deity]
void AddClericClass(int nDeity, int nClassType);
// adds a religion (nEnemy) as an enemy of nDeity - [FILE: v2_inc_deity]
void AddDeityEnemy(int nDeity, int nEnemy);
// removes the classtype as a priest supported by the deity - [FILE: v2_inc_deity]
void RemoveClericClass(int nDeity, int nClassType);
// removes a religion (nEnemy) as an enemy of nDeity - [FILE: v2_inc_deity]
void RemoveDeityEnemy(int nDeity, int nEnemy);
// returns true if the PC has a religious class - [FILE: v2_inc_deity]
int GetHasReligiousClass(object oPC);
// sets the question given when deciding whether to convert to this religion - [FILE: v2_inc_deity]
void SetDeityConvertQuestion(int nDeity, string sConvertQuestions);
// returns the question given when deciding whether to convert to this religion - [FILE: v2_inc_deity]
string GetDeityConvertQuestion(int nDeity);
// sets the general, common knowledge knowledge about the religion - [FILE: v2_inc_deity]
void SetDeityDescription(int nDeity, string sDescription);
// returns the general, common knowledge knowledge about the religion - [FILE: v2_inc_deity]
string GetDeityDescription(int nDeity);
// checks the string against the deity list, and returns a standardized name for the deity - [FILE: v2_inc_deity]
// returns an empty string on failure
string GetStandardizedDeityName(string sDeity);
// determines whether oPC recognizes nDeity - [FILE: v2_inc_deity]
int GetKnowsReligion(object oPC, int nDeity);
// sets whether oPC recognizes nDeity - [FILE: v2_inc_deity]
void SetKnowsReligion(object oPC, int nDeity, int bKnows=TRUE);
// returns true if the Deity accepts this item as an offering - [FILE: v2_inc_deity]
int GetDeityAcceptsOffering(int nDeity, object oOffering, object oSacredSpace=OBJECT_INVALID);
// returns true if the Deity accepts this item as an offering - [FILE: v2_inc_deity]
//void AddDeityOffering(int nDeity, string sOfferringTag);

// IMPLEMENTATION

int GetGodIndex(string sName)
{
    int nNumDeities = GetLocalInt(GetModule(), DEITY_COUNTER);
    int nDeity = 0;

    // Loop through the known deities.
    while ( nDeity < nNumDeities )
    {
        // Check for a match.
        if ( sName == GetLocalString(GetModule(), DEITY_NAME + IntToHexString(nDeity)) )
            // Return this index.
            return nDeity;

        ++nDeity;
    }
    // This deity was not found.
    return -1;
}

int GetDeityParent(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_PARENT + IntToHexString(nDeity));
    /*
    int nParent;
    if(nDeity>=3 && nDeity<=14)
        nParent = 3; // The Faith
    else if(nDeity>=15 && nDeity<=35)
        nParent = 15; // Polytheist
    else
        nParent = GetLocalInt(GetModule(), DEITY_PARENT + IntToHexString(nDeity));
    return nParent;
    */
}

int GetIsSupportedPriest(object oPC, int nClassType = CLASS_TYPE_INVALID)
{
    int nDeity = GetDeityIndex(oPC);
    // Get the list of accepted races.
    string sClasses = GetLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity));

    // Check for universal rejection.
    if ( sClasses == "" )
        return FALSE;

    int nClass;
    if(nClassType!=CLASS_TYPE_INVALID) // enable to check for specific class
    {
        nClass = nClassType;
        if(!GetLevelByClass(nClass,oPC)) // pc does not have the class
            return FALSE;
        else if(CheckDeityPriest(nDeity, nClass))
            return TRUE;
    }
    else
    {
        int nX = 1;
        while(nX<4)
        {
            nClass = GetClassByPosition(nX, oPC);
            if(nClass == CLASS_TYPE_INVALID) // pc has no more classes to check
                break;

            // Loop through the list of classes.
            if(CheckDeityPriest(nDeity, nClass))
                return TRUE;
            sClasses = GetLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity));
            ++nX;
        }
    }
    // If we get to this point, this character does not have a religious class supported by nDeity
    return FALSE;
}

int CheckDeityPriest(int nDeity, int nClassType)
{
    string sClasses = GetLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity));

    while ( sClasses != "" )
    {
            // Check for a match.
            if ( nClassType == StringToInt(GetStringLeft(sClasses, 10)) )
                // This deity accepts this race.
               return TRUE;

            // Proceed to the next race. (Remove the leftmost 10 characters.)
            sClasses = GetStringRight(sClasses, GetStringLength(sClasses)-10);
    }

    return FALSE;
}

int CheckDeityEnemy(int nDeity, int nEnemy)
{
    string sEnemies = GetLocalString(GetModule(), DEITY_ENEMY + IntToHexString(nDeity));

    while ( sEnemies != "" )
    {
            // Check for a match.
            if ( nEnemy == StringToInt(GetStringLeft(sEnemies, 10)) )
                // nDeity considers nEnemy as an enemy.
               return TRUE;

            // Proceed to the next race. (Remove the leftmost 10 characters.)
            sEnemies = GetStringRight(sEnemies, GetStringLength(sEnemies)-10);
    }

    return FALSE;
}

void AddDeityParent(int nDeity, int nParent)
{
    /*
    if(nParent==-1)
    {
        // This god no longer has a parent religion
        DeleteLocalString(GetModule(), DEITY_PARENT + IntToHexString(nDeity));
    }
    else
    {
        // Add nEnemy to the end of the list.
        SetLocalString(GetModule(), DEITY_PARENT + IntToHexString(nDeity),
            GetLocalString(GetModule(), DEITY_PARENT+IntToHexString(nDeity)) + IntToFLString(nParent)
                        );
        // By using fixed-length strings, we get a built-in separator.
    }
    */

    SetLocalInt(GetModule(), DEITY_PARENT + IntToHexString(nDeity), nParent);
}

void AddClericClass(int nDeity, int nClassType)
{
    if(nClassType==CLASS_TYPE_INVALID)
    {
        // This god no longer supports priests
        DeleteLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity));
    }
    else
    {
        // Add nClassType to the end of the list.
        SetLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity),
            GetLocalString(GetModule(), CLERIC_PRIEST+IntToHexString(nDeity)) + IntToFLString(nClassType)
                        );
        // By using fixed-length strings, we get a built-in separator.
    }
}

// adds a religion (nEnemy) as an enemy of nDeity - [FILE: v2_inc_deity]
void AddDeityEnemy(int nDeity, int nEnemy)
{
    if(nEnemy==-1)
    {
        // This god no longer has an enemy religion
        DeleteLocalString(GetModule(), DEITY_ENEMY + IntToHexString(nDeity));
    }
    else
    {
        // Add nEnemy to the end of the list.
        SetLocalString(GetModule(), DEITY_ENEMY + IntToHexString(nDeity),
            GetLocalString(GetModule(), DEITY_ENEMY+IntToHexString(nDeity)) + IntToFLString(nEnemy)
                        );
        // By using fixed-length strings, we get a built-in separator.
    }

}

void RemoveClericClass(int nDeity, int nClassType)
{
    string sClasses = GetLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity));

    string sNewClasses;
    string sTemp;
    while ( sClasses != "" )
    {
        sTemp   = GetStringLeft(sClasses, 10);
        // add everything but a match
        if ( nClassType != StringToInt(sTemp) )
        {
            // nDeity still considers this one an enemy.
            sNewClasses += sTemp;
        }

        // Proceed to the next class. (Remove the leftmost 10 characters.)
        sClasses = GetStringRight(sClasses, GetStringLength(sClasses)-10);
    }

    SetLocalString(GetModule(), CLERIC_PRIEST + IntToHexString(nDeity), sNewClasses);
}

void RemoveDeityEnemy(int nDeity, int nEnemy)
{
    string sEnemies = GetLocalString(GetModule(), DEITY_ENEMY + IntToHexString(nDeity));

    string sNewEnemies;
    string sTemp;
    while ( sEnemies != "" )
    {
        sTemp   = GetStringLeft(sEnemies, 10);
        // add everything but a match
        if ( nEnemy != StringToInt(sTemp) )
        {
            // nDeity still considers this one an enemy.
            sNewEnemies += sTemp;
        }

        // Proceed to the next enemy. (Remove the leftmost 10 characters.)
        sEnemies = GetStringRight(sEnemies, GetStringLength(sEnemies)-10);
    }

    SetLocalString(GetModule(), DEITY_ENEMY + IntToHexString(nDeity), sNewEnemies);
}

int GetHasReligiousClass(object oPC)
{
    if(     GetLevelByClass(CLASS_TYPE_PALADIN, oPC)
        ||  GetLevelByClass(CLASS_TYPE_DRUID, oPC)
        ||  GetLevelByClass(CLASS_TYPE_CLERIC, oPC)
        ||  GetLevelByClass(CLASS_TYPE_MONK, oPC)
        ||  GetLevelByClass(CLASS_TYPE_RANGER, oPC)>=4
       )
    {
        return TRUE;
    }
    return FALSE;
}

void SetDeityConvertQuestion(int nDeity, string sConvertQuestions)
{
    SetLocalString(GetModule(), DEITY_CONVERT + IntToHexString(nDeity),sConvertQuestions);
}

string GetDeityConvertQuestion(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_CONVERT + IntToHexString(nDeity));
}

void SetDeityDescription(int nDeity, string sDescription)
{
    SetLocalString(GetModule(), DEITY_DESCRIPTION + IntToHexString(nDeity),sDescription);
}

string GetDeityDescription(int nDeity)
{
    return GetLocalString(GetModule(), DEITY_DESCRIPTION + IntToHexString(nDeity));
}

string GetStandardizedDeityName(string sDeity)
{
    object oMod     = GetModule();
    string sMatch   = "";
    int nLength     = GetStringLength(sDeity) + 1;   // Add one for a space.
    int nNumDeities = GetLocalInt(oMod, DEITY_COUNTER);
    int nDeity      = -1;

    sDeity  = GetStringUpperCase(sDeity);

    // Loop through the known deities.
    while ( ++nDeity < nNumDeities )
    {
        // Get this deity's name.
        sMatch = GetStringUpperCase(
                    GetLocalString(oMod, DEITY_NAME+IntToHexString(nDeity))
                    );

        // Check for a match.
        if(     sDeity == sMatch
            ||  sDeity+" " == GetStringLeft(sMatch,nLength)
            ||  " "+sDeity == GetStringRight(sMatch,nLength)
          )
        {

            // return the standard name for this deity
            return GetLocalString(oMod, DEITY_NAME + IntToHexString(nDeity));
        }
    }

    // Return empty (not found).
    return "";
}

// determines whether oPC recognizes nDeity - [FILE: v2_inc_deity]
int GetKnowsReligion(object oPC, int nDeity)
{
    string sDeityName    = GetDeityName(nDeity);
    int bKnown;
    if(NBDE_GetCampaignInt(CHARACTER_DATA,"KNOW_RELIGION_"+sDeityName,oPC))
        bKnown  = TRUE;


    int nPCDeity        = GetDeityIndex(oPC);
    int bDeityRelated   = (     nDeity==nPCDeity
                            ||  GetDeityParent(nDeity)==nPCDeity
                            ||  GetDeityParent(nPCDeity)==nDeity
                          );
    //int bPCEnemyToDeity = CheckDeityEnemy(nDeity, nPCDeity);
    int bDeityEnemyToPC = CheckDeityEnemy(nPCDeity, nDeity);
    if(GetHasReligiousClass(oPC))
    {
        if(bDeityEnemyToPC || bDeityRelated)
            bKnown  = TRUE;
        else if(GetSkillRank(SKILL_LORE,oPC)+d20()>=25)
            bKnown  = TRUE;
    }
    else
    {
        if(nPCDeity==nDeity)
            bKnown  = TRUE;
        else if(GetSkillRank(SKILL_LORE,oPC)+d20()>=35)
            bKnown  = TRUE;
    }

    NBDE_SetCampaignInt(CHARACTER_DATA,"KNOW_RELIGION_"+sDeityName,bKnown,oPC);

    return bKnown;
}

// sets whether oPC recognizes nDeity - [FILE: v2_inc_deity]
void SetKnowsReligion(object oPC, int nDeity, int bKnows=TRUE)
{
    NBDE_SetCampaignInt(CHARACTER_DATA,"KNOW_RELIGION_"+GetDeityName(nDeity),bKnows,oPC);
}

int GetDeityAcceptsOffering(int nDeity, object oOffering, object oSacredSpace=OBJECT_INVALID)
{

    if(oSacredSpace!=OBJECT_INVALID)
    {
        string sSpecial = GetLocalString(oSacredSpace,"SACRED_OFFERING_SPECIAL_TAG");
        string sTag     = GetTag(oOffering);
        if(FindSubString(sTag,sSpecial)!=-1)
            return TRUE;
    }

    // presently very few offerings are accepted
    return FALSE;
}

//void main(){}
