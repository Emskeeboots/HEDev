//::///////////////////////////////////////////////
//:: _plc_moveskill
//:://////////////////////////////////////////////
/*
    Original:
    Player Handbook Movement Skills 1.02
    by OldManWhistler

    Also made use of Failed Bards Jump and Climb animations and script


*/
//:://////////////////////////////////////////////
//:: Created:   Old Man Whistler
//:: Modified:  The Magus (2012 jan 31)
//:: Modified:  Henesua (2014 jan 13) rewrite
//:://////////////////////////////////////////////

#include "x0_i0_spells"

#include "aid_inc_global"

// The Magus's Includes
#include "_inc_spells"
//#include "_inc_data"
#include "_inc_xp"

// CONSTANTS -------------------------------------------------------------------

// How much distance to search for possible destination when waypoint isn't specified?
// Value 0.0 to infinity. The max distance only exists to prevent false
const float MS_MAX_NO_WP_SEARCH_DISTANCE = 30.0;
// How much time does the player have to choose to click the object after
// getting the description message?
// Value greater than 0.0.
const float MS_CLICK_TIMEOUT_SEC        = 30.0;
const float MS_REFRACTORY_PERIOD        = 6.0;
// Turn on debugging information for development.
//const int MS_DEBUG = FALSE;

// The skill types.
const int MS_SKILL_CLIMB        = 1;
const int MS_SKILL_SWIM         = 2;
const int MS_SKILL_TIGHT_SPACE  = 3;
const int MS_SKILL_JUMP         = 4;

//// (11/30/2012) Failed Bard
//// Include for climbing and jumping animation handling
// Custom animation constants for easier modifying.
const int ANIMATION_WALL_CLIMB = ANIMATION_LOOPING_CUSTOM1;
const int ANIMATION_JUMP_DOWN  = ANIMATION_LOOPING_CUSTOM2;
const int ANIMATION_LONG_JUMP  = ANIMATION_LOOPING_CUSTOM8;



struct MOVESKILL
{
    object self;
    // user's destination
    object destination;         // MOVE_DESTINATION      - is tag for this waypoint
    object failDestination;     // MOVE_FAIL             - is tag for this waypoint

    // data set directly by builder
    int skillPrime;             // MOVE_SKILL   - index of list - 1-climb, 2-swim, 3-squeeze, 4-jump
    int DC;                     // MOVE_DC      - challenge rating of primary skill
    int height;                 // MOVE_HEIGHT  - vertical distance scaled or descended during success
    int failHeight;             // MOVE_FAIL_HEIGHT needed for falls
                                //                  when MOVE_FAIL_DESTINATION != MOVE_DESTINATION
    int distance;               // MOVE_DISTANCE- horizontal distance to be crossed during success
    int fromTop;                // MOVE_TOP     - move is from a high position
    int maxSize;                // MOVE_SIZE    - move is limited by size (and thus likely through a gateway)
    int isSubmerged;            // MOVE_SUBMERGED - move is through a fluid
    int isFall;                 // MOVE_FALL    - the move IS a fall (this is used by things like sinkholes)
    int isVertJump;             // MOVE_VERTICAL - move IS vertical (used for Jumps)
    // data set dynamically by script
    int skill;                  // The skill we are using.
    int skillOverride;          // Established by other interfaces which force a different move type at this node
    int isRoped;                // ROPED        - means that a rope is tied here
    int ropeLength;             // ROPE_LENGTH - the length of the rope tied here
    int ropeMagic;              // ROPE_MAGIC  - magical quality on rope tied here
    // bookkeeping data in this script
    // results for user
    int type; // type of movement, which influences animations played

    int isSuccessful; // -1 = failure, 0 = undetermined, 1 = success
    string describeResults;
};

struct JUMP
{
    float min;
    float max;
    float actual;
    string type;
};

// DECLARATIONS ----------------------------------------------------------------

// returns jump values. min distance, max distance, actual, and type descript - [FILE: _plc_moveskill]
struct JUMP GetJump(object oUser, int bLongJump=TRUE, int bRunning=TRUE);

// Determines whether this item can be equipped while swimming. - [FILE: _plc_moveskill]
int GetCanSwimWith(object oItem);
// Set OBJECT_SELF in swimming mode. If bSwim=FALSE, cancel swim. - [FILE: _plc_moveskill]
void SetIsSwimming(int bSwim=TRUE);
// OBJECT_SELF suffers the consequences of failing to swim. - [FILE: _plc_moveskill]
void SwimFailure(int bKnockDown=TRUE);

// MSErrorMsg
// Displays error messages in the code.
//  oUser - the player who triggered the error.
//  sMsg - the error message.
void MSErrorMsg (object oUser, string sMsg);
// MSGetSkillName
// Get the skill name from the number.
//  oUser - used for displaying error messages only.
//  iSkill - a MS_SKILL_* constant.
string MSGetSkillName(object oUser, int iSkill);
// MSGetDestination
// Get the destination waypoint matching sDestTag. If waypoint not found, it
// looks for another object with the same tag within MS_MAX_NO_WP_SEARCH_DISTANCE.
//  sDestTag - the tag of the destination waypoint.
//  bKeepLooking - should we look for an object with the same tag if we can't
//                 find the waypoint?
object MSGetDestination(string sDestTag, int bKeepLooking = TRUE);
// MSGetBonusRank
// Returns the number the bonus modifier to oUser's skill rank.
//  nSkill - MS_SKILL_* constant.
//  oUser - the PC to get the modifier for.
int MSGetBonusRank(int nSkill, object oUser);
// MSGetPenalty
// Get all of the appropriate penalties based on the skill being checked.
//  nSkill - a MS_SKILL_* constant.
//  oUser - the player to get the penalty for.
int MSGetPenalty(int nSkill, object oUser);
// MSGetSkillRank
// Get the complete skill rank (innate, bonuses and penalties) for a player.
//  nSkill - a MS_SKILL_* constant.
//  oUser - the player to get the skill rank for.
int MSGetSkillRank(int nSkill, object oUser);
// MSGetDifficultyLevel
// Returns a string representing the challenge of the DC based on how high a PC
// needs to roll to succeed the check.
//  iRank - the player's total rank.
//  iDC - the DC of the check.
string MSGetDifficultyLevel(int iRank, int iDC);
// MSGetAngleBetween
// Returns a string representing the cardinal direction between the player
// and a destination in the distance.
//  oDestination - destination in the distance.
//  oUser - source object.
string MSGetAngleBetween(object oDestination, object oUser);

// Animation Functions --------------

//// Determines animation length for climb animation, and jumps oTarget to lTarget
//// at appropriate time.. - [FILE: _plc_moveskill]
void MSUserClimbs(location lTarget);
//// Determines animation length for jump animations, decides whether to use longjump
//// or jump down type based on comparison of Z and XY distances, and jumps oTarget
//// to lTarget at appropriate time.. - [FILE: _plc_moveskill]
void ActionJump  (object oTarget, location lTarget);
//// returns the animation scale for that appearance number/gender combination.
//// returns 1.0f if no match is present. - [FILE: _plc_moveskill]
float GetAnimationScale (object oTarget = OBJECT_SELF);
//// Moved to its own routine so I can compare the animation scale modified distance
//// to determine animation speed change. - [FILE: _plc_moveskill].
float GetFallTime (float fDistance);
//// Gets the height difference between two vectors. - [FILE: _plc_moveskill].
float GetZChange (vector vTarget, vector vSource);
//// Gets the XY axis distance between two vectors. - [FILE: _plc_moveskill].
float GetXYChange (vector vTarget, vector vSource);


struct MOVESKILL MSInitialize(object oUser);

int MSGetAltMovePossible(struct MOVESKILL Move);
// Move.type values determine animation
// 1 - normal animations
// 2 - disappear/appear (looks like flying or a spider climbs)
// 3 - fade/appear (incorporeal style)
// 4 - similar to passdoor
struct MOVESKILL MSGetAutomaticResults(struct MOVESKILL Move, object oUser);
object MSGetUser();
int MSGetUserClicks(object oUser);
void MSDescribeMove(object oUser);
void MSAttemptMove(object oUser);
// Executes on the user of the move node
void MSUserMoves(struct MOVESKILL Move);
// loop through all of users companions, determining if they can follow
void MSSendCompanions(object oUser, object oDest, string sMoveType);
// send one creature - called by MSSendCompanions
void MSSendCreature(object oCreature, object oDest);
// This animation and sound sequence is played when a character fails a check.
void MSUserComplains();
void MSUserFalls(int bTop, int nHeight, int bRoped);
void MSUserJFalls(int bTop, int nHeight, int bRoped);
void MSDoFallingDamage(int nDam, int nTumble, int bRoped);

void MSCleanUp(object oUser);

void MSIgnoreUser(object oUser);


// IMPLEMENTATION --------------------------------------------------------------

struct JUMP GetJump(object oUser, int bLongJump=TRUE, int bRunning=TRUE)
{
    struct JUMP Jump;

    // type of jump
    if(bRunning)
    {
        if(bLongJump)
            Jump.type = "running jump";
        else
            Jump.type = "broad jump";
    }
    else
    {
        if(bLongJump)
            Jump.type = "high jump";
        else
            Jump.type = "jump";
    }

    // gather common info
    int bIsRunning  = GetCanRun(oUser)&&bRunning;
    int bSpellExpRet= GetHasSpellEffect(SPELL_EXPEDITIOUS_RETREAT,oUser)||GetHasFeat(FEAT_BURST_SPEED);
    int nAppear     = GetAppearanceType(oUser);
    float fNatJump  = GetLocalFloat(oUser,"JUMP_DISTANCE");
    if(fNatJump==0.0)
          fNatJump  = StringToFloat(Get2DAString("appearance_x", "JUMP_DISTANCE", nAppear));

    float fPCHeight = StringToFloat(Get2DAString("appearance", "HEIGHT", nAppear));
    if(fPCHeight<1.0)
        fPCHeight   = 1.0;
    int nJumpSkill  = MSGetSkillRank(SKILL_JUMP, oUser);

    // next determine the maximum .....................
    // if monk feat: jump, or jump spell - no max distance.
    if(     GetHasSpellEffect(SPELL_JUMP,oUser)
        ||  GetHasFeat(FEAT_MONK_JUMP,oUser)
      )
    {
        Jump.max = 0.0; // no max. unlimited jump
    }
    // calculate max
    else
    {
        if(bLongJump)
        {
            if(bIsRunning)
                Jump.max  = fPCHeight * 6.0f;
            else
                Jump.max  = fPCHeight * 2.0f;
        }
        else
        {
            if(bIsRunning)
                Jump.max  = fPCHeight * 1.5f;
            else
                Jump.max  = fPCHeight;
        }

        if(bSpellExpRet)
            Jump.max *= 2.0f;

        Jump.max  += fNatJump;
    }

    // next determine the minimum .....................
    if(bLongJump && bIsRunning)
        Jump.min    = 2.0f;
    else
        Jump.min    = 1.0f;
    // base can not be less than height
    if(Jump.min<fPCHeight)
        Jump.min    = fPCHeight;

    float fAdjust;
    if(bLongJump)
    {
        if(bIsRunning)
            fAdjust = (nJumpSkill/3.0f)-10.0f;
        else
            fAdjust = (nJumpSkill/6.0f)-10.0f;
    }
    else
    {
        if(bIsRunning)
            fAdjust = (nJumpSkill/12.0f)-10.0f;
        else
            fAdjust = (nJumpSkill/24.0f)-10.0f;
    }
    if(fAdjust>0.0)
        Jump.min   += fAdjust;

    Jump.min += fNatJump;

    // if min is greater than max.. clamp it
    if(Jump.max!=0.0 && Jump.max<=Jump.min)
        Jump.min= Jump.max;

    // lastly make an actual jump check .............................
    if(bLongJump)
    {
        if(bIsRunning)
            fAdjust = ((d20()+nJumpSkill)/3.0f)-10.0f;
        else
            fAdjust = ((d20()+nJumpSkill)/6.0f)-10.0f;
    }
    else
    {
        if(bIsRunning)
            fAdjust = ((d20()+nJumpSkill)/12.0f)-10.0f;
        else
            fAdjust = ((d20()+nJumpSkill)/24.0f)-10.0f;
    }
        Jump.actual = Jump.min;
    if(fAdjust>0.0)
        Jump.actual += fAdjust;

    Jump.actual += fNatJump;

    // then handle multipliers
    float fSpeedPercent = 1.00f;
    if(GetHasEffect(EFFECT_TYPE_HASTE,oUser))
    {
        if(!GetHasEffect(EFFECT_TYPE_SLOW,oUser))
            fSpeedPercent += 0.50f;
    }
    else if(GetHasEffect(EFFECT_TYPE_SLOW,oUser))
        fSpeedPercent   -= 0.50f;
    if(bSpellExpRet)
        fSpeedPercent   += 1.00f;

    if(GetHasFeat(FEAT_MONK_ENDURANCE,oUser))
        fSpeedPercent   += (GetLevelByClass(CLASS_TYPE_MONK,oUser)/3)*0.10f;
    else if(GetHasFeat(FEAT_BARBARIAN_ENDURANCE,oUser))
        fSpeedPercent   += 0.10f;

    Jump.actual *= fSpeedPercent;

    if(Jump.max>0.0 && Jump.actual>Jump.max)
        Jump.actual = Jump.max;

    return Jump;
}

int GetCanSwimWith(object oItem)
{
    if(GetWeight(oItem)<11)
        return TRUE;

    int nType   = GetBaseItemType(oItem);
    if(     nType==BASE_ITEM_DAGGER
        ||  nType==BASE_ITEM_TRIDENT
        ||  nType==BASE_ITEM_KUKRI
        ||  nType==BASE_ITEM_SHURIKEN
        ||  nType==BASE_ITEM_MAGICWAND
      )
        return TRUE;

    return FALSE;
}

void SetIsSwimming(int bSwim=TRUE)
{
    if(bSwim)
    {
        if(!GetLocalInt(OBJECT_SELF, "IS_SWIMMING"))
        {
            SetLocalInt(OBJECT_SELF, "IS_SWIMMING", TRUE);
            if(!CreatureGetIsAquatic(OBJECT_SELF))
            {
                ClearAllActions();
                object oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
                object oLeft    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
                if(!GetCanSwimWith(oLeft))
                    ActionUnequipItem(oLeft);
                if(!GetCanSwimWith(oRight))
                    ActionUnequipItem(oRight);
            }
            PlaySound("");
            int nApp    = GetAppearanceType(OBJECT_SELF);
            if(nApp<7)
                DelayCommand(1.0, SetPhenoType(46, OBJECT_SELF));
        }
    }
    else
    {
        SetLocalInt(OBJECT_SELF, "IS_SWIMMING", FALSE);
        if(GetPhenoType(OBJECT_SELF)==46)
        {
            int nPhenoNatural   = Q_ACPGetPhenoFromString(GetSkinString(OBJECT_SELF, "PHENOTYPE_NATURAL_NAME"));
            //SendMessageToPC(OBJECT_SELF, "STOP SWIMMING Pheno("+IntToString(nPhenoNatural)+")");
            if(nPhenoNatural<1)
                nPhenoNatural   = 0;
            DelayCommand(1.0, SetPhenoType(nPhenoNatural, OBJECT_SELF));
        }

    }
}

void SwimFailure(int bKnockDown=TRUE)
{
    if(bKnockDown)
    {
        ClearAllActions(TRUE);
        PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 2.5);
        object oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        object oLeft    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
        int bDrop;
        location lLoc   = GetLocation(OBJECT_SELF);
        if(!GetCanSwimWith(oLeft))
        {
            bDrop   = TRUE;
            ActionUnequipItem(oLeft);
            object oDrop = CopyObject(oLeft,lLoc);
            DestroyObject(oLeft, 0.1);
        }
        if(!GetCanSwimWith(oRight))
        {
            bDrop   = TRUE;
            ActionUnequipItem(oRight);
            object oDrop = CopyObject(oRight,lLoc);
            DestroyObject(oRight, 0.1);
        }
        if(bDrop)
            SendMessageToPC(OBJECT_SELF, LIME+"Something slips from your fingers.");
    }

    GivePCFatigue();

}

// ****************************************************************************
void MSErrorMsg (object oUser, string sMsg)
{
    string sErrorMsg = "MoveSkillError: "+sMsg+" on obj:"+GetResRef(OBJECT_SELF)+" tag:"+GetTag(OBJECT_SELF)+" area:"+GetName(GetArea(OBJECT_SELF));
    SendMessageToAllDMs(sErrorMsg);
    // Players are given a water-downed error message.
    SendMessageToPC(oUser, sMsg);
    WriteTimestampedLogEntry(sErrorMsg);
}

// ****************************************************************************

string MSGetSkillName(object oUser, int iSkill)
{
    switch (iSkill)
    {
        case MS_SKILL_CLIMB: return "climb";
        case MS_SKILL_SWIM: return "swim";
        case MS_SKILL_TIGHT_SPACE: return "tight space";
        case MS_SKILL_JUMP: return "jump";
    }
    MSErrorMsg (oUser, "Skill "+IntToString(iSkill)+" was not recognized.");
    return "Unknown Skill";
}

// ****************************************************************************

object MSGetDestination(string sDestTag, int bKeepLooking = TRUE)
{
    object oDest = GetWaypointByTag(sDestTag);
    if (GetIsObjectValid(oDest) || !bKeepLooking)
        return oDest;

    oDest   = GetLocalObject(OBJECT_SELF, "MOVE_DESTINATION_OBJECT");
    if (GetIsObjectValid(oDest))
        return oDest;

    if(GetObjectType(OBJECT_SELF)==OBJECT_TYPE_DOOR)
        return OBJECT_SELF;

    // Try to find nearest object with the same tag.
    // sDestTag is the tag of the waypoint, so don't use it.
    oDest = GetNearestObjectByTag(GetTag(OBJECT_SELF));
    if (!GetIsObjectValid(oDest))
        // Destination was not found.
        return OBJECT_INVALID;

    float fDistance = GetDistanceBetween(OBJECT_SELF, oDest);
    if (fDistance>0.0 && fDistance<=MS_MAX_NO_WP_SEARCH_DISTANCE)
        return oDest;

    // Destination was not found.
    return OBJECT_INVALID;
}

// ****************************************************************************

int MSGetBonusRank(int nSkill, object oUser)
{
    int iBonus = 0;
    int iMonkLevel = 0;
    switch(nSkill)
    {
        case MS_SKILL_CLIMB:

            break;
        case MS_SKILL_SWIM:

            break;
        case MS_SKILL_TIGHT_SPACE:
            if(GetSkillRank(SKILL_TUMBLE, oUser,TRUE)>=5)
                iBonus += 2;
            break;
        case MS_SKILL_JUMP:
            if(GetSkillRank(SKILL_TUMBLE, oUser,TRUE)>=5)
                iBonus += 2;
            if(GetRacialType(oUser)==RACIAL_TYPE_HALFLING)
                iBonus += 2;
            break;
    }
    return iBonus;
}

// ****************************************************************************

int MSGetPenalty(int nSkill, object oUser)
{
    int iPenalty = 0;
    switch(nSkill)
    {
        case MS_SKILL_TIGHT_SPACE:
            // Size no longer matters. Tight space is relative to size of creature.
            //iPenalty = iPenalty - 10*GetCreatureSizeModifier(oUser);
            iPenalty = iPenalty + GetEncumbrancePenalty(oUser);
            break;
        case MS_SKILL_CLIMB:
            iPenalty = iPenalty + GetEncumbrancePenalty(oUser);
            break;
        case MS_SKILL_SWIM:
            // -1 penalty for every 5 lb
            // GetWeight returns the weight in lb * 10 (to handle fractional weights with an int).
            iPenalty = iPenalty - FloatToInt((GetWeight(oUser)/50.0)+0.001);
            break;
        case MS_SKILL_JUMP:
            // armor penalty is built in
            break;

    }
    return iPenalty;
}

// ****************************************************************************

int MSGetSkillRank(int nSkill, object oUser)
{
    int iRank, iRank1, iRank2, iRank3  = 0;

    // calculate bonus and penalty
    int iBonus      = MSGetBonusRank(nSkill, oUser);
    int iPenalty    = MSGetPenalty(nSkill, oUser);

    // use actual skill rank for climb, swim, escape artist
    if(nSkill == MS_SKILL_CLIMB)
        iRank   = GetSkillRank(SKILL_CLIMB, oUser);
    else if(nSkill == MS_SKILL_SWIM)
        iRank   = GetSkillRank(SKILL_SWIM, oUser);
    else if(nSkill == MS_SKILL_TIGHT_SPACE)
        iRank   = GetSkillRank(SKILL_ESCAPE_ARTIST, oUser);
    else if(nSkill == MS_SKILL_JUMP)
        iRank   = GetSkillRank(SKILL_JUMP, oUser);

    return (iRank+iBonus+iPenalty);
}

// ****************************************************************************

string MSGetDifficultyLevel(int iRank, int iDC)
{
    if (iRank >= iDC) return "a certain";
    else if (iRank+5 >= iDC) return "an easy";
    else if (iRank+10 >= iDC) return "an average";
    else if (iRank+15 >= iDC) return "a difficult";
    else if (iRank+20 >= iDC) return "a very difficult";
    return "an impossible";
}

// ****************************************************************************

string MSGetAngleBetween(object oDestination, object oUser)
{
    if(GetArea(oUser)!=GetArea(oDestination))
        return "";
    float fAngle = VectorToAngle(GetPosition(oDestination)-GetPosition(oUser));
    AssignCommand(oUser, SetFacing(fAngle));
    switch (FloatToInt(fAngle / 45))
    {
        // 0 degrees
        case 0: return "east";
        // 45 degrees
        case 1: return "north east";
        // 90 degrees
        case 2: return "north";
        // 135 degrees
        case 3: return "north west";
        // 180 degrees
        case 4: return "west";
        // 225 degrees
        case 5: return "south west";
        // 270 degrees
        case 6: return "south";
        // 315 degrees
        case 7: return "south east";
        // 360 degrees
        case 8: return "east";
    }
    return "";
}

// ****************************************************************************

void MSUserDoActionClimb(location lDestination, float fZDistance)
{
    float fDuration = 3.0 + fabs (((fZDistance - 1.0) * 2.0) / GetAnimationScale() );

    PlayAnimation (ANIMATION_WALL_CLIMB, 1.0, fDuration);
    DelayCommand (fDuration - 0.01, JumpToLocation(lDestination));
}

//// Wrapper function to add the action to the queue.
void MSUserClimbs(location lDestination)
{
    float fZChange = GetZChange( GetPositionFromLocation(lDestination), GetPosition(OBJECT_SELF) );

    ActionDoCommand( MSUserDoActionClimb(lDestination, fZChange) );
}



void DoJumpDown (location lTarget, float fDistance)
{
 // initial fDistance needs to be positive.
 fDistance = fabs (fDistance) - 1.0;

 float fMod = GetFallTime (fDistance);

 float fDuration = 2.0 + fMod;
 float fSpeed = (2.0 + GetFallTime (fDistance / GetAnimationScale() ) ) / fDuration;

 PlayAnimation (ANIMATION_JUMP_DOWN, fSpeed, fDuration);
 DelayCommand (fDuration - 0.01, JumpToLocation (lTarget));
}

void DoLongJump (location lTarget, float fDistance)
{
 // initial fDistance needs to be positive.
 fDistance = fabs (fDistance) - 3.0;

 float fDuration = 2.0 + (fDistance / 2.0);
 float fSpeed = (2.0 + (fDistance / 2.0) / GetAnimationScale() ) / fDuration;

 PlayAnimation (ANIMATION_LONG_JUMP, fSpeed, fDuration);
 DelayCommand (fDuration - 0.01, JumpToLocation (lTarget));
}

//// Wrapper function to add the action to the queue.
//// Also determines animation to use.
void ActionJump (object oTarget, location lTarget)
{
    vector vTarget = GetPositionFromLocation(lTarget);
    vector vSource = GetPosition (oTarget);

    float fZChange = GetZChange (vTarget, vSource);
    float fXYChange = GetXYChange (vTarget, vSource);

    if(fabs (fZChange) > fXYChange) // If falling further than jumping, use fall animation.
    {
        AssignCommand (oTarget, ActionDoCommand (DoJumpDown (lTarget, fZChange)));
    }
    else
    {
        AssignCommand (oTarget, ActionDoCommand (DoLongJump (lTarget, fXYChange)));
    }
}


//// returns the animation scale for that appearance number.
//// returns 1.0f if no match is present.
float GetAnimationScale(object oTarget = OBJECT_SELF)
{
 float fScale = 1.0;

 if (GetGender (oTarget) == GENDER_FEMALE)
    {
     switch (GetAppearanceType(oTarget))
        {
         case APPEARANCE_TYPE_DWARF: fScale = 0.65; break;
         case APPEARANCE_TYPE_ELF: fScale = 0.894; break;
         case APPEARANCE_TYPE_GNOME:
         case APPEARANCE_TYPE_HALFLING: fScale = 0.64; break;

         // The 1.0 races aren't really needed, since it's 1.0 already anyways.
         /*
         case APPEARANCE_TYPE_HALF_ELF:
         case APPEARANCE_TYPE_HALF_ORC:
         case APPEARANCE_TYPE_HUMAN: fScale = 1.0; break;
         */
        }
    }
 else
    {
     switch (GetAppearanceType(oTarget))
        {
         case APPEARANCE_TYPE_DWARF: fScale = 0.66; break;
         case APPEARANCE_TYPE_ELF: fScale = 0.895; break;
         case APPEARANCE_TYPE_GNOME: fScale = 0.62; break;
         case APPEARANCE_TYPE_HALFLING: fScale = 0.65; break;

         // The 1.0 races aren't really needed, since it's 1.0 already anyways.
         /*
         case APPEARANCE_TYPE_HALF_ELF:
         case APPEARANCE_TYPE_HALF_ORC:
         case APPEARANCE_TYPE_HUMAN: fScale = 1.0; break;
         */
        }
    }
 return fScale;
}

//// Moved to its own routine so I can compare the animation scale modified distance
//// to determine animation speed change.
float GetFallTime (float fDistance)
{
 float fTime;
// There's likely a formula, but I can't think of one offhand.
 if      (fDistance >= 20.0) fTime = 4.0 + ((fDistance - 20.0) / 10.0);
 else if (fDistance >= 12.0) fTime = 3.0 + ((fDistance - 12.0) / 8.0);
 else if (fDistance >= 6.0)  fTime = 2.0 + ((fDistance - 6.0)  / 6.0);
 else if (fDistance >= 2.0)  fTime = 1.0 + ((fDistance - 2.0)  / 4.0);
 else                        fTime =         fDistance / 2.0;

 return fTime;
}

//// Gets the height difference between two vectors.
float GetZChange (vector vTarget, vector vSource)
{
 return vTarget.z - vSource.z;
}

//// Gets the XY axis distance between two vectors.
float GetXYChange (vector vTarget, vector vSource)
{
 return sqrt (pow (fabs(vTarget.x - vSource.x), 2.0) + pow(fabs(vTarget.y - vSource.y), 2.0));
}


struct MOVESKILL MSInitialize(object oUser)
{
    struct MOVESKILL Move;
    string sDest        = GetLocalString(OBJECT_SELF, "MOVE_DESTINATION");
    Move.destination    = MSGetDestination(sDest);
    string sFail        = GetLocalString( OBJECT_SELF, "MOVE_FAIL");
    if(sFail!="")
        Move.failDestination= MSGetDestination(sFail);

    Move.self           = OBJECT_SELF;
    Move.skillPrime     = GetLocalInt(OBJECT_SELF, "MOVE_SKILL");
    Move.skillOverride  = GetLocalInt(oUser, "MOVE_SKILL_OVERRIDE");
    Move.DC             = GetLocalInt(OBJECT_SELF, "MOVE_DC");
    Move.fromTop        = GetLocalInt(OBJECT_SELF, "MOVE_TOP");
    Move.height         = GetLocalInt(OBJECT_SELF, "MOVE_HEIGHT");
    Move.failHeight     = GetLocalInt(OBJECT_SELF, "MOVE_FAIL_HEIGHT");
    Move.distance       = GetLocalInt(OBJECT_SELF, "MOVE_DISTANCE");
    Move.maxSize        = GetLocalInt(OBJECT_SELF, "MOVE_SIZE");

    Move.isRoped        = GetLocalInt(OBJECT_SELF, "ROPED");
    Move.ropeLength     = GetLocalInt(OBJECT_SELF, "ROPE_LENGTH");
    Move.ropeMagic      = GetLocalInt(OBJECT_SELF, "ROPE_MAGIC");
    Move.isSubmerged    = GetLocalInt(OBJECT_SELF, "MOVE_SUBMERGED");
    Move.isFall         = GetLocalInt(OBJECT_SELF, "MOVE_FALL");
    Move.isVertJump     = GetLocalInt(OBJECT_SELF, "MOVE_VERTICAL");
    if(Move.skillOverride)
    {
        Move.skill  = Move.skillOverride;
        // If illogical, the isSuccessful goes to -2

        // PRIME MOVE CLIMB
        if(Move.skillPrime==MS_SKILL_CLIMB)
        {
          // this is a sink hole or some other situation where you free fall
          if(Move.isFall)
          {
            if(Move.skill==MS_SKILL_JUMP)
            {
                // chance to reduce fall
                // and jump is down rather than a long jump
                Move.isVertJump = TRUE;
            }
            else if(Move.skill==MS_SKILL_TIGHT_SPACE)
            {
                // reduce fall by height of character
                Move.height = Move.height - StringToInt(Get2DAString("appearance","HEIGHT",GetAppearanceType(oUser)));
            }
          }
          else if(Move.isSubmerged)
          {
            if(Move.skill==MS_SKILL_SWIM)
                // normal swim
                Move.DC = 10;
          }
          else if(Move.fromTop)
          {
            if(Move.skill==MS_SKILL_JUMP)
            {
                // controlled drop in which height is reduced.
                Move.isFall = TRUE;
                Move.isVertJump = TRUE;
                // and jump is down rather than a long jump
            }
          }
          else
          {
            if(Move.skill==MS_SKILL_JUMP)
            {
                //unlikely to succeed. need to check height
                Move.isVertJump = TRUE;
                // not a long jump or jump down
            }
            else
                Move.isSuccessful   = -2; // illogical
          }
        }
        // PRIME MOVE SWIM
        else if(Move.skillPrime==MS_SKILL_SWIM)
        {
            if(Move.skill==MS_SKILL_CLIMB)
            {
                Move.isSuccessful   = -2; // illogical
            }
            else if(Move.skill==MS_SKILL_TIGHT_SPACE)
            {
                if(Move.isSubmerged)
                    Move.skill  = MS_SKILL_SWIM; // proceed as if swimming
                else
                    Move.isSuccessful   = -1; // proceed to fail destination if there is one
            }
            else if(Move.skill==MS_SKILL_JUMP)
            {
                if(Move.isSubmerged)
                    Move.isSuccessful   = -2; // illogical
                else
                    Move.isSuccessful   = -1; // proceed to fail destination if there is one
            }
        }
        // PRIME MOVE TIGHT SPACE
        else if(Move.skillPrime==MS_SKILL_TIGHT_SPACE)
        {
            if(     Move.skill==MS_SKILL_CLIMB
                ||  (Move.skill==MS_SKILL_SWIM && Move.isSubmerged)
              )
            {
                // proceed as a tight-space
                Move.skill  = MS_SKILL_TIGHT_SPACE;
            }
            else
            {
                Move.isSuccessful   = -2; // illogical
            }
        }
        // PRIME MOVE JUMP
        else if(Move.skillPrime==MS_SKILL_JUMP)
        {
            if(Move.skill==MS_SKILL_CLIMB || Move.skill==MS_SKILL_TIGHT_SPACE)
            {
                if(GetIsObjectValid(Move.failDestination))
                {
                    Move.destination    = Move.failDestination;
                    if(Move.failHeight)
                        Move.height     = Move.failHeight;
                    else if(GetArea(Move.destination)==GetArea(OBJECT_SELF))
                    {
                        vector vDist    = GetPosition(OBJECT_SELF)-GetPosition(Move.destination);
                        Move.height    = abs(FloatToInt(vDist.z));
                    }
                    else
                        Move.height = 10;
                    if(Move.skill==MS_SKILL_TIGHT_SPACE)
                        Move.isFall         = TRUE;

                    Move.DC             = 15+d10();
                }
                else
                    Move.isSuccessful   = -1;
            }
            else
            {
                Move.isSuccessful   = -2; // illogical
            }
        }

    }
    else
        Move.skill      = Move.skillPrime;

    // default
    if(!Move.skill)
        Move.skill      = MS_SKILL_CLIMB;


    if(     Move.skill==MS_SKILL_CLIMB
        &&  Move.DC>5
        &&  Move.isRoped
        &&  CreatureGetHasHands(oUser)
      )
        Move.DC         = 5;

    return Move;
}

struct MOVESKILL MSGetAutomaticResults(struct MOVESKILL Move, object oUser)
{
    int nCreatureSize   = GetCreatureSize(oUser); // any challenge can be failed if you are too big
    // universal results for all challenges
    if(GetIsDM(oUser))
    {
        Move.type               = 1;
        Move.isSuccessful       = 1;
        Move.describeResults    = "For the DM, it ";
    }
    else if(Move.isSuccessful==-2)
    {
        Move.type               = -1;
        Move.describeResults    = "This move ";
    }
    else if(    Move.isSubmerged
            &&  GetHasSpellEffect(SPELL_GASEOUS_FORM,oUser)
           )
    {
        Move.type               = 1;
        Move.isSuccessful       = -1;
        Move.describeResults    = "While in gaseous form, it ";
    }
    else if(GetCreatureFlag(oUser, CREATURE_VAR_IS_INCORPOREAL))
    {
        Move.type               = 3;
        Move.isSuccessful       = 1;
        Move.describeResults    = "For an incorporeal creature, it ";
    }
    else if(    GetHasEffect(EFFECT_TYPE_PARALYZE, oUser)
            ||  GetHasEffect(EFFECT_TYPE_PETRIFY, oUser)
            ||  GetHasEffect(EFFECT_TYPE_STUNNED, oUser)
            ||  GetHasEffect(EFFECT_TYPE_ENTANGLE, oUser)
           )
    {
        Move.type               = -1;
        Move.isSuccessful       = -1;
        Move.describeResults    = "For an immobile creature, it ";
    }
    else if(Move.maxSize && nCreatureSize>Move.maxSize)
    {
        Move.isSuccessful       = -1;
        Move.describeResults    = "For someone of your size, it ";
    }
    // results by required skill
    else if(Move.skill==MS_SKILL_CLIMB)
    {
        if( CreatureGetIsFlier(oUser, TRUE) )
        {
            Move.type               = 2;
            Move.isSuccessful       = 1;
            Move.describeResults    = "For a flying creature, it ";
        }
        else if(GetHasFeat(FEAT_SPIDER_CLIMB, oUser)) //spider climb feat
        {
            Move.isSuccessful       = 1;
            Move.describeResults    = "With the ability to climb like a spider, it ";
            if(CreatureGetIsSpider(oUser))
                Move.type           = 2;
            else
                Move.type           = 1;
        }
    }
    else if(Move.skill==MS_SKILL_SWIM)
    {
        if( CreatureGetIsAquatic(oUser) )
        {
            Move.type               = 1;
            Move.isSuccessful       = 1;
            Move.describeResults    = "For an aquatic creature, it ";
        }
        else if( !Move.isSubmerged )
        {
            if( CreatureGetIsFlier(oUser, TRUE) )
            {
                Move.type               = 2;
                Move.isSuccessful       = 1;
                Move.describeResults    = "For a flying creature, it ";
            }
            else if( GetHasFeat(FEAT_SPIDER_CLIMB, oUser) && GetIsAreaInterior(GetArea(OBJECT_SELF)) )
            {
                Move.type               = 2;
                Move.isSuccessful       = 1;
                Move.describeResults    = "With the ability to climb across the ceiling, it ";
            }
        }

    }
    else if(Move.skill==MS_SKILL_TIGHT_SPACE)
    {
        if(nCreatureSize<Move.maxSize)
        {
            Move.type               = 1;
            Move.isSuccessful       = 1;
            Move.describeResults    = "For someone of your size, it ";
        }
        else if( CreatureGetIsSoftBodied(oUser) )
        {
            Move.type               = 4;
            Move.isSuccessful       = 1;
            Move.describeResults    = "For a soft body, it ";
        }
        else if(GetHasFeat(FEAT_PASS_DOOR,oUser))
        {
            Move.type               = 4;
            Move.isSuccessful       = 1;
            Move.describeResults    = "For someone with your flexibility, it ";
        }
        // unnecessary because we check this for all moves
        /*
        else if(nCreatureSize>Move.maxSize)
        {
            Move.isSuccessful       = -1;
            Move.describeResults    = "For someone of your size, it ";
        }
        */
    }
    else if(Move.skill==MS_SKILL_JUMP)
    {
        if( CreatureGetIsFlier(oUser, TRUE) )
        {
            Move.type               = 2;
            Move.isSuccessful       = 1;
            Move.describeResults    = "For a flying creature, it ";
        }
        else if( GetHasFeat(FEAT_SPIDER_CLIMB, oUser) && GetIsAreaInterior(GetArea(OBJECT_SELF)) )
        {
            Move.type               = 2;
            Move.isSuccessful       = 1;
            Move.describeResults    = "With the ability to climb across the ceiling, it ";
        }
        else
        {
            struct JUMP Jump    = GetJump(oUser,FALSE);
            if(Move.isVertJump)
            {
                if(Move.height && Move.height<=FloatToInt(Jump.min))
                {
                    Move.type               = 1;
                    Move.isSuccessful       = 1;
                }
                else if(Move.height && Jump.max!=0.0 && Move.height>FloatToInt(Jump.max))
                    Move.isSuccessful       = -1;
            }
            else if(Move.distance && Move.distance<=FloatToInt(Jump.min))
            {
                Move.type               = 1;
                Move.isSuccessful       = 1;
            }
            else if(Move.distance && Jump.max!=0.0 && Move.distance>FloatToInt(Jump.max))
                Move.isSuccessful       = -1;
            if(Move.isSuccessful)
                Move.describeResults    = "At this distance, it ";
        }
    }

    return Move;
}

object MSGetUser()
{
    // this script can be called via executeScript from AID
    object oUser  = GetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    DeleteLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    // if not executed by AID determine traditional use of object
    if(oUser==OBJECT_INVALID)
    {
        /*  // only blueprints we have so far are placeables
            // use the commented out code when we implement a trigger
        if (GetObjectType(OBJECT_SELF)==OBJECT_TYPE_TRIGGER)
            oUser     = GetClickingObject();
        else
        */
            oUser     = GetLastUsedBy();
    }

    return oUser;
}

int MSGetUserClicks(object oUser)
{
    string sPlayer  = GetPCPlayerName(oUser);

    // is this the first time the user has clicked this object recently?
    if(!GetLocalInt(OBJECT_SELF, sPlayer))
    {
        DelayCommand(MS_CLICK_TIMEOUT_SEC, DeleteLocalInt(OBJECT_SELF, sPlayer) );
        SetLocalInt(OBJECT_SELF, sPlayer, TRUE);
        return 1; // the first click triggers a description of the move
    }
    else
    {
        // how many clicks in the last 6 seconds since the first one?
        int nUserClicks = GetLocalInt(OBJECT_SELF, sPlayer+"_CLICKS")+1;
        SetLocalInt(OBJECT_SELF, sPlayer+"_CLICKS", nUserClicks);

        if(nUserClicks==1)
        {
            DelayCommand(MS_REFRACTORY_PERIOD, DeleteLocalInt(OBJECT_SELF, sPlayer+"_CLICKS") );

            // Keep track of how many times they have attempted the move. This is used for "take 20" rules.
            int iAttempt = GetLocalInt(OBJECT_SELF, sPlayer+"_ATTEMPT");
            if(!iAttempt)
                DelayCommand(MS_CLICK_TIMEOUT_SEC, DeleteLocalInt(OBJECT_SELF, sPlayer+"_ATTEMPT") );
            SetLocalInt(OBJECT_SELF, sPlayer+"_ATTEMPT", iAttempt+1);

            return 2; // this is the second click, and the one we will act on
        }
        else
        {
            return 3; // we will ignore this click
        }
    }
}

void MSDescribeMove(object oUser)
{
    struct MOVESKILL Move = MSInitialize(oUser);

    if (!GetIsObjectValid(Move.destination))
    {
        MSErrorMsg(oUser, "Destination could not be found.");
        return;
    }

    Move  = MSGetAutomaticResults(Move, oUser);
    string sReason  = Move.describeResults;
    if(sReason=="")
        sReason     = "It ";

    // Determine difficulty
    string sDifficulty;
    if(Move.isSuccessful>0)
        sDifficulty = "a certain";
    else if(Move.isSuccessful==-2)
        sDifficulty = "it is not a";
    else if(Move.isSuccessful<0)
        sDifficulty = "an impossible";
    else
        sDifficulty  = MSGetDifficultyLevel(MSGetSkillRank(Move.skill, oUser), Move.DC);

    string sSkillName   = MSGetSkillName(oUser, Move.skill);

    // direction of the move
    string sDir         = MSGetAngleBetween(Move.destination, oUser);
    if(Move.isSuccessful==-2)
           sDir         = "";
    else if(sDir!="")
           sDir         = " heading "+sDir;

    // DESCRIPTION OUTPUT
    // name of the object/move
    FloatingTextStringOnCreature(GREEN+GetName(OBJECT_SELF), oUser, FALSE);
    // description
    FloatingTextStringOnCreature(LIME+sReason+"looks like "+sDifficulty+" "+sSkillName+sDir+".", oUser, FALSE);
    // what to do
    FloatingTextStringOnCreature(LIME+"CLICK AGAIN TO MOVE", oUser, FALSE);
}

void MSAttemptMove(object oUser)
{
    struct MOVESKILL Move = MSInitialize(oUser);

    if (!GetIsObjectValid(Move.destination))
    {
        MSErrorMsg(oUser, "Destination could not be found.");
        return;
    }

    AssignCommand(oUser, ClearAllActions(TRUE));

    string sSkillName   = MSGetSkillName(oUser, Move.skill);
    string sRoll, sDifficulty;
    // determine whether success or failure is known prior to conducting a skill check
    // eg: a flying creature automatically succeeds at climbing
    Move  = MSGetAutomaticResults(Move, oUser);

    // Is movement impossible?
    if(Move.type==-1)
    {
        SendMessageToPC(oUser, RED+"You are unable to proceed.");
        return;
    }
    // Automatic success
    else if(Move.isSuccessful==1)
    {
        sDifficulty = "a certain ";
    }
    // Automatic failure
    else if(Move.isSuccessful==-1)
    {
        sDifficulty = "an impossible ";
    }
    // need to attempt skill check?
    else if(Move.isSuccessful==0)
    {
        // roll the dice
        int iRoll   = d20();
        // Only allow players to take 20 if they are out of combat and they could not be damaged by the task.
        if(     !GetIsInCombat(oUser)
            && (!Move.height || !Move.fromTop)
        )
        {
            switch(GetLocalInt(OBJECT_SELF, GetPCPlayerName(oUser)+"_ATTEMPT"))
            {
                case 1:
                    if(iRoll<5) iRoll=5;
                break;
                case 2:
                    if(iRoll<10) iRoll=10;
                break;
                default:
                    iRoll=20;
                break;
            }
        }

        // Determine PC's level of skill (iRank)
        int iRank   = MSGetSkillRank(Move.skill, oUser);

        // SKILL CHECK CONDUCTED
        Move.isSuccessful=(iRank+iRoll)>=Move.DC;
        // -------------------------------------

        // FEEDBACK FOR THE SKILL CHECK ----------------------------------------
        sRoll        = CYAN+IntToString(iRoll)+"+"+IntToString(iRank)+"="+IntToString(iRank+iRoll)+" vs DC="+IntToString(Move.DC);
        sDifficulty  = MSGetDifficultyLevel(iRank, Move.DC);
    }

    // --- SUCCESS FEEDBACK ---
    if(Move.isSuccessful>0)
    {
        // Let the player know what they rolled.
        if(sRoll!="")
            DelayCommand(2.0, FloatingTextStringOnCreature(DMBLUE+"*"+GetStringUpperCase(sSkillName)+" SUCCESS* "+sRoll, oUser, FALSE) );
        // Make the nearby people aware of the result. In playtesting the players liked this feature.
        AssignCommand(oUser, DelayCommand(2.0, SpeakString("*SUCCESS* on "+sDifficulty+" "+sSkillName)) );

/*     // reward xp for skill use?
      int last    = GetLocalInt(oUser, "XP_MOVE_LAST");
      int now     = GetTimeCumulative();
      if(   MSGetSkillRank(Move.skill, oUser)<Move.DC         // ensure that there was some challenge or use of resources
        &&  (!last||  (now-last)>(GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")*7)) // only give XP every 7 RL minutes for move skill
        )
      {
        SetLocalInt(oUser, "XP_MOVE_LAST", now);

        // reward XP for skilluse
        string sRewardTag   = TAG_SKILL+"MOVE_"+GetLocalString(OBJECT_SELF,"MOVE_DESTINATION");
        int nXPReward   = Move.DC*7;

        // XPRewardByType handles the declining reward based on count.
        DelayCommand(2.1, XPRewardByType( sRewardTag, oUser, nXPReward, XP_TYPE_ABILITY) );
      }
      */
    }
    // --- FAILURE FEEDBACK ---
    else
    {
        // special description for failure
        string sFailMsg    = GetLocalString( OBJECT_SELF, "MOVE_FAIL_DESCRIPTION");
        if(sFailMsg!="")
        {
            int nPos1, nPos2, nLen;
            string sBefore, sAfter;
            nPos1   = FindSubString( sFailMsg, "(pc)" );
            if(nPos1!=-1)
            {
                nPos2   = nPos1+4;
                sBefore = GetStringLeft(sFailMsg, nPos1);
                sAfter  = GetStringRight(sFailMsg, GetStringLength(sFailMsg)-nPos2);
                sFailMsg= LIME+sBefore+GREEN+GetName(oUser)+LIME+sAfter;
            }
            else
                sFailMsg= LIME+sFailMsg;
            SpeakString(sFailMsg);
        }
        // Let the player know what they rolled.
        if(sRoll!="")
            DelayCommand(2.0, FloatingTextStringOnCreature(RED+"*"+GetStringUpperCase(sSkillName)+" FAILURE* "+sRoll, oUser, FALSE) );
        // Make the nearby people aware of the result. In playtesting the players liked this feature.
        AssignCommand(oUser, DelayCommand(2.0, SpeakString("*FAILURE* on "+sDifficulty+" "+sSkillName)) );
    }

    // CONDUCT MOVEMENT --------------------------------------------------------
    if(GetArea(OBJECT_SELF)==GetArea(Move.destination))
    {
        AssignCommand(  oUser,
                        SetFacing( VectorToAngle(GetPosition(Move.destination)-GetPosition(OBJECT_SELF)) )
                    );
    }
    else
    {
        TurnToFaceObject(OBJECT_SELF, oUser);
    }
    AssignCommand(oUser, MSUserMoves(Move));
}

void MSUserMoves(struct MOVESKILL Move)
{
    float fDelay        = 1.1;
    object oDest        = Move.destination;
    if(oDest==Move.self && GetObjectType(Move.self)==OBJECT_TYPE_DOOR)
    {
        oDest   = GetTransitionTarget(Move.self);
        if(GetIsObjectValid(oDest))
        {
            vector vNewPos;
            float fFace = GetFacing(oDest);
            if (fFace<180.0)
                fFace=fFace+179.9;
            else
                fFace=fFace-179.9;
            vNewPos = GetPosition(oDest) +  AngleToVector(fFace);
            location lPastDoor = Location(
                                    GetArea(oDest),
                                    vNewPos,
                                    fFace
                                );
            oDest   = CreateObject(OBJECT_TYPE_WAYPOINT,"nw_waypoint001",lPastDoor);
        }
        else
        {
            vector vDoor        = GetPosition(Move.self);
            vector vDoorFromUser= vDoor-GetPosition(OBJECT_SELF);
            location lPastDoor  = Location( GetArea(OBJECT_SELF),
                                            vDoor + VectorNormalize(vDoorFromUser),
                                            VectorToAngle(vDoorFromUser)
                                          );
            oDest   = CreateObject(OBJECT_TYPE_WAYPOINT,"nw_waypoint001",lPastDoor);
        }

        DestroyObject(oDest,12.0);
    }

    string sMoveSkill   = MSGetSkillName(OBJECT_SELF, Move.skill);
    // Modify Destination for Failed Move
    if(Move.isSuccessful<1)
    {
        if(Move.failDestination!=OBJECT_INVALID)
        {
            oDest   = Move.failDestination;
        }
        else if(    !Move.fromTop
                &&  !Move.isFall
               )
        {
            oDest   = OBJECT_INVALID;

        }
    }



    // Move.type
    // 1 - normal animations
    // 2 - disappear/appear (looks like flying or a spider climbs)
    // 3 - fade/appear (incorporeal style)
    // 4 - similar to passdoor

    // Flying and Spider Climbing
    if(Move.type==2)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                            EffectDisappearAppear(GetLocation(oDest)),
                            OBJECT_SELF,
                            3.0
                           );
        DelayCommand(3.1, MSSendCompanions(OBJECT_SELF, oDest, sMoveSkill) );
        return;
    }
    // incorporeal
    else if(Move.type==3)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                            EffectVisualEffect(VFX_DUR_GHOST_SMOKE_2),
                            OBJECT_SELF,
                            0.5
                           );
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                            EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY),
                            OBJECT_SELF,
                            2.0
                           );

        DelayCommand(1.0, JumpToObject(oDest));
        DelayCommand(1.1, MSSendCompanions(OBJECT_SELF, oDest, sMoveSkill) );
        return;
    }
    // normal skill use
    else if(Move.skill==MS_SKILL_CLIMB)
    {
        // unequip items in hands
        ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_LEFTHAND));
        ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));

        Move.failHeight = Move.height;
        // CLIMB ANIMATIONS ------------------------------------------
        // sometimes the climb requires a fall (sink hole)
        if(     Move.isFall
            &&  (!Move.isRoped || Move.height>(GetCreatureHeight(OBJECT_SELF,TRUE)+Move.ropeLength))
          )
        {
            ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, fDelay);
            DelayCommand(0.1, PlaySound("fs_dirt_hard1"));
            DelayCommand(fDelay-0.2, PlaySound("fs_dirt_hard2"));
            DelayCommand(fDelay-0.1, PlaySound("fs_dirt_hard3"));

            if(CreatureGetHasHands(OBJECT_SELF))
                Move.failHeight = Move.height - Move.ropeLength;
        }
        // climbing between nodes in same area
        else if( GetArea(Move.destination)==GetArea(OBJECT_SELF) )
        {
            float fZDiff    = GetZChange(GetPosition(Move.destination), GetPosition(OBJECT_SELF));

            // climbing up
            if(fZDiff>0.0)
            {
                //MSUserDoActionClimb(GetLocation(Move.destination), fZDiff);
                fDelay = 3.0 + fabs( ((fZDiff - 1.0) * 2.0) / GetAnimationScale() );
                ActionPlayAnimation(ANIMATION_WALL_CLIMB, 1.0, fDelay-0.01);
            }
            // climbing down
            else
            {
                ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, fDelay);
                DelayCommand(0.1, PlaySound("fs_dirt_hard1"));
                DelayCommand(fDelay-0.2, PlaySound("fs_dirt_hard2"));
                DelayCommand(fDelay-0.1, PlaySound("fs_dirt_hard3"));
            }
        }
        else
        {
            ActionPlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL, 1.0, fDelay);
            DelayCommand(0.1, PlaySound("fs_dirt_hard1"));
            DelayCommand(fDelay-0.2, PlaySound("fs_dirt_hard2"));
            DelayCommand(fDelay-0.1, PlaySound("fs_dirt_hard3"));
        }

        // Failure Results (movement happens later
        if( Move.isSuccessful<1
            || (    Move.isFall
                &&  (!Move.isRoped || Move.height>(GetCreatureHeight(OBJECT_SELF)+Move.ropeLength))
               )
          )
        {
            DelayCommand(fDelay+0.1, ActionDoCommand(MSUserComplains()) );
            DelayCommand(fDelay+0.1, ActionDoCommand(MSUserFalls(Move.fromTop, Move.failHeight, Move.isRoped)) );
        }
    }
    else if(Move.skill==MS_SKILL_SWIM)
    {
        fDelay = 1.3;

        object oLeft    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
        object oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        if(!GetCanSwimWith(oLeft))
            ActionUnequipItem(oLeft);
        if(!GetCanSwimWith(oRight))
            ActionUnequipItem(oRight);

        DelayCommand(0.1, PlaySound("fs_water_large3"));
        DelayCommand(0.3, ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK));
        DelayCommand(0.5, PlaySound("as_na_splash2"));
        DelayCommand(fDelay-0.3, PlaySound("as_na_splash1"));
        DelayCommand(fDelay+0.3, PlaySound("fs_water_hard1"));

        // Failure Results (movement happens below
        if(Move.isSuccessful<1)
        {
            DelayCommand(fDelay+0.1, ActionDoCommand(MSUserComplains()));
            DelayCommand(fDelay+0.1, ActionDoCommand(SwimFailure(FALSE)));
        }
    }
    else if(Move.skill==MS_SKILL_TIGHT_SPACE)
    {
        fDelay  = 1.0;

        //PlaySound("as_cv_brickscrp1");
        ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM10);

        // Failure Results (movement happens below
        if(Move.isSuccessful<1)
        {
            int nAnim;
            if (Random(2))
                nAnim   = ANIMATION_LOOPING_CUSTOM10;
            else
            {
                nAnim   = ANIMATION_LOOPING_SPASM;
            }

            DelayCommand(fDelay+0.1, ActionDoCommand(MSUserComplains()));
            DelayCommand(fDelay+0.1, ActionPlayAnimation(nAnim, 1.0, 2.0));
            DelayCommand(fDelay+0.2, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectParalyze(), OBJECT_SELF, 2.0) );
        }
    }
    else if(Move.skill==MS_SKILL_JUMP)
    {
        fDelay  = 1.0;

        //PlaySound("as_cv_brickscrp1");
        if( GetArea(Move.destination)==GetArea(OBJECT_SELF) )
        {
            vector vTarget = GetPosition(Move.destination);
            vector vSource = GetPosition (OBJECT_SELF);

            // initial fDistance needs to be positive.
            float fDistance = fabs (GetXYChange (vTarget, vSource)) - 3.0;

            fDelay = 2.0 + (fDistance / 2.0);
            float fSpeed = (2.0 + (fDistance / 2.0) / GetAnimationScale() ) / fDelay;

            PlayAnimation (ANIMATION_LONG_JUMP, fSpeed, fDelay);
        }
        else
        {
            ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK, 1.0, fDelay);
            DelayCommand(0.1, PlaySound("fs_dirt_hard1"));
            DelayCommand(fDelay-0.2, PlaySound("fs_dirt_hard2"));
            DelayCommand(fDelay-0.1, PlaySound("fs_dirt_hard3"));
        }
        // Failure Results (movement happens below
        if(Move.isSuccessful<1)
        {
            int nAnim;
            if (Random(2))
                nAnim   = ANIMATION_LOOPING_GET_LOW;
            else
            {
                nAnim   = ANIMATION_LOOPING_SPASM;
            }

            DelayCommand(fDelay+0.1, ActionDoCommand(MSUserComplains()));
            DelayCommand(fDelay+0.1, ActionDoCommand(MSUserJFalls(Move.fromTop, Move.failHeight, Move.isRoped)) );
            //DelayCommand(fDelay+0.1, ActionPlayAnimation(nAnim, 1.0, 12.0));
            //DelayCommand(fDelay+0.2, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectParalyze(), OBJECT_SELF, 8.0) );
            //SendMessageToPC(OBJECT_SELF, "You get paralyzed");
        }
    }

    // JUMP TO DESTINATION
    if(oDest!=OBJECT_INVALID)
    {
        DelayCommand(fDelay+0.1, MSSendCompanions(OBJECT_SELF, oDest,sMoveSkill) );
        DelayCommand(fDelay, JumpToObject(oDest));
    }
}

void MSSendCompanions(object oUser, object oDest, string sMoveType)
{
    object oNPC;
    int nType = 2; int nTh; int nSize;
    // loop through all Associates of OBJECT_SELF/oUser
    for (nType = 1; nType<=5; nType++)
    {
        nTh = 1;
        oNPC = GetAssociate(nType, oUser, nTh);
        while (GetIsObjectValid(oNPC))
        {
            nSize   = GetCreatureSize(oNPC);
            if(     GetCreatureFlag(oNPC, CREATURE_VAR_IS_INCORPOREAL)
                ||  nSize<GetCreatureSize(oUser)
              )
                MSSendCreature(oNPC, oDest);
            else if(     sMoveType=="climb"
                    &&(     GetHasFeat(FEAT_SPIDER_CLIMB,oNPC)
                        ||  GetHasFeat(FEAT_FLIGHT,oNPC)
                      )
              )
                MSSendCreature(oNPC, oDest);
            else if(sMoveType=="swim"
                    &&(     (GetHasFeat(FEAT_FLIGHT,oNPC)&&!GetLocalInt(OBJECT_SELF,"MOVE_SUBMERGED"))
                        ||  CreatureGetIsAquatic(oNPC)
                      )
                   )
                MSSendCreature(oNPC, oDest);
            else if(sMoveType=="tight space"
                    &&(     nSize<=GetLocalInt(OBJECT_SELF,"MOVE_SIZE")
                        ||  GetHasFeat(FEAT_PASS_DOOR, oNPC)
                        ||  CreatureGetIsSoftBodied(oNPC)
                      )
                    )
                MSSendCreature(oNPC, oDest);


            oNPC = GetAssociate(nType, oUser, ++nTh);
        }
    }
}

void MSSendCreature(object oCreature, object oDest)
{
    if(oCreature != OBJECT_INVALID)
    {
        AssignCommand(oCreature, ClearAllActions());
        AssignCommand(oCreature, ActionJumpToObject(oDest,FALSE));
    }
}

// -- failure reuslts --------------
void MSUserComplains()
{
//SendMessageToPC(OBJECT_SELF, "UserComplains!");
    int iVoice = VOICE_CHAT_CANTDO;
    switch (Random(8))
    {
        case 0: iVoice = VOICE_CHAT_BADIDEA; break;
        case 1: iVoice = VOICE_CHAT_CANTDO; break;
        case 2: iVoice = VOICE_CHAT_CUSS; break;
        case 3: iVoice = VOICE_CHAT_LAUGH; break;
        case 4: iVoice = VOICE_CHAT_NO; break;
        case 5: iVoice = VOICE_CHAT_PAIN1; break;
        case 6: iVoice = VOICE_CHAT_PAIN2; break;
        case 7: iVoice = VOICE_CHAT_PAIN3; break;
    }
    PlayVoiceChat(iVoice);
}

void MSUserJFalls(int bTop, int nHeight, int bRoped)
{

        int rFall;

    if(GetHasSpellEffect(SPELL_FEATHER_FALL))
        {
            nHeight = 0;
            FloatingTextStringOnCreature(GREEN+GetName(OBJECT_SELF)+LIME+" floats gently to the ground.", OBJECT_SELF);
        }
    else if(GetHasFeat(FEAT_MONK_FALL))
        {
            int monk_level  = GetLevelByClass(CLASS_TYPE_MONK);
            if(monk_level>=18)
                nHeight = 0;
            else if(monk_level>=8)
                nHeight -= 15;
            else if(monk_level>=6)
                nHeight -= 10;
            else
                nHeight -= 6;
//SendMessageToPC(OBJECT_SELF, "Monk Fall only");
        }

        int nTumble = GetIsSkillSuccessful(OBJECT_SELF, SKILL_TUMBLE, 15);
    if(nTumble)
            rFall   = nHeight-3;
    else
            rFall   = nHeight;
    if(bRoped)
            rFall   = rFall-(GetCreatureHeight(OBJECT_SELF,TRUE)+1);


        int nTens = rFall/3;
//SendMessageToPC(OBJECT_SELF, "Tumble?");
        if(nTens>0)
        {
            if(    GetHasSpell(SPELL_FEATHER_FALL)
                && nTens*6 >= GetCurrentHitPoints(OBJECT_SELF)
              )
            {
                DecrementRemainingSpellUses(OBJECT_SELF,SPELL_FEATHER_FALL);
                FloatingTextStringOnCreature(GREEN+GetName(OBJECT_SELF)+LIME+" floats gently to the ground.", OBJECT_SELF);
                FloatingTextStringOnCreature(RED+"Feather Fall saved your life.", OBJECT_SELF,FALSE);
            }
            else
            {
                // create damage from fall
                int nDam    = d6(nTens);
                MSDoFallingDamage(nDam, nTumble, bRoped);

                if (Random(2))
                PlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 5.0);
                else
                PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 5.0);


//SendMessageToPC(OBJECT_SELF, "Damage runs");
            }
        }

}





void MSUserFalls(int bTop, int nHeight, int bRoped)
{

            int rFall;
    if(!bTop)
    {
        ApplyEffectAtLocation(  DURATION_TYPE_INSTANT,
                                EffectVisualEffect(VFX_IMP_DUST_EXPLOSION),
                                GetLocation(OBJECT_SELF)
                             );


//SendMessageToPC(OBJECT_SELF, "btop");

        if (!GetHasFeat(FEAT_MONK_FALL, OBJECT_SELF)||!GetHasSpellEffect(SPELL_FEATHER_FALL, OBJECT_SELF))
        {
            if (Random(2))
                PlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 5.0);
            else
                PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 5.0);

            GivePCFatigue();
//SendMessageToPC(OBJECT_SELF, "Monk Fall");
        }

        else
        {
            FloatingTextStringOnCreature(GREEN+GetName(OBJECT_SELF)+LIME+" glides down with grace despite poor climbing skills.", OBJECT_SELF);
        }

    }
    else
    {
        int rFall;

        if(GetHasSpellEffect(SPELL_FEATHER_FALL))
        {
            nHeight = 0;
            FloatingTextStringOnCreature(GREEN+GetName(OBJECT_SELF)+LIME+" floats gently to the ground.", OBJECT_SELF);
        }
        else if(GetHasFeat(FEAT_MONK_FALL))
        {
            int monk_level  = GetLevelByClass(CLASS_TYPE_MONK);
            if(monk_level>=18)
                nHeight = 0;
            else if(monk_level>=8)
                nHeight -= 15;
            else if(monk_level>=6)
                nHeight -= 10;
            else
                nHeight -= 6;
//SendMessageToPC(OBJECT_SELF, "Monk Fall only");
        }

        int nTumble = GetIsSkillSuccessful(OBJECT_SELF, SKILL_TUMBLE, 15);
        if(nTumble)
            rFall   = nHeight-3;
        else
            rFall   = nHeight;
        if(bRoped)
            rFall   = rFall-(GetCreatureHeight(OBJECT_SELF,TRUE)+1);


        int nTens = rFall/3;
//SendMessageToPC(OBJECT_SELF, "Tumble?");
        if(nTens>0)
        {
            if(    GetHasSpell(SPELL_FEATHER_FALL)
                && nTens*6 >= GetCurrentHitPoints(OBJECT_SELF)
              )
            {
                DecrementRemainingSpellUses(OBJECT_SELF,SPELL_FEATHER_FALL);
                FloatingTextStringOnCreature(GREEN+GetName(OBJECT_SELF)+LIME+" floats gently to the ground.", OBJECT_SELF);
                FloatingTextStringOnCreature(RED+"Feather Fall saved your life.", OBJECT_SELF,FALSE);
            }
            else
            {
                // create damage from fall
                int nDam    = d6(nTens);
                MSDoFallingDamage(nDam, nTumble, bRoped);
//SendMessageToPC(OBJECT_SELF, "Damage runs");
            }
        }
    }
}


void MSDoFallingDamage(int nDam, int nTumble, int bRoped)
{
  if(GetIsObjectValid(OBJECT_SELF))
  {
    if( !GetIsObjectValid(GetArea(OBJECT_SELF)) )
        DelayCommand(1.0, MSDoFallingDamage(nDam, nTumble, bRoped));
    else
    {

        int nHP = GetCurrentHitPoints(OBJECT_SELF);
        if(!bRoped && nDam>nHP)
            nDam=nHP;
        else if(bRoped && nDam>=nHP)
            nDam=nHP-1;

        effect  eDam    = EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, OBJECT_SELF);
        if(!nTumble&&!GetHasFeat(FEAT_MONK_FALL))
            PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT);
        ApplyEffectAtLocation(
                DURATION_TYPE_INSTANT,
                EffectVisualEffect(VFX_IMP_DUST_EXPLOSION),
                GetLocation(OBJECT_SELF)




            );
    }
  }

}

// from main
// ignore more than 1 attempt every 6 seconds
void MSIgnoreUser(object oUser)
{
    FloatingTextStringOnCreature(PINK+"Only one attempt every 6 seconds is allowed.", oUser, FALSE);
}

// from main
// clean up local variables that were set on user or move node for one time configuration
void MSCleanUp(object oUser)
{
    // deletion of the AID forced skill override
    DeleteLocalInt(oUser, "MOVE_SKILL_OVERRIDE");
}

// ---- MAIN -------------------------------------------------------------------

void main()
{
    // determine who is using the move skill node
    object oUser = MSGetUser(); if(oUser==OBJECT_INVALID) return;

    switch(MSGetUserClicks(oUser))
    {
        case 1:
            // explain the challenge
            MSDescribeMove(oUser);
        break;
        case 2:
            // attempt a move
            MSAttemptMove(oUser);
        break;
        case 3:
            // ignore more than 1 attempt every 6 seconds
            MSIgnoreUser(oUser);
        break;
    }

    MSCleanUp(oUser);
}
