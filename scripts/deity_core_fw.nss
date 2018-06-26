///////////////////////////////////////////////////////////////////////////////
// deity_core_fw.nss
//
// Created by: The Krit
// Date: 2/24/07
///////////////////////////////////////////////////////////////////////////////
//
// Core definitions for favored weapon features.
// Modify this file at your own risk!
//
// (If you don't know what you're doing, don't modify this file.)
// (If you don't want the favored weapon features enabled, don't call
// DeityWeaponsPostLevel() and don't set a deity's weapon with the
// bPropogate parameter set to TRUE.)
//
///////////////////////////////////////////////////////////////////////////////

#include "_inc_nwnx"
// Configuration settings and core defs.
#include "deity_configure"
#include "deity_core_defs"


// BioWare's "INVLAID" constant is not so good, so...
const int BASE_ITEM_NONE = -1;
// Not really a base item, but this makes the scripts easier to read.
const int BASE_ITEM_UNARMED = -2;


// List of constants for use with DeitySetWeapon().
// (Equivalent to item property subtypes, c.f IP_CONST_FEAT_*.)
const int WEAPON_BASTARDSWORD   =  63;
const int WEAPON_BATTLEAXE      =  64;
const int WEAPON_CLUB           =  65;
const int WEAPON_DAGGER         =  66;
const int WEAPON_DART           =  67;
const int WEAPON_DIREMACE       =  68;
const int WEAPON_DOUBLEAXE      =  69;
const int WEAPON_DWARVENWARAXE  =  70;
const int WEAPON_GREATAXE       =  71;
const int WEAPON_GREATSWORD     =  72;
const int WEAPON_HALBERD        =  73;
const int WEAPON_HANDAXE        =  74;
const int WEAPON_HEAVYCROSSBOW  =  75;
const int WEAPON_HEAVYFLAIL     =  76;
const int WEAPON_KAMA           =  77;
const int WEAPON_KATANA         =  78;
const int WEAPON_KUKRI          =  79;
const int WEAPON_LIGHTCROSSBOW  =  80;
const int WEAPON_LIGHTFLAIL     =  81;
const int WEAPON_LIGHTHAMMER    =  82;
const int WEAPON_MACE           =  83; // a.k.a. light mace
const int WEAPON_LONGBOW        =  84;
const int WEAPON_LONGSWORD      =  85;
const int WEAPON_MAGICSTAFF     =  86;
const int WEAPON_MORNINGSTAR    =  87;
const int WEAPON_QUARTERSTAFF   =  88;
const int WEAPON_RAPIER         =  89;
const int WEAPON_SCIMITAR       =  90;
const int WEAPON_SCYTHE         =  91;
const int WEAPON_SHORTBOW       =  92;
const int WEAPON_SPEAR          =  93; // a.k.a. short spear
const int WEAPON_SHORTSWORD     =  94;
const int WEAPON_SHURIKEN       =  95;
const int WEAPON_SICKLE         =  96;
const int WEAPON_SLING          =  97;
const int WEAPON_THROWINGAXE    =  98;
const int WEAPON_TRIDENT        =  99;
const int WEAPON_TWOBLADEDSWORD = 100;
const int WEAPON_UNARMEDSTRIKE  = 101; const int WEAPON_UNARMED = 101; // alias.
const int WEAPON_WARHAMMER      = 102;
const int WEAPON_WHIP           = 103;
// CEP weapons:
const int WEAPON_DOUBLESCIMITAR = 104;
const int WEAPON_FALCHION       = 105;
const int WEAPON_GOAD           = 106;
const int WEAPON_HEAVYMACE      = 107;
const int WEAPON_HEAVYPICK      = 108;
const int WEAPON_KATAR          = 109;
const int WEAPON_LIGHTPICK      = 110;
const int WEAPON_MAUL           = 111;
const int WEAPON_NUNCHAKU       = 112;
const int WEAPON_SAI            = 113;
const int WEAPON_SAP            = 114;
const int WEAPON_WINDFIREWHEEL  = 115;

// To aid processing of the favored weapon feats:
const int WEAPON_FIRST =  63;
const int WEAPON_LAST  = 115;


// CEP base items (weapons).
// Renamed to avoid name conflicts if zep_inc_main is also included somewhere.

const int BASE_ITEM_CEP_TINYSPEAR           = 210;
const int BASE_ITEM_CEP_TRIDENT_1H          = 300;
const int BASE_ITEM_CEP_HEAVYPICK           = 301;
const int BASE_ITEM_CEP_LIGHTPICK           = 302;
const int BASE_ITEM_CEP_SAI                 = 303;
const int BASE_ITEM_CEP_NUNCHAKU            = 304;
const int BASE_ITEM_CEP_FALCHION1           = 305;
const int BASE_ITEM_CEP_SAP                 = 308;
const int BASE_ITEM_CEP_DAGGERASSASSIN      = 309;
const int BASE_ITEM_CEP_KATAR               = 310;
const int BASE_ITEM_CEP_LIGHTMACE2          = 312;
const int BASE_ITEM_CEP_KUKRI2              = 313;
const int BASE_ITEM_CEP_FALCHION2           = 316;
const int BASE_ITEM_CEP_HEAVYMACE           = 317;
const int BASE_ITEM_CEP_MAUL                = 318;
const int BASE_ITEM_CEP_MERCURIALLONGSWORD  = 319;
const int BASE_ITEM_CEP_MERCURIALGREATSWORD = 320;
const int BASE_ITEM_CEP_DOUBLESCIMITAR      = 321;
const int BASE_ITEM_CEP_GOAD                = 322;
const int BASE_ITEM_CEP_WINDFIREWHEEL       = 323;
const int BASE_ITEM_CEP_MAUGDOUBLESWORD     = 324;
//const int BASE_ITEM_CEP_LONGSWORD2          = 330;


// The names of PC local variables used to track favored weapons.
const string FAVOREDWEAPON_COUNT = "TK_DEITY_FW_COUNT";
const string FAVOREDWEAPON_ENTRY = "TK_DEITY_FW_ENTRY_";
const string FAVOREDWEAPON_STATUS = "TK_DEITY_FW_STATUS";
// Function to make a campaign variable name.
string FW_CampaignStatus(object oPC);
string FW_CampaignStatus(object oPC)
  { return GetStringLeft("FW_STATUS_" + GetName(oPC) + "_" + GetPCPlayerName(oPC), 32); }



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Initializes the feats and variables for the favored weapon implementation.
void DeityWeaponsInit(object oPC, int nDeity);

// Returns TRUE if oWeapon counts as a favored weapon for oPC.
// OBJECT_INVALID matches unarmed when bOffHand is FALSE.
int IsDeityWeapon(object oPC, object oWeapon, int bOffHand = FALSE);

// Removes the favored weapon properties from oPC, assuming nStatus indicates
// the current properties.
// (A positive status indicates bonuses; negative, penalties.)
void ClearDeityWeaponStatus(object oPC, int nStatus);

// Applies favored weapon bonuses to oPC, as if oPC is level nLevel.
void SetDeityWeaponBonus(object oPC, int nLevel);

// Applies favored weapon penalties to oPC, as if oPC is level nLevel.
void SetDeityWeaponPenalty(object oPC, int nLevel);

// Returns a base item (BASE_ITEM_*) associated with a favored weapon constant.
// Returns BASE_ITEM_NONE when input values are out of range.
//
// nFeat must be a WEAPON_* constant.
// nIndex is an index into the list of base items (starts at 0).
//
// Most weapons have only one base item.
int GetFavWeapFromFeatIP(int nWeapon, int nIndex);


///////////////////////////////////////////////////////////////////////////////
// UTILITY PROTOTYPES:

// Removes the first item property from oItem that matches the indicated
// type and cost.
void RemoveItemPropertyByTypeAndCost(object oItem, int nType, int nCost);

// Removes the first item property from oItem that matches the indicated
// type, subtype, and cost.
void RemoveItemPropertyBySubtypeAndCost(object oItem, int nType, int nSubtype, int nCost);



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// DeityWeaponsInit()
//
// Initializes the feats and variables for the favored weapon implementation.
//
void DeityWeaponsInit(object oPC, int nDeity)
{
    // Get the deity's favored weapons.
    int nFirstWeapon = GetDeityWeapon(nDeity);
    int nSecondWeapon = GetDeityWeaponAlternate(nDeity);
    int nBaseItem = BASE_ITEM_NONE;

    // Record the base items associated with the first favored weapon.
    int nFirstBaseItemCount = 0;
    nBaseItem = GetFavWeapFromFeatIP(nFirstWeapon, 0);
    while ( nBaseItem != BASE_ITEM_NONE )
    {
        SetLocalInt(oPC, FAVOREDWEAPON_ENTRY + IntToHexString(nFirstBaseItemCount), nBaseItem);
        nBaseItem = GetFavWeapFromFeatIP(nFirstWeapon, ++nFirstBaseItemCount);
    }

    // Record the base items associated with the second favored weapon.
    int nSecondBaseItemCount = 0;
    nBaseItem = GetFavWeapFromFeatIP(nSecondWeapon, 0);
    while ( nBaseItem != BASE_ITEM_NONE )
    {
        SetLocalInt(oPC, FAVOREDWEAPON_ENTRY + IntToHexString(nSecondBaseItemCount + nFirstBaseItemCount), nBaseItem);
        nBaseItem = GetFavWeapFromFeatIP(nSecondWeapon, ++nSecondBaseItemCount);
    }

    // Record the total number of base items.
    SetLocalInt(oPC, FAVOREDWEAPON_COUNT, nFirstBaseItemCount + nSecondBaseItemCount);


    /* Skipping this check - not planning to have it change 
    // Get oPC's hide.
    object oHide = GetSkin(oPC);

    // Make sure oHide has no extra Favored Weapon feats.
    // Should only be an issue if a deity's favored weapon changes.
    itemproperty ipHide = GetFirstItemProperty(oHide);
    while ( GetIsItemPropertyValid(ipHide) )
    {
        int nHideWeapon = GetItemPropertySubType(ipHide);

        // See if ipHide grants a Favored Weapon feat.
        if ( WEAPON_FIRST <= nHideWeapon  &&  nHideWeapon <= WEAPON_LAST  &&
             GetItemPropertyType(ipHide) == ITEM_PROPERTY_BONUS_FEAT )
        {
            // Should ipHide have this feat?
            if ( nHideWeapon == nFirstWeapon )
                // Mark the first weapon as handled.
                nFirstWeapon = WEAPON_NONE;
            else if ( nHideWeapon == nSecondWeapon )
                // Mark the second weapon as handled.
                nSecondWeapon = WEAPON_NONE;
            else
                // This property should not be there.
                RemoveItemProperty(oHide, ipHide);
        }
        // Next item property.
        ipHide = GetNextItemProperty(oHide);
    }
    // Add missing Favored Weapon feats to oHide.
    if ( nFirstWeapon != WEAPON_NONE )
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nFirstWeapon), oHide);
    if ( nSecondWeapon != WEAPON_NONE )
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nSecondWeapon), oHide);
        */

        // Using nwnx code to handle this directly if possible
        if ( nFirstWeapon != WEAPON_NONE) {
                NWNX_AddKnownFeat(oPC, -1, nFirstWeapon); // using item prop number so feat is -1
        }
        if ( nSecondWeapon != WEAPON_NONE) {
                NWNX_AddKnownFeat(oPC, -1, nSecondWeapon); // using item prop number so feat is -1
        }
}


///////////////////////////////////////////////////////////////////////////////
// IsDeityWeapon()
//
// Returns TRUE if oWeapon counts as a favored weapon for oPC.
//
// OBJECT_INVALID matches unarmed when bOffHand is FALSE.
//
int IsDeityWeapon(object oPC, object oWeapon, int bOffHand = FALSE)
{
    // Get the base item of oWeapon.
    int nWeaponType = GetBaseItemType(oWeapon);

    // Check the "unarmed" special case.
    if ( !GetIsObjectValid(oWeapon) )
    {
        if ( bOffHand )
            // Unarmed doesn't count for the off-hand.
            return FALSE;
        else
            // Use my unarmed base item instead of BASE_ITEM_INVALID.
            nWeaponType = BASE_ITEM_UNARMED;
    }

    // Loop through the list of base items.
    int nBaseItemCount = GetLocalInt(oPC, FAVOREDWEAPON_COUNT);
    while ( nBaseItemCount-- > 0 )
        if ( GetLocalInt(oPC, FAVOREDWEAPON_ENTRY + IntToHexString(nBaseItemCount))
             == nWeaponType )
            return TRUE;

    // At this point, nWeaponType is not in the favored list.
    return FALSE;
}


///////////////////////////////////////////////////////////////////////////////
// ClearDeityWeaponStatus()
//
// Removes the favored weapon properties from oPC, assuming nStatus indicates
// the current properties.
//
// (A positive status indicates bonuses; negative, penalties.)
//
void ClearDeityWeaponStatus(object oPC, int nStatus)
{
    // Get oPC's hide.
    object oHide = GetSkin(oPC);

    // Remove properties based on nStatus.
    // Apply penalties based on nLevel.
    if ( nStatus <= -36 )      // -2 Will, Fortitude, Reflex saves
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_WILL, 2);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_FORTITUDE, 2);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 2);

        // Hack to make NWN recognize saving throw penalties being removed.
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }
    else if ( nStatus <= -30 ) // -2 Will, Fortitude; -1 Reflex saves
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_WILL, 2);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_FORTITUDE, 2);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);

        // Hack to make NWN recognize saving throw penalties being removed.
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }
    else if ( nStatus <= -24 ) // -2 Will; -1 Fortitude, Reflex saves
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_WILL, 2);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_FORTITUDE, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);

        // Hack to make NWN recognize saving throw penalties being removed.
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }
    else if ( nStatus <= -18 ) // -1 Will, Fortitude, Reflex saves
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_WILL, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_FORTITUDE, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);

        // Hack to make NWN recognize saving throw penalties being removed.
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }
    else if ( nStatus <= -12 ) // -1 Will, Fortitude saves
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_WILL, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_FORTITUDE, 1);

        // Hack to make NWN recognize saving throw penalties being removed.
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }
    else if ( nStatus <= -6 )  // -1 Will saves
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_WILL, 1);

        // Hack to make NWN recognize saving throw penalties being removed.
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }
    else if ( nStatus < 5 )    // No penalties or bonuses.
    {
        ;
    }
    else if ( nStatus < 10 )   // +1 Reflex
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
    }
    else if ( nStatus < 15 )   // +1 Reflex, Poison
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
    }
    else if ( nStatus < 20 )   // +1 Reflex, Poison, Fear
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_FEAR, 1);
    }
    else if ( nStatus < 25 )   // +1 Reflex, Poison, Fear; 5% Divine Immunity
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_FEAR, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE,
            IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEIMMUNITY_5_PERCENT);
    }
    else if ( nStatus < 30 )   // +1 Reflex, Poison, Fear, Disease; 5% Divine Immunity
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_FEAR, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_DISEASE, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE,
            IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEIMMUNITY_5_PERCENT);
    }
    else if ( nStatus < 35 )   // +1 Reflex, Poison, Fear, Disease, Mind-affecting; 5% Divine Immunity
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_FEAR, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_DISEASE, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_MINDAFFECTING, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE,
            IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEIMMUNITY_5_PERCENT);
    }
    else if ( nStatus < 40 )   // +1 Reflex, Poison, Fear, Disease, Mind-affecting, Death; 5% Divine Immunity
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_FEAR, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_DISEASE, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_MINDAFFECTING, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_DEATH, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE,
            IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEIMMUNITY_5_PERCENT);
    }
    else                       // +1 Reflex, Poison, Fear, Disease, Mind-affecting, Death; 10% Divine Immunity
    {
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,
            IP_CONST_SAVEBASETYPE_REFLEX, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_POISON, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_FEAR, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_DISEASE, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_MINDAFFECTING, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_SAVING_THROW_BONUS,
            IP_CONST_SAVEVS_DEATH, 1);
        RemoveItemPropertyBySubtypeAndCost(oHide, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE,
            IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEIMMUNITY_10_PERCENT);
    }

    // Record the current status (locally and persistently).
    SetLocalInt(oPC, FAVOREDWEAPON_STATUS, 0);
    SetCampaignInt(DEITY_DATABASE, FW_CampaignStatus(oPC), 0, oPC);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityWeaponBonus()
//
// Applies favored weapon bonuses to oPC, as if oPC is level nLevel.
//
void SetDeityWeaponBonus(object oPC, int nLevel)
{
    // Get oPC's hide.
    object oHide = GetSkin(oPC);

    // Apply bonuses based on nLevel.
    if ( nLevel < 1 )  // was 5     // No bonuses.
    {
        ;
    }
    else if ( nLevel < 3 ) // was 10 // +1 Reflex
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
    }
    else if ( nLevel < 6 ) // was 15 // +1 Reflex, Poison
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
    }
    else if ( nLevel < 9 ) // was 20 // +1 Reflex, Poison, Fear
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 1), oHide);
    }
    else if ( nLevel < 12 ) //was 25 // +1 Reflex, Poison, Fear; 5% Divine Immunity
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_DIVINE,
                IP_CONST_DAMAGEIMMUNITY_5_PERCENT), oHide);
    }
    else if ( nLevel < 15 ) // was 30 // +1 Reflex, Poison, Fear, Disease; 5% Divine Immunity
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DISEASE, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_DIVINE,
                IP_CONST_DAMAGEIMMUNITY_5_PERCENT), oHide);
    }
    else if ( nLevel < 18 ) // was 35 // +1 Reflex, Poison, Fear, Disease, Mind-affecting; 5% Divine Immunity
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DISEASE, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_MINDAFFECTING, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_DIVINE,
                IP_CONST_DAMAGEIMMUNITY_5_PERCENT), oHide);
    }
    else if ( nLevel < 21 ) // was 40  // +1 Reflex, Poison, Fear, Disease, Mind-affecting, Death; 5% Divine Immunity
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DISEASE, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_MINDAFFECTING, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DEATH, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_DIVINE,
                IP_CONST_DAMAGEIMMUNITY_5_PERCENT), oHide);
    }
    else                    // +1 Reflex, Poison, Fear, Disease, Mind-affecting, Death; 10% Divine Immunity
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DISEASE, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_MINDAFFECTING, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DEATH, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_DIVINE,
                IP_CONST_DAMAGEIMMUNITY_10_PERCENT), oHide);
    }

    // Record the current status (locally and persistently).
    SetLocalInt(oPC, FAVOREDWEAPON_STATUS, nLevel);
    SetCampaignInt(DEITY_DATABASE, FW_CampaignStatus(oPC), nLevel, oPC);
}


///////////////////////////////////////////////////////////////////////////////
// SetDeityWeaponPenalty()
//
// Applies favored weapon penalties to oPC, as if oPC is level nLevel.
//
void SetDeityWeaponPenalty(object oPC, int nLevel)
{
    // Get oPC's hide.
    object oHide = GetSkin(oPC);

    // Apply penalties based on nLevel.
    if ( nLevel < 6 )       // No penalties.
    {
        ;
    }
    else if ( nLevel < 12 ) // -1 Will saves
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL, 1), oHide);
    }
    else if ( nLevel < 18 ) // -1 Will, Fortitude saves
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 1), oHide);
    }
    else if ( nLevel < 24 ) // -1 Will, Fortitude, Reflex saves
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
    }
    else if ( nLevel < 30 ) // -2 Will; -1 Fortitude, Reflex saves
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL, 2), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 1), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
    }
    else if ( nLevel < 36 ) // -2 Will, Fortitude; -1 Reflex saves
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL, 2), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 2), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 1), oHide);
    }
    else                    // -2 Will, Fortitude, Reflex saves
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL, 2), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 2), oHide);
        AddItemProperty(DURATION_TYPE_PERMANENT,
            ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 2), oHide);
    }

    // Record the current status (locally and persistently).
    SetLocalInt(oPC, FAVOREDWEAPON_STATUS, -nLevel);
    SetCampaignInt(DEITY_DATABASE, FW_CampaignStatus(oPC), -nLevel, oPC);
}


///////////////////////////////////////////////////////////////////////////////
// GetFavWeapFromFeatIP()
//
// Returns a base item (BASE_ITEM_*) associated with a favored weapon constant.
// Returns BASE_ITEM_NONE when input values are out of range.
//
// nFeat must be a WEAPON_* constant.
// nIndex is an index into the list of base items (starts at 0).
//
// Most weapons have only one base item.
//
int GetFavWeapFromFeatIP(int nWeapon, int nIndex)
{
    // This is basically a look-up table.
    switch ( nWeapon )
    {
        case WEAPON_BASTARDSWORD:
                if ( nIndex == 0 )
                    return BASE_ITEM_BASTARDSWORD;
                return BASE_ITEM_NONE;

        case WEAPON_BATTLEAXE:
                if ( nIndex == 0 )
                    return BASE_ITEM_BATTLEAXE;
                return BASE_ITEM_NONE;

        case WEAPON_CLUB:
                if ( nIndex == 0 )
                    return BASE_ITEM_CLUB;
                return BASE_ITEM_NONE;

        case WEAPON_DAGGER:
                if ( nIndex == 0 )
                    return BASE_ITEM_DAGGER;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_DAGGERASSASSIN;
                return BASE_ITEM_NONE;

        case WEAPON_DART:
                if ( nIndex == 0 )
                    return BASE_ITEM_DART;
                return BASE_ITEM_NONE;

        case WEAPON_DIREMACE:
                if ( nIndex == 0 )
                    return BASE_ITEM_DIREMACE;
                return BASE_ITEM_NONE;

        case WEAPON_DOUBLEAXE:
                if ( nIndex == 0 )
                    return BASE_ITEM_DOUBLEAXE;
                return BASE_ITEM_NONE;

        case WEAPON_DWARVENWARAXE:
                if ( nIndex == 0 )
                    return BASE_ITEM_DWARVENWARAXE;
                return BASE_ITEM_NONE;

        case WEAPON_GREATAXE:
                if ( nIndex == 0 )
                    return BASE_ITEM_GREATAXE;
                return BASE_ITEM_NONE;

        case WEAPON_GREATSWORD:
                if ( nIndex == 0 )
                    return BASE_ITEM_GREATSWORD;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_MERCURIALGREATSWORD;
                return BASE_ITEM_NONE;

        case WEAPON_HALBERD:
                if ( nIndex == 0 )
                    return BASE_ITEM_HALBERD;
                return BASE_ITEM_NONE;

        case WEAPON_HANDAXE:
                if ( nIndex == 0 )
                    return BASE_ITEM_HANDAXE;
                return BASE_ITEM_NONE;

        case WEAPON_HEAVYCROSSBOW:
                if ( nIndex == 0 )
                    return BASE_ITEM_HEAVYCROSSBOW;
                return BASE_ITEM_NONE;

        case WEAPON_HEAVYFLAIL:
                if ( nIndex == 0 )
                    return BASE_ITEM_HEAVYFLAIL;
                return BASE_ITEM_NONE;

        case WEAPON_KAMA:
                if ( nIndex == 0 )
                    return BASE_ITEM_KAMA;
                return BASE_ITEM_NONE;

        case WEAPON_KATANA:
                if ( nIndex == 0 )
                    return BASE_ITEM_KATANA;
                return BASE_ITEM_NONE;

        case WEAPON_KUKRI:
                if ( nIndex == 0 )
                    return BASE_ITEM_KUKRI;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_KUKRI2;
                return BASE_ITEM_NONE;

        case WEAPON_LIGHTCROSSBOW:
                if ( nIndex == 0 )
                    return BASE_ITEM_LIGHTCROSSBOW;
                return BASE_ITEM_NONE;

        case WEAPON_LIGHTFLAIL:
                if ( nIndex == 0 )
                    return BASE_ITEM_LIGHTFLAIL;
                return BASE_ITEM_NONE;

        case WEAPON_LIGHTHAMMER:
                if ( nIndex == 0 )
                    return BASE_ITEM_LIGHTHAMMER;
                return BASE_ITEM_NONE;

        case WEAPON_MACE:
                if ( nIndex == 0 )
                    return BASE_ITEM_LIGHTMACE;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_LIGHTMACE2;
                return BASE_ITEM_NONE;

        case WEAPON_LONGBOW:
                if ( nIndex == 0 )
                    return BASE_ITEM_LONGBOW;
                return BASE_ITEM_NONE;

        case WEAPON_LONGSWORD:
                if ( nIndex == 0 )
                    return BASE_ITEM_LONGSWORD;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_MERCURIALLONGSWORD;
//                if ( nIndex == 2 )
//                    return BASE_ITEM_CEP_LONGSWORD2;
                return BASE_ITEM_NONE;

        case WEAPON_MAGICSTAFF:
                if ( nIndex == 0 )
                    return BASE_ITEM_MAGICSTAFF;
                return BASE_ITEM_NONE;

        case WEAPON_MORNINGSTAR:
                if ( nIndex == 0 )
                    return BASE_ITEM_MORNINGSTAR;
                return BASE_ITEM_NONE;

        case WEAPON_QUARTERSTAFF:
                if ( nIndex == 0 )
                    return BASE_ITEM_QUARTERSTAFF;
                return BASE_ITEM_NONE;

        case WEAPON_RAPIER:
                if ( nIndex == 0 )
                    return BASE_ITEM_RAPIER;
                return BASE_ITEM_NONE;

        case WEAPON_SCIMITAR:
                if ( nIndex == 0 )
                    return BASE_ITEM_SCIMITAR;
                return BASE_ITEM_NONE;

        case WEAPON_SCYTHE:
                if ( nIndex == 0 )
                    return BASE_ITEM_SCYTHE;
                return BASE_ITEM_NONE;

        case WEAPON_SHORTBOW:
                if ( nIndex == 0 )
                    return BASE_ITEM_SHORTBOW;
                return BASE_ITEM_NONE;

        case WEAPON_SPEAR:
                if ( nIndex == 0 )
                    return BASE_ITEM_SHORTSPEAR;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_TINYSPEAR;
                return BASE_ITEM_NONE;

        case WEAPON_SHORTSWORD:
                if ( nIndex == 0 )
                    return BASE_ITEM_SHORTSWORD;
                return BASE_ITEM_NONE;

        case WEAPON_SHURIKEN:
                if ( nIndex == 0 )
                    return BASE_ITEM_SHURIKEN;
                return BASE_ITEM_NONE;

        case WEAPON_SICKLE:
                if ( nIndex == 0 )
                    return BASE_ITEM_SICKLE;
                return BASE_ITEM_NONE;

        case WEAPON_SLING:
                if ( nIndex == 0 )
                    return BASE_ITEM_SLING;
                return BASE_ITEM_NONE;

        case WEAPON_THROWINGAXE:
                if ( nIndex == 0 )
                    return BASE_ITEM_THROWINGAXE;
                return BASE_ITEM_NONE;

        case WEAPON_TRIDENT:
                if ( nIndex == 0 )
                    return BASE_ITEM_TRIDENT;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_TRIDENT_1H;
                return BASE_ITEM_NONE;

        case WEAPON_TWOBLADEDSWORD:
                if ( nIndex == 0 )
                    return BASE_ITEM_TWOBLADEDSWORD;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_MAUGDOUBLESWORD;
                return BASE_ITEM_NONE;

        case WEAPON_UNARMEDSTRIKE:
                if ( nIndex == 0 )
                    return BASE_ITEM_UNARMED;
                return BASE_ITEM_NONE;

        case WEAPON_WARHAMMER:
                if ( nIndex == 0 )
                    return BASE_ITEM_WARHAMMER;
                return BASE_ITEM_NONE;

        case WEAPON_WHIP:
                if ( nIndex == 0 )
                    return BASE_ITEM_WHIP;
                return BASE_ITEM_NONE;

        // CEP Weapons:

        case WEAPON_DOUBLESCIMITAR:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_DOUBLESCIMITAR;
                return BASE_ITEM_NONE;

        case WEAPON_FALCHION:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_FALCHION1;
                if ( nIndex == 1 )
                    return BASE_ITEM_CEP_FALCHION2;
                return BASE_ITEM_NONE;

        case WEAPON_GOAD:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_GOAD;
                return BASE_ITEM_NONE;

        case WEAPON_HEAVYMACE:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_HEAVYMACE;
                return BASE_ITEM_NONE;

        case WEAPON_HEAVYPICK:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_HEAVYPICK;
                return BASE_ITEM_NONE;

        case WEAPON_KATAR:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_KATAR;
                return BASE_ITEM_NONE;

        case WEAPON_LIGHTPICK:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_LIGHTPICK;
                return BASE_ITEM_NONE;

        case WEAPON_MAUL:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_MAUL;
                return BASE_ITEM_NONE;

        case WEAPON_NUNCHAKU:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_NUNCHAKU;
                return BASE_ITEM_NONE;

        case WEAPON_SAI:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_SAI;
                return BASE_ITEM_NONE;

        case WEAPON_SAP:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_SAP;
                return BASE_ITEM_NONE;

        case WEAPON_WINDFIREWHEEL:
                if ( nIndex == 0 )
                    return BASE_ITEM_CEP_WINDFIREWHEEL;
                return BASE_ITEM_NONE;
    }//switch (nWeapon)

    // Unrecognized weapon. No base items.
    return BASE_ITEM_NONE;
}


///////////////////////////////////////////////////////////////////////////////
// UTILITY DEFINITIONS:


///////////////////////////////////////////////////////////////////////////////
// RemoveItemPropertyByTypeAndCost()
//
// Removes the first item property from oItem that matches the indicated
// type and cost.
//
void RemoveItemPropertyByTypeAndCost(object oItem, int nType, int nCost)
{
    // Loop through the item's properties.
    itemproperty ipRemove = GetFirstItemProperty(oItem);
    while ( GetIsItemPropertyValid(ipRemove) )
    {
        // Compare ipRemove to the given criteria.
        if ( GetItemPropertyType(ipRemove) == nType  &&
             GetItemPropertyCostTableValue(ipRemove) == nCost )
        {
            // This is the property to remove.
            RemoveItemProperty(oItem, ipRemove);
            return;
        }
        // Next item property.
        ipRemove = GetNextItemProperty(oItem);
    }
}


///////////////////////////////////////////////////////////////////////////////
// RemoveItemPropertyBySubtypeAndCost()
//
// Removes the first item property from oItem that matches the indicated
// type, subtype, and cost.
//
void RemoveItemPropertyBySubtypeAndCost(object oItem, int nType, int nSubtype, int nCost)
{
    // Loop through the item's properties.
    itemproperty ipRemove = GetFirstItemProperty(oItem);
    while ( GetIsItemPropertyValid(ipRemove) )
    {
        // Compare ipRemove to the given criteria.
        if ( GetItemPropertyType(ipRemove) == nType  &&
             GetItemPropertySubType(ipRemove) == nSubtype  &&
             GetItemPropertyCostTableValue(ipRemove) == nCost )
        {
            // This is the property to remove.
            RemoveItemProperty(oItem, ipRemove);
            return;
        }
        // Next item property.
        ipRemove = GetNextItemProperty(oItem);
    }
}
