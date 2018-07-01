///////////////////////////////////////////////////////////////////////////////
// deity_onlevel.nss
//
// Created by: The Krit
// Date: 11/06/06
///////////////////////////////////////////////////////////////////////////////
//
// This file is probably not something you want to change. It implements the
// checks that a PC has not violated pantheon rules when leveling.
//
///////////////////////////////////////////////////////////////////////////////
//
// To use, call CheckDeityRestrictions() in your module's OnLevelUp event.
// (The parameter should be the object leveling up, either GetPCLevellingUp()
// or a variable that has been assigned that value.)
//
// A TRUE return value indicates that the PC leveled ok.
//
// A FALSE return value indicates that the PC violated a rule and should be
// dealt with. (A message will have been sent to the PC explaining why the
// levelup was bad, but no actual de-leveling takes place in this file.)
//
// If all levelup checks are passed, call DeityRestrictionsPostLevel() to
// prepare for the next levelup. If you want to use the deity favored weapons,
// also call DeityWeaponsPostLevel().


#include "deity_include" 


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Returns FALSE if oPC just gained a cleric level, but does not meet the
// deity's requirements.
// Returns TRUE otherwise.
// "Just gained" means since character creation, since the last call to
// DeityRestrictionsPostLevel(), or since the last server reset, whichever
// was most recent.
int CheckDeityRestrictions(object oPC);

// Call after CheckDeityRestrictions() to record the current level as accepted.
void DeityRestrictionsPostLevel(object oPC);

// Call after a level-up is accepted to initiate the favored weapon portion
// of this package.
void DeityWeaponsPostLevel(object oPC);



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// CheckDeityRestrictions()
//
// Returns FALSE if oPC just gained a cleric level, but does not meet the
// deity's requirements.
//
// Returns TRUE otherwise.
//
// "Just gained" means since character creation, since the last call to
// DeityRestrictionsPostLevel(), or since the last server reset, whichever
// was most recent.
// TODO - this is currently only clerics.  There is no code yet to check other divine casters
// 
int CheckDeityRestrictions(object oPC) {
        int bOK = FALSE;    // Flag indicating if the most recent level is accepted.
        int nOldClericLevel = GetLocalInt(oPC, "ClericLevel");          // Old cleric level.
        int nNewClericLevel = GetLevelByClass(CLASS_TYPE_CLERIC, oPC);  // New cleric level.

    // Check if a cleric level was added.
        if ( nNewClericLevel == nOldClericLevel ) {
        // No cleric levels added, so all is ok by this function.
                return TRUE;
        } else {
                int nDeity = GetDeityIndex(oPC);    // Current deity.

                //SendMessageToPC(oPC, "OnLevel - got index " + IntToString(nDeity) + " For pc deity = " + GetDeity(oPC));
                // Check for an invalid deity.
                if ( nDeity < 0 ) {
                        // Tell the player why this is rejected.
                        SendMessageToPC(oPC, "The gods of " + WORLDNAME + " will not allow a cleric of a god from another realm!");
                }
        // Check for an invalid alignment.
                else if ( !CheckClericAlignment(oPC, nDeity) ) {
            // Tell the player why this is rejected.
                        if ( nOldClericLevel == 0 ) {
                                SendMessageToPC(oPC, GetDeity(oPC) + " does not accept those of your moral caliber!");
                                SendMessageToPC(oPC, "You may need to find a temple or altar of the deity you wish to serve to become a cleric.");
                        } else {
                                SendMessageToPC(oPC, "You have fallen from the grace of " + GetDeity(oPC) + "!");
                                SendMessageToPC(oPC, "You will need to return to favor to advance as a cleric.");
                        }
                }

        // Check for an invalid race.
                else if ( !CheckClericRace(oPC, nDeity) ) {
                        // Tell the player why this is rejected.
                        SendMessageToPC(oPC, GetDeity(oPC) + " does not accept servants of your race!");
                }
        // Check for an invalid domain.
                else if ( !CheckClericDomains(oPC, nDeity) ) {
                        // Tell the player why this is rejected.
                        SendMessageToPC(oPC, "You have not chosen domains pleasing to " + GetDeity(oPC) + "!");
                }

        // Check for a domain/alignment conflict, chaos.
                else if ( bForceAlignmentDomainMatch  &&  GetHasFeat(FEAT_CHAOS_DOMAIN_POWER, oPC)  
                        && GetAlignmentLawChaos(oPC) != ALIGNMENT_CHAOTIC ) {
                        SendMessageToPC(oPC, "A cleric of chaos must be chaotic.");
                }
        // Check for a domain/alignment conflict, evil.
                else if ( bForceAlignmentDomainMatch  &&  GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oPC)  
                        && GetAlignmentGoodEvil(oPC) != ALIGNMENT_EVIL ) {
                        SendMessageToPC(oPC, "A cleric of evil must be evil.");
                }
        // Check for a domain/alignment conflict, good.
                else if ( bForceAlignmentDomainMatch  &&  GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oPC)  
                        && GetAlignmentGoodEvil(oPC) != ALIGNMENT_GOOD ) {
                        SendMessageToPC(oPC, "A cleric of good must be good.");
                }

        // Check for a domain/alignment conflict, law.
                else if ( bForceAlignmentDomainMatch  &&  GetHasFeat(FEAT_LAW_DOMAIN_POWER, oPC)  
                        && GetAlignmentLawChaos(oPC) != ALIGNMENT_LAWFUL ) {
                        SendMessageToPC(oPC, "A cleric of law must be lawful.");
                }
                else if ( !CheckClericGender(oPC, nDeity)) {
                       // Tell the player why this is rejected.
                       SendMessageToPC(oPC, GetDeity(oPC) + " does not allow clerics of your gender.");

                } else {
                        // Passed all checks!
                        bOK = TRUE;
                }
        }//else (cleric level added)

        return bOK;
}


///////////////////////////////////////////////////////////////////////////////
// DeityRestrictionsPostLevel()
//
// Call after CheckDeityRestrictions() to record the current level as accepted.
//
void DeityRestrictionsPostLevel(object oPC) {
    SetLocalInt(oPC, "ClericLevel", GetLevelByClass(CLASS_TYPE_CLERIC, oPC));
}


///////////////////////////////////////////////////////////////////////////////
// DeityWeaponsPostLevel()
//
// Call after a level-up is accepted to initiate the favored weapon portion
// of this package.
//
void DeityWeaponsPostLevel(object oPC) {
    // Nothing needs to be done if oPC is not a cleric.
    if ( GetLevelByClass(CLASS_TYPE_CLERIC, oPC) != 0 ) {
        // Make sure the system is initialized.
        DeityWeaponsInit(oPC, GetDeityIndex(oPC));
        // Update the consequences.
        //UpdateDeityWeapons(oPC);
	ExecuteScript("deity_onequip", oPC);
    }
}

