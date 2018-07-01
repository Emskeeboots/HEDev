//::///////////////////////////////////////////////
//:: Continual Flame
//:: x0_s0_clight.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 Permanent Light spell

    XP2
    If cast on an item, item will get permanently
    get the property "light".
    Previously existing permanent light properties
    will be removed!

*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 18, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
//:: Added XP2 cast on item code: Georg Z, 2003-06-05
//:://////////////////////////////////////////////
/*
Patch 1.71, fix by Shadooow

- any item that this spell is cast at is now marked as stolen to disable the cast/sell exploit
- spell can dispell the shadowblend effect
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 14)   added local CONTINUAL_FLAME to help with dispelling
//                                      removed the setting of the stolen flag since light properties have no cost

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    // Handle spell cast on item....
    if (GetObjectType(spell.Target) == OBJECT_TYPE_ITEM && ! CIGetIsCraftFeatBaseItem(spell.Target))
    {
        // Do not allow casting on not equippable items
        if (!IPGetIsItemEquipable(spell.Target))
        {
            // Item must be equipable...
            FloatingTextStrRefOnCreature(83326,spell.Caster);
            return;
        }
        itemproperty ip = ItemPropertyLight (IP_CONST_LIGHTBRIGHTNESS_BRIGHT, IP_CONST_LIGHTCOLOR_WHITE);
        IPSafeAddItemProperty(spell.Target, ip, 0.0,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,TRUE,TRUE);

        // ---- removed the stolen flag. better solution was to set the cost of the light property to zero
        //casting this spell on every crap and then sell it is very well known exploit
        //SetStolenFlag(spell.Target, TRUE);//sets item to be stolen, thus harder to sell
    }
    else
    {
        if(GetHasSpellEffect(757, spell.Target))
        {
            //Continual light effectively dispells shadowblend effect
            RemoveEffectsFromSpell(spell.Target, 757);
        }
        //Declare major variables
        effect eVis = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_20);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eLink = SupernaturalEffect(EffectLinkEffects(eVis, eDur));

        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spell.Target);
    }

    // used for dispelling the light effect
    SetLocalInt(spell.Target,"CONTINUAL_FLAME", spell.Level);
}
