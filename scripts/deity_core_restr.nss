///////////////////////////////////////////////////////////////////////////////
// deity_core_restr.nss
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
// To use: (even though probably not used outside this package)
//
// Call CheckClericAlignment() to see if a cleric meets the deity's alignment
// requirement.
//
// Call CheckClericDomains() to see if a cleric meets the deity's domain
// requirement.
//
// Call CheckClericRace() to see if a cleric meets the deity's race and
// subrace requirements.
//
///////////////////////////////////////////////////////////////////////////////
// NOTES:
//
// There is special handling for Lolth (in other files) that requires her
// clerics to be female. This requirement could be added in a generic fashion
// like the other cleric checks, but as long as there is but one special case,
// there is insufficient need to justify writing generic code.
///////////////////////////////////////////////////////////////////////////////


// Configuration settings and core defs should be included before this file.
#include "deity_configure"
#include "deity_core_defs"

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Returns TRUE iff deity nDeity accepts clerics of oPC's alignment.
int CheckClericAlignment(object oPC, int nDeity);

// Returns TRUE iff deity nDeity accepts clerics with oPC's domains.
// More precisely, returns TRUE iff the deity has no domain requirement or
// oPC possesses two domains from the deity's list. (If the list contains a
// duplicate, having that one duplicated domain will count as possessing two.)
int CheckClericDomains(object oPC, int nDeity);

// Returns TRUE iff deity nDeity accepts clerics of oPC's race.
// If the deity has a subrace specified, returns true if nDeity accepts oPC's
// race AND subrace. The subrace comparison is case-insensitive.
int CheckClericRace(object oPC, int nDeity);

// Returns TRUE iff deity nDeity accepts clerics of oPC's gender.
int CheckClericGender(object oPC, int nDeity);

// Returns TRUE if the given PC could be a worshipper or follower of
// the given deity.
int DeityCheckCanFollow(object oPC, int nDeity);

// Returns TRUE if the given PC could serve as a cleric of the given deity.
int DeityCheckCanServe(object oPC, int nDeity);


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// CheckClericAlignment()
//
// Returns TRUE iff deity nDeity accepts clerics of oPC's alignment.
int CheckClericAlignment(object oPC, int nDeity) {
    // Get the list of accepted alignments.
    string sAlignments = GetLocalString(GetModule(), CLERIC_ALIGNMENT + IntToHexString(nDeity));

    // Check for universal acceptance.
    if ( sAlignments == "" )
        return TRUE;

    // Get the cleric's alignment.
    int nLawChaos = GetAlignmentLawChaos(oPC);
    int nGoodEvil = GetAlignmentGoodEvil(oPC);

    // Loop through the list of alignments.
    while ( sAlignments != "" )
    {
        // Check for a match.
        if ( nLawChaos == StringToInt(GetStringLeft(sAlignments, 10)) &&
             nGoodEvil == StringToInt(GetSubString(sAlignments, 10, 10)) )
            // This deity accepts this alignment.
            return TRUE;
        // Proceed to the next alignment. (Remove the leftmost 20 characters.)
        sAlignments = GetStringRight(sAlignments, GetStringLength(sAlignments)-20);
    }

    // If we get to this point, this alignment is not accepted by nDeity.
    return FALSE;
}


///////////////////////////////////////////////////////////////////////////////
// CheckClericDomains()
//
// Returns TRUE iff deity nDeity accepts clerics with oPC's domains.
//
// More precisely, returns TRUE iff the deity has no domain requirement or
// oPC possesses two domains from the deity's list. (If the list contains a
// duplicate, having that one duplicated domain will count as possessing two.)
int CheckClericDomains(object oPC, int nDeity) {
    // Get the list of accepted domains.
    string sDomains = GetLocalString(GetModule(), CLERIC_DOMAIN + IntToHexString(nDeity));

    // Check for universal acceptance.
    if ( sDomains == "" )
        return TRUE;

    // PC can be grandfathered to skip the domain check
    if (GetLocalInt(oPC, "deity_no_domaincheck"))  {
        SendMessageToPC(oPC, "No Domain check is set...");
        return TRUE;
    }

    // Count of the number of listed domains possessed.
    int nCount = 0;

    // Loop through the list of domains.
    while ( sDomains != "" ) {
        // Check for a match.
        if ( GetHasFeat(StringToInt(GetStringLeft(sDomains, 10)), oPC) )
            nCount++;

        // Proceed to the next domain. (Remove the leftmost 10 characters.)
        sDomains = GetStringRight(sDomains, GetStringLength(sDomains)-10);
    }

    // We need (at least) two domains from the list to be accepted.
    return nCount > 1;
}


///////////////////////////////////////////////////////////////////////////////
// CheckClericRace()
//
// Returns TRUE iff deity nDeity accepts clerics of oPC's race.
//
// If the deity has a subrace specified, returns true if nDeity accepts oPC's
// race AND subrace. The subrace comparison is case-insensitive.
int CheckClericRace(object oPC, int nDeity)
{
    // BEGIN SUBRACE CHECK.
    // Get the subrace requirement.
    string sSubrace = GetStringUpperCase(
                        GetLocalString(GetModule(),
                                       CLERIC_SUBRACE + IntToHexString(nDeity)) );
    // If a subrace is required.
    if ( sSubrace != "" )
        // If oPC's subrace does not match.
        if ( GetStringUpperCase(GetSubRace(oPC)) != sSubrace )
            // Wrong subrace; no need to check the race.
            return FALSE;
    // END SUBRACE CHECK.

    // Get the list of accepted races.
    string sRaces = GetLocalString(GetModule(), CLERIC_RACE + IntToHexString(nDeity));

    // Check for universal acceptance.
    if ( sRaces == "" )
        return TRUE;

    // Get the cleric's race.
    int nRace = GetRacialType(oPC);

    // Loop through the list of races.
    while ( sRaces != "" )
    {
        // Check for a match.
        if ( nRace == StringToInt(GetStringLeft(sRaces, 10)) )
            // This deity accepts this race.
            return TRUE;

        // Proceed to the next race. (Remove the leftmost 10 characters.)
        sRaces = GetStringRight(sRaces, GetStringLength(sRaces)-10);
    }

    // If we get to this point, this race is not accepted by nDeity.
    return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// CheckClericGender()
//
// Returns TRUE iff deity nDeity accepts clerics of oPC's gender
int CheckClericGender(object oPC, int nDeity) {

    int nReqGender = GetClericGender(nDeity);

    // no restriction
    if (nReqGender == GENDER_BOTH)
        return TRUE;

    // There is a restriction - check for match
    int nGender = GetGender(oPC);
    if (nReqGender == nGender)
        return TRUE;

    // If we get to this point, the PC's gender is not correct for the deity.
    return FALSE;
}

// Returns TRUE if the given PC could be a worshipper or follower of
// the given deity.
int DeityCheckCanFollow(object oPC, int nDeity) {
       return CheckClericAlignment(oPC, nDeity)  &&  CheckClericRace(oPC, nDeity);
}

// Returns TRUE if the given PC could serve as a cleric of the given deity.
// regardless of whether the PC is currently a cleric (of this or any other deity).
// For Clerics this checks alignment, race, gender and domains.
// for others this check alignment, race and gender.
int DeityCheckCanServe(object oPC, int nDeity) {

    // Check if could be a follower first
    if (DeityCheckCanFollow(oPC, nDeity)) {
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0) {
                return CheckClericDomains(oPC, nDeity)  &&  CheckClericGender(oPC, nDeity);
        } else {
                return CheckClericGender(oPC, nDeity);
        }
    }
    return FALSE;
}


// Get the PCs current favor points with her deity.
int DeityGetFavorPoints(object oPC) {
        int nRet  = GetLocalInt(oPC, "deity_favor_points");
        return nRet;
}

// set the PCs current favor points with her deity.
void DeitySetFavorPoints(object oPC, int nPoints) {
        SetLocalInt(oPC, "deity_favor_points", nPoints);
}




// Returns TRUE if the PC is currently out of favor with his/her deity.
// This is useful for restricting spell casting, having temples react differently etc
// This applies to followers and clerics.
int DeityOutOfFavor(object oPC) {
    int nDeity = GetDeityIndex(oPC);

    // This should not happen...
      if ( nDeity < 0 )
          return TRUE; // not a valid deity

      // the higher level checks
      // not checking domain since that should only change on level up.
      // not sure if race or gender will change that often, but just in case...
      if (!CheckClericAlignment(oPC, nDeity)
          ||  !CheckClericRace(oPC, nDeity)
          ||  !CheckClericGender(oPC, nDeity))
          return TRUE;

      // Here we can check a more dynamic local var on the PC
      int nFavor = DeityGetFavorPoints(oPC);

      // TODO clean this up - should apply to PALADIN (and DRUID?) as well.
      if (nFavor < 30 || (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) && nFavor < 50)) {
        return TRUE;
      }

      // everythings ok...
      return FALSE;
}
