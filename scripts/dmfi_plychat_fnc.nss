//::///////////////////////////////////////////////
//:: dmfi_plychat_fnc
//:://////////////////////////////////////////////
//:: DMFI - OnPlayerChat functions processor
//:: original: dmfi_plychat_exe
//:://////////////////////////////////////////////
/*
  Include for the OnPlayerChat-triggered DMFI functions.

    Custom Modifications added:
    Ambiguous Interactive Dungeons (AID) by Layonara Team and modified by The Magus

    IMPORTANT:
    If you are using AID you need to uncomment 2 lines.
    Search for _AID_ and read the instructions.

*/
//:://////////////////////////////////////////////
//:: Created By: The DMFI Team
//:://////////////////////////////////////////////
//:: 2007.12.12 Merle
//::    - revisions for NWN patch 1.69
//:: 2008.03.24 tsunami282
//::    - renamed from dmfi_voice_exe, updated to work with event hooking system
//:: 2008.06.23 Prince Demetri & Night Journey
//::    - added languages: Sylvan, Mulhorandi, Rashemi
//:: 2008.07.30 morderon
//::    - better emote processing, allow certain dot commands for PC's
//:: 2011.12.29 Magus
//::    - removed Main and saved as dmfi_plychat_fnc
//::    - rewrote ParseEmote to work with _AID_
//::        and improved interpretation of emotes
//:: 2012.09.10 Magus
//::    - Added emote parsing for Vaei's additional animations

#include "x2_inc_switches"
#include "x0_i0_stringlib"
#include "dmfi_string_inc"
#include "dmfi_plchlishk_i"
#include "dmfi_db_inc"
// _AID_ uncomment the line below if you are using AID. See ParseEmote
#include "aid_inc_fcns"

#include "_inc_languages"

const int DMFI_LOG_CONVERSATION = TRUE; // turn on or off logging of conversation text
const int DMFI_EMOTE_SAVES      = TRUE; // turn on or off the response to saving throws in ParseEmote

// FUNCTIONS DECLARED //////////////////////////////////////////////////////////
//[file: dmfi_plychat_fnc]
void EmoteDance(object oPC);
//[file: dmfi_plychat_fnc]
int AppearType (string sCom);
//[file: dmfi_plychat_fnc]
void dmw_CleanUp(object oMySpeaker);
//[file: dmfi_plychat_fnc]
location GetLocationAboveAndInFrontOf(object oPC, float fDist, float fHeight);
//Smoking Function by Jason Robinson [file: dmfi_plychat_fnc]
void SmokePipe(object oActivator);
//Parses Emotes and Integrates with _AID_ (changed by Magus) [file: dmfi_plychat_fnc]
void ParseEmote(string sEmote, object oPC);

//[file: dmfi_plychat_fnc]
// Generic utility function. Name Colision with others?
int GetIsAlphanumeric(string sCharacter);
//[file: dmfi_plychat_fnc]
void ParseCommand(object oTarget, object oCommander, string sComIn);

//[file: dmfi_plychat_fnc]
// Necessary function?
int RelayTextToEavesdropper(object oShouter, int nVolume, string sSaid);

// FUNCTIONS IMPLEMENTED ///////////////////////////////////////////////////////

void EmoteDance(object oPC)
{
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
    object oLeftHand =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);

    AssignCommand(oPC,ActionUnequipItem(oRightHand));
    AssignCommand(oPC,ActionUnequipItem(oLeftHand));

    int nType   = GetAppearanceType(oPC);
    if(     GetGender(oPC)==GENDER_FEMALE
        &&  (nType==APPEARANCE_TYPE_HUMAN || nType==APPEARANCE_TYPE_HALF_ELF)
      )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM19,2.0,120.0));
    else
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM20,2.0,120.0));

    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_BOW));
    /*
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY2,1.0));
    AssignCommand(oPC,ActionDoCommand(PlayVoiceChat(VOICE_CHAT_LAUGH,oPC)));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_LOOPING_TALK_LAUGHING, 2.0, 2.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY1,1.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY3,2.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_LOOPING_GET_MID, 3.0, 1.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_LOOPING_TALK_FORCEFUL,1.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY2,1.0));
    AssignCommand(oPC,ActionDoCommand(PlayVoiceChat(VOICE_CHAT_LAUGH,oPC)));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_LOOPING_TALK_LAUGHING, 2.0, 2.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY1,1.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY3,2.0));
    AssignCommand(oPC,ActionDoCommand(PlayVoiceChat(VOICE_CHAT_LAUGH,oPC)));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_LOOPING_GET_MID, 3.0, 1.0));
    AssignCommand(oPC,ActionPlayAnimation( ANIMATION_FIREFORGET_VICTORY2,1.0));


    AssignCommand(oPC,ActionDoCommand(ActionEquipItem(oLeftHand,INVENTORY_SLOT_LEFTHAND)));
    AssignCommand(oPC,ActionDoCommand(ActionEquipItem(oRightHand,INVENTORY_SLOT_RIGHTHAND)));
    */
}

int AppearType (string sCom)
{
//  2008.03.24 tsunami282 - pull descriptions from 2da first; allow numerics

    // is it numeric? If so just convert and return
    if (TestStringAgainstPattern("*n", sCom)) return StringToInt(sCom);
    if (sCom == "ARANEA")
        return APPEARANCE_TYPE_ARANEA;
    if (sCom == "ALLIP")
        return APPEARANCE_TYPE_ALLIP;
    if (sCom == "ARCH_TARGET")
        return APPEARANCE_TYPE_ARCH_TARGET;
    if (sCom == "ARIBETH")
        return APPEARANCE_TYPE_ARIBETH;
    if (sCom == "ASABI_CHIEFTAIN")
        return APPEARANCE_TYPE_ASABI_CHIEFTAIN;
    if (sCom == "ASABI_SHAMAN")
        return APPEARANCE_TYPE_ASABI_SHAMAN;
    if (sCom == "ASABI_WARRIOR")
        return APPEARANCE_TYPE_ASABI_WARRIOR;
    if (sCom == "BADGER")
        return APPEARANCE_TYPE_BADGER;
    if (sCom == "BADGER_DIRE")
        return APPEARANCE_TYPE_BADGER_DIRE;
    if (sCom == "BALOR")
        return APPEARANCE_TYPE_BALOR;
    if (sCom == "BARTENDER")
        return APPEARANCE_TYPE_BARTENDER;
    if (sCom == "BASILISK")
        return APPEARANCE_TYPE_BASILISK;
    if (sCom == "BAT")
        return APPEARANCE_TYPE_BAT;
    if (sCom == "BAT_HORROR")
        return APPEARANCE_TYPE_BAT_HORROR;
    if (sCom == "BEAR_BLACK")
        return APPEARANCE_TYPE_BEAR_BLACK;
    if (sCom == "BEAR_BROWN")
        return APPEARANCE_TYPE_BEAR_BROWN;
    if (sCom == "BEAR_DIRE")
        return APPEARANCE_TYPE_BEAR_DIRE;
    if (sCom == "BEAR_KODIAK")
        return APPEARANCE_TYPE_BEAR_KODIAK;
    if (sCom == "BEAR_POLAR")
        return APPEARANCE_TYPE_BEAR_POLAR;
    if (sCom == "BEETLE_FIRE")
        return APPEARANCE_TYPE_BEETLE_FIRE;
    if (sCom == "BEETLE_SLICER")
        return APPEARANCE_TYPE_BEETLE_SLICER;
    if (sCom == "BEETLE_STAG")
        return APPEARANCE_TYPE_BEETLE_STAG;
    if (sCom == "BEETLE_STINK")
        return APPEARANCE_TYPE_BEETLE_STINK;
    if (sCom == "BEGGER")
        return APPEARANCE_TYPE_BEGGER;
    if (sCom == "BLOOD_SAILER")
        return APPEARANCE_TYPE_BLOOD_SAILER;
    if (sCom == "BOAR")
        return APPEARANCE_TYPE_BOAR;
    if (sCom == "BOAR_DIRE")
        return APPEARANCE_TYPE_BOAR_DIRE;
    if (sCom == "BODAK")
        return APPEARANCE_TYPE_BODAK;
    if (sCom == "BUGBEAR_A")
        return APPEARANCE_TYPE_BUGBEAR_A;
    if (sCom == "BUGBEAR_B")
        return APPEARANCE_TYPE_BUGBEAR_B;
    if (sCom == "BUGBEAR_CHIEFTAIN_A")
        return APPEARANCE_TYPE_BUGBEAR_CHIEFTAIN_A;
    if (sCom == "BUGBEAR_CHIEFTAIN_B")
        return APPEARANCE_TYPE_BUGBEAR_CHIEFTAIN_B;
    if (sCom == "BUGBEAR_SHAMAN_A")
        return APPEARANCE_TYPE_BUGBEAR_SHAMAN_A;
    if (sCom == "BUGBEAR_SHAMAN_B")
        return APPEARANCE_TYPE_BUGBEAR_SHAMAN_B;
    if (sCom == "CAT_CAT_DIRE")
        return APPEARANCE_TYPE_CAT_CAT_DIRE;
    if (sCom == "CAT_COUGAR")
        return APPEARANCE_TYPE_CAT_COUGAR;
    if (sCom == "CAT_CRAG_CAT")
        return APPEARANCE_TYPE_CAT_CRAG_CAT;
    if (sCom == "CAT_JAGUAR")
        return APPEARANCE_TYPE_CAT_JAGUAR;
    if (sCom == "CAT_KRENSHAR")
        return APPEARANCE_TYPE_CAT_KRENSHAR;
    if (sCom == "CAT_LEOPARD")
        return APPEARANCE_TYPE_CAT_LEOPARD;
    if (sCom == "CAT_LION")
        return APPEARANCE_TYPE_CAT_LION;
    if (sCom == "CAT_MPANTHER")
        return APPEARANCE_TYPE_CAT_MPANTHER;
    if (sCom == "CAT_PANTHER")
        return APPEARANCE_TYPE_CAT_PANTHER;
    if (sCom == "CHICKEN")
        return APPEARANCE_TYPE_CHICKEN;
    if (sCom == "COCKATRICE")
        return APPEARANCE_TYPE_COCKATRICE;
    if (sCom == "COMBAT_DUMMY")
        return APPEARANCE_TYPE_COMBAT_DUMMY;
    if (sCom == "CONVICT")
        return APPEARANCE_TYPE_CONVICT;
    if (sCom == "COW")
        return APPEARANCE_TYPE_COW;
    if (sCom == "CULT_MEMBER")
        return APPEARANCE_TYPE_CULT_MEMBER;
    if (sCom == "DEER")
        return APPEARANCE_TYPE_DEER;
    if (sCom == "DEER_STAG")
        return APPEARANCE_TYPE_DEER_STAG;
    if (sCom == "DEVIL")
        return APPEARANCE_TYPE_DEVIL;
    if (sCom == "DOG")
        return APPEARANCE_TYPE_DOG;
    if (sCom == "DOG_BLINKDOG")
        return APPEARANCE_TYPE_DOG_BLINKDOG;
    if (sCom == "DOG_DIRE_WOLF")
        return APPEARANCE_TYPE_DOG_DIRE_WOLF;
    if (sCom == "DOG_FENHOUND")
        return APPEARANCE_TYPE_DOG_FENHOUND;
    if (sCom == "DOG_HELL_HOUND")
        return APPEARANCE_TYPE_DOG_HELL_HOUND;
    if (sCom == "DOG_SHADOW_MASTIF")
        return APPEARANCE_TYPE_DOG_SHADOW_MASTIF;
    if (sCom == "DOG_WINTER_WOLF")
        return APPEARANCE_TYPE_DOG_WINTER_WOLF;
    if (sCom == "DOG_WORG")
        return APPEARANCE_TYPE_DOG_WORG;
    if (sCom == "DOG_WOLF")
        return APPEARANCE_TYPE_DOG_WOLF;
    if (sCom == "DOOM_KNIGHT")
        return APPEARANCE_TYPE_DOOM_KNIGHT;
    if (sCom == "DRAGON_BLACK")
        return APPEARANCE_TYPE_DRAGON_BLACK;
    if (sCom == "DRAGON_BLUE")
        return APPEARANCE_TYPE_DRAGON_BLUE;
    if (sCom == "DRAGON_BRASS")
        return APPEARANCE_TYPE_DRAGON_BRASS;
    if (sCom == "DRAGON_BRONZE")
        return APPEARANCE_TYPE_DRAGON_BRONZE;
    if (sCom == "DRAGON_COPPER")
        return APPEARANCE_TYPE_DRAGON_COPPER;
    if (sCom == "DRAGON_GOLD")
        return APPEARANCE_TYPE_DRAGON_GOLD;
    if (sCom == "DRAGON_GREEN")
        return APPEARANCE_TYPE_DRAGON_GREEN;
    if (sCom == "DRAGON_RED")
        return APPEARANCE_TYPE_DRAGON_RED;
    if (sCom == "DRAGON_SILVER")
        return APPEARANCE_TYPE_DRAGON_SILVER;
    if (sCom == "DRAGON_WHITE")
        return APPEARANCE_TYPE_DRAGON_WHITE;
    if (sCom == "DROW_CLERIC")
        return APPEARANCE_TYPE_DROW_CLERIC;
    if (sCom == "DROW_FIGHTER")
        return APPEARANCE_TYPE_DROW_FIGHTER;
    if (sCom == "DRUEGAR_CLERIC")
        return APPEARANCE_TYPE_DRUEGAR_CLERIC;
    if (sCom == "DRUEGAR_FIGHTER")
        return APPEARANCE_TYPE_DRUEGAR_FIGHTER;
    if (sCom == "DRYAD")
        return APPEARANCE_TYPE_DRYAD;
    if (sCom == "DWARF")
        return APPEARANCE_TYPE_DWARF;
    if (sCom == "DWARF_NPC_FEMALE")
        return APPEARANCE_TYPE_DWARF_NPC_FEMALE;
    if (sCom == "DWARF_NPC_MALE")
        return APPEARANCE_TYPE_DWARF_NPC_MALE;
    if (sCom == "ELEMENTAL_AIR")
        return APPEARANCE_TYPE_ELEMENTAL_AIR;
    if (sCom == "ELEMENTAL_AIR_ELDER")
        return APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER;
    if (sCom == "ELEMENTAL_EARTH")
        return APPEARANCE_TYPE_ELEMENTAL_EARTH;
    if (sCom == "ELEMENTAL_EARTH_ELDER")
        return APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER;
    if (sCom == "ELEMENTAL_FIRE")
        return APPEARANCE_TYPE_ELEMENTAL_FIRE;
    if (sCom == "ELEMENTAL_FIRE_ELDER")
        return APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER;
    if (sCom == "ELEMENTAL_WATER")
        return APPEARANCE_TYPE_ELEMENTAL_WATER;
    if (sCom == "ELEMENTAL_WATER_ELDER")
        return APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER;
    if (sCom == "ELF")
        return APPEARANCE_TYPE_ELF;
    if (sCom == "ELF_NPC_FEMALE")
        return APPEARANCE_TYPE_ELF_NPC_FEMALE;
    if (sCom == "ELF_NPC_MALE_01")
        return APPEARANCE_TYPE_ELF_NPC_MALE_01;
    if (sCom == "ELF_NPC_MALE_02")
        return APPEARANCE_TYPE_ELF_NPC_MALE_02;
    if (sCom == "ETTERCAP")
        return APPEARANCE_TYPE_ETTERCAP;
    if (sCom == "ETTIN")
        return APPEARANCE_TYPE_ETTIN;
    if (sCom == "FAERIE_DRAGON")
        return APPEARANCE_TYPE_FAERIE_DRAGON;
    if (sCom == "FAIRY")
        return APPEARANCE_TYPE_FAIRY;
    if (sCom == "FALCON")
        return APPEARANCE_TYPE_FALCON;
    if (sCom == "FEMALE_01")
        return APPEARANCE_TYPE_FEMALE_01;
    if (sCom == "FEMALE_02")
        return APPEARANCE_TYPE_FEMALE_02;
    if (sCom == "FEMALE_03")
        return APPEARANCE_TYPE_FEMALE_03;
    if (sCom == "FEMALE_04")
        return APPEARANCE_TYPE_FEMALE_04;
    if (sCom == "FORMIAN_MYRMARCH")
        return APPEARANCE_TYPE_FORMIAN_MYRMARCH;
    if (sCom == "FORMIAN_QUEEN")
        return APPEARANCE_TYPE_FORMIAN_QUEEN;
    if (sCom == "FORMIAN_WARRIOR")
        return APPEARANCE_TYPE_FORMIAN_WARRIOR;
    if (sCom == "FORMIAN_WORKER")
        return APPEARANCE_TYPE_FORMIAN_WORKER;
    if (sCom == "GARGOYLE")
        return APPEARANCE_TYPE_GARGOYLE;
    if (sCom == "GHAST")
        return APPEARANCE_TYPE_GHAST;
    if (sCom == "GHOUL")
        return APPEARANCE_TYPE_GHOUL;
    if (sCom == "GHOUL_LORD")
        return APPEARANCE_TYPE_GHOUL_LORD;
    if (sCom == "GIANT_FIRE")
        return APPEARANCE_TYPE_GIANT_FIRE;
    if (sCom == "GIANT_FIRE_FEMALE")
        return APPEARANCE_TYPE_GIANT_FIRE_FEMALE;
    if (sCom == "GIANT_FROST")
        return APPEARANCE_TYPE_GIANT_FROST;
    if (sCom == "GIANT_FROST_FEMALE")
        return APPEARANCE_TYPE_GIANT_FROST_FEMALE;
    if (sCom == "GIANT_HILL")
        return APPEARANCE_TYPE_GIANT_HILL;
    if (sCom == "GIANT_MOUNTAIN")
        return APPEARANCE_TYPE_GIANT_MOUNTAIN;
    if (sCom == "GNOLL_WARRIOR")
        return APPEARANCE_TYPE_GNOLL_WARRIOR;
    if (sCom == "GNOLL_WIZ")
        return APPEARANCE_TYPE_GNOLL_WIZ;
    if (sCom == "GNOME")
        return APPEARANCE_TYPE_GNOME;
    if (sCom == "GNOME_NPC_FEMALE")
        return APPEARANCE_TYPE_GNOME_NPC_FEMALE;
    if (sCom == "GNOME_NPC_MALE")
        return APPEARANCE_TYPE_GNOME_NPC_MALE;
    if (sCom == "GOBLIN_A")
        return APPEARANCE_TYPE_GOBLIN_A;
    if (sCom == "GOBLIN_B")
        return APPEARANCE_TYPE_GOBLIN_B;
    if (sCom == "GOBLIN_CHIEF_A")
        return APPEARANCE_TYPE_GOBLIN_CHIEF_A;
    if (sCom == "GOBLIN_CHIEF_B")
        return APPEARANCE_TYPE_GOBLIN_CHIEF_B;
    if (sCom == "GOBLIN_SHAMAN_A")
        return APPEARANCE_TYPE_GOBLIN_SHAMAN_A;
    if (sCom == "GOBLIN_SHAMAN_B")
        return APPEARANCE_TYPE_GOBLIN_SHAMAN_B;
    if (sCom == "GOLEM_BONE")
        return APPEARANCE_TYPE_GOLEM_BONE;
    if (sCom == "GOLEM_CLAY")
        return APPEARANCE_TYPE_GOLEM_CLAY;
    if (sCom == "GOLEM_FLESH")
        return APPEARANCE_TYPE_GOLEM_FLESH;
    if (sCom == "GOLEM_IRON")
        return APPEARANCE_TYPE_GOLEM_IRON;
    if (sCom == "GOLEM_STONE")
        return APPEARANCE_TYPE_GOLEM_STONE;
    if (sCom == "GORGON")
        return APPEARANCE_TYPE_GORGON;
    if (sCom == "GREY_RENDER")
        return APPEARANCE_TYPE_GREY_RENDER;
    if (sCom == "GYNOSPHINX")
        return APPEARANCE_TYPE_GYNOSPHINX;
    if (sCom == "HALF_ELF")
        return APPEARANCE_TYPE_HALF_ELF;
    if (sCom == "HALF_ORC")
        return APPEARANCE_TYPE_HALF_ORC;
    if (sCom == "HALF_ORC_NPC_FEMALE")
        return APPEARANCE_TYPE_HALF_ORC_NPC_FEMALE;
    if (sCom == "HALF_ORC_NPC_MALE_01")
        return APPEARANCE_TYPE_HALF_ORC_NPC_MALE_01;
    if (sCom == "HALF_ORC_NPC_MALE_02")
        return APPEARANCE_TYPE_HALF_ORC_NPC_MALE_02;
    if (sCom == "HALFLING")
        return APPEARANCE_TYPE_HALFLING;
    if (sCom == "HALFLING_NPC_FEMALE")
        return APPEARANCE_TYPE_HALFLING_NPC_FEMALE;
    if (sCom == "HALFLING_NPC_MALE")
        return APPEARANCE_TYPE_HALFLING_NPC_MALE;
    if (sCom == "HELMED_HORROR")
        return APPEARANCE_TYPE_HELMED_HORROR;
    if (sCom == "HEURODIS_LICH")
        return APPEARANCE_TYPE_HEURODIS_LICH;
    if (sCom == "HOBGOBLIN_WARRIOR")
        return APPEARANCE_TYPE_HOBGOBLIN_WARRIOR;
    if (sCom == "HOOK_HORROR")
        return APPEARANCE_TYPE_HOOK_HORROR;
    if (sCom == "HOBGOBLIN_WIZARD")
        return APPEARANCE_TYPE_HOBGOBLIN_WIZARD;
    if (sCom == "HOUSE_GUARD")
        return APPEARANCE_TYPE_HOUSE_GUARD;
    if (sCom == "HUMAN")
        return APPEARANCE_TYPE_HUMAN;
    if (sCom == "HUMAN_NPC_FEMALE_01")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_01;
    if (sCom == "HUMAN_NPC_FEMALE_02")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_02;
    if (sCom == "HUMAN_NPC_FEMALE_03")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_03;
    if (sCom == "HUMAN_NPC_FEMALE_04")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_04;
    if (sCom == "HUMAN_NPC_FEMALE_05")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_05;
    if (sCom == "HUMAN_NPC_FEMALE_06")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_06;
    if (sCom == "HUMAN_NPC_FEMALE_07")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_07;
    if (sCom == "HUMAN_NPC_FEMALE_08")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_08;
    if (sCom == "HUMAN_NPC_FEMALE_09")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_09;
    if (sCom == "HUMAN_NPC_FEMALE_10")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_10;
    if (sCom == "HUMAN_NPC_FEMALE_11")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_11;
    if (sCom == "HUMAN_NPC_FEMALE_12")
        return APPEARANCE_TYPE_HUMAN_NPC_FEMALE_12;
    if (sCom == "HUMAN_NPC_MALE_01")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_01;
    if (sCom == "HUMAN_NPC_MALE_02")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_02;
    if (sCom == "HUMAN_NPC_MALE_03")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_03;
    if (sCom == "HUMAN_NPC_MALE_04")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_04;
    if (sCom == "HUMAN_NPC_MALE_05")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_05;
    if (sCom == "HUMAN_NPC_MALE_06")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_06;
    if (sCom == "HUMAN_NPC_MALE_07")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_07;
    if (sCom == "HUMAN_NPC_MALE_08")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_08;
    if (sCom == "HUMAN_NPC_MALE_09")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_09;
    if (sCom == "HUMAN_NPC_MALE_10")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_10;
    if (sCom == "HUMAN_NPC_MALE_11")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_11;
    if (sCom == "HUMAN_NPC_MALE_12")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_12;
    if (sCom == "HUMAN_NPC_MALE_13")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_13;
    if (sCom == "HUMAN_NPC_MALE_14")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_14;
    if (sCom == "HUMAN_NPC_MALE_15")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_15;
    if (sCom == "HUMAN_NPC_MALE_16")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_16;
    if (sCom == "HUMAN_NPC_MALE_17")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_17;
    if (sCom == "HUMAN_NPC_MALE_18")
        return APPEARANCE_TYPE_HUMAN_NPC_MALE_18;
    if (sCom == "IMP")
        return APPEARANCE_TYPE_IMP;
    if (sCom == "INN_KEEPER")
        return APPEARANCE_TYPE_INN_KEEPER;
    if (sCom == "INTELLECT_DEVOURER")
        return APPEARANCE_TYPE_INTELLECT_DEVOURER;
    if (sCom == "INVISIBLE_HUMAN_MALE")
        return APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE;
    if (sCom == "INVISIBLE_STALKER")
        return APPEARANCE_TYPE_INVISIBLE_STALKER;
    if (sCom == "KID_FEMALE")
        return APPEARANCE_TYPE_KID_FEMALE;
    if (sCom == "KID_MALE")
        return APPEARANCE_TYPE_KID_MALE;
    if (sCom == "KOBOLD_A")
        return APPEARANCE_TYPE_KOBOLD_A;
    if (sCom == "KOBOLD_B")
        return APPEARANCE_TYPE_KOBOLD_B;
    if (sCom == "KOBOLD_CHIEF_A")
        return APPEARANCE_TYPE_KOBOLD_CHIEF_A;
    if (sCom == "KOBOLD_CHIEF_B")
        return APPEARANCE_TYPE_KOBOLD_CHIEF_B;
    if (sCom == "KOBOLD_SHAMAN_A")
        return APPEARANCE_TYPE_KOBOLD_SHAMAN_A;
    if (sCom == "KOBOLD_SHAMAN_B")
        return APPEARANCE_TYPE_KOBOLD_SHAMAN_B;
    if (sCom == "LANTERN_ARCHON")
        return APPEARANCE_TYPE_LANTERN_ARCHON;
    if (sCom == "LICH")
        return APPEARANCE_TYPE_LICH;
    if (sCom == "LIZARDFOLK_A")
        return APPEARANCE_TYPE_LIZARDFOLK_A;
    if (sCom == "LIZARDFOLK_B")
        return APPEARANCE_TYPE_LIZARDFOLK_B;
    if (sCom == "LIZARDFOLK_SHAMAN_A")
        return APPEARANCE_TYPE_LIZARDFOLK_SHAMAN_A;
    if (sCom == "LIZARDFOLK_SHAMAN_B")
        return APPEARANCE_TYPE_LIZARDFOLK_SHAMAN_B;
    if (sCom == "LIZARDFOLK_WARRIOR_A")
        return APPEARANCE_TYPE_LIZARDFOLK_WARRIOR_A;
    if (sCom == "LIZARDFOLK_WARRIOR_B")
        return APPEARANCE_TYPE_LIZARDFOLK_WARRIOR_B;
    if (sCom == "LUSKAN_GUARD")
        return APPEARANCE_TYPE_LUSKAN_GUARD;
    if (sCom == "MALE_01")
        return APPEARANCE_TYPE_MALE_01;
    if (sCom == "MALE_02")
        return APPEARANCE_TYPE_MALE_02;
    if (sCom == "MALE_03")
        return APPEARANCE_TYPE_MALE_03;
    if (sCom == "MALE_04")
        return APPEARANCE_TYPE_MALE_04;
    if (sCom == "MALE_05")
        return APPEARANCE_TYPE_MALE_05;
    if (sCom == "MANTICORE")
        return APPEARANCE_TYPE_MANTICORE;
    if (sCom == "MEDUSA")
        return APPEARANCE_TYPE_MEDUSA;
    if (sCom == "MEPHIT_AIR")
        return APPEARANCE_TYPE_MEPHIT_AIR;
    if (sCom == "MEPHIT_DUST")
        return APPEARANCE_TYPE_MEPHIT_DUST;
    if (sCom == "MEPHIT_EARTH")
        return APPEARANCE_TYPE_MEPHIT_EARTH;
    if (sCom == "MEPHIT_FIRE")
        return APPEARANCE_TYPE_MEPHIT_FIRE;
    if (sCom == "MEPHIT_ICE")
        return APPEARANCE_TYPE_MEPHIT_ICE;
    if (sCom == "MEPHIT_MAGMA")
        return APPEARANCE_TYPE_MEPHIT_MAGMA;
    if (sCom == "MEPHIT_OOZE")
        return APPEARANCE_TYPE_MEPHIT_OOZE;
    if (sCom == "MEPHIT_SALT")
        return APPEARANCE_TYPE_MEPHIT_SALT;
    if (sCom == "MEPHIT_STEAM")
        return APPEARANCE_TYPE_MEPHIT_STEAM;
    if (sCom == "MEPHIT_WATER")
        return APPEARANCE_TYPE_MEPHIT_WATER;
    if (sCom == "MINOGON")
        return APPEARANCE_TYPE_MINOGON;
    if (sCom == "MINOTAUR")
        return APPEARANCE_TYPE_MINOTAUR;
    if (sCom == "MINOTAUR_CHIEFTAIN")
        return APPEARANCE_TYPE_MINOTAUR_CHIEFTAIN;
    if (sCom == "MINOTAUR_SHAMAN")
        return APPEARANCE_TYPE_MINOTAUR_SHAMAN;
    if (sCom == "MOHRG")
        return APPEARANCE_TYPE_MOHRG;
    if (sCom == "MUMMY_COMMON")
        return APPEARANCE_TYPE_MUMMY_COMMON;
    if (sCom == "MUMMY_FIGHTER_2")
        return APPEARANCE_TYPE_MUMMY_FIGHTER_2;
    if (sCom == "MUMMY_GREATER")
        return APPEARANCE_TYPE_MUMMY_GREATER;
    if (sCom == "MUMMY_WARRIOR")
        return APPEARANCE_TYPE_MUMMY_WARRIOR;
    if (sCom == "NW_MILITIA_MEMBER")
        return APPEARANCE_TYPE_NW_MILITIA_MEMBER;
    if (sCom == "NWN_AARIN")
        return APPEARANCE_TYPE_NWN_AARIN;
    if (sCom == "NWN_ARIBETH_EVIL")
        return APPEARANCE_TYPE_NWN_ARIBETH_EVIL;
    if (sCom == "NWN_HAEDRALINE")
        return APPEARANCE_TYPE_NWN_HAEDRALINE;
    if (sCom == "NWN_MAUGRIM")
        return APPEARANCE_TYPE_NWN_MAUGRIM;
    if (sCom == "NWN_MORAG")
        return APPEARANCE_TYPE_NWN_MORAG;
    if (sCom == "NWN_NASHER")
        return APPEARANCE_TYPE_NWN_NASHER;
    if (sCom == "NWN_SEDOS")
        return APPEARANCE_TYPE_NWN_SEDOS;
    if (sCom == "NYMPH")
        return APPEARANCE_TYPE_NYMPH;
    if (sCom == "OGRE")
        return APPEARANCE_TYPE_OGRE;
    if (sCom == "OGRE_CHIEFTAIN")
        return APPEARANCE_TYPE_OGRE_CHIEFTAIN;
    if (sCom == "OGRE_CHIEFTAINB")
        return APPEARANCE_TYPE_OGRE_CHIEFTAINB;
    if (sCom == "OGRE_MAGE")
        return APPEARANCE_TYPE_OGRE_MAGE;
    if (sCom == "OGRE_MAGEB")
        return APPEARANCE_TYPE_OGRE_MAGEB;
    if (sCom == "OGREB")
        return APPEARANCE_TYPE_OGREB;
    if (sCom == "OLD_MAN")
        return APPEARANCE_TYPE_OLD_MAN;
    if (sCom == "OLD_WOMAN")
        return APPEARANCE_TYPE_OLD_WOMAN;
    if (sCom == "ORC_A")
        return APPEARANCE_TYPE_ORC_A;
    if (sCom == "ORC_B")
        return APPEARANCE_TYPE_ORC_B;
    if (sCom == "ORC_CHIEFTAIN_A")
        return APPEARANCE_TYPE_ORC_CHIEFTAIN_A;
    if (sCom == "ORC_CHIEFTAIN_B")
        return APPEARANCE_TYPE_ORC_CHIEFTAIN_B;
    if (sCom == "ORC_SHAMAN_A")
        return APPEARANCE_TYPE_ORC_SHAMAN_A;
    if (sCom == "ORC_SHAMAN_B")
        return APPEARANCE_TYPE_ORC_SHAMAN_B;
    if (sCom == "OX")
        return APPEARANCE_TYPE_OX;
    if (sCom == "PENGUIN")
        return APPEARANCE_TYPE_PENGUIN;
    if (sCom == "PLAGUE_VICTIM")
        return APPEARANCE_TYPE_PLAGUE_VICTIM;
    if (sCom == "PROSTITUTE_01")
        return APPEARANCE_TYPE_PROSTITUTE_01;
    if (sCom == "PROSTITUTE_02")
        return APPEARANCE_TYPE_PROSTITUTE_02;
    if (sCom == "PSEUDODRAGON")
        return APPEARANCE_TYPE_PSEUDODRAGON;
    if (sCom == "QUASIT")
        return APPEARANCE_TYPE_QUASIT;
    if (sCom == "RAKSHASA_BEAR_MALE")
        return APPEARANCE_TYPE_RAKSHASA_BEAR_MALE;
    if (sCom == "RAKSHASA_TIGER_FEMALE")
        return APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE;
    if (sCom == "RAKSHASA_TIGER_MALE")
        return APPEARANCE_TYPE_RAKSHASA_TIGER_MALE;
    if (sCom == "RAKSHASA_WOLF_MALE")
        return APPEARANCE_TYPE_RAKSHASA_WOLF_MALE;
    if (sCom == "RAT")
        return APPEARANCE_TYPE_RAT;
    if (sCom == "RAT_DIRE")
        return APPEARANCE_TYPE_RAT_DIRE;
    if (sCom == "RAVEN")
        return APPEARANCE_TYPE_RAVEN;
    if (sCom == "SHADOW")
        return APPEARANCE_TYPE_SHADOW;
    if (sCom == "SHADOW_FIEND")
        return APPEARANCE_TYPE_SHADOW_FIEND;
    if (sCom == "SHIELD_GUARDIAN")
        return APPEARANCE_TYPE_SHIELD_GUARDIAN;
    if (sCom == "SHOP_KEEPER")
        return APPEARANCE_TYPE_SHOP_KEEPER;
    if (sCom == "SKELETAL_DEVOURER")
        return APPEARANCE_TYPE_SKELETAL_DEVOURER;
    if (sCom == "SKELETON_CHIEFTAIN")
        return APPEARANCE_TYPE_SKELETON_CHIEFTAIN;
    if (sCom == "SKELETON_COMMON")
        return APPEARANCE_TYPE_SKELETON_COMMON;
    if (sCom == "SKELETON_MAGE")
        return APPEARANCE_TYPE_SKELETON_MAGE;
    if (sCom == "SKELETON_WARRIOR")
        return APPEARANCE_TYPE_SKELETON_WARRIOR;
    if (sCom == "SKELETON_PRIEST")
        return APPEARANCE_TYPE_SKELETON_PRIEST;
    if (sCom == "SKELETON_WARRIOR_1")
        return APPEARANCE_TYPE_SKELETON_WARRIOR_1;
    if (sCom == "SKELETON_WARRIOR_2")
        return APPEARANCE_TYPE_SKELETON_WARRIOR_2;
    if (sCom == "SPHINX")
        return APPEARANCE_TYPE_SPHINX;
    if (sCom == "SPIDER_WRAITH")
        return APPEARANCE_TYPE_SPIDER_WRAITH;
    if (sCom == "STINGER")
        return APPEARANCE_TYPE_STINGER;
    if (sCom == "STINGER_CHIEFTAIN")
        return APPEARANCE_TYPE_STINGER_CHIEFTAIN;
    if (sCom == "STINGER_MAGE")
        return APPEARANCE_TYPE_STINGER_MAGE;
    if (sCom == "STINGER_WARRIOR")
        return APPEARANCE_TYPE_STINGER_WARRIOR;
    if (sCom == "SUCCUBUS")
        return APPEARANCE_TYPE_SUCCUBUS;
    if (sCom == "TROLL")
        return APPEARANCE_TYPE_TROLL;
    if (sCom == "TROLL_CHIEFTAIN")
        return APPEARANCE_TYPE_TROLL_CHIEFTAIN;
    if (sCom == "TROLL_SHAMAN")
        return APPEARANCE_TYPE_TROLL_SHAMAN;
    if (sCom == "UMBERHULK")
        return APPEARANCE_TYPE_UMBERHULK;
    if (sCom == "UTHGARD_ELK_TRIBE")
        return APPEARANCE_TYPE_UTHGARD_ELK_TRIBE;
    if (sCom == "UTHGARD_TIGER_TRIBE")
        return APPEARANCE_TYPE_UTHGARD_TIGER_TRIBE;
    if (sCom == "VAMPIRE_FEMALE")
        return APPEARANCE_TYPE_VAMPIRE_FEMALE;
    if (sCom == "VAMPIRE_MALE")
        return APPEARANCE_TYPE_VAMPIRE_MALE;
    if (sCom == "VROCK")
        return APPEARANCE_TYPE_VROCK;
    if (sCom == "WAITRESS")
        return APPEARANCE_TYPE_WAITRESS;
    if (sCom == "WAR_DEVOURER")
        return APPEARANCE_TYPE_WAR_DEVOURER;
    if (sCom == "WERECAT")
        return APPEARANCE_TYPE_WERECAT;
    if (sCom == "WERERAT")
        return APPEARANCE_TYPE_WERERAT;
    if (sCom == "WEREWOLF")
        return APPEARANCE_TYPE_WEREWOLF;
    if (sCom == "WIGHT")
        return APPEARANCE_TYPE_WIGHT;
    if (sCom == "WILL_O_WISP")
        return APPEARANCE_TYPE_WILL_O_WISP;
    if (sCom == "WRAITH")
        return APPEARANCE_TYPE_WRAITH;
    if (sCom == "WYRMLING_BLACK")
        return APPEARANCE_TYPE_WYRMLING_BLACK;
    if (sCom == "WYRMLING_BLUE")
        return APPEARANCE_TYPE_WYRMLING_BLUE;
    if (sCom == "WYRMLING_BRASS")
        return APPEARANCE_TYPE_WYRMLING_BRASS;
    if (sCom == "WYRMLING_BRONZE")
        return APPEARANCE_TYPE_WYRMLING_BRONZE;
    if (sCom == "WYRMLING_COPPER")
        return APPEARANCE_TYPE_WYRMLING_COPPER;
    if (sCom == "WYRMLING_GOLD")
        return APPEARANCE_TYPE_WYRMLING_GOLD;
    if (sCom == "WYRMLING_GREEN")
        return APPEARANCE_TYPE_WYRMLING_GREEN;
    if (sCom == "WYRMLING_RED")
        return APPEARANCE_TYPE_WYRMLING_RED;
    if (sCom == "WYRMLING_SILVER")
        return APPEARANCE_TYPE_WYRMLING_SILVER;
    if (sCom == "WYRMLING_WHITE")
        return APPEARANCE_TYPE_WYRMLING_WHITE;
    if (sCom == "YUAN_TI")
        return APPEARANCE_TYPE_YUAN_TI;
    if (sCom == "YUAN_TI_CHIEFTEN")
        return APPEARANCE_TYPE_YUAN_TI_CHIEFTEN;
    if (sCom == "YUAN_TI_WIZARD")
        return APPEARANCE_TYPE_YUAN_TI_WIZARD;
    if (sCom == "ZOMBIE")
        return APPEARANCE_TYPE_ZOMBIE;
    if (sCom == "ZOMBIE_ROTTING")
        return APPEARANCE_TYPE_ZOMBIE_ROTTING;
    if (sCom == "ZOMBIE_TYRANT_FOG")
        return APPEARANCE_TYPE_ZOMBIE_TYRANT_FOG;
    if (sCom == "ZOMBIE_WARRIOR_1")
        return APPEARANCE_TYPE_ZOMBIE_WARRIOR_1;
    if (sCom == "ZOMBIE_WARRIOR_2")
        return APPEARANCE_TYPE_ZOMBIE_WARRIOR_2;

    // new 1.09 behavior - also check against the 2da
    string s2daval;
    int i = 0;
    while (1)
    {
        s2daval = Get2DAString("appearance", "NAME", i);
        if (s2daval == "") break; // end of file
        s2daval = Get2DAString("appearance", "LABEL", i);
        if (s2daval != "")
        {
            if (GetStringUpperCase(sCom) == GetStringUpperCase(s2daval)) return i;
        }
        i++;
    }
    return -1;
}

////////////////////////////////////////////////////////////////////////
void dmw_CleanUp(object oMySpeaker)
{
    int nCount;
    int nCache;
    //DeleteLocalObject(oMySpeaker, "dmfi_univ_target");
    DeleteLocalLocation(oMySpeaker, "dmfi_univ_location");
    DeleteLocalObject(oMySpeaker, "dmw_item");
    DeleteLocalString(oMySpeaker, "dmw_repamt");
    DeleteLocalString(oMySpeaker, "dmw_repargs");
    nCache = GetLocalInt(oMySpeaker, "dmw_playercache");
    for (nCount = 1; nCount <= nCache; nCount++)
    {
        DeleteLocalObject(oMySpeaker, "dmw_playercache" + IntToString(nCount));
    }
    DeleteLocalInt(oMySpeaker, "dmw_playercache");
    nCache = GetLocalInt(oMySpeaker, "dmw_itemcache");
    for (nCount = 1; nCount <= nCache; nCount++)
    {
        DeleteLocalObject(oMySpeaker, "dmw_itemcache" + IntToString(nCount));
    }
    DeleteLocalInt(oMySpeaker, "dmw_itemcache");
    for (nCount = 1; nCount <= 10; nCount++)
    {
        DeleteLocalString(oMySpeaker, "dmw_dialog" + IntToString(nCount));
        DeleteLocalString(oMySpeaker, "dmw_function" + IntToString(nCount));
        DeleteLocalString(oMySpeaker, "dmw_params" + IntToString(nCount));
    }
    DeleteLocalString(oMySpeaker, "dmw_playerfunc");
    DeleteLocalInt(oMySpeaker, "dmw_started");
}

////////////////////////////////////////////////////////////////////////
location GetLocationAboveAndInFrontOf(object oPC, float fDist, float fHeight)
{
    float fDistance = -fDist;
    object oTarget = (oPC);
    object oArea = GetArea(oTarget);
    vector vPosition = GetPosition(oTarget);
    vPosition.z += fHeight;
    float fOrientation = GetFacing(oTarget);
    vector vNewPos = AngleToVector(fOrientation);
    float vZ = vPosition.z;
    float vX = vPosition.x - fDistance * vNewPos.x;
    float vY = vPosition.y - fDistance * vNewPos.y;
    fOrientation = GetFacing(oTarget);
    vX = vPosition.x - fDistance * vNewPos.x;
    vY = vPosition.y - fDistance * vNewPos.y;
    vNewPos = AngleToVector(fOrientation);
    vZ = vPosition.z;
    vNewPos = Vector(vX, vY, vZ);
    return Location(oArea, vNewPos, fOrientation);
}

////////////////////////////////////////////////////////////////////////
//Smoking Function by Jason Robinson
void SmokePipe(object oActivator)
{
    string sEmote1 = "*puffs on a pipe*";
    string sEmote2 = "*inhales from a pipe*";
    string sEmote3 = "*pulls a mouthful of smoke from a pipe*";
    float fHeight = 1.7;
    float fDistance = 0.1;
    // Set height based on race and gender
    if (GetGender(oActivator) == GENDER_MALE)
    {
        switch (GetRacialType(oActivator))
        {
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF: fHeight = 1.7; fDistance = 0.12; break;
        case RACIAL_TYPE_ELF: fHeight = 1.55; fDistance = 0.08; break;
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING: fHeight = 1.15; fDistance = 0.12; break;
        case RACIAL_TYPE_DWARF: fHeight = 1.2; fDistance = 0.12; break;
        case RACIAL_TYPE_HALFORC: fHeight = 1.9; fDistance = 0.2; break;
        }
    }
    else
    {
        // FEMALES
        switch (GetRacialType(oActivator))
        {
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF: fHeight = 1.6; fDistance = 0.12; break;
        case RACIAL_TYPE_ELF: fHeight = 1.45; fDistance = 0.12; break;
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING: fHeight = 1.1; fDistance = 0.075; break;
        case RACIAL_TYPE_DWARF: fHeight = 1.2; fDistance = 0.1; break;
        case RACIAL_TYPE_HALFORC: fHeight = 1.8; fDistance = 0.13; break;
        }
    }
    location lAboveHead = GetLocationAboveAndInFrontOf(oActivator, fDistance, fHeight);
    // emotes
    switch (d3())
    {
    case 1: AssignCommand(oActivator, ActionSpeakString(sEmote1)); break;
    case 2: AssignCommand(oActivator, ActionSpeakString(sEmote2)); break;
    case 3: AssignCommand(oActivator, ActionSpeakString(sEmote3));break;
    }
    // glow red
    AssignCommand(oActivator, ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_LIGHT_RED_5), oActivator, 0.15)));
    // wait a moment
    AssignCommand(oActivator, ActionWait(3.0));
    // puff of smoke above and in front of head
    AssignCommand(oActivator, ActionDoCommand(ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), lAboveHead)));
    // if female, turn head to left
    if ((GetGender(oActivator) == GENDER_FEMALE) && (GetRacialType(oActivator) != RACIAL_TYPE_DWARF))
        AssignCommand(oActivator, ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 1.0, 5.0));
}

////////////////////////////////////////////////////////////////////////
void ParseEmote(string sEmote, object oPC)
{
    // allow builder to suppress
    if (GetLocalInt(GetModule(), "DMFI_SUPPRESS_EMOTES")) return;

    // initialize
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
    object oLeftHand =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);

    //isolate emote text from chat message
    int nLength = GetStringLength(sEmote);
    int nPos1, nPos2;
    string sTemp;
    nPos1   = FindSubString(sEmote,"*");
    while(nPos1!=-1 && nPos2!=-1)
    {
        nPos2   = FindSubString(sEmote,"*",(nPos1+1));
        if(nPos2==-1)
        {
            sTemp   += "*"+" "+GetStringRight(sEmote,nLength-(nPos1+1))+" ";
            break;
        }
        else if(nPos2>(nPos1+1))
        {
            sTemp   += "*"+" "+GetSubString(sEmote,(nPos1+1),((nPos2)-(nPos1+1)))+" ";
            nPos1   = FindSubString(sEmote,"*",(nPos2+1));
        }
        else
            nPos1   = nPos2;
    }
    sEmote = sTemp;

    int iSit;
    object oArea;
    object oChair;
    // morderon - rewrote from here to end for better text case handling
    string sLCEmote = GetStringLowerCase(sEmote);

    //_AID_ -------- MAGUS -----------------------------------------------------
    if(AIDParseEmote(oPC, sLCEmote)){return;}

    // has PC muted their own emotes? If TRUE, exit
    if (GetLocalInt(oPC, "hls_emotemute")){return;}

    //*emote* rolls
  if(DMFI_EMOTE_SAVES)
  {
    DeleteLocalInt(oPC, "dmfi_univ_int");
    if ((FindSubString(sLCEmote, " strength ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 61);
    else if ((FindSubString(sLCEmote, " dexterity ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 62);
    else if ((FindSubString(sLCEmote, " constitution ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 63);
    else if ((FindSubString(sLCEmote, " intelligence ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 64);
    else if ((FindSubString(sLCEmote, " wisdom ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 65);
    else if ((FindSubString(sLCEmote, " charisma ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 66);
    else if ((FindSubString(sLCEmote, " fortitude ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 67);
    else if ((FindSubString(sLCEmote, " reflex ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 68);
    else if ((FindSubString(sLCEmote, " will ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 69);

    else if ((FindSubString(sLCEmote, " animal empathy ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 70);
    else if ((FindSubString(sLCEmote, " bargain") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 71);
    else if ((FindSubString(sLCEmote, " bluff") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 72);
    else if ((FindSubString(sLCEmote, " climb") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 73);
    else if ((FindSubString(sLCEmote, " concentration ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 74);
    else if ((FindSubString(sLCEmote, " crafting ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 75);
    else if ((FindSubString(sLCEmote, " decipher") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 76);
    else if ((FindSubString(sLCEmote, " disable trap") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 77);
    else if ((FindSubString(sLCEmote, " discipline ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 78);
    else if ((FindSubString(sLCEmote, " escape artist ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 79);
    else if ((FindSubString(sLCEmote, " forgery ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 80);




    else if ((FindSubString(sLCEmote, " heal") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 81);
    else if((FindSubString(sLCEmote, " hide check ")!=-1)||(FindSubString(sLCEmote, " hides ")!=-1&&FindSubString(sLCEmote, "some hides ")==-1&&FindSubString(sLCEmote, " hides the ")==-1&&FindSubString(sLCEmote, " hides some")==-1&&FindSubString(sLCEmote, " hides a ")==-1))
        SetLocalInt(oPC, "dmfi_univ_int", 82);
    else if ((FindSubString(sLCEmote, "intimidate") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 83);
    else if ((FindSubString(sLCEmote, " jump") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 84);
    else if ((FindSubString(sLCEmote, " listen") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 85);
    else if ((FindSubString(sLCEmote, " lore ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 86);
    else if ((FindSubString(sLCEmote, " move silently ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 87);
    else if ((FindSubString(sLCEmote, " open lock ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 88);
    else if ((FindSubString(sLCEmote, " perform") != -1))
    {
        SetLocalInt(oPC, "dmfi_univ_int", 89);
        if(FindSubString(GetTag(oLeftHand),"instrument")!=-1)
        {
            SetLocalObject(oPC, "DMFI_USE_INSTRUMENT", oLeftHand);
            ExecuteScript("do_instrument", oPC);
        }
    }
    else if ((FindSubString(sLCEmote, " persuade") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 90);

    else if ((FindSubString(sLCEmote, " pick pocket ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 91);
    else if ((FindSubString(sLCEmote, " search check ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 92);
    else if ((FindSubString(sLCEmote, " set trap ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 93);
    else if ((FindSubString(sLCEmote, " sense motive ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 94);
    else if ((FindSubString(sLCEmote, " spellcraft ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 95);
    else if ((FindSubString(sLCEmote, " spot check ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 96);
    else if ((FindSubString(sLCEmote, " swim ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 97);
    else if ((FindSubString(sLCEmote, " taunt") != -1))
    {
        SetLocalInt(oPC, "dmfi_univ_int", 98);

        PlayVoiceChat(VOICE_CHAT_TAUNT, oPC);
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_TAUNT, 1.0));
    }
    else if ((FindSubString(sLCEmote, " tumble") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 99);
    else if ((FindSubString(sLCEmote, " use magic device ") != -1))
        SetLocalInt(oPC, "dmfi_univ_int", 100);

    if (GetLocalInt(oPC, "dmfi_univ_int"))
    {
        SetLocalString(oPC, "dmfi_univ_conv", "pc_dicebag");
        ExecuteScript("dmfi_execute", oPC);
        return;
    }
  }

    //*emote*
    if (FindSubString(sLCEmote, " bow") != -1 ||
        FindSubString(sLCEmote, " curtsey") != -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_BOW, 1.0));
    else if( FindSubString(sLCEmote, " drink")!=-1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_DRINK, 1.0));
    else if(    FindSubString(sLCEmote, " sits ")!= -1
            ||  FindSubString(sLCEmote, " sit ")!= -1
           )
    {
        if( FindSubString(sLCEmote, " drink")!=-1)
        {
            AssignCommand(oPC, ActionPlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0f));
            DelayCommand(1.0f, AssignCommand(oPC, PlayAnimation( ANIMATION_FIREFORGET_DRINK, 1.0)));
            DelayCommand(3.0f, AssignCommand(oPC, PlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0)));
        }
        else if( FindSubString(sLCEmote, " reads ") != -1)
        {
            AssignCommand(oPC, ActionPlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0f));
            DelayCommand(1.0f, AssignCommand(oPC, PlayAnimation( ANIMATION_FIREFORGET_READ, 1.0)));
            DelayCommand(3.0f, AssignCommand(oPC, PlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0)));
        }
        else
            AssignCommand(oPC, ActionPlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0f));
    }
    else if (FindSubString(sLCEmote, " greet")!= -1 ||
             FindSubString(sLCEmote, " wave") != -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_GREETING, 1.0));
    else if (FindSubString(sLCEmote, " nod")!= -1 )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_LISTEN, 1.0, 4.0));
    else if (FindSubString(sLCEmote, " yawn")!= -1 ||
             FindSubString(sLCEmote, " stretch") != -1 ||
             FindSubString(sLCEmote, " bored") != -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_BORED, 1.0));
    else if (FindSubString(sLCEmote, " scratch")!= -1)
    {
        AssignCommand(oPC,ActionUnequipItem(oRightHand));
        AssignCommand(oPC,ActionUnequipItem(oLeftHand));
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD, 1.0));
    }
    else if (FindSubString(sLCEmote, " reads ")!= -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_READ, 1.0));
    else if (FindSubString(sLCEmote, " salute")!= -1)
    {
        AssignCommand(oPC,ActionUnequipItem(oRightHand));
        AssignCommand(oPC,ActionUnequipItem(oLeftHand));
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_SALUTE, 1.0));
    }
    else if (FindSubString(sLCEmote, " steal")!= -1 ||
             FindSubString(sLCEmote, " swipes ") != -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_STEAL, 1.0));
    else if (FindSubString(sLCEmote, " ridicules ")!= -1 ||
             FindSubString(sLCEmote, " mocks ") != -1
            )
    {
        PlayVoiceChat(VOICE_CHAT_TAUNT, oPC);
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_TAUNT, 1.0));
    }
    else if (FindSubString(sLCEmote, " smokes") != -1)
        SmokePipe(oPC);
    else if (FindSubString(sLCEmote, " cheer")!= -1)
    {
        PlayVoiceChat(VOICE_CHAT_CHEER, oPC);
        int roll    = d3();
        if(roll==1)
            AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_VICTORY1, 1.0));
        else if(roll==2)
            AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_VICTORY2, 1.0));
        else
            AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_VICTORY3, 1.0));
    }
    else if(FindSubString(sLCEmote, " giggl")!= -1)
    {
        if(GetGender(oPC) == GENDER_FEMALE)
            AssignCommand(oPC, PlaySound("vs_fshaldrf_haha"));
        else
        {
            PlayVoiceChat(VOICE_CHAT_LAUGH, oPC);
            AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING, 1.0, 2.0));
        }
    }
    else if(    FindSubString(sLCEmote, " lies down")!= -1 )
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM18, 1.0, 10000.0));
        if(FindSubString(sLCEmote, "sleep")!= -1 || FindSubString(sLCEmote, " snor")!= -1)
            DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oPC));
    }
    else if(    FindSubString(sLCEmote, " flops")!= -1
            ||  FindSubString(sLCEmote, " falls")!= -1
            )
    {
        if( FindSubString(sLCEmote, "sleep")!=-1)
            AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM18, 1.0, 10000.0));
        else if( FindSubString(sLCEmote, " back")!=-1)
            AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 99999.0));
        else
            AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 99999.0));

        if( FindSubString(sLCEmote, "sleep")!=-1)
            DelayCommand(4.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oPC));

    }
    else if(    FindSubString(sLCEmote, " crouches")!= -1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM10, 1.0, 30.0));

    else if(    FindSubString(sLCEmote, " lay drunk")!= -1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM12, 1.0, 10000.0));

    else if(    FindSubString(sLCEmote, " lay bottle")!= -1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM13, 1.0, 10000.0));


    else if(    FindSubString(sLCEmote, " bends")!= -1
             || FindSubString(sLCEmote, " stoop")!= -1
           )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " fiddles ")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 5.0));
    else if (FindSubString(sLCEmote, " peers ")!= -1 ||
             FindSubString(sLCEmote, " scans ")!= -1
            )
        AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_LOOK_FAR, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " pray")!= -1 ||
             FindSubString(sLCEmote, " meditate")!= -1)
    {
        AssignCommand(oPC,ActionUnequipItem(oRightHand));
        AssignCommand(oPC,ActionUnequipItem(oLeftHand));
        AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, 99999.0));
    }
    else if (FindSubString(sLCEmote, " drunk")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " tired ")!= -1 ||
             FindSubString(sLCEmote, " fatigue ")!= -1 ||
             FindSubString(sLCEmote, " exhausted ")!= -1)
    {
        PlayVoiceChat(VOICE_CHAT_REST, oPC);
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED, 1.0, 3.0));
    }
    else if (FindSubString(sLCEmote, " fidget")!= -1 ||
             FindSubString(sLCEmote, " shifts ")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " demand")!= -1 ||
             FindSubString(sLCEmote, " threaten")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " laugh")!= -1 ||
             FindSubString(sLCEmote, " chuckles ")!= -1
           )
    {
        PlayVoiceChat(VOICE_CHAT_LAUGH, oPC);
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING, 1.0, 2.0));
    }
    else if (FindSubString(sLCEmote, " begs ")!= -1 ||
             FindSubString(sLCEmote, " plead")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_PLEADING, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " points")!= -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM16, 1.0, 2.0));

    else if (FindSubString(sLCEmote, " point down")!= -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM4, 1.0, 2.0));

    else if (FindSubString(sLCEmote, " thinks")!= -1)
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM17, 1.0, 30.0));
    else if(    FindSubString(sLCEmote, " crosses arms")!= -1
            ||  FindSubString(sLCEmote, " arms crossed")!= -1
           )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM7, 1.0, 30.0));
    else if(    FindSubString(sLCEmote, " beckons")!= -1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM9, 2.0, 2.2));
    else if(    FindSubString(sLCEmote, " cowers")!= -1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM5, 1.0, 30.0));
    else if (FindSubString(sLCEmote, " worship")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_WORSHIP, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " snore")!= -1)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oPC);
    else if (FindSubString(sLCEmote, " sings")!= -1 ||
             FindSubString(sLCEmote, " hums")!= -1)
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_BARD_SONG), oPC, 6.0f);
    else if (FindSubString(sLCEmote, " whistles")!= -1)
        AssignCommand(oPC, PlaySound("as_pl_whistle2"));
    else if (FindSubString(sLCEmote, " talk")!= -1 ||
             FindSubString(sLCEmote, " chat")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_NORMAL, 1.0, 99999.0));
    else if ( FindSubString(sLCEmote, " shakes head") != -1 )
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 1.0, 0.25f));
        DelayCommand(0.15f, AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 1.0, 0.25f)));
        DelayCommand(0.40f, AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 1.0, 0.25f)));
        DelayCommand(0.65f, AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 1.0, 0.25f)));
    }
    else if (FindSubString(sLCEmote, " ducks")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " dodges")!= -1 || FindSubString(sLCEmote, " dodging ")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_SIDE, 1.0, 99999.0));
    /*
    else if (FindSubString(sLCEmote, " cantrip")!= -1)
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE1, 1.0, 99999.0));
    */
    else if (FindSubString(sLCEmote, " cast")!= -1
             && FindSubString(sLCEmote, " spell")>FindSubString(sLCEmote, " cast")
            )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " spasm")!= -1 )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, 99999.0));
    //Still testing. Believed to be used by ProjectQ only.
    else if (FindSubString(sLCEmote, " dances")!= -1 || FindSubString(sLCEmote, " waltzes")!= -1)
        EmoteDance(oPC);
    else if(    FindSubString(sLCEmote, " kneels")!= -1 )
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_CUSTOM10, 1.0, 30.0));
    else if (FindSubString(sLCEmote, " custom1")!= -1 )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM1, 1.0, 99999.0));
    else if (FindSubString(sLCEmote, " custom2")!= -1 )
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM2, 1.0, 99999.0));
}

////////////////////////////////////////////////////////////////////////
int GetIsAlphanumeric(string sCharacter) {
        sCharacter = GetStringLowerCase(sCharacter);
        if (sCharacter == "a" ||
                sCharacter == "b" ||
                sCharacter == "c" ||
                sCharacter == "d" ||
                sCharacter == "e" ||
                sCharacter == "f" ||
                sCharacter == "g" ||
                sCharacter == "h" ||
                sCharacter == "i" ||
                sCharacter == "j" ||
                sCharacter == "k" ||
                sCharacter == "l" ||
                sCharacter == "m" ||
                sCharacter == "n" ||
                sCharacter == "o" ||
                sCharacter == "p" ||
                sCharacter == "q" ||
                sCharacter == "r" ||
                sCharacter == "s" ||
                sCharacter == "t" ||
                sCharacter == "u" ||
                sCharacter == "v" ||
                sCharacter == "w" ||
                sCharacter == "x" ||
                sCharacter == "y" ||
                sCharacter == "z" ||
                sCharacter == "1" ||
                sCharacter == "2" ||
                sCharacter == "3" ||
                sCharacter == "4" ||
                sCharacter == "5" ||
                sCharacter == "6" ||
                sCharacter == "7" ||
                sCharacter == "8" ||
                sCharacter == "9" ||
                sCharacter == "0") {
                return TRUE;
        }

        return FALSE;
}

////////////////////////////////////////////////////////////////////////
void ParseCommand(object oTarget, object oCommander, string sComIn)
{
// :: 2008.07.31 morderon / tsunami282 - allow certain . commands for
// ::     PCs as well as DM's; allow shortcut targeting of henchies/pets

    int iOffset=0;
    if (GetIsDM(oTarget) && (oTarget != oCommander)) return; //DMs can only be affected by their own .commands

    int bValidTarget = GetIsObjectValid(oTarget);
    if (!bValidTarget)
    {
        DMFISendMessageToPC(oCommander, "No current command target - no commands will function.", FALSE, DMFI_MESSAGE_COLOR_ALERT);
        return;
    }

    // break into command and args
    struct sStringTokenizer st = GetStringTokenizer(sComIn, " ");
    st = AdvanceToNextToken(st);
    string sCom = GetStringLowerCase(GetNextToken(st));
    string sArgs = LTrim(st.sRemaining);

    // ** commands usable by all pc's/dm's
    if (GetStringLeft(sCom, 4) == ".loc")
    {
        SetLocalInt(oCommander, "dmfi_dicebag", 2);
        SetCustomToken(20681, "Local");
        SetDMFIPersistentInt("dmfi", "dmfi_dicebag", 2, oCommander);
        FloatingTextStringOnCreature("Broadcast Mode set to Local", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 4) == ".glo")
    {
        SetLocalInt(oCommander, "dmfi_dicebag", 1);
        SetCustomToken(20681, "Global");
        SetDMFIPersistentInt("dmfi", "dmfi_dicebag", 1, oCommander);
        FloatingTextStringOnCreature("Broadcast Mode set to Global", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 4) == ".pri")
    {
        SetLocalInt(oCommander, "dmfi_dicebag", 0);
        SetCustomToken(20681, "Private");
        SetDMFIPersistentInt("dmfi", "dmfi_dicebag", 0, oCommander);
        FloatingTextStringOnCreature("Broadcast Mode set to Private", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 3) == ".dm")
    {
        SetLocalInt(oCommander, "dmfi_dicebag", 3);
        SetCustomToken(20681, "DM Only");
        SetDMFIPersistentInt("dmfi", "dmfi_dicebag", 3, oCommander);
        FloatingTextStringOnCreature("Broadcast Mode set to DM Only", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 5) == ".aniy")
    {
        SetLocalInt(oCommander, "dmfi_dice_no_animate", 0);
        FloatingTextStringOnCreature("Rolls will show animation", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 5) == ".anin")
    {
        SetLocalInt(oCommander, "dmfi_dice_no_animate", 1);
        FloatingTextStringOnCreature("Rolls will NOT show animation", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 5) == ".emoy") // control emotes (based on Morderon code)
    {
        SetLocalInt(oCommander, "hls_emotemute", 0);
        FloatingTextStringOnCreature("*emote* commands are on", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 5) == ".emon") // control emotes (based on Morderon code)
    {
        SetLocalInt(oCommander, "hls_emotemute", 1);
        FloatingTextStringOnCreature("*emote* commands are off", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".lan") //sets the language of the target
    {
        // check target allowed
        if (!(GetIsDM(oCommander) || GetIsDMPossessed(oCommander) ||
            oTarget == oCommander || GetMaster(oTarget) == oCommander))
        {
            FloatingTextStringOnCreature("You cannot perform this command on a creature you do not control.", oCommander, FALSE);
            return;
        }

        string sArgsLC = GetStringLowerCase(sArgs);
        int iLang = 0;
        string sLang = "";
        int nLen    = GetStringLength(sArgsLC);
        string sLan = GetStringLeft(sArgsLC,3);
        iLang       = GetLanguageID(sLan);
        sLang       = GetLanguageName(iLang);

        // see if target is allowed to speak that language
        if (!GetIsDM(oCommander) && !GetIsDMPossessed(oCommander)) // DM's can set any language on anyone
            SetCurrentLanguageSpoken(oTarget, iLang);
        else
            SetCurrentLanguageSpoken(oTarget, iLang, TRUE, TRUE);

        return;
    }

    // that's all the PC commands, bail out if not DM
    if (!GetIsDM(oCommander) && !GetIsDMPossessed(oCommander))
    {
        DMFISendMessageToPC(oCommander, "DMFI dot command nonexistent or restricted to DM's - aborting.", FALSE, DMFI_MESSAGE_COLOR_ALERT);
        return;
    }

    if (GetStringLeft(sCom, 7) ==".appear")
    {
        string sNew = sArgs;
        DMFISendMessageToPC(oCommander, "Setting target appearance to: " + sNew, FALSE, DMFI_MESSAGE_COLOR_STATUS);
        int Appear = AppearType(sNew);

        if (Appear!=-1)
        {
            SetCreatureAppearanceType(GetLocalObject(oCommander, "dmfi_univ_target"), Appear);
            //SetCreatureAppearanceType(oTarget, Appear);
        }
        else
        {
            FloatingTextStringOnCreature("Invalid Appearance Type", oCommander);
        }

        dmw_CleanUp(oCommander);
        return;
    }

    if (GetStringLeft(sCom, 5) == ".stre")
        iOffset=  11;
    else if (GetStringLeft(sCom, 5) == ".dext")
        iOffset = 12;
    else if (GetStringLeft(sCom, 5) == ".cons")
        iOffset = 13;
    else if (GetStringLeft(sCom, 5) == ".inte")
        iOffset = 14;
    else if (GetStringLeft(sCom, 5) == ".wisd")
        iOffset = 15;
    else if (GetStringLeft(sCom, 5) == ".char")
        iOffset = 16;
    else if (GetStringLeft(sCom, 5) == ".fort")
        iOffset = 17;
    else if (GetStringLeft(sCom, 5) == ".refl")
        iOffset = 18;
    else if (GetStringLeft(sCom, 5) == ".anim")
        iOffset = 21;
    else if (GetStringLeft(sCom, 5) == ".appr")
        iOffset = 22;
    else if (GetStringLeft(sCom, 5) == ".bluf")
        iOffset =  23;
    else if (GetStringLeft(sCom, 5) == ".conc")
        iOffset = 24;
    else if (GetStringLeft(sCom, 9) == ".craft ar")
        iOffset =  25;
    else if (GetStringLeft(sCom, 9) == ".craft tr")
        iOffset =  26;
    else if (GetStringLeft(sCom, 9) == ".craft we")
        iOffset =  27;
    else if (GetStringLeft(sCom, 5) == ".disa")
        iOffset =  28;
    else if (GetStringLeft(sCom, 5) == ".disc")
        iOffset =  29;
    else if (GetStringLeft(sCom, 5) == ".heal")
        iOffset =  31;
    else if (GetStringLeft(sCom, 5) == ".hide")
        iOffset =  32;
    else if (GetStringLeft(sCom, 5) == ".inti")
        iOffset =  33;
    else if (GetStringLeft(sCom, 5) == ".list")
        iOffset =  34;
    else if (GetStringLeft(sCom, 5) == ".lore")
        iOffset =  35;
    else if (GetStringLeft(sCom, 5) == ".move")
        iOffset =  36;
    else if (GetStringLeft(sCom, 5) == ".open")
        iOffset =   37;
    else if (GetStringLeft(sCom, 5) == ".parr")
        iOffset =  38;
    else if (GetStringLeft(sCom, 5) == ".perf")
        iOffset =  39;
    else if (GetStringLeft(sCom, 5) == ".pers")
        iOffset =  41;
    else if (GetStringLeft(sCom, 5) == ".pick")
        iOffset =  42;
    else if (GetStringLeft(sCom, 5) == ".sear")
        iOffset =  43;
    else if (GetStringLeft(sCom, 6) == ".set t")
        iOffset =  44;
    else if (GetStringLeft(sCom, 5) == ".spel")
        iOffset =  45;
    else if (GetStringLeft(sCom, 5) == ".spot")
        iOffset =  46;
    else if (GetStringLeft(sCom, 5) == ".taun")
        iOffset =   47;
    else if (GetStringLeft(sCom, 5) == ".tumb")
        iOffset =  48;
    else if (GetStringLeft(sCom, 4) == ".use")
        iOffset =   49;

    if (iOffset!=0)
    {
        if (FindSubString(sCom, "all") != -1 || FindSubString(sArgs, "all") != -1)
            SetLocalInt(oCommander, "dmfi_univ_int", iOffset+40);
        else
            SetLocalInt(oCommander, "dmfi_univ_int", iOffset);

        SetLocalString(oCommander, "dmfi_univ_conv", "dicebag");
        if (GetIsObjectValid(oTarget))
        {
            if (oTarget != GetLocalObject(oCommander, "dmfi_univ_target"))
            {
                SetLocalObject(oCommander, "dmfi_univ_target", oTarget);
                FloatingTextStringOnCreature("DMFI Target set to "+GetName(oTarget), oCommander);
            }
            ExecuteScript("dmfi_execute", oCommander);
        }
        else
        {
            DMFISendMessageToPC(oCommander, "No valid DMFI target!", FALSE, DMFI_MESSAGE_COLOR_ALERT);
        }

        dmw_CleanUp(oCommander);
        return;
    }


    if (GetStringLeft(sCom, 4) == ".set")
    {
        // sCom = GetStringRight(sCom, GetStringLength(sCom) - 4);
        while (sArgs != "")
        {
            if(     FindSubString(CHAT_KEY, GetStringLeft(sArgs, 1) )!=-1
                ||  GetIsAlphanumeric(GetStringLeft(sArgs, 1))
              )
                sArgs = GetStringRight(sArgs, GetStringLength(sArgs) - 1);
            else
            {
                SetLocalObject(oCommander, GetStringLeft(sArgs, 1), oTarget);
                FloatingTextStringOnCreature("The Control character for " + GetName(oTarget) + " is " + GetStringLeft(sArgs, 1), oCommander, FALSE);
                return;
            }
        }
        FloatingTextStringOnCreature("Your Control Character is not valid. Perhaps you are using a reserved character.", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".ani")
    {
        int iArg = StringToInt(sArgs);
        AssignCommand(oTarget, ClearAllActions(TRUE));
        AssignCommand(oTarget, ActionPlayAnimation(iArg, 1.0, 99999.0f));
        return;
    }
    else if (GetStringLowerCase(GetStringLeft(sCom, 4)) == ".buf")
    {
        string sArgsLC = GetStringLowerCase(sArgs);
        if (FindSubString(sArgsLC, "low") !=-1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectACIncrease(3, AC_NATURAL_BONUS), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROT_BARKSKIN), oTarget, 3600.0f);
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_RESISTANCE, oTarget, METAMAGIC_ANY, TRUE, 5, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_GHOSTLY_VISAGE, oTarget, METAMAGIC_ANY, TRUE, 5, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_CLARITY,  oTarget,METAMAGIC_ANY, TRUE, 5, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            FloatingTextStringOnCreature("Low Buff applied: " + GetName(oTarget), oCommander);   return;
        }
        else if (FindSubString(sArgsLC, "mid") !=-1)
        {
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_LESSER_SPELL_MANTLE, oTarget, METAMAGIC_ANY, TRUE, 10, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_STONESKIN, oTarget, METAMAGIC_ANY, TRUE, 10, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_ELEMENTAL_SHIELD,  oTarget,METAMAGIC_ANY, TRUE, 10, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            FloatingTextStringOnCreature("Mid Buff applied: " + GetName(oTarget), oCommander);  return;
        }
        else if (FindSubString(sArgsLC, "high") !=-1)
        {
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_SPELL_MANTLE, oTarget, METAMAGIC_ANY, TRUE, 15, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_STONESKIN, oTarget, METAMAGIC_ANY, TRUE,15, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_SHADOW_SHIELD,  oTarget,METAMAGIC_ANY, TRUE, 15, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            FloatingTextStringOnCreature("High Buff applied: " + GetName(oTarget), oCommander);  return;
        }
        else if (FindSubString(sArgsLC, "epic") !=-1)
        {
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, oTarget, METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_SPELL_RESISTANCE, oTarget, METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_SHADOW_SHIELD,  oTarget,METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_CLARITY,  oTarget,METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            FloatingTextStringOnCreature("Epic Buff applied: " + GetName(oTarget), oCommander);  return;
        }
        else if (FindSubString(sArgsLC, "barkskin") != -1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectACIncrease(3, AC_NATURAL_BONUS), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROT_BARKSKIN), oTarget, 3600.0f);  return;
        }
        else if (FindSubString(sArgsLC, "elements") != -1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_COLD, 20, 40), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_FIRE, 20, 40), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_ACID, 20, 40), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_SONIC, 20, 40), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, 20, 40), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS), oTarget, 3600.0f);  return;
        }
        else if (FindSubString(sArgsLC, "haste") != -1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectHaste(), oTarget, 3600.0f);  return;
        }
        else if (FindSubString(sArgsLC, "immortal") != -1) // tsunami282 added
        {
            SetImmortal(oTarget, TRUE);
            FloatingTextStringOnCreature("The target is set to Immortal (cannot die).", oCommander, FALSE);  return;
        }
        else if (FindSubString(sArgsLC, "mortal") != -1) // tsunami282 added
        {
            SetImmortal(oTarget, TRUE);
            FloatingTextStringOnCreature("The target is set to Mortal (can die).", oCommander, FALSE);  return;
        }
        else if (FindSubString(sArgsLC, "invis") != -1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), oTarget, 3600.0f);   return;
        }
        else if (FindSubString(sArgsLC, "unplot") != -1)
        {
            SetPlotFlag(oTarget, FALSE);
            FloatingTextStringOnCreature("The target is set to non-Plot.", oCommander, FALSE); return;
        }
        else if (FindSubString(sArgsLC, "plot") != -1)
        {
            SetPlotFlag(oTarget, TRUE);
            FloatingTextStringOnCreature("The target is set to Plot.", oCommander, FALSE);  return;
        }
        else if (FindSubString(sArgsLC, "stoneskin") != -1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageReduction(10, DAMAGE_POWER_PLUS_THREE, 100), oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROT_GREATER_STONESKIN), oTarget, 3600.0f); return;
        }
        else if (FindSubString(sArgsLC, "trues") != -1)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTrueSeeing(), oTarget, 3600.0f); return;
        }
    }
    else if (GetStringLeft(sCom, 4) == ".dam")
    {
        int iArg = StringToInt(sArgs);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iArg, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL), oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_BLOOD_LRG_RED), oTarget);
        FloatingTextStringOnCreature(GetName(oTarget) + " has taken " + IntToString(iArg) + " damage.", oCommander, FALSE);
        return;
    }
    // 2008.05.29 tsunami282 - set description
    else if (GetStringLeft(sCom, 5) == ".desc")
    {
        // object oTgt = GetLocalObject(oCommander, "dmfi_univ_target");
        if (GetIsObjectValid(oTarget))
        {
            if (sArgs == ".") // single dot means reset to base description
            {
                SetDescription(oTarget);
            }
            else // assign new description
            {
                SetDescription(oTarget, sArgs);
            }
            FloatingTextStringOnCreature("Target's description set to " + GetDescription(oTarget), oCommander, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("Invalid target - command not processed.", oCommander, FALSE);
        }
    }
    else if (GetStringLeft(sCom, 5) == ".dism")
    {
        DestroyObject(oTarget);
        FloatingTextStringOnCreature(GetName(oTarget) + " dismissed", oCommander, FALSE); return;
    }
    else if (GetStringLeft(sCom, 4) == ".inv")
    {
        OpenInventory(oTarget, oCommander);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".dmt")
    {
        SetLocalInt(GetModule(), "dmfi_DMToolLock", abs(GetLocalInt(GetModule(), "dmfi_DMToolLock") -1)); return;
    }
    // else if (GetStringLowerCase(GetStringLeft(sCom, 4)) == ".dms")
    // {
    //     SetDMFIPersistentInt("dmfi", "dmfi_DMSpy", abs(GetDMFIPersistentInt("dmfi", "dmfi_DMSpy", oCommander) -1), oCommander); return;
    // }
    else if (GetStringLeft(sCom, 4) == ".fac")
    {
        string sArgsLC = GetStringLowerCase(sArgs);
        if (FindSubString(sArgsLC, "hostile") != -1)
        {
            ChangeToStandardFaction(oTarget, STANDARD_FACTION_HOSTILE);
            FloatingTextStringOnCreature("Faction set to hostile", oCommander, FALSE);
        }
        else if (FindSubString(sArgsLC, "commoner") != -1)
        {
            ChangeToStandardFaction(oTarget, STANDARD_FACTION_COMMONER);
            FloatingTextStringOnCreature("Faction set to commoner", oCommander, FALSE);
        }
        else if (FindSubString(sArgsLC, "defender") != -1)
        {
            ChangeToStandardFaction(oTarget, STANDARD_FACTION_DEFENDER);
            FloatingTextStringOnCreature("Faction set to defender", oCommander, FALSE);
        }
        else if (FindSubString(sArgsLC, "merchant") != -1)
        {
            ChangeToStandardFaction(oTarget, STANDARD_FACTION_MERCHANT);
            FloatingTextStringOnCreature("Faction set to merchant", oCommander, FALSE);
        }
        else
        {
            DMFISendMessageToPC(oCommander, "Invalid faction name - command aborted.", FALSE, DMFI_MESSAGE_COLOR_ALERT);
            return;
        }

        // toggle blindness on the target, to cause a re-perception
        if (GetIsImmune(oTarget, IMMUNITY_TYPE_BLINDNESS))
        {
            DMFISendMessageToPC(oCommander, "Targeted creature is blind immune - no attack will occur until new perception event is fired", FALSE, DMFI_MESSAGE_COLOR_ALERT);
        }
        else
        {
            effect eInvis =EffectBlindness();
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, oTarget, 6.1);
            DMFISendMessageToPC(oCommander, "Faction Adjusted - will take effect in 6 seconds", FALSE, DMFI_MESSAGE_COLOR_STATUS);
        }
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".fle")
    {
        AssignCommand(oTarget, ClearAllActions(TRUE));
        AssignCommand(oTarget, ActionMoveAwayFromObject(oCommander, TRUE));
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".fly")
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDisappear(), oTarget);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".fol")
    {
        int iArg = StringToInt(sArgs);
        FloatingTextStringOnCreature(GetName(oTarget) + " will follow you for "+IntToString(iArg)+" seconds.", oCommander, FALSE);
        AssignCommand(oTarget, ClearAllActions(TRUE));
        AssignCommand(oTarget, ActionForceMoveToObject(oCommander, TRUE, 2.0f, IntToFloat(iArg)));
        DelayCommand(IntToFloat(iArg), FloatingTextStringOnCreature(GetName(oTarget) + " has stopped following you.", oCommander, FALSE));
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".fre")
    {
        FloatingTextStringOnCreature(GetName(oTarget) + " frozen", oCommander, FALSE);
        SetCommandable(TRUE, oTarget);
        AssignCommand(oTarget, ClearAllActions(TRUE));
        DelayCommand(0.5f, SetCommandable(FALSE, oTarget));
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".get")
    {
        while (sArgs != "")
        {
            if (GetStringLeft(sArgs, 1) == " " ||
                GetStringLeft(sArgs, 1) == "[" ||
                GetStringLeft(sArgs, 1) == "." ||
                GetStringLeft(sArgs, 1) == ":" ||
                GetStringLeft(sArgs, 1) == ";" ||
                GetStringLeft(sArgs, 1) == "*" ||
                GetIsAlphanumeric(GetStringLeft(sArgs, 1)))
                sArgs = GetStringRight(sArgs, GetStringLength(sArgs) - 1);
            else
            {
                object oJump = GetLocalObject(GetModule(), "hls_NPCControl" + GetStringLeft(sArgs, 1));
                if (GetIsObjectValid(oJump))
                {
                    AssignCommand(oJump, ClearAllActions());
                    AssignCommand(oJump, ActionJumpToLocation(GetLocation(oCommander)));
                }
                else
                {
                    FloatingTextStringOnCreature("Your Control Character is not valid. Perhaps you are using a reserved character.", oCommander, FALSE);
                }
                return;
            }
        }
        FloatingTextStringOnCreature("Your Control Character is not valid. Perhaps you are using a reserved character.", oCommander, FALSE);
        return;

    }
    else if (GetStringLeft(sCom, 4) == ".got")
    {
        while (sArgs != "")
        {
            if (GetStringLeft(sArgs, 1) == " " ||
                GetStringLeft(sArgs, 1) == "[" ||
                GetStringLeft(sArgs, 1) == "." ||
                GetStringLeft(sArgs, 1) == ":" ||
                GetStringLeft(sArgs, 1) == ";" ||
                GetStringLeft(sArgs, 1) == "*" ||
                GetIsAlphanumeric(GetStringLeft(sArgs, 1)))
                sArgs = GetStringRight(sArgs, GetStringLength(sArgs) - 1);
            else
            {
                object oJump = GetLocalObject(GetModule(), "hls_NPCControl" + GetStringLeft(sArgs, 1));
                if (GetIsObjectValid(oJump))
                {
                    AssignCommand(oCommander, ClearAllActions());
                    AssignCommand(oCommander, ActionJumpToLocation(GetLocation(oJump)));
                }
                else
                {
                    FloatingTextStringOnCreature("Your Control Character is not valid. Perhaps you are using a reserved character.", oCommander, FALSE);
                }
                return;
            }
        }
        FloatingTextStringOnCreature("Your Control Character is not valid. Perhaps you are using a reserved character.", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".hea")
    {
        int iArg = StringToInt(sArgs);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(iArg), oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_M), oTarget);
        FloatingTextStringOnCreature(GetName(oTarget) + " has healed " + IntToString(iArg) + " HP.", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".ite")
    {
        object oCreate = CreateItemOnObject(sArgs, oTarget, 1);
        if (GetIsObjectValid(oCreate)) FloatingTextStringOnCreature("Item " + GetName(oCreate) + " created.", oCommander, FALSE);
        return;
    }
    // 2008.05.29 tsunami282 - set name
    else if (GetStringLeft(sCom, 5) == ".name")
    {
        // object oTgt = GetLocalObject(oCommander, "dmfi_univ_target");
        if (GetIsObjectValid(oTarget))
        {
            if (sArgs == ".") // single dot means reset to base name
            {
                SetName(oTarget);
            }
            else // assign new name
            {
                SetName(oTarget, sArgs);
            }
            FloatingTextStringOnCreature("Target's name set to " + GetName(oTarget), oCommander, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("Invalid target - command not processed.", oCommander, FALSE);
        }
    }
    else if (GetStringLeft(sCom, 4) == ".mut")
    {
        FloatingTextStringOnCreature(GetName(oTarget) + " muted", oCommander, FALSE);
        SetLocalInt(oTarget, "dmfi_Mute", 1);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".npc")
    {
        object oCreate = CreateObject(OBJECT_TYPE_CREATURE, sArgs, GetLocation(oTarget));
        if (GetIsObjectValid(oCreate))
            FloatingTextStringOnCreature("NPC " + GetName(oCreate) + " created.", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".pla")
    {
        object oCreate = CreateObject(OBJECT_TYPE_PLACEABLE, sArgs, GetLocation(oTarget));
        if (GetIsObjectValid(oCreate))
            FloatingTextStringOnCreature("Placeable " + GetName(oCreate) + " created.", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".rem")
    {
        effect eRemove = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eRemove))
        {
            RemoveEffect(oTarget, eRemove);
            eRemove = GetNextEffect(oTarget);
        }
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".say")
    {
        int iArg = StringToInt(sArgs);
        if (GetDMFIPersistentString("dmfi", "hls206" + IntToString(iArg)) != "")
        {
            AssignCommand(oTarget, SpeakString(GetDMFIPersistentString("dmfi", "hls206" + IntToString(iArg))));
        }
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".tar")
    {
        object oGet = GetFirstObjectInArea(GetArea(oCommander));
        while (GetIsObjectValid(oGet))
        {
            if (FindSubString(GetName(oGet), sArgs) != -1)
            {
                // SetLocalObject(oCommander, "dmfi_VoiceTarget", oGet);
                SetLocalObject(oCommander, "dmfi_univ_target", oGet);
                FloatingTextStringOnCreature("You have targeted " + GetName(oGet) + " with the DMFI Targeting Widget", oCommander, FALSE);
                return;
            }
            oGet = GetNextObjectInArea(GetArea(oCommander));
        }
        FloatingTextStringOnCreature("Target not found.", oCommander, FALSE);
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".unf")
    {
        FloatingTextStringOnCreature(GetName(oTarget) + " unfrozen", oCommander, FALSE);
        SetCommandable(TRUE, oTarget); return;
    }
    else if (GetStringLeft(sCom, 4) == ".unm")
    {
        FloatingTextStringOnCreature(GetName(oTarget) + " un-muted", oCommander, FALSE);
        DeleteLocalInt(oTarget, "dmfi_Mute"); return;
    }
    else if (GetStringLeft(sCom, 4) == ".vfx")
    {
        int iArg = StringToInt(sArgs);
        if (GetTag(oTarget) == "dmfi_voice")
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(iArg), GetLocation(oTarget), 10.0f);
        else
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(iArg), oTarget, 10.0f);
        return;
    }
    else if (GetStringLeft(sCom, 5) == ".vtar")
    {
        object oGet = GetFirstObjectInArea(GetArea(oCommander));
        while (GetIsObjectValid(oGet))
        {
            if (FindSubString(GetName(oGet), sArgs) != -1)
            {
                SetLocalObject(oCommander, "dmfi_VoiceTarget", oGet);
                FloatingTextStringOnCreature("You have targeted " + GetName(oGet) + " with the Voice Widget", oCommander, FALSE);
                return;
            }
            oGet = GetNextObjectInArea(GetArea(oCommander));
        }
        FloatingTextStringOnCreature("Target not found.", oCommander, FALSE);
        return;
    }
}

////////////////////////////////////////////////////////////////////////
int RelayTextToEavesdropper(object oShouter, int nVolume, string sSaid)
{
// arguments
//  (return) - flag to continue processing text: X2_EXECUTE_SCRIPT_CONTINUE or
//             X2_EXECUTE_SCRIPT_END
//  oShouter - object that spoke
//  nVolume - channel (TALKVOLUME) text was spoken on
//  sSaid - text that was spoken

    int bScriptEnd = X2_EXECUTE_SCRIPT_CONTINUE;

    // sanity checks
    if (GetIsObjectValid(oShouter))
    {
        int iHookToDelete = 0;
        int iHookType = 0;
        int channels = 0;
        int rangemode = 0;
        string siHook = "";
        object oMod = GetModule();
        int iHook = 1;
        while (1)
        {
            siHook = IntToString(iHook);
            iHookType = GetLocalInt(oMod, sHookTypeVarname+siHook);
            if (iHookType == 0) break; // end of list

            // check channel
            channels = GetLocalInt(oMod, sHookChannelsVarname+siHook);
            if (((1 << nVolume) & channels) != 0)
            {
                string sVol = (nVolume == TALKVOLUME_WHISPER ? "whispers" : "says");
                object oOwner = GetLocalObject(oMod, sHookOwnerVarname+siHook);
                if (GetIsObjectValid(oOwner))
                {
                    // it's a channel for us to listen on, process
                    int bcast = GetLocalInt(oMod, sHookBcastDMsVarname+siHook);
                    // for type 1, see if speaker is the one we want (pc or party)
                    // for type 2, see if speaker says his stuff within ("earshot" / area / module) of listener's location
                    if (iHookType == 1) // listen to what a PC hears
                    {
                        object oListener;
                        location locShouter, locListener;
                        object oTargeted = GetLocalObject(oMod, sHookCreatureVarname+siHook);
                        if (GetIsObjectValid(oTargeted))
                        {
                            rangemode = GetLocalInt(oMod, sHookRangeModeVarname+siHook);
                            if (rangemode) oListener = GetFirstFactionMember(oTargeted, FALSE); // everyone in party are our listeners
                            else oListener = oTargeted; // only selected PC is our listener
                            while (GetIsObjectValid(oListener))
                            {
                                // check speaker:
                                // check within earshot
                                int bInRange = FALSE;
                                locShouter = GetLocation(oShouter);
                                locListener = GetLocation(oListener);
                                if (oShouter == oListener)
                                {
                                    bInRange = TRUE; // the target can always hear himself
                                }
                                else if (GetAreaFromLocation(locShouter) == GetAreaFromLocation(locListener))
                                {
                                    float dist = GetDistanceBetweenLocations(locListener, locShouter);
                                    if ((nVolume == TALKVOLUME_WHISPER && dist <= WHISPER_DISTANCE) ||
                                        (nVolume != TALKVOLUME_WHISPER && dist <= TALK_DISTANCE))
                                    {
                                        bInRange = TRUE;
                                    }
                                }
                                if (bInRange)
                                {
                                    // relay what's said to the hook owner
                                    string sMesg = "("+GetName(GetArea(oShouter))+") "+GetName(oShouter)+" "+sVol+": "+sSaid;
                                    // if (bcast) SendMessageToAllDMs(sMesg);
                                    // else SendMessageToPC(oOwner, sMesg);
                                    DMFISendMessageToPC(oOwner, sMesg, bcast, DMFI_MESSAGE_COLOR_EAVESDROP);
                                }
                                if (rangemode == 0) break; // only check the target creature for rangemode 0
                                if (bInRange) break; // once any party member hears shouter, we're done
                                oListener = GetNextFactionMember(oTargeted, FALSE);
                            }
                        }
                        else
                        {
                            // bad desired speaker, remove hook
                            iHookToDelete = iHook;
                        }
                    }
                    else if (iHookType == 2) // listen at location
                    {
                        location locShouter, locListener;
                        object oListener = GetLocalObject(oMod, sHookCreatureVarname+siHook);
                        if (oListener != OBJECT_INVALID)
                        {
                            locListener = GetLocation(oListener);
                        }
                        else
                        {
                            locListener = GetLocalLocation(oMod, sHookLocationVarname+siHook);
                        }
                        locShouter = GetLocation(oShouter);
                        rangemode = GetLocalInt(oMod, sHookRangeModeVarname+siHook);
                        int bInRange = FALSE;
                        if (rangemode == 0)
                        {
                            // check within earshot
                            if (GetAreaFromLocation(locShouter) == GetAreaFromLocation(locListener))
                            {
                                float dist = GetDistanceBetweenLocations(locListener, locShouter);
                                if ((nVolume == TALKVOLUME_WHISPER && dist <= WHISPER_DISTANCE) ||
                                    (nVolume != TALKVOLUME_WHISPER && dist <= TALK_DISTANCE))
                                {
                                    bInRange = TRUE;
                                }
                            }
                        }
                        else if (rangemode == 1)
                        {
                            // check within area
                            if (GetAreaFromLocation(locShouter) == GetAreaFromLocation(locListener)) bInRange = TRUE;
                        }
                        else
                        {
                            // module-wide
                            bInRange = TRUE;
                        }
                        if (bInRange)
                        {
                            // relay what's said to the hook owner
                            string sMesg = "("+GetName(GetArea(oShouter))+") "+GetName(oShouter)+" "+sVol+": "+sSaid;
                            // if (bcast) SendMessageToAllDMs(sMesg);
                            // else SendMessageToPC(oOwner, sMesg);
                            DMFISendMessageToPC(oOwner, sMesg, bcast, DMFI_MESSAGE_COLOR_EAVESDROP);
                        }
                    }
                    else
                    {
                        WriteTimestampedLogEntry("ERROR: DMFI OnPlayerChat handler: invalid iHookType; removing hook.");
                        iHookToDelete = iHook;
                    }
                }
                else
                {
                    // bad owner, delete hook
                    iHookToDelete = iHook;
                }
            }

            iHook++;
        }

        // remove a bad hook: note we can only remove one bad hook this way, have to rely on subsequent calls to remove any others
        if (iHookToDelete > 0)
        {
            RemoveListenerHook(iHookToDelete);
        }
    }

    return bScriptEnd;
}

////////////////////////////////////////////////////////////////////////
//void main(){}
