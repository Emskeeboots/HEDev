//::///////////////////////////////////////////////
//:: Summon Animal Companion
//:: NW_S2_AnimalComp
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell summons a Druid's animal companion
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 27, 2001
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 12) summoning is limited to deaths rather than feat uses

#include "x2_inc_spellhook"

#include "x3_inc_skin"

#include "_inc_pets"

void main()
{
    /* Spellcast Hook Code */
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;

    IncrementRemainingFeatUses(OBJECT_SELF, FEAT_ANIMAL_COMPANION);

    if(GetSkinInt(OBJECT_SELF, COMPANION_DEAD))
    {
        SendMessageToPC(OBJECT_SELF, RED+"Your spirit animal was killed recently and"
            +" is not yet ready to return.");
        return;
    }

    /*
    if(!GetCompanionEnvironmentSuitable(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, RED+"Your present environment is unsuitable for"
            +" the summoning of your spirit animal.");
        return;
    }
    */

    if(!GetLocalInt(OBJECT_SELF, COMPANION_SUMMONED))
        SetLocalInt(OBJECT_SELF, COMPANION_SUMMONED, TRUE);

    // Actual summoning happens in SummonAnimalCompanion() which is HARD CODED.
    // Therefore most customization happens in the creature's event scripts.
    // see: nw_ch_acani9
    SummonAnimalCompanion();
}
