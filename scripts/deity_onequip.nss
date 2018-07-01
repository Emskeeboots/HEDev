///////////////////////////////////////////////////////////////////////////////
// deity_onequip.nss
//
// Created by: The Krit
// Date: 2/25/07
///////////////////////////////////////////////////////////////////////////////
//
// This file is probably not something you want to change. It implements the
// favored weapon bonuses when equipped items change.
//
///////////////////////////////////////////////////////////////////////////////
//
// To use, call UpdateDeityWeapons() in your module's OnPlayerEquipItem and
// OnPlayerUnequipItem events.
// (The parameter should be the object leveling up, either GetPCLevellingUp()
// or a variable that has been assigned that value.)
//
///////////////////////////////////////////////////////////////////////////////


#include "deity_include"


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION PROTOTYPES:
///////////////////////////////////////////////////////////////////////////////

// Implements the favored weapon effects for oPC.
// During an unequip event, call this on delay so that the item is actually unequipped.
// (The item is not unequipped while the event fires.)
void UpdateDeityWeapons(object oPC);



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FUNCTION DEFINITIONS:
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// UpdateDeityWeapons()
//
// Implements the favored weapon effects for oPC.
//
// During an unequip event, call this on delay so that the item is actually unequipped.
//
//void UpdateDeityWeapons(object oPC)
void main () {
        object oPC = OBJECT_SELF;


    // Check for disallowing equipping a holy symbol - This does not apply of we using the default holy symbol for all deities.
    // Otherwise PCs may only equip holy symbols of their deity. 
        if (deityHolysymbolEquip(oPC, GetPCItemLastEquipped())) {
              return;
        }

        int nClericLevel = GetLevelByClass(CLASS_TYPE_CLERIC, oPC);
    // Nothing needs to be done if oPC is not a cleric.
        if (!nClericLevel)
              return;

    // Get the current favored weapon status.
        int nStatus = GetLocalInt(oPC, FAVOREDWEAPON_STATUS);
        if ( nStatus == 0 ) {
        // No local variable. Check the persistent database variable.
                nStatus = GetCampaignInt(DEITY_DATABASE, FW_CampaignStatus(oPC), oPC);
                if ( nStatus != 0 ) {
            // Resync the local variable.
                        SetLocalInt(oPC, FAVOREDWEAPON_STATUS, nStatus);
                }
        }

    // Check oPC's weapons.
        if ( IsDeityWeapon(oPC, GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC))
           || IsDeityWeapon(oPC, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC), TRUE)) {
        // Favored weapon wielded. See if the bonuses are not already present.
                if ( nStatus != nClericLevel ) {
            // Clear old "effects".
                        ClearDeityWeaponStatus(oPC, nStatus);
            // Set new bonus.
                        SetDeityWeaponBonus(oPC, nClericLevel);
                }
        } else {
        // Favored weapon not wielded. See if the penalties are not already present.
                if ( nStatus != -nClericLevel ) {
            // Clear old "effects".
                        ClearDeityWeaponStatus(oPC, nStatus);
            // Set new penalty.
                        SetDeityWeaponPenalty(oPC, nClericLevel);
                }
        }
}

