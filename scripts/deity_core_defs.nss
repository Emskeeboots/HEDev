///////////////////////////////////////////////////////////////////////////////
// deity_core_defs.nss
//
// Created by: The Krit
// Date: 11/06/06
///////////////////////////////////////////////////////////////////////////////
//
// Core functions for pantheon implementation. Modify this file at your own
// risk!
//
// (If you don't know what you're doing, don't modify this file.)
//
///////////////////////////////////////////////////////////////////////////////
//
// To use: (for examples, see deity_onload.nss)
//
// Call AddDeity() for each deity in your world.
// The return value is an index into the list of deities.
// Note: Some feedback messages will appear odd if you add "" as a deity.
//
// Call SetDeityAlignment() to record the alignment of each deity, if needed.
// If this is not called, the default value is ALIGNMENT_ALL.
//
// Call SetDeityGender() to record each deity's gender, if needed.
// If this is not called, the default value is GENDER_NONE.
//
// Call SetDeityWeapon() to record each deity's favored weapon, if needed.
// If this is not called, the default value is WEAPON_NONE.
// The favored weapon scripts of this package will have no effect if both the
// weapon and weapon alternate are WEAPON_NONE.
// To indicate favoring fighting without weapons, set this to WEAPON_UNARMED.
//
// Call SetDeityWeaponAlternate() to record each deity's second favored
// weapon, if needed. If this is not called, the default value is WEAPON_NONE.
// The favored weapon scripts of this package will have no effect if both the
// weapon and weapon alternate are WEAPON_NONE.
//
// Call AddClericAlignment() to set an alignment allowed for clerics of each
// deity. If this is not called, all alignments are allowed.
//
// Call AddClericDomain() to set an allowed domain for clerics of each deity.
// If this is not called, all domains are allowed.
// Note: If a deity has but one allowed domain, no PC can qualify as a cleric
// of that deity. If a deity has a duplicate in the list, a PC needs just that
// one domain to qualify.
//
// Call AddClericRace() to set a race allowed for clerics of each deity. If
// this is not called, all races are allowed.
//
// Call SetClericSubrace() to set the only subrace allowed for clerics of each
// deity. If this is not called, all subraces are allowed. If both this and
// AddClericRace are called, clerics must both have this subrace set and be
// one of the races specified.
//
// Call GetDeityIndex() instead of GetDeity() to get the index corresponding
// to a PC's deity.
//
// Call GetDeityName() to get the name corresponfing to an index.
//
// Call GetDeityAlignmentLC() to get a deity's law/chaos alignment.
//
// Call GetDeityAlignmentGE() to get a deity's good/evil alignment.
//
// Call GetDeityGender() to get a deity's gender.
//
// Call GetDeityWeapon() to retrieve a deity's preferred weapon, as a
// WEAPON_* constant.
//
// Call GetDeityWeaponAlternate() to retrieve a deity's second preferred weapon,
// as a WEAPON_* constant.
//
// Call GetDeitySubrace() to get the subrace required of a deity's clerics.
//
// Call GetDeityCount() to get the number of deities in the pantheon.
//
// Call ShiftAlignmentTowardsDeity() to adjust a PC's alignment towards the
// PC's deity's alignment. Could be useful for rewards.
//
// Call StandardizeDeityName() for all the new PC's if you want to allow
// a somewhat more forgiving entry of deities at character creation.
// Specifically, case will not matter, and matching the first or last word(s)
// of a deity's name will be close enough. (Players wishing to follow a
// deity like "Solonor Thelandira" may appreciate this feature.)
//
///////////////////////////////////////////////////////////////////////////////

#include "x3_inc_skin"

// Configuration settings.
#include "deity_configure"


// New feats available if the .hak is used.
// (These constants have no effect if the .hak is not used.)
const int FEAT_CHAOS_DOMAIN_POWER = 1203;
const int FEAT_LAW_DOMAIN_POWER   = 1204;

// Not yet implemented 
const int FEAT_DARKNESS_DOMAIN_POWER   = 2000;

// The names of module variables used to track the deities.
const string DEITY_COUNTER    = "TK_DEITY_COUNTER";
const string DEITY_NAME       = "TK_DEITY_NAME_";
const string DEITY_ALIGNMENT  = "TK_DEITY_PRIMARY_ALIGNMENT_";
const string DEITY_GENDER     = "TK_DEITY_GENDER_";
const string CLERIC_ALIGNMENT = "TK_DEITY_ALIGNMENTS_";
const string CLERIC_DOMAIN    = "TK_DEITY_DOMAINS_";
const string CLERIC_RACE      = "TK_DEITY_RACES_";
const string CLERIC_GENDER    = "TK_DEITY_CLERIC_GENDER_";
const string CLERIC_SUBRACE   = "TK_DEITY_SUBRACE_";
const string DEITY_WEAPON     = "TK_DEITY_WEAPON_";
const string DEITY_WEAPON_ALT = "TK_DEITY_WEAPONALT_";
const string DEITY_CLASSES    = "TK_DEITY_CLASSES_";


// The database that will be used for any persistent data.
// (Currently, the only persistent data is favored weapon status.)
const string DEITY_DATABASE = "TK_Deity";


// A value that is not valid for effect constructors.
// -1 is valid for EffectSpellImmunity() and EffectSpellLevelAbsorption().
const int PARAMETER_INVALID = -2;

// Effect types not defined by BioWare:
const int EFFECT_TYPE_CUTSCENEDOMINATED = 100;
const int EFFECT_TYPE_DAMAGE            = 101;
const int EFFECT_TYPE_DEATH             = 102;
const int EFFECT_TYPE_HEAL              = 103;
const int EFFECT_TYPE_KNOCKDOWN         = 104;
const int EFFECT_TYPE_MODIFYATTACKS     = 105;

// These are flags that determine which classes are allowed to serve (not follow) a given deity
const int DEITY_CLASS_CLERIC            = 0x01;
const int DEITY_CLASS_DRUID             = 0x02;
const int DEITY_CLASS_PALADIN           = 0x04;
const int DEITY_CLASS_RANGER            = 0x08;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Adds sName as an accepted deity.
int AddDeity(string sName);

// Records the alignment of deity nDeity.
// This is unique, unlike the allowed alignments of clerics.
// nDeity should be a return value of AddDeity(), and nLawChaos and nGoodEvil
// should be ALIGNMENT_* constants.
void SetDeityAlignment(int nDeity, int nLawChaos, int nGoodEvil);

// Records nGender as the gender of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetDeityGender(int nDeity, int nGender);

// Records nWeapon as the favored weapon of deity nDeity.
// nDeity should be a return value of AddDeity().
// nWeapon should be a WEAPON_* constant.
// bPropogate should be TRUE if favored weapon effects are being used and this
// function is called to change a favored weapon in the middle of the game
// (unless the second favored weapon is also about to change).
//
// To indicate favoring fighting without weapons, nWeapon should be WEAPON_UNARMED.
void SetDeityWeapon(int nDeity, int nWeapon, int bPropogate = FALSE);

// Records nWeapon as the second favored weapon of deity nDeity.
// nDeity should be a return value of AddDeity().
// nWeapon should be a WEAPON_* constant.
// bPropogate should be TRUE if favored weapon effects are being used and this
// function is called to change a favored weapon in the middle of the game.
void SetDeityWeaponAlternate(int nDeity, int nWeapon, int bPropogate = FALSE);

// Adds nAlign as an allowed alignment of clerics of deity nDeity.
// nDeity should be a return value of AddDeity(), and nAlign should be one of
// the ALIGNMENT_* constants.
void AddClericAlignment(int nDeity, int nLawChaos, int nGoodEvil);

// Adds nDomain as an allowed domain of clerics of deity nDeity.
// nDeity should be a return value of AddDeity(), and nDomain should be one of
// the FEAT_*_DOMAIN_POWER (or DOMAIN_*) constants.
// A deity will not be able to have any clerics if exactly one domain is added
// by this function.
void AddClericDomain(int nDeity, int nDomain);

// Adds nRace as an allowed race of clerics of deity nDeity.
// nDeity should be a return value of AddDeity(), and nRace should be one of
// the RACIAL_TYPE_* constants.
void AddClericRace(int nDeity, int nRace);

// Adds nClass as an allowed class for servants (clerics/paladins/druid/rangers) of deity nDeity.
// nDeity should be a return value of AddDeity(), and nClass should be one of
// the CLASS_TYPE_* constants which uses divine spells.
void AddDeityClass(int nDeity, int nClass);

// sets nGender as the only allowed gender of clerics of deity nDeity.
// nDeity should be a return value of AddDeity(), and nGender should be one of
// GENDER_MALE or GENDER_FEMALE to restrict clerics to the given gender. Only
// one setting is allowed. Unset it allows both genders.
void SetClericGender(int nDeity, int nRace);

// Records sSubrace as the only allowed subrace of clerics of deity nDeity.
// nDeity should be a return value of AddDeity().
void SetClericSubrace(int nDeity, string sSubrace);

// If the given deity name was added by addDeity then this returns that deity's index.
// Returns -1 if the deity does not have an index (i.e. is not valid).
int GetDeityIndexFromName(string sName);

// If oPC's deity was added by AddDeity, returns that deity's index.
// Returns -1 if the deity does not have an index (i.e. is not valid).
int GetDeityIndex(object oPC);

// Returns the name of deity nDeity.
string GetDeityName(int nDeity);

// Returns the law/chaos alignment of deity nDeity.
int GetDeityAlignmentLC(int nDeity);

// Returns the good/evil alignment of deity nDeity.
int GetDeityAlignmentGE(int nDeity);

// Returns the gender of deity nDeity.
int GetDeityGender(int nDeity);

// Returns the favored weapon of deity nDeity as a WEAPON_* constant.
int GetDeityWeapon(int nDeity);

// Returns the second favored weapon of deity nDeity as a WEAPON_* constant.
int GetDeityWeaponAlternate(int nDeity);

// Returns the only allowed subrace of clerics of deity nDeity.
string GetClericSubrace(int nDeity);

// Return GENDER_MALE, GENDER_FEMALE or GENDER_BOTH
int GetClericGender(int nDeity);

// Returns the number of deities entered into the pantheon.
int GetDeityCount();

// Moves oPC's alignment towards oPC's deity's alignment by nAmount.
// The default for nAmount may be appropriate for tithing.
void ShiftAlignmentTowardsDeity(object oPC, int nAmount = 1);

// If oPC's deity field is a case-insensitive match to the beginning or end
// word(s) of a deity's name, this resets the deity field to the standard name.
//
// I am not checking for middle names because they are not that popular
// (non-existent, in fact, among the standard pantheon), and matching the middle
// word of something like "Thor of Olympus" seems strange.
//
// If there are multiple matches, only the first one counts. (Warn your players
// if your pantheon has re-used names.)
//
// Returns TRUE if a match is found.
int StandardizeDeityName(object oPC);


///////////////////////////////////////////////////////////////////////////////
// Utilities, prototyped:

// Generates an effect previously recorded by SetLocalEffect().
// Returns an effect of type EFFECT_TYPE_INVALIDEFFECT on error.
// NOTE: The creator of the effect is this script, not whoever recorded the effect.
effect GetLocalEffect(object oObject, string sVarName);

// Returns oPC's hide. If none exists, one is created.
// This function might clear oPC's action queue.
object GetSkin(object oPC);

// Converts an integer to a Fixed-Length string.
//
// The length of the string returned is 10 characters, making this function
// roughly equivalent to IntToHexString, but the strings from this function
// can be converted back to integers by StringToInt().
string IntToFLString(int nInteger);

// Moves oSubject's alignment by nAmount, towards nLawChaos along the law/chaos
// axis, and towards nGoodEvil along the good/evil axis.
//
// Shifts towards neutrality ony affect oSubject if oSubject is not already
// neutral on that axis or if both shifts are towards neutrality.
//
// nLawChaos and nGoodEvil should be appropriate ALIGNMENT_* constants.
void ShiftAlignment(object oSubject, int nLawChaos, int nGoodEvil, int nAmount);

// Stores the parameters for an effect in local variables.
//
// nEffectType must be an EFFECT_TYPE_* constant.
// Unsupported constants: EFFECT_TYPE_ARCANE_SPELL_FAILURE, EFFECT_TYPE_AREA_OF_EFFECT,
//   EFFECT_TYPE_BEAM, EFFECT_TYPE_DISAPPEARAPPEAR, EFFECT_TYPE_ENEMY_ATTACK_BONUS,
//   EFFECT_TYPE_INVULNERABLE, EFFECT_TYPE_SWARM.
// Custom allowed constants: EFFECT_TYPE_CUTSCENEDOMINATED, EFFECT_TYPE_DAMAGE,
//   EFFECT_TYPE_DEATH, EFFECT_TYPE_HEAL, EFFECT_TYPE_KNOCKDOWN, EFFECT_TYPE_MODIFYATTACKS
// Unsupported constructors: EffectAppear(), EffectAreaOfEffect(), EffectBeam(),
//   EffectDisappear(), EffectDisappearAppear(), EffectHitPointChangeWhenDying(),
//   EffectLinkEffects(), EffectSummonCreature(), EffectSwarm()
// NOTE: The constant for EffectDamageShield() is EFFECT_TYPE_ELEMENTALSHIELD.
//
// nParam? are the parameters passed to the corresponding effect constructor
//   (the Effect*() functions), in the order the constructor takes them.
// Be sure to use the correct number of parameters, as there is no error checking
//   on that. If the effect constructor needs less than six parameters, leave the
//   excess at their default values. You do not have to supply parameters that are
//   optional to the constructor.
// NOTE: EffectRegenerate() takes a floating point parameter, but it must be
//   passed to this function as an integer.
void SetLocalEffect(object oObject, string sVarName, int nEffectType, int nParam1 = PARAMETER_INVALID, int nParam2 = PARAMETER_INVALID, int nParam3 = PARAMETER_INVALID, int nParam4 = PARAMETER_INVALID, int nParam5 = PARAMETER_INVALID, int nParam6 = PARAMETER_INVALID);



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// AddDeity()
//
// Adds sName as an accepted deity.
//
int AddDeity(string sName) {
    // Get the index for the next deity entry.
    int nDeity = GetLocalInt(GetModule(), DEITY_COUNTER);
    // Store sName in the next slot.
    SetLocalString(GetModule(), DEITY_NAME + IntToHexString(nDeity), sName);
    // Record the new length of the deity list.
    SetLocalInt(GetModule(), DEITY_COUNTER, nDeity+1);

    // Hack to default the gender to be GENDER_NONE. (The normal default of 0 is GENDER_MALE.)
    SetDeityGender(nDeity, GENDER_NONE);

    // Hack to default the favored weapons to WEAPON_NONE. (The normal default
    // of 0 could possibly -- albeit unlikely -- be confused with the
    // Ambidexterity feat's item property.)
    SetDeityWeapon(nDeity, WEAPON_NONE);
    SetDeityWeaponAlternate(nDeity, WEAPON_NONE);

    // Return the index of this entry.
    return nDeity;
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityAlignment()
//
// Records the alignment of deity nDeity.
// This is unique, unlike the allowed alignments of clerics.
//
// nDeity should be a return value of AddDeity(), and nLawChaos and nGoodEvil
// should be ALIGNMENT_* constants.
//
void SetDeityAlignment(int nDeity, int nLawChaos, int nGoodEvil)
{
    SetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_LC", nLawChaos);
    SetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_GE", nGoodEvil);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityGender()
//
// Records nGender as the gender of deity nDeity.
//
// nDeity should be a return value of AddDeity().
void SetDeityGender(int nDeity, int nGender)
{
    SetLocalInt(GetModule(), DEITY_GENDER + IntToHexString(nDeity), nGender);
}

///////////////////////////////////////////////////////////////////////////////
// SetDeityWeapon()
//
// Records nWeapon as the favored weapon of deity nDeity.
//
// nDeity should be a return value of AddDeity().
// nWeapon should be a WEAPON_* constant.
// bPropogate should be TRUE if favored weapon effects are being used and this
// function is called to change a favored weapon in the middle of the game
// (unless the second favored weapon is also about to change).
//
// To indicate favoring fighting without weapons, nWeapon should be WEAPON_UNARMED.
//
void SetDeityWeapon(int nDeity, int nWeapon, int bPropogate = FALSE)
{
    SetLocalInt(GetModule(), DEITY_WEAPON + IntToHexString(nDeity), nWeapon);

    // See if this change should be propogated to all PC's.
    if ( bPropogate )
    {
        // Loop through all PC's.
        object oPC = GetFirstPC();
        while ( GetIsObjectValid(oPC) )
        {
            // Did this PC's deity's favored weapon change?
            if ( GetDeityIndex(oPC) == nDeity )
                // Tell the PC to update itself.
                ExecuteScript("deity_core_pc_fw", oPC);
            oPC = GetNextPC();
        }
    }
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityWeaponAlternate()
//
// Records nWeapon as the second favored weapon of deity nDeity.
//
// nDeity should be a return value of AddDeity().
// nWeapon should be a WEAPON_* constant.
// bPropogate should be TRUE if favored weapon effects are being used and this
// function is called to change a favored weapon in the middle of the game.
//
void SetDeityWeaponAlternate(int nDeity, int nWeapon, int bPropogate = FALSE)
{
    SetLocalInt(GetModule(), DEITY_WEAPON_ALT + IntToHexString(nDeity), nWeapon);

    // See if this change should be propogated to all PC's.
    if ( bPropogate )
    {
        // Loop through all PC's.
        object oPC = GetFirstPC();
        while ( GetIsObjectValid(oPC) )
        {
            // Did this PC's deity's favored weapon change?
            if ( GetDeityIndex(oPC) == nDeity )
                // Tell the PC to update itself.
                ExecuteScript("deity_core_pc_fw", oPC);
            oPC = GetNextPC();
        }
    }
}


///////////////////////////////////////////////////////////////////////////////
// AddClericAlignment()
//
// Adds nAlign as an allowed alignment of clerics of deity nDeity.
//
// nDeity should be a return value of AddDeity(), and nAlign should be one of
// the ALIGNMENT_* constants.
//
void AddClericAlignment(int nDeity, int nLawChaos, int nGoodEvil)
{
    // Add this alignment to the end of the list.
    SetLocalString(GetModule(), CLERIC_ALIGNMENT + IntToHexString(nDeity),
        GetLocalString(GetModule(), CLERIC_ALIGNMENT + IntToHexString(nDeity)) +
        IntToFLString(nLawChaos) + IntToFLString(nGoodEvil));
        // By using fixed-length strings, we get a built-in separator.
}


///////////////////////////////////////////////////////////////////////////////
// AddClericDomain()
//
// Adds nDomain as an allowed domain of clerics of deity nDeity.
//
// nDeity should be a return value of AddDeity(), and nDomain should be one of
// the FEAT_*_DOMAIN_POWER (or DOMAIN_*) constants.
//
// A deity will not be able to have any clerics if exactly one domain is added
// by this function.
//
void AddClericDomain(int nDeity, int nDomain)
{
    // Add nDomain to the end of the list.
    SetLocalString(GetModule(), CLERIC_DOMAIN + IntToHexString(nDeity),
        GetLocalString(GetModule(), CLERIC_DOMAIN + IntToHexString(nDeity)) +
        IntToFLString(nDomain));
        // By using fixed-length strings, we get a built-in separator.
}


///////////////////////////////////////////////////////////////////////////////
// AddClericRace()
//
// Adds nRace as an allowed race of clerics of deity nDeity.
//
// nDeity should be a return value of AddDeity(), and nRace should be one of
// the RACIAL_TYPE_* constants.
//
void AddClericRace(int nDeity, int nRace)
{
    // Add nRace to the end of the list.
    SetLocalString(GetModule(), CLERIC_RACE + IntToHexString(nDeity),
        GetLocalString(GetModule(), CLERIC_RACE + IntToHexString(nDeity)) +
        IntToFLString(nRace));
        // By using fixed-length strings, we get a built-in separator.
}

int deityGetClassBit(int nClass) {
        switch (nClass) {
                case CLASS_TYPE_CLERIC: return DEITY_CLASS_CLERIC;
                case CLASS_TYPE_DRUID: return DEITY_CLASS_DRUID;
                case CLASS_TYPE_PALADIN: return DEITY_CLASS_PALADIN;
                case CLASS_TYPE_RANGER: return DEITY_CLASS_RANGER;
        }
        return 0;
}

///////////////////////////////////////////////////////////////////////////////
// AddDeityClass()
//
// Adds nClass as an allowed class for servants of deity nDeity. This applies to 
// Classes that use divine spells (cleric/paladin/druid/ranger)
//
// nDeity should be a return value of AddDeity(), and nClass should be one of
// the CLASS_TYPE_* constants.
//
void AddDeityClass(int nDeity, int nClass)
{
    // Add nClass to the bit map 
    int nCur = GetLocalInt(GetModule(), DEITY_CLASSES + IntToHexString(nDeity));
    SetLocalInt(GetModule(), DEITY_CLASSES + IntToHexString(nDeity), nCur + deityGetClassBit(nClass));

}

////////////////////////////
// GetDeityClasses() 
// Return the full bitmap of allowed classes  (DEITY_CLASS_*)
// nDeity should be a return value of AddDeity(),
int GetDeityClasses(int nDeity) {
        return GetLocalInt(GetModule(), DEITY_CLASSES + IntToHexString(nDeity));
}

/////////////////////
// GetDeityCanClass()
// Return TRUE if nClass can server nDeity. 
// nDeity should be a return value of AddDeity(), and nClass should be one of
// the CLASS_TYPE_* constants.
int GetDeityCanClass(int nDeity, int nClass) {
        int nClasses = GetDeityClasses(nDeity);
        if (!nClasses) return FALSE;

        return (nClasses && deityGetClassBit(nClass));
}

///////////////////////////////////////////////////////////////////////////////
// SetClericGender()
//
// sets nGender as an allowed gender of clerics of deity nDeity.
//
//
void SetClericGender(int nDeity, int nGender) {
    int nVal = 0;
    if (nGender == GENDER_MALE)
        nVal = 1;
    else if (nGender == GENDER_FEMALE)
        nVal = 2;
    
    //WriteTimestampedLogEntry ("ClericGender for " + GetDeityName(nDeity) + " set to " + IntToString(nVal));
    if (nVal) {
        SetLocalInt(GetModule(), CLERIC_GENDER + IntToHexString(nDeity), nVal);
    } else
        DeleteLocalInt(GetModule(), CLERIC_GENDER + IntToHexString(nDeity));
}

///////////////////////////////////////////////////////////////////////////////
// GetClericGender()
//
// Returns GENDER_MALE, GENDER_FEMALE, or GENDER_BOTH
//
//
int GetClericGender(int nDeity) {
    int nRet = GetLocalInt(GetModule(), CLERIC_GENDER + IntToHexString(nDeity));
    db("GetClericGender for " + GetDeityName(nDeity) + " got var " + IntToString(nRet));
    WriteTimestampedLogEntry( "GetClericGender for " + GetDeityName(nDeity) + " got var " + IntToString(nRet));
    if (nRet == 1)
        return GENDER_MALE;
    if (nRet == 2)
        return GENDER_FEMALE;

    return GENDER_BOTH;
}




///////////////////////////////////////////////////////////////////////////////
// SetClericSubrace()
//
// Records sSubrace as the only allowed subrace of clerics of deity nDeity.
//
// nDeity should be a return value of AddDeity().
//
void SetClericSubrace(int nDeity, string sSubrace)
{
    SetLocalString(GetModule(), CLERIC_SUBRACE + IntToHexString(nDeity), sSubrace);
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityIndexFromName()
//
// If the given deity name was added by addDeity then this returns that deity's index.
//
// Returns -1 if the deity does not have an index (i.e. is not valid).
//
int GetDeityIndexFromName(string sName) {

    int nNumDeities = GetLocalInt(GetModule(), DEITY_COUNTER);
    int nDeity = -1;

    string sTmp = GetStringLowerCase(sName);

    // Loop through the known deities.
    while (++nDeity < nNumDeities) {
        if ( sTmp == GetStringLowerCase(GetLocalString(GetModule(), DEITY_NAME + IntToHexString(nDeity))) )
            return nDeity;
    }

    // This deity was not found.
    return -1;
}

///////////////////////////////////////////////////////////////////////////////
// GetDeityIndex()
//
// If oPC's deity was added by AddDeity, returns that deity's index.
//
// Returns -1 if the deity does not have an index (i.e. is not valid).
//
int GetDeityIndex(object oPC) {

	int nRet = GetLocalInt(oPC, "deity_cached_idx");
	if (nRet > 0) return nRet;
	if (nRet == 0 && GetLocalInt(oPC, "deity_cache_valid")) return 0;
	
	string sName = GetDeity(oPC);
	nRet = GetDeityIndexFromName(sName);

	if (nRet >= 0) {
		SetLocalInt(oPC, "deity_cached_idx", nRet);
		SetLocalInt(oPC, "deity_cache_valid", 1);
		return nRet;
	}
	return -1;
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityName()
//
// Returns the name of deity nDeity.
//
string GetDeityName(int nDeity) {
    return GetLocalString(GetModule(), DEITY_NAME + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityAlignmentLC()
//
// Returns the law/chaos alignment of deity nDeity.
//
int GetDeityAlignmentLC(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_LC");
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityAlignmentGE()
//
// Returns the good/evil alignment of deity nDeity.
//
int GetDeityAlignmentGE(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_GE");
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityGender()
//
// Returns the gender of deity nDeity.
//
int GetDeityGender(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_GENDER + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityWeapon()
//
// Returns the favored weapon of deity nDeity as a WEAPON_* constant.
//
int GetDeityWeapon(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_WEAPON + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityWeaponAlternate()
//
// Returns the second favored weapon of deity nDeity as a WEAPON_* constant.
//
int GetDeityWeaponAlternate(int nDeity)
{
    return GetLocalInt(GetModule(), DEITY_WEAPON_ALT + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetClericSubrace()
//
// Returns the only allowed subrace of clerics of deity nDeity.
//
string GetClericSubrace(int nDeity)
{
    return GetLocalString(GetModule(), CLERIC_SUBRACE + IntToHexString(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// GetDeityCount()
//
// Returns the number of deities entered into the pantheon.
//
int GetDeityCount()
{
    return GetLocalInt(GetModule(), DEITY_COUNTER);
}


///////////////////////////////////////////////////////////////////////////////
// ShiftAlignmentTowardsDeity()
//
// Moves oPC's alignment towards oPC's deity's alignment by nAmount.
//
// The default for nAmount may be appropriate for tithing.
//
void ShiftAlignmentTowardsDeity(object oPC, int nAmount = 1) {
    // Get oPC's deity's index.
    int nDeity = GetDeityIndex(oPC);

    // Abort if the deity is unknown.
    if ( nDeity < 0 )
        return;

    // Shift oPC towards the alignment stored for nDeity by SetDeityAlignment().
    ShiftAlignment(oPC,
        GetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_LC"),
        GetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_GE"),
        nAmount);
}


///////////////////////////////////////////////////////////////////////////////
// StandardizeDeityName()
//
// If oPC's deity field is a case-insensitive match to the beginning or end
// word(s) of a deity's name, this resets the deity field to the standard name.
//
// I am not checking for middle names because they are not that popular
// (non-existent, in fact, among the standard pantheon), and matching the middle
// word of something like "Thor of Olympus" seems strange.
//
// If there are multiple matches, only the first one counts. (Warn your players
// if your pantheon has re-used names.)
//
// Returns TRUE if a match is found.
//
int StandardizeDeityName(object oPC) {
    string sName = GetStringUpperCase(GetDeity(oPC));
    string sMatch = "";
    object oMod = GetModule();
    int nLength = GetStringLength(sName) + 1;   // Add one for a space.
    int nNumDeities = GetLocalInt(oMod, DEITY_COUNTER);
    int nDeity = -1;


    // Loop through the known deities.
    while ( ++nDeity < nNumDeities ) {
        // Get this deity's name.
        sMatch = GetStringUpperCase(
                    GetLocalString(oMod, DEITY_NAME + IntToHexString(nDeity)) );

        // Special handling for Selûne's special character.
        if ( sMatch == "SELûNE"  &&  sName == "SELUNE" )
            sName = sMatch;

        // Check for a match.
        if ( sName == sMatch  ||
             sName + " " == GetStringLeft(sMatch, nLength)  ||
             " " + sName == GetStringRight(sMatch, nLength) )
        {
            // Set oPC's deity to the standard name.
            SetDeity(oPC,
                GetLocalString(oMod, DEITY_NAME + IntToHexString(nDeity)) );

            // Return TRUE (found).
            return TRUE;
        }
    }

    // Return FALSE (not found).
    return FALSE;
}


///////////////////////////////////////////////////////////////////////////////
// UTILITIES
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// GetLocalEffect()
//
// Generates an effect previously recorded by SetLocalEffect().
//
// Returns an effect of type EFFECT_TYPE_INVALIDEFFECT on error.
//
// NOTE: The creator of the effect is this script, not whoever recorded the effect.
//
effect GetLocalEffect(object oObject, string sVarName) {
    // Retrieve the stored parameters.
    int nParam1 = GetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_1");
    int nParam2 = GetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_2");
    int nParam3 = GetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_3");
    int nParam4 = GetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_4");
    int nParam5 = GetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_5");
    int nParam6 = GetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_6");

    // Switch on the type of effect recorded.
    // If the type was not set, it defaults to 0, a.k.a. EFFECT_TYPE_INVALIDEFFECT.
    // For each type, we'll return the result of the associated effect constructor.
    switch ( GetLocalInt(oObject, sVarName + "_TK__EFFECT_TYPE") )
    {
        case EFFECT_TYPE_ABILITY_DECREASE:
                return EffectAbilityDecrease(nParam1, nParam2);

        case EFFECT_TYPE_ABILITY_INCREASE:
                return EffectAbilityIncrease(nParam1, nParam2);

        case EFFECT_TYPE_AC_DECREASE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectACDecrease(nParam1);
                else if ( nParam3 == PARAMETER_INVALID )
                    return EffectACDecrease(nParam1, nParam2);
                else
                    return EffectACDecrease(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_AC_INCREASE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectACIncrease(nParam1);
                else if ( nParam3 == PARAMETER_INVALID )
                    return EffectACIncrease(nParam1, nParam2);
                else
                    return EffectACIncrease(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_ATTACK_DECREASE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectAttackDecrease(nParam1);
                else
                    return EffectAttackDecrease(nParam1, nParam2);

        case EFFECT_TYPE_ATTACK_INCREASE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectAttackIncrease(nParam1);
                else
                    return EffectAttackIncrease(nParam1, nParam2);

        case EFFECT_TYPE_BLINDNESS:
                return EffectBlindness();

        case EFFECT_TYPE_CHARMED:
                return EffectCharmed();

        case EFFECT_TYPE_CONCEALMENT:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectConcealment(nParam1);
                else
                    return EffectConcealment(nParam1, nParam2);

        case EFFECT_TYPE_CONFUSED:
                return EffectConfused();

        case EFFECT_TYPE_CURSE:
                // Check for optional parameters.
                if ( nParam1 == PARAMETER_INVALID )
                    return EffectCurse();
                else if ( nParam2 == PARAMETER_INVALID )
                    return EffectCurse(nParam1);
                else if ( nParam3 == PARAMETER_INVALID )
                    return EffectCurse(nParam1, nParam2);
                else if ( nParam4 == PARAMETER_INVALID )
                    return EffectCurse(nParam1, nParam2, nParam3);
                else if ( nParam5 == PARAMETER_INVALID )
                    return EffectCurse(nParam1, nParam2, nParam3, nParam4);
                else if ( nParam6 == PARAMETER_INVALID )
                    return EffectCurse(nParam1, nParam2, nParam3, nParam4, nParam5);
                else
                    return EffectCurse(nParam1, nParam2, nParam3, nParam4, nParam5, nParam6);

        case EFFECT_TYPE_CUTSCENE_PARALYZE:
                return EffectCutsceneParalyze();

        case EFFECT_TYPE_CUTSCENEDOMINATED:
                return EffectCutsceneDominated();

        case EFFECT_TYPE_CUTSCENEGHOST:
                return EffectCutsceneGhost();

        case EFFECT_TYPE_CUTSCENEIMMOBILIZE:
                return EffectCutsceneImmobilize();

        case EFFECT_TYPE_DAMAGE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectDamage(nParam1);
                else if ( nParam3 == PARAMETER_INVALID )
                    return EffectDamage(nParam1, nParam2);
                else
                    return EffectDamage(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_DAMAGE_DECREASE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectDamageDecrease(nParam1);
                else
                    return EffectDamageDecrease(nParam1, nParam2);

        case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
                return EffectDamageImmunityDecrease(nParam1, nParam2);

        case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE:
                return EffectDamageImmunityIncrease(nParam1, nParam2);

        case EFFECT_TYPE_DAMAGE_INCREASE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectDamageIncrease(nParam1);
                else
                    return EffectDamageIncrease(nParam1, nParam2);

        case EFFECT_TYPE_DAMAGE_REDUCTION:
                // Check for optional parameters.
                if ( nParam3 == PARAMETER_INVALID )
                    return EffectDamageReduction(nParam1, nParam2);
                else
                    return EffectDamageReduction(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_DAMAGE_RESISTANCE:
                // Check for optional parameters.
                if ( nParam3 == PARAMETER_INVALID )
                    return EffectDamageResistance(nParam1, nParam2);
                else
                    return EffectDamageResistance(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_DARKNESS:
                return EffectDarkness();

        case EFFECT_TYPE_DAZED:
                return EffectDazed();

        case EFFECT_TYPE_DEAF:
                return EffectDeaf();

        case EFFECT_TYPE_DEATH:
                // Check for optional parameters.
                if ( nParam1 == PARAMETER_INVALID )
                    return EffectDeath();
                else if ( nParam2 == PARAMETER_INVALID )
                    return EffectDeath(nParam1);
                else
                    return EffectDeath(nParam1, nParam2);

        case EFFECT_TYPE_DISEASE:
                return EffectDisease(nParam1);

        case EFFECT_TYPE_DISPELMAGICALL:
                // Check for optional parameters.
                if ( nParam1 == PARAMETER_INVALID )
                    return EffectDispelMagicAll();
                else
                    return EffectDispelMagicAll(nParam1);

        case EFFECT_TYPE_DISPELMAGICBEST:
                // Check for optional parameters.
                if ( nParam1 == PARAMETER_INVALID )
                    return EffectDispelMagicBest();
                else
                    return EffectDispelMagicBest(nParam1);

        case EFFECT_TYPE_DOMINATED:
                return EffectDominated();

        case EFFECT_TYPE_ELEMENTALSHIELD:
                return EffectDamageShield(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_ENTANGLE:
                return EffectEntangle();

        case EFFECT_TYPE_ETHEREAL:
                return EffectEthereal();

        case EFFECT_TYPE_FRIGHTENED:
                return EffectFrightened();

        case EFFECT_TYPE_HASTE:
                return EffectHaste();

        case EFFECT_TYPE_HEAL:
                return EffectHeal(nParam1);

        case EFFECT_TYPE_IMMUNITY:
                return EffectImmunity(nParam1);

        case EFFECT_TYPE_IMPROVEDINVISIBILITY:
                return EffectInvisibility(INVISIBILITY_TYPE_IMPROVED);

        case EFFECT_TYPE_INVISIBILITY:
                return EffectInvisibility(nParam1);

        case EFFECT_TYPE_KNOCKDOWN:
                return EffectKnockdown();

        case EFFECT_TYPE_MISS_CHANCE:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectMissChance(nParam1);
                else
                    return EffectMissChance(nParam1, nParam2);

        case EFFECT_TYPE_MODIFYATTACKS:
                return EffectModifyAttacks(nParam1);

        case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                return EffectMovementSpeedDecrease(nParam1);

        case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE:
                return EffectMovementSpeedIncrease(nParam1);

        case EFFECT_TYPE_NEGATIVELEVEL:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectNegativeLevel(nParam1);
                else
                    return EffectNegativeLevel(nParam1, nParam2);

        case EFFECT_TYPE_PARALYZE:
                return EffectParalyze();

        case EFFECT_TYPE_PETRIFY:
                return EffectPetrify();

        case EFFECT_TYPE_POISON:
                return EffectPoison(nParam1);

        case EFFECT_TYPE_POLYMORPH:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectPolymorph(nParam1);
                else
                    return EffectPolymorph(nParam1, nParam2);

        case EFFECT_TYPE_REGENERATE:
                return EffectRegenerate(nParam1, IntToFloat(nParam2));

        case EFFECT_TYPE_RESURRECTION:
                return EffectResurrection();

        case EFFECT_TYPE_SANCTUARY:
                return EffectSanctuary(nParam1);

        case EFFECT_TYPE_SAVING_THROW_DECREASE:
                // Check for optional parameters.
                if ( nParam3 == PARAMETER_INVALID )
                    return EffectSavingThrowDecrease(nParam1, nParam2);
                else
                    return EffectSavingThrowDecrease(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_SAVING_THROW_INCREASE:
                // Check for optional parameters.
                if ( nParam3 == PARAMETER_INVALID )
                    return EffectSavingThrowIncrease(nParam1, nParam2);
                else
                    return EffectSavingThrowIncrease(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_SEEINVISIBLE:
                return EffectSeeInvisible();

        case EFFECT_TYPE_SILENCE:
                return EffectSilence();

        case EFFECT_TYPE_SKILL_DECREASE:
                return EffectSkillDecrease(nParam1, nParam2);

        case EFFECT_TYPE_SKILL_INCREASE:
                return EffectSkillIncrease(nParam1, nParam2);

        case EFFECT_TYPE_SLEEP:
                return EffectSleep();

        case EFFECT_TYPE_SLOW:
                return EffectSlow();

        case EFFECT_TYPE_SPELL_FAILURE:
                // Check for optional parameters.
                if ( nParam1 == PARAMETER_INVALID )
                    return EffectSpellFailure();
                else if ( nParam2 == PARAMETER_INVALID )
                    return EffectSpellFailure(nParam1);
                else
                    return EffectSpellFailure(nParam1, nParam2);

        case EFFECT_TYPE_SPELL_IMMUNITY:
                // Check for optional parameters. (Ignoring the documented bug.)
                if ( nParam1 == PARAMETER_INVALID )
                    return EffectSpellImmunity();
                else
                    return EffectSpellImmunity(nParam1);

        case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
                return EffectSpellResistanceDecrease(nParam1);

        case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE:
                return EffectSpellResistanceIncrease(nParam1);

        case EFFECT_TYPE_SPELLLEVELABSORPTION:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectSpellLevelAbsorption(nParam1);
                else if ( nParam3 == PARAMETER_INVALID )
                    return EffectSpellLevelAbsorption(nParam1, nParam2);
                else
                    return EffectSpellLevelAbsorption(nParam1, nParam2, nParam3);

        case EFFECT_TYPE_STUNNED:
                return EffectStunned();

        case EFFECT_TYPE_TEMPORARY_HITPOINTS:
                return EffectTemporaryHitpoints(nParam1);

        case EFFECT_TYPE_TIMESTOP:
                return EffectTimeStop();

        case EFFECT_TYPE_TRUESEEING:
                return EffectTrueSeeing();

        case EFFECT_TYPE_TURN_RESISTANCE_DECREASE:
                return EffectTurnResistanceDecrease(nParam1);

        case EFFECT_TYPE_TURN_RESISTANCE_INCREASE:
                return EffectTurnResistanceIncrease(nParam1);

        case EFFECT_TYPE_TURNED:
                return EffectTurned();

        case EFFECT_TYPE_ULTRAVISION:
                return EffectUltravision();

        case EFFECT_TYPE_VISUALEFFECT:
                // Check for optional parameters.
                if ( nParam2 == PARAMETER_INVALID )
                    return EffectVisualEffect(nParam1);
                else
                    return EffectVisualEffect(nParam1, nParam2);
    }

    // Unrecognized type of effect. Return an invalid one.
    return EffectTemporaryHitpoints(-1);
}


///////////////////////////////////////////////////////////////////////////////
// GetSkin()
//
// Returns oPC's hide. If none exists, one is created.
//
// This function might clear oPC's action queue.
//
object GetSkin(object oPC) {
    return SkinGetSkin(oPC, TRUE);
}


///////////////////////////////////////////////////////////////////////////////
// IntToFLString()
//
// Converts an integer to a Fixed-Length string.
//
// The length of the string returned is 10 characters, making this function
// roughly equivalent to IntToHexString, but the strings from this function
// can be converted back to integers by StringToInt().
//
string IntToFLString(int nInteger) {
    string sInteger = "          ";     // 10 spaces for padding.
    sInteger += IntToString(nInteger);  // Convert to an over-long string.
    return GetStringRight(sInteger, 10);// Trim to 10 characters.
}


///////////////////////////////////////////////////////////////////////////////
// ShiftAlignment()
//
// Moves oSubject's alignment by nAmount, towards nLawChaos along the law/chaos
// axis, and towards nGoodEvil along the good/evil axis.
//
// Shifts towards neutrality ony affect oSubject if oSubject is not already
// neutral on that axis or if both shifts are towards neutrality.
//
// nLawChaos and nGoodEvil should be appropriate ALIGNMENT_* constants.
//
void ShiftAlignment(object oSubject, int nLawChaos, int nGoodEvil, int nAmount)
{
    // Check for neutral shifts. They need special handling.
    if ( nLawChaos == ALIGNMENT_NEUTRAL )
    {
        // Check for a full neutral shift. This doesn't need special handling.
        if ( nGoodEvil == ALIGNMENT_NEUTRAL )
        {
            // Do a full neutral shift and return.
            AdjustAlignment(oSubject, ALIGNMENT_NEUTRAL, nAmount);
            return;
        }

        // Instead of shifting to neutral on law/chaos, shift away from
        // oSubject's current alignment.
        // If oSubject is already neutral, do nothing.
        switch ( GetAlignmentLawChaos(oSubject) )
        {
            case ALIGNMENT_LAWFUL:  nLawChaos = ALIGNMENT_CHAOTIC; break;
            case ALIGNMENT_CHAOTIC: nLawChaos = ALIGNMENT_LAWFUL;  break;
        }
    }
    else if ( nGoodEvil == ALIGNMENT_NEUTRAL )
        // Instead of shifting to neutral on good/evil, shift away from
        // oSubject's current alignment.
        // If oSubject is already neutral, do nothing.
        switch ( GetAlignmentGoodEvil(oSubject) )
        {
            case ALIGNMENT_GOOD: nGoodEvil = ALIGNMENT_EVIL; break;
            case ALIGNMENT_EVIL: nGoodEvil = ALIGNMENT_GOOD; break;
        }

    // Call the standard library function for each axis, unless the shift is
    // still towards neutrality.
    if ( nLawChaos != ALIGNMENT_NEUTRAL )
        AdjustAlignment(oSubject, nLawChaos, nAmount);
    if ( nGoodEvil != ALIGNMENT_NEUTRAL )
        AdjustAlignment(oSubject, nGoodEvil, nAmount);
}


///////////////////////////////////////////////////////////////////////////////
// SetLocalEffect()
//
// Stores the parameters for an effect in local variables.
//
//
// nEffectType must be an EFFECT_TYPE_* constant.
//
// Unsupported constants:
//
//  * EFFECT_TYPE_ARCANE_SPELL_FAILURE
//  * EFFECT_TYPE_AREA_OF_EFFECT
//  * EFFECT_TYPE_BEAM
//  * EFFECT_TYPE_DISAPPEARAPPEAR
//  * EFFECT_TYPE_ENEMY_ATTACK_BONUS
//  * EFFECT_TYPE_INVULNERABLE
//  * EFFECT_TYPE_SWARM
//
// Custom allowed constants:
//
//  * EFFECT_TYPE_CUTSCENEDOMINATED
//  * EFFECT_TYPE_DAMAGE
//  * EFFECT_TYPE_DEATH
//  * EFFECT_TYPE_HEAL
//  * EFFECT_TYPE_KNOCKDOWN
//  * EFFECT_TYPE_MODIFYATTACKS
//
// Unsupported constructors:
//  * EffectAppear()
//  * EffectAreaOfEffect()
//  * EffectBeam()
//  * EffectDisappear()
//  * EffectDisappearAppear()
//  * EffectHitPointChangeWhenDying()
//  * EffectLinkEffects()
//  * EffectSummonCreature()
//  * EffectSwarm()
//
// NOTE: The constant for EffectDamageShield() is EFFECT_TYPE_ELEMENTALSHIELD.
//
//
// nParam? are the parameters passed to the corresponding effect constructor
// (the Effect*() functions), in the order the constructor takes them.
//
// Be sure to use the correct number of parameters, as there is no error checking
// on that. If the effect constructor needs less than six parameters, leave the
// excess at their default values. You do not have to supply parameters that are
// optional to the constructor.
//
// NOTE: EffectRegenerate() takes a floating point parameter, but it must be
// passed to this function as an integer.
//
void SetLocalEffect(object oObject, string sVarName, int nEffectType,
        int nParam1 = PARAMETER_INVALID, int nParam2 = PARAMETER_INVALID,
        int nParam3 = PARAMETER_INVALID, int nParam4 = PARAMETER_INVALID,
        int nParam5 = PARAMETER_INVALID, int nParam6 = PARAMETER_INVALID)
{
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_TYPE", nEffectType);
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_1", nParam1);
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_2", nParam2);
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_3", nParam3);
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_4", nParam4);
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_5", nParam5);
    SetLocalInt(oObject, sVarName + "_TK__EFFECT_PARAM_6", nParam6);
}

