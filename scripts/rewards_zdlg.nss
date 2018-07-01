/*
  Name: zdlg_reward
  Author: Mithreas
  Date: May 22 2018
  Description: Bounty conversation script. Uses Z-Dialog.

  NPC variables:
    dlg_prompt (string) - the greeting the NPC will use, should explain what they want.
    item_tag (string)   - the tag of the item they want
    item_count (int)    - the number of items they want.  Defaults to 1 if not present.

    item1 (string)      - resref of a possible reward item
    item2...n           - as many optional items as you'd like to add.

    prop1type (int)     - index into itempropdef.2da of the first type of bonus property
                          we could add to the item.
    prop1subtype (int)  - property subtupe, index into the 2da defined as SubTypeResRef in
                          the relevant row of itempropdef.2da
    prop1cost (int)     - index into the relevant cost table to determine property size (1, d4 etc)

    prop2type, prop3type etc can all be defined as for prop1 with the same 3 variables.
    Only positive/beneficial properties are supported.

    See this link for more info on what the subtype and cost should be for different property types.
    Many properties do not need a subtype or cost, or just need one of them.
    https://nwnlexicon.com/index.php?title=Category:Item_Creation_Functions



#_name: the response, you likely want to include how many items the reward cossts here as well as gold cost
#_item: this is the reward, should be the tag of a chest somewhere in the module inaccessible, place the rewards (with properties) in the chest
#_#_input is the input, first # should match the # of the corresponding #_item, the 2nd is to specify more items, so if 1_1_input is bat wings, 1_2_input can be rat pelts, both will be required to get an item from 1_item



*/
#include "zdlg_include_i"

const string MAIN_MENU   = "main_options";
const string PAGE_2 = "page_2";
const string END = "end";

const int PROPS = 2;



void Init()
{
  // variables
  string sTag;
  string sTagList = GetLocalString(OBJECT_SELF, "TAG_LIST");
  string sItemTag;
  object oPC = GetPCSpeaker();


  int i=1;
  if(sTagList == "")
  {
    int x=1;

    sTag = GetLocalString(OBJECT_SELF, "1_1_input");

    while(sTag != "")
    {
      while(sTag != "")
      {
        sTagList += ","+sTag;
        sTag = GetLocalString(OBJECT_SELF, IntToString(x)+"_"+IntToString(++i)+"_input");
      }
      i = 1;
      sTag = GetLocalString(OBJECT_SELF, IntToString(++x)+"_1_input");
    }
	sTagList += ",";
    SetLocalString(OBJECT_SELF, "TAG_LIST", sTagList);
  }
  //erase oldd item list
  int nCommaEnd = FindSubString(sTagList, ",", 1);
  int nCommaStart = 0;
  while(nCommaEnd > -1)
  {

    DeleteLocalString(oPC, GetSubString(sTagList, nCommaStart+1, nCommaEnd-nCommaStart-1));

    nCommaStart = nCommaEnd;
    nCommaEnd = FindSubString(sTagList, ",", nCommaStart+1);

  }
  object oItem = GetFirstItemInInventory(oPC);
  while (GetIsObjectValid(oItem))
  {
    sItemTag = GetResRef(oItem);

    if (FindSubString(sTagList, ","+sItemTag+",") > -1)
    {

      SetLocalInt(oPC, sItemTag, GetLocalInt(oPC, sItemTag) + GetItemStackSize(oItem));
        }



    oItem = GetNextItemInInventory(oPC);
  }



  if(GetElementCount(MAIN_MENU) == 0)
  {
    /// Build response list.
    AddStringElement("Not today, sorry.", MAIN_MENU);
    string sResponse = GetLocalString(OBJECT_SELF, "1_name");
    i = 1;
    while(sResponse != "")
    {
      AddStringElement(sResponse, MAIN_MENU);

      //sResponse = GetLocalString(IntToString(++i)+"_name");
      sResponse = GetLocalString(OBJECT_SELF, IntToString(++i)+"_name");
    }
  }



  // End of conversation
  if (GetElementCount(END) == 0)
  {
    AddStringElement("Thanks, goodbye.", END);
  }




}

void PageInit()
{
  // This is the function that sets up the prompts for each page.
  string sPage = GetDlgPageString();
  object oPC   = GetPcDlgSpeaker();

  if (sPage == "")
  {
    SetDlgPrompt(GetLocalString(OBJECT_SELF, "dlg_prompt"));
    SetDlgResponseList(MAIN_MENU, OBJECT_SELF);
  }
  else if (sPage == PAGE_2)
  {



    SetDlgPrompt("Thanks, here's a little something for your trouble.");
    SetDlgResponseList(END, OBJECT_SELF);
  }
  else
  {
    SendMessageToPC(oPC,
                    "You've found a bug. How embarrassing. Please report it.");
    EndDlg();
  }
}

void HandleSelection()
{
  int selection  = GetDlgSelection();
  object oPC     = GetPcDlgSpeaker();
  string sPage   = GetDlgPageString();

  if (sPage == "")
  {
    switch (selection)
    {
      case 0:
        // Don't have something to sell, or don't want to.
        {
          EndDlg();
          break;
        }
      default:
        // Have something to sell
        {

          // variables
          string sTagList;
          string sSel = IntToString(selection);
          string sTag    = GetLocalString(OBJECT_SELF, sSel+"_1_input");
          int    nNeeded ;
          int i = 1;
          string sItemTag;
          //checkk itemss here
		  if(GetGold(oPC) < GetLocalInt(OBJECT_SELF, sSel+"_gold"))
          {
            SpeakString("You don't have enough gold.");
            EndDlg();
            return;
          }
          while(sTag != "")
          {
            nNeeded = GetLocalInt(OBJECT_SELF, sSel+"_"+IntToString(i)+"_item_count");
			if(nNeeded == 0) nNeeded = 1;

			SendMessageToPC(oPC, "Needed: " + IntToString(nNeeded));
            if(GetLocalInt(oPC, sTag) < nNeeded)
            {
              SpeakString("You don't have enough items.");
              EndDlg();
              return;
            }
            else
            {
                SetLocalInt(oPC, sTag, nNeeded);
                sTagList += ","+sTag;


            }
            sTag    = GetLocalString(OBJECT_SELF, sSel+"_"+IntToString(++i)+"_input");
          }
          sTagList += ",";
          //remove items here
          object oItem = GetFirstItemInInventory(oPC);

          while (GetIsObjectValid(oItem))
          {
           sItemTag = GetResRef(oItem);
		   nNeeded = GetLocalInt(oPC, sItemTag);
		   SendMessageToPC(oPC, "Needed for: " +sItemTag + ":"+ IntToString(nNeeded));
           if (FindSubString(sTagList, ","+sItemTag+",") > -1 && nNeeded > 0)
           {

              if (GetItemStackSize(oItem) > nNeeded)
              {
                SetItemStackSize (oItem, GetItemStackSize(oItem) - nNeeded);
                nNeeded = 0;
                DeleteLocalInt(oPC, sItemTag);
              }
              else
              {
                    DestroyObject (oItem);
                nNeeded -= GetItemStackSize(oItem);
                SetLocalInt(oPC, sItemTag, nNeeded);

              }


           }

           oItem = GetNextItemInInventory(oPC);
          }
		  TakeGoldFromCreature(GetLocalInt(OBJECT_SELF, sSel+"_gold"), oPC, TRUE);
        // Do reward.

          // Select a random item
          string sChest = GetLocalString(OBJECT_SELF, sSel+"_item");
          object oChest = GetObjectByTag(sChest);
          int nAmt = GetLocalInt(oChest, "REWARD_AMT");

          if(!GetIsObjectValid(oChest))
          {
            SendMessageToPC(oPC, "Chest with tag: " + sChest + " not found.");
          }
          if(nAmt == 0)
          {
            oItem = GetFirstItemInInventory(oChest);
            while(GetIsObjectValid(oItem))
            {
                nAmt++;
                oItem = GetNextItemInInventory(oChest);
            }
          }

          nAmt  = Random(nAmt)+1;
          oItem = GetFirstItemInInventory(oChest);

          i=1;
          while(GetIsObjectValid(oItem))
          {

            if(i++ == nAmt) break;
            oItem = GetNextItemInInventory(oChest);
          }
          oItem = CopyItem(oItem, oPC, TRUE);
          //remove properties

          nAmt = 0;
    itemproperty ipItemProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipItemProp))
          {
            nAmt++;
            ipItemProp = GetNextItemProperty(oItem);
          }
          if(nAmt > PROPS)
          {
            string sPropList;
            string sRandom;

            for(i = 1; i <= PROPS; i++)
            {
                sRandom = ","+IntToString(Random(nAmt)+1)+",";
                if(FindSubString(sPropList, sRandom) == -1)
                    sPropList += sRandom;
                else
                    i--;
            }
            itemproperty ipItemProp = GetFirstItemProperty(oItem);
            i = 1;

            while(GetIsItemPropertyValid(ipItemProp))
            {
                if(FindSubString(sPropList, ","+IntToString(i++)+",") == -1)
                  RemoveItemProperty(oItem, ipItemProp);

                ipItemProp = GetNextItemProperty(oItem);
            }
          }
          SetDlgPageString(PAGE_2);
          break;
        }
    }
  }
  else if (GetDlgResponseList() == END)
  {
    EndDlg();
  }
  else
  {
    SendMessageToPC(oPC,
                    "You've found a bug. How embarassing. Please report it.");
    EndDlg();
  }
}

void main()
{
  int nEvent = GetDlgEventType();
  switch (nEvent)
  {
    case DLG_INIT:
      Init();
      break;
    case DLG_PAGE_INIT:
      PageInit();
      break;
    case DLG_SELECTION:
      HandleSelection();
      break;
    case DLG_ABORT:
    case DLG_END:
      break;
  }
}



/*
  Name: zdlg_reward
  Author: Mithreas
  Date: May 22 2018
  Description: Bounty conversation script. Uses Z-Dialog.

  NPC variables:
    dlg_prompt (string) - the greeting the NPC will use, should explain what they want.
    item_tag (string)   - the tag of the item they want
    item_count (int)    - the number of items they want.  Defaults to 1 if not present.

    item1 (string)      - resref of a possible reward item
    item2...n           - as many optional items as you'd like to add.

    prop1type (int)     - index into itempropdef.2da of the first type of bonus property
                          we could add to the item.
    prop1subtype (int)  - property subtupe, index into the 2da defined as SubTypeResRef in
                          the relevant row of itempropdef.2da
    prop1cost (int)     - index into the relevant cost table to determine property size (1, d4 etc)

    prop2type, prop3type etc can all be defined as for prop1 with the same 3 variables.
    Only positive/beneficial properties are supported.

    See this link for more info on what the subtype and cost should be for different property types.
    Many properties do not need a subtype or cost, or just need one of them.
    https://nwnlexicon.com/index.php?title=Category:Item_Creation_Functions



#_name: the response, you likely want to include how many items the reward cossts here as well as gold cost
#_item: this is the reward, should be the tag of a chest somewhere in the module inaccessible, place the rewards (with properties) in the chest
#_#_input is the input, first # should match the # of the corresponding #_item, the 2nd is to specify more items, so if 1_1_input is bat wings, 1_2_input can be rat pelts, both will be required to get an item from 1_item



*/
/*
#include "zdlg_include_i"

const string MAIN_MENU   = "main_options";
const string PAGE_2 = "page_2";
const string END = "end";

const int PROPS = 2;



void Init()
{
  // variables
  string sTag;
  string sTagList = GetLocalString(OBJECT_SELF, "TAG_LIST");
  string sItemTag;
  object oPC = GetPCSpeaker();


  int i=1;
  if(sTagList == "")
  {
    int x=1;

    sTag = GetLocalString(OBJECT_SELF, "1_1_input");

    while(sTag != "")
    {
      while(sTag != "")
      {
        sTagList += ","+sTag;
        sTag = GetLocalString(OBJECT_SELF, IntToString(x)+"_"+IntToString(++i)+"_input");
      }
      i = 1;
      sTag = GetLocalString(OBJECT_SELF, IntToString(++x)+"_1_input");
    }
    sTagList += ",";
    SetLocalString(OBJECT_SELF, "TAG_LIST", sTagList);
  }
  //erase oldd item list
  int nCommaEnd = FindSubString(sTagList, ",", 1);
  int nCommaStart = 0;
  while(nCommaEnd > -1)
  {

    DeleteLocalString(oPC, GetSubString(sTagList, nCommaStart+1, nCommaEnd-nCommaStart-1));

    nCommaStart = nCommaEnd;
    nCommaEnd = FindSubString(sTagList, ",", nCommaStart+1);

  }
  object oItem = GetFirstItemInInventory(oPC);
  while (GetIsObjectValid(oItem))
  {
    sItemTag = GetResRef(oItem);

    if (FindSubString(sTagList, ","+sItemTag+",") > -1)
    {

      SetLocalInt(oPC, sItemTag, GetLocalInt(oPC, sItemTag) + GetItemStackSize(oItem));
        }



    oItem = GetNextItemInInventory(oPC);
  }



  if(GetElementCount(MAIN_MENU) == 0)
  {
    /// Build response list.
    AddStringElement("Not today, sorry.", MAIN_MENU);
    string sResponse = GetLocalString(OBJECT_SELF, "1_name");
    i = 1;
    while(sResponse != "")
    {
      AddStringElement(sResponse, MAIN_MENU);

      //sResponse = GetLocalString(IntToString(++i)+"_name");
      sResponse = GetLocalString(OBJECT_SELF, IntToString(++i)+"_name");
    }
  }



  // End of conversation
  if (GetElementCount(END) == 0)
  {
    AddStringElement("Thanks, goodbye.", END);
  }




}

void PageInit()
{
  // This is the function that sets up the prompts for each page.
  string sPage = GetDlgPageString();
  object oPC   = GetPcDlgSpeaker();

  if (sPage == "")
  {
    SetDlgPrompt(GetLocalString(OBJECT_SELF, "dlg_prompt"));
    SetDlgResponseList(MAIN_MENU, OBJECT_SELF);
  }
  else if (sPage == PAGE_2)
  {



    SetDlgPrompt("Thanks, here's a little something for your trouble.");
    SetDlgResponseList(END, OBJECT_SELF);
  }
  else
  {
    SendMessageToPC(oPC,
                    "You've found a bug. How embarrassing. Please report it.");
    EndDlg();
  }
}

void HandleSelection()
{
  int selection  = GetDlgSelection();
  object oPC     = GetPcDlgSpeaker();
  string sPage   = GetDlgPageString();

  if (sPage == "")
  {
    switch (selection)
    {
      case 0:
        // Don't have something to sell, or don't want to.
        {
          EndDlg();
          break;
        }
      default:
        // Have something to sell
        {

          // variables
          string sTagList;
          string sSel = IntToString(selection);
          string sTag    = GetLocalString(OBJECT_SELF, sSel+"_1_input");
          int    nNeeded ;
          int i = 1;
          string sItemTag;
          //checkk itemss here
          if(GetGold(oPC) < GetLocalInt(OBJECT_SELF, sSel+"_gold"))
          {
            SpeakString("You don't have enough gold.");
            EndDlg();
            return;
          }
          while(sTag != "")
          {
            nNeeded = GetLocalInt(OBJECT_SELF, sSel+"_"+IntToString(i)+"_item_count");
            if(nNeeded == 0) nNeeded = 1;


            if(GetLocalInt(oPC, sTag) < nNeeded)
            {
              SpeakString("You don't have enough items.");
              EndDlg();
              return;
            }
            else
            {
                SetLocalInt(oPC, sTag, nNeeded);
                sTagList += ","+sTag;


            }
            sTag    = GetLocalString(OBJECT_SELF, sSel+"_"+IntToString(++i)+"_input");
          }
          sTagList += ",";
          //remove items here
          object oItem = GetFirstItemInInventory(oPC);

          while (GetIsObjectValid(oItem))
          {
           sItemTag = GetResRef(oItem);
           if (FindSubString(sTagList, ","+sItemTag+",") > -1)
           {
              nNeeded = GetLocalInt(oPC, sItemTag);
              if (GetItemStackSize(oItem) > nNeeded)
              {
                SetItemStackSize (oItem, GetItemStackSize(oItem) - nNeeded);
                nNeeded = 0;
                DeleteLocalInt(oPC, sItemTag);
              }
              else
              {
                    DestroyObject (oItem);
                nNeeded -= GetItemStackSize(oItem);
                SetLocalInt(oPC, sItemTag, nNeeded);

              }

              if (nNeeded == 0) break;
           }

           oItem = GetNextItemInInventory(oPC);
          }
          TakeGoldFromCreature(GetLocalInt(OBJECT_SELF, sSel+"_gold"), oPC, TRUE);
        // Do reward.

          // Select a random item
          string sChest = GetLocalString(OBJECT_SELF, sSel+"_item");
          object oChest = GetObjectByTag(sChest);
          int nAmt = GetLocalInt(oChest, "REWARD_AMT");

          if(!GetIsObjectValid(oChest))
          {
            SendMessageToPC(oPC, "Chest with tag: " + sChest + " not found.");
          }
          if(nAmt == 0)
          {
            oItem = GetFirstItemInInventory(oChest);
            while(GetIsObjectValid(oItem))
            {
                nAmt++;
                oItem = GetNextItemInInventory(oChest);
            }
          }

          nAmt  = Random(nAmt)+1;
          oItem = GetFirstItemInInventory(oChest);

          i=1;
          while(GetIsObjectValid(oItem))
          {

            if(i++ == nAmt) break;
            oItem = GetNextItemInInventory(oChest);
          }
          oItem = CopyItem(oItem, oPC, TRUE);
          //remove properties

          nAmt = 0;
    itemproperty ipItemProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipItemProp))
          {
            nAmt++;
            ipItemProp = GetNextItemProperty(oItem);
          }
          if(nAmt > PROPS)
          {
            string sPropList;
            string sRandom;

            for(i = 1; i <= PROPS; i++)
            {
                sRandom = ","+IntToString(Random(nAmt)+1)+",";
                if(FindSubString(sPropList, sRandom) == -1)
                    sPropList += sRandom;
                else
                    i--;
            }
            itemproperty ipItemProp = GetFirstItemProperty(oItem);
            i = 1;

            while(GetIsItemPropertyValid(ipItemProp))
            {
                if(FindSubString(sPropList, ","+IntToString(i++)+",") == -1)
                  RemoveItemProperty(oItem, ipItemProp);

                ipItemProp = GetNextItemProperty(oItem);
            }
          }
          SetDlgPageString(PAGE_2);
          break;
        }
    }
  }
  else if (GetDlgResponseList() == END)
  {
    EndDlg();
  }
  else
  {
    SendMessageToPC(oPC,
                    "You've found a bug. How embarassing. Please report it.");
    EndDlg();
  }
}

void main()
{
  int nEvent = GetDlgEventType();
  switch (nEvent)
  {
    case DLG_INIT:
      Init();
      break;
    case DLG_PAGE_INIT:
      PageInit();
      break;
    case DLG_SELECTION:
      HandleSelection();
      break;
    case DLG_ABORT:
    case DLG_END:
      break;
  }
}
*/
