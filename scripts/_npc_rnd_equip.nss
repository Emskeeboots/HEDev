//::///////////////////////////////////////////////
//:: _npc_rnd_equip
//:://////////////////////////////////////////////
/*
    Called from x2_def_userdef (default ai post spawn event)
    Local Int EQUIPMENT_VARIABLE must be set on the NPC.

    WEAPON_COUNT                = number of weapons to choose from
    WEAPON_1, WEAPON_2  etc...  = resref


*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 jun 10)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_itemprop"


int GetClothColor(int nType=1, int nColor=999);
int GetLeatherColor(int nType=1, int nColor=999);

int GetClothColor(int nType=1, int nColor=999)
{
    // This line ensures the Random function behaves randomly.
    int iRandomize = Random(Random(GetTimeMillisecond()));

  if(nType==1)// typical civilized
  {
    if(nColor==999)
        nColor  = ((Random(9)+1)*4)-1;
    else
    {
        nColor+=Random(3)-1;
        if(nColor==32)
            nColor=4;
    }
    if(nColor==20)
        nColor=32;
    else if(nColor==21)
        nColor=30;
    else if(nColor==22)
        nColor=32;
    else if(nColor==23)
        nColor=32;
    else if(nColor==27)
        nColor=24;
    else if(nColor==31)
        nColor=107;
    else if(nColor==33)
        nColor=3;
    else if(nColor==4)
        nColor=32;
    else if(nColor==35)
        nColor=32;

  }

//Oldfog Modifications  ///////////////////////

 else if(nType==10)// Hill's Edge
  {
    if(nColor==999)
        nColor  = ((Random(9)+1)*4)-1;
    else
    {
        nColor+=Random(3)-1;
        if(nColor==32)
            nColor=4;
    }
    if(nColor==20)
        nColor=32;
    else if(nColor==21)
        nColor=30;
    else if(nColor==22)
        nColor=32;
    else if(nColor==23)
        nColor=32;
    else if(nColor==27)
        nColor=24;
    else if(nColor==31)
        nColor=107;
    else if(nColor==33)
        nColor=3;
    else if(nColor==4)
        nColor=32;
    else if(nColor==35)
        nColor=32;

  }

////////////////////////////////////////////










  else if(nType==11)// typical rustic
  {
    if(nColor==999)
        nColor = Random(3);
    else
        nColor+Random(21)-1;

    if(nColor==19)
        nColor=0;
    else if(nColor==12)
        nColor=1;
    else if(nColor==13)
        nColor=2;
    else if(nColor==14)
        nColor=3;
    else if(nColor==4)
        nColor=2;
    else if(nColor==5 || nColor==6)
        nColor=1;
  }
  else if(nType==12)//Noble
  {
    if(nColor==999)
        nColor = Random(3);
    else
        nColor+Random(33)-1;

    if(nColor==0)
        nColor=20;
    else if(nColor==1)
        nColor=22;
    else if(nColor==2)
        nColor=24;
    else if(nColor==3)
        nColor=25;
    else if(nColor==4)
        nColor=36;
    else if(nColor==5)
        nColor=37;
    else if(nColor==6)
        nColor=37;
    else if(nColor==7)
        nColor=37;
    else if(nColor==8)
        nColor=37;
    else if(nColor==9)
        nColor=37;
    else if(nColor==10)
        nColor=32;
    else if(nColor==11)
        nColor=32;
    else if(nColor==12)
        nColor=33;
    else if(nColor==13)
        nColor=33;
    else if(nColor==14)
        nColor=104;
    else if(nColor==15)
        nColor=105;
    else if(nColor==16)
        nColor=106;
    else if(nColor==17)
        nColor=107;
    else if(nColor==18)
        nColor=108;
    else if(nColor==19)
        nColor=109;
    else if(nColor==20)
        nColor=110;
    else if(nColor==21)
        nColor=111;
    else if(nColor==22)
        nColor=136;
    else if(nColor==23)
        nColor=137;
    else if(nColor==24)
        nColor=138;
    else if(nColor==25)
        nColor=139;
    else if(nColor==26)
        nColor=160;
    else if(nColor==27)
        nColor=161;
    else if(nColor==28)
        nColor=164;
    else if(nColor==29)
        nColor=166;
    else if(nColor==30)
        nColor=166;
    else if(nColor==31)
        nColor=164;
    else if(nColor==32)
        nColor=166;
  }
  else
  {
    if(nColor==999)
        nColor  = ((Random(7)+1)*4)-1;
    else
        nColor+Random(2);

    if(nColor==20)
        nColor=32;
    else if(nColor==21)
        nColor=30;
    else if(nColor==22)
        nColor=32;
    else if(nColor==23)
        nColor=24;
  }

    return nColor;
}

int GetLeatherColor(int nType=1, int nColor=999)
{
  if(nType==50) // goblin commoners
  {
    if(nColor==999)
    {
        if(d2()==1)
            nColor  = 111+d4();
        else
            nColor  = 168+Random(6);
    }
  }
  else
  {
    if(nColor==999)
        nColor = Random(18);
    else
        nColor+Random(2);

    if(nColor==0)
        nColor=1;
    else if(nColor==4)
        nColor=3;
    else if(nColor==8)
        nColor=7;
    else if(nColor==12)
        nColor=11;
    else if(nColor==16)
        nColor=15;
    else if(nColor==17 || nColor==24)
        nColor=23;
  }

    return nColor;
}


string GetClothing(int nType=20)
   //string nType  = GetLocalInt(OBJECT_SELF, "EQUIPMENT_TYPE");

  // if(nType==20)

{

    // This line ensures the Random function behaves randomly.
    int iRandomize = Random(Random(GetTimeMillisecond()));

    string sClothResRef;
    int nCOUNT = GetLocalInt(OBJECT_SELF,"EQUIPMENT_CLOTHING_COUNT");

    if(nCOUNT)
        sClothResRef = GetLocalString(OBJECT_SELF,"EQUIPMENT_CLOTHING_"+IntToString(Random(nCOUNT)+1));
    else
    {
        switch(Random(22)+1)
        {
                    case 1 : sClothResRef="tt_cloth_com001";break;
                    case 2 : sClothResRef="tt_cloth_com002";break;
                    case 3 : sClothResRef="tt_cloth_com003";break;
                    case 4 : sClothResRef="tt_cloth_com004";break;
                    case 5 : sClothResRef="tt_cloth_com005";break;
                    case 6 : sClothResRef="tt_cloth_com006";break;
                    case 7 : sClothResRef="tt_cloth_com007";break;
                    case 8 : sClothResRef="tt_cloth_com008";break;
                    case 9 : sClothResRef="tt_cloth_com009";break;
                    case 10: sClothResRef="tt_cloth_com010";break;
                    case 11: sClothResRef="tt_cloth_com011";break;
                    case 12: sClothResRef="tt_cloth_com012";break;
                    case 13: sClothResRef="tt_cloth_com013";break;
                    case 14: sClothResRef="tt_cloth_com014";break;
                    case 15: sClothResRef="tt_cloth_com015";break;
                    case 16: sClothResRef="tt_cloth_com023";break;
                    case 17: sClothResRef="tt_cloth_com024";break;
                    case 18: sClothResRef="tt_cloth_com025";break;
                    case 19: sClothResRef="tt_cloth_com026";break;
                    case 20: sClothResRef="tt_cloth_com027";break;
                    case 21: sClothResRef="tt_cloth_com028";break;
                    case 22: sClothResRef="tt_cloth_com029";break;
                    case 23: sClothResRef="tt_cloth_com036";break;
                    default: sClothResRef="cloth027";break;
        }
    }



    return sClothResRef;



}


///////////////////////////////////////// EQUIPMENT_TYPE - 30 (Worker) //////////////////
/*
string GetClothing(int nType=30)
{
    // This line ensures the Random function behaves randomly.
    int iRandomize = Random(Random(GetTimeMillisecond()));

    string sClothResRef;
    int nCOUNT = GetLocalInt(OBJECT_SELF,"EQUIPMENT_CLOTHING_COUNT");

    if(nCOUNT)
        sClothResRef = GetLocalString(OBJECT_SELF,"EQUIPMENT_CLOTHING_"+IntToString(Random(nCOUNT)+1));
    else
    {
        switch(Random(11)+1)
        {
                    case 1 : sClothResRef="tt_cloth_com001";break;
                    case 2 : sClothResRef="tt_cloth_com004";break;
                    case 3 : sClothResRef="tt_cloth_com005";break;
                    case 4 : sClothResRef="tt_cloth_com008";break;
                    case 5 : sClothResRef="tt_cloth_com009";break;
                    case 6 : sClothResRef="tt_cloth_com010";break;
                    case 7 : sClothResRef="tt_cloth_com013";break;
                    case 8 : sClothResRef="tt_cloth_com014";break;
                    case 9 : sClothResRef="tt_cloth_com023";break;
                    case 10: sClothResRef="tt_cloth_com023";break;
                    case 11: sClothResRef="tt_cloth_com023";break;
                    case 12: sClothResRef="tt_cloth_com023";break;
                      default: sClothResRef="cloth023";break;
        }
    }
    return sClothResRef;
}
*/
/////////////////////////////////////////////////////////////////////////////


void main()
{
    // This line ensures the Random function behaves randomly.
    int iRandomize = Random(Random(GetTimeMillisecond()));

    int nAppType  = GetLocalInt(OBJECT_SELF, "APPEARANCE_TYPE");

    // CLOTHING/ARMOR ----------------------------------------------------------
    int bDroppable;
    object oClothing    = GetItemInSlot(INVENTORY_SLOT_CHEST,OBJECT_SELF);
    if(!GetIsObjectValid(oClothing))
    {
        oClothing       = CreateItemOnObject(GetClothing(),OBJECT_SELF,1,"npc_clothing");
        bDroppable      = GetLocalInt(OBJECT_SELF, "EQUIPMENT_CLOTHING_DROPPABLE");
    }

    // Colorof clothing/armor --------------------------------------------------
    int nC          = GetClothColor(nAppType);
    int nL          = GetLeatherColor(nAppType);
    if(nC!=999)
        oClothing   = IPDyeArmor(oClothing,ITEM_APPR_ARMOR_COLOR_CLOTH1, nC);
    if(nC!=999)
        oClothing   = IPDyeArmor(oClothing,ITEM_APPR_ARMOR_COLOR_CLOTH2, GetClothColor(nAppType,nC));
    if(nL!=999)
        oClothing   = IPDyeArmor(oClothing,ITEM_APPR_ARMOR_COLOR_LEATHER1, nL);
    if(nL!=999)
        oClothing   = IPDyeArmor(oClothing,ITEM_APPR_ARMOR_COLOR_LEATHER2, GetLeatherColor(nAppType,nL));

    IPRemoveAllItemProperties(oClothing,DURATION_TYPE_TEMPORARY);
    ClearAllActions(TRUE);
    ActionEquipItem(oClothing,INVENTORY_SLOT_CHEST);
    SetDroppableFlag(oClothing, bDroppable);


    // WEAPONS -----------------------------------------------------------------
    int nWeapon     = GetLocalInt(OBJECT_SELF,"EQUIPMENT_WEAPON_COUNT");

    string sWeapon  = GetLocalString(OBJECT_SELF,"EQUIPMENT_WEAPON_"+IntToString(Random(nWeapon)+1));
    if(sWeapon!="")
    {
        object oWeapon  = CreateItemOnObject(sWeapon, OBJECT_SELF, 1, "npc_weapon");
        if(GetIsObjectValid(oWeapon))
        {
            if(!GetLocalInt(OBJECT_SELF, "EQUIPMENT_WEAPON_NOT_EQUIPPED"))
                ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND);
            SetDroppableFlag(oWeapon, GetLocalInt(OBJECT_SELF, "EQUIPMENT_WEAPON_DROPPABLE"));
        }
    }
}
