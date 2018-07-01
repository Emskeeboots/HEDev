//::///////////////////////////////////////////////
//:: Summon Familiar
//:: nw_s2_familiar
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell summons an Arcane caster's familiar
*/
//:://////////////////////////////////////////////
//:: Created: Preston Watamaniuk : Sept 27, 2001
//:: Modifief: The Magus (2013 jan 5) - innocuous familiars
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"
#include "_inc_pets"
#include "_inc_data"
#include "_inc_color"

void main()
{
    // INNOCUOUS FAMILIARS -----------------------------------------------------

    // the feat receives unlimited uses
    IncrementRemainingFeatUses(OBJECT_SELF, FEAT_SUMMON_FAMILIAR);

    //Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return; // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    // End of Spell Cast Hook

    // dead familiars can not be spawned
    if(GetSkinInt(OBJECT_SELF, FAMILIAR_DEAD))
    {
        SendMessageToPC(OBJECT_SELF, RED+"Your familiar is dead.");
        return;
    }
    // track whether the familiar is summoned
    SetLocalInt(OBJECT_SELF, FAMILIAR_SUMMONED, TRUE);

    // END INNOCUOUS FAMILIARS -------------------------------------------------

    //Yep thats it
    SummonFamiliar();
}
