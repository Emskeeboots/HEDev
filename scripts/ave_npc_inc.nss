//#include "engine"
//#include "inc_misc"
//#include "aps_include"


//death_counter_name (string) This is the name of the counter. Recommended that all builders add their builder prefix before each counter they use
//death_counter_prereq_proximity_distance (float) number of meters that the OBJECT_SELF can be away from the proximity object
//death_counter_prereq_proximity_object (string) tag of an object. If the OBJECT_SELF is not close enough to the object, nothing happens
//death_counter_change (int) Amount by which the counter increases (or decreases, if negative) each time this event occurs
//death_counter_threshold (int) if the counter is at or above this amount after being incremented, the subsequent occurs
//death_subsequent_script (string) name of the script that subsequently fires if counter_threshold is reached
//death_subsequent_target (string) tag of the NEW OJBECT_SELF that is associated with subsequent_script. If this is blank, the OBJECT_SELF doesn't change.
//death_reset (int) if 1, the counter will reset to 0 after the script in question fires
//death_counter_persistent (int) if 1, the counter continues even across server resets (requires linux nwnx setup)
//death_vfx (int) A specific vfx that fires if the counter is successfully incremented because all its conditions have been met

//used_counter_name (string) Exactly the same as above, but now it counts for the OnUsed event instead of OnDeath
//...used_*_* ditto

//This is designed to be highly flexible, so other prerequisites can be added with minimal difficulty.

/*
//oSelf is usually the OBJECT_SELF. sEventType is usually something like "death" or "used"
void AveCheckCounterEvents(object oSelf,string sEventType)
{
    int iSuccessVFX=GetLocalInt(oSelf,sEventType+"_vfx");
    string sCounter=GetLocalString(oSelf,sEventType+"_counter_name");
    if(sCounter=="") return;//Do nothing if the parameters haven't been set for this object
    string sProxTag=GetLocalString(oSelf,sEventType+"_counter_prereq_proximity_object");
    if(sProxTag!="")//There is a proximity prerequisite.
    {
        object oProxObj=GetObjectByTag(sProxTag);
        if(!GetIsObjectValid(oProxObj)) return; //The proximity object doesn't exist (has it been destroyed?)
        if(GetArea(oProxObj)!=GetArea(oSelf)) return; //The proximity object is in another area.
        float fDist=GetLocalFloat(oSelf,sEventType+"_counter_prereq_proximity_distance");
        if(GetDistanceBetween(oSelf,oProxObj)>fDist) return; //The proximity object is too far away.
    }
    if(iSuccessVFX>0)
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(iSuccessVFX),GetLocation(oSelf));
    }
    object oModule=GetModule();
    int iPersist=GetLocalInt(oSelf,sEventType+"_counter_persistent");
    int iCount;
    if(iPersist==0) iCount=GetLocalInt(oModule,sCounter);
    else iCount=GetPersistentInt(oModule,sCounter);
    iCount=iCount+GetLocalInt(oSelf,sEventType+"_counter_change");
    if(iPersist==0) SetLocalInt(oModule,sCounter,iCount);
    else SetPersistentInt(oModule,sCounter,iCount);
    int iThresh=GetLocalInt(oSelf,sEventType+"_counter_threshold");
    if(iCount>iThresh)
    {
        if(GetLocalInt(oSelf,sEventType+"_reset")==1)
        {
            if(iPersist==0) SetLocalInt(oModule,sCounter,0);
            else SetPersistentInt(oModule,sCounter,0);
        }
        int iSuccessVFX=GetLocalInt(oSelf,sEventType+"_vfx");
        string sScript=GetLocalString(oSelf,sEventType+"_subsequent_script");
        string sTargetTag=GetLocalString(oSelf,sEventType+"_subsequent_target");
        object oTarget;
        if(sTargetTag=="") oTarget=oSelf;
        else oTarget=GetObjectByTag(sTargetTag);
        ExecuteScript(sScript,oTarget);
    }
}
*/


//configure_npc_parts (int) 1
//causes the system to check these variables. Otherwise, the system is not used.
//CREATURE_PART constants - go up to 20 (head)
//COLOR_CHANNEL_SKIN=0
//COLOR_CHANNEL constants go up to 3 (thus there are four)
//colorrange_0_1_start (int) - start of range one for channel 0 (example; you could put 50 which would be skin color 50)
//colorrange_0_1_end (int) - start of range one for channel 0 (example; you could put 55 which would result in skin colors 50-55, inclusive)
//colorrange_0_1_percent (int) - Percent chance. So a 20 would be a 20% chance of drawing a color between 50 and 55. If all percentages add up to less than 100, the remainder is the chance the NPC keeps its default skin color
//colorrange_0_2_start (int)
//colorrange_0_2_end (int)
//colorrange_0_2_percent (int)

//partrange_*_*_* can likewise be used for any of the CREATURE_PART constants.


void ConcludeNPCPartConfig(object oNPC, string sType, int nChannel, int nMax, int nMin)
{
    int nDo=nMin+Random(1+nMax-nMin);
//    SendMessageToAll("Debug: sType is "+sType+" nChannel is "+IntToString(nChannel)+" nMax is "+IntToString(nMax)+" nMin is "+IntToString(nMin)+" nDo is "+IntToString(nDo));
    if(sType=="color")
    {
        DelayCommand(0.2,SetColor(oNPC,nChannel,nDo));
    }
    else if(sType=="part")
    {
        DelayCommand(0.2,SetCreatureBodyPart(nChannel,nDo,oNPC));
    }
}

//sType is 'color' or 'part'
void CheckNPCPartConfig(object oNPC, string sType)
{
    int nMaxChannels;
    if(sType=="color")
    {
        nMaxChannels=4;
    }
    else if(sType=="part")
    {
        nMaxChannels=21;
    }
    else return; //garbage input; do nothing.
    if(GetLocalInt(oNPC,"configure_npc_parts")!=1) return;
    int ThisStart;
    int ThisEnd;
    int ThisPercent;
    int nChannelCheck;
    int nRangesCheck;
    int nPick;
    int nPickCount;
    while(nChannelCheck<nMaxChannels)
    {
        nRangesCheck=1;
        nPick=Random(100);
        nPickCount=0;
        ThisPercent=GetLocalInt(oNPC,sType+"range_"+IntToString(nChannelCheck)+"_"+IntToString(nRangesCheck)+"_percent");
        while(ThisPercent>0)
        {
            if(ThisPercent+nPickCount>nPick)
            {
                ThisStart=GetLocalInt(oNPC,sType+"range_"+IntToString(nChannelCheck)+"_"+IntToString(nRangesCheck)+"_start");
                ThisEnd=GetLocalInt(oNPC,sType+"range_"+IntToString(nChannelCheck)+"_"+IntToString(nRangesCheck)+"_end");
                ConcludeNPCPartConfig(oNPC,sType,nChannelCheck,ThisStart,ThisEnd);
                break;//nRangesCheck=-2;//Forces exit from nearest while loop
            }
            nPickCount=nPickCount+ThisPercent;
            nRangesCheck=nRangesCheck+1;
            ThisPercent=GetLocalInt(oNPC,sType+"range_"+IntToString(nChannelCheck)+"_"+IntToString(nRangesCheck)+"_percent");
        }
        nChannelCheck=nChannelCheck+1;
    }
}

int HexCharToDecChar(string sChar)
{
    if(sChar=="0") return 0;
    if(sChar=="1") return 1;
    if(sChar=="2") return 2;
    if(sChar=="3") return 3;
    if(sChar=="4") return 4;
    if(sChar=="5") return 5;
    if(sChar=="6") return 6;
    if(sChar=="7") return 7;
    if(sChar=="8") return 8;
    if(sChar=="9") return 9;
    if(sChar=="A") return 10;
    if(sChar=="B") return 11;
    if(sChar=="C") return 12;
    if(sChar=="D") return 13;
    if(sChar=="E") return 14;
    if(sChar=="F") return 15;
    return -1;//Error code
}

//nHighestToCheck should be a power of 2
//Returns the lowest TRUE bit in nBinaryNumber
//nHighestToCheck should be at least twice as large as nBinaryNumber
int BinaryToBitPosition(int nBinaryNumber,int nHighestToCheck)
{
    if(nBinaryNumber>2*nHighestToCheck) return -1;//Error.
    int nReturn;
    int nBit;
    int nBegin;//TRUE once we begin the countdown
    while(nHighestToCheck>1)
    {
        nBit=nBit+1;
        //if(nBegin==1) nReturn=nReturn+1;
        //SendMessageToAll("Debug: binary number is "+IntToString(nBinaryNumber)+" check value is "+IntToString(nHighestToCheck));
        if(nBinaryNumber>=nHighestToCheck)
        {
            nBinaryNumber=nBinaryNumber-nHighestToCheck;
            nReturn=nBit;
            //SendMessageToAll("Debug: nBit is "+IntToString(nBit));
            nBegin=1;
        }
        nHighestToCheck=nHighestToCheck/2;
    }
    nReturn=17-nReturn;
    //SendMessageToAll("Debug: bit rank of that value is "+IntToString(nReturn));
    return nReturn;
}

//Converts a five-character hex code (eg 0x1C030) to the bit in it that is TRUE. If more than one bit is TRUE, returns the lowest TRUE bit.
int ByteCodeToInt(string nHex)
{
    if(GetStringLength(nHex)!=7)//Make sure we are dealing with something resembling a hex code
    {
        return -1;//error code
    }
    int nCount;
    nHex=GetStringRight(nHex,5);//Get the DATA
    while(GetStringLength(nHex)>0)
    {
        nCount=nCount*16;
        nCount=nCount+HexCharToDecChar(GetStringLeft(nHex,1));
        nHex=GetStringRight(nHex,GetStringLength(nHex)-1);
    }
    //SendMessageToAll("Debug: binary value is "+IntToString(nCount));
    return BinaryToBitPosition(nCount,65536);
}

//Tries to figure out which INVENTORY_SLOT oItem belongs in
int GetItemSlotBelonging(object oItem)
{
    int nType=GetBaseItemType(oItem);
    string sHexCode=Get2DAString("baseitems","EquipableSlots",nType);
    //SendMessageToAll("Debug: item name is "+GetName(oItem)+" type is "+IntToString(nType)+", hexcode is "+sHexCode);
    int nCode=ByteCodeToInt(sHexCode);
    return nCode;
}

void SmartEquipItem(object oNPC,object oItem)
{
    int nSlot=GetItemSlotBelonging(oItem);
    //SendMessageToAll("Debug: slot is "+IntToString(nSlot));
    if(nSlot>0) AssignCommand(oNPC,ActionEquipItem(oItem,nSlot));
}

//random_spawn1_1 / string / longsword001
//random_spawn1_2 / string / longsword002
//random_spawn1_3 / string / longsword003
//random_spawn2_1 / string / ring001
//random_spawn2_2 / string / ring002
//random_spawn2_2 / string / ring003
//The above example will cause the NPC to spawn one of three types of longswords,
//AND spawn one of three types of rings, from their respective blueprints
//There's no technical limit to the number of random_spawn(n) you can have. But it might get a little slow if you go above 600 or so.

//spawnchance1 / Int / 45
//Sets the spawn chance for item 1 to 4.5%

//spawnchance2 / Int / 55
//Sets the spawn chance for item 2 to 5.5%

//(note that percent chances are in tenths of a percent!!!!!!)

//equipitem1 / Int / 1 (true)
//Equips item 1

void SpawnAveNPCTreasure(object oNPC)
{
    string sBP;
    int nItemCount;
    int nPickCount=2;
    int nChance;
    int nChosen;
    object oItem;
    int StillToPick=TRUE;
    while(nPickCount>1)
    {
        nItemCount=nItemCount+1;
        nPickCount=1;
        sBP=GetLocalString(oNPC,"random_spawn"+IntToString(nItemCount)+"_"+IntToString(nPickCount));
        while(sBP!="")        //Count the number of pick options
        {
            nPickCount=nPickCount+1;
            sBP=GetLocalString(oNPC,"random_spawn"+IntToString(nItemCount)+"_"+IntToString(nPickCount));
        }
        if(nPickCount>1)
        {
            nChance=GetLocalInt(oNPC,"spawnchance"+IntToString(nPickCount));
            if(Random(1000)<nChance||nChance==0)
            {
                nChosen=Random(nPickCount-1)+1;//+1 because the Random function is 0-based. -1 because the last blueprint was the invalid one that broke the loop
                sBP=GetLocalString(oNPC,"random_spawn"+IntToString(nItemCount)+"_"+IntToString(nChosen));
                oItem=CreateItemOnObject(sBP,oNPC);
                //SendMessageToAll("Debug: Testing for item equip code: "+"equipitem"+IntToString(nItemCount));
                if(GetLocalInt(oNPC,"equipitem"+IntToString(nItemCount)))
                {
                    //SendMessageToAll("Debug: Attempting to equip item...");
                    DelayCommand(0.2,SmartEquipItem(oNPC,oItem));
                }
            }
        }
    }
}

