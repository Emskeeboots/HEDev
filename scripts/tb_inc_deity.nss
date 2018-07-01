///////////////////////////////////////////////////////////////////////////////
// tb_inc_deity.nss
//
//
//////////////////////////////
// Started as deity_example
// Created by: The Krit
// Date: 11/06/06
///////////////////////////////////////////////////////////////////////////////
//
// This file includes many of the extensions of the Krit's pantheon system by
// meaglyn.
//
// Documentation for changes from krit's system.
//
// PC can be marked with "deity_no_domaincheck" set to true to grandfather
// domain selection since that can't be changed after creation(barring NWNX etc)/
// This would be useful for the deity chooser conversation for PCs starting as cleric.
// NOTE: this should be changed to a SkinInt or otherwise preserved in multiplayer.
//
//
///////////////////////////////////////////////////////////////////////////////

#include "_inc_data"
#include "deity_include"
#include "deity_onlevel"
#include "tb_inc_util"

const int DEITY_STANDING_OTHER         = 0;
const int DEITY_STANDING_CLERIC_OK     = 1;
const int DEITY_STANDING_FOLLOWER_OK   = 2;
const int DEITY_STANDING_CLERIC_HIGH   = 3;
const int DEITY_STANDING_FOLLOWER_HIGH = 4;
const int DEITY_STANDING_CLERIC_LAPSED = -1;
const int DEITY_STANDING_FOLLOWER_LAPSED = -2;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Gives new clerics their holy symbols.
// This assumes the tag of each holy symbol is "HolySymbol", which I am told
// is the same assumption HCR uses.
void GiveHolySymbol(object oPC);

// Gives oPC the effect of faithfully praying at the temple of nDeity.
void RewardFaithfulness(object oPC, int nDeity);

// Sets oPC's start location based upon oPC's deity.
// This assumes some other script uses the "SpawnLoc" local string to find the
// location.
void SetPlayerSpawnLoc(object oPC);

// Causes oPC's to say an epithet appropriate for the PC's deity.
void deityDoSwear(object oPC);

// Returns TRUE if the given PC has a holy symbol for his/her deity.
int HasHolySymbol(object oPC);

// Get the tag assigned for the holy symbol for the PC's deity.
// This returns "" if invalid.
string deityGetHolySymbolTag(object oPC);

// Return one of the DEITY_STANDING constants for how this PC is
// in respect to the given nDeity index.
int deityGetStanding(int nDeity, object oPC);

// get the amount the PC should pay for full healing.
// Based on the DEFAULT_HEAL_BASE_COST, the PCs standing and level and
// if made an offering (using bDidTithe) already.
int deityGetHealAmount(int nDeity, object oPC, int bDidTithe = FALSE);


// This routine does a full restoration (heal and effects) of the given
//target
void deityDoRestore(object oTarget);
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////


// Returns TRUE if the given PC has a holy symbol for his/her deity.
int HasHolySymbol(object oPC) {

    // Get oPC's deity's index.
    int nDeity = GetDeityIndex(oPC);

    string sTag = GetDeityHolySymbolTag(nDeity);
    if ( GetIsObjectValid(GetItemPossessedBy(oPC, sTag)) )
        return TRUE;

    return FALSE;
}

// Get the tag assigned for the holy symbol for the PC's deity.
// This returns "" if invalid.
string deityGetHolySymbolTag(object oPC) {

    // Get oPC's deity's index.
    int nDeity = GetDeityIndex(oPC);

    // Abort if the deity is unknown.
    if ( nDeity < 0 )
        return "";

    return GetDeityHolySymbolTag(nDeity);
}

///////////////////////////////////////////////////////////////////////////////
// GiveHolySymbol()
//
// Gives new clerics their holy symbols.
//
void GiveHolySymbol(object oPC) {
    // Check for an existing holy symbol.
    if (HasHolySymbol(oPC))
        return;

    // Get oPC's deity's index.
    int nDeity = GetDeityIndex(oPC);

    // Abort if the deity is unknown.
    if ( nDeity < 0 )
        return;

    // Give oPC the appropriate holy symbol.
    CreateItemOnObject(GetDeityHolySymbol(nDeity), oPC, 1, GetDeityHolySymbolTag(nDeity));
}

object  deityGetCorpseItem(object oPC) {
	object oItem = GetFirstItemInInventory(oPC);
	while (GetIsObjectValid(oItem)) {
		if (GetResRef(oItem) == "corpse_pc") return oItem;

		oItem = GetNextItemInInventory(oPC);
	}
	return OBJECT_INVALID;
}
///////////////////////////////////////////////////////////////////////////////
// RewardFaithfulness()
//
// Gives oPC the effect of faithfully praying at the temple of nDeity.
//
void RewardFaithfulness(object oPC, int nDeity) {
    // Benefits are only given to followers/servants.
    if ( GetDeityIndex(oPC) == nDeity ) {

        // First check if the PC is in need and if we do anything about that -
        // this could be things like fixing hunger or thirst. Fixing cold/hot non-lethal damage etc.


        // check for a specific effect
        effect e = GetDeityTempleEffect(nDeity);
        if (GetEffectType(e) != EFFECT_TYPE_INVALIDEFFECT) {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e, oPC, HoursToSeconds(DEFAULT_PRAYER_EFFECT_HOURS));
        } else {
            // the default effect is an increase in primary ability
            int nClass = GetClassByPosition(1, oPC);

            string sAbil = Get2DAString("classes", "PrimaryAbil", nClass);

            SendMessageToPC(oPC, "Got class " + IntToString(nClass) + " primary " + sAbil);

            int nAbil;
            if (sAbil == "STR") {
                nAbil = ABILITY_STRENGTH;
            } else if (sAbil == "CON") {
                nAbil = ABILITY_CONSTITUTION;
            } else if (sAbil == "DEX") {
                nAbil = ABILITY_DEXTERITY;
            } else if (sAbil == "INT") {
                nAbil = ABILITY_INTELLIGENCE;
            } else if (sAbil == "WIS") {
                nAbil = ABILITY_WISDOM;
            } else if (sAbil == "CHA") {
                nAbil = ABILITY_CHARISMA;
            }

            e = EffectAbilityIncrease(nAbil, 1);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e, oPC, HoursToSeconds(DEFAULT_PRAYER_EFFECT_HOURS));

        }
    }
}


///////////////////////////////////////////////////////////////////////////////
// SetPlayerSpawnLoc()
//
// Sets oPC's start location based upon oPC's deity.
//
// This assumes some other script uses the "SpwanLoc" local string to find the
// location.
void SetPlayerSpawnLoc(object oPC) {
    // Get oPC's deity's index.
    int nDeity = GetDeityIndex(oPC);

    // Set the local string containing the start location.
    // Note that this does not work if oPC's deity is known, but that deity's
    // spawn location has not been set.
    // See deity_onload for why this works if oPC's deity is unknown.
    SetLocalString(oPC, "SpawnLoc", GetDeitySpawnLoc(nDeity));
}


///////////////////////////////////////////////////////////////////////////////
// deityDoSwear()
//
// Causes oPC to say an epithet appropriate for the PC's deity.
void deityDoSwear(object oPC) {
    // Get oPC's deity's index.
    int nDeity = GetDeityIndex(oPC);

    // Get the deity's epithet.
    string sSwear = GetDeitySwear(nDeity);

    // Check for a null entry.
    if ( sSwear == "" )
        // Fill in the generic entry. Assumes SetDeitySwear(-1, "something")
        // was called. (See deity_onload.)
        sSwear = GetDeitySwear(-1);

    // Yell it out (figuratively speaking, not the actual SHOUT channel).
    AssignCommand(oPC, SpeakString(sSwear));
}

///////////////////////////////////////////////////////////////////////////////
// deityGetBlessingStr()
//
// returns a blessing appropriate for the given deity by index
string  deityGetBlessingStr(int nDeity) {
    string sBless = GetDeityBlessing(nDeity);

    // Check for a null entry.
    if ( sBless == "" ) {
        //if (GetDeityGender(nDeity) ==
        // Fill in the generic entry. Assumes SetDeitySwear(-1, "something")
        // was called. (See deity_onload.)
        return "Blessings of " + GetDeityName(nDeity) + " upon you.";
    }
    return sBless;
}

///////////////////////////////////////////////////////////////////////////////
// deityGetBlessing()
//
// returns a blessing appropriate for the PC's deity.
string  deityGetBlessing(object oPC) {
    int nDeity = GetDeityIndex(oPC);
    return  deityGetBlessingStr(nDeity);
}

// This just uses the above to make the given object speak the string.
void deityDoBless(object oPC) {
    AssignCommand(oPC, SpeakString(deityGetBlessing(oPC)));
}

/////////////////////
//  Check for miraculous effect on PC in combat
//
void deityMiracleCheck(object oPC) {
        int nDeity = GetDeityIndex(oPC);
        int nStanding =  deityGetStanding(nDeity,oPC);

        // Lapsed or non-follower no chance.
        if (nStanding <= 0)
                return;

        int nFavor =  DeityGetFavorPoints(oPC);

        if (nFavor < 50)
                return;

        int nChance;
        int bHigh = FALSE;
        if (nFavor >= 90) {
                nChance = 4 + (nFavor - 90);
                bHigh = TRUE;
        } else {
                nChance = 2 + (nFavor - 50)/10;
                 // Cause non high favored to take possible attacks of opp for praying in combat.
                AssignCommand(oPC, ClearAllActions(TRUE));
        }

        // Nothing to do
        if (d100() > nChance)
                return;


        // figure out how badly the PC needs aid
        // and do something - heal, cure poison/disease, kill nearby creature etc.
        // For now just doing a restore
        if (GetCurrentHitPoints(oPC) > GetMaxHitPoints(oPC)/2) {
                DelayCommand(0.0, FloatingTextStringOnCreature("Your need is not great.", oPC));
                DeitySetFavorPoints(oPC, nFavor - 10);
        }


        DelayCommand(0.1, deityDoRestore(oPC));
        DelayCommand(0.0, FloatingTextStringOnCreature("Your prayers have been answered.", oPC));

        // charge PC some favor points. - more if not in desperate need.
        if (bHigh)
                DeitySetFavorPoints(oPC, nFavor - 3);
        else  {
                DeitySetFavorPoints(oPC, nFavor - 8);
        }
}

// Make a small (0) , medium (1)  or large (2) positive adjustment in PC towards (or away from) her deity's alignment and favor.
// nStanding should be pcs standing with deity before any changes have been made. Used to provide feedback
// when standing changes.
// bNegative means we are penalizing the PC with respect to her deity.
void deityAdjustFavor(object oPC, int nStanding, int nLevel = 0, int bNegative = FALSE) {


        // Alignment shifts only work to pull you closer to deity alignment
        if (!bNegative){


                int nAmount = 1;

                if (nLevel == 1)
                        nAmount = 2;

                if (nLevel == 2)
                        nAmount = 5;
                //Oldfog Commented this out 2018-06-24
                //ShiftAlignmentTowardsDeity(oPC, nAmount);

        }


    // adjust dynamic favor tracking
        int nCur =  DeityGetFavorPoints(oPC);
        if (bNegative) {
                nCur -= (nLevel + 1);
        } else {
                if (nCur >= 90)
                        nCur += 1;
                else if (nCur < 25)
                        nCur += 3;
                else
                        nCur += (nLevel + 1);
        }

        // Adjust new favor
        if (nCur > 100) nCur = 100;
        if (nCur < 1) nCur = 1;

        // Set limits based on current standing
        // can't become favored if lapsed due to alignment ...
        if (nStanding <= 0 && nCur > 89)
                nCur = 89;

        DeitySetFavorPoints(oPC, nCur);

        // now get standing again and see if it changed
        int nNewStand = deityGetStanding(GetDeityIndex(oPC),oPC);
        if (nNewStand != nStanding) {
                string sMsg = "";
                if (nNewStand == DEITY_STANDING_CLERIC_LAPSED || nNewStand == DEITY_STANDING_FOLLOWER_LAPSED) {
                        sMsg = "You feel a sense of spiritual unease.";
                } else if (nNewStand == DEITY_STANDING_CLERIC_HIGH || nNewStand == DEITY_STANDING_FOLLOWER_HIGH) {
                        sMsg = "You feel a sense of complete spiritual ease.";
                } else if (nNewStand == DEITY_STANDING_CLERIC_OK || nNewStand == DEITY_STANDING_FOLLOWER_OK) {
                        sMsg = "you feel a sense of spiritual ease.";
                }
                if (sMsg != "")
                        DelayCommand(5.0, FloatingTextStringOnCreature(sMsg, oPC));
        }
        //deityUpdateStanding(oPC, nStanding, nCur);
}


// Gets an amount for a tithe based on the PCs standing with the given deity.
// If PCs deity is different this is the base amount. Otherwise it will be larger
// depending on the PCs status with his/her deity.
int deityGetTitheAmount(int nDeity, object oPC) {
    int nAmount = DEFAULT_TITHE_BASE_COST;
    int nStand =  deityGetStanding(nDeity, oPC);

    if (nStand == DEITY_STANDING_FOLLOWER_OK || nStand == DEITY_STANDING_FOLLOWER_HIGH || nStand == DEITY_STANDING_FOLLOWER_LAPSED) {
        nAmount = nAmount * GetHitDice(oPC);
    } else if (nStand == DEITY_STANDING_CLERIC_OK || nStand == DEITY_STANDING_CLERIC_HIGH || nStand == DEITY_STANDING_CLERIC_LAPSED) {
        nAmount = nAmount * 2 * GetLevelByClass(CLASS_TYPE_CLERIC, oPC);
    }

    return nAmount;
}

// get the amount the PC should pay for full healing.
// Based on the DEFAULT_HEAL_BASE_COST, the PCs standing and level and
// if made an offering (using bDidTithe) already.
int deityGetHealAmount(int nDeity, object oPC, int bDidTithe = FALSE) {
    int nAmount = DEFAULT_HEAL_BASE_COST;
    int nStand =  deityGetStanding(nDeity, oPC);

    // 20% discount if PC made an offering or tithed.
    if (bDidTithe)
        nAmount = (nAmount * 8) / 10;


    switch (nStand) {

    case DEITY_STANDING_OTHER:
        nAmount = (nAmount * 3) * GetHitDice(oPC);
        break;

    case DEITY_STANDING_FOLLOWER_LAPSED:
        nAmount = (nAmount * 2) * GetHitDice(oPC);
        break;

    case DEITY_STANDING_FOLLOWER_OK:
    case DEITY_STANDING_FOLLOWER_HIGH:
        nAmount = nAmount * GetHitDice(oPC);
        break;

    case DEITY_STANDING_CLERIC_LAPSED:
        if (bDidTithe)
            nAmount = (nAmount * 6)/10;
        nAmount = nAmount * GetLevelByClass(CLASS_TYPE_CLERIC, oPC);
        break;
    case DEITY_STANDING_CLERIC_OK:
    case DEITY_STANDING_CLERIC_HIGH:
        nAmount = 0;
        break;
        // Cleric in good standing - free healing...
    }

    return nAmount;
}

void deityAnimatePrayer(int nDeity, object oPC) {
     string sDeity = GetDeityName(nDeity);

    AssignCommand(oPC,ActionSpeakString("Oh " + sDeity + " bless your humble servant " +GetName(oPC) + "!" ));
    AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE,1.0f,10.0f));

    string sBless = deityGetBlessingStr(nDeity);
    AssignCommand(oPC,ActionSpeakString(sBless));
}

// Return TRUE if the PC is one of the classes
// that is treated as a cleric for praying purposes
// CLERIC, PALADIN, DRUID
int deityIsCleric(object oPC) {
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC)
                || GetLevelByClass(CLASS_TYPE_DRUID, oPC)  //counting druids for this
                || GetLevelByClass(CLASS_TYPE_PALADIN, oPC))

                return TRUE;

        return FALSE;
}

// Have the PC pray to the given deity.
// Prayer can have an effect at most once per day.
// PC may pray to deities other than her official deity.
// Returns TRUE if an effect was granted.
int deityDoPrayer(int nDeity, object oPC, int bAltar = TRUE) {
        int nStanding =  deityGetStanding(nDeity, oPC);
        string sDeity = GetDeityName(nDeity);

        int nLast = GetLocalInt(oPC, "deity_last_pray_" + IntToString(nDeity));
        int nCur  = CurrentDay();
        int bCleric = deityIsCleric(oPC);
        int nCount = GetLocalInt(oPC, "deity_pray_count");
        int nMax = 1;
        if (bCleric)
                nMax ++;

    //SendMessageToPC(oPC, "DoPrayer. last " + IntToString(nLast) + " cur day = " + IntToString(nCur) + " max = " + IntToString(nMax));
    //SendMessageToPC(oPC, "DoPrayer. count = " + IntToString(nCount) + " standing = " + IntToString(nStanding));

    SetLocalInt(oPC, "deity_pray_count", nCount + 1);

        // We allow prayer of different deity once per day.
        // We track the count of times PC prays to her deity per day.
        if (nLast < nCur) {
        // Okay for all to pray - clear num_pray_times
                if (nStanding) {
                        //DeleteLocalInt(oPC, "deity_pray_count");
            SetLocalInt(oPC, "deity_pray_count", 1);
        }
        } else if (nStanding && nCount < nMax) {
                ;
        } else {
                //
        SendMessageToPC(oPC, "You are unsure if your prayer was heard or not but feel further attempts would be fruitless.");
        return 0;
        }

        SetLocalInt(oPC, "deity_last_pray_" + IntToString(nDeity), nCur);

        // Praying to a different deity
        if (!nStanding) {
        // All you get if you are not a follower or cleric is a minor shift towards this deity.



                if (Random(100) < 40) {
            // Shift oPC towards the alignment stored for nDeity by SetDeityAlignment().
//                        ShiftAlignment(oPC,
//                               GetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_LC"),
//                               GetLocalInt(GetModule(), DEITY_ALIGNMENT + IntToHexString(nDeity) + "_GE"),
//                               d2());
 //                       return 1;
                }


                // Praying to a different deity causes loss of favor with your deity.
                if (bCleric) {
                        deityAdjustFavor(oPC, nStanding, 2, TRUE);
                } else {
                        deityAdjustFavor(oPC, nStanding, 0, TRUE);
                }
                return 0;
        }

    // If follower or cleric you get an alignment/favor shift.
        deityAdjustFavor(oPC, nStanding, bAltar);

    // If you were already in favor you also get a bonus...
    int nChance = 50;
    if (bAltar) nChance = 80;

        if (nStanding > 0 && Random(100) < nChance) {
                RewardFaithfulness(oPC, nDeity);
        }
        return 1;
}

void deityDoPrayerEither(object oPC, object oAltar) {
        int nDeity = GetDeityIndex(oPC);
        int bAltar = GetIsObjectValid(oAltar);

        deityDoPrayer(nDeity, oPC, bAltar);
}

void deityDoDailyCheck(object oPC) {
        int nCount = GetLocalInt(oPC, "deity_pray_count");
        DeleteLocalInt(oPC, "deity_pray_count");
        int nPen =  0;
        if (deityIsCleric(oPC)) {
                if (nCount <= 0) {
                        nPen = 3;
                } else if (nCount == 1) {
                        nPen = 1;
                } else {
                        if (Random(100) < 25)
                                nPen = 1;
                }
        } else {
                if (nCount <= 0)
                        nPen = 1;
                else if (Random(100) < 25)
                        nPen = 1;
        }
        if (nPen >= 0) {
                                // this does one more than given value since 0 is valid level.
                deityAdjustFavor(oPC, deityGetStanding(GetDeityIndex(oPC),oPC), nPen -1, TRUE);
        }

}
void deityDoRemCurse(object oTarget, int nLevel) {

        SetLocalInt(OBJECT_SELF, "spell_tmp_spell", SPELL_REMOVE_CURSE);
        SetLocalObject(OBJECT_SELF, "spell_tmp_target", oTarget);
        SetLocalInt(OBJECT_SELF, "spell_tmp_level", nLevel);
        ExecuteScript("tb_spells_do_op1", OBJECT_SELF);

}

void deityDoRestore(object oTarget) {

        SetLocalInt(OBJECT_SELF, "spell_tmp_spell", SPELL_RESTORATION);
        SetLocalObject(OBJECT_SELF, "spell_tmp_target", oTarget);
        ExecuteScript("tb_spells_do_op1", OBJECT_SELF);
        /*
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION_GREATER);

    effect eBad = GetFirstEffect(oTarget);
    //Search for negative effects
    while(GetIsEffectValid(eBad)) {
        if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_AC_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_ATTACK_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_SAVING_THROW_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_SKILL_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS ||
            GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
            GetEffectType(eBad) == EFFECT_TYPE_CURSE ||
            GetEffectType(eBad) == EFFECT_TYPE_DISEASE ||
            GetEffectType(eBad) == EFFECT_TYPE_POISON ||
            GetEffectType(eBad) == EFFECT_TYPE_PARALYZE ||
            GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL) {
            //Remove effect if it is negative.
            RemoveEffect(oTarget, eBad);
        }
        eBad = GetNextEffect(oTarget);
    }
    if(GetRacialType(oTarget) != RACIAL_TYPE_UNDEAD) {
        //Apply the VFX impact and effects
        int nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
        effect eHeal = EffectHeal(nHeal);

        // Mar 2, 2004: Always heal at least one hp. Otherwise, if you have the wounding effect
        // but are at max hp (because of regeneration or whatever), the wounding will not
        // be removed.
        if(nHeal<1) nHeal = 1;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
    */
}

void deityFullHeal(object oPC, object oHealer = OBJECT_SELF) {

/*
  object oAnimal = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION,oPC);
  object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR,oPC);
  object oDominated = GetAssociate(ASSOCIATE_TYPE_DOMINATED,oPC);
  object oSummoned = GetAssociate(ASSOCIATE_TYPE_SUMMONED,oPC);
*/

    ActionPauseConversation();

    // this is to make the healer look like doing someting. probably breaks the convo...
    ActionCastFakeSpellAtObject(SPELL_GREATER_RESTORATION, oHealer);

    // This does the healing
    ActionDoCommand(deityDoRestore(oPC));
    //deityFakeRestore(oPC);

    int nHench = 1;
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oPC,nHench++);

    while (GetIsObjectValid(oHenchman)) {
        ActionDoCommand(deityDoRestore(oHenchman));
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oPC,nHench++);
    }

/*
  if(GetIsObjectValid(oAnimal))
  {
  ActionDoCommand(FakeRestore(oAnimal));
  }
  if(GetIsObjectValid(oFamiliar))
  {
  ActionDoCommand(FakeRestore(oFamiliar));
  }
  if(GetIsObjectValid(oDominated))
  {
  ActionDoCommand(FakeRestore(oDominated));
  }
  if(GetIsObjectValid(oSummoned))
  {
  ActionDoCommand(FakeRestore(oSummoned));
  }
*/
    ActionResumeConversation();
}

int deityGetHasCurse(object oPC) {

        if (GetHasSpellEffect(SPELL_BESTOW_CURSE, oPC) || GetHasSpellEffect(644, oPC)
                || GetHasSpellEffect(1016, oPC))
                return TRUE;

        object oItem;
        int i;
        // Head through bolts - not interested in creature parts -
        for (i = 0; i < 14; i ++) {
                oItem = GetItemInSlot(i, oPC);
                if (!GetIsObjectValid(oItem))
                        continue;

                if (GetLocalInt(oItem, "CursedDC") > 0 && GetLocalInt(oItem, "curse_applied")) {
                        return TRUE;
                }
        }

        //  non equippable cursed items
        oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem)) {
                if (GetIsObjectValid(oItem) && GetLocalInt(oItem, "CursedDC") > 0 && GetLocalInt(oItem, "curse_applied"))
                        return TRUE;

                oItem = GetNextItemInInventory(oPC);
        }

        return FALSE;
}

void deityRemCurse(object oPC, object oHealer = OBJECT_SELF) {

    ActionPauseConversation();

    int nLevel = GetLevelByClass(CLASS_TYPE_CLERIC, oHealer);

    if (nLevel < 10) nLevel = 10;

    // this is to make the healer look like doing someting. probably breaks the convo...
    ActionCastFakeSpellAtObject(SPELL_GREATER_RESTORATION, oHealer);

    // This does the healing
    ActionDoCommand(deityDoRemCurse(oPC, nLevel));
    //deityFakeRestore(oPC);

    int nHench = 1;
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oPC,nHench++);

    while (GetIsObjectValid(oHenchman)) {
        ActionDoCommand(deityDoRemCurse(oHenchman, nLevel));
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN,oPC,nHench++);
    }
    ActionResumeConversation();
}

// Return one of the DEITY_STANDING constants for how this PC is
// in respect to the given nDeity index.
int deityGetStanding(int nDeity, object oPC) {

    // If PC's deity is different return DEITY_STANDING_OTHER
    int nPCDeity = GetDeityIndex(oPC);

    if (nDeity != nPCDeity)
        return DEITY_STANDING_OTHER ;

    // At this point we're talking about the same deity...
    // Figure if PC is cleric
    if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0) {
        // Check for good standing
        if (DeityOutOfFavor(oPC))
            return DEITY_STANDING_CLERIC_LAPSED;

        if (DeityGetFavorPoints(oPC) >=90)
                return DEITY_STANDING_CLERIC_HIGH;

        return  DEITY_STANDING_CLERIC_OK;
    }
    // else follower
    if (DeityOutOfFavor(oPC))
        return DEITY_STANDING_FOLLOWER_LAPSED;

       if (DeityGetFavorPoints(oPC) >=90)
                return DEITY_STANDING_FOLLOWER_HIGH;
    return DEITY_STANDING_FOLLOWER_OK;
}

/* <CUSTOM420> is the <CUSTOM422> <CUSTOM424><CUSTOM423><CUSTOM425>. <CUSTOM421> has the ability to grant clerics the powers of <CUSTOM427><CUSTOM430>.
Clerics of <CUSTOM420> must be<CUSTOM426><CUSTOM428><CUSTOM429>.
*/
string dlgGetDeityInfo(object oNPC = OBJECT_SELF) {


    string sRet =  GetLocalString(oNPC, "_cur_deity_name") + " is the "
        + GetLocalString(OBJECT_SELF, "_cur_deity_align") + " "
        +  GetLocalString(OBJECT_SELF, "_cur_deity_title")
        +  GetLocalString(OBJECT_SELF, "_cur_deity_portfolio")
        +  GetLocalString(OBJECT_SELF, "_cur_deity_altnames") + ". "
        +  GetLocalString(OBJECT_SELF, "_cur_deity_weaps") + ". ";

        //+  GetLocalString(OBJECT_SELF, "_cur_deity_gender") + " has the ability to grant clerics the powers of "
        //+ GetLocalString(OBJECT_SELF, "_cur_deity_domains")
        //+ GetLocalString(OBJECT_SELF, "_cur_deity_weapon") + ". ";
        sRet = sRet + GetLocalString(OBJECT_SELF, "_cur_deity_req_gender");

        sRet += "\n";

    // Check for any restriction
    string s1 = GetLocalString(OBJECT_SELF, "_cur_deity_req_align");
    string s2 = GetLocalString(OBJECT_SELF, "_cur_deity_req_race");
    string s3 = GetLocalString(OBJECT_SELF, "_cur_deity_req_subrace");
    string sDoms =    GetLocalString(OBJECT_SELF, "_cur_deity_domains") ;

    if (sDoms != "") {
        sRet += "\n Domains: " + sDoms;
    }

    if (s1 != "") {
        sRet += "\n Alignments: " + s1;
    }

    if (s2 != "") {
        sRet += "\n Race: " + s2;
        if (s3 != "") {
                sRet += s3;
        }
    }

    //if (s1 != "" || s2 != "" || s3 != "") {
    //    sRet = sRet + "Servants of " + GetLocalString(oNPC, "_cur_deity_name") + " must be"
    //        +  s1 + s2 + s3 + ". ";
    //}
    //sRet = sRet + GetLocalString(OBJECT_SELF, "_cur_deity_req_gender");

    return sRet;
}


string dlgGetDeityRestrictions(object oNPC = OBJECT_SELF) {


    string sRet = "You may serve "
        + GetLocalString(oNPC, "_cur_deity_name") + " if you are "
        +  GetLocalString(OBJECT_SELF, "_cur_deity_req_align")
        +  GetLocalString(OBJECT_SELF, "_cur_deity_req_race")
        +  GetLocalString(OBJECT_SELF, "_cur_deity_req_subrace") + "."
        +  GetLocalString(OBJECT_SELF, "_cur_deity_req_gender");


    return sRet;
}

// Then I will pray for <CUSTOM420> to call you to his service.  When you are experienced enough, begin your profession as a cleric with the <CUSTOM427> domains.  You must be <CUSTOM426>, otherwise your prayers will not be granted and you may suffer the wrath of <CUSTOM420>.

string dlgGetServeMessage(object oNPC = OBJECT_SELF) {

    string sRet = "Then I will pray for " + GetLocalString(oNPC, "_cur_deity_name") + " to call you to service."
        + " When you are experienced enough, begin your profession as a cleric with the "
        +  GetLocalString(OBJECT_SELF, "_cur_deity_domains")
        + "domains. You must be " +  GetLocalString(OBJECT_SELF, "_cur_deity_req_align")
        + ", otherwise your prayers will not be granted.";

    return sRet;
}


string dlgGetAltarName(int nDeity, object oAltar = OBJECT_SELF) {
    string sName =  GetLocalString(OBJECT_SELF, "dlg_altar_name");
    if (sName != "") return sName;

    string sTemp =   GetDeityChurchName(nDeity);
    if (sTemp == "shrine")
        return "shrine";

    // church and temple gods default to altar.
    return "altar";
}

/*
  This is a/an [shrine/altar] to <deityname> god/goddess/deity of foobar...
*/
string dlgGetAltarMessage(int nDeity, object oAltar = OBJECT_SELF) {
    string sTemp =  dlgGetAltarName(nDeity, OBJECT_SELF);
    string sDeity = GetDeityName(nDeity);

    string sN = "";
    if (sTemp == "altar") sN = "n";

    string sRet = "This is a" + sN + " " + sTemp + " to " + sDeity + ", the "
        + GetLocalString(OBJECT_SELF, "_cur_deity_title")
        +  GetLocalString(OBJECT_SELF, "_cur_deity_portfolio")
        + ".";

    return sRet;
}

// Return true if the PC is a divine spell caster.
// Currently works on basic classes only.
int deityPCDivineCaster(object oPC) {
    if (GetLevelByClass(CLASS_TYPE_DRUID, oPC)
        || GetLevelByClass(CLASS_TYPE_CLERIC, oPC)
        || GetLevelByClass(CLASS_TYPE_PALADIN, oPC) > 3
        || GetLevelByClass(CLASS_TYPE_RANGER, oPC) > 3)
        return TRUE;

    return FALSE;
}

// Returns true if the PC needs a holysymbol and this object is
// configured to provide one.
// Only works for clerics and followers in good standing nDeity.
int dlgDeityNeedsHolySymbol(object oPC, int nDeity, object oNPC = OBJECT_SELF) {
    if (!GetLocalInt(oNPC, "deity_gives_holysymbol"))
        return FALSE;

    int nStanding = deityGetStanding(nDeity, oPC);

    if ((nStanding == DEITY_STANDING_CLERIC_OK)
        || (nStanding == DEITY_STANDING_FOLLOWER_OK && deityPCDivineCaster(oPC))) {
            if (!HasHolySymbol(oPC))
                return TRUE;
        }

        return FALSE;
}


void deityRestoreSavedData(object oPC) {
        SetLocalInt(oPC, "deity_favor_points", GetPersistentInt(oPC, "deity_favor_points"));
        int nCur = GetPersistentInt(oPC, "deity_last_pray");
        SetLocalInt(oPC, "deity_last_pray_" + IntToString(GetDeityIndex(oPC)), nCur);
        if (CurrentDay() > nCur)
                DeleteLocalInt(oPC, "deity_pray_count");
        else
                SetLocalInt(oPC, "deity_pray_count", GetPersistentInt(oPC, "deity_pray_count"));

}

// Set the PC to follow or serve the given deity
// sDeity should be a valid deity in the current configuration
void deitySetDeity(object oPC, string sDeity) {

        SetDeity(oPC, sDeity);
        if (deityIsCleric(oPC))
                SetPersistentInt(oPC,  "deity_favor_points", 65);
        else
                SetPersistentInt(oPC,  "deity_favor_points", 50);

        deityRestoreSavedData(oPC);

        DeityRestrictionsPostLevel(oPC);
        DeityWeaponsPostLevel(oPC);
}


void deityStatusFeedback(object oPC) {
        int nDeity = GetDeityIndex(oPC);
        int nStanding = deityGetStanding(nDeity, oPC);
        string sDeity = GetDeityName(nDeity);

        string sType = "follower";
        string sStatus = " ";
        string sExtra = "(" + IntToString(DeityGetFavorPoints(oPC)) + "/100)";
        switch(nStanding) {

              case DEITY_STANDING_CLERIC_OK: sType = "servant";   break;
              case DEITY_STANDING_CLERIC_LAPSED:  sType = "servant"; sStatus = "lapsed "; break;
              case DEITY_STANDING_CLERIC_HIGH: sType = "servant"; sStatus = "favored ";break;


              case DEITY_STANDING_FOLLOWER_OK: break;
              case DEITY_STANDING_FOLLOWER_HIGH:sStatus = "lapsed "; break;
              case DEITY_STANDING_FOLLOWER_LAPSED:sStatus = "favored ";break;

        }

        if (nStanding)
                SendMessageToPC(oPC, "You are a " + sStatus + sType + " of " + sDeity + ". " + sExtra);
        else
                SendMessageToPC(oPC, "You are a follower or servant of no god.");

}
