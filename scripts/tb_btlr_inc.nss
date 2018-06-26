// btlr_inc
// Body tailor include.
// This is modified from the one included in project Q.
// Not sure about the original author.



//******************************************************************************
// FUNCTIONS

#include "tlr_inc_utils"


string bt_GetPartName(int nPart) {

        switch (nPart) {
                case CREATURE_PART_HEAD:           return "head";            // 20
                case CREATURE_PART_TORSO:          return "torso";           // 7
                case CREATURE_PART_LEFT_BICEP:     return "left bicep";      // 13
                case CREATURE_PART_RIGHT_BICEP:    return "right bicep";     // 12
                case CREATURE_PART_LEFT_FOREARM:   return "left forearm";    // 11
                case CREATURE_PART_RIGHT_FOREARM:  return "right forearm";   // 10
                case CREATURE_PART_LEFT_THIGH:     return "left thigh";      // 4
                case CREATURE_PART_RIGHT_THIGH:    return "right thigh";     // 5
                case CREATURE_PART_LEFT_SHIN:      return "left shin";       // 3
                case CREATURE_PART_RIGHT_SHIN:     return "right shin";      // 2
                case CREATURE_PART_LEFT_FOOT:      return "left foot";       // 1
                case CREATURE_PART_RIGHT_FOOT:     return "right foot";      // 0
                case CREATURE_PART_PELVIS:         return "pelvis";          // 6
                case CREATURE_PART_BELT:           return "belt";            // 8
                case CREATURE_PART_LEFT_HAND:      return "left hand";       // 17
                case CREATURE_PART_RIGHT_HAND:     return "right hand";      // 16
                case CREATURE_PART_LEFT_SHOULDER:  return "left shoulder";   // 15
                case CREATURE_PART_RIGHT_SHOULDER: return "right shoulder";  // 14
                case CREATURE_PART_NECK:           return "neck";            // 9
        }
        return "Ooops";
}

string bt_GetChannelName(int nChannel) {
        switch (nChannel){
                case COLOR_CHANNEL_SKIN: return "skin";
                case COLOR_CHANNEL_HAIR: return "hair";
                case COLOR_CHANNEL_TATTOO_1: return "tattoo 1";
                case COLOR_CHANNEL_TATTOO_2: return "tattoo 2";
        }
        return "Ooops";
}

void bt_PrepareBodyTailor(object oPC, int nPart) {
    // Store what part is being modified and the base body part ID
        SetLocalInt(oPC, "Body_Part_Modified", nPart);
        int nID = GetCreatureBodyPart(nPart, oPC);
        SetLocalInt(oPC, "Body_Part_ID", nID);

    // Remove clothes and shield, store clothing
        object oClothes = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
        object oShield =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);

        if (GetLocalObject(oPC, "CLOTHES_ON") == OBJECT_INVALID) {
                SetLocalObject(oPC, "CLOTHES_ON", oClothes);
        }
        if (GetIsObjectValid(oShield) && (GetBaseItemType(oShield) == BASE_ITEM_LARGESHIELD ||
          GetBaseItemType(oShield) == BASE_ITEM_SMALLSHIELD ||
          GetBaseItemType(oShield) == BASE_ITEM_TOWERSHIELD ))
        {
                AssignCommand(oPC, ActionUnequipItem(oShield));
        }
        AssignCommand(oPC, ActionUnequipItem(oClothes));
}


int btGetNextHead(int nID, int nGender, int nAppear, int bDec = FALSE) {
        string sAllow = "";
        string sDeny = "";
        int nBottom = 1;
        int nTop = 212;

        if (nGender == GENDER_MALE) {
                      //1, 3-13, 15-19, 21-32, 35-36, 38, 40-43, 48-53, 55-62, 100-103, 105-123,132, 135, 138,
                      // 145-156, 158-160 163-165
                if (nAppear == APPEARANCE_TYPE_HUMAN) {
                        sAllow="1-212";
                        sDeny ="33,34,39,45,100,107,109,117,118,119,120,129,144,146,150,154,162,169,170,171,177,178,179,180,185,196,197,208";
                        nTop = 212;
                }
            //1, 3-13, 15-19, 21-32, 35-36, 38, 40-43, 48-53, 55-62, 100-103, 105-123,132, 135, 138,
            //   145-156, 158-160 163-165
                else if (nAppear == APPEARANCE_TYPE_HALF_ELF ) {

                        sAllow="1-212";
                        sDeny ="33,34,39,45,100,107,109,117,118,119,120,129,144,146,150,154,162,169,170,171,177,178,179,180,185,196,197,208";
                        nTop = 212;
                }

            //Male Dwarf  1-13,15, 19 21-24
                else if (nAppear == APPEARANCE_TYPE_DWARF) {
                        sAllow="1-14,17-19,21-28,35,101,115-124";
                        sDeny ="26,116,120";
                        nTop = 124;
                }
            // Male Elf  1-9, 11, 13-14, 16-22, 25, 29-35, 111
                else if (nAppear == APPEARANCE_TYPE_ELF) {
                        sAllow="1-20,39-44,101,104,108-111,118,136,138-141";
                        sDeny ="10,15";
                        nTop = 141;
                }
            // Male Gnome   1-13, 15-16, 19-23, 34-35
                else if (nAppear == APPEARANCE_TYPE_GNOME) {
                        sAllow="1-23,34,35";
                        sDeny ="14,17,18";
                        nTop = 35;
                }
            // Male half-orc : 1-14, 20,21 23-25 30,31
                else if (nAppear == APPEARANCE_TYPE_HALF_ORC) {
                        sAllow="1-14,20,21,23-25,30,31";
                        sDeny ="";
                        nTop = 35;
                }
            //  Male halfling : 1-8, 10-14, 160-161
                else if (nAppear == APPEARANCE_TYPE_HALFLING){
                        sAllow="1-8,23,";
                        sDeny ="";
                        nTop = 23;
                }
        }

        else if (nGender == GENDER_FEMALE) {

             //Female humans 1-11, 13, 15-25 28-38 51-64 100-107, 112, 114, 116-117, 120, 122, 124-127, 129-133, 135, 137, 147-149, 153, 155-156,
                //158-159, 164,172, 180 182, 190, 191
              // remove ears
                if (nAppear == APPEARANCE_TYPE_HUMAN) {
                        sAllow="1-217";
                        sDeny ="14,26,27,50,67,73,76,131,141,160,161,167,177,187,188,190,192,212";
                        nTop = 217;
                }

            //Female half-elf  1-11, 13, 15-25 28-38 45-64 100-107, 112, 114, 116-118, 120-127, 129-133, 135, 137, 147-149, 153, 155-156,
                //158-159, 164,172, 180 182, 190, 191
                else if (nAppear == APPEARANCE_TYPE_HALF_ELF ) {
                        sAllow="1-217";
                        sDeny ="14,26,27,50,67,73,76,131,141,160,161,167,177,187,188,190,192,212";
                        nTop = 217;
                }
            // Femal dwarf  1-16, 18, 20-21
                else if (nAppear == APPEARANCE_TYPE_DWARF) {
                        sAllow="1-18";
                        sDeny ="";
                        nTop = 18;
                }
            // Female elf :1, 6-13, 15-33, 35-37,39-43, 47-49,  101-103, 106, 111, 112, 122,179-182
                else if (nAppear == APPEARANCE_TYPE_ELF) {
                        sAllow="1-59,106-109,115,122,138,140,141,142,176,180";
                        sDeny ="14,38,108";
                        nTop = 180;
                }
            // Female gnome 1-4, 6-10
                else if (nAppear == APPEARANCE_TYPE_GNOME) {
                        sAllow="";
                        sDeny ="5";
                        nTop = 10;
                }

            // Female Half-orc 1-12, 14
                else if (nAppear == APPEARANCE_TYPE_HALF_ORC) {
                        sAllow="";
                        sDeny ="13";
                        nTop = 14;
                }
            //  Fem halfling  1, 5-8, 11-15, 102, 162-165
                if (nAppear == APPEARANCE_TYPE_HALFLING){
                        sAllow="1,2,4-9,11-18,21,102,107,194";
                        sDeny ="14,16";
                        nTop = 194;
                }
        }
        if (bDec)
                return tlrGetPrevIdx(nID, nBottom, nTop, sAllow, sDeny);
        return tlrGetNextIdx(nID, nBottom, nTop, sAllow, sDeny);;
}

int btGetNextBodyPart(int nID, int nPart, int nGender, int nAppear, int bDec = FALSE) {
        string sAllow = "";
        string sDeny = "";
        int nBottom = 1;
        int nTop = 254;

        switch (nPart) {
        case CREATURE_PART_TORSO:
                // orig :1,2,159-162,166-169,170-178
                // cur: some duplicates :1,2,160-162,183,216"
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;
        case CREATURE_PART_LEFT_BICEP:
        case CREATURE_PART_RIGHT_BICEP:
                // orig: top 180  : 1,2,13,15,156,159,162,180
                // 156 is an arm band -
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;
        case CREATURE_PART_LEFT_FOREARM:
        case CREATURE_PART_RIGHT_FOREARM:
                //top 181 : orig 1,151-153,157,162,164,166,167,181
                // cur 1,2,152,153,157
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;
        case CREATURE_PART_LEFT_THIGH:
        case CREATURE_PART_RIGHT_THIGH:
                // top 180 : 1,2,154,180
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;
        case CREATURE_PART_LEFT_SHIN:
        case CREATURE_PART_RIGHT_SHIN:
                // top 157: 1,2,152,156,157(anklet)
                sAllow="1-254";
                sDeny="";
                 nTop=254;
                break;
        case CREATURE_PART_LEFT_HAND:
        case CREATURE_PART_RIGHT_HAND:
                //
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;
        case CREATURE_PART_LEFT_FOOT:
        case CREATURE_PART_RIGHT_FOOT:
                //
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;
        case CREATURE_PART_PELVIS:
                //1,2,134-137
                sAllow="1-254";
                sDeny="";
                nTop=254;
                break;

        }
        if (bDec)
                return tlrGetPrevIdx(nID, nBottom, nTop, sAllow, sDeny);
        return tlrGetNextIdx(nID, nBottom, nTop, sAllow, sDeny);;
}

void bt_IncrementBodyPart(object oPC, int nPart) {
        int nID = GetCreatureBodyPart(nPart, oPC);

    // Set parameters for body parts - this is gonna be a huge section
        int nAppear = GetAppearanceType(oPC);
        int nGender = GetGender(oPC);
        if (nPart == CREATURE_PART_HEAD) {
                nID = btGetNextHead(nID, nGender, nAppear, FALSE);
        }
        else  {
                nID  = btGetNextBodyPart(nID, nPart, nGender, nAppear, FALSE);
        }

        string sPart = bt_GetPartName(nPart);
        SendMessageToPC(oPC, "Setting " + sPart + " to " + IntToString(nID));
        SetCreatureBodyPart(nPart, nID, oPC);
}

void bt_DecrementBodyPart(object oPC, int nPart) {
        int nID = GetCreatureBodyPart(nPart, oPC);

    // Set parameters for body parts - this is gonna be a huge section
        int nAppear = GetAppearanceType(oPC);
        int nGender = GetGender(oPC);

        if (nPart == CREATURE_PART_HEAD) {
                nID = btGetNextHead(nID, nGender, nAppear, TRUE);
        } else {
                nID  = btGetNextBodyPart(nID, nPart, nGender, nAppear, TRUE);
        }

        string sPart = bt_GetPartName(nPart);
        SendMessageToPC(oPC, "Setting " + sPart + " to " + IntToString(nID));
        SetCreatureBodyPart(nPart, nID, oPC);
}

void bt_ResetBodyTailor(object oPC, int bKeep = FALSE) {

        int nPart = GetLocalInt(oPC, "Body_Part_Modified");
        int nID   = GetLocalInt(oPC, "Body_Part_ID");

        if (!bKeep && nID > 0) {
                SetCreatureBodyPart(nPart, nID, oPC);
        }

        DeleteLocalInt(oPC, "Body_Part_Modified");
        DeleteLocalInt(oPC, "Body_Part_ID");

        object oClothes = GetLocalObject(oPC, "CLOTHES_ON");
        if (GetIsObjectValid(oClothes)) {
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, ActionEquipItem(oClothes, INVENTORY_SLOT_CHEST));

        }
        DeleteLocalObject(oPC, "CLOTHES_ON");

}

void bt_PrepareColorTailor(object oPC, int nChannel) {
    // Store what channel is being modified and the base body part ID
    SetLocalInt(oPC, "Color_Channel_Modified", nChannel);
    int nID = GetColor(oPC, nChannel);
    SetLocalInt(oPC, "Color_ID", nID);

    // Remove clothes and shield, store clothing
    object oClothes = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    object oShield =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);

    if (GetLocalObject(oPC, "CLOTHES_ON") == OBJECT_INVALID) {
        SetLocalObject(oPC, "CLOTHES_ON", oClothes);
    }
    if (GetIsObjectValid(oShield) && (GetBaseItemType(oShield) == BASE_ITEM_LARGESHIELD ||
                                      GetBaseItemType(oShield) == BASE_ITEM_SMALLSHIELD ||
                                      GetBaseItemType(oShield) == BASE_ITEM_TOWERSHIELD )) {
        AssignCommand(oPC, ActionUnequipItem(oShield));
    }
    AssignCommand(oPC, ActionUnequipItem(oClothes));
}

void bt_IncrementColor(object oPC, int nChannel) {
    int nColor = GetColor(oPC, nChannel);
    nColor ++;
    if (nColor > 175) {
        nColor = 0;
    }
    SendMessageToPC(oPC, "Setting " + bt_GetChannelName(nChannel) +  " color to " + IntToString(nColor));
    SetColor(oPC, nChannel, nColor);
}

void bt_DecrementColor(object oPC, int nChannel) {
    int nColor = GetColor(oPC, nChannel);
    nColor --;

    if (nColor < 0) {
        nColor = 175;
    }

    SendMessageToPC(oPC, "Setting " + bt_GetChannelName(nChannel) +  " color to " + IntToString(nColor));
    SetColor(oPC, nChannel, nColor);
}

void bt_SetColor(object oPC, int nChannel, int nColor) {

    if (nColor < 0 || nColor > 175) {
        return;
    }
    SendMessageToPC(oPC, "Setting " + bt_GetChannelName(nChannel) +  " color to " + IntToString(nColor));
    SetColor(oPC, nChannel, nColor);
}

void bt_ResetColorTailor(object oPC, int bKeep = FALSE) {

        int nChannel = GetLocalInt(oPC, "Color_Channel_Modified");
        int nID   = GetLocalInt(oPC, "Color_ID");

        if (!bKeep && nID > 0) {
                SetColor(oPC, nChannel, nID);
        }

        DeleteLocalInt(oPC, "Color_Channel_Modified");
        DeleteLocalInt(oPC, "Color_ID");

        object oClothes = GetLocalObject(oPC, "CLOTHES_ON");
        if (GetIsObjectValid(oClothes)) {
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, ActionEquipItem(oClothes, INVENTORY_SLOT_CHEST));

        }
        DeleteLocalObject(oPC, "CLOTHES_ON");
}

void bt_dumpBodyParts(object oPC, object oCreature) {

        SendMessageToPC(oPC, "BODY PART for " + GetName(oCreature));

        string space = "                ";
        int i;
        for (i = 0 ; i <= 20 ; i ++ ) {
                if (i == 18 || i == 19)
                        continue;

                int nID =  GetCreatureBodyPart(i, oPC);
                string sName = bt_GetPartName(i);

                SendMessageToPC(oPC, sName  + GetStringLeft(space, GetStringLength(space) - GetStringLength(sName)) + ": " + IntToString(nID));
        }
}



/*
// TailModel.2da
const int CREATURE_TAIL_TYPE_DRAGON_BRASS   = 4;
const int CREATURE_TAIL_TYPE_DRAGON_BRONZE  = 5;
const int CREATURE_TAIL_TYPE_DRAGON_COPPER  = 6;
const int CREATURE_TAIL_TYPE_DRAGON_SILVER  = 7;
const int CREATURE_TAIL_TYPE_DRAGON_GOLD    = 8;
const int CREATURE_TAIL_TYPE_DRAGON_BLACK   = 9;
const int CREATURE_TAIL_TYPE_DRAGON_BLUE    = 10;
const int CREATURE_TAIL_TYPE_DRAGON_GREEN   = 11;
const int CREATURE_TAIL_TYPE_DRAGON_RED     = 12;
const int CREATURE_TAIL_TYPE_DRAGON_WHITE   = 13;
const int CREATURE_TAIL_TYPE_CAT_PLT        = 565;
const int CREATURE_TAIL_TYPE_DEVIL_PLT      = 566;
const int CREATURE_TAIL_TYPE_LIZARD_PLT     = 567;

// WingModel.2da
const int CREATURE_WING_TYPE_DEMON_PLT          = 22;
const int CREATURE_WING_TYPE_ANGEL_PLT          = 23;
const int CREATURE_WING_TYPE_BAT_PLT            = 24;
const int CREATURE_WING_TYPE_BUTTERFLY_PLT      = 25;
const int CREATURE_WING_TYPE_BIRD_PLT           = 26;
const int CREATURE_WING_TYPE_DRAGON_PLT         = 27;
const int CREATURE_WING_TYPE_DRAGON_BRASS       = 59;
const int CREATURE_WING_TYPE_DRAGON_BRONZE      = 60;
const int CREATURE_WING_TYPE_DRAGON_COPPER      = 61;
const int CREATURE_WING_TYPE_DRAGON_SILVER      = 62;
const int CREATURE_WING_TYPE_DRAGON_GOLD        = 63;
const int CREATURE_WING_TYPE_DRAGON_WHITE       = 64;
const int CREATURE_WING_TYPE_DRAGON_BLACK       = 65;
const int CREATURE_WING_TYPE_DRAGON_GREEN       = 66;
const int CREATURE_WING_TYPE_DRAGON_BLUE        = 67;
const int CREATURE_WING_TYPE_DRAGON_RED         = 68;
const int CREATURE_WING_TYPE_DRAGON_BRASS_2     = 69;
const int CREATURE_WING_TYPE_DRAGON_BRONZE_2    = 70;
const int CREATURE_WING_TYPE_DRAGON_COPPER_2    = 71;
const int CREATURE_WING_TYPE_DRAGON_SILVER_2    = 72;
const int CREATURE_WING_TYPE_DRAGON_GOLD_2      = 73;
const int CREATURE_WING_TYPE_DRAGON_WHITE_2     = 74;
const int CREATURE_WING_TYPE_DRAGON_BLACK_2     = 75;
const int CREATURE_WING_TYPE_DRAGON_GREEN_2     = 76;
const int CREATURE_WING_TYPE_DRAGON_BLUE_2      = 77;
const int CREATURE_WING_TYPE_DRAGON_RED_2       = 78;
*/

/* these are unused in essea  -
void bt_SetTail(object oPC, int nTail)
{
    SetLocalInt(oPC, "Base_Tail_Model", GetCreatureTailType(oPC));
    SetCreatureTailType(nTail, oPC);
}

void bt_ResetTail(object oPC)
{
    int nTail = GetLocalInt(oPC, "Base_Tail_Model");
    SetCreatureTailType(nTail, oPC);
    DeleteLocalInt(oPC, "Base_Tail_Model");
}

void bt_SetWings(object oPC, int nTail)
{
    SetLocalInt(oPC, "Base_Wings_Model", GetCreatureWingType(oPC));
    SetCreatureWingType(nTail, oPC);
}

void bt_ResetWings(object oPC)
{
    int nTail = GetLocalInt(oPC, "Base_Wings_Model");
    SetCreatureWingType(nTail, oPC);
    DeleteLocalInt(oPC, "Base_Wings_Model");
}
*/
