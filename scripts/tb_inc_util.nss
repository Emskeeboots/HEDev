// tb_inc_util
// common utility library

#include "x0_i0_position"
#include "x0_i0_assoc"
#include "x0_i0_match"
#include "x3_inc_string"

const int ARMOR_TYPE_CLOTH   = 0;
const int ARMOR_TYPE_LIGHT   = 1;
const int ARMOR_TYPE_MEDIUM  = 2;
const int ARMOR_TYPE_HEAVY   = 3;

//----------------------------------------------------
// Time related routines
//
// Advance the clock by given number of hours
void AdvanceTime(int hours, int bForce = FALSE);

//Returns Current Time in hours, good for absolute time
int CurrentTime();

//returns current time in days, good for absolute days elapses
int CurrentDay();

//Returns a Timestamp in seconds, good for fine grained absolute time
int CurrentTimeStamp();

// Take timestamp in seconds and convert it to hours used by CurrentTime
int TimeStampToHours(int nTime);

// Take timestamp in seconds and convert it to days used by CurrentTimeDay
int TimeStampToDays(int nTime);

// Get the number of rounds of 6 secs per game hour
int tbRoundsPerHour();

// Get the hour for dawn
int tbGetDawnHour();

// Get the hour for dusk
int tbGetDuskHour();

// Get the number of rounds of 6 secs per game minute
// This usually rounds up to 1.
int tbRoundsPerMin();
// Get the number of rounds of 6 seconds per 10 game minutes
// This is 1/6 of HBsPerHour, not always 10 * HBsPerMin due to rounding
int tbRoundsPerTen();


// this is a first hack to get better random numbers. It's probably
// CPU intensive. Call it rarely, like on enter area once for each area
// not every time you want to call random.
// TODO - forum states this is not needed - evidence suggests otherwise
void ReSeedRandom();

// Checks if the weather outside is frightful
int isFoulWeather(object oObj = OBJECT_SELF);

////////////////////////////////
// Position and facing routines
////////////////////////////////
// Set creature (oNPC) to face given object
void SetFacingObject(object oTarget, object oNPC = OBJECT_SELF);

// This returns the location flanking the target to the right
location tbGetFlankingRightLocation(object oTarget, float fDist = 3.0);

// Returns the location flanking the target to the left
// (slightly behind) and facing same direction as the target.
// (useful for backup)
location tbGetFlankingLeftLocation(object oTarget, float fDist = 3.0);

// Returns location directly behind the target and facing same
// direction as the target (useful for backstabbing attacks)
location tbGetBehindLocation(object oTarget, float fDist = 3.0);

// Get a new location fdistance in front of object
location tbGetCustomAheadLocation(object oObject, float fDist = 3.0);

// get a new location to the right front of object a short distance away (3.0)
location tbGetRightFrontLocation(object oObject, float fDist = 3.0) ;

// Get a new location randomly around the given location. If dist is 0.0
// location of oObject is returned.
location tbGetRandomNearLocation(object oObject, float fDist = 0.0);

// Lightfoot's code to determine if the oTarget is within oSelf's from nViewArc
int GetIsFacingTarget(object oSelf, object oTarget, int nViewArc);

/////////////////////////
// Hench person routines
/////////////////////////
// set all of oPCs henchpeople to busy so they don't teleport to the PCs location.
void SetHenchBusy(object oPC, int bBusy = TRUE);

// Determine the given PC has a henchperson with tag sTag
// returns TRUE if so, FALSE otherwise
int hasHenchPerson(object oPC, string sTag) ;

// Determine the given PC has a henchperson with tag sTag
// returns the henchperson object if so, OBJECT_INVALID otherwise
object getHenchPerson(object oPC, string sTag);

//Returns the number of henchmen oPC has employed - [FILE: tb_inc_util]
//Returns -1 if oPC isn't a valid PC
//int GetNumHenchmen(object oPC);


// Used this as a wrapper to get around using non-void routines as actions
//
//  e.g. ActionDoCommand( oMakeAction(
//               CopyItem( GetItemPossessedBy( OBJECT_SELF, "plotitem"), oPC)));
void oMakeAction(object oObject) { }
void iMakeAction(int nInt) {}

// Cause oSelf to die.
void ActionDie(object oSelf = OBJECT_SELF);


// 0 pad a positive int and return it as a string.
// nplaces must be > 0 and <= 5.
// e.g. tbPadInt(5, 2) -> "05"
string tbPadInt(int nNum, int nPlaces = 2);

// returns the first PC in this area if any
// returns OBJECT_INVALID if no player in area
object GetPlayerInArea();

// * returns true if there is no player in the area
// * has to be ran from an object
int NoPlayerInArea();

// Function to do a private version of this skill check, no result
// is told to the PC
int GetIsSkillSuccessfulPrivate(object oTarget, int nSkill, int nDifficulty);

/////////////////////////
// item and inventory routines
/////////////////////////

// A.k.a. Strip : removes all items and gold from given PC object except clothing, unless bCloth is TRUE
// If oDest is a valid object with inventory then all items and gold not removed are placed there.
void tbTakePCInventory(object oPC, int bCloth = FALSE, object oDest = OBJECT_INVALID);

// is this the hood for a hooded cloak?
int isCloakHood(object oItem);

// Get the base (non magical) AC of the given armor
// return -1 if not an armor
int GetItemACBase( object oItem);

// Get the armor type of the given armor. Or -1 if not an armor
// Returns one of ARMOR_TYPE_* constants
int GetItemArmorType(object oItem);

// returns the number of items with the given tag carried by oCreature
// counting stacked items as 1 unless bStack is TRUE.
int GetNumItemsByTag(object oCreature, string sTag, int bStack = FALSE);
int DestroyAllItemsByTag(object oCreature, string sTag, int bStack = FALSE);

// destroy nNum of sTag item in oTarget's inventory.
// This will start with unequipped inventory and then look in equipped items.
// It will handle stacked items.
// Return value is the number of item in nNum it did not remove.
// So a return of 0 is expected when all required items were found.
int DestroyNumItems(object oTarget, string sTag, int nNum = 1);

// get the GP value if the given item.
// Identifies it temporarily if needed.
int GetIdentifiedValue(object oItem);

// is PC wearing the given clothes by tag
int isWearingThis(object oPC, string tag);

//Function will check if oPC is the correct gender
//to equip oItem.  If not, it will force the player
//to unequip the item and inform them of the reason.
// Set the name of the item to end in (f) to restrict to female (m) for male.
// Or set one of GENDER_FEMALE or GENDER_MALE on the item - this may be fragile
// with stores.
// Or set the gender restrict item property on the item, if enabled. TBD
// This returns true if the restriction was enforced (e.g. male tried to equip female item)
int tbGenderRestrict(object oItem, object oPC);

// Get the effective weapon size of oWeapon when used by oCreature.
// For example short sword(size 2) used by a small creature returns 3 (normal weapon size).
int getEffectiveWeaponSize(object oWeapon, object oCreature);

// is the given creature's head/face covered
int tbGetIsConcealed(object oCreature);

// return the racial type of the creature. If the creature could pass for human and if
// concealed then return human. Concealed only applies to PCs. just returns regular racial type
// for NPCs.
int tbGetRacialType(object oCreature);


////////////////////////////
// Effects and such
////////////////////////////
// This function will hide just applied effect's icon. How it works? Simply,
// I apply this effect twice, first time normally, but second time with some other effect in link.
// And then I will strip the second linked effect, so effect icon will disappear but original effect will stay.
//nDurationType - only permanent and temporary, its logical
//may not work properly with linked effect, proper testing is recommended
// From ShadOow
void ApplyEffectToPCAndHideIcon(int nDurationType, effect eEffect, object oPC, float fDuration=0.0);


// Put the given NPC to sleep
void tbPutToSleep(object oNPC);

// wake up the given sleeping NPC
void tbWakeUp(object oNPC);

// simple check for if the NPC is sleeping.
// Returns false for invalid oNPC object
int tnp_is_sleeping(object oNPC = OBJECT_SELF);

// remove all given effect by type from the creature. Or only those created by valid oCreator object
void tbRemoveEffect(object oCreature, int effectType, object oCreator = OBJECT_INVALID);

// Makes the PC invisible for a fraction of a second. This causes everyone nearby to go back through 
// on perception code. Useful when chaning creatures to hostile to make sure they attack for example.
void tbForceRePerceivePC(object oPC);

// Get the class name of a playable class
string GetClassName (int nClass);

// Add nVal to local int variable sVar on oObj. Returns the new value
// of the variable.
int AddLocalInt(object oObj, string sVar, int nVal);

// Apply the given visual effect to the given location as an instant.
void ApplyVisualAtLocation(int nVis, location lLoc);

// Get first object in the area that is not tagged with sTag.
object GetObjectInAreaNotTag(object oArea, string sTag);

// Get first object in the area that is tagged with sTag.
object GetObjectInAreaByTag(object oArea, string sTag);

// Dice related functions
// perform the given die roll and return the result.
// Die roll should be in normal DnD format (xDy +/- z) 
// The D or d is accepted.
// If the string fails to parse then 1 is returned. 
// "x"   - returns x
// xdy   - returns x rolls of a dx sided die.
// dy    - same as 1dy
// xdy + z - z must be a number or is ignored. 
// Valid values for y are 1,2,3,4,6,8,10,12,20,100
int getDieRoll(string sRoll) {
        int nZ = 0;
        int nX;
        int nY; 
        int nOp; 
        int nRet = 0;
        int bNeg = FALSE;

        if (sRoll == "") return 1;
        sRoll = GetStringLowerCase(sRoll);

        // Look for a plus sign and split
        nOp = FindSubString(sRoll, "+");
        if (nOp == -1) {
                nOp = FindSubString(sRoll, "-");
                bNeg = TRUE;
        }

        string sBonus = "";
        string sDice = "";
        if (nOp > 0) {
                sBonus = GetStringRight(sRoll, GetStringLength(sRoll) - nOp -1);
                sDice = GetStringLeft(sRoll, nOp);
        } else {
                sDice = sRoll;
        }
        if (sBonus != "") {
                nZ = StringToInt(sBonus);
                if (bNeg) {
                        nZ = 0 - nZ;
                }
        }

        if (sDice == "") {
                if (nZ > 0) return nZ;
                return 1;
        }
        int nIdx = FindSubString(sDice, "d");
        if (nIdx <0) {
                // no d so return x + z
                nX = StringToInt(sDice);
                nRet = nX + nZ;
                if (nRet <= 1) return 1;
                return nRet;
        }

        string sX = GetStringLeft(sDice, nIdx);
        string sY = GetStringRight(sDice,  GetStringLength(sDice) - nIdx -1);

        nX = StringToInt(sX);
        if (nX <= 0) nX = 1;

        nY = StringToInt(sY);
        switch (nY) {
                case 1: nRet = nX + nZ; break;
                case 2: nRet = d2(nX)  + nZ; break;
                case 3: nRet = d3(nX)  + nZ; break;
                case 4: nRet = d4(nX)  + nZ; break;
                case 6: nRet = d6(nX)  + nZ; break;
                case 8: nRet = d8(nX)  + nZ; break;
                case 10: nRet = d10(nX)  + nZ; break;
                case 12: nRet = d12(nX)  + nZ; break;
                case 20: nRet = d20(nX)  + nZ; break;
                case 100: nRet = d100(nX)  + nZ; break;

                default:
                nRet = 1 + nZ; 
        }
        return nRet;
}

/*-------------------------------------------------------------
 * Implementation
 -------------------------------------------------------------*/
// Advance the clock by given number of hours
void AdvanceTime(int hours, int bForce = FALSE) {

    // Don't do anything in multiplayer unless told to
    if (GetLocalInt(GetModule(), "tb_multiplayer") && !bForce)
        return;

    int hour = GetTimeHour ();

    hour = hour + hours;
    //if (hour > 23) hour = hour - 24;
    SetTime (hour, GetTimeMinute(), GetTimeSecond(), 0);
}

//Returns Current Time in hours, good for absolute time
// in matters of hour granularity
int CurrentTime() {
    return  GetCalendarYear()  * 8064 +
        GetCalendarMonth() * 672  +
        GetCalendarDay()   * 24   +
        GetTimeHour();
}

//returns current time in days, good for absolute days elapses
int CurrentDay() {
    return  GetCalendarYear()  * 336 +
        GetCalendarMonth() * 28  +
        GetCalendarDay() ;
}

//Returns a Timestamp in seconds, good for fine grained absolute time
int CurrentTimeStamp() {
    int nSecHour = FloatToInt(HoursToSeconds(1));
    return CurrentTime() * nSecHour
            + GetTimeMinute() * 60
            + GetTimeSecond();
}

// Take timestamp in seconds and convert it to hours used by CurrentTime
int TimeStampToHours(int nTime) {
    return nTime / FloatToInt(HoursToSeconds(1));
}

// Take timestamp in seconds and convert it to days used by CurrentTimeDay
int TimeStampToDays(int nTime) {
    return nTime / (FloatToInt(HoursToSeconds(1)) * 24);
}

// Given a date string "yyyy,mm,dd" return the corresponding day time stamp.
int tbDatetoTS(string sDate) {
    int nYear = StringToInt(GetSubString(sDate, 0, 4));
    int nMonth = StringToInt(GetSubString(sDate, 5, 2));
    int nDay = StringToInt(GetSubString(sDate, 8,2));

    return  nYear * 336 + nMonth * 28 + nDay;
}

// Given a day timestamp return a string "yyyy,mm,dd"
string tbTStoDateStr(int nTime) {
    string ret;
    int nYear = nTime / 336;
    int nRest = nTime % 336;
    int nMonth = nRest/28;

    if (nTime == 0)
        return "0000,00,00";

    if (nMonth == 0) {
        nMonth = 12;
        nYear --;
    }

    int nDay = nRest %28;

    if (nDay == 0) {
        nMonth --;
        nDay = 28;
    }

    if (nMonth == 0) {
        nMonth = 12;
        nYear --;
    }
    return IntToString(nYear) + "," +  tbPadInt(nMonth) + "," + tbPadInt(nDay);
}

// Given a day timestamp return a string "day %d, month %m of year %yyyy
string tbTStoDatePrettyStr(int nTime) {
    string ret;
    int nYear = nTime / 336;
    int nRest = nTime % 336;
    int nMonth = nRest/28;

    if (nTime == 0)
        return "the beginning of time";

    if (nMonth == 0) {
        nMonth = 12;
        nYear --;
    }

    int nDay = nRest %28;

    if (nDay == 0) {
        nMonth --;
        nDay = 28;
    }

    if (nMonth == 0) {
        nMonth = 12;
        nYear --;
    }
    return "day " + IntToString(nDay) + " month " + IntToString(nMonth) + " of year " + IntToString(nYear);
}


// Get the hour for dawn
// This is stored as 1 - 24.
int tbGetDawnHour() { return GetLocalInt(GetModule(), "tb_dawn_hour") - 1; }

// Get the hour for dusk
// This is stored as 1 - 24.
int tbGetDuskHour() { return GetLocalInt(GetModule(), "tb_dusk_hour")  -1; }

// Get the number of rounds of 6 secs per game minute

// Get the number of rounds of 6 secs per game hour
int tbRoundsPerHour() {
    return GetLocalInt(GetModule(), "rounds_per_hour");
}

// Get the number of rounds of 6 secs per game minute
// This usually rounds up to 1.
int tbRoundsPerMin(){
    return GetLocalInt(GetModule(), "rounds_per_min");
}

// Get the number of rounds of 6 seconds per 10 game minutes
// This is 1/6 of HBsPerHour, not always 10 * HBsPerMin due to rounding
int tbRoundsPerTen(){
    return GetLocalInt(GetModule(), "rounds_per_ten");
}

// this is a first hack to get better random numbers. It's probably
// CPU intensive. Call it rarely, like on enter area once for each area
// not every time you want to call random.
void ReSeedRandom() {
    // Random seed is set each time a PC enters an area, but it's seeded
    // the same on each area. This advanced the sequence to a hopefully
    // different place.
    int i;
    for (i = 0 ; i < GetTimeMillisecond() ; i ++ ) {
        Random(100);
    }
}

// Checks if the weather outside is frightful
int isFoulWeather(object oObj = OBJECT_SELF) {
    object oArea = GetArea(oObj);

    int nWeather = GetWeather(oArea);
    if (nWeather == WEATHER_RAIN || nWeather == WEATHER_SNOW)
        return TRUE;

    return FALSE;
}


void SetFacingObject(object oTarget, object oNPC = OBJECT_SELF)
{
    vector vFace = GetPosition(oTarget);
    AssignCommand(oNPC, SetFacingPoint(vFace));
    // ambient used this AssignCommand(oNPC, SetFacingPoint(GetPositionFromLocation(GetLocation(oToFace))));
}


/* These are from x0_i0_position which defines
   // Distances used for determining positions
   const float DISTANCE_TINY = 1.0;
   const float DISTANCE_SHORT = 3.0;
   const float DISTANCE_MEDIUM = 5.0;
   const float DISTANCE_LARGE = 10.0;
   const float DISTANCE_HUGE = 20.0;
 */

// This returns the location flanking the target to the right
location tbGetFlankingRightLocation(object oTarget, float fDist = 3.0)
{
    float fDir = GetFacing(oTarget);
    float fAngleToRightFlank = GetFarRightDirection(fDir);
    return GenerateNewLocation(oTarget,
                               fDist,
                               fAngleToRightFlank,
                               fDir);
}


// Returns the location flanking the target to the left
// (slightly behind) and facing same direction as the target.
// (useful for backup)
location tbGetFlankingLeftLocation(object oTarget, float fDist = 3.0) {
    float fDir = GetFacing(oTarget);
    float fAngleToLeftFlank = GetFarLeftDirection(fDir);
    return GenerateNewLocation(oTarget,
                               fDist,
                               fAngleToLeftFlank,
                               fDir);
}

// Returns location directly behind the target and facing same
// direction as the target (useful for backstabbing attacks)
location tbGetBehindLocation(object oTarget, float fDist = 3.0) {
    float fDir = GetFacing(oTarget);
    float fAngleOpposite = GetOppositeDirection(fDir);
    return GenerateNewLocation(oTarget,
                               fDist,
                               fAngleOpposite,
                               fDir);
}

location tbGetCustomAheadLocation(object oObject, float fDist = 3.0){
    vector vOrig = GetPosition(oObject);
    float fFacing = GetFacing(oObject);
    vector vNew = vOrig + fDist * AngleToVector(fFacing);
    return Location(GetArea(oObject), vNew, fFacing + 180.0);
}

location tbGetRightFrontLocation(object oObject, float fDist = 3.0) {
    float fDir = GetFacing(oObject);
    float fAngle = GetHalfRightDirection(fDir);
    return GenerateNewLocation(oObject, fDist, fAngle, fDir);
}

location tbGetRandomNearLocation(object oObject, float fDist = 0.0) {
        location lLoc = GetLocation(oObject);
        if (fDist <= 0.01)
                return lLoc;

        object oArea = GetAreaFromLocation(lLoc);
        vector vVect = GetPositionFromLocation(lLoc);
        float fAngle = IntToFloat(Random(360));
        vector vNew = GetChangedPosition(vVect, fDist, fAngle);
        return Location(GetAreaFromLocation(lLoc), vNew, GetFacingFromLocation(lLoc));
}

location GetThreeQuarterLocation(location lStart, location lEnd) {
        float fX, fY;
        vector vStart = GetPositionFromLocation(lStart);
        vector vEnd = GetPositionFromLocation(lEnd);

        if(vEnd.x > vStart.x)
                fX = vEnd.x - ((vEnd.x - vStart.x) * 0.25);
        else
                fX = ((vStart.x - vEnd.x) * 0.25) + vEnd.x;

        if(vEnd.y > vStart.y)
                fY = vEnd.y - ((vEnd.y - vStart.y) * 0.25);
        else
                fY = ((vStart.y - vEnd.y) * 0.25) + vEnd.y;

        vector vMoveTo = Vector(fX, fY, vEnd.z);
        if(0 >= 1) {
                SendMessageToPC(OBJECT_SELF, "Start: "+FloatToString(vStart.x) + ", "+
                        FloatToString(vStart.y));
                SendMessageToPC(OBJECT_SELF, "End: "+FloatToString(vEnd.x) + ", "+
                        FloatToString(vEnd.y));
                SendMessageToPC(OBJECT_SELF, "MoveTo: "+FloatToString(fX) + ", "+
                        FloatToString(fY));
        }
        return Location(GetArea(OBJECT_SELF), vMoveTo, 90.0);
}

// Lightfoot's code to determine if the oTarget is within oSelf's from nViewArc
/*
int GetIsFacingTarget(object oSelf, object oTarget, int nViewArc) {
    float AngleOffset = VectorToAngle( GetPosition(oTarget) - GetPosition(oSelf)) - GetFacing(oSelf) ;
    return (abs(FloatToInt(AngleOffset)) <  nViewArc/2);
}
*/
// WhiZard reported this :
// AngleOffset has a range of -360<x<360 such that if I were facing East (reported as 0) and my target was
// 1 degree South of East (-1 is reported as 359) the AngleOffset would be 359 which would require a ViewArc
//to be greater than 718 in order to report true.
int GetIsFacingTarget(object oSelf, object oTarget, int nViewArc) {
        float fViewArc = IntToFloat(nViewArc);
        float AngleOffset = fabs(fabs(VectorToAngle(GetPosition(oSelf) - GetPosition(oTarget)) - GetFacing(oSelf)) - 180.0);
        return (AngleOffset <  fViewArc/2.0);
}

void ActionDie(object oSelf = OBJECT_SELF) {

    if (GetObjectType(oSelf) != OBJECT_TYPE_CREATURE) {
        return;
    }

    ClearAllActions();
    SetIsDestroyable(FALSE,FALSE,FALSE);
    if (GetIsImmune(oSelf, IMMUNITY_TYPE_DEATH)) {
        int iHP = GetCurrentHitPoints(oSelf) + 10;
        effect eDamage = EffectDamage(iHP);
        ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oSelf));
    } else {
        effect eDeath = EffectDeath();
        ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oSelf));
    }
}

// set all of oPCs henchpeople to busy so they don't teleport to the PCs location.
void SetHenchBusy(object oPC, int bBusy = TRUE) {
    int nNth = 1;
    object oHench = GetHenchman(oPC, nNth++);
    while (GetIsObjectValid(oHench)) {
        SetAssociateState(NW_ASC_IS_BUSY, bBusy, oHench);
        //AssignCommand(oHench, SetIsBusy(bBusy));
        if (bBusy && !GetAssociateState(NW_ASC_IS_BUSY, oHench))
            SendMessageToPC(GetFirstPC(), "hench " + GetTag(oHench) + " Is not busy");
        oHench = GetHenchman(oPC, nNth ++);
    }

}

// Determine the given PC has a henchperson with tag sTag
// returns TRUE if so, FALSE otherwise
int hasHenchPerson(object oPC, string sTag) {
     int nNth = 1;
     object oHench = GetHenchman(oPC, nNth++);
     while (GetIsObjectValid(oHench)) {
        if (GetTag(oHench) == sTag) {
            return TRUE;
        }
        oHench = GetHenchman(oPC, nNth ++);
     }
     return FALSE;
}

// Determine the given PC has a henchperson with tag sTag
// returns the henchperson object if so, OBJECT_INVALID otherwise
object getHenchPerson(object oPC, string sTag) {
     int nNth = 1;
     object oHench = GetHenchman(oPC, nNth++);
     while (GetIsObjectValid(oHench)) {
        if (GetTag(oHench) == sTag) {
            return oHench;
        }
        oHench = GetHenchman(oPC, nNth ++);
     }
     return OBJECT_INVALID;
}

/* _inc_utils.nss
// get the number of henchpeople
int GetNumHenchmen(object oPC) {
    if (!GetIsPC(oPC)) return -1;

    int nLoop, nCount;
    for (nLoop=1; nLoop<=GetMaxHenchmen(); nLoop++) {
        if (GetIsObjectValid(GetHenchman(oPC, nLoop)))
            nCount++;
    }
    return nCount;
}
*/

void ForceUnequip (object oTarget, object oItem) {

        //SendMessageToPC(oTarget, "ForceUnequip Called item " + GetName(oItem));
        if (!GetIsObjectValid(oTarget) || GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
                return;

        if (!GetIsObjectValid(GetArea(oTarget))) {
                DelayCommand(5.0, ForceUnequip(oTarget, oItem));
                return;
        }


        //SendMessageToPC(oTarget, "ForceUnequip - Doing work.");
        AssignCommand(oTarget, ClearAllActions(TRUE));
        //SetLocalInt(oItem, "ForceUnequipped", TRUE);
        AssignCommand(oTarget, ActionUnequipItem(oItem));
        AssignCommand(oTarget, ActionDoCommand(SetCommandable(TRUE)));
        AssignCommand(oTarget, SetCommandable(FALSE));
}

void ForceJump (object oTarget, location lTarget, int bClearCombat=TRUE, int bForceCommandable=FALSE) {
        if (!GetIsObjectValid(oTarget) || GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
                return;

        if (!GetIsObjectValid(GetArea(oTarget))) {
                DelayCommand(5.0, ForceJump(oTarget, lTarget, bClearCombat, bForceCommandable));
                return;
        }

        /* Not sure about this. If used by the death code it will need to be integrated.
           I wonder if the jump to limbo is effected by these holes?
        if (GetIsDead(oTarget)) {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oTarget)), oTarget);

                effect eBad = GetFirstEffect(oTarget);
                while (GetIsEffectValid(eBad)) {
                        if (GetEffectIsNegative(eBad))
                                RemoveEffect(oTarget, eBad);

                        eBad = GetNextEffect(oTarget);
                }

                if (GetIsPC(oTarget))
                        AssignCommand(oTarget, ExecuteScript("fky_deathprocess", oTarget));

                DelayCommand(0.1, ForceJump(oTarget, lTarget, bClearCombat, bForceCommandable));
        } else  */

        if (!GetCommandable(oTarget)) {
                if (bForceCommandable) {
                        AssignCommand(oTarget, SetCommandable(TRUE));

                        if (bForceCommandable >= 5)
                                WriteTimestampedLogEntry("FORCEJUMP : " + GetPCPlayerName(oTarget) + " : "
                                        + GetName(oTarget) + " : more than 5 attempts to force commandable jumping to "
                                        + GetResRef(GetAreaFromLocation(lTarget)));
                }

                DelayCommand(1.0, ForceJump(oTarget, lTarget, bClearCombat, ++bForceCommandable));
        } else {
                AssignCommand(oTarget, ClearAllActions(bClearCombat));
                AssignCommand(oTarget, ActionJumpToLocation(lTarget));
                AssignCommand(oTarget, ActionDoCommand(SetCommandable(TRUE)));
                AssignCommand(oTarget, SetCommandable(FALSE));
        }
}

// Add this after adding all the required actions to creature's action queue
void tbForceCompleteActions(object oTarget = OBJECT_SELF) {
        AssignCommand(oTarget, ActionDoCommand(SetCommandable(TRUE)));
        AssignCommand(oTarget, SetCommandable(FALSE));
}

// returns the number of items with the given tag carried by oCreature
// counting stacked items as 1 unless bStack is TRUE.
int GetNumItemsByTag(object oCreature, string sTag, int bStack = FALSE) {
    int nCount = 0;
    int i;

    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem)) {
        if (sTag == GetTag(oItem)) {
            if (bStack)
                nCount += GetItemStackSize(oItem);
            else
                nCount ++;
        }

        oItem = GetNextItemInInventory(oCreature);
    }

    // Count equipped items too
    for (i = 0; i < NUM_INVENTORY_SLOTS; ++i) {
        oItem = GetItemInSlot(i, oCreature);
        if (GetIsObjectValid(oItem)
        && (GetTag(oItem) == sTag)) {
             if (bStack)
                nCount += GetItemStackSize(oItem);
            else
                nCount ++;
        }
    }

   return nCount;
}


// Like the above getNumItemsByTag except it destroys them as it counts them.
// Returns the number of items destroyed.
int DestroyAllItemsByTag(object oCreature, string sTag, int bStack = FALSE) {
    int nCount = 0;
    int i;

    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem)) {
        if (sTag == GetTag(oItem)) {
            if (bStack)
                nCount += GetItemStackSize(oItem);
            else
                nCount ++;
            DestroyObject(oItem);
        }

        oItem = GetNextItemInInventory(oCreature);
    }

    // Count equipped items too
    for (i = 0; i < NUM_INVENTORY_SLOTS; ++i) {
        oItem = GetItemInSlot(i, oCreature);
        if (GetIsObjectValid(oItem)
        && (GetTag(oItem) == sTag)) {
             if (bStack)
                nCount += GetItemStackSize(oItem);
            else
                nCount ++;
            DestroyObject(oItem);
        }
    }

   return nCount;
}

// This is a wrapper for use with assigncommand or delaycommand.
void tbCreateItemOnObject(string sRef, object oDest, int nStack) {
        object oItem = CreateItemOnObject(sRef, oDest, nStack);
        if (!GetIsObjectValid(oItem)) {
                if (GetLocalInt(GetModule(), "DEBUG")) {
                        SendMessageToPC(oDest, "Create of " + sRef + " on " + GetName(oDest) + " failed.");
                }
        }
}

// This is a wrapper to ensure the description gets copied. 
// Normal CopyTtem does not copy custom descriptions. 
object tbCopyItem(object oItem, object oTarget) {
        object oCopy = CopyItem(oItem, oTarget, TRUE);
        SetDescription(oCopy, GetDescription(oItem));
        return oCopy;
}

// TODO - these two routines probably want to be in an item handling include
// Copy any system known local variables from oOld to oNew
void tbCopyItemVars(object oNew, object oOld) {

        // only concerned with items
        if (GetObjectType(oNew) != OBJECT_TYPE_ITEM)
                return;

        // Specific code here for each variable which may be on an item
        // If they are specific to types this could be taken into account
        // for efficiency.
        SetLocalObject(OBJECT_SELF, "wpn_tmp_item", oOld);
        SetLocalObject(OBJECT_SELF, "wpn_tmp_new", oNew);
        SetLocalInt(OBJECT_SELF, "wpn_tmp_op", 9);
        ExecuteScript("wpn_do_op", OBJECT_SELF);

        if (GetLocalInt(oOld, "CursedDC")) {
                SetLocalInt(oNew, "CursedDC", GetLocalInt(oOld, "CursedDC"));
                int nIdx = 0;
                string s1;
                int n1;
                while (nIdx < 4) {
                        string sIdx = IntToString(nIdx);
                        s1 = GetLocalString(oOld, "curse_ip" + sIdx);
                        n1 = GetLocalInt(oOld, "curse_ip" + sIdx);
                        if (s1 != "" || n1 != 0) {
                                if (s1 != "") SetLocalString(oNew,  "curse_ip" + sIdx, s1);
                                if (n1 != 0) SetLocalInt(oNew, "curse_ip" + sIdx, n1);
                                SetLocalInt(oNew, "curse_val" + sIdx, GetLocalInt(oOld,"curse_val" + sIdx));
                                SetLocalInt(oNew, "curse_type" + sIdx, GetLocalInt(oOld,"curse_type" + sIdx));
                        } else {
                                break;
                        }
                        nIdx ++;
                }
        }

        if (GetLocalInt(oOld, "MagicDC")) {
                SetLocalInt(oNew, "MagicDC", GetLocalInt(oOld, "MagicDC"));
                // Don't set this so that the IPs ger re-applied.
                //SetLocalInt(oNew, "magic_ip_applied", GetLocalInt(oOld, "magic_ip_applied"));
                int nIdx = 0;
                string s1;
                int nIp = GetLocalInt(oOld, "magic_ip" + IntToString(nIdx));
                while (nIp != 0) {
                        string sIdx = IntToString(nIdx);

                        SetLocalInt(oNew, "magic_ip" + sIdx, nIp);
                        SetLocalInt(oNew, "magic_value" + sIdx, GetLocalInt(oOld,"magic_value" + sIdx));
                        SetLocalInt(oNew, "magic_subtype" + sIdx, GetLocalInt(oOld,"magic_subtype" + sIdx));
                        SetLocalInt(oNew, "magic_costtable" + sIdx, GetLocalInt(oOld,"magic_costtable" + sIdx));
                        nIp = GetLocalInt(oOld, "magic_ip" + IntToString(++nIdx));
                }
        }


        if (GetLocalInt(oOld, "pois_wpn_idx") > 0) {
                SetLocalInt(oNew, "pois_wpn_idx", GetLocalInt(oOld, "pois_wpn_idx"));
                SetLocalInt(oNew, "pois_wpn_uses", GetLocalInt(oOld, "pois_wpn_uses"));
                SetLocalInt(oNew, "poison_has_clean" ,  GetLocalInt(oOld, "poison_has_clean"));
        }

        if (GetLocalInt(oOld, "pois_itm_idx") > 0) {
                SetLocalInt(oNew, "pois_itm_idx", GetLocalInt(oOld, "pois_itm_idx"));
                SetLocalInt(oNew, "pois_itm_uses", GetLocalInt(oOld, "pois_itm_uses"));
                SetLocalInt(oNew, "poison_has_clean" ,  GetLocalInt(oOld, "poison_has_clean"));
                SetLocalInt(oNew, "pois_itm_trap_dc", GetLocalInt(oOld, "pois_itm_trap_dc"));
        }

        if (GetLocalInt(oOld, "pois_food_idx") > 0) {
                SetLocalInt(oNew, "pois_food_idx", GetLocalInt(oOld, "pois_food_idx"));
                SetLocalInt(oNew, "pois_food_uses", GetLocalInt(oOld, "pois_food_uses"));
                SetLocalInt(oNew, "pois_food_trap_dc", GetLocalInt(oOld, "pois_food_trap_dc"));
        }

        if (GetStringLeft(GetTag(oOld), 8) == "it_loot_") {
                SetLocalInt(oNew, "loot_auto_on", GetLocalInt(oOld, "loot_auto_on"));
        }

}

object DumpObjectToGround(object oItem, location lLoc, int bPlaceable = FALSE) {

        object oNew = OBJECT_INVALID;

        if (GetItemCursedFlag(oItem) || GetPlotFlag(oItem))
                return oNew;

        object oTarget = OBJECT_INVALID;

        if (bPlaceable)
                oTarget = CreateObject(OBJECT_TYPE_PLACEABLE, "invis_coin_plc", lLoc);

        if (GetIsObjectValid(oTarget)) {
                oNew = tbCopyItem(oItem, oTarget);
                DestroyObject(oItem);
                DestroyObject(oTarget);
        } else {
                oNew = CopyObject(oItem,lLoc);
              // copy any system variables on oItem to oNew
                tbCopyItemVars(oNew, oItem);
                DestroyObject(oItem);
        }
        return oNew;
}

int doCopyInventory(object oSource, object oTarget) {
        int nCount = 0;
        object oItem = GetFirstItemInInventory(oSource);
        while(GetIsObjectValid(oItem)) {
                if(!GetLocalInt(oItem,"COPIED")) {
                        tbCopyItem(oItem, oTarget);
                        SetLocalInt(oItem, "COPIED", TRUE);
                        DestroyObject(oItem, 0.1);
                        nCount ++;
                }
                oItem = GetNextItemInInventory(oSource);
        }
        return nCount;
}

object tbCopyContainer(object oItem, object oDest) {
        // If the container is empty this is just a copyItem
        if (!GetIsObjectValid(GetFirstItemInInventory(oItem)))
                return tbCopyItem(oItem, oDest);

        // Else we have real work to do
        // TODO - this may miss other variables on containers... maybe use copyitemvars
        // copyItem fails if inventory not empty and copyobject will copy contianed items
        // this duplicating, so we use this.
        object oCopy = CreateItemOnObject(GetResRef(oItem), oDest, 1, GetTag(oItem));
        SetLocalInt(oItem, "COPIED", TRUE);
        SetName(oCopy, GetName(oItem));
        SetDescription(oCopy, GetDescription(oItem));
        SetIdentified(oCopy, GetIdentified(oItem));
        if (GetStringLeft(GetTag(oItem), 8) == "it_loot_") {
                SetLocalInt(oCopy, "loot_auto_on", GetLocalInt(oItem, "loot_auto_on"));
        }
        int nCount = doCopyInventory(oItem, oCopy);
        //SetLocalInt(oCopy, "COPY_COUNT", nCount);
        return oCopy;
}


// A.k.a. Strip : removes all items and gold from given PC object except clothing, unless bCloth is TRUE
// If oDest is a valid object with inventory then all items and gold not removed are placed there.
void tbTakePCInventory(object oPC, int bCloth = FALSE, object oDest = OBJECT_INVALID) {
        object oCopy;
        int bCopy = FALSE;
        if (GetIsObjectValid(oDest)) {
                if (!GetHasInventory(oDest)) {
                        SendMessageToPC(oPC, "ERROR - destination for taken items has no inventory - not taking items");
                        return;
                }
                bCopy = TRUE;
        }

        string sIDResRef = GetLocalString(GetModule(), "PW_PCID_RESREF");

        object oItem = GetFirstItemInInventory(oPC);
        while(GetIsObjectValid(oItem)) {

        // Skip the PW PC Id item.
                if (sIDResRef != "" && GetResRef(oItem) == sIDResRef) {
                        SendMessageToPC(oPC, "Skipping taking ID item.");
                        oItem = GetNextItemInInventory(oPC);
                        continue;
                }

                // Not sure I like this plot flag... or cursed for that matter.
                // these are protecting certain items like the search tool ...
                if((GetPlotFlag(oItem) || GetItemCursedFlag(oItem)) && GetLocalInt(oItem, "PC_TOOL"))  {
                        SendMessageToPC(oPC, "Skipping taking PC tool item.");
                        oItem = GetNextItemInInventory(oPC);
                        continue;
                }

                // skip hs_lang tokens
                if (GetStringLeft(GetTag(oItem), 8) == "hlslang_") {
                        SendMessageToPC(oPC, "Skipping hslang widget item.");
                        oItem = GetNextItemInInventory(oPC);
                        continue;
                }

                if (GetLocalInt(oItem, "CursedDC") > 0 && GetLocalInt(oItem, "curse_applied")) {
                        SendMessageToPC(oPC, "Skipping curse applied item.");
                        oItem = GetNextItemInInventory(oPC);
                        continue;
                }

                // Already done it
                if (GetLocalInt(oItem,"COPIED")) {
                        oItem = GetNextItemInInventory(oPC);
                        continue;
                }

                if (bCopy) {
                        if (GetHasInventory(oItem)) {
                                oCopy = tbCopyContainer(oItem, oDest);
                        } else {
                                oCopy = tbCopyItem(oItem, oDest);
                        }
                }
                SetPlotFlag(oItem, FALSE);
                SetLocalInt(oItem, "COPIED", TRUE);
                DestroyObject(oItem, 0.1);
                oItem = GetNextItemInInventory(oPC);
        }

    // Loop through equipped items
        int i;
        for(i = 0; i <= NUM_INVENTORY_SLOTS; i++) {
                if (i == INVENTORY_SLOT_CARMOUR)
                        continue;
                if (!bCloth && i == INVENTORY_SLOT_CHEST)
                        continue;

                oItem = GetItemInSlot(i, oPC);
                if (GetIsObjectValid(oItem)) {
                        if (GetLocalInt(oItem, "CursedDC") > 0 && GetLocalInt(oItem, "curse_applied")) {
                                SendMessageToPC(oPC, "Skipping curse applied item.");
                                continue;
                        }

                        if (bCopy){
                                oCopy = tbCopyItem(oItem, oDest);
                        }
                        SetPlotFlag(oItem, FALSE);
                        DestroyObject(oItem, 0.1);
                }
        }
    // This does not need to change for coins - the items will all be taken anyway. And PC should
    // have no gold.
        int nGold = GetGold (oPC);
        if (nGold > 0) {
                if (bCopy) {
                        AssignCommand (oDest, TakeGoldFromCreature (nGold, oPC, FALSE));
                } else {
                        AssignCommand (oPC, TakeGoldFromCreature (nGold, oPC, TRUE));
                }
        }
}

// Return the slot number (INVENTGORY_SLOT_*) in which the given item
// is currently equipped or -1 if the item is not equipped.
// Applies to the normal PC equipapable slots only (not creture slots)
int GetEquippedSlot(object oOwner, object oItem) {
        if (!GetIsObjectValid(oOwner) || !GetIsObjectValid(oItem))
                return -1;

        int nRet = -1;
        int nSlot;
        for (nSlot = 0; nSlot <= INVENTORY_SLOT_BOLTS; nSlot ++) {
                if (GetItemInSlot(nSlot, oOwner) == oItem)
                        return nSlot;
        }
        return nRet;
}


// is PC wearing the given clothes by tag
int isWearingThis(object oPC, string tag) {

     if(!GetIsObjectValid(GetItemPossessedBy(oPC, tag)))
        return FALSE;

    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    if (oArmor != OBJECT_INVALID && GetTag(oArmor) == tag)
        return TRUE;

    return FALSE;
}

// This is cribbed from ZEP code in the CEP
// replaced here so that we can use a different mechanism
// rather than relying solely on the new ITEM PROP.
const int ITEM_PROPERTY_USE_LIMITATION_GENDER = 88;

// Returns GENDER_MALE or GENDER_FEMALE if item is gender speicifc otherwise -1
int tbGetItemGender(object oItem) {
        int nItemGender = -1;
        itemproperty ipGenderProperty=GetFirstItemProperty(oItem);
        while (GetIsItemPropertyValid(ipGenderProperty)) {
                if (GetItemPropertyType(ipGenderProperty)==ITEM_PROPERTY_USE_LIMITATION_GENDER)
                        break;
                ipGenderProperty=GetNextItemProperty(oItem);
        }
        if (GetIsItemPropertyValid(ipGenderProperty)) {
                nItemGender = GetItemPropertySubType(ipGenderProperty);
        }

        if (nItemGender == -1) {
                string sName = GetName(oItem);
                string sEnd = GetStringRight(sName,3);
                if (sEnd == "(m)" || GetLocalInt(oItem, "GENDER_MALE"))
                        nItemGender = GENDER_MALE;

                if (sEnd == "(f)" || GetLocalInt(oItem, "GENDER_FEMALE"))
                        nItemGender = GENDER_FEMALE;
        }
        return nItemGender;
}


//Function will check if oPC is the correct gender
//to equip oItem.  If not, it will force the player
//to unequip the item and inform them of the reason.
int tbGenderRestrict(object oItem, object oPC) {
        int nGender = GetGender(oPC);
        int nItemGender = tbGetItemGender(oItem);

        //First we check if this has the item property: Use Limitation: Gender.
        //If so, we enter the if statment and check PC gender
        //vs. the item's limitation.  Else we continue out of the
        //function.
        if (nItemGender != -1 && nItemGender != nGender) {
            //Not equal, so take it off!
                ForceUnequip(oPC, oItem);
                //AssignCommand(oPC,ActionUnequipItem(oItem));
            //Tell PC why.
        //SendMessageToPC(oPC,"You cannot equip that =item due to gender differences.");
                string sMessageToPC = "This item does not fit right";
                SendMessageToPC(oPC,sMessageToPC);
                return TRUE;
        }
        return FALSE;
}

void tbGenderRestrictNPC(object oItem, object oNPC) {
        if (GetIsPC(oNPC)) return;
        if (!GetIsPC(GetMaster(oNPC))) return;

        int nItemGender =  tbGetItemGender(oItem);
        if (nItemGender != -1) {
                int nGender = GetGender(oNPC);
                if (nGender != nItemGender) {
                        object oPC = GetMaster(oNPC);
                        AssignCommand(oNPC, ActionGiveItem(oItem, oPC));
                        OpenInventory(oNPC, oPC);
                        OpenInventory(oPC, oPC);
                        AssignCommand(oNPC, SpeakString("I cannot wear this. It does not fit me."));
                }
        }
}


// Get the effective weapon size of oWeapon when used by oCreature.
// For example short sword(size 2) used by a small creature returns 3 (normal weapon size).
int getEffectiveWeaponSize(object oWeapon, object oCreature) {


        int nBaseType = GetBaseItemType(oWeapon);
        int nValue = StringToInt(Get2DAString("baseitems", "Category", nBaseType));
        if (nValue == 1 || nValue == 2 || nValue == 7) {
                nValue = StringToInt(Get2DAString("baseitems", "WeaponSize", nBaseType));
                int nSize = GetCreatureSize(oCreature);
                int nRet = nValue + 3 - nSize;
                if (nRet < 1) nRet = 1;
                if (nRet > 4) nRet = 4;
                return nRet;
        } else {
               return 0;
        }



}
// is this the hood for a hooded cloak?
int isCloakHood(object oItem) {
    if (GetBaseItemType(oItem) == BASE_ITEM_HELMET
            && GetStringRight(GetTag(oItem), 5) == "_HOOD")
          return TRUE;
    return FALSE;
}

// is the given creature's head/face covered
int tbGetIsConcealed(object oCreature) {

    // Any helmet is okay I suppose
      object oHood = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
      if (GetIsObjectValid(oHood))
        return TRUE;

      // Other items like an amulet that did it via magic would be here

      return FALSE;
}

// return the racial type of the creature. If the creature could pass for human and if
// concealed then return human. Concealed only applies to PCs. just returns regular racial type
// for NPCs.
int tbGetRacialType(object oCreature) {
    int nRace = GetRacialType(oCreature);
    if (!GetIsPC(oCreature))
        return nRace;

    if (nRace == RACIAL_TYPE_HALFELF ||
        nRace == RACIAL_TYPE_HALFORC ||
        nRace == RACIAL_TYPE_ELF ||
        nRace == RACIAL_TYPE_HUMAN) {
        if (tbGetIsConcealed(oCreature))
            return RACIAL_TYPE_HUMAN;
    }
    return nRace;
}


// Get the base (non magical) AC of the given item
// This is the base AC of an armor or the AC entry of the item in baseitems
// This only returns non-zero for armor and shields.
// It does not include any properties.
int GetItemACBase(object oItem){
        if( !GetIsObjectValid(oItem))
                return 0;

        string sACBase = "0";
        int nType = GetBaseItemType(oItem);
        if (nType == BASE_ITEM_ARMOR) {
    // Get the torso model number
                int nTorso = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);

                // Read 2DA for base AC
                // Can also use "parts_chest" which returns it as a "float"
                //string sACBase = Get2DAString( "des_crft_appear", "BaseAC", nTorso);
                sACBase = Get2DAString( "parts_chest","ACBONUS", nTorso);
        } else if (nType == BASE_ITEM_SMALLSHIELD || nType == BASE_ITEM_LARGESHIELD || nType == BASE_ITEM_TOWERSHIELD) {
                int nType = GetBaseItemType(oItem);
                sACBase = Get2DAString("baseitems", "BaseAC", nType);
        }
        return StringToInt(sACBase);
}

// Get the armor type of the given armor. Or -1 if not an armor
// Returns one of ARMOR_TYPE_* constants
int GetItemArmorType(object oItem) {

        if(!GetIsObjectValid(oItem))
                return -1;
        if (GetBaseItemType( oItem) != BASE_ITEM_ARMOR)
            return -1;

    // Get and check Base AC
        switch(GetItemACBase( oItem)) {
                case 0: return  ARMOR_TYPE_CLOTH;
                case 1:
                case 2:
                case 3:
                return ARMOR_TYPE_LIGHT;
                case 4:
                case 5:
                return ARMOR_TYPE_MEDIUM;
                case 6:
                case 7:
                case 8:
                return ARMOR_TYPE_HEAVY;
        }
        return -1;
}
int IsCrossbow(object oWeapon) {
        if(!GetIsObjectValid(oWeapon))
                return FALSE;

        int nType = GetBaseItemType(oWeapon);
        switch (nType) {
                case BASE_ITEM_HEAVYCROSSBOW:
                case BASE_ITEM_LIGHTCROSSBOW:
                return TRUE;
        }
        return FALSE;
}


int IsBow(object oWeapon) {
        if(!GetIsObjectValid(oWeapon))
                return FALSE;

        int nType = GetBaseItemType(oWeapon);
        switch (nType) {
                case BASE_ITEM_LONGBOW:
                case BASE_ITEM_SHORTBOW:
                return TRUE;
        }
        return FALSE;
}

// 0 pad a positive int and return it as a string.
// nplaces must be > 0 and <= 5.
// e.g. tbPadInt(5, 2) -> "05"
string tbPadInt(int nNum, int nPlaces = 2) {
    if (nPlaces > 5) nPlaces = 5;
    if (nPlaces < 1) nPlaces = 1;
    if (nNum >= 0)
        return GetStringRight("00000"+IntToString(nNum),nPlaces);
    else
        return IntToString(nNum);
}

// destroy nNum of sTag item in oTarget's inventory.
// This will start with unequipped inventory and then look in equipped items.
// It will handle stacked items.
// Return value is the number of item in nNum it did not remove.
// So a return of 0 is expected when all required items were found.
int DestroyNumItems(object oTarget, string sTag, int nNum = 1) {
    object oItem = GetFirstItemInInventory(oTarget);
        while (GetIsObjectValid(oItem) && nNum > 0) {

        if (GetTag(oItem) == sTag) {
            int nCurStack = GetItemStackSize(oItem);
            if (nCurStack > nNum) {
                SetItemStackSize(oItem, nCurStack - nNum);
                return 0; // we're done.
            }
            // stack is <= nNum take them all and adjust nNum.
            DestroyObject(oItem);
            nNum -= nCurStack;
        }
        oItem = GetNextItemInInventory(oTarget);
        }

    if (nNum == 0) return 0;


    // check the equipment slots for the item
    int x;
    for (x = 0; x < NUM_INVENTORY_SLOTS; x++) {
        oItem = GetItemInSlot(x, oTarget);
        if (GetIsObjectValid(oItem)
            && (GetTag(oItem) == sTag)) {
            int nCurStack = GetItemStackSize(oItem);
            if (nCurStack > nNum) {
                SetItemStackSize(oItem, nCurStack - nNum);
                return 0; // we're done.
            }
            DestroyObject(oItem);
            nNum -= nCurStack;
            if (nNum == 0)
                return 0;
        }
    }

    return nNum;
}


// Identify items held by PC.
//  Will identify upto nCount items (or all items with Tag == sTag). If nCount == 0 all
//  all (matching) items will be identified. Returns the number of items actually identified.
int utilIdentifyItems(object oPC, string sTag = "", int nCount = 0) {
        int nRet = 0;
        object oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem)) {
                if (!GetIdentified(oItem)) {
                        if (sTag == "" || GetTag(oItem) == sTag) {
                                // Found one - check count
                                if (!nCount || nRet <= nCount) {
                                        SetIdentified(oItem, TRUE);
                                        nRet ++;
                                        if (nCount && nRet >= nCount)
                                                break;
                                }
                        }
                }
                oItem = GetNextItemInInventory(oPC);
        }
        return nRet;
}


// This function will hide just applied effect's icon. How it works? Simply,
// I apply this effect twice, first time normally, but second time with some other effect in link.
// And then I will strip the second linked effect, so effect icon will disappear but original effect will stay.
//nDurationType - only permanent and temporary, its logical
//may not work properly with linked effect, proper testing is recommended
// From ShadoOow
void ApplyEffectToPCAndHideIcon(int nDurationType, effect eEffect, object oPC, float fDuration=0.0) {
    ApplyEffectToObject(nDurationType,eEffect,oPC,fDuration);

    // Skip hiding the effect if this is set.
    if (GetLocalInt(GetModule(), "DEBUG_EFFECTS"))
        return;
    eEffect = EffectLinkEffects(eEffect,EffectTurnResistanceIncrease(1));
    ApplyEffectToObject(nDurationType,eEffect,oPC,fDuration);
    RemoveEffect(oPC,eEffect);
}

int AbrToAbility(string abr) {
        abr = GetStringUpperCase(abr);
        int nAbility = -1;
        if     (abr == "CON") nAbility =ABILITY_CONSTITUTION;
        else if(abr == "DEX") nAbility = ABILITY_DEXTERITY;
        else if(abr == "STR") nAbility = ABILITY_STRENGTH;
        else if(abr == "WIS") nAbility = ABILITY_WISDOM;
        else if(abr == "INT") nAbility = ABILITY_INTELLIGENCE;
        else if(abr == "CHA") nAbility = ABILITY_CHARISMA;
        return nAbility;
}

string abilityToString(int nAbility) {

        string sRet = "ABILITY_STRENGTH";
        switch (nAbility) {
                case ABILITY_CONSTITUTION: sRet = "constitution"; break;
                case ABILITY_STRENGTH: sRet = "strength"; break;
                case ABILITY_DEXTERITY: sRet = "dexterity"; break;
                case ABILITY_WISDOM: sRet = "wisdom"; break;
                case ABILITY_INTELLIGENCE: sRet = "intelligence"; break;
                case ABILITY_CHARISMA: sRet = "charisma"; break;
        }
        return sRet;
}

// Returns the ability modifier for the specified ability
// Get oCreature's ability modifier for nAbility.
// - nAbility: ABILITY_*
// - oCreature
// - nBaseAbilityScore: if set to true will return the ability modifier without
//                      bonuses (e.g. ability bonuses granted from equipped items).
// Return value on error: 0
int tbGetAbilityModifier(int nAbility,object oCreature,int nBaseAbilityScore);
int tbGetAbilityModifier(int nAbility,object oCreature,int nBaseAbilityScore) {

        if(!nBaseAbilityScore==FALSE)
                return GetAbilityModifier(nAbility,oCreature);

        int iMod;
        float fMod;
        int iGet_Ab  = GetAbilityScore(oCreature,nAbility,TRUE);

        if (iGet_Ab >= 10) {
                iMod = (iGet_Ab-10)/2;
        } else {
                fMod = (IntToFloat(iGet_Ab) - 10.0)/2.0 - 0.5;
                iMod = FloatToInt(fMod);
        }
        return iMod;
}


int plcIsSmallLightSource(object oPlc) {

        // If explicitly set
        // Should be set to 2 if this is a small source
        if (GetLocalInt(oPlc, "LIGHT_SOURCE") == 2)
                return TRUE;

        // Else try to figure it out
        string sTag = GetTag(oPlc);
        sTag = GetStringLowerCase(sTag);
        if (FindSubString(sTag, "candelabra") > -1) return TRUE;
        else if (FindSubString(sTag, "tb_plc_tch") > -1) return TRUE;


        return FALSE;
}

void  tbInitUtils() {
     // these are set once on first module load and read from variables

        int nSecs = FloatToInt(HoursToSeconds(1));
        int nHBsHour =  nSecs/6; // rounds of 6 secs per game hour
        int nHBsminute = nHBsHour/60; // rounds of 6 secs per minute
        if (nHBsminute <= 0) nHBsminute = 1;

        // this is not 10* minutes because that is often rounded up to 1
        int nHBsten  = nHBsHour/6; // rounds of 6 secs per 10 game minutes 1/6th hour
    // nwscript rounds down so if nSecs is 60, this ends up being 10/6 = 1.
    // which is the same as HBsminute in that case so make it longer.
    // Don't expect this to happen much - TBoT uses nSecs = 360.
    if (nHBsten < 2) nHBsten == 2;

    SetLocalInt(GetModule(), "rounds_per_hour", nHBsHour);
    SetLocalInt(GetModule(), "rounds_per_min", nHBsminute);
    SetLocalInt(GetModule(), "rounds_per_ten", nHBsten);

    // anything else which needs to be setup goes here
    if (GetLocalInt(GetModule(), "tb_dawn_hour") == 0) {
        SendMessageToPC(GetFirstPC(), "Dawn hour not set assuming 6!");
        SetLocalInt(GetModule(), "tb_dawn_hour", 6 + 1);
    }
    if (GetLocalInt(GetModule(), "tb_dusk_hour") == 0) {
        SendMessageToPC(GetFirstPC(),"Dusk hour not set assuming 19!");
        SetLocalInt(GetModule(), "tb_dusk_hour", 19 + 1);
    }
}

// get the GP value if the given item.
// Identifies it temporarily if needed.
int GetIdentifiedValue(object oItem) {
    int bIdentified = GetIdentified(oItem);

    // If not already, set to identfied
    if (!bIdentified)
        SetIdentified(oItem, TRUE);
    int nGP=GetGoldPieceValue(oItem);

    // Re-set the identification flag to its original
    SetIdentified(oItem, bIdentified);

    return nGP;
}
// returns the first PC in this area if any
// returns OBJECT_INVALID if no player in area
object GetPlayerInArea() {
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC)) {
        if (GetArea(oPC) == GetArea(OBJECT_SELF))
            return oPC;
        oPC = GetNextPC();
    }
    return OBJECT_INVALID; // * no player in area
}

// * returns true if there is no player in the area
// * has to be ran from an object
int NoPlayerInArea() {
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC)) {
        if (GetArea(oPC) == GetArea(OBJECT_SELF))
            return FALSE;
        oPC = GetNextPC();
    }
    return TRUE; // * no player in area
}

// simple check for if the NPC is sleeping.
// Returns false for invalid oNPC object
int tnp_is_sleeping(object oNPC = OBJECT_SELF) {

    if (oNPC == OBJECT_INVALID)
        return FALSE;

    if (GetLocalInt(oNPC, "SLEEPING") || GetHasEffect(EFFECT_TYPE_SLEEP, oNPC))
        return TRUE;

        return FALSE;
}

// Put the given NPC to sleep
void tbPutToSleep(object oNPC) {

    //db("tbPutToSleep : " + GetTag(oNPC) + " isSleeping = ",   tnp_is_sleeping(oNPC));
    // already asleep - nothing to do
    if (tnp_is_sleeping(oNPC))
        return;

        SetLocalInt(oNPC,"SLEEPING",1); //stopping the script being fired repeatedly
        //Elf or Halfelf.
        if (GetRacialType(oNPC) == RACIAL_TYPE_ELF || GetRacialType(oNPC) == RACIAL_TYPE_HALFELF)
        {
        //SpeakString("Time to get some rest!");
        AssignCommand(oNPC, PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0f, 3600.0f)); // that should be long enough
        }
        else //Humans etc
        {
        //SpeakString("Time to get some rest!");
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSleep(), oNPC, 3600.0f);
        }
}

// wake up the given sleeping NPC
void tbWakeUp(object oNPC) {
    tbRemoveEffect(oNPC, EFFECT_TYPE_SLEEP);
    DeleteLocalInt(OBJECT_SELF,"SLEEPING");
    ClearAllActions();
    // do we need to do anything else here to get the creature moving?
}


// remove all given effect by type from the creature. Or only those created by valid oCreator object
void tbRemoveEffect(object oCreature, int effectType, object oCreator = OBJECT_INVALID) {

   effect eEffect = GetFirstEffect(oCreature);
   while(GetIsEffectValid(eEffect)) {
       if(GetEffectType(eEffect) == effectType
          && (oCreator == OBJECT_INVALID || oCreator == GetEffectCreator(eEffect))) {
           //db("Removing effect from " + GetTag(oCreature), -1,"",-1, TRUE, GetFirstPC());
               RemoveEffect(oCreature,eEffect);
       }
       eEffect = GetNextEffect(oCreature);
   }
}

void tbRemoveECEffect(object oCreature, object oCreator) {

        effect eEffect = GetFirstEffect(oCreature);
        while(GetIsEffectValid(eEffect)) {
                if(oCreator == GetEffectCreator(eEffect)) {
                        RemoveEffect(oCreature,eEffect);
                }
                eEffect = GetNextEffect(oCreature);
        }
}
// Makes the PC invisible for a fraction of a second. This causes everyone nearby to go back through 
// on perception code. Useful when chaning creatures to hostile to make sure they attack for example.
void tbForceRePerceivePC(object oPC) {
        //if (!GetIsPC(oPC)) return; // not sure this matters 
        if (GetIsObjectValid(oPC)) {
                effect eEff = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oPC, 0.05);
                DelayCommand(0.5, RemoveEffect(oPC, eEff));
        } 
}

// Function to do a private version of this skill check, no result
// is told to the PC
int GetIsSkillSuccessfulPrivate(object oTarget, int nSkill, int nDifficulty) {
    // Do the roll for the skill
    int nSr = GetSkillRank(nSkill, oTarget);
    int nRoll = d20();
    //db("Skill check rank =" + IntToString(nSr) +  " d20 = " , nRoll, " DC = ", nDifficulty);
    if ((nSr >= 0) &&  (nSr + nRoll) >= nDifficulty)
    {
        // They passed the DC
        //db("check passed");
        return TRUE;
    }
    // Failed the check
    return FALSE;
}


int GetHasClass( int iClass, object oCreature = OBJECT_SELF){
        if(!GetIsObjectValid( oCreature))
                return FALSE;
        return (GetLevelByClass(iClass, oCreature) >= 1);
}

// Returns the class of the highest level class the creature has attained.
int GetHighestClass(object oCreature = OBJECT_SELF){
        if( !GetIsObjectValid(oCreature)
            || (GetObjectType(oCreature) != OBJECT_TYPE_CREATURE))
                return 0;

        int iClass1 = GetClassByPosition( 1, oCreature);
        int iClass2 = GetClassByPosition( 2, oCreature);
        int iClass3 = GetClassByPosition( 3, oCreature);
        int nLevel1 = ((iClass1 != CLASS_TYPE_INVALID) ? GetLevelByPosition( 1, oCreature) : 0);
        int nLevel2 = ((iClass2 != CLASS_TYPE_INVALID) ? GetLevelByPosition( 2, oCreature) : 0);
        int nLevel3 = ((iClass3 != CLASS_TYPE_INVALID) ? GetLevelByPosition( 3, oCreature) : 0);

        if( nLevel1 >= nLevel2) {
                if(nLevel1 >= nLevel3)
                        return iClass1;
                return iClass3;
        } else if(nLevel2 >= nLevel3)
                return iClass2;
        return iClass3;
}

int GetIsSpellClass(int nClass, int nLevel = 1) {
        if (nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER
                || nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_DRUID
                || nClass == CLASS_TYPE_BARD) {
                return nLevel;
        }

        if (nClass == CLASS_TYPE_PALADIN || nClass == CLASS_TYPE_RANGER) {
                if (nLevel > 3) return nLevel - 3;
        }
        return 0;
}

int GetHighestSpellClass(object oCreature = OBJECT_SELF){
        if( !GetIsObjectValid(oCreature)
            || (GetObjectType(oCreature) != OBJECT_TYPE_CREATURE))
                return CLASS_TYPE_INVALID;

        int nHighest = 0;
        int nClass = CLASS_TYPE_INVALID;
        int i;
        for (i = 1; i < 4; i++) {
                int iClass = GetClassByPosition( i, oCreature);
                int nTmp = GetIsSpellClass(iClass, GetLevelByClass(iClass, oCreature));
                if (nTmp && nTmp > nHighest) {
                        nHighest = nTmp;
                        nClass = iClass;
                }
        }
        return  nClass;
}

// This function returns TRUE if the creature has at least 1 level in
//the requested class. If the bHighest is TRUE it will return TRUE only if the creature's highest class is the requested class.
int GetIsClass( int iClass, object oCreature = OBJECT_SELF,  int bHighest = FALSE){
        if(!GetHasClass( iClass, oCreature))
                return FALSE;

        if( bHighest) {
                int iHighest = GetHighestClass( oCreature);
                if( iHighest == iClass)
                        return TRUE;
                int iPos = 0;
                while( ++iPos <= 3)
                        if( (GetLevelByPosition( iPos, oCreature) >= iHighest) && (GetClassByPosition(iPos, oCreature) == iClass) )
                                return TRUE;
                return FALSE; }
        return TRUE;
}
// Convert a given EL equivalent and its encounter level,
// return the corresponding CR
float ConvertELEquivToCR(float fEquiv, float fEncounterLevel) {
    if (fEquiv == 0.0)
        return 0.0;
    /*
    float fCR, fEquivSq, fTemp;
    fEquivSq = fEquiv * fEquiv;
    fTemp = log(fEquivSq);
    fTemp /= log(2.0);
    fCR = fEncounterLevel + fTemp;
    */

    return fEncounterLevel + (log(fEquiv * fEquiv)/log(2.0));
}

// Convert a given CR to its encounter level equivalent per DMG page 101.
float ConvertCRToELEquiv(float fCR, float fEncounterLevel) {
    if(     fCR>fEncounterLevel
        ||  fCR<1.0
      )
        return 1.0;
/*
    float fEquiv, fExponent, fDenom;

    fExponent   = (fEncounterLevel - fCR)*0.5;
    fDenom      = pow(2.0, fExponent);
    fEquiv      =  1.0 / fDenom;
*/
    return (1.0 / pow(2.0, ((fEncounterLevel - fCR)*0.5) ) );
}

string GetClassName (int nClass) {
    // nClass - CLASS_* constant
    switch (nClass) {
        // Standard Classes
        case CLASS_TYPE_BARBARIAN: return "Barbarian";
        case CLASS_TYPE_BARD: return "Bard";
        case CLASS_TYPE_CLERIC: return "Cleric";
        case CLASS_TYPE_DRUID: return "Druid";
        case CLASS_TYPE_FIGHTER: return "Fighter";
        case CLASS_TYPE_MONK: return "Monk";
        case CLASS_TYPE_PALADIN: return "Paladin";
        case CLASS_TYPE_RANGER: return "Ranger";
        case CLASS_TYPE_ROGUE: return "Rogue";
        case CLASS_TYPE_SORCERER: return "Sorcerer";
        case CLASS_TYPE_WIZARD: return "Wizard";
        // Prestige Classes
        case CLASS_TYPE_ARCANE_ARCHER: return "ArcaneArcher";
        case CLASS_TYPE_ASSASSIN: return "Assassin";
        case CLASS_TYPE_BLACKGUARD: return "Blackguard";
        case CLASS_TYPE_DIVINE_CHAMPION: return "DivineChamp";
        case CLASS_TYPE_DRAGON_DISCIPLE: return "DragonDisc";
        case CLASS_TYPE_DWARVEN_DEFENDER: return "DwarvenDef";
        case CLASS_TYPE_HARPER: return "Harper";
        case CLASS_TYPE_PALE_MASTER: return "PaleMaster";
        case CLASS_TYPE_SHADOWDANCER: return "ShadowDancer";
        case CLASS_TYPE_SHIFTER: return "Shifter";
        case CLASS_TYPE_WEAPON_MASTER: return "WeaponMaster";
    }
    return "";
}


// Add nVal to local int variable sVar on oObj. Returns the new value
// of the variable.
int AddLocalInt(object oObj, string sVar, int nVal) {
        int nRet = GetLocalInt(oObj, sVar) + nVal;
        SetLocalInt(oObj, sVar, nRet);
        return nRet;
}

// Set the bits in nVal in the int variable sVar on oObj
// Return newly modified value. E.g. OrLocalInt(oPC, foo, 8) sets the 4th bit (bit # 3 starting at 0).
int OrLocalInt(object oObj, string sVar, int nVal) {
        int nRet = GetLocalInt(oObj, sVar) | nVal;
        SetLocalInt(oObj, sVar, nRet);
        return nRet;
}


// Apply the given visual effect to the given location as an instant.
void ApplyVisualAtLocation(int nVis, location lLoc) {
         effect eImpact = EffectVisualEffect(nVis);
           ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lLoc);
}

/* needs rename since aid has function with same name - but this is not currently used
// Get first object in the area that is not tagged with sTag.
object GetObjectInArea(object oArea, string sTag) {
        object oRet = GetFirstObjectInArea(oArea);
        while (GetTag(oRet) == sTag)
                oRet = GetNextObjectInArea(oArea);
        return oRet;
}
*/
// Get first object in the area that is tagged with sTag.
object GetObjectInAreaByTag(object oArea, string sTag) {
        object oRet = GetFirstObjectInArea(oArea);
        if (GetTag(oRet) != sTag)
                oRet = GetNearestObjectByTag(sTag, oRet);
        return oRet;
}

int tbGetIsEncounterCreature(object oCreature = OBJECT_SELF) {
        if (GetIsEncounterCreature(oCreature))
                return TRUE;

        if (GetIsObjectValid(GetLocalObject(oCreature, "EncCreatorObj")))
                return TRUE;

        if(GetLocalInt(oCreature, "encounter_creature"))
                return TRUE;

        return FALSE;
}


// Returns true if the given object is considered a fire for warmth and resting benefits.
// Must make sure any fire  you want to provide warmth or rest benefits has one of these tags
int tbGetIsFire(object oPlc) {
        string sTag = GetTag(oPlc);
         // TODO - make sure it's a lit fire -- I think this is okay - just don't put tags of unlit ones
         // in the conditional
        if (sTag == "rest_campfire" || sTag == "CookSpit" || sTag == "CampFire")
                return TRUE;

        return FALSE;
}


// Get the nearest lit campfire object.
object tbGetNearestFire(object oPC, float fMax = 6.0) {
        int nNth = 1;
        string sTag;
        object oFire = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth++);
        while (GetIsObjectValid(oFire) && GetDistanceBetween(oPC, oFire) <= fMax) {
                if (tbGetIsFire(oFire)) {
                        return oFire;
                }
                oFire = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth++);
        }

        return OBJECT_INVALID;
}

int GetIsTorchEquipped(object oPC) {
        object oTorch = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
        if (!GetIsObjectValid(oTorch)) return FALSE;

        string sTag = GetTag (oTorch);
        if (sTag == "tb_torch" || sTag == "tb_lantern")
               return TRUE;
        return FALSE;
}
// Cribbed from nw_i0_spell so that other code can use it.
float tbGetRandomDelay(float fMinimumTime = 0.4, float MaximumTime = 1.1) {
        if(fMinimumTime<MaximumTime) {
               float fRandom = MaximumTime-fMinimumTime;
               int nRandom = FloatToInt(fRandom*10.0);
               nRandom = Random(nRandom+1);
               fRandom = IntToFloat(nRandom);
               fRandom /= 10.0;
               return fRandom + fMinimumTime;
        }
        return 0.0;
}

// Get amount of XP needed for PC to next level or to keep at current level
int GetXPNeededByPC(object oPC, int bNext = TRUE) {
    int nLevel  = GetHitDice(oPC);
    if(bNext){++nLevel;}

    int nXP = (nLevel * (nLevel - 1)) / 2 * 1000;
    /*
    switch (nLevel)
    {
        case 0:  nXP=     0; break;
        case 1:  nXP=  1000; break;
        case 2:  nXP=  3000; break;
        case 3:  nXP=  6000; break;
        case 4:  nXP= 10000; break;
        case 5:  nXP= 15000; break;
        case 6:  nXP= 21000; break;
        case 7:  nXP= 28000; break;
        case 8:  nXP= 36000; break;
        case 9:  nXP= 45000; break;
        case 10: nXP= 55000; break;
        case 11: nXP= 66000; break;
        case 12: nXP= 78000; break;
        case 13: nXP= 91000; break;
        case 14: nXP=105000; break;
        case 15: nXP=120000; break;
        case 16: nXP=136000; break;
        case 17: nXP=153000; break;
        case 18: nXP=171000; break;
        case 19: nXP=190000; break;
        case 20: nXP=210000; break;
    }
        */

    if(bNext)
        nXP = nXP - GetXP(oPC);

    return nXP;
}

// Take XP from a PC. If bLevel is TRUE this is allowed to lower levels, otherwise
// this will take as much as possible but leave the PC at current level.
void ApplyXPPenalty(object oPC, int nPenalty, int bLevel = FALSE) {

        int nCurXP = GetXP(oPC);
        int nThisLevel = GetXPNeededByPC(oPC, FALSE);

        SendMessageToPC(oPC, "XP penalty - thislevel = " + IntToString(nThisLevel) + " vs current XP = " + IntToString(nCurXP)
                + " penalty = " + IntToString(nPenalty));

        int nMax = nCurXP - nThisLevel;
        if (bLevel)
              nMax = nCurXP;

        if (nPenalty > nMax)
             nPenalty = nMax - 1;
        if (nPenalty <= 0) {
                return;
        }

        SendMessageToPC(oPC, "XP penalty - " + IntToString(nPenalty) + " new xp = " + IntToString(nCurXP - nPenalty));
        nCurXP = nCurXP - nPenalty;
        SetXP(oPC, nCurXP);
}

object getNearestChair(object oPC, float fDist) {

        object oChair;
        int nNth = 1;
        oChair = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth ++);
        while(GetIsObjectValid(oChair) && GetDistanceBetween(oPC, oChair) <= fDist) {
             string sTag = GetStringLowerCase(GetTag(oChair));
        // Other tags or names to auto detect
                // don't count zep broken chairs
                if ( FindSubString(sTag, "bchair") > -1) {
                     oChair = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth ++);
                     continue;
                }
                if (sTag == "chair" || (FindSubString(sTag, "chair") > -1) || GetLocalInt(oChair, "CHAIR")) {
                        // Check for usable or is that non needed?
                        // Check for occupied
                        if(!GetIsObjectValid(GetSittingCreature(oChair))) {
                                return oChair;
                        }
                }
                oChair = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth ++);
        }
        return OBJECT_INVALID;
}

////////////////////
//Created by OwChallie
// Used to create a number of objects around a given location
// nObjectType - the type of object to be created, OBJECT_TYPE_*
// sObjectTag  - the tag of the objects to be created
// nNoOfSides  - the number of sides the shape has
// lMidPoint   - the mid point of the shape
// fSize       - the size of the shape
// sNewTag     - the new tag of the object created being sNewTag1 to sNewTagn,
//               n being the number specified by nNoOfSides
// fObjectLife - the number of seconds the object exists (0.0 for infinite)
void CreateObjectsInShape(int nObjectType, string sObjectTag, int nNoOfSides, location lMidPoint, float fSize, string sNewTag="", float fObjectLife=0.0);
void CreateObjectsInShape(int nObjectType, string sObjectTag, int nNoOfSides, location lMidPoint, float fSize, string sNewTag, float fObjectLife) {
        object oObject, oArea = GetAreaFromLocation(lMidPoint);
        float fFacing = GetFacingFromLocation(lMidPoint);
        float fAngle, fNewX, fNewY;
        int nLooper;
        vector vPos = GetPositionFromLocation(lMidPoint);
        vector vNewPos;
        location lNewLoc;
        string sTag;
        for (nLooper = 0; nLooper < nNoOfSides; nLooper++) {
                if (sNewTag != "") {
                        sTag = sNewTag + IntToString(nLooper + 1);
                }
                fAngle = IntToFloat(360 / nNoOfSides) * IntToFloat(nLooper);
                vNewPos = vPos + (fSize * AngleToVector(fFacing + fAngle));
                lNewLoc = Location(oArea, vNewPos, fFacing + fAngle);
                oObject = CreateObject(nObjectType, sObjectTag, lNewLoc, TRUE, sTag);
                if (fObjectLife != 0.0)  {
                        DestroyObject(oObject, fObjectLife);
                }
      }
}

//useful for NPCs to give players "directions"
string GetCompassDirectionToObject(float fFacing, object oCaster, object oCreature, float nDistance) {
   //Correct the bug in GetFacing
        if (fFacing >= 360.0)
                fFacing  =  720.0 - fFacing;
        if (fFacing <    0.0)
                fFacing += (360.0);

        int iFacing = FloatToInt(fFacing);
        string sDirection = "";
   
        if     ((iFacing >= 359) && (iFacing <=   2)) sDirection = "East of here";
        else if((iFacing >=   3) && (iFacing <=  45)) sDirection = "North East East of here";
        else if((iFacing >=  46) && (iFacing <=  87)) sDirection = "North North East of here";
        else if((iFacing >=  88) && (iFacing <=  92)) sDirection = "North of here";
        else if((iFacing >=  93) && (iFacing <= 135)) sDirection = "North North West from here";
        else if((iFacing >= 136) && (iFacing <= 177)) sDirection = "North West West from here";
        else if((iFacing >= 178) && (iFacing <= 182)) sDirection = "West from here";
        else if((iFacing >= 183) && (iFacing <= 225)) sDirection = "South West West of here";
        else if((iFacing >= 226) && (iFacing <= 267)) sDirection = "South South West of here";
        else if((iFacing >= 268) && (iFacing <= 272)) sDirection = "South of here";
        else if((iFacing >= 273) && (iFacing <= 315)) sDirection = "South South West of here";
        else if((iFacing >= 316) && (iFacing <= 358)) sDirection = "South East East from here";
   
        string sDistance = IntToString(FloatToInt(nDistance));
        //SendMessageToPC(oCaster, "It is about " +sDistance +" meters to the " + sDirection);
        return "It is about " +sDistance +" meters to the " + sDirection;
}

//Change the tile lighting in an area:
//
void ChangeLightingInArea(object oArea, int iMainLight1, int iMainLight2, int iSourceLight1, int iSourceLight2, int iWidth = 8, int iHeight = 8) {
        int x;
        int y;
        location lTile;
        for (x = 0; x <= iWidth; x++) {
                for (y = 0; y <= iHeight; y++) {
                        lTile = Location(oArea, Vector (IntToFloat(x), IntToFloat(y)), 0.0);
                        SetTileMainLightColor(lTile, iMainLight1, iMainLight2);
                        SetTileSourceLightColor(lTile, iSourceLight1, iSourceLight2);
                }
        }
}
/*
int bh_able_to_talk(object oNPC, int bRespectStealth = TRUE) {
  if (GetHasEffect(EFFECT_TYPE_CONFUSED, oNPC) || GetHasEffect(EFFECT_TYPE_DOMINATED, oNPC) ||
      GetHasEffect(EFFECT_TYPE_PETRIFY, oNPC) || GetHasEffect(EFFECT_TYPE_PARALYZE, oNPC)   ||
      GetHasEffect(EFFECT_TYPE_STUNNED, oNPC) || GetHasEffect(EFFECT_TYPE_FRIGHTENED, oNPC))
    return FALSE;

  if (IsInConversation(oNPC))                         return FALSE;
  if (GetIsInCombat(oNPC))                            return FALSE;
  if (GetCommandable(oNPC) == FALSE)                  return FALSE;
  if (GetStealthMode(oNPC) == STEALTH_MODE_ACTIVATED)
    if (bRespectStealth)                              return FALSE;
  return TRUE;
}
*/
