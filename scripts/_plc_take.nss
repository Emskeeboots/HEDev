//::///////////////////////////////////////////////
//:: _plc_take
//:://////////////////////////////////////////////
/*
    placeable OnUsed - makes the placeable "takeable"

    local variables
    PLACEABLE_TAKE_RESREF   (string)    is the name of the ResRef of the item to create
    PLACEABLE_TAKE_ONCE     (int)       item will not retain placable's data when created
    PLACEABLE_TAKE_IMMEDIATE(int)       take action not required. item is created in pc's inventory.

    if no PLACEABLE_TAKE_RESREF is supplied,
        the script attempts to create an item with the same resref as the placeable

    Event OnUsed:
        Create item in same location as placeable
        Direct User to pickup Item
        Destroy Placeable
*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2011 apr 14)
//:: Modified:  The Magus (2011 aug 14) taken candles transfer description and data to item.
//:: Modified:  The Magus (2013 july 13) minor adjustments for public consumption
//:://////////////////////////////////////////////

#include "aid_inc_global"

void main()
{
    object oPC  = GetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    DeleteLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    if(!GetIsObjectValid(oPC))
        oPC     = GetPlaceableLastClickedBy();


  // BEGIN open placeable
  if(GetFirstItemInInventory(OBJECT_SELF)!=OBJECT_INVALID)
  {
    SetLocalInt(OBJECT_SELF,"PLACEABLE_TAKE_OPEN",TRUE);
  }
  // END open placeable
  // this is a catch for whether the placeable was opened, and allows it to close without being taken
  else if(GetLocalInt(OBJECT_SELF,"PLACEABLE_TAKE_OPEN"))
    DeleteLocalInt(OBJECT_SELF,"PLACEABLE_TAKE_OPEN");
  // BEGIN take item
  else
  {
    object oArea        = GetArea(OBJECT_SELF);
    string sRef         = GetLocalString(OBJECT_SELF, PLACEABLE_ITEM_RESREF);
    if (sRef == "")
        sRef            = GetResRef(OBJECT_SELF);
    int bOnce           = GetLocalInt(OBJECT_SELF, "PLACEABLE_TAKE_ONCE");
    int bImmediate      = GetLocalInt(OBJECT_SELF, "PLACEABLE_TAKE_IMMEDIATE");

    string sName        = GetName(OBJECT_SELF);
    string sDescription = GetDescription(OBJECT_SELF);
    string sTag         = "";
    int nStack;

    // MAGUS LIGHT SYSTEM
    int bLight          = GetLocalInt(OBJECT_SELF, "LIGHTABLE");
    if(bLight)
        sTag = GetTag(OBJECT_SELF);

    object oItem;
    if(!bImmediate)
        oItem   = CreateObject(OBJECT_TYPE_ITEM, sRef, GetLocation(OBJECT_SELF), FALSE, sTag);
    else
        oItem   = CreateItemOnObject(sRef, oPC, 1, sTag);

    if(nStack)
        SetItemStackSize(oItem, nStack);

    AssignCommand(oPC, PlaySound("it_pickup"));

    if(!bOnce)
    {
        SetLocalString(oItem, PLACEABLE_ITEM_RESREF, GetResRef(OBJECT_SELF)); // sRef identifies the placeable to create when dropped
        SetName(oItem, sName);
        SetDescription(oItem, sDescription);
    }

    // MAGUS LIGHT SYSTEM
    if (bLight)
    {
        SetLocalInt(oItem, "LIGHTABLE", bLight);
        SetLocalString(oItem, "LIGHTABLE_TYPE", GetLocalString(OBJECT_SELF,"LIGHTABLE_TYPE"));
        SetLocalInt(oItem, "LIGHTABLE_BURNED_TICKS", GetLocalInt(OBJECT_SELF, "LIGHTABLE_BURNED_TICKS"));
        if (GetLocalInt(OBJECT_SELF, "LIGHTABLE_LANTERN_EMPTY"))
            SetLocalInt(oItem, "LIGHTABLE_LANTERN_EMPTY", TRUE);
    }

    if(!bImmediate)
    {
        AssignCommand(oPC, ActionPickUpItem(oItem));
    }

    // MAGUS LIGHT SYSTEM
    if (bLight)
        AssignCommand(oArea, DelayCommand(2.4, RecomputeStaticLighting(oArea)) );

    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF);
  }
  // END take item
}
