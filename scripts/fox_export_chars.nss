// +----------------------+
// | FOX_EXPORT_CHARS.nss |
// +----------------------+
//
// ExportAllCharacters()
// ExportSingleCharacter()
//
// [fox - 25 Apr 2011 - standalone version]
// This script is the solution to the problem of polymorphed PCs losing their
// precious itemproperties after an Export of their Character.
//
// This script is designed to run via ExecuteScript().
// Make it run for a PC for an ExportSingleCharacter().
// Make it run for anything else for an ExportAllCharacters().



// +-----------+
// | CONSTANTS |
// +-----------+
// Name of a LocalObject we set on a polymorphed PC prior to export him. We use
// this to keep, briefly, a reference to all his equipment.
const string sFox_EXPORT_SLOTn = "FOX_EXP_00";



// +------------+
// | PROTOTYPES |
// +------------+
void fox_ExportAllCharacters     ();
void fox_ExportSingleCharacter   (object oPC);
void fox_ReapplyEnhancements     (object oPC);
void fox_RemoveAllItemProperties (object oItem);
void fox_CopyAllItemProperties   (object oDest, object oSource);



void main ()
{
    /////////////////////////////
    // Who are we running for?

    // Is this a PC?
    //if (GetIsPC (OBJECT_SELF))
    if (GetLocalInt(OBJECT_SELF, "IS_PC"))
    {
        // He is. Attempt to export him alone.
        fox_ExportSingleCharacter (OBJECT_SELF);
    }
    else
    {
        // Not a PC. We attempt to export every PC.
        fox_ExportAllCharacters ();
    }
}



// -----------------------------------------------------------------------------
// Only a helper function to reduce the clutter.
// Cycles through all PCs and export them all.
// -----------------------------------------------------------------------------
void fox_ExportAllCharacters ()
{
    ////////////////////////////
    // Cycle through all PCs.

    object oPC = GetFirstPC ();
    while (GetIsObjectValid (oPC))
    {
        fox_ExportSingleCharacter (oPC);

        oPC = GetNextPC ();
    }
}



// -----------------------------------------------------------------------------
// Only a helper function to reduce the clutter.
// Export the given PC.
// -----------------------------------------------------------------------------
void fox_ExportSingleCharacter (object oPC)
{
    // Check if this PC is polymorphed.
    int bPoly = FALSE;
    effect eSeek = GetFirstEffect (oPC);
    while (GetIsEffectValid (eSeek))
    {
        if (GetEffectType (eSeek) == EFFECT_TYPE_POLYMORPH)
        {
            bPoly = TRUE;
            break;
        }

        eSeek = GetNextEffect (oPC);
    }


    ////////////////////////////////////////////////////////////////////////////
    // If the PC is polymorphed, we create a temporary copy of his current
    // equipment. We set a LocalObject on him for each item we create a copy of.
    ////////////////////////////////////////////////////////////////////////////

    if (bPoly)
    {
        // Sanity check. Is the PC in a valid Area?
        if (!GetIsObjectValid (GetArea (oPC)))
        {
            ////////////////////////////////////////////////////////////////////
            // There is a period of time, during Area Transitions, in which the
            // PC is -technically- outside of the Area he was last in, and not
            // yet in the Area he is transitioning to. The length of this window
            // depends on the complexity of the Areas involved in the process.
            // It is possible that a script executes when the PC is in such a
            // no-Area, and any code involving Areas or Locations shall go bug.
            ////////////////////////////////////////////////////////////////////

            // PC is in a no-Area. Quit.
            return;
        }

        // Get the current location of this PC.
        location lAt = GetLocation (oPC);

        // Scan all equipped items on this polymorphed PC.
        int i;
        for (i = 0; i < NUM_INVENTORY_SLOTS; ++i)
        {
            object oEquip = GetItemInSlot (i, oPC);
            if (GetIsObjectValid (oEquip))
            {
                //////////////////////////////////////////////////////
                // Create, on ground, a copy of this equipped item.
                // -------------------------------------------------------
                // NOTE : The copy will stay around for a very brief time.
                //        Nobody will notice it.
                // -------------------------------------------------------

                object oCopy = CopyObject (oEquip, lAt, OBJECT_INVALID, "");
                if (GetIsObjectValid (oCopy))
                {
                    // Set a reference on the PC to the copy we have made.
                    SetLocalObject (oPC, sFox_EXPORT_SLOTn + IntToString (i), oCopy);
                }
            }
        }
    }


    /////////////////////
    // Export this PC.

    ExportSingleCharacter (oPC);


    /////////////////////////////////////////////////////////////////////////
    // If the PC is polymorphed, we now reinstate what itemproperties he just
    // lost to the export.
    /////////////////////////////////////////////////////////////////////////

    if (bPoly)
    {
        DelayCommand (0.1f, fox_ReapplyEnhancements (oPC));
    }
}



// -----------------------------------------------------------------------------
// This function takes care to reapply all the enhancements a polymorphed PC had
// at the time of the export of his Character.
// We discovered that, after an export, all equipped items but the Skin/Hide are
// re-spawned anew on the polymorphed PC. Thus we have a set of itemproperties
// that is missing. And there is no way to unequip nor equip items on a PC while
// polymorphed.
// Our solution is to create temporary copies of all items equipped pre-export.
// Then, post-export, we clear the equipped items on the polymorphed PC of all
// their itemproperties. And immediately after we reinstate all itemproperties
// from the copies we made pre-export. This is the only approach that can react
// properly to new properties added to the equipped items after a polymorph.
//
// Our logic is flawless :-)
// -----------------------------------------------------------------------------
void fox_ReapplyEnhancements (object oPC)
{
    // Scan all equipped items on this polymorphed PC.
    int i;
    for (i = 0; i < NUM_INVENTORY_SLOTS; ++i)
    {
        object oEquip = GetItemInSlot (i, oPC);
        if (GetIsObjectValid (oEquip))
        {
            string sKey = sFox_EXPORT_SLOTn + IntToString (i);

            // Get a reference to the temporary copy we made of this item.
            object oCopy = GetLocalObject (oPC, sKey);

            if (GetIsObjectValid (oCopy))
            {
                // Delete the reference (we no longer need it).
                DeleteLocalObject (oPC, sKey);

                // Remove all current itemproperties from the equipped item.
                fox_RemoveAllItemProperties (oEquip);

                // Copy all itemproperties from the temporary copy.
                // (the copy is destroyed within the function)
                DelayCommand (0.0f, fox_CopyAllItemProperties (oEquip, oCopy));
            }
        }
    }
}



// -----------------------------------------------------------------------------
// Only a helper function to reduce the clutter.
// Removes ALL itemproperties from the given item.
// -----------------------------------------------------------------------------
void fox_RemoveAllItemProperties (object oItem)
{
    itemproperty ipSeek = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipSeek))
    {
        RemoveItemProperty (oItem, ipSeek);

        ipSeek = GetNextItemProperty (oItem);
    }
}



// -----------------------------------------------------------------------------
// Only a helper function to reduce the clutter.
// Copy ALL itemproperties from the Source item to the Destination item.
// -----------------------------------------------------------------------------
void fox_CopyAllItemProperties (object oDest, object oSource)
{
    itemproperty ipSeek = GetFirstItemProperty (oSource);
    while (GetIsItemPropertyValid (ipSeek))
    {
        AddItemProperty (DURATION_TYPE_PERMANENT, ipSeek, oDest, 0.0f);

        ipSeek = GetNextItemProperty (oSource);
    }

    // Destroy the Source item.
    // (that is, the temporary copy item we made)
    DestroyObject (oSource, 0.0f);
}
