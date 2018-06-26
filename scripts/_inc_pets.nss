//::///////////////////////////////////////////////
//:: _inc_pets
//:://////////////////////////////////////////////
/*

    Master include for associates of PC (familiars, animal companions)

    Foundation
        The Magus' Innocuous Familiars

    Integrated Systems
        Rolo Kipp's Mounted Familiar VFX
    if you are NOT using Rolo's VFX,
    ensure the code is commented out.
    conversely if you are using Rolo's VFX,
    ensure the code is not commented.

    to find the code search for
    // Rolo Kipp's Mounted Familiar VFX

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 4)
//:: Modified:  The Magus (2013 jan 28) Integration with Rolo Kipp's Mounted Familiar VFX
//:: Modified:  The Magus (2015 sep 20) Integration with nwnx funcs
//:://////////////////////////////////////////////
//:: Modified:  henesua (2016) pulled into one file

#include "_inc_constants"
// colors for feedback text
#include "_inc_color"
// spell functions
#include "_inc_spells"

#include "_inc_nwnx"

// GetAssociateState
#include "X0_INC_HENAI"
// GetHasEffect
#include "x0_i0_match"
// persistent vars on master's skin
#include "x3_inc_skin"
// adding properties to the familiar hide (skin)
#include "x2_inc_itemprop"

// CONSTANTS -------------------------------------------------------------------

//CONFIGURATION

// name of 2DA used to describe familiars
const string FAMILIAR_2DA           = "hen_familiar_x";

// if TRUE, PCs will only be able to Bind familiars of the same "type"
//  see ifamiliar.2da:
//  column HEN_FAMILIAR relates each familiar back to an index of hen_familiar.2da
//  hen_familiar.2da defines the PC's options for familiars during character creation and level up
const int FAMILIARS_RESTRICTED_BY_TYPE  = FALSE;

const int FAMILIAR_PORTRAIT_GENERIC = 817;          // index of default familiar portrait
const string FAMILIAR_EQUIP_DEFAULT = "default";    // string in resref indicates default equipment for familiar
const int FAMILIAR_XP_LOST_PER_LEVEL= 200;          // amount of XP lost per master level when reincarnating a dead familiar

// FAMILIAR TYPES (index of hen_familiar.2da)
//const int FAMILIAR_CREATURE_TYPE_BAT    = 0; // NWN has same value
const int FAMILIAR_CREATURE_TYPE_CAT    = 1;
const int FAMILIAR_CREATURE_TYPE_DOG    = 2;
const int FAMILIAR_CREATURE_TYPE_SNAKE  = 3;
const int FAMILIAR_CREATURE_TYPE_CROW   = 7;
const int FAMILIAR_CREATURE_TYPE_SEAGULL= 8;
const int FAMILIAR_CREATURE_TYPE_MOUSE  = 10;
const int FAMILIAR_CREATURE_TYPE_VIPER  = 22;
const int FAMILIAR_CREATURE_TYPE_RAVENB = 29;

//SPELLS
const int SPELL_FAMILIAR_MAGIC_MISSILE              = 1012;
const int SPELL_FAMILIAR_CONFUSION                  = 1016;
const int SPELL_FAMILIAR_DISPEL_MAGIC               = 1017;
const int SPELL_FAMILIAR_KNOCK                      = 1018;
const int SPELL_FAMILIAR_HOUND_BREATH               = 1019;
const int SPELL_FAMILIAR_GAZE_FEAR                  = 1020;

const int VFX_IMP_SPELLPOOL_DEPLETION   = 1662;
const int VFX_SND_MAGIC_MISSILE         = 1663;
const int VFX_SND_INVISIBILITY          = 1664;
const int VFX_CAST_HOUNDBREATH          = 1680;
const int VFX_CAST_GAZEFEAR             = 1681;

//FEATS

//const int FEAT_FLIGHT               = 2012;
//const int FEAT_PASSDO0R             = 2013;
//const int FEAT_MARK_TARGET          = 2014;
//const int FEAT_SPELL_TARGET         = 2015;
//const int FEAT_FAMILIAR_SPELL_TOUCH = 2016;
//const int FEAT_FAMILIAR_SPELL_SHORT = 2017;
//const int FEAT_FAMILIAR_SPELL_MEDIUM= 2018;
//const int FEAT_FAMILIAR_SPELL_LONG  = 2019;
const int FEAT_FAMILIAR_INVISIBILITY            = 2020;
const int FEAT_FAMILIAR_IMPROVED_INVISIBILITY   = 2021;
const int FEAT_FAMILIAR_MAGIC_MISSILE           = 2022;

const int FEAT_FAMILIAR_CONFUSION               = 2026;
const int FEAT_FAMILIAR_DISPEL_MAGIC            = 2027;
const int FEAT_FAMILIAR_KNOCK                   = 2028;
const int FEAT_FAMILIAR_HOUND_BREATH            = 2029;
const int FEAT_FAMILIAR_GAZE_FEAR               = 2030;

//IPFEATS
const int IPFEAT_FAMILIAR_SPELL_TOUCH   = 211;
const int IPFEAT_FAMILIAR_SPELL_SHORT   = 212;
const int IPFEAT_FAMILIAR_SPELL_MEDIUM  = 213;
const int IPFEAT_FAMILIAR_SPELL_LONG    = 214;
const int IPFEAT_FAMILIAR_INVISIBILITY  = 215;
const int IPFEAT_FAMILIAR_IMPROVED_INVISIBILITY  = 216;
const int IPFEAT_FAMILIAR_MAGIC_MISSILE = 217;
const int IPFEAT_FAMILIAR_CONFUSION     = 221;
const int IPFEAT_FAMILIAR_DISPEL_MAGIC  = 222;
const int IPFEAT_FAMILIAR_KNOCK         = 223;
const int IPFEAT_FAMILIAR_HOUND_BREATH  = 224;
const int IPFEAT_FAMILIAR_GAZE_FEAR     = 225;

// globals .....................................................................

struct BENEFITS
{
    effect perk;
    string description;
};

// FAMILIARS
const string HAS_PET                = "PC_HAS_PET";

const string FAMILIAR               = "FAMILIAR";
const string FAMILIAR_SUMMONED      = "FAM_SUMMONED";
const string FAMILIAR_DEAD          = "FAM_DEAD";
const string FAMILIAR_HP            = "FAM_HP";
const string FAMILIAR_ALIGN_SHIFT   = "FAM_ALGN_SHFT";

const string FAMILIAR_FEAT_COUNT= "FAM_IPRP_CNT";
const string FAMILIAR_FEAT_INDEX= "FAM_IPRP_IDX";
const string FAMILIAR_FEAT_LEVEL= "FAM_IPRP_LVL";

const string FAMILIAR_SPELL_POOL            = "FAM_SPELLPOOL";
const string FAMILIAR_SPELL_POOL_SKILL      = "FAM_POOL_SKILL";
const string FAMILIAR_SPELL_POOL_ABILITY    = "FAM_POOL_ABILITY";
const int FAMILIAR_SPELL_POOL_DEFAULT       = -1;

const string FAMILIAR_INDEX     = "FAM_INDEX"; // ifamiliar.2da index set on master as local int
const string FAMILIAR_TYPE      = "FAM_TYPE";  // hen_familiar.2da index set on master as skin int for tracking purposes
const string FAMILIAR_FORM      = "FAM_FORM";  // appearance.2da index set on master as local int
const string FAMILIAR_NAME      = "FAM_NAME";  // name set on master as local string
const string FAMILIAR_DESCRIBE  = "FAM_DESC";  // description set on master as local string
const string FAMILIAR_STICKY    = "FAM_STKY";  // boolean on master, if TRUE this familiar can not be changed in the normal manner

const string FAMILIAR_GOOD      = "FAM_GOOD";  // Familiar Align Good Axis
const string FAMILIAR_LAW       = "FAM_LAW";   // Familiar Align Law Axis

// ANIMAL COMPANIONS

const string COMPANION              = "COMPANION";
const string COMPANION_SUMMONED     = "COM_SUMMONED";
const string COMPANION_DEAD         = "COM_DEAD";

const string COMPANION_AWAKENED     = "COM_AWAKENED";
const string COMPANION_AWAKENED_WIS = "COM_AWAKENED_WIS";

// FUNCTION DECLARATIONS -------------------------------------------------------

// Configurable ................................................................

// User configurable Special Data - [FILE: _inc_pets]
// - indicate special ability initialization
// - change familiar's data in the middle of a spawn
// - or otherwise run any script you like
// returns TRUE or FALSE. if TRUE, spawn event continues. if FALSE, spawn event stops
int FamiliarInitializeSpecialData(object oMaster);
// If creature has an alternate appearance for flying (like a seagull) initialize self - [FILE: _inc_pets]
void FamiliarInitializeFlyAppearance(int nForm, int nFamIndex);
// Returns an index to ifamiliar.2da based on appearance - [FILE: _inc_pets]
int GetFamiliarIndex(object oCreature);
// Customizable benefits for master - [FILE: _inc_pets]
// nBenefitType is the value of the column MASTER_BENEFITS in ifamiliar.2da
// bReceivedAlertness is either TRUE or FALSE depending on whether master is receiving the alertness perk
struct BENEFITS GetMasterBenefits(int nBenefitType, int bReceivedAlertness);
// User configurable additions to the Familiar's Spawn Event. - [FILE: _inc_pets]
void FamiliarSpawnEventCustom(object oMaster);


// Master ......................................................................

// Initializes Master with Pet data - [FILE: _inc_pets]
// eg. calls: MasterInitializeFamiliarData()
void MasterInitializePets();
// Initializes Master with Familiar data - [FILE: _inc_pets]
void MasterInitializeFamiliarData();
// Erases Familiar Data from the Master. This effectively destroys the familiar, and prompts a refresh. - [FILE: _inc_pets]
void MasterWipeFamiliarData();
// Master's heartbeat event executes in the pc loop of a module heartbeat - [FILE: _inc_pets]
// if the PC has a familiar which is no longer summoned, Despawning of the familiar is handled (retroactively)
void MasterHeartbeatEvent();
// Master (OBJECT_SELF) has successfully leveled up - [FILE: _inc_pets]
void MasterLevelUpEvent();
// Master (OBJECT_SELF) has rested, and their familiar will as well - [FILE: _inc_pets]
void MasterRestEvent();
// Special case to track death of a possessed familiar - [FILE: _inc_pets]
void MasterExperiencedFamiliarDeath(string sFamName);
// Spell Sharing called from Module's UserDefined Event - [FILE: _inc_pets]
void MasterSharesSpellWithFamiliar(int nSpellID, object oFamiliar, int nMeta, int nLevel);

// Familiar ....................................................................

// Familiar Spawn Event - [FILE: _inc_pets]
//  - NPCs can summon a familiar with a name and appearance other than a bat
//      set name with local string "FAM_NAME" on Wizard NPC
//      set appearance with local int "FAM_FORM" on Wizard NPC
//  - Alternate appearances for all Familiars. Alt Appearance is persistently stored on PC Skin.
//  - Applies Familiar Benefits to master. See: _s0_fameffects
//  - Persistent HP for familiar are stored on PC skin
//  - Fly and walk form switching enabled for seagulls - and similar birds
void FamiliarSpawnEvent(object oMaster);
// Familiar (OBJECT_SELF) equips creature items based on nFamIndex and hitdice - [FILE: _inc_pets]
void FamiliarEquipItems(int nFamIndex);
// Familiar (OBJECT_SELF) gains itemprops on hide based on nFamIndex and hitdice - [FILE: _inc_pets]
void FamiliarLevelUp(int nFamIndex);
// Familiar (OBJECT_SELF) gains skills based on rules set in 2DA - [FILE: _inc_pets]
void FamiliarSkill(int SKILL_INDEX, int nfamiliar_HD, int nSkillBonus, object oHide);
// Familiar (OBJECT_SELF) gains natural armor based on nFamIndex and hitdice - [FILE: _inc_pets]
void FamiliarNaturalArmor(int nFamIndex);
// Familiar (OBJECT_SELF) gains spell resistance based on nFamIndex and hitdice - [FILE: _inc_pets]
void FamiliarSpellResistance(int nFamIndex);
// Familiar (OBJECT_SELF) is updated at end of Master's Rest - [FILE: _inc_pets]
void FamiliarRest(int nFamIndex);
// Damage to the familiar (OBJECT_SELF) is tracked and stored on the master's skin - [FILE: _inc_pets]
void FamiliarTrackHitPoints(object oMaster);
// Familiar (OBJECT_SELF) is restored to its HitPoint count when spawning - [FILE: _inc_pets]
void FamiliarStartingHitPoints(int nDamage);
// Familiar (OBJECT_SELF) Death Event - [FILE: _inc_pets]
void FamiliarDeathEvent(object oMaster);
// Familiar's alignment is determined and set - [FILE: _inc_pets]
void FamiliarAlignment(object oMaster, int nFamIndex);
// Familiar's heartbeat event - [FILE: _inc_pets]
// checks for stealth or search mode
// Fly/Walk switch for seagulls and similar birds
void FamiliarHeartbeatEvent(object oMaster, int nAction, float fDistToMaster, float fDistFollow);
// Returns the maximum spell pool for the familiar - [FILE: _inc_pets]
int FamiliarGetMaxSpellPool();
// Refills the familiar's spell pool - [FILE: _inc_pets]
void FamiliarReplenishSpellPool(object oMaster);
// Describes remaining capacity of spell pool - [FILE: _inc_pets]
void FamiliarDisplaySpellPool(int nPool=-99);

// .............................................................................

// Handles despawning event of a familiar on first HB after familiar is gone- [FILE: _inc_pets]
// Removes Familiar efects from master which are created when a familiar is spawned.
void DoFamiliarDespawnEvent(object oMaster);
// Familiar's Hide loses the item property which allows it to cast a stored spell - [FILE: _inc_pets]
void RemoveMasterSpellsFromFamiliarHide(object oHide, int nIPFeatProp=0, object oFamiliar=OBJECT_SELF);
// Returns TRUE if oCreature is compatible with oPC - [FILE: _inc_pets]
int GetIsCompatibleFamiliar(object oCreature, object oPC);
// Returns portrait ID from ifamiliar.2da by familiar index - [FILE: _inc_pets]
int GetFamiliarPortraitId(int nFamIndex);


// FUNCTION IMPLEMENTATIONS ----------------------------------------------------

// Configurable ................................................................

int FamiliarInitializeSpecialData(object oMaster)
{
    // default spell pool
    // each special familiar can differ from the default, be changing these in the code blocks below
    // see FamiliarGetMaxSpellPool() to see how these values are used
    SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL_SKILL, FAMILIAR_SPELL_POOL_DEFAULT);
    SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL_ABILITY, FAMILIAR_SPELL_POOL_DEFAULT);

    // a do once thing?
    if(GetLocalInt(oMaster, "FAMILIAR_NOT_SPECIAL"))
        return TRUE;

    // Integers only and do not use 0 in "SPECIAL" if you want to use this function
    int nSpecial    = StringToInt(Get2DAString(FAMILIAR_2DA,"SPECIAL",GetLocalInt(oMaster,FAMILIAR_INDEX)));

    if(!nSpecial)
        SetLocalInt(oMaster, "FAMILIAR_NOT_SPECIAL", TRUE);
    else if(nSpecial==1)
    {
        // IMP

        // Setup Pseudo Array of Bonus Feats to set on skin
        // number added to familiar skin. - length of Pseudo Array
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_COUNT, 2);
        // Pseudo Array begins at 1.
        //  we identify the index of the feat
        //  and at which level the familiar gains it
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"1", IPFEAT_FAMILIAR_MAGIC_MISSILE);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"1", 1);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"2", IPFEAT_FAMILIAR_INVISIBILITY);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"2", 5);

        // everytime this familiar is summoned alignment might shift
        SetLocalInt(oMaster, FAMILIAR_ALIGN_SHIFT, TRUE);
    }
    else if(nSpecial==2)
    {
        // PIXIE

        // Setup Pseudo Array of Bonus Feats to set on skin
        // number added to familiar skin. - length of Pseudo Array
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_COUNT, 3);
        // Pseudo Array begins at 1.
        //  we identify the index of the feat
        //  and at which level the familiar gains it
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"1", IPFEAT_FAMILIAR_CONFUSION);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"1", 1);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"2", IPFEAT_FAMILIAR_DISPEL_MAGIC);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"2", 1);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"3", IPFEAT_FAMILIAR_KNOCK);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"3", 1);
    }
    else if(nSpecial==3)
    {
        // HELL HOUND
        SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL_SKILL, SKILL_DISCIPLINE);
        SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL_ABILITY, ABILITY_CONSTITUTION);
        // Setup Pseudo Array of Bonus Feats to set on skin
        // number added to familiar skin. - length of Pseudo Array
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_COUNT, 1);
        // Pseudo Array begins at 1.
        //  we identify the index of the feat
        //  and at which level the familiar gains it
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"1", IPFEAT_FAMILIAR_HOUND_BREATH);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"1", 1);

    }
    else if(nSpecial==4)
    {
        // QUASIT

        // Setup Pseudo Array of Bonus Feats to set on skin
        // number added to familiar skin. - length of Pseudo Array
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_COUNT, 2);
        // Pseudo Array begins at 1.
        //  we identify the index of the feat
        //  and at which level the familiar gains it
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"1", IPFEAT_FAMILIAR_GAZE_FEAR);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"1", 1);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+"2", IPFEAT_FAMILIAR_INVISIBILITY);
        SetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+"2", 5);

        // everytime this familiar is summoned alignment might shift
        SetLocalInt(oMaster, FAMILIAR_ALIGN_SHIFT, TRUE);
    }

    return TRUE;
}

void FamiliarInitializeFlyAppearance(int nForm, int nFamIndex)
{
    string sFlying  = Get2DAString(FAMILIAR_2DA, "ALT_FLIER", nFamIndex);

    if(sFlying=="")
        return;
    else if( nForm==StringToInt(Get2DAString(FAMILIAR_2DA, "APPEARANCE", nFamIndex)) )
    {
        SetLocalInt(OBJECT_SELF, "ALT_WALKER", nForm);
        SetLocalInt(OBJECT_SELF, "ALT_FLIER", StringToInt(sFlying));
        return;
    }

    // otherwise need to set this manually
    // seagulls
    if(nForm==APPEARANCE_TYPE_SEAGULL_FLYING || nForm==APPEARANCE_TYPE_SEAGULL_WALKING)
    {
        SetLocalInt(OBJECT_SELF, "ALT_WALKER", APPEARANCE_TYPE_SEAGULL_WALKING);
        SetLocalInt(OBJECT_SELF, "ALT_FLIER", APPEARANCE_TYPE_SEAGULL_FLYING);
    }
}

int GetFamiliarIndex(object oCreature)
{
    int nFamIndex   = GetLocalInt(oCreature, FAMILIAR_INDEX);
    if(nFamIndex){return nFamIndex;}

    int nForm   = GetAppearanceType(oCreature);
    // these are creatures that are not flagged with a familiar index (or have index 0)
    // but are still appropriate targets of the Bind Familiar spell
    // ALL of the forms for familiars with index 0 must be specifically identified here
    // or else the Bind Familiar spell will fail on them
    // Alternatively if you do NOT want a specific creature to be a familiar
    // flag that creature with familiar type -1
    if(nForm==10)
        return 0;
    else if(nForm==2074)
       return 1;    // cat
    else if(nForm==176)
        return 2;   // dog
    else if(nForm==2090)
        return 3;   // snake
    else if(nForm==2079)
        return 4;   // rabbit
    else if(nForm==2083)
        return 5;   // frog
    else if(nForm==2085)
        return 6;  // weasel
    else if(nForm==2047 || nForm==2048)
        return 7;  // crow
    else if(    nForm==APPEARANCE_TYPE_SEAGULL_FLYING
            ||  nForm==APPEARANCE_TYPE_SEAGULL_WALKING
           )
        return 8;   // seagull
    else if(nForm==2086 || nForm==2087)
        return 9;  // lizard
    else if(nForm==2088 || nForm==2089)
        return 10;  // mouse
    else if(nForm==387)
        return 20;  // dire rat
    else if(nForm==740)
        return 21;  // parrot
    else if(nForm==183 || nForm==178 || nForm==194)
        return 22;  // viper
    else if(nForm==144)
        return 23;  // falcon
    else if(nForm==105)
        return 24;  // imp
    else if(nForm==375)
        return 25;  // pseudodragon
    else if(nForm==55)
        return 26;  // pixie
    else if(nForm==179)
        return 27;  // hell hound
    else if(nForm==202)
        return 28;  // panther
    else if(nForm==145)
        return 29;  // raven
    else if(nForm==104)
        return 30;  // quasit
    else if(nForm==912)
        return 31;  // owl

    return -1;
}

struct BENEFITS GetMasterBenefits(int nBenefitType, int bReceivedAlertness)
{
    struct BENEFITS Benefits;
    // special effects set as an integer in MASTER_BENEFITS column of ifamiliar.2da
    switch(nBenefitType)
    {
        case 0:
        break;
        case 1: // stealth
            // define effects
            Benefits.perk   = EffectLinkEffects(EffectSkillIncrease(SKILL_MOVE_SILENTLY, 2),
                                            EffectSkillIncrease(SKILL_HIDE, 2)
                                            );
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "a lighter step ("+PALEBLUE+"+2 move silently and hide"+DMBLUE+")";
        break;
        case 2: // search
            Benefits.perk    = EffectSkillIncrease(SKILL_SEARCH, 2);
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have become ";
            Benefits.description        += "better at finding things ("+PALEBLUE+"+2 search"+DMBLUE+")";
        break;
        case 3: // lucky
            Benefits.perk    = EffectSavingThrowIncrease(SAVING_THROW_ALL, 1);
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you are ";
            Benefits.description        += "luckier ("+PALEBLUE+"+1 saves"+DMBLUE+")";
        break;
        case 4: // tenacity
            Benefits.perk    = EffectLinkEffects(EffectSkillIncrease(SKILL_CONCENTRATION, 2),
                                            EffectSkillIncrease(SKILL_DISCIPLINE, 2)
                                            );
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "tenacity ("+PALEBLUE+"+2 concentration and discipline"+DMBLUE+")";
        break;
        case 5: // silver tongue
            Benefits.perk    = EffectLinkEffects(EffectSkillIncrease(SKILL_PERSUADE, 2),
                                            EffectSkillIncrease(SKILL_BLUFF, 2)
                                            );
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "a sharper tongue ("+PALEBLUE+"+2 bluff and persuade"+DMBLUE+")";
        break;
        case 6: // piercing gaze
            Benefits.perk    = EffectLinkEffects(EffectSkillIncrease(SKILL_INTIMIDATE, 2),
                                            EffectSkillIncrease(SKILL_SPOT, 4)
                                            );
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "a piercing gaze ("+PALEBLUE+"+2 intimidate and spot"+DMBLUE+")";
        break;
        case 7: // arcane insight
            Benefits.perk    = EffectLinkEffects(EffectSkillIncrease(SKILL_SPELLCRAFT, 2),
                                            EffectSkillIncrease(SKILL_LORE, 2)
                                            );
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you gain ";
            Benefits.description        += "arcane insight ("+PALEBLUE+"+2 spellcraft and lore"+DMBLUE+")";
        break;
        case 8: // intelligence
            Benefits.perk    = EffectAbilityIncrease(ABILITY_INTELLIGENCE, 2);
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "heightened intelligence ("+PALEBLUE+"+2 intelligence"+DMBLUE+")";
        break;
        case 9: // spell resistance
            Benefits.perk    = EffectSpellResistanceIncrease(18);
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "spell resistance ("+PALEBLUE+"18 SR"+DMBLUE+")";
        break;
        case 10: // see invisible
            Benefits.perk    = EffectSeeInvisible();
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you can ";
            Benefits.description        += "see invisible creatures ("+PALEBLUE+"see invisibility"+DMBLUE+")";
        break;
        case 11: // fire resistance
            Benefits.perk    = EffectDamageResistance(DAMAGE_TYPE_FIRE,8);
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you ";
            Benefits.description        += "resist fire ("+PALEBLUE+"DR 8 fire"+DMBLUE+")";
        break;
        case 12: // charisma
            Benefits.perk    = EffectAbilityIncrease(ABILITY_CHARISMA, 2);
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "more charisma ("+PALEBLUE+"+2 charisma"+DMBLUE+")";
        break;
        case 13: // peace
            Benefits.perk    = EffectLinkEffects(EffectSkillIncrease(SKILL_CONCENTRATION, 2),
                                            EffectSkillIncrease(SKILL_PERFORM, 2)
                                            );
            Benefits.perk    = EffectLinkEffects( EffectSkillIncrease(SKILL_SENSE_MOTIVE, 2),
                                                  Benefits.perk
                                            );
            if(bReceivedAlertness)
                Benefits.description    =" and ";
            else
                Benefits.description    =" you have ";
            Benefits.description        += "a sense of peace ("+PALEBLUE+"+2 concentration, persuade, and sense motive"+DMBLUE+")";
        break;
        default:
        break;
    }

    return Benefits;
}

void FamiliarSpawnEventCustom(object oMaster)
{
    // user additions

    // end user additions
}

// MASTER ......................................................................

void MasterInitializePets()
{

    MasterInitializeFamiliarData();
}

void MasterInitializeFamiliarData()
{
    int nFamType    = GetFamiliarCreatureType(OBJECT_SELF);
    if(     nFamType!=FAMILIAR_CREATURE_TYPE_NONE
        //&&  !GetSkinInt(OBJECT_SELF, FAMILIAR_DEAD)
      )
    {
        SetLocalInt(OBJECT_SELF, HAS_PET, TRUE);
        if(GetIsPC(OBJECT_SELF))
        {
            // familiar's form is stored persistently on the skin, but transferred to a local variable
            // this enables persistence for PCs but also allows a builder to customize an NPCs familiar
            int nForm       = GetSkinInt(OBJECT_SELF,FAMILIAR_FORM);

            // familiar's index (ifamiliar.2da) is stored persistently on the skin,
            // but transferred to a local variable for the same reason that form is
            // we assume that nForm of 0 (dwarf pc) is invalid
            // and we must check that nFamIndex of 0 is valid prior to setting it
            int nFamIndex   = GetSkinInt(OBJECT_SELF, FAMILIAR_INDEX);
            if( nForm>0
                &&( nFamIndex>0
                    ||(     nFamIndex==0
                        &&  nForm==StringToInt(Get2DAString(FAMILIAR_2DA,"APPEARANCE",nFamIndex))
                      )
                  )
              )
            {
                // Re-establish locals only. Familiar is valid.

                SetLocalInt(OBJECT_SELF, FAMILIAR_INDEX, nFamIndex);
                SetLocalInt(OBJECT_SELF, FAMILIAR_FORM, nForm );

                // Allowing a PC to change the familiar's name and description
                // will require a tool for recording text
                // but with this implementation I am not interested in creating such a tool
                //SetLocalString(OBJECT_SELF, FAMILIAR_NAME, GetSkinString(OBJECT_SELF,FAMILIAR_NAME) );
                //SetLocalString(OBJECT_SELF, FAMILIAR_DESCRIBE, GetSkinString(OBJECT_SELF,FAMILIAR_DESCRIBE) );

                // Alignment
                // Alignment is kept for certain special familiars
                // to indicate which see the ALIGNED column in ifamiliar
                // the alignment is taken from the creature that was bound
                // otherwise the alignment of the creature matches that of the master
                SetLocalInt(OBJECT_SELF, FAMILIAR_GOOD, GetSkinInt(OBJECT_SELF, FAMILIAR_GOOD) );
                SetLocalInt(OBJECT_SELF, FAMILIAR_LAW, GetSkinInt(OBJECT_SELF, FAMILIAR_LAW) );
            }
            else
            {

                // no valid familiar found on PC.
                // Set up persistent data
                nFamIndex   = nFamType;
                nForm       = StringToInt(Get2DAString(FAMILIAR_2DA,"APPEARANCE",nFamType));

                SetLocalInt(OBJECT_SELF, FAMILIAR_INDEX, nFamIndex );
                SetLocalInt(OBJECT_SELF, FAMILIAR_FORM, nForm );

                SetSkinInt(OBJECT_SELF, FAMILIAR_INDEX, nFamIndex );
                SetSkinInt(OBJECT_SELF, FAMILIAR_TYPE, nFamType);
                SetSkinInt(OBJECT_SELF, FAMILIAR_FORM, nForm );

                // Flag Spell Pool for replenishment
                SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL, SPELL_POOL_REPLENISH);

                // Initialize Alignment
                int nGood, nLaw;
                string sAlign   = GetStringUpperCase(Get2DAString(FAMILIAR_2DA,"ALIGNED", nFamIndex));
                if(sAlign=="LG")
                {
                    nGood   = 85;
                    nLaw    = 85;
                }
                else if(sAlign=="LE")
                {
                    nGood   = 15;
                    nLaw    = 85;
                }
                else if(sAlign=="LN")
                {
                    nGood   = 50;
                    nLaw    = 85;
                }
                else if(sAlign=="CG")
                {
                    nGood   = 85;
                    nLaw    = 15;
                }
                else if(sAlign=="CE")
                {
                    nGood   = 15;
                    nLaw    = 15;
                }
                else if(sAlign=="CN")
                {
                    nGood   = 50;
                    nLaw    = 15;
                }
                else if(sAlign=="NG")
                {
                    nGood   = 85;
                    nLaw    = 50;
                }
                else if(sAlign=="NE")
                {
                    nGood   = 15;
                    nLaw    = 50;
                }
                else if(sAlign=="N"||sAlign=="NN")
                {
                    nGood   = 50;
                    nLaw    = 50;
                }
                else
                {
                    // Use Master's alignment
                    nGood   = GetGoodEvilValue(OBJECT_SELF);
                    nLaw    = GetLawChaosValue(OBJECT_SELF);
                }
                // record Alignment
                SetLocalInt(OBJECT_SELF, FAMILIAR_GOOD, nGood);
                SetLocalInt(OBJECT_SELF, FAMILIAR_LAW, nLaw);
                SetSkinInt(OBJECT_SELF, FAMILIAR_GOOD, nGood);
                SetSkinInt(OBJECT_SELF, FAMILIAR_LAW, nLaw);
            }
        }
    }
}

void MasterWipeFamiliarData()
{

    DeleteSkinInt(OBJECT_SELF, FAMILIAR_INDEX);         // persistent index
    //DeleteSkinInt(OBJECT_SELF, FAMILIAR_TYPE);          // persistent type should only be changed at level up
    DeleteSkinInt(OBJECT_SELF, FAMILIAR_FORM);          // persistent appearance
    DeleteSkinString(OBJECT_SELF, FAMILIAR_NAME);       // persistent name
    DeleteSkinString(OBJECT_SELF, FAMILIAR_DESCRIBE);   // persistent description
    DeleteSkinInt(OBJECT_SELF, FAMILIAR_STICKY);        // unchangeable familiar
    // persistent record of original alignment
    DeleteSkinInt(OBJECT_SELF, FAMILIAR_GOOD);
    DeleteSkinInt(OBJECT_SELF, FAMILIAR_LAW);

    // We don't want to remove these values on an NPC
    if(GetIsPC(OBJECT_SELF))
    {
        DeleteLocalInt(OBJECT_SELF, FAMILIAR_INDEX);
        //DeleteLocalInt(OBJECT_SELF, FAMILIAR_TYPE);
        DeleteLocalInt(OBJECT_SELF, FAMILIAR_FORM);
        DeleteLocalInt(OBJECT_SELF, FAMILIAR_FEAT_COUNT);
        DeleteLocalInt(OBJECT_SELF, "FAMILIAR_NOT_SPECIAL");
        DeleteLocalString(OBJECT_SELF, FAMILIAR_NAME);
        DeleteLocalString(OBJECT_SELF, FAMILIAR_DESCRIBE);
        DeleteLocalInt(OBJECT_SELF, FAMILIAR_GOOD);
        DeleteLocalInt(OBJECT_SELF, FAMILIAR_LAW);
    }
}

void MasterHeartbeatEvent()
{
    if(GetLocalInt(OBJECT_SELF, HAS_PET))
    {
        // familiars are separated out because there is also the opportunity to add Animal Companions to this check
        if( GetLocalInt(OBJECT_SELF, FAMILIAR_SUMMONED) )
        {
            // Only one of the following should be used. See FamiliarSpawnEvent(object oMaster)
            //object oFamiliar    = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);// more_efficient_familiar
            object oFamiliar    = GetLocalObject(OBJECT_SELF, FAMILIAR);// more_flexible_familiar

            // if the familiar is invalid and yet indicates it is still summoned
            // we need to execute the despawn "event" which cleans up Master Benefits from a spawned familiar
            if(!GetIsObjectValid(oFamiliar))
                DoFamiliarDespawnEvent(OBJECT_SELF);
            // Rolo Kipp's Mounted Familiar VFX
            /*
            // if the familiar has been possessed, and yet still indicates a mounted VFX on master
            // we need to dismount the familiar (immediately)
            else if(    GetIsPossessedFamiliar(oFamiliar)
                    &&  GetLocalString(oFamiliar,"X2_SPECIAL_COMBAT_AI_SCRIPT")=="ccc_fam_dismt"
                   )
                DismountFamiliarVFX(OBJECT_SELF, TRUE);
            */
        }
    }
}

void MasterLevelUpEvent()
{
    int nFamType    = GetFamiliarCreatureType(OBJECT_SELF);
    if(nFamType!=FAMILIAR_CREATURE_TYPE_NONE)
    {
        // IDEA: perhaps if the familiar's name has changed this is a new familiar?

        int nLastFamType    = GetSkinInt(OBJECT_SELF, FAMILIAR_TYPE);
        if(     nFamType!=nLastFamType    // changed familiar type
            ||  GetSkinInt(OBJECT_SELF, FAMILIAR_DEAD)              // the familiar is dead so replace it
          )
        {

            DeleteSkinInt(OBJECT_SELF, FAMILIAR_DEAD);  // Familiar is alive again

            if(!GetSkinInt(OBJECT_SELF, FAMILIAR_STICKY)) // Familiar is not sticky SO change it
            {
                MasterWipeFamiliarData();       // Familiar is changed so wipe the data
                MasterInitializeFamiliarData();  // NEW FAMILIAR
            }
            /*
            else
            {
                // IDEA: notify Master that this familiar can not be changed?

            }
            */
        }

        DeleteSkinInt(OBJECT_SELF, FAMILIAR_HP);    // Familiar HP restored
        SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL, SPELL_POOL_REPLENISH); // Flag Familiar Spell Pool for replenishment
    }
}

void MasterRestEvent()
{
    if(GetLocalInt(OBJECT_SELF, HAS_PET))
    {
        // Default: Familiars are not restored to life at rest.
        // Only at level up or after master casts Bind Familiar on a replacement
        // if you want the familiar's life restored on rest, uncomment the line below
        //DeleteSkinInt(OBJECT_SELF, FAMILIAR_DEAD);

        // Persistent Damage cleared out - whether summoned or not
        // if still alive familiar will now spawn at max hp
        DeleteSkinInt(OBJECT_SELF, FAMILIAR_HP);

        // Flag Spell Pool for replenishment
        SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL, SPELL_POOL_REPLENISH);

        // Summoned Familiars will need Extraordinary Effects Restored etc...
        if(GetLocalInt(OBJECT_SELF, FAMILIAR_SUMMONED))
        {
            object oMaster  = OBJECT_SELF;
            AssignCommand(  // Only one of the following should be used. See FamiliarSpawnEvent(object oMaster)
                            //GetAssociate(ASSOCIATE_TYPE_FAMILIAR),// more_efficient_familiar
                            GetLocalObject(oMaster, FAMILIAR),      // more_flexible_familiar

                            DelayCommand(0.1, FamiliarRest(GetLocalInt(oMaster,FAMILIAR_INDEX)) )
                         );
        }
    }
}

void MasterExperiencedFamiliarDeath(string sFamName)
{
    SetSkinInt(OBJECT_SELF, FAMILIAR_DEAD, TRUE);
    DeleteSkinInt(OBJECT_SELF, FAMILIAR_HP);
    FloatingTextStringOnCreature(RED+"Your familiar, "+sFamName+", has died.", OBJECT_SELF, FALSE);

    // lose half of your current hitpoints, or at least 1 (which in rare circumstances can kill the PC)
    int nDam    = GetCurrentHitPoints(OBJECT_SELF)/2;
    if(nDam<1)
        nDam    = 1;

    ApplyEffectToObject(    DURATION_TYPE_PERMANENT,
                            EffectDamage(nDam),
                            OBJECT_SELF
                       );

    ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT);
}

void MasterSharesSpellWithFamiliar(int nSpellID, object oFamiliar, int nMeta, int nLevel)
{
    // These are made use of by ShaDoOoW's Community Patch 1.70
    // They give the spell script the proper level, DC, and metamagic feat
    // Without the community patch Spell Sharing spells appear to be cast at level 10
    SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE", nLevel );
    SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_METAMAGIC_OVERRIDE", nMeta);

    // Feedback
    SendMessageToPC(OBJECT_SELF, DMBLUE+"Spell sharing with "+GetName(oFamiliar)+".");
    // Cheat Cast Shared Spell
    ActionCastSpellAtObject(nSpellID, oFamiliar, nMeta, TRUE, nLevel, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    // Garbage Collection
    DelayCommand(1.5, ActionDoCommand(CasterClearsSpellOverrides()) );
}

// FAMILIAR ....................................................................

void FamiliarSpawnEvent(object oMaster)
{
    // these scripts run twice, but we only want this code to run the second time
    if(!GetLocalInt(oMaster,"FAMILIAR_EFFECTS_CAST"))
    {
        SetLocalInt(oMaster,"FAMILIAR_EFFECTS_CAST",TRUE);
    }
    else
    {
        DeleteLocalInt(oMaster,"FAMILIAR_EFFECTS_CAST");

        // STORE POINTERS for retrieval regardless of associate type or if possessed
        // TESTING used during possession since we assume GetMaster will fail
        SetLocalObject(OBJECT_SELF, "MASTER", oMaster);
        // pointer to familiar, even when technically it is a "henchman"
        // if you never plan to convert familiars to henchmen, you can remove this to improve efficiency
        // you will also need to change several lines of code
        // search all scripts for more_efficient_familiar
        // to locate the code that needs to be reestablished
        SetLocalObject(oMaster, FAMILIAR, OBJECT_SELF);
        // self ID as a familiar - a contingency
        SetLocalInt(OBJECT_SELF, "IS_FAMILIAR", TRUE);

        // Special Familiar Data
        if( FamiliarInitializeSpecialData(oMaster)==FALSE )
            return; // provides option to short circuit the rest of spawn

        int nFamType    = GetFamiliarCreatureType(OBJECT_SELF); // familiar chosen at levelup/character creation
        int nFamIndex   = GetLocalInt(oMaster, FAMILIAR_INDEX); // index to ifamiliar.2da. this identifies the familiar type

        // Name and Description ----------------------------------------
        string sAltName = GetLocalString(oMaster, FAMILIAR_NAME);
        if(sAltName!="")
            SetName(OBJECT_SELF, sAltName);
        string sAltDesc = GetLocalString(oMaster, FAMILIAR_DESCRIBE);
        if(sAltDesc!="")
            SetDescription(OBJECT_SELF, sAltDesc);

        // Appearance --------------------------------------------------
        int nAltForm    = GetLocalInt(oMaster, FAMILIAR_FORM);
        SetCreatureAppearanceType(OBJECT_SELF, nAltForm);

        // Portrait ----------------------------------------------------
        SetPortraitId(OBJECT_SELF, GetFamiliarPortraitId(nFamIndex));

        // Soundset ----------------------------------------------------
        int nSoundset   = StringToInt(Get2DAString(FAMILIAR_2DA,"SOUNDSET",nFamIndex));
        if(nSoundset) 
            NWNX_SetSoundset(OBJECT_SELF, nSoundset);

        // Fly/Walk alternate appearances ------------------------------
        FamiliarInitializeFlyAppearance(nAltForm, nFamIndex);

        // Alignment ---------------------------------------------------
        FamiliarAlignment(oMaster, nFamIndex);

        // Familiar's Creature Items = CLAWS, BITE, HIDE ---------------
        FamiliarEquipItems(nFamIndex);

        // Bonuses to Skills and Spell Resistance etc... added to Creature Hide
        FamiliarLevelUp(nFamIndex);

        // Spell Pool ----------------------------------------------------------
        if(GetLocalInt(oMaster, FAMILIAR_SPELL_POOL)==SPELL_POOL_REPLENISH)
            ActionDoCommand( FamiliarReplenishSpellPool(oMaster) );

        // Persistent HP -----------------------------------------------
        ActionDoCommand( FamiliarStartingHitPoints(GetSkinInt(oMaster,FAMILIAR_HP)) );

        // Master Casts familiar effects on master ---------------------
        AssignCommand(  oMaster,
                        ActionCastSpellAtObject(SPELL_FAMILIAR_EFFECTS, oMaster, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)
                     );

        // Custom Spawn Event
        FamiliarSpawnEventCustom(oMaster);
    }
}

object FamiliarInventory(string sWeapon, string sType)
{
    object oItem = GetLocalObject(OBJECT_SELF,"ITEM_"+sType);
    if(oItem!=OBJECT_INVALID)
        return oItem;

    string sRef,sHD;
    int nHD     = GetHitDice(OBJECT_SELF);
    int nX;
    if(FindSubString(sWeapon, FAMILIAR_EQUIP_DEFAULT)!=-1)
        sRef    = sWeapon;
    else
    {
        nX          = nHD;
        sHD         = IntToString(nX);
        if(nX<10)
            sHD     = "0"+sHD;
        sRef        = sWeapon+sHD;
    }

    oItem   = CreateItemOnObject(sRef);
    while(oItem==OBJECT_INVALID)
    {
        --nX;
        if(nX<0)
            break;
        else
        {
                sHD         = IntToString(nX);
                if(nX<10)
                    sHD     = "0"+sHD;
                sRef        = sWeapon+sHD;
        }
        oItem   = CreateItemOnObject(sRef);
    }

    SetLocalObject(OBJECT_SELF,"ITEM_"+sType,oItem);
    return oItem;
}

void FamiliarEquipItems(int nFamIndex)
{
    object oItem;

    string sHide    = Get2DAString(FAMILIAR_2DA,"REF_HIDE",nFamIndex);
    if( sHide!="" )
    {
        oItem       = FamiliarInventory(sHide, "REF_HIDE");

        if(oItem!=OBJECT_INVALID)
        {
            SetLocalObject(OBJECT_SELF, "oX3_Skin", oItem);
            SetLocalObject(OBJECT_SELF, "oX3_VariableHolder", oItem);
            ActionEquipItem(oItem,INVENTORY_SLOT_CARMOUR);
        }
    }

    string sClaw1   = Get2DAString(FAMILIAR_2DA,"REF_CLAW1",nFamIndex);
    if( sClaw1!="" )
    {
        oItem       = FamiliarInventory(sClaw1, "REF_CLAW1");

        if(oItem!=OBJECT_INVALID)
            ActionEquipItem(oItem,INVENTORY_SLOT_CWEAPON_L);
    }

    string sClaw2   = Get2DAString(FAMILIAR_2DA,"REF_CLAW2",nFamIndex);
    if( sClaw2!="" )
    {
        oItem       = FamiliarInventory(sClaw2, "REF_CLAW2");

        if(oItem!=OBJECT_INVALID)
            ActionEquipItem(oItem,INVENTORY_SLOT_CWEAPON_R);

    }

    string sBite    = Get2DAString(FAMILIAR_2DA,"REF_BITE",nFamIndex);
    if( sBite!="" )
    {
        oItem       = FamiliarInventory(sBite, "REF_BITE");

        if(oItem!=OBJECT_INVALID)
            ActionEquipItem(oItem,INVENTORY_SLOT_CWEAPON_B);
    }
}

void FamiliarLevelUp(int nFamIndex)
{
    object oHide    = GetLocalObject(OBJECT_SELF, "oX3_Skin");
    if(oHide!=GetItemInSlot(INVENTORY_SLOT_CARMOUR))
    {
        DelayCommand( 0.1, FamiliarLevelUp(nFamIndex) );
        return;
    }

    int nHD     = GetHitDice(OBJECT_SELF);

    // ABILITIES ---------------------------------------------------------------
    int B_ABILITY   = StringToInt(Get2DAString(FAMILIAR_2DA,"ABILITY_IMPROVE",nFamIndex));
    int BONUS       = nHD/4;

    int BASE_STR    = StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_STR",nFamIndex));
    if(B_ABILITY==ABILITY_STRENGTH){BASE_STR+=BONUS;}
    NWNX_SetAbilityScore (OBJECT_SELF, ABILITY_STRENGTH, BASE_STR);

    int BASE_DEX    = StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_DEX",nFamIndex));
    if(B_ABILITY==ABILITY_DEXTERITY){BASE_DEX+=BONUS;}
    NWNX_SetAbilityScore (OBJECT_SELF, ABILITY_DEXTERITY, BASE_DEX);

    int BASE_CON    = StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_CON",nFamIndex));
    if(B_ABILITY==ABILITY_CONSTITUTION){BASE_CON+=BONUS;}
    NWNX_SetAbilityScore (OBJECT_SELF, ABILITY_CONSTITUTION, BASE_CON);
    // intelligence is a special case because all familiars advance in intelligence
    int BASE_INT    = StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_INT",nFamIndex));
    int STD_INT     = FloatToInt( (IntToFloat(nHD)/2.0f)+0.5f )+5;
    if(STD_INT>BASE_INT)
        BASE_INT    = STD_INT;
    if(B_ABILITY==ABILITY_INTELLIGENCE){BASE_INT+=BONUS;}
    NWNX_SetAbilityScore (OBJECT_SELF, ABILITY_INTELLIGENCE, BASE_INT);

    int BASE_WIS    = StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_WIS",nFamIndex));
    if(B_ABILITY==ABILITY_WISDOM){BASE_WIS+=BONUS;}
    NWNX_SetAbilityScore (OBJECT_SELF, ABILITY_WISDOM, BASE_WIS);

    int BASE_CHA    = StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_CHA",nFamIndex));
    if(B_ABILITY==ABILITY_CHARISMA){BASE_CHA+=BONUS;}
    NWNX_SetAbilityScore (OBJECT_SELF, ABILITY_CHARISMA, BASE_CHA);

    // MAX HITPOINTS -----------------------------------------------------------
    int nHP_per_level   = StringToInt(Get2DAString(FAMILIAR_2DA,"HP_PER_LEVEL",nFamIndex));

    if(!nHP_per_level)
        nHP_per_level   = 4;

    NWNX_SetMaxHitPoints (OBJECT_SELF, nHP_per_level*nHD);

    // BONUS FEATS -------------------------------------------------------------
    int nBonusFeats   = GetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_COUNT);
    if(nBonusFeats)
    {
        int x; string sX;
        for(x=1; x<=nBonusFeats; x++)
        {
            sX  = IntToString(x);
            if(GetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_LEVEL+sX)<=nHD)
                IPSafeAddItemProperty( oHide, ItemPropertyBonusFeat(GetLocalInt(OBJECT_SELF, FAMILIAR_FEAT_INDEX+sX)) );
        }
    }

    // NATURALARMOR ------------------------------------------------------------
    FamiliarNaturalArmor(nFamIndex);

    // SPELLRESISTANCE ---------------------------------------------------------
    FamiliarSpellResistance(nFamIndex);

    // SKILLS ------------------------------------------------------------------

    // SKILL_SPOT --------------------------------
    FamiliarSkill(  SKILL_SPOT,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_SPOT",nFamIndex)),oHide
                  );
    // SKILL_LISTEN ------------------------------
    FamiliarSkill(  SKILL_LISTEN,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_LISTEN",nFamIndex)),oHide
                  );
    // SKILL_SEARCH ------------------------------
    FamiliarSkill(  SKILL_SEARCH,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_SEARCH",nFamIndex)),oHide
                  );
    // SKILL_HIDE --------------------------------
    FamiliarSkill(  SKILL_HIDE,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_HIDE",nFamIndex)),oHide
                  );
    // SKILL_MOVE -----------------------
    FamiliarSkill(  SKILL_MOVE_SILENTLY,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_MOVE",nFamIndex)),oHide
                  );
    // SKILL_TUMBLE ------------------------------
    FamiliarSkill(  SKILL_TUMBLE,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_TUMBLE",nFamIndex)),oHide
                  );
    // SKILL_DISCIPLINE -------------------------------
    FamiliarSkill(  SKILL_DISCIPLINE,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_DISCIPLINE",nFamIndex)),oHide
                  );
    // SKILL_TAUNT -------------------------------
    FamiliarSkill(  SKILL_TAUNT,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_TAUNT",nFamIndex)),oHide
                  );
    // SKILL_PARRY -------------------------------
    FamiliarSkill(  SKILL_PARRY,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_PARRY",nFamIndex)),oHide
                  );
    // SKILL_DISABLETRAP -------------------------------
    FamiliarSkill(  SKILL_DISABLE_TRAP,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_DISABLETRAP",nFamIndex)),oHide
                  );
    // SKILL_OPENLOCK -------------------------------
    FamiliarSkill(  SKILL_OPEN_LOCK,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_OPENLOCK",nFamIndex)),oHide
                  );
    // SKILL_PICKPOCKET -------------------------------
    FamiliarSkill(  SKILL_PICK_POCKET,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_PICKPOCKET",nFamIndex)),oHide
                  );

    // SKILL_CONCENTRATION -------------------------------
    FamiliarSkill(  SKILL_CONCENTRATION,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_CONCENTRATION",nFamIndex)),oHide
                  );
    // SKILL_SPELLCRAFT -------------------------------
    FamiliarSkill(  SKILL_SPELLCRAFT,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_SPELLCRAFT",nFamIndex)),oHide
                  );
    // SKILL_LORE -------------------------------
    FamiliarSkill(  SKILL_LORE,nHD,
                    StringToInt(Get2DAString(FAMILIAR_2DA,"SKILL_LORE",nFamIndex)),oHide
                  );
}

void FamiliarSkill(int SKILL_INDEX, int nfamiliar_HD, int nSkillBonus, object oHide)
{
    if(nSkillBonus && nSkillBonus<=nfamiliar_HD)
    {

        if(nSkillBonus==1)
            nSkillBonus  = 3 + nfamiliar_HD;
        else
            nSkillBonus  = (nfamiliar_HD-nSkillBonus)+1;

        NWNX_ModifySkillRank(OBJECT_SELF, SKILL_INDEX, nSkillBonus);
    }
}

void FamiliarNaturalArmor(int nFamIndex)
{
    int nHD     = GetHitDice(OBJECT_SELF);
    int nNACBase= StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_NATURALARMOR",nFamIndex));
    int STD_NAC = FloatToInt( (IntToFloat(nHD)/2.0f)+0.5f );

    int nNACBonus   = nNACBase + STD_NAC;

    NWNX_SetACNaturalBase(OBJECT_SELF, nNACBonus);
}

void FamiliarSpellResistance(int nFamIndex)
{
    int nHD     = GetHitDice(OBJECT_SELF);
    int nSR_Base= StringToInt(Get2DAString(FAMILIAR_2DA,"BASE_SPELLRESISTANCE",nFamIndex));
    if(nSR_Base || nHD>=5)
    {
        int nSR     = 10 + (nHD-5);
        if(nSR<nSR_Base)
            nSR = nSR_Base;
        effect eSR  = ExtraordinaryEffect(EffectSpellResistanceIncrease(nSR)); // removed by resting
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSR, OBJECT_SELF);
    }
}

void FamiliarRest(int nFamIndex)
{
    // Remove Stored Spells
    // Uncomment the line below to remove stored Master's Spells on rest
    // RemoveMasterSpellsFromFamiliarHide( GetItemInSlot(INVENTORY_SLOT_CARMOUR), GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_PROPERTY") );

    // Replenish Spell Pool
    FamiliarReplenishSpellPool(GetMaster());

    // Restore Spell Resistance
    FamiliarSpellResistance(nFamIndex);
}

void FamiliarTrackHitPoints(object oMaster)
{
    SetSkinInt(oMaster, FAMILIAR_HP, (GetMaxHitPoints()-GetCurrentHitPoints()) );
}

void FamiliarStartingHitPoints(int nDamage)
{
    NWNX_SetCurrentHitPoints(OBJECT_SELF, GetMaxHitPoints()-nDamage);
}

void FamiliarDeathEvent(object oMaster)
{
    // if wizard is possessing their familiar...wizard loses half their hitpoints
    if(GetIsPossessedFamiliar(OBJECT_SELF))
    {
        string sFamName = GetName(OBJECT_SELF);
        AssignCommand(oMaster, MasterExperiencedFamiliarDeath(sFamName) );
    }
    else
    {
        SetSkinInt(oMaster, FAMILIAR_DEAD, TRUE);
        DeleteSkinInt(oMaster, FAMILIAR_HP);

        FloatingTextStringOnCreature(RED+"Your familiar, "+GetName(OBJECT_SELF)+", has died.", oMaster, FALSE);
    }
    DoFamiliarDespawnEvent(oMaster);
}

void FamiliarAlignment(object oMaster, int nFamIndex)
{
    int nGood, nLaw;
    //int nAligned    = StringToInt(Get2DAString(FAMILIAR_2DA,"ALIGNED", nFamIndex));

    nGood       = GetLocalInt(oMaster, FAMILIAR_GOOD)-50;
    nLaw        = GetLocalInt(oMaster, FAMILIAR_LAW)-50;

    if(nGood>0)
        AdjustAlignment(OBJECT_SELF, ALIGNMENT_GOOD, nGood, FALSE);
    else if(nGood<0)
        AdjustAlignment(OBJECT_SELF, ALIGNMENT_EVIL, abs(nGood), FALSE);
    if(nLaw>0)
        AdjustAlignment(OBJECT_SELF, ALIGNMENT_LAWFUL, nLaw, FALSE);
    else if(nLaw<0)
        AdjustAlignment(OBJECT_SELF, ALIGNMENT_CHAOTIC, abs(nLaw), FALSE);
}

void FamiliarHeartbeatEvent(object oMaster, int nAction, float fDistToMaster, float fDistFollow)
{
    // enter sealth mode?
    if( GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) )
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
    else if( GetStealthMode(oMaster)==STEALTH_MODE_ACTIVATED )
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
    else
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);

    // enter search mode?
    if( GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH) )
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
    else if( GetDetectMode(oMaster)==DETECT_MODE_ACTIVE )
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
    else
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);

    // Appearance switching for fly/walk forms - Seagulls etc...
    int nFlier      = GetLocalInt(OBJECT_SELF, "ALT_FLIER");
    int nWalker     = GetLocalInt(OBJECT_SELF, "ALT_WALKER");
    int nForm       = GetAppearanceType(OBJECT_SELF);

    if(     nFlier>0 && nFlier==nForm  // Flying Bird?
        &&  nAction !=ACTION_ATTACKOBJECT
        &&  fDistToMaster <= fDistFollow
      )
    {
        int nIdle   = GetLocalInt(OBJECT_SELF, "IDLE_COUNT")+1;
        SetLocalInt(OBJECT_SELF, "IDLE_COUNT", nIdle);
        // if we've been hovering for 3 HBs, start walking
        if(nIdle>2)
        {
            SetCreatureAppearanceType(OBJECT_SELF, nWalker);
            DeleteLocalInt(OBJECT_SELF, "IDLE_COUNT");
        }
    }
    else if(    nWalker>0 && nWalker==nForm  // Walking Bird?
            &&  !GetAssociateState(NW_ASC_MODE_STAND_GROUND)
            &&  nAction == ACTION_FOLLOW
            &&  fDistToMaster >= fDistFollow
           )
    {
        SetCreatureAppearanceType(OBJECT_SELF, nFlier);
        DeleteLocalInt(OBJECT_SELF, "IDLE_COUNT");
    }
}

int FamiliarGetMaxSpellPool()
{
    int nSkill          = GetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL_SKILL);
    int nAbility        = GetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL_ABILITY);
    int nSpellSkill, nSpellAbility;

    if(nSkill==FAMILIAR_SPELL_POOL_DEFAULT)
        nSpellSkill     = GetSkillRank(SKILL_SPELLCRAFT, OBJECT_SELF);
    else
        nSpellSkill     = GetSkillRank(nSkill, OBJECT_SELF);
    if(nAbility==FAMILIAR_SPELL_POOL_DEFAULT)
        nSpellAbility   = GetAbilityModifier(ABILITY_CHARISMA, OBJECT_SELF);
    else
        nSpellAbility   = GetAbilityModifier(nAbility, OBJECT_SELF);

    if(nSpellAbility<1 && nSpellSkill<1)
        return 1;
    else if(nSpellSkill<nSpellAbility)
        return nSpellAbility;
    else
        return nSpellSkill;
}

void FamiliarReplenishSpellPool(object oMaster)
{
    SetLocalInt(oMaster, FAMILIAR_SPELL_POOL, FamiliarGetMaxSpellPool());
}

void FamiliarDisplaySpellPool(int nPool=-99)
{
    int nRemaining;

    if(nPool!=-99)
        nRemaining  = nPool;
    else
        nRemaining  = GetLocalInt(GetMaster(), FAMILIAR_SPELL_POOL);

    if(nRemaining>1000)
    {
        FamiliarReplenishSpellPool(GetMaster());
        nRemaining  = GetLocalInt(GetMaster(), FAMILIAR_SPELL_POOL);
    }

    if(nRemaining<0)
        // spell Pool over drawn
        SendMessageToPC(OBJECT_SELF, RED+GetName(OBJECT_SELF)+"'s spell pool is insufficient to cast that spell!");
    else if(nRemaining==0)
        // spell Pool exhausted
        SendMessageToPC(OBJECT_SELF, PINK+GetName(OBJECT_SELF)+"'s spell pool is exhausted!");
    else if(nRemaining==1)
        // spell Pool nearly exhausted
        SendMessageToPC(OBJECT_SELF, PINK+GetName(OBJECT_SELF)+"'s spell pool is nearly empty.");
    else
        // spell Pool Count
        SendMessageToPC(OBJECT_SELF, DMBLUE+GetName(OBJECT_SELF)+" has "+PALEBLUE+IntToString(nRemaining)+DMBLUE+" spell points remaining in their pool.");
}

// .............................................................................

void DoFamiliarDespawnEvent(object oMaster)
{
    DeleteLocalInt(oMaster, FAMILIAR_SUMMONED);
    DeleteLocalObject(oMaster, FAMILIAR); // comment this out if you have switched to a more_efficient_familiar
    effect eEffect = GetFirstEffect(oMaster);
    while(GetIsEffectValid(eEffect))
    {
        if(GetEffectSpellId(eEffect)==SPELL_FAMILIAR_EFFECTS)
        {
            RemoveEffect(oMaster, eEffect);
        }

        eEffect = GetNextEffect(oMaster);
    }

    // Rolo Kipp's Mounted Familiar VFX
    //DismountFamiliarVFX(OBJECT_SELF, TRUE);
}

void RemoveMasterSpellsFromFamiliarHide(object oHide, int nIPFeatProp=0, object oFamiliar=OBJECT_SELF)
{
  if(nIPFeatProp)
  {
    itemproperty ip = GetFirstItemProperty(oHide);
    while(GetIsItemPropertyValid(ip))
    {
        if(     GetItemPropertyType(ip)==ITEM_PROPERTY_BONUS_FEAT
            &&  GetItemPropertySubType(ip)==nIPFeatProp
          )
            RemoveItemProperty(oHide, ip);

        ip = GetNextItemProperty(oHide);
    }
  }
  else
  {
    itemproperty ip = GetFirstItemProperty(oHide);
    while(GetIsItemPropertyValid(ip))
    {
        if( GetItemPropertyType(ip)==ITEM_PROPERTY_BONUS_FEAT )
        {
            int nip = GetItemPropertySubType(ip);
            if(     nip>=IPFEAT_FAMILIAR_SPELL_TOUCH
                &&  nip<=IPFEAT_FAMILIAR_SPELL_LONG
              )
                RemoveItemProperty(oHide, ip);
        }

        ip = GetNextItemProperty(oHide);
    }
  }

    // Garbage Collection
    SetLocalInt(oFamiliar, "FAMILIAR_SPELL_ID", -1);
    SetLocalInt(oFamiliar, "FAMILIAR_SPELL_META", METAMAGIC_NONE);
    DeleteLocalInt(oFamiliar, "FAMILIAR_SPELL_PROPERTY");
    DeleteLocalInt(oFamiliar, "FAMILIAR_SPELL_LEVEL");
    DeleteLocalInt(oFamiliar, "FAMILIAR_SPELL_DC");
    // Used By Community Patch
    DeleteLocalInt(oFamiliar, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE");
    DeleteLocalInt(oFamiliar, "SPECIAL_ABILITY_DC_OVERRIDE");
    DeleteLocalInt(oFamiliar, "SPECIAL_ABILITY_METAMAGIC_OVERRIDE");
}

int GetIsCompatibleFamiliar(object oCreature, object oPC)
{
    if(oCreature==oPC)
        return TRUE;

    int nMasterType = GetFamiliarCreatureType(oPC);
    if(nMasterType==FAMILIAR_CREATURE_TYPE_NONE)
        return FALSE;

    int nFamIndex;

    // all other familiars are incompatible until the master gets rid of their current familiar
    if(GetSkinInt(oPC, FAMILIAR_STICKY))
        return FALSE;

    string sFamType = Get2DAString(FAMILIAR_2DA,"HEN_FAMILIAR",nFamIndex);

    // are we restricting familiar types to specific groups?
    if(FAMILIARS_RESTRICTED_BY_TYPE)
    {
        if(sFamType=="")
            return TRUE; // special familiars are always compatible
        if(nMasterType==StringToInt(sFamType))
            return TRUE;
    }
    // This module does not have restrictions
    else
        return TRUE;

    return FALSE;
}

int GetFamiliarPortraitId(int nFamIndex)
{
    string sPortrait   = Get2DAString(FAMILIAR_2DA,"PORTRAITS",nFamIndex);
    int nPortrait;
    if(sPortrait=="")
        nPortrait   = FAMILIAR_PORTRAIT_GENERIC;
    else
        nPortrait   = StringToInt(sPortrait);

    return nPortrait;
}

//void main(){}
