//::///////////////////////////////////////////////
//:: _s2_famspell
//:://////////////////////////////////////////////
/*
    Spell Script for Cast Master's Spell


*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2013 jan 12)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

#include "_inc_pets"

void main()
{
    //Spellcast Hook Code
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    int nSpellID    = GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_ID");
    if(nSpellID==-1)
    {   // NO SPELL TO CAST
        // clear hide of spell storing feats
        RemoveMasterSpellsFromFamiliarHide( GetItemInSlot(INVENTORY_SLOT_CARMOUR),
                                            GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_PROPERTY")
                                          );
        return;
    }

    ClearAllActions(TRUE);

    object oTarget  = GetSpellTargetObject();
    int nMeta       = GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_META");
    // These are made use of by ShaDoOoW's Community Patch 1.70
    // They give the spell script the proper level, DC, and metamagic feat
    // Without the community patch familiar spells appear to be cast at level 10
    SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE", GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_LEVEL") );
    SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_DC_OVERRIDE", GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_DC") );
    SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_METAMAGIC_OVERRIDE", nMeta);

    if(oTarget!=OBJECT_INVALID)
        ActionCastSpellAtObject(nSpellID, oTarget, nMeta, TRUE);
    else
        ActionCastSpellAtLocation(nSpellID, GetSpellTargetLocation(), nMeta, TRUE);

    ActionDoCommand(    DelayCommand(0.1, RemoveMasterSpellsFromFamiliarHide(   GetItemInSlot(INVENTORY_SLOT_CARMOUR),
                                                                                GetLocalInt(OBJECT_SELF, "FAMILIAR_SPELL_PROPERTY")
                                                                            )
                                    )
                   );
}
