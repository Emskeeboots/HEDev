//::////////////////////////////////////////////////////////////////////////////
//:: Name: Sir Elric's Player Validity Checker for non ELC servers(v1.4)
//:: FileName:  se_inc_pc_check
//:: File Type: include
//::////////////////////////////////////////////////////////////////////////////
/*
    For use on non ELC servers to catch and boot player hackers.

    - Checks newly created characters ability points, skills, hitpoints and
      feats for any abnormalities. If any are found the player is booted,
      their cdkey is recorded to the database and DM's alerted.

      If the PC check is clean the PC is set to valid and saved to the database

    - While not an exact check it will severely limit PC hackers ability to add
      extra feats, hitpoints, ability or skill points on non ELC servers.

    - You MUST compile the OnClientEnter script if any settings are changed in
      this include for them to take effect.

    - To INSTALL import the erf use the example On_Client_Enter script for the
      modules OnClientEnter event or merge with your current script.
      Compile all scripts!

    - * Note DEBUG_MODE is set to DM only & BOOT_PLAYER is on by default
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 22nd November, 2006
//:: Updated On: 25th April, 2007
//::////////////////////////////////////////////////////////////////////////////

// Modified by Meaglyn to use differnet persistence and run standalone.
#include "_inc_pw"

// -----------------------------------------------------------------------------
//  CONSTANTS
//
//  Main Settings - Please note the numbers below are just my estimates
//
//  In my testing these settings allowed all valid characters I tested to login
//  within the confines of the checks.
//  I'm no guru on what points/feats players normally get at creation so fine
//  tune these settings if you know better.
//
//  (You MUST compile the OnClientEnter script if any settings are changed in
//  this include for them to take effect)
// -----------------------------------------------------------------------------

const int BOOT_PLAYER = TRUE;              // Set to FALSE for testing only!
const int COMBINED_ABILITY_POINTS_MAX = 90;// Total ability points allowed
const int ABILITY_POINTS_MAX_SINGLE = 20;  // Max points in any one ability
const int MAX_SKILL_POINTS_TOTAL = 80;     // Max skill points in total
const int MAX_SKILL_POINTS_SINGLE = 10;    // Max skill points in any one skill
const int MAX_HITPOINTS = 18;              // Max hit points allowed
const int DEBUG_MODE = 0;                  // 0 = Off, 1 = PC & DM, 2 = DM Only


// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Created for non ELC servers
// Checks newly created chars ability points, hitpoints, skills, feats for any
// abnormalities if any are found the player is booted set as such to the
// Bioware DB & DM's alerted
// If the char is valid they are set as such to the Bioware DB
void SE_PlayerValidityCheck(object oPC);

int SE_DoPlayerValidityCheck(object oPC);

// Feats not available to a newly created character
// (Note that this function is far from complete & only covers mainly epic feats,
// it may or may not be updated)
int SE_CheckForInvalidFeats(object oPC);

int SE_TotalFeatsByRaceClass(object oPC);

int SE_CheckFeatTotal(object oPC);

int SE_CheckSkillPointsTotal(object oPC);

int SE_CheckSkillPointsSingle(object oPC);

int SE_CheckAllAbiltyScores(object oPC);

int SE_CombinedAbilityPoints(object oPC);

// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------
void SE_doBoot(object oPC) {
        if(BOOT_PLAYER) {
                NWNX_BanPlayer(oPC, "Failed ELC Check. Hacked character detected.");
                SetLocalInt(oPC, "BOOTED", 1);
        } 
}


void SE_PlayerValidityCheck(object oPC) {
        object oMod = GetModule();
        // Nothing to do here if not MP
        if (!MODULE_NWNX_MODE) 
                return;
        

	if (NWNX_GetPCInitialized(oPC)) {
		pwDebugMessage("Same valid character login detected!", oPC);
                return;
        }
	
        if (GetIsDM(oPC))
                return;

        // There's a window where a crash will leave initialized unset but the 1 XP will be given - Next login 
        // PC gets the hacked old character message and get's banned.
        // It appears missing haks can cause a client crash during this window so we rely on the initialized bit only
        //if(GetLocalInt(oPC, "NEW_PC_FLAG") || DEBUG_MODE) {
                if(SE_DoPlayerValidityCheck(oPC)) {
                        if(!DEBUG_MODE)
                                pwErrorMessage("Hacked character login detected!", oPC);
                        else 
                                pwDebugMessage("Hacked character login detected!", oPC);
                        SE_doBoot(oPC);
                } else if(GetIsPC(oPC)) {
                        pwDebugMessage("This character has passed the validity check.", oPC);
                }
        //} else {
                // old PC has not been validated...
                // Ban key and log message.
        //        pwErrorMessage("Hacked old character login detected - should not happen!", oPC);  
        //        SE_doBoot(oPC);
        //}
}

int SE_DoPlayerValidityCheck(object oPC) {
        if(SE_CombinedAbilityPoints(oPC) > COMBINED_ABILITY_POINTS_MAX) {
                pwErrorMessage("Character failed combined ability points check.");
                return TRUE;
        }

        if (SE_CheckSkillPointsTotal(oPC) > MAX_SKILL_POINTS_TOTAL) {
                pwErrorMessage("Character failed skill points check.");
                return TRUE;
        } 

        if (SE_CheckFeatTotal(oPC) > SE_TotalFeatsByRaceClass(oPC)) {
                pwErrorMessage("Character failed total feats check.");
                return TRUE;
        }
        if (SE_CheckAllAbiltyScores(oPC)) {
                pwErrorMessage("Character failed individual ability score check.");
                return TRUE;
        }
        
        if (SE_CheckSkillPointsSingle(oPC)){
                pwErrorMessage("Character failed individual skill points check.");
                return TRUE;       
        }

        if(SE_CheckForInvalidFeats(oPC)){
                pwErrorMessage("Character failed specific feats check.");
                return TRUE;       
        }
        if (GetCurrentHitPoints(oPC) > MAX_HITPOINTS) {
                pwErrorMessage("Character failed max HP check.");
                return TRUE;
        }
        return FALSE;
}

int SE_CheckForInvalidFeats(object oPC) {
        int nFeat = 490;// start from FEAT_EPIC_ARMOR_SKIN
        while (nFeat < 870) // stop at FEAT_EPIC_LASTING_INSPIRATION 
        {
                if(GetHasFeat(nFeat, oPC))
                        return TRUE;
                else
                        nFeat++;
        }

        nFeat = 872;// start from FEAT_EPIC_WILD_SHAPE_UNDEAD
        while (nFeat < 910) // stop at FEAT_EXTRA_SMITING
        {
                if(GetHasFeat(nFeat, oPC))
                        return TRUE;
                else
                        nFeat++;
        }

        nFeat = 917;// start from FEAT_EPIC_SKILL_FOCUS_BLUFF
        while (nFeat < 943) // stop at FEAT_WEAPON_OF_CHOICE_TWOBLADEDSWORD
        {
                if(GetHasFeat(nFeat, oPC))
                        return TRUE;
                else
                        nFeat++;
        }

        nFeat = 955;// start from FEAT_EPIC_DEVASTATING_CRITICAL_DWAXE
        while (nFeat < 1071) // stop at FEAT_EPIC_SUPERIOR_WEAPON_FOCUS
        {
                if(GetHasFeat(nFeat, oPC))
                        return TRUE;
                else
                        nFeat++;
        }

        return FALSE;
}

int SE_TotalFeatsByRaceClass(object oPC) {
        int nFeats = 1;
    //racial feat count
        switch(GetRacialType(oPC)) {
                case RACIAL_TYPE_DWARF:    nFeats += 8; break;
                case RACIAL_TYPE_ELF:      nFeats += 8; break;
                case RACIAL_TYPE_GNOME:    nFeats += 9; break;
                case RACIAL_TYPE_HALFELF:  nFeats += 6; break;
                case RACIAL_TYPE_HALFLING: nFeats += 6; break;
                case RACIAL_TYPE_HALFORC:  nFeats += 1; break;
                case RACIAL_TYPE_HUMAN:    nFeats += 2; break;// +1(extra feat for humans)
        }
    
    //class feat count
        switch(GetClassByPosition(1, oPC)) {
                case CLASS_TYPE_BARBARIAN:nFeats += 7; break;
                case CLASS_TYPE_BARD:     nFeats += 6; break;// -1 for Scribe Scroll
                case CLASS_TYPE_CLERIC:   nFeats += 8; break;// +2 for Domain Powers
                                                     // -1 for Scribe Scroll
                case CLASS_TYPE_DRUID:    nFeats += 6; break;// -1 for Scribe Scroll
                case CLASS_TYPE_FIGHTER:  nFeats += 7; break;
                case CLASS_TYPE_MONK:     nFeats += 7; break;
                case CLASS_TYPE_PALADIN:  nFeats += 9; break;// -1 for Scribe Scroll
                case CLASS_TYPE_RANGER:   nFeats += 10; break;// +2 for Ambidexterity & Two Weapon Fighting
                                                      // -1 for Scribe Scroll
                case CLASS_TYPE_ROGUE:    nFeats += 3; break;
                case CLASS_TYPE_SORCERER: nFeats += 2; break;// -1 for Scribe Scroll
                case CLASS_TYPE_WIZARD:   nFeats += 3; break;
        }
        pwDebugMessage("Race + Class feats should total [" + IntToString(nFeats) + "]");
        return nFeats;
}

int SE_CheckFeatTotal(object oPC) {
        int nFeat, i;
        for (i = 0; i < 1071; i++) {
                if(GetHasFeat(i, oPC)) {
                        pwDebugMessage("You have feat [" + IntToString(i) + "]");
                        nFeat++;
                }
        }

        pwDebugMessage("You have a total of [" + IntToString(nFeat) + "] feats");
        return nFeat;
}

int SE_CheckSkillPointsTotal(object oPC) {
        int nSkill, i;
        for (i = 0; i < 27; i++) {
                if(GetSkillRank(i, oPC) > -1)
                       nSkill += GetSkillRank(i, oPC);
        }

        pwDebugMessage("You have a total of [" + IntToString(nSkill) + "] skill points");
        return nSkill;
}

int SE_CheckSkillPointsSingle(object oPC) {
        int i;
        for (i = 0; i < 27; i++) {
                if(GetSkillRank(i, oPC) > MAX_SKILL_POINTS_SINGLE)
                        return TRUE;
        }

        return FALSE;
}

int SE_CheckAllAbiltyScores(object oPC) {
        if(GetAbilityScore(oPC, ABILITY_CHARISMA) > ABILITY_POINTS_MAX_SINGLE
                || GetAbilityScore(oPC, ABILITY_CONSTITUTION) > ABILITY_POINTS_MAX_SINGLE
                || GetAbilityScore(oPC, ABILITY_DEXTERITY) > ABILITY_POINTS_MAX_SINGLE
                || GetAbilityScore(oPC, ABILITY_INTELLIGENCE) > ABILITY_POINTS_MAX_SINGLE
                || GetAbilityScore(oPC, ABILITY_STRENGTH) > ABILITY_POINTS_MAX_SINGLE
                || GetAbilityScore(oPC, ABILITY_WISDOM) > ABILITY_POINTS_MAX_SINGLE)
                return TRUE;
        else
                return FALSE;
}

int SE_CombinedAbilityPoints(object oPC) {
        int n = GetAbilityScore(oPC, ABILITY_CHARISMA);
        n += GetAbilityScore(oPC, ABILITY_CONSTITUTION);
        n += GetAbilityScore(oPC, ABILITY_DEXTERITY);
        n += GetAbilityScore(oPC, ABILITY_INTELLIGENCE);
        n += GetAbilityScore(oPC, ABILITY_STRENGTH);
        n += GetAbilityScore(oPC, ABILITY_WISDOM);
        pwDebugMessage("You have a total of [" + IntToString(n) + "] ability points");
        return n;
}

void main(){
        object oPC = OBJECT_SELF;

        SE_PlayerValidityCheck(oPC);
}
