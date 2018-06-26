//::///////////////////////////////////////////////
//:: _npc_rnd_apear
//:://////////////////////////////////////////////
/*
    Called from x2_def_userdef (default ai post spawn event)
    Local Int APPEARANCE_TYPE must be set on the NPC.
    The value corresponds to the following types:
    1   = default (non-specific)
    2   =

    50  = goblin

    99= Entire Model is changed so use APPEARANCE_SWITCH

    APPEARANCE_COUNT                   = number of appearance types to change
    APPEARANCE_1, APPEARANCE_2  etc...  = index in appearance.2da


*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 jun 8)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_constants"

int GetTattooColorMatchingSkin(int nSkin);
int GetTattooColorMatchingSkin(int nSkin)
{
    int nTattoo;

    if(nSkin<=3)
        nTattoo  = nSkin +4;
    else if(nSkin<=7)
        nTattoo  = nSkin +112;
    else if(nSkin<=11)
        nTattoo  = nSkin +108;
    else if(nSkin==12)
        nTattoo  = 162;
    else if(nSkin<=15)
        nTattoo  = nSkin +144;
    else if(nSkin<=19)
        nTattoo  = nSkin +108;
    else if(nSkin>=24 && nSkin<=27)
        nTattoo  = nSkin -16;
    else if(nSkin<=31)
        nTattoo  = nSkin +84;
    else
        nTattoo  = nSkin;

    return nTattoo;
}

int GetHairColorMatchingSkin(int nSkin);
int GetHairColorMatchingSkin(int nSkin)
{
    int nHair;
    // dark
    if(     (nSkin>=3 &&nSkin<=7)
        || nSkin==10
        || nSkin==11
        || nSkin==14
        || nSkin==15
      )
    {
        switch(d4())
        {
            case 1: return 3;break;
            case 2: return 15;break;
            case 3: return 22;break;
            case 4: return 23;break;
            default: return 23; break;
        }
    }
    // light
    else if(    nSkin==0
            ||  nSkin==1
            ||  nSkin==8
            ||  nSkin==12
            ||  nSkin==13
           )
    {
        int nRnd    = Random(13);

        if(nRnd>8)
        {
            if(nRnd==9)
                return 14;
            else if(nRnd==10)
                return 15;
            else if(nRnd==11)
                return 22;
            else
                return 23;
        }
        else
            return nRnd;
    }

    return Random(9);

}

void main()
{
    // This line ensures the Random function behaves randomly.
    int iRandomize = Random( Random( GetTimeMillisecond()));

    int nAppType  = GetLocalInt(OBJECT_SELF, "APPEARANCE_TYPE");
    int nAppear;
    // Creature model Appearance switches on spawn to one within an array
    // the value is equivalent to the index of appearance.2da
    if(nAppType==99)
    {
        int nAppCnt   = GetLocalInt(OBJECT_SELF, "APPEARANCE_COUNT");
        string sAppID   = IntToString(Random(nAppCnt)+1);

            nAppear     = GetLocalInt(OBJECT_SELF,"APPEARANCE_"+sAppID);
        if(nAppear>0)
            SetCreatureAppearanceType(OBJECT_SELF, nAppear);
        return; // nothing else to change
    }

    // Parts based NPC models
        nAppear = GetAppearanceType(OBJECT_SELF);
    int nSex    = GetGender(OBJECT_SELF);

    int nHead   = 999;
    int nHands  = 999;
    int nFeet   = 999;
    int nShins  = 999;
    int nHair   = 999;
    int nSkin   = 999;
    int nTat1   = 999;
    int nTat2   = 999;
    string sHorns;

/*    // Generic Civilized NPC ---------------------------------------------------
    if(nAppType==1)
    {
       // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }

        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(16);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(7);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(16);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(12);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(16);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(16);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(37);
            if(nHead==27)
                nHead=110;
            else if(nHead==33)
                nHead=44;
            else if(nHead==34)
                nHead=43;
            else if(nHead==37)
                nHead=42;
            else if(nHead==2)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(34);
            if(nHead==34)
                nHead=120;
            else if(nHead==12)
                nHead=40;
            else if(nHead==21)
                nHead=42;
        }
        // SKIN
        nSkin   = Random(16);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }

//------------------------------------------------------------------------------
    // generic woods/rustic
    else if(nAppType==2)
    {
       // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }

        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(16);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(7);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(16);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(12);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(16);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(16);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(37);
            if(nHead==27)
                nHead=110;
            else if(nHead==33)
                nHead=44;
            else if(nHead==34)
                nHead=43;
            else if(nHead==37)
                nHead=42;
            else if(nHead==2)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(34);
            if(nHead==34)
                nHead=120;
            else if(nHead==12)
                nHead=40;
            else if(nHead==21)
                nHead=42;
        }
        // SKIN
        nSkin   = Random(16);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }


*/






// ---------------------OLDFOG MODIFICATIONS # 1 Hill's Edge Commoners-----------------------------------------------------------------------------------------

    // Generic Civilized NPC ---------------------------------------------------
    if(nAppType==10)
    {
      /* // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }
      */
        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(5);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(8);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(16);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {

            nHead   = 1+Random(70);
            if(nHead==11)
                nHead=86;
            else if(nHead==14)
                nHead=88;
            else if(nHead==20)
                nHead=97;
            else if(nHead==26)
                nHead=103;
            else if(nHead==27)
                nHead=106;
            else if(nHead==33)
                nHead=108;
            else if(nHead==34)
                nHead=112;
            else if(nHead==38)
                nHead=130;
            else if(nHead==39)
                nHead=132;
            else if(nHead==45)
                nHead=134;
            else if(nHead==52)
                nHead=135;
            else if(nHead==56)
                nHead=137;
            else if(nHead==57)
                nHead=138;
            else if(nHead==65)
                nHead=149;
            else if(nHead==67)
                nHead=155;
            else if(nHead==71)
                nHead=160;

        }
        else
        {
            nHead   = 1+Random(63);
            if(nHead==11)
                nHead=81;
            else if(nHead==14)
                nHead=82;
            else if(nHead==20)
                nHead=86;
            else if(nHead==21)
                nHead=89;
            else if(nHead==26)
                nHead=90;
            else if(nHead==27)
                nHead=94;
            else if(nHead==47)
                nHead=102;
            else if(nHead==50)
                nHead=111;
            else if(nHead==51)
                nHead=117;
            else if(nHead==52)
                nHead=135;
            else if(nHead==53)
                nHead=136;
            else if(nHead==60)
                nHead=137;
            else if(nHead==61)
                nHead=138;
            else if(nHead==62)
                nHead=139;
            else if(nHead==63)
                nHead=146;
            else if(nHead==64)
                nHead=81;
        }
        // SKIN
        nSkin   = Random(5);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }


// ---------------------END OLDFOG MODIFICATIONS -----------------------------------------------------------------------------------------

// ---------------------OLDFOG MODIFICATIONS # 1 Hill's Edge Workers-----------------------------------------------------------------------------------------

    // Generic Civilized NPC ---------------------------------------------------
    if(nAppType==11)
    {
      /* // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }
      */
        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(5);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(12);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {

            nHead   = 1+Random(70);
            if(nHead==11)
                nHead=86;
            else if(nHead==14)
                nHead=88;
            else if(nHead==20)
                nHead=97;
            else if(nHead==26)
                nHead=103;
            else if(nHead==27)
                nHead=106;
            else if(nHead==33)
                nHead=108;
            else if(nHead==34)
                nHead=112;
            else if(nHead==38)
                nHead=130;
            else if(nHead==39)
                nHead=132;
            else if(nHead==45)
                nHead=134;
            else if(nHead==52)
                nHead=135;
            else if(nHead==56)
                nHead=137;
            else if(nHead==57)
                nHead=138;
            else if(nHead==65)
                nHead=149;
            else if(nHead==67)
                nHead=155;
            else if(nHead==71)
                nHead=160;

        }
        else
        {
            nHead   = 1+Random(63);
            if(nHead==11)
                nHead=81;
            else if(nHead==14)
                nHead=82;
            else if(nHead==20)
                nHead=86;
            else if(nHead==21)
                nHead=89;
            else if(nHead==26)
                nHead=90;
            else if(nHead==27)
                nHead=94;
            else if(nHead==47)
                nHead=102;
            else if(nHead==50)
                nHead=111;
            else if(nHead==51)
                nHead=117;
            else if(nHead==52)
                nHead=135;
            else if(nHead==53)
                nHead=136;
            else if(nHead==60)
                nHead=137;
            else if(nHead==61)
                nHead=138;
            else if(nHead==62)
                nHead=139;
            else if(nHead==63)
                nHead=146;
            else if(nHead==64)
                nHead=81;
        }
        // SKIN
        nSkin   = Random(5);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }


// ---------------------END OLDFOG MODIFICATIONS -----------------------------------------------------------------------------------------


// ---------------------OLDFOG MODIFICATIONS # 2 Hill's Edge Nobles-----------------------------------------------------------------------------------------

    // Generic Civilized NPC ---------------------------------------------------
    if(nAppType==12)
    {
      /* // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }
      */
        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(5);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(12);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {

            nHead   = 1+Random(70);
            if(nHead==11)
                nHead=86;
            else if(nHead==14)
                nHead=88;
            else if(nHead==20)
                nHead=97;
            else if(nHead==26)
                nHead=103;
            else if(nHead==27)
                nHead=106;
            else if(nHead==33)
                nHead=108;
            else if(nHead==34)
                nHead=112;
            else if(nHead==38)
                nHead=130;
            else if(nHead==39)
                nHead=132;
            else if(nHead==45)
                nHead=134;
            else if(nHead==52)
                nHead=135;
            else if(nHead==56)
                nHead=137;
            else if(nHead==57)
                nHead=138;
            else if(nHead==65)
                nHead=149;
            else if(nHead==67)
                nHead=155;
            else if(nHead==71)
                nHead=160;

        }
        else
        {
            nHead   = 1+Random(63);
            if(nHead==11)
                nHead=81;
            else if(nHead==14)
                nHead=82;
            else if(nHead==20)
                nHead=86;
            else if(nHead==21)
                nHead=89;
            else if(nHead==26)
                nHead=90;
            else if(nHead==27)
                nHead=94;
            else if(nHead==47)
                nHead=102;
            else if(nHead==50)
                nHead=111;
            else if(nHead==51)
                nHead=117;
            else if(nHead==52)
                nHead=135;
            else if(nHead==53)
                nHead=136;
            else if(nHead==60)
                nHead=137;
            else if(nHead==61)
                nHead=138;
            else if(nHead==62)
                nHead=139;
            else if(nHead==63)
                nHead=146;
            else if(nHead==64)
                nHead=81;
        }
        // SKIN
        nSkin   = Random(5);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }


// ---------------------END OLDFOG MODIFICATIONS -----------------------------------------------------------------------------------------




// ---------------------OLDFOG MODIFICATIONS # 2 Hill's LOW CLASS COMMONER-----------------------------------------------------------------------------------------

    // Generic Civilized NPC ---------------------------------------------------
    if(nAppType==13)
    {
      /* // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }
      */
        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(5);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(12);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {

            nHead   = 1+Random(70);
            if(nHead==11)
                nHead=86;
            else if(nHead==14)
                nHead=88;
            else if(nHead==20)
                nHead=97;
            else if(nHead==26)
                nHead=103;
            else if(nHead==27)
                nHead=106;
            else if(nHead==33)
                nHead=108;
            else if(nHead==34)
                nHead=112;
            else if(nHead==38)
                nHead=130;
            else if(nHead==39)
                nHead=132;
            else if(nHead==45)
                nHead=134;
            else if(nHead==52)
                nHead=135;
            else if(nHead==56)
                nHead=137;
            else if(nHead==57)
                nHead=138;
            else if(nHead==65)
                nHead=149;
            else if(nHead==67)
                nHead=155;
            else if(nHead==71)
                nHead=160;

        }
        else
        {
            nHead   = 1+Random(63);
            if(nHead==11)
                nHead=81;
            else if(nHead==14)
                nHead=82;
            else if(nHead==20)
                nHead=86;
            else if(nHead==21)
                nHead=89;
            else if(nHead==26)
                nHead=90;
            else if(nHead==27)
                nHead=94;
            else if(nHead==47)
                nHead=102;
            else if(nHead==50)
                nHead=111;
            else if(nHead==51)
                nHead=117;
            else if(nHead==52)
                nHead=135;
            else if(nHead==53)
                nHead=136;
            else if(nHead==60)
                nHead=137;
            else if(nHead==61)
                nHead=138;
            else if(nHead==62)
                nHead=139;
            else if(nHead==63)
                nHead=146;
            else if(nHead==64)
                nHead=81;
        }
        // SKIN
        nSkin   = Random(5);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }


// ---------------------END OLDFOG MODIFICATIONS -----------------------------------------------------------------------------------------

// ---------------------OLDFOG MODIFICATIONS # 2 Hill's LOW CLASS COMMONER-----------------------------------------------------------------------------------------

    // Drawn Swords Archers ---------------------------------------------------
    if(nAppType==14)
    {
      /* // decided not to switch apperance because the phenotype typically gets messed up
      int nPheno  = GetPhenoType(OBJECT_SELF);
      int nRnd = Random(100)+1;
      if(nRnd>=70)
      {
        switch(d12())
        {
            case 1:nAppear=2;break;// gnome
            case 2:nAppear=5;break;// orclun
            case 3:
            case 4:nAppear=1;break;// elf
            case 5:
            case 6:
            case 7:
            case 8:nAppear=3;break;// hin
            case 9:
            case 10:
            case 11:
            case 12:nAppear=0;break;// dwarf
            default:nAppear=0;break;

        }

        SetCreatureAppearanceType(OBJECT_SELF,nAppear);
        SetPhenoType(nPheno);
      }
      */
        // HEAD
      // dwarf
      if(nAppear==0)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(15);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // elf
      else if(nAppear==1)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(21);
            if(nHead==15)
                nHead=40;
        }
        else
        {
            nHead   = 1+Random(33);
            if(nHead==14)
                nHead=106;
            else if(nHead==20)
                nHead=40;
        }
        // SKIN
        nSkin   = Random(5);
        if(nSkin>2)
        {
            if(nSkin==3)
                nSkin=8;
            else if(nSkin==4)
                nSkin=9;
            else if(nSkin==5)
                nSkin=12;
            else if(nSkin==6)
                nSkin=13;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(13);
        else
            nHead   = 1+Random(10);

        // SKIN
        nSkin   = Random(5);
      }
      // 1/2ling
      else if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 1+Random(12);
            if(nHead==9)
                nHead=13;
            else if(nHead==11)
                nHead=14;
        }
        else
        {
            nHead   = 1+Random(16);
            if(nHead==3)
                nHead = 21;
            else if(nHead==9)
                nHead=22;
            else if(nHead==10)
                nHead=101;
            else if(nHead==14)
                nHead=102;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // ORCLUN
      else if(nAppear==5)
      {
        if(nSex==GENDER_MALE)
            nHead   = 1+Random(18);
        else
        {
            nHead   = 1+Random(13);
            if(nHead==13)
                nHead=15;
        }
        // SKIN
        nSkin   = Random(5);
      }
      // 1/2 elf or human
      else if(nAppear==4 || nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {

            nHead   = 1+Random(10);
            if(nHead==1)
                nHead=117;
            else if(nHead==2)
                nHead=118;
            else if(nHead==3)
                nHead=120;
            else if(nHead==4)
                nHead=129;
            else if(nHead==5)
                nHead=130;
            else if(nHead==6)
                nHead=144;
            else if(nHead==7)
                nHead=177;
            else if(nHead==8)
                nHead=178;
            else if(nHead==9)
                nHead=179;
            else if(nHead==10)
                nHead=180;
        }
        else
        {
            nHead   = 1+Random(10);
            if(nHead==1)
                nHead=131;
            else if(nHead==2)
                nHead=141;
            else if(nHead==3)
                nHead=160;
            else if(nHead==4)
                nHead=177;
            else if(nHead==5)
                nHead=187;
            else if(nHead==6)
                nHead=188;
            else if(nHead==7)
                nHead=190;
            else if(nHead==8)
                nHead=18;
            else if(nHead==9)
                nHead=37;
            else if(nHead==10)
                nHead=47;

        }
        // SKIN
        nSkin   = Random(5);
     }


        // HAIR
        nHair   = GetHairColorMatchingSkin(nSkin);

        nTat1   = GetTattooColorMatchingSkin(nSkin);
        nTat2   = nTat1;
    }


// ---------------------END OLDFOG MODIFICATIONS -----------------------------------------------------------------------------------------





    // Goblins -----------------------------------------------------------------
    else if(nAppType==50)
    {
      switch(d4())
      {
        case 1: if(nAppear!=6){nAppear=6;SetCreatureAppearanceType(OBJECT_SELF,6);} break;
        case 2: if(nAppear!=3){nAppear=3;SetCreatureAppearanceType(OBJECT_SELF,3);} break;
        default:if(nAppear!=2){nAppear=2;SetCreatureAppearanceType(OBJECT_SELF,2);} break;

      }

        // HEAD
      // 1/2ling
      if(nAppear==3)
      {
        if(nSex==GENDER_MALE)
        {
            nHead   = 171+Random(10);
        }
        else
        {
            if(d4()==1)
                nHead   = 180;
            else
                nHead   = 171;
        }
      }
      // gnome
      else if(nAppear==2)
      {
        if(nSex==GENDER_MALE)
            nHead   = 160+Random(5);
        else
            nHead   = 164;
      }
      // human
      else if(nAppear==6)
      {
        if(nSex==GENDER_MALE)
        {
            switch(d4())
            {
                case 1: nHead=138; break;
                case 2: nHead=139; break;
                case 3: nHead=163; break;
                case 4: nHead=164; break;
                default:nHead=138; break;
            }
        }
        else
        {
            if(d2()==1)
                nHead   = 138;
            else
                nHead   = 139;
        }
      }
        // HANDS
        switch(d4())
        {
            case 1: nHands=201; break;
            case 2: nHands=203; break;
            default: nHands=208; break;
        }
        // FEET
        switch(d6())
        {
            case 1: nFeet=200;nShins=213; break;
            case 2: nFeet=210; break;
            case 3: nFeet=216; break;
            default:nFeet=217; break;
        }

        // SKIN
        nSkin   = 169 +Random(5);
        // HAIR
        nHair   = Random(9)+14;
    }
    // end goblins -------------------------------------------------------------
    /*
    switch(nRace)
    {
        case RACIAL_TYPE_HUMAN:
          if(nSex==GENDER_MALE)
          {
            // Head Male Human
            nHead    = Random(32)+1;
            if(nHead<4)
                nHead=1;
            else if(nHead==11)
                nHead=10;
            else if(nHead==14)
                nHead=13;
            else if(nHead>18&&nHead<22)
                nHead=18;
            else if(nHead>24&&nHead<28)
                nHead=24;
          }
          else
          {
            // Head Female Human
            nHead    = Random(33)+1;
            if(nHead==6)
                nHead=5;
            else if(nHead>10&&nHead<15)
                nHead=10;
            else if(nHead==21)
                nHead=20;
            else if(nHead>25&&nHead<29)
                nHead=25;
          }
            // Color
            if(nAppType==4)//aderlating commoner
            {
                nHair   = Random(3)+13;
                nSkin   = Random(4)+1;

                nTat2   = 5;
            }
            else
            {
                nHair   = Random(8);
                nSkin   = Random(3)+1;
                if(nSkin==3)
                    nSkin=12;
                nTat2   = 4;
            }
        break;
        default: break;
    }
    */


    // Make changes
    if(nHead!=999)
        SetCreatureBodyPart( CREATURE_PART_HEAD, nHead, OBJECT_SELF);
    if(nShins!=999)
    {
        SetCreatureBodyPart( CREATURE_PART_LEFT_SHIN, nShins, OBJECT_SELF);
        SetCreatureBodyPart( CREATURE_PART_RIGHT_SHIN, nShins, OBJECT_SELF);
    }
    if(nFeet!=999)
    {
        SetCreatureBodyPart( CREATURE_PART_LEFT_FOOT, nFeet, OBJECT_SELF);
        SetCreatureBodyPart( CREATURE_PART_RIGHT_FOOT, nFeet, OBJECT_SELF);
    }
    if(nHands!=999)
    {
        SetCreatureBodyPart( CREATURE_PART_LEFT_HAND, nHands, OBJECT_SELF);
        SetCreatureBodyPart( CREATURE_PART_RIGHT_HAND, nHands, OBJECT_SELF);
    }

    if(nHair!=999)
        SetColor(OBJECT_SELF, COLOR_CHANNEL_HAIR, nHair);
    if(nSkin!=999)
        SetColor(OBJECT_SELF, COLOR_CHANNEL_SKIN, nSkin);
    if(nTat1!=999)
        SetColor(OBJECT_SELF, COLOR_CHANNEL_TATTOO_1, nTat1);
    if(nTat2!=999)
        SetColor(OBJECT_SELF, COLOR_CHANNEL_TATTOO_2, nTat2);
}
