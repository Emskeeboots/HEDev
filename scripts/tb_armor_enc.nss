// tb_armor_enc
// Handle armor encumbrace equip and uneqip events
// Called with ExecuteScript() as the module.
//

#include "x2_inc_switches"
#include "tb_inc_movement"

void main() {
    int nEvent = GetUserDefinedItemEventNumber();
    if (!TB_ARMOR_ENCUMBRANCE)
        return;

    if (nEvent ==  X2_ITEM_EVENT_EQUIP) {
          tbArmorOnEquip(GetPCItemLastEquipped(), GetPCItemLastEquippedBy());
          return;
    }
    if (nEvent ==  X2_ITEM_EVENT_UNEQUIP) {
        tbArmorOnUnEquip(GetPCItemLastUnequipped(), GetPCItemLastUnequippedBy());
        return;
    }

}
