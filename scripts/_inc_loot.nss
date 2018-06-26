//::///////////////////////////////////////////////
//:: _inc_loot
//:://////////////////////////////////////////////
/*
    MAGUS LOOT SYSTEM

    incorporates SOU treasure system from NWN.

    LOCAL VARIABLES

    LOOT            int     0 = no loot, 1 or more indicates the max number of items to create in loot
    LOOT_ONCE       int     1 = this object will only generate loot once per module load
    LOOT_PERIOD     int     time in game minutes between loot spawns. if unset, the default is used.
    LOOT_TYPE       string  a space delimited list of any number of treasure types. see below.
    LOOT_ITEM_ONCE  int     1 = duplicates from non-custom lists will only spawn once.
    LOOT_ONLY_QUALITY int   1 = non custom items will always be better than minimum value
    LOOT_LEVEL_ADJ  int     1 = min and max value of treasure is set by level, but never more than LOOT_VALUE_MAX and never less than LOOT_VALUE_MIN
    LOOT_VALUE_MAX  int     maximum GP value of loot (if an item puts total loot value over max, the item is destroyed)
    LOOT_VALUE_MIN  int     minimum GP value of loot (if total loot value is less than minimum, the remainder is gold)
    LOOT_REMAINDER  int     0 = no remainder, 1 = top off with coins

    LOOT TYPES:
        - "coins" type generates gold coins at random between min and max
        - "custom" type picks one item at random from a pseudo array defined as follows:
        LOOT_CUSTOM     int     length of custom loot pseduo-array
        LOOT_CUSTOM_ONCE int    1 = duplicates of custom items will not be spawned. (Each item on list only spawns once per loot)
        LOOT_CUSTOM_1   string  resref of loot item #1
        LOOT_CUSTOM_,,, string  another resref of a custom loot item
        - other than these 2 special types this sould be the tag of a store, the inventory of which will contain a list of possible loot items

        - following the tag or special type you can use a % followed by 2 digits to indicate percentage.

    example:
        LOOT        = 10
        LOOT_TYPE   = loot_store1%99   coins%20   loot_weapons%15   loot_junk%34

    note that the percentage does not need to add up to 100%.
    Percentage for coins indicates % of total loot to be made up of coins.
    Percentage for custom or a merchant indicates the maximum number of items to be possibly generated from this source.
    So for our example loot_store1 will generate at most 9 items. loot_weapons 1, loot_junk 3
    coins will be generated first (because thats how treasure is generated) and comprise up to 20% of the total value of the loot

*/
//:://////////////////////////////////////////////
//:: Created:   magus (2016 mar 1)
//:: Modified:
//:://////////////////////////////////////////////

// Shadows Of Undrentide treasure system (with a few small changes for compatibility)
#include "x0_i0_treasure"

//#include "_inc_constants"
#include "_inc_util"
#include "_inc_color"

// DECLARATIIONS ---------------------------------------------------------------

// initialize the set of possible items for the container [File: _inc_loot]
int LootInitPossibleList(string sLootTypes, int nMaxItems, int nMaxValue, int nMinValue, object oContainer);
// removes this item from the possible list [File: _inc_loot]
void LootSetItemImpossible(string sItem, object oContainer);
// returns a count of all the items on the "possible" subset [File: _inc_loot]
int LootGetPossibleCount(object oContainer);
// returns a min or max value for loot based on level [File: _inc_loot]
int LootGetLevelAdjValue(int nLevel, int nMin, int nMax, int return_max=TRUE);
// generates a random amount of gold in a container [File: _inc_loot]
// range of gold is between nLow and nHigh
// return value equals amount of gold created
int LootCreateGold(int nHigh, int nLow, object oContainer=OBJECT_SELF);
// master function which generates loot for a container [File: _inc_loot]
void LootGenerate(object oLooter, object oContainer=OBJECT_SELF);
// Calculate item drop for creatures killed by PC. - [FILE: _inc_loot]
void LootCreatureDeath(object oCreature, object oKiller=OBJECT_INVALID);


// IMPLEMENTATIONS -------------------------------------------------------------

int LootInitPossibleList(string sLootTypes, int nMaxItems, int nMaxValue, int nMinValue, object oContainer)
{
    // prep possible set
    string sPossible    = ":";
    int nListLen; // number of items in set

    string sTmp; int nTmp;
    sLootTypes = " "+sLootTypes+" ";
    int loot_types_count, nValue;
    int nPos1   = 1;
    int nPosA;
    int nPos2   = FindSubString(sLootTypes," ", nPos1);
    object oMasterL;
    while(nPos2>-1)
    {
        if(nPos2==nPos1)
        {
            // do nothing but search again. we ignore spaces adjacent one another
        }
        // we've found a gap between delimters, parse it.
        else
        {
            sTmp    = GetSubString(sLootTypes, nPos1, nPos2-(nPos1));
            nPosA   = FindSubString(sTmp,"%");
            if(nPosA>-1)
            {
                nTmp    = StringToInt( GetStringRight(sTmp,GetStringLength(sTmp)-(nPosA+1)) );
                if(nTmp)
                {
                    if(FindSubString(sTmp,"coins")==-1)
                    {
                        nTmp= FloatToInt(nMaxItems*(nTmp/100.0f));
                        if(!nTmp){nTmp=1;}
                    }
                }
                else
                    nTmp= 100;

                sTmp    = GetStringLeft(sTmp, nPosA);
            }
            else
            {
                nTmp    = 100;
            }

            SetLocalInt(oContainer,"LOOT_LIST_"+sTmp+"_MAX",nTmp);
            SetLocalInt(oContainer,"LOOT_LIST_"+sTmp+"_CNT",0);

            string sType = sTmp;
            if(     FindSubString(sPossible,sType)==-1  // do not record the same list twice
                &&  sType != "coins"                    // coins are a special case. do not add to list
              )
            {
                int nItems;
                // add this type to the list
                if(sType=="custom")
                {
                    nItems   = GetLocalInt(oContainer,"LOOT_CUSTOM");
                    if(!nItems)
                        nItems  = GetLocalInt(GetLocalObject(oContainer,"PAIRED"),"LOOT_CUSTOM");
                }
                else
                {
                    oMasterL = GetObjectByTag(sType);
                    if(GetIsObjectValid(oMasterL))
                    {
                        CTG_InitContainer(oMasterL);
                        nItems  = CTG_GetNumItemsInBaseContainer(oMasterL);
                    }
                }

                if(nItems)
                {
                    nListLen    += nItems;
                    int i; string sID;
                    for (i=0; i<nItems; i++)
                    {
                        sID = IntToString(i+1);
                        nValue  = GetLocalInt(oMasterL, sTreasureValueVar+sID);
                        if(     sType=="custom"
                            || (    nMaxValue>=nValue
                                &&  nMinValue<=nValue
                               )
                          )
                            sPossible+=sType+"#"+sID+":";
                        else
                            nListLen--;
                    }
                    // we'll want this later for when we remove all items of a loot type from the list
                    loot_types_count++;
                    SetLocalInt(oContainer,"LOOT_TYPES_COUNT",loot_types_count);
                    SetLocalString(oContainer,"LOOT_TYPE_"+IntToString(loot_types_count),sType);
                }
            }

        }
        nPos1   = nPos2+1;
        nPos2   = FindSubString(sLootTypes," ", nPos1);
    }

    // record possible set
    SetLocalString(oContainer, "LOOT_POSSIBLE", sPossible);
    return nListLen; // return length
}

void LootSetItemImpossible(string sItem, object oContainer)
{
    string sItemFnd = ":"+sItem+":";
    string sPosSet  = GetLocalString(oContainer,"LOOT_POSSIBLE");

    int nPos        = FindSubString(sPosSet,sItemFnd);
    if(nPos!=-1)
    {
        string sBefore = GetStringLeft(sPosSet,nPos);
        string sAfter  = GetStringRight(sPosSet,GetStringLength(sPosSet)-(nPos+(GetStringLength(sItemFnd)-1)) );
        SetLocalString(oContainer,"LOOT_POSSIBLE",sBefore+sAfter);
    }
}

int LootGetPossibleCount(object oContainer)
{
    string list = GetLocalString(oContainer,"LOOT_POSSIBLE");
    int nLength;

    int nPos    = FindSubString(list,":",1);
    while(nPos>-1)
    {
        nLength++;
        nPos    = FindSubString(list,":",nPos+1);
    }

    return nLength;
}

string LootGetListItem(int nIndex, object oContainer)
{
    string sList    = GetLocalString(oContainer,"LOOT_POSSIBLE");

    int nPos0   = 1;
    int nPos1   = FindSubString(sList,":",nPos0);
    int nCount  = 1;
    while(nCount<nIndex)
    {
        nCount++;
        nPos0   = nPos1+1;
        nPos1   = FindSubString(sList,":",nPos0);
        if(nPos1==-1)
            return "";
    }

    return GetSubString(sList, nPos0, nPos1-nPos0);
}

string LootGetNextTypeInList(string sType, string sList, object oContainer)
{
    string next_type;

    int loot_types_count    = GetLocalInt(oContainer,"LOOT_TYPES_COUNT");
    if(loot_types_count==1)
        return "";

    int nCurrent            = 1;
    while(nCurrent<loot_types_count)
    {
        if(sType==GetLocalString(oContainer,"LOOT_TYPE_"+IntToString(nCurrent)))
            break;
        nCurrent++;
    }

    if(nCurrent>=loot_types_count)
        return "";

    int nNext   = nCurrent+1;
    while(nNext<=loot_types_count)
    {
        next_type   = GetLocalString(oContainer,"LOOT_TYPE_"+IntToString(nNext));
        if(FindSubString(sList,":"+next_type)!=-1)
            return next_type;

        nNext++;
    }

    return "";
}

int LootCheckTypeFinished(string sType, int nMaxOfType, object oContainer)
{
    string type_count_label = "LOOT_LIST_"+sType+"_CNT";
    int nCount  = GetLocalInt(oContainer, type_count_label)+1;
    SetLocalInt(oContainer, type_count_label, nCount);
    if(nCount<nMaxOfType)
        return FALSE;
    else
    {
        string list = GetLocalString(oContainer,"LOOT_POSSIBLE");

        if(FindSubString(list,":"+sType+"#")!=-1)
        {
            int nLen    = GetStringLength(list);
            string sTypeNext = LootGetNextTypeInList(sType,list,oContainer);

            int nPosA   = FindSubString(list,sType+"#");
            int nPosB;
            if(sTypeNext=="")
                nPosB = nLen-1;
            else
                nPosB = FindSubString(list,":"+sTypeNext,nPosA);

            string sBefore  = GetStringLeft(list,nPosA);
            string sAfter   = GetStringRight(list,nLen-(nPosB+1));

            SetLocalString(oContainer,"LOOT_POSSIBLE",sBefore+sAfter);
        }

        return TRUE;
    }
}

int LootGetLevelAdjValue(int nLevel, int nMin, int nMax, int return_max=TRUE)
{
    int nMinTmp, nMaxTmp;
    switch(nLevel)
    {
        case 1:
            nMinTmp = 10;
            nMaxTmp = 300;
        break;
        case 2:
            nMinTmp = 20;
            nMaxTmp = 600;
        break;
        case 3:
            nMinTmp = 30;
            nMaxTmp = 900;
        break;
        case 4:
            nMinTmp = 50;
            nMaxTmp = 1200;
        break;
        case 5:
            nMinTmp = 70;
            nMaxTmp = 1600;
        break;
        case 6:
            nMinTmp = 90;
            nMaxTmp = 2000;
        break;
        case 7:
            nMinTmp = 110;
            nMaxTmp = 2600;
        break;
        case 8:
            nMinTmp = 150;
            nMaxTmp = 3400;
        break;
        case 9:
            nMinTmp = 200;
            nMaxTmp = 4500;
        break;
        case 10:
            nMinTmp = 250;
            nMaxTmp = 5800;
        break;
        case 11:
            nMinTmp = 300;
            nMaxTmp = 7500;
        break;
        case 12:
            nMinTmp = 350;
            nMaxTmp = 9800;
        break;
        case 13:
            nMinTmp = 400;
            nMaxTmp = 13000;
        break;
        case 14:
            nMinTmp = 450;
            nMaxTmp = 17000;
        break;
        case 15:
            nMinTmp = 500;
            nMaxTmp = 22000;
        break;
        case 16:
            nMinTmp = 600;
            nMaxTmp = 28000;
        break;
        case 17:
            nMinTmp = 800;
            nMaxTmp = 36000;
        break;
        case 18:
            nMinTmp = 1000;
            nMaxTmp = 47000;
        break;
        case 19:
            nMinTmp = 1200;
            nMaxTmp = 61000;
        break;
        case 20:
            nMinTmp = 1400;
            nMaxTmp = 80000;
        break;
    }

    if(nMinTmp<nMin)
        nMinTmp = nMin;
    if(nMaxTmp>nMax && nMax)
        nMaxTmp = nMax;

    if(return_max)
        return nMaxTmp;
    else
        return nMinTmp;
}

int LootCreateGold(int nHigh, int nLow, object oContainer=OBJECT_SELF)
{
    int nGold   = Random((nHigh-nLow)+1)+nLow;

    if(GetObjectType(oContainer)==OBJECT_TYPE_CREATURE)
    {
        GiveGoldToCreature(oContainer,nGold);
    }
    else
    {
        string sRef = "nw_it_gold001";
        /*
        // you could have other appearances for gold stacks if you set up these resrefs
        // and expand the base_item for gold with more bitmap appearances and drop models
        int nRandom = Random(6)+1;
        if(nRandom==1)
            sRef    = "gold_silver";
        else if(nRandom==2 || nRandom==3)
            sRef    = "gold_old";
        */
        object oGold= CreateItemOnObject(sRef,oContainer,nGold);
    }

    return nGold;
}

void LootGenerate(object oLooter, object oContainer=OBJECT_SELF)
{
    if(!GetHasInventory(oContainer))
        return;

    object oMod     = GetModule();
    object oDataObj = oContainer;
    int nLootItems  = GetLocalInt(oDataObj, "LOOT");
    if(!nLootItems)
    {
        oDataObj    = GetLocalObject(oContainer,"PAIRED");
        nLootItems  = GetLocalInt(oDataObj, "LOOT");
        if(!nLootItems)
            return;
    }

    if(GetLocalInt(oDataObj, "LOOT_ONCE"))
        SetLocalInt(oDataObj,"LOOT",0);

    // time until next treasure can be spawned
    int nPeriod     = GetLocalInt(oMod, "LOOT_PERIOD");
//  int nPeriod     = GetLocalInt(oDataObj, "LOOT_PERIOD");
    if(!nPeriod)
    {
        nPeriod     = GetLocalInt(GetModule(), "LOOT_PERIOD_MINUTES");
        SetLocalInt(oDataObj,"LOOT_PERIOD",nPeriod);
    }

    // is it time to spawn treasure?
    int nMinutes    = GetTimeCumulative(TIME_MINUTES);
    if(nMinutes<GetLocalInt(oDataObj, "LOOT_NEXT_SPAWN"))
        return; // not time yet
    else
        SetLocalInt(oDataObj, "LOOT_NEXT_SPAWN", nMinutes+nPeriod); // continue

    // This line ensures the Random function behaves randomly.
    int iRandomize  = Random(Random(GetTimeMillisecond()));

    string sLootType= GetStringLowerCase(GetLocalString(oDataObj, "LOOT_TYPE"));
    int nEachOnce   = GetLocalInt(oDataObj, "LOOT_ITEM_ONCE");
    int nCustomOnce = GetLocalInt(oDataObj, "LOOT_CUSTOM_ONCE");
    int nMin        = GetLocalInt(oDataObj, "LOOT_VALUE_MIN");
    int nMax        = GetLocalInt(oDataObj, "LOOT_VALUE_MAX");
    int nTotal;

    if(GetLocalInt(oDataObj, "LOOT_LEVEL_ADJ"))
    {
        int nLevel  = GetHitDice(oLooter);
        if(nLevel)
        {
            nMax    = LootGetLevelAdjValue(nLevel, nMin, nMax);
            nMin    = LootGetLevelAdjValue(nLevel, nMin, nMax, FALSE);
        }
    }
    // initialize list of possible items
    int nMinTmp;
    if(GetLocalInt(oDataObj,"LOOT_ONLY_QUALITY"))
        nMinTmp = nMin;
    int nListLen    = LootInitPossibleList(sLootType,nLootItems,nMax,nMinTmp,oContainer);

    // gold
    int nGoldPer    = GetLocalInt(oContainer,"LOOT_LIST_coins_MAX");
    if(nGoldPer)
    {
        int nGoldMax;
        if(!nMax)
            nGoldMax= 50000*nGoldPer/100;
        else
            nGoldMax= nMax*nGoldPer/100;

        nTotal      = LootCreateGold(nGoldMax, (nMin*nGoldPer/100), oContainer);
    }

    // items
    int nItem, nValue, nCount; string sItemID; object oItem, oMasterL;
    while(TRUE)
    {
        iRandomize  = Random(Random(GetTimeMillisecond()));
        // pull item id from list of possibles
        sItemID = LootGetListItem(Random(nListLen)+1,oContainer);

        int nPosA       = FindSubString(sItemID,"#");
        string sType    = GetStringLeft(sItemID,nPosA);
        string sID      = GetStringRight(sItemID,GetStringLength(sItemID)-(nPosA+1));

        int nMaxOfType  = GetLocalInt(oContainer,"LOOT_LIST_"+sType+"_MAX");

        if(sType=="custom")
        {
            // generate item
            oItem   = CreateItemOnObject(   GetStringLowerCase(GetLocalString(oDataObj,"LOOT_CUSTOM_"+sID)),
                                            oContainer
                                        );

            nValue  = GetGoldPieceValue(oItem);
        }
        else
        {
            oMasterL = GetObjectByTag(sType);
            nValue  = GetLocalInt(oMasterL, sTreasureValueVar+sID);
        }

        // item is too expensive
        if(nMax && (nTotal+nValue)>nMax)
        {
            if(sType=="custom")
                DestroyObject(oItem);

            LootSetItemImpossible(sItemID, oContainer);
            --nListLen;
            if(!nListLen)
                break;
        }
        // add this item to the loot, and update count
        else
        {
            if(sType=="custom")
            {
                if(nCustomOnce)
                {
                    LootSetItemImpossible(sItemID, oContainer);
                    --nListLen;
                    if(!nListLen)
                        break;
                }
            }
            else
            {
                object orig = CTG_GetTreasureItem(oMasterL, StringToInt(sID));
                oItem   = CopyItem( orig, oContainer, TRUE );
                if(nEachOnce)
                {
                    LootSetItemImpossible(sItemID, oContainer);
                    --nListLen;
                    if(!nListLen)
                        break;
                }
            }

            nTotal +=nValue;
            nCount++;
            if(nCount>=nLootItems)
                break;
            if(LootCheckTypeFinished(sType,nMaxOfType,oContainer))
            {
                nListLen    = LootGetPossibleCount(oContainer);
                if(!nListLen)
                    break;
            }
        }
    }

    // REMAINDER
    // if the value of loot is less than the minimum (or less than max 33% of time), make up the difference with gold
    int nRemainderType  = GetLocalInt(oContainer,"LOOT_REMAINDER");
    if(!nMax){nMax = nMin+5;}
    if(     nRemainderType
        &&(     nTotal<nMin
            ||  (nTotal<nMax && d3()==1)
          )
      )
    {
        // remainder is made up with gold
        if(nRemainderType==1)
        {
            nTotal  += LootCreateGold(nMax-nTotal, nMin-nTotal, oContainer);
        }
    }
}

//item drop for killed creatures
void LootCreatureDeath(object oCreature, object oKiller=OBJECT_INVALID)
{
    //craft_drop_items(oKiller); // bioware drop


      if(GetLocalInt(oCreature,"LOOT"))
    {
        // Generate loot -- if any
        LootGenerate(oKiller, oCreature);
        SetLocalInt(oCreature,"LOOT",0);
    }
}

//void main(){}





