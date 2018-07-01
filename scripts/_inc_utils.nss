// _inc_utils.nss
// This is a set of utility functions that don't require other scripts.
// Safe to include where needed.

#include "x2_inc_itemprop"
#include "_inc_constants"

// TEMP for debugging
#include "00_debug"

// TIME ------------------------------------------------------------------------
// adjust this number based on module time settings (duration of game hours in minutes)
// 30 for each game hour lasts 2 minutes
// 3 for each game hour lasts 20 minutes
//const int IGMINUTES_PER_RLMINUTE    = 3;
// indicate time denomination
//const int TIME_MILLISECONDS = 1; // not a good one.
const int TIME_SECONDS              = 2;
const int TIME_MINUTES              = 3;
const int TIME_HOURS                = 4;
const int TIME_DAYS                 = 5;
const int TIME_MONTHS               = 6;
const int TIME_YEARS                = 7;

// returns TRUE if OBJECT_SELF or the Area has been flagged OUT_OF_CHARACTER - [FILE: _inc_util]
// meaning that the PC or the Area are currently out of play, no enforced roleplay, no persistence, etc....
int IsOOC(object oCreature=OBJECT_SELF);

// applies temporary strength damage. - [FILE: _inc_util]
void GivePCFatigue(object oPC=OBJECT_SELF);
// checks whether oWeapon does slashing damage. - [FILE: _inc_util]
int GetIsSlashingWeapon(object oWeapon);
// Checks oPC equipped items for a slashing weapon - [FILE: _inc_util]
int GetIsWieldingSlashingWeapon(object oPC);
// Checks oPC equipped items for a flame (torch or flaming weapon) - [FILE: _inc_util]
int GetIsWieldingFlame(object oPC);
// Checks oPC equipped items for an Axe-like tool - [FILE: _inc_util]
int GetIsWieldingAxe(object oPC);
// Checks oPC equipped items for an Hammer-like tool - [FILE: _inc_util]
int GetIsWieldingHammer(object oPC);
// Checks oPC equipped items for a Knife-like tool - [FILE: _inc_util]
int GetIsWieldingKnife(object oPC);



// Returns the first prefix of a tag, without the underscore - [FILE: _inc_util]
string GetTagPrefix(string sTag);
//Returns the number of henchmen oPC has employed - [FILE: _inc_util]
//Returns -1 if oPC isn't a valid PC
int GetNumHenchmen(object oPC);

// Moves equipped items from oSource to oTarget - [FILE: _inc_util]
// if oSource is not a creature, it does nothing.
// if oTarget is a creature, oTarget equips the items
int MoveEquippedItems(object oSource, object oTarget, int copy=FALSE);
// Moves all of inventory from oSource to oTarget - [FILE: _inc_util]
// returns number of items moved
int MoveInventory(object oSource, object oTarget, int copy=FALSE);
// Deletes all items and gold from inventory of oTarget - [FILE: _inc_util]
void StripInventory(object oTarget, int strip_inventory=TRUE, int strip_gold=TRUE, int strip_equipped=TRUE, int is_npc=FALSE);
// removes effects of effect_type. - [FILE: _inc_util]
// if effect_type = -1, all effects stripped
void RemoveEffectsByType(object target, int effect_type=-1);
struct DATETIME
{
    int year, month, day, hour, minute, second;
};
// Return current IG time measured since the epoch - [FILE: _inc_util]
// default time returned is minutes, also works for seconds, hours and days
int GetTimeCumulative(int nTime=TIME_MINUTES);
// Return game seconds to elapse over real seconds - [FILE: _inc_util]
int ConvertRealSecondsToGameSeconds(int nRealSeconds);
// Return DATETIME from sTimeStamp  [FILE: _inc_util]
// if this is REAL TIME - set gametime to FALSE
struct DATETIME ConvertTimeStampToDateTime(string sTimeStamp, int gametime=TRUE);
// Return timestamp from DATETIME  [FILE: _inc_util]
// if this is REAL TIME - set gametime to FALSE
string ConvertDateTimeToTimeStamp(struct DATETIME time, int gametime=TRUE);
// Return timestamp when id of type sEntity was created (nwnx_odbc2) - [FILE: _inc_util]
// sEntity is the string of the type of thing (table name), id is its ID in the DB
// timestamp is in real time
/////////////////////////////////

int IsOOC(object oCreature=OBJECT_SELF)
{
    if(     GetLocalInt(GetArea(oCreature), "OUT_OF_CHARACTER")
        ||  GetLocalInt(oCreature, "OUT_OF_CHARACTER")
      )
        return TRUE;
    else
        return FALSE;
}

void GivePCFatigue(object oPC=OBJECT_SELF)
{
    if((GetAbilityScore(oPC,ABILITY_STRENGTH,TRUE)-GetAbilityScore(oPC,ABILITY_STRENGTH))<6)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                            EffectAbilityDecrease(ABILITY_STRENGTH,1),
                            oPC,
                            120.0
                            );
    }
    string sPossessive  = "his";
    if(GetGender(oPC)==GENDER_FEMALE)
        sPossessive = "her";
    FloatingTextStringOnCreature(RED+GetName(oPC)+" is fatigued by "+sPossessive+" efforts!", oPC);
}

int GetIsSlashingWeapon(object oWeapon)
{
    int nItemType   = GetBaseItemType(oWeapon);
    if( nItemType==BASE_ITEM_INVALID )
        return FALSE;

    string sDam     = Get2DAString("baseitems", "WeaponType", nItemType);
    int nDam        = StringToInt(sDam);

    if(     nDam==3
        ||  nDam==4
      )
        return TRUE;
    else
        return FALSE;
}

int GetIsWieldingSlashingWeapon(object oPC)
{
    object oLeft    = GetItemInSlot( INVENTORY_SLOT_LEFTHAND,oPC);
    object oRight   = GetItemInSlot( INVENTORY_SLOT_RIGHTHAND,oPC);

    if(     GetIsSlashingWeapon(oLeft)
        ||  GetIsSlashingWeapon(oRight)
      )
        return TRUE;
    else
    {
        int bSuccess;
        itemproperty ip = GetFirstItemProperty(oLeft);
        while( GetIsItemPropertyValid(ip) && bSuccess==FALSE )
        {
            if(ip==ItemPropertyExtraMeleeDamageType(IP_CONST_DAMAGETYPE_SLASHING))
                bSuccess==TRUE;
            ip = GetNextItemProperty(oLeft);
        }
        ip = GetFirstItemProperty(oRight);
        while( GetIsItemPropertyValid(ip) && bSuccess==FALSE )
        {
            if(ip==ItemPropertyExtraMeleeDamageType(IP_CONST_DAMAGETYPE_SLASHING))
                bSuccess==TRUE;
            ip = GetNextItemProperty(oRight);
        }
        return bSuccess;
    }
}

int GetIsWieldingFlame(object oPC)
{
    object oLeft    = GetItemInSlot( INVENTORY_SLOT_LEFTHAND,oPC);
    object oRight   = GetItemInSlot( INVENTORY_SLOT_RIGHTHAND,oPC);
    int nItemTypeL, nItemTypeR;
    if(GetIsObjectValid(oLeft))
        nItemTypeL  = GetBaseItemType(oLeft);

    string sLightType = GetLocalString(oLeft, "LIGHTABLE_TYPE");
    if( nItemTypeL==BASE_ITEM_TORCH && sLightType=="torch" )
        return TRUE;
    else
    {
        if(GetIsObjectValid(oRight))
        {
            itemproperty ipR    = GetFirstItemProperty(oRight);
            while(GetIsItemPropertyValid(ipR))
            {
                if(GetItemPropertyParam1(ipR)==0 && GetItemPropertyParam1Value(ipR)==10)
                    return TRUE;
                ipR = GetNextItemProperty(oRight);
            }
        }
        if(GetIsObjectValid(oLeft))
        {
            itemproperty ipL    = GetFirstItemProperty(oLeft);
            while(GetIsItemPropertyValid(ipL))
            {
                if(GetItemPropertyParam1(ipL)==0 && GetItemPropertyParam1Value(ipL)==10)
                    return TRUE;
                ipL = GetNextItemProperty(oLeft);
            }
        }
    }
    return FALSE;
}

int GetIsWieldingAxe(object oPC)
{
    object oLeft    = GetItemInSlot( INVENTORY_SLOT_LEFTHAND,oPC);
    object oRight   = GetItemInSlot( INVENTORY_SLOT_RIGHTHAND,oPC);

    if(GetIsObjectValid(oLeft))
    {
        int nItemTypeL  = GetBaseItemType(oLeft);
        if(     nItemTypeL==BASE_ITEM_BATTLEAXE
            ||  nItemTypeL==BASE_ITEM_DWARVENWARAXE
            ||  nItemTypeL==BASE_ITEM_GREATAXE
            ||  nItemTypeL==BASE_ITEM_HANDAXE
            ||  nItemTypeL==BASE_ITEM_SCIMITAR
          )
            return TRUE;
    }
    if(GetIsObjectValid(oRight))
    {
        int nItemTypeR  = GetBaseItemType(oRight);
        if(     nItemTypeR==BASE_ITEM_BATTLEAXE
            ||  nItemTypeR==BASE_ITEM_DWARVENWARAXE
            ||  nItemTypeR==BASE_ITEM_GREATAXE
            ||  nItemTypeR==BASE_ITEM_HANDAXE
            ||  nItemTypeR==BASE_ITEM_SCIMITAR
          )
            return TRUE;
    }

    return FALSE;
}

int GetIsWieldingHammer(object oPC)
{
    object oLeft    = GetItemInSlot( INVENTORY_SLOT_LEFTHAND,oPC);
    object oRight   = GetItemInSlot( INVENTORY_SLOT_RIGHTHAND,oPC);

    if(GetIsObjectValid(oLeft))
    {
        int nItemTypeL  = GetBaseItemType(oLeft);
        if(     nItemTypeL==BASE_ITEM_LIGHTHAMMER
            ||  nItemTypeL==BASE_ITEM_LIGHTMACE
            ||  nItemTypeL==BASE_ITEM_WARHAMMER
            ||  nItemTypeL==BASE_ITEM_MAUL
          )
            return TRUE;
    }
    if(GetIsObjectValid(oRight))
    {
        int nItemTypeR  = GetBaseItemType(oRight);
        if(     nItemTypeR==BASE_ITEM_LIGHTHAMMER
            ||  nItemTypeR==BASE_ITEM_LIGHTMACE
            ||  nItemTypeR==BASE_ITEM_WARHAMMER
            ||  nItemTypeR==BASE_ITEM_MAUL
          )
            return TRUE;
    }

    return FALSE;

}

int GetIsWieldingKnife(object oPC)
{
    object oLeft    = GetItemInSlot( INVENTORY_SLOT_LEFTHAND,oPC);
    object oRight   = GetItemInSlot( INVENTORY_SLOT_RIGHTHAND,oPC);
    if(GetIsObjectValid(oLeft))
    {
        int nItemTypeL  = GetBaseItemType(oLeft);
        if(     nItemTypeL==BASE_ITEM_DAGGER
            ||  nItemTypeL==BASE_ITEM_KUKRI
            ||  nItemTypeL==309// assassin dagger
            ||  nItemTypeL==310// katar
          )
            return TRUE;
    }
    if(GetIsObjectValid(oRight))
    {
        int nItemTypeR  = GetBaseItemType(oRight);
        if(     nItemTypeR==BASE_ITEM_DAGGER
            ||  nItemTypeR==BASE_ITEM_KUKRI
            ||  nItemTypeR==309// assassin dagger
            ||  nItemTypeR==310// katar
          )
            return TRUE;
    }

    return FALSE;
}

string GetTagPrefix(string sTag)
{
    string sTagPrefix   = "";
    int iPos1           = FindSubString(sTag, "_");
    int iPos2;
    int iLastPos        = GetStringLength(sTag)-1;

    if (iPos1 > 0)
    {
        sTagPrefix   = GetStringLeft(sTag, iPos1); // returns prefix without underscores
    }
    else if (iPos1 == 0)
    {
        // we have a leading underscore
        iPos2 = FindSubString(sTag, "_", ++iPos1);// look for a second underscore
        if (iPos2 != -1 && iPos2 != 1 && iPos2 != iLastPos) // ignore: _XXXXX , __XXXX , _XXXX_
        {
            sTagPrefix  = GetSubString(sTag, iPos1, iPos2 - iPos1);
        }
    }

    return GetStringLowerCase(sTagPrefix);
}

int GetNumHenchmen(object oPC)
{
    if (!GetIsPC(oPC)) return -1;

    int nLoop, nCount;
    for (nLoop=1; nLoop<=GetMaxHenchmen(); nLoop++)
    {
        if (GetIsObjectValid(GetHenchman(oPC, nLoop)))
            nCount++;
    }
    return nCount;
}
int MoveEquippedItems(object oSource, object oTarget, int copy=FALSE)
{
        string sSource;
        string sTarget;
        if (GetIsPC(oSource)) sSource = GetName(oSource);
        else sSource = GetTag(oSource);

        if (GetIsPC(oTarget)) sTarget = GetName(oTarget);
        else sTarget = GetTag(oTarget);

        dbstr("MoveEquipped called " + sSource + " to " + sTarget + " copy = " + IntToString(copy));
    // this function is unnecessary, if the source is not a creature
        if(!GetObjectType(oSource)==OBJECT_TYPE_CREATURE) return 0;

    object oItem, oCopy; int nCount, nSlot;
    int target_is_creature  = (GetObjectType(oTarget)==OBJECT_TYPE_CREATURE);

    for (nSlot=0; nSlot<14; nSlot++)
    {
        oItem    = GetItemInSlot(nSlot,oSource);
        if( GetIsObjectValid(oItem) && !GetLocalInt(oItem,"COPIED") )
        {
            nCount++;
            oCopy   = CopyItem(oItem, oTarget, TRUE);
            SetLocalInt(oItem,"COPIED",TRUE);
            DelayCommand(0.2,DeleteLocalInt(oItem,"COPIED"));
            SetLocalInt(oCopy,"EQUIPPED_SLOT", nSlot+100);
            dbstr(GetName(oCopy) + " to " + sTarget + " slot =" + IntToString(nSlot + 100));
            if(!copy)
                DestroyObject(oItem, 0.1);
            else
            {
                SetLocalObject(oCopy,"PAIRED",oItem);
                SetLocalObject(oItem,"PAIRED",oCopy);
            }

            if(target_is_creature)
            {
                dbstr(sTarget + " equipping " + GetName(oCopy));
                AssignCommand(oTarget,ActionEquipItem(oCopy,nSlot));
                DelayCommand(0.1, AssignCommand(oTarget,ActionEquipItem(oCopy,nSlot)));
            }

        }
    }

    return nCount;
}

int MoveInventory(object oSource, object oTarget, int copy=FALSE)
{
    object oItem, oCopy; int nCount;
    string sSource;
    string sTarget;
    if (GetIsPC(oSource)) sSource = GetName(oSource);
    else sSource = GetTag(oSource);

    if (GetIsPC(oTarget)) sTarget = GetName(oTarget);
    else sTarget = GetTag(oTarget);

    if(GetObjectType(oSource)==OBJECT_TYPE_CREATURE)
    {
        if(!GetLocalInt(oSource,"GOLD_MOVED"))
        {
            // move gold
            int nGold   = GetGold(oSource);
            if(nGold)
            {
                SetLocalInt(oSource,"GOLD_MOVED",TRUE);
                DelayCommand(0.2, DeleteLocalInt(oSource,"GOLD_MOVED"));
                if(!copy)
                {
                    AssignCommand(oTarget, TakeGoldFromCreature(nGold, oSource,FALSE));
                    DelayCommand(0.1, TakeGoldFromCreature(nGold, oSource,TRUE));
                }
                else
                {
                    if(GetObjectType(oTarget)==OBJECT_TYPE_CREATURE)
                        GiveGoldToCreature(oTarget,nGold);
                    else
                        CreateItemOnObject("nw_it_gold001",oTarget,nGold);
                }
                ++nCount;
            }
        }
    }

    // copy containers
    oItem    = GetFirstItemInInventory(oSource);
    while(GetIsObjectValid(oItem))
    {
        if(GetHasInventory(oItem)&&!GetLocalInt(oItem,"COPIED"))
        {
            nCount++;
            // create a copy of the container
            if(GetObjectType(oTarget)!=OBJECT_TYPE_ITEM)
                oCopy   = CreateItemOnObject(GetResRef(oItem), oTarget, 1, GetTag(oItem));
            else
            {
                oCopy   = CreateObject(OBJECT_TYPE_ITEM, GetResRef(oItem), GetLocation(oSource), FALSE, GetTag(oItem));
                AssignCommand(oSource, SpeakString("*"+GetName(oItem)+" falls out*") );
                AssignCommand(oSource, PlaySound("it_genericmedium") );
            }

            SetLocalInt(oItem, "COPIED", TRUE); // mark the original as copied
            DelayCommand(0.1,DeleteLocalInt(oItem,"COPIED"));
            SetName(oCopy, GetName(oItem));
            SetDescription(oCopy, GetDescription(oItem));
            SetIdentified(oCopy, GetIdentified(oItem));
            // copy contents of container
            nCount = MoveInventory(oItem,oCopy,copy);
            if(!copy)
                DestroyObject(oItem, 0.2);
            else
            {
                SetLocalObject(oCopy,"PAIRED",oItem);
                SetLocalObject(oItem,"PAIRED",oCopy);
            }
        }

        oItem   = GetNextItemInInventory(oSource);
    }
    // copy items
    oItem    = GetFirstItemInInventory(oSource);
    while(GetIsObjectValid(oItem))
    {
        if(!GetHasInventory(oItem)&&!GetLocalInt(oItem,"COPIED"))
        {
            nCount++;
            oCopy = CopyItem(oItem, oTarget, TRUE);

            // if the intended target did not receive it, force the current possessor to give it
            object oPossessor = GetItemPossessor(oCopy);
            if( oPossessor!=oTarget )
                AssignCommand(oPossessor, ActionGiveItem(oCopy,oTarget));
 
            SetLocalInt(oItem, "COPIED", TRUE);
            DelayCommand(0.1,DeleteLocalInt(oItem,"COPIED"));
            if(!copy)
                DestroyObject(oItem, 0.1);
            else
            {
                SetLocalObject(oCopy,"PAIRED",oItem);
                SetLocalObject(oItem,"PAIRED",oCopy);
            }
        }

        oItem   = GetNextItemInInventory(oSource);
    }

    return nCount;
}

void StripInventory(object oTarget, int strip_inventory=TRUE, int strip_gold=TRUE, int strip_equipped=TRUE, int is_npc=FALSE)
{
    DestroyObject(GetItemPossessedBy(oTarget,"x2_it_emptyskin"));

    object oItem;
    if(GetObjectType(oTarget)==OBJECT_TYPE_CREATURE)
    {
      if(strip_gold)
      {
        int nGold   = GetGold(oTarget);
        if(nGold)
            TakeGoldFromCreature(nGold, oTarget, TRUE);
      }

      if(strip_equipped)
      {
        int nSlot;
        for (nSlot=0; nSlot<14; nSlot++)
        {
            oItem   = GetItemInSlot(nSlot,oTarget);
            if( GetIsObjectValid(oItem) ) {
		    AssignCommand(oTarget, ActionUnequipItem(oItem));
		    SetDroppableFlag(oItem, FALSE);
		    DestroyObject(oItem);
	    }
        }
      }
      if(is_npc)
      {
	 int nSlot;
	 for (nSlot=14; nSlot<18; nSlot++)
	 {
            oItem   = GetItemInSlot(nSlot,oTarget);
            if( GetIsObjectValid(oItem) ) {
		    AssignCommand(oTarget, ActionUnequipItem(oItem));
		    SetDroppableFlag(oItem, FALSE);
		    DestroyObject(oItem);
	    }
        }
      }
    }

    if(strip_inventory)
    {
        oItem   = GetFirstItemInInventory(oTarget);
        while(GetIsObjectValid(oItem))
        {
            DestroyObject(oItem);
            oItem   = GetNextItemInInventory(oTarget);
        }
    }
}
void RemoveEffectsByType(object target, int effect_type=-1)
{
    // remove effects of type
    effect eEffect = GetFirstEffect(target);
    if(effect_type == -1)
    {
        while(GetIsEffectValid(eEffect))
        {
            RemoveEffect(target,eEffect);

            eEffect = GetNextEffect(target);
        }
    }
    else
    {
        while(GetIsEffectValid(eEffect))
        {
            if( GetEffectType(eEffect) == effect_type )
                RemoveEffect(target,eEffect);

            eEffect = GetNextEffect(target);
        }
    }
}


int GetTimeCumulative(int nTime=TIME_MINUTES)
{
    object oMod = GetModule();
    int iYear       = GetCalendarYear() - GetLocalInt(oMod,"EPOCH_YEAR");
    int iMonth      = GetCalendarMonth()- GetLocalInt(oMod,"EPOCH_MONTH");
    int iDay        = GetCalendarDay()  - GetLocalInt(oMod,"EPOCH_DAY");

    int nRLMinutes = GetLocalInt(oMod, "IGMINUTES_PER_RLMINUTE");

    if(nTime==TIME_MINUTES)
    {
        return( (GetTimeMinute()*nRLMinutes) + ((GetTimeHour()+((iDay+((iMonth+(iYear*12))*28))*24))*60) );
    }
    else if (nTime==TIME_HOURS)
    {
        return (GetTimeHour()+((iDay+((iMonth+(iYear*12))*28))*24));
    }
    // can only handle about 60 years worth of cumaltive seconds
    else if (nTime==TIME_SECONDS)
    {
        return(GetTimeSecond()
                        +(
                          (
                            (GetTimeMinute()*nRLMinutes) + ((GetTimeHour()+((iDay+((iMonth+(iYear*12))*28))*24))*60)
                          )*60
                         )
                    );
    }
    else if (nTime==TIME_DAYS)
    {
        return(iDay+((iMonth+(iYear*12))*28));
    }

    // return minutes as default
    return( ((GetTimeMinute()*nRLMinutes)+ ((GetTimeHour()+((iDay+((iMonth+(iYear*12))*28))*24))*60) ) );
}

int ConvertRealSecondsToGameSeconds(int nRealSeconds) {

	int nGameMinutes    = (nRealSeconds/60)*GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE");
	int nGameSeconds    = (nGameMinutes*60)+(nRealSeconds%60);

	return nGameSeconds;
}

struct DATETIME ConvertTimeStampToDateTime(string sTimeStamp, int gametime=TRUE)
{
    struct DATETIME time;

    // 0 if this is real time, 1 if this is game time
    // timestamp length changes due to year ranges altering
    int g =   (gametime!=FALSE);

    time.year   = StringToInt(GetSubString(sTimeStamp,0,4+g));
    time.month  = StringToInt(GetSubString(sTimeStamp,5+g,2));
    time.day    = StringToInt(GetSubString(sTimeStamp,8+g,2));
    time.hour   = StringToInt(GetSubString(sTimeStamp,11+g,2));
    time.minute = StringToInt(GetSubString(sTimeStamp,14+g,2));
    time.second = StringToInt(GetSubString(sTimeStamp,17+g,2));

    return time;
}

string ConvertDateTimeToTimeStamp(struct DATETIME time, int gametime=TRUE)
{
    string timestamp;

    int yln =   4;
    if(gametime){yln = 5;}

    string year     = IntToString(time.year);
           year     = (GetStringLength(year)<yln)? GetStringLeft("00000", yln-GetStringLength(year))+year : year;
    string month    = IntToString(time.month);
           month    = (GetStringLength(month)<2)? GetStringLeft("0000", 2-GetStringLength(month))+month : month;
    string day      = IntToString(time.day);
           day      = (GetStringLength(day)<2)? GetStringLeft("0000", 2-GetStringLength(day))+day : day;
    string hour     = IntToString(time.hour);
           hour     = (GetStringLength(hour)<2)? GetStringLeft("0000", 2-GetStringLength(hour))+hour : hour;
    string minute   = IntToString(time.minute);
           minute   = (GetStringLength(minute)<2)? GetStringLeft("0000", 2-GetStringLength(minute))+minute : minute;
    string second   = IntToString(time.second);
           second   = (GetStringLength(second)<2)? GetStringLeft("0000", 2-GetStringLength(second))+second : second;

    return (year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second);
}
