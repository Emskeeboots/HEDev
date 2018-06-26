//::///////////////////////////////////////////////
//:: x0_inc_generic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    new functions breaking down some of the 'big'
    functions in nw_i0_generic for readability.



    MODIFICATION FEBRUARY 6 2003: MAJOR!!!
    Put the clarallactions that preceeded almost every talent call
    inside of BkTalentFilter


    - Dec 18 2002: Only henchmen will now make evaluations
           based upon difficulty of the combat.

* Many of these functions are incorporating
* Pausanias' changes, a big thanks goes out to him.


SECTION 1:

*/

#include "x0_i0_debug"
// #include "x0_i0_match" -- included in x0_i0_enemy
// #include "x0_i0_enemy" -- included in x0_i0_equip
// #include "x0_i0_assoc" -- included in x0_i0_equip
#include "x0_i0_equip"

/**********************************************************************
 * CONSTANTS
 **********************************************************************/

// IF this is true there is no CR consideration for using powers
const int NO_SMART = FALSE;

/**********************************************************************
 * FUNCTION PROTOTYPES
 **********************************************************************/

// Set up our hated class
void bkSetupBehavior(int nBehaviour);

// Return the combat difficulty.
// This is only used for henchmen and its only function currently
// is to keep henchmen from casting spells in an easy fight.
// This determines the difficulty by counting the number of allies
// and enemies and their respective CRs, then converting the value
// into a "spell CR" rating.
// A value of 20 means use whatever you have, a negative value
// means a very easy fight.
int GetCombatDifficulty(object oRelativeTo=OBJECT_SELF, int bEnable=FALSE);

// Determine our target for the next combat round.
// Normally, this will be the same target as the last round.
// The only time this changes is if the target is gone/killed
// or they are in dying mode.
object bkAcquireTarget();

// Choose a new nearby target. Target must be an enemy, perceived,
// and not in dying mode. If possible, we first target members of
// a class we "hate" -- this is generally random, to keep everyone
// from attacking the same target.
object ChooseNewTarget(object oLastTarget=OBJECT_INVALID);

//    Determines the Spell CR to be used in the
//    given situation
//
//    BK: changed this. It returns the the max CR for
//    this particular scenario.
//
//    NOTE: Will apply to all creatures though it may
//    be necessary to limit it just for associates.
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 18, 2001
int GetCRMax();

//    Returns true if something that shouldn't
//    have happened, happens. Will abort this combat
//    round.
int bkEvaluationSanityCheck(object oIntruder, float fFollow);

//    This function is the last minute filter to prevent
//    any inappropriate effects from being applied
//    to inapproprite creatures.
//
//    Returns TRUE if the talent was valid, FALSE otherwise.
//
//    If an invalid talent is attempted, we instead perform
//    a standard melee attack to avoid AI stopping.
//
// Based on Pausanias's Final Talent Filter.
// Parameters
// bJustTest = If this is true the function only does a test
//  the action stack is NOT modified at all
int bkTalentFilter(talent tUse, object oTarget, int bJustTest=FALSE);

//Sets a local variable for the last spell used
void SetLastGenericSpellCast(int nSpell);

//Returns a SPELL_ constant for the last spell used
int GetLastGenericSpellCast();

//Compares the current spell with the last one cast
int CompareLastSpellCast(int nSpell);

//Does a check to determine if the NPC has an attempted
//spell or attack target
int GetIsFighting(object oFighting);


/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/


//::///////////////////////////////////////////////
//:: SetupBehaviour
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Behavior1 = Hated Class
*/
void bkSetupBehavior(int nBehaviour)
{
    int nHatedClass = Random(10);
    nHatedClass = nHatedClass + 1;     // for purposes of using 0 as a
                                       // unitialized value.
                                       // will decrement in bkAcquireTarget
    SetLocalInt(OBJECT_SELF, "NW_L_BEHAVIOUR1", nHatedClass);
}

// Return the combat difficulty.
// This is only used for henchmen and its only function currently
// is to keep henchmen from casting spells in an easy fight.
// This determines the difficulty by counting the number of allies
// and enemies and their respective CRs, then converting the value
// into a "spell CR" rating.
// A value of 20 means use whatever you have, a negative value
// means a very easy fight.
// * Only does something if Enable is turned on, since I originally turned this function off
int GetCombatDifficulty(object oRelativeTo=OBJECT_SELF, int bEnable=FALSE)
{
    // DECEMBER 2002
    // * if I am not a henchman then DO NOT use combat difficulty
    // * simply use whatever I have available

    // FEBRUARY 2003
    // * Testing indicated that people were just too confused
    // * when they saw their henchmen not casting spells
    // * so this functionality has been cut entirely.

    // if (GetHenchman(GetMaster()) != oRelativeTo)
    if (bEnable == FALSE)
        return 20;

    // * Count Enemies
    struct sSituation sitCurr = CountEnemiesAndAllies(20.0, oRelativeTo);
    int nNumEnemies = sitCurr.ENEMY_NUM;
    int nNumAllies = sitCurr.ALLY_NUM;
    int nAllyCR = sitCurr.ALLY_CR;
    int nEnemyCR = sitCurr.ENEMY_CR;

    // * If for some reason no enemies then return low number
    if (nNumEnemies == 0) return -3;
    if (nNumAllies == 0) nNumAllies = 1;

    // * Average CR of enemies vs. Average CR of the players
    // * The + 5.0 is for flash. It would be boring if equally matched
    // * opponents never cast spells at each other.
    int nDiff = (nEnemyCR/nNumEnemies) - (nAllyCR/nNumAllies) + 3;

    // * if my side is outnumbered, then add difficulty to it
    if (nNumEnemies > (nNumAllies + 1))
        nDiff += 10;

    if (nDiff <= 1)
        return -2;

    // We now convert this number into the "spell CR" --
    // spell CR is as follows:
    // spell innate level * 2 - 1
    // eg, cantrip: innate level 0: spell CR -1
    // level 1 spell: innate level 1: spell CR 1
    // level 4 spell: innate level 4: spell CR 7
    // etc
    nDiff = (nDiff * 2) - 1;

    // * If I am at less than 50% hit-points add +10 -->
    // * it means that things are going badly for me
    // * and I need an edge
    if (GetCurrentHitPoints() <= GetMaxHitPoints()/2)
        nDiff = nDiff + 10;

    // * if not a low number then just return the difficulty
    // * converted into 'spell rounding'
    return nDiff;
}

// This function returns the target for this combat round.
// Normally, this will be the same target as the last round.
// The only time this changes is if the target is gone/killed
// or they are in dying mode.
object bkAcquireTarget()
{
    object oLastTarget = GetAttackTarget();

    // * for now no 'target switching' other
    // * than what occurs in the OnDamaged and OnPerceived events
    // * (I may roll their functionality into this function
    if (GetIsObjectValid(oLastTarget) == TRUE
        && !GetAssociateState(NW_ASC_MODE_DYING, oLastTarget))
    {
        return oLastTarget;
    } else {
        oLastTarget = ChooseNewTarget(oLastTarget);
    }

    // * If no valid target it means no enemies are nearby, resume normal behavior
    if (! GetIsObjectValid(oLastTarget)) {
        // * henchmen should only equip weapons based on what you tell them
        if (GetIsObjectValid(GetMaster(OBJECT_SELF)) == FALSE) {
            // * if no ranged weapon this function should
            // * automatically be melee weapon
            ActionEquipMostDamagingRanged();
        }
    }

    // valid or not, return it
    return oLastTarget;
}



// Choose a new nearby target. Target must be an enemy, perceived,
// and not in dying mode. If possible, we first target members of
// a class we hate.
object ChooseNewTarget(object oLastTarget=OBJECT_INVALID)
{
    int nHatedClass = GetLocalInt(OBJECT_SELF, "NW_L_BEHAVIOUR1") - 1;

    // * if the object has no hated class, then assign it
    // * a random one.
    // * NOTE: Classes are off-by-one
    if (nHatedClass == -1)
    {
        bkSetupBehavior(1);
        nHatedClass = GetLocalInt(OBJECT_SELF, "NW_L_BEHAVIOUR1") - 1;
    }

    //MyPrintString("I hate " + IntToString(nHatedClass));

    // * First try to attack the class you hate the most
    object oTarget = GetNearestPerceivedEnemy(OBJECT_SELF, 1,
                                              CREATURE_TYPE_CLASS,
                                              nHatedClass);

    if (GetIsObjectValid(oTarget) && oTarget != oLastTarget && !GetIsDead(oTarget) && !GetHasSpellEffect(SPELL_ETHEREALNESS, oTarget) && !GetAssociateState(NW_ASC_MODE_DYING, oTarget))
        return oTarget;

    // If we didn't find one with the criteria, look
    // for a nearby one
    // * Keep looking until we find a perceived target that
    // * isn't in dying mode
    oTarget = GetNearestPerceivedEnemy(OBJECT_SELF, 1, CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, SPELL_ETHEREALNESS);
    int nNth = 1;
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oLastTarget && !GetIsDead(oTarget) && !GetAssociateState(NW_ASC_MODE_DYING, oTarget))
        {
            break;
        }
        oTarget = GetNearestPerceivedEnemy(OBJECT_SELF, ++nNth, CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, SPELL_ETHEREALNESS);
    }

    return oTarget;
}


//::///////////////////////////////////////////////
//:: Get CR Max for Talents
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the Spell CR to be used in the
    given situation

    BK: changed this. It returns the the max CR for
    this particular scenario.

    NOTE: Will apply to all creatures though it may
    be necessary to limit it just for associates.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 18, 2001
//:://////////////////////////////////////////////
int GetCRMax()
{
    //int nCR;

    // * retrieves the combat difficulty that has been stored
    // * from being set in DetermineCombatRound
    //int nDiff =  GetLocalInt(OBJECT_SELF, "NW_L_COMBATDIFF");

    if  (NO_SMART == TRUE)
        return 20;
   else
       return GetLocalInt(OBJECT_SELF, "NW_L_COMBATDIFF"); // the max CR of any talent that is going to be used
}



//::///////////////////////////////////////////////
//:: bkEvaluationSanityCheck
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

    Returns true if something that shouldn't
    have happened, happens. Will abort this combat
    round.



*/
int bkEvaluationSanityCheck(object oIntruder, float fFollow)
{
    // Pausanias: sanity check for various effects
    if (GetHasEffect(EFFECT_TYPE_PARALYZE) ||
        GetHasEffect(EFFECT_TYPE_STUNNED) ||
        GetHasEffect(EFFECT_TYPE_FRIGHTENED) ||
        GetHasEffect(EFFECT_TYPE_SLEEP) ||
        GetHasEffect(EFFECT_TYPE_DAZED))
        return TRUE;

    // * no point in seeing if intruder has same master if no valid intruder
    if (!GetIsObjectValid(oIntruder))
        return FALSE;

    // Pausanias sanity check: do not attack target
    // if you share the same master.
    object oMaster = GetMaster();
    if (GetIsObjectValid(oMaster) && GetMaster(oIntruder) == oMaster)
        return TRUE;

    return FALSE; //* COntinue on with DetermineCombatRound
}

/*
//    This function is the last minute filter to prevent
//    any inappropriate effects from being applied
//    to inapproprite creatures.
//
//    Returns TRUE if the talent was valid, FALSE otherwise.
//
//    If an invalid talent is attempted, we instead perform
//    a standard melee attack to avoid AI stopping.
//
 MODIFIED JULY 11 2003 (BK):
      - If I cannot use this particular ability
        then in *most* cases I will delete the spell
        from my list so I do not try to use it again.
        This will help to prevent the "wizard just attacking"
        when the spell they most want to use is ineffective.
// Based on Pausanias's Final Talent Filter.
//
*/
int bkTalentFilter(talent tUse, object oTarget, int bJustTest=FALSE)
{
    if(!bJustTest)
        ClearActions(CLEAR_X0_INC_GENERIC_TalentFilter);
    // * try to equip if not equipped at this point
    // * has to be here, to avoid ClearAllAction
//    object oRightHand =GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
//    int bValidOnHand = GetIsObjectValid(oRightHand);
//    if (bValidOnHand  == FALSE || GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_LEFTHAND)) == FALSE)
//    {
        // MyPrintString("equipping a new item");
        // * if a ranged weapon then I don't care that my left hand is empty
//        int bHoldingRanged = FALSE;

//        if (bValidOnHand == TRUE)
//        {
//            bHoldingRanged = GetWeaponRanged(oRightHand);
//        }
//        if (bHoldingRanged == FALSE)
            bkEquipAppropriateWeapons(oTarget, GetAssociateState(NW_ASC_USE_RANGED_WEAPON));
//    }

    int iId = GetIdFromTalent(tUse);
    int nType = GetTypeFromTalent(tUse);
    int iAmDone = FALSE;
    int nNotValid = FALSE;

    int nTargetRacialType = GetRacialType(oTarget);

    // Check for undead!

    if(nTargetRacialType == RACIAL_TYPE_UNDEAD)
    {
      // DO NOT USE SILLY HARM ON THEM; substitute a heal spell if possible
      if(nType == TALENT_TYPE_SPELL)
      {
        switch(iId)
        {
        case SPELL_INFLICT_MINOR_WOUNDS:
            if(GetHasSpell(SPELL_CURE_MINOR_WOUNDS))
                iAmDone = SPELL_CURE_MINOR_WOUNDS;
        case SPELL_INFLICT_LIGHT_WOUNDS:
        case SPELL_NEGATIVE_ENERGY_RAY:
            if(GetHasSpell(SPELL_CURE_LIGHT_WOUNDS))
                iAmDone = SPELL_CURE_LIGHT_WOUNDS;
        case SPELL_INFLICT_MODERATE_WOUNDS:
        case SPELL_NEGATIVE_ENERGY_BURST:
            if(GetHasSpell(SPELL_CURE_MODERATE_WOUNDS))
                iAmDone = SPELL_CURE_MODERATE_WOUNDS;
        case SPELL_INFLICT_SERIOUS_WOUNDS:
            if(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS))
                iAmDone = SPELL_CURE_SERIOUS_WOUNDS;
        case SPELL_INFLICT_CRITICAL_WOUNDS:
            if(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS))
                iAmDone = SPELL_CURE_CRITICAL_WOUNDS;
        case SPELL_HARM:
            if(GetHasSpell(SPELL_HEAL) && GetChallengeRating(oTarget) > 8.0)
                iAmDone = SPELL_HEAL;
            if(!iAmDone)
                iAmDone = -1;
        break;
        }
      }
      else if(nType == TALENT_TYPE_FEAT)
      {
        switch(iId)
        {
        case FEAT_INFLICT_LIGHT_WOUNDS:
            if(GetHasSpell(SPELL_CURE_LIGHT_WOUNDS))
                iAmDone = SPELL_CURE_LIGHT_WOUNDS;
        case FEAT_INFLICT_MODERATE_WOUNDS:
            if(GetHasSpell(SPELL_CURE_MODERATE_WOUNDS))
                iAmDone = SPELL_CURE_MODERATE_WOUNDS;
        case FEAT_INFLICT_SERIOUS_WOUNDS:
            if(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS))
                iAmDone = SPELL_CURE_SERIOUS_WOUNDS;
        case FEAT_INFLICT_CRITICAL_WOUNDS:
            if(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS))
                iAmDone = SPELL_CURE_CRITICAL_WOUNDS;
            if(GetHasSpell(SPELL_HEAL) && GetChallengeRating(oTarget) > 8.0)
                iAmDone = SPELL_HEAL;
            if(!iAmDone)
                iAmDone = -1;
        break;
        }
      }
      if(iAmDone > 0)
      {//spell substituted
        tUse = TalentSpell(iAmDone);
        iAmDone = TRUE;
      }
      else if(iAmDone < 0)
      {
        if(GetRacialType(OBJECT_SELF) == RACIAL_TYPE_UNDEAD && iId != SPELL_NEGATIVE_ENERGY_RAY && GetCurrentHitPoints() < GetMaxHitPoints())
        {//if no heal talents available but I am an undead, then use these spells rather to heal myself
          oTarget = OBJECT_SELF;
        }
        else
        {//remove the spell, so the caster doesn't get stuck trying to use it.
          nNotValid = TRUE;
          DecrementRemainingSpellUses(OBJECT_SELF, iId);
        }
        iAmDone = TRUE;
      }
    }

    // *
    // * Don't use drown against nonliving opponents
/*    if (iId == SPELL_DROWN && !iAmDone)
    {
        if (MatchNonliving(nTargetRacialType) || GetRacialType(oTarget) == RACIAL_TYPE_OOZE)
        {
            nNotValid = TRUE;
            iAmDone = TRUE;
            DecrementRemainingSpellUses(OBJECT_SELF, SPELL_DROWN);
        }
    }   */

    // * August 2003
    // * If casting certain spells that should not harm creatures
    // * who are immune to losing levels, try another
/*    if (!iAmDone && iId == SPELL_ENERGY_DRAIN && GetIsImmune(oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL))
    {
        nNotValid = TRUE;
        DecrementRemainingSpellUses(OBJECT_SELF, iId);
        iAmDone = TRUE;
    }  */
    //1.71: do not spam petrify talents on creatures already petrified
    if(!iAmDone && (iId == 495 || iId == 496 || iId == 497 || iId == 687) && GetHasEffect(EFFECT_TYPE_PETRIFY,oTarget))
    {
        iAmDone = TRUE;
        nNotValid = TRUE;
    }

    // * Negative damage does nothing to undead or constructs. Don't use it.
/*    if (!iAmDone && (iId == SPELL_NEGATIVE_ENERGY_BURST || iId == SPELL_NEGATIVE_ENERGY_RAY) && nTargetRacialType == RACIAL_TYPE_CONSTRUCT)
    {
        nNotValid = TRUE;
        DecrementRemainingSpellUses(OBJECT_SELF, iId);
        iAmDone = TRUE;
    }*/

    // Check if the sleep spell is being used appropriately.
    if(!iAmDone && ((nType == TALENT_TYPE_SPELL && iId == SPELL_SLEEP) || (nType == TALENT_TYPE_FEAT && iId == FEAT_HARPER_SLEEP)))
    {
        if(GetHitDice(oTarget) > 4)
        {
            nNotValid = TRUE;
            iAmDone = TRUE;
            DecrementRemainingSpellUses(OBJECT_SELF, SPELL_SLEEP);
        }
/*        // * elves and half-elves are immune to sleep
        switch (nTargetRacialType)
        {
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_HALFELF:
          nNotValid = TRUE;
          iAmDone = TRUE;
          DecrementRemainingSpellUses(OBJECT_SELF, SPELL_SLEEP);
          break;
        } */
    }

    // * Check: (Dec 19 2002) Don't waste Power Word Kill
    // on Targets with more than 100hp
    if(!iAmDone && nType == TALENT_TYPE_SPELL && iId == SPELL_POWER_WORD_KILL)
    {
        iAmDone = TRUE;
        if(GetCurrentHitPoints(oTarget) > 100)
        {
            if(bJustTest)
            {
                nNotValid = TRUE;
            }
            else
            {
                // * Since planning on doing a harmful ranged, try another one
                tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_RANGED, 20);
                if(!GetIsTalentValid(tUse) || GetIdFromTalent(tUse) == SPELL_POWER_WORD_KILL)
                {
                    // 1.70: Try lower talent then
                    tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_RANGED, 15);
                }
            }
        }
    }
    //1.71: dont cast haste on targets with haste effect
    if(!iAmDone && nType == TALENT_TYPE_SPELL && iId == SPELL_HASTE && GetHasEffect(EFFECT_TYPE_HASTE,oTarget))
    {
        //todo: haste item property check would be great as well, but atm it would be too resources expensive
        iAmDone = TRUE;
        nNotValid = TRUE;
    }

    // Check if person spells are being used appropriately.

    if (!iAmDone && nType == TALENT_TYPE_SPELL && MatchPersonSpells(iId))
        switch (nTargetRacialType)
        {
            case RACIAL_TYPE_ELF:
            case RACIAL_TYPE_HALFELF:
            case RACIAL_TYPE_DWARF:
            case RACIAL_TYPE_HUMAN:
            case RACIAL_TYPE_HALFLING:
            case RACIAL_TYPE_HALFORC:
            case RACIAL_TYPE_GNOME:
            case RACIAL_TYPE_HUMANOID_GOBLINOID:
            case RACIAL_TYPE_HUMANOID_MONSTROUS:
            case RACIAL_TYPE_HUMANOID_ORC:
            case RACIAL_TYPE_HUMANOID_REPTILIAN:
                iAmDone = TRUE;
            break;
            default:
                nNotValid = TRUE;
            break;
        }

    // Do a final check for mind affecting spells.
    if(!iAmDone && nType == TALENT_TYPE_SPELL && MatchMindAffectingSpells(iId))
        if(GetIsImmune(oTarget,IMMUNITY_TYPE_MIND_SPELLS))
        {
            switch(nTargetRacialType)//don't cheat, block spell only when immunity is obvious
            {
            case RACIAL_TYPE_UNDEAD:
            case RACIAL_TYPE_ELEMENTAL:
            case RACIAL_TYPE_CONSTRUCT:
            case RACIAL_TYPE_VERMIN:
            case RACIAL_TYPE_OOZE:
                nNotValid = TRUE;
            break;
            }
         }
    if(nNotValid)
    {   // * remove the spell, so the caster doesn't get stuck trying to use it.
        if(nType == TALENT_TYPE_SPELL)
        {
            DecrementRemainingSpellUses(OBJECT_SELF, iId);
        }
        else if(nType == TALENT_TYPE_FEAT)
        {
            DecrementRemainingFeatUses(OBJECT_SELF, iId);
        }
    }
    if(GetTypeFromTalent(tUse) == TALENT_TYPE_FEAT)
    {
        //MyPrintString("Using feat: " + IntToString(iId));
        if(!VerifyCombatMeleeTalent(tUse, oTarget) || !VerifyDisarm(tUse, oTarget))
        {
            //MyPrintString("combat melee & disarm OK");
            nNotValid = TRUE;
        }
    }

    if(bJustTest)
    {
        return !nNotValid && GetIsTalentValid(tUse);//1.71: return value for testing purposes moved here so it doesn't try to cast spells below
    }

    // *
    // * STAY STILL!!  (return condition)
    // * September 5 2003
    // *
    // * In certain cases (i.e., the spell Meteor Swarm) the caster should not move
    // * towards his target if the target is within range. In this caster the caster should just
    // * cast the spell centered around himself
    if(iId == SPELL_METEOR_SWARM || iId == SPELL_FIRE_STORM || iId == SPELL_STORM_OF_VENGEANCE || iId == SPELL_TIME_STOP)
    {
        if(iId == SPELL_TIME_STOP || GetDistanceToObject(oTarget) <= 10.5)
        {
            ActionUseTalentOnObject(tUse, OBJECT_SELF);
            return TRUE;
        }
        else
        {
            ActionMoveToObject(oTarget, TRUE, 9.0);
            ActionUseTalentOnObject(tUse, OBJECT_SELF);
            return TRUE;
        }
    }

    // * BK: My talent was not appropriate to use
    // *     will attack this round instead
    if(nNotValid || !GetIsTalentValid(tUse))
    {
        //MyPrintString("Invalid talent, id: " + IntToString(iId)
        //              + ", type: " + IntToString(GetTypeFromTalent(tUse)));
        //if(!bJustTest)
            WrapperActionAttack(oTarget);
    }
    else
    {
        //if(!bJustTest)
            ActionUseTalentOnObject(tUse, oTarget);
        return TRUE;
    }
    return FALSE;
}



//::///////////////////////////////////////////////
//:: Get / Set Compare Last Spell Cast
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gets the local int off of the character
    determining what the Last Spell Cast was.

    Sets the local int on of the character
    storing what the Last Spell Cast was.

    Compares whether the local is the same as the
    currently selected spell.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 27, 2002
//:://////////////////////////////////////////////

int GetLastGenericSpellCast()
{
    return GetLocalInt(OBJECT_SELF, "NW_GENERIC_LAST_SPELL");
}

void SetLastGenericSpellCast(int nSpell)
{
    SetLocalInt(OBJECT_SELF, "NW_GENERIC_LAST_SPELL", nSpell);
    // February 2003. Needed to add a way for this to reset itself, so that
    // spell might indeed be atempted later.
   // DelayCommand(8.0,SetLocalInt(OBJECT_SELF, "NW_GENERIC_LAST_SPELL", -1));//1.71: uncommented to retain randomization over time
}

int CompareLastSpellCast(int nSpell)
{
    int nLastSpell = GetLastGenericSpellCast();
    if(nSpell == nLastSpell)
    {
        return TRUE;
        SetLastGenericSpellCast(-1);
    }
    return FALSE;
}


//::///////////////////////////////////////////////
//:: GetIsFighting
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Checks if the passed object has an Attempted
    Attack or Spell Target
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: March 13, 2002
//:://////////////////////////////////////////////
int GetIsFighting(object oFighting)
{
    object oAttack = GetAttemptedAttackTarget();
    object oSpellTarget = GetAttemptedSpellTarget();

    if(GetIsObjectValid(oAttack) || GetIsObjectValid(oSpellTarget))
    {
        return TRUE;
    }
    return FALSE;
}



/* void main() {} /* */
