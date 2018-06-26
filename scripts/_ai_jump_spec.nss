//::///////////////////////////////////////////////
//:: _ai_jump_spec
//:://////////////////////////////////////////////
/*
    This is a Special Combat AI Script called by DetermineCombatRound [file: nw_i0_generic]
    It is called by ExecuteScript on a Creature Object.

    To give this special AI to a creature
    Set Local String
        X2_SPECIAL_COMBAT_AI_SCRIPT     =  v2_ai_jump_spec

    Local Floats (optional):
        MOVE_JUMP_DISTANCE
        CREPERSPACE

*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2011 july 10)
//:: Modified: The Magus (2011 july 12) added explicit calls to attack after jumping to enemy,
//::                                    and success sets the flag to skip normal combat ai this round
//:: Modified: The Magus (2016 jan 16) modifications for hillsedge
//:://////////////////////////////////////////////

#include "nw_i0_generic"

#include "_inc_constants"
#include "_inc_util"


// DEFINE SUB-FUNCTIONS --------------------------------------------------------
// determines type of special maneuver to make
void DetermineSpecialMovement(object oEnemy);

int SpecialCombatJump(object oEnemy, int bFlee = FALSE);

// utility sub functions

// Returns TRUE if creature should run from PC
int IsAfraid(object oEnemy);
// Returns a location to which the monster can be successfully moved
location DetermineDestination(object oEnemy, int bRandom = TRUE, float fDist = 6.0, int bFlee = FALSE);
// Returns the CREPERSPACE for OBJECT_SELF
float DetermineDistance();


// IMPLEMENT SUB-FUNCTIONS -----------------------------------------------------
void DetermineSpecialMovement(object oEnemy)
{
    int nSuccess = FALSE; // special combat moves return TRUE on success

    // This is where we would choose between attack maneuvers
    nSuccess = SpecialCombatJump(oEnemy, IsAfraid(oEnemy)); // jump attack

    if (nSuccess)
        SetLocalInt(OBJECT_SELF, "X2_SPECIAL_COMBAT_AI_SCRIPT_OK", TRUE); // skip normal combat AI this round
}

int SpecialCombatJump(object oEnemy, int bFlee = FALSE)
{
    int nSuccess    = FALSE; // returned to signify whether this action was successful
    location lDestination; // destination of jump
    int iSize       = GetCreatureSize(OBJECT_SELF);
    int bInterior   = GetIsAreaInterior(GetArea(OBJECT_SELF));
    int bShort      = FALSE;
    int bKnockdown  = GetHasFeat(FEAT_KNOCKDOWN); // capability of flying leap knockdown
    int bSpider     = GetHasFeat(2017); // has spiderclimb?

    float fMaxDistance  = GetLocalFloat(OBJECT_SELF, "MOVE_JUMP_DISTANCE"); // distance in meters creature can leap
    if (fMaxDistance <= 0.0)// default jump distance
    {
        switch(iSize) // based on size
        {
            case 1: case 2: case 3: fMaxDistance = 7.6; break;
            case 4: fMaxDistance = 15.0; break;
            case 5: fMaxDistance = 22.6; break;
            default: fMaxDistance = 7.6; break;
        }
    }
    if(!bInterior)
        fMaxDistance *= 1.5; // greater potential to leap outdoors
    else if (bSpider)
        fMaxDistance = 255.0; // spiders indoors can jump/climb and reach anywhere

    // Determine outcome of potential knockdown
    int bImmune = GetIsImmune(oEnemy, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF);
    int nRoll   = d20();
    int nRank   = GetSkillRank( SKILL_DISCIPLINE,oEnemy);
    int nSzDiff     = iSize - GetCreatureSize(oEnemy);
    int nDC     = d20() + GetBaseAttackBonus(OBJECT_SELF) + GetAbilityModifier(ABILITY_STRENGTH) - 4 + (nSzDiff*4);
    string sResult = PALEBLUE + GetName(oEnemy) + BLUE + " : Discipline : ";

        if(nRoll+nRank >= nDC)
            sResult += "*success*";
        else
           sResult += "*failure*";
       sResult += " : (" + IntToString(nRoll) + " + " + IntToString(nRank) + " = " + IntToString(nRoll+nRank) + " vs. DC: " +IntToString(nDC)+ ")";

    // determine distance relative to max jump
    if ( GetDistanceBetween(oEnemy, OBJECT_SELF) > fMaxDistance || bFlee)
    {
        bShort = TRUE; // too far for knockdown attack
        if(!bFlee)
            TurnToFaceObject(oEnemy, OBJECT_SELF);
        lDestination = DetermineDestination(oEnemy, FALSE, fMaxDistance, bFlee);
    }
    else
        lDestination = DetermineDestination(oEnemy);

    if ( GetIsObjectValid(GetAreaFromLocation(lDestination)) )
    {
        if( !bSpider || (bSpider && bInterior) )
        {   // Spiders Inside and all others
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDisappearAppear(lDestination), OBJECT_SELF, 3.0);
            if(!bImmune && !bShort && bKnockdown && !bFlee) // Knockdown
            {
                if(GetIsPC(oEnemy))
                    DelayCommand(3.0, SendMessageToPC(oEnemy, sResult));
                if( nRoll+nRank < nDC )
                    DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oEnemy, 3.0));
            }
            if(bFlee)
            {
                DelayCommand(3.1, ClearAllActions());
                DelayCommand(3.2, ActionMoveAwayFromObject(oEnemy, TRUE));
            }
            else
                DelayCommand(3.1, ActionAttack(oEnemy));
        }
        else
        {   // Spiders outside
            AssignCommand(OBJECT_SELF, ClearAllActions());
            AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_FIREFORGET_SPASM));
            AssignCommand(OBJECT_SELF, ActionJumpToLocation(lDestination));
            if(!bImmune && !bShort && bKnockdown && !bFlee ) // Knockdown
            {
                if(GetIsPC(oEnemy))
                    DelayCommand(1.75, SendMessageToPC(oEnemy, sResult));
                if( nRoll+nRank < nDC )
                    DelayCommand(1.75, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oEnemy, 3.0));
            }
            if(!bFlee)
                DelayCommand(1.8, AssignCommand(OBJECT_SELF, ActionAttack(oEnemy)));
            else
                DelayCommand(1.8, AssignCommand(OBJECT_SELF, ActionMoveAwayFromObject(oEnemy, TRUE)));
        }
        nSuccess = TRUE;
    }

    return nSuccess;
}

// IMPLEMENT UTILITY SUB FUNCTIONS -------------------------------------------------------
int IsAfraid(object oEnemy)
{
    if (    GetHasEffect(EFFECT_TYPE_TURNED)        // use for determining fight or flight
        ||  GetHasEffect(EFFECT_TYPE_FRIGHTENED) // use for determining fight or flight
        ||  GetLocalInt(OBJECT_SELF, "AI_MODE_FLEEING")
       )
    {
        return TRUE; // Flight
    }

    return FALSE; // Fight
}

location DetermineDestination(object oEnemy, int bRandom = TRUE, float fDist = 6.0, int bFlee = FALSE)
{
    location lDestination; // returned result
    string sResRef  = GetResRef(OBJECT_SELF);
    float fSpace    = DetermineDistance(); // distance from target based on CREPERSPACE
    object oTemp; // test object
    int x           = 0;
    int y           = 26; // max loops for random test
    float fMargin   = 5.0; // tolerance for random test
    float fDir      = GetFacing(OBJECT_SELF);
    float fTempDist;

    if (!bRandom || bFlee)
    {
        y = 6; // max loops
        fMargin = 1.5; // tolerance
    }

    while(x < y)
    {
        x++;
        // Generate a location
        if (bRandom)
        {   // at random
            lDestination = GetRandomLocation(GetArea(oEnemy), oEnemy, fSpace);
        }
        else
        {   // a series of 5 test jumps in a line extending from origin to maxdist
            fTempDist = (fDist/5.0) * IntToFloat(x);
            lDestination = GenerateNewLocation(OBJECT_SELF, fTempDist, fDir, fDir);
        }
        // create the test object
        oTemp = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lDestination);
        // did the test object arrive within the margin of error?
        if ( GetDistanceBetweenLocations(lDestination, GetLocation(oTemp)) <= fMargin )
        {   // YES! we found a suitable location to jump to
            DestroyObject(oTemp);
            break;
        }
        DestroyObject(oTemp);
        lDestination = GetLocation(OBJECT_INVALID); // this signifies an unsuitable jump
    }

    return lDestination;
}

float DetermineDistance()
{
    // To reduce server load CREPERSPACE can be stored on the creature
    // This should not be set on creatures that can shape shift
    float fSpace = GetLocalFloat(OBJECT_SELF, "CREPERSPACE");
    // if CREPERSPACE is not set, the appearance 2da is searched for the value
    if (fSpace <= 0.00)
    {
        string sSpace = Get2DAString("appearance", "CREPERSPACE", GetAppearanceType(OBJECT_SELF));
        fSpace = StringToFloat(sSpace);
        SetLocalFloat(OBJECT_SELF, "CREPERSPACE", fSpace);
    }
    return fSpace;
}

// MAIN LOOP -------------------------------------------------------------------
void main()
{
    object oSelf        = OBJECT_SELF;
    object oEnemy       = GetLocalObject(oSelf, "X2_NW_I0_GENERIC_INTRUDER");

    // Choose an enemy to focus on: intruder > nearest seen
    if (!GetIsObjectValid(oEnemy))
        oEnemy = GetNearestSeenEnemy();

    // determine if stuck in place
    if(
        GetIsObjectValid(oEnemy)
        && !GetIsObjectValid(GetAttemptedAttackTarget())
        && !GetIsObjectValid(GetAttemptedSpellTarget())
        && !GetHasEffect(EFFECT_TYPE_SLEEP)
        && !GetHasEffect(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE)
        && GetCommandable()
        )
    {
        location lLastLocation = GetLocalLocation(oSelf, "LOCATION");
        location lLocation = GetLocation(oSelf);

        if (GetAreaFromLocation(lLastLocation) == GetAreaFromLocation(lLocation)
            && GetTimeCumulative(TIME_SECONDS) - GetLocalInt(oSelf, "LOCATION_TIMESTAMP") < 12
           )
        {
            float fDelta = GetDistanceBetweenLocations(lLastLocation, lLocation);
            if (fDelta < 1.0)
            {
                DetermineSpecialMovement(oEnemy);
            }
        }

        SetLocalInt(oSelf, "LOCATION_TIMESTAMP", GetTimeCumulative(TIME_SECONDS));
        SetLocalLocation(oSelf, "LOCATION", lLocation);
    }
}
