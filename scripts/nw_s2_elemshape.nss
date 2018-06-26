//::///////////////////////////////////////////////
//:: Elemental Shape
//:: NW_S2_ElemShape
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Allows the Druid to change into elemental forms.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 22, 2002
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified Date: January 15th-16th, 2008
//:://////////////////////////////////////////////
/*
    Modified to insure no shapeshifting spells are castable upon
    mounted targets.  This prevents problems that can occur due
    to dismounting after shape shifting, or other issues that can
    occur due to preserved appearances getting out of synch.

    This can additional check can be disabled by setting the variable
    X3_NO_SHAPESHIFT_SPELL_CHECK to 1 on the module object.  If this
    variable is set then this script will function as it did prior to
    this modification.

Patch 1.71, by Shadooow

- allowed to merge any custom non-weapon in left hand slot such as flags or
musical instruments
- added optional feature to stack ability bonuses from multiple items together
- added optional feature to merge bracers (when items are allowed to merge)
- cured from horse include while retaining the shapeshifting horse check
- fixed dying when unpolymorphed as an result of sudden constitution bonus drop
which also could result to the server crash
*/
//:: Modified: Henesua (2014 jan 25) poly tracking and horse fix merge

#include "70_inc_itemprop"

#include "x2_inc_spellhook"
#include "x2_inc_itemprop"
#include "x3_inc_horse"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    int nSpell = GetSpellId();
    object oTarget = GetSpellTargetObject();
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly;
    int nPoly;
    int nDuration = GetLevelByClass(CLASS_TYPE_DRUID); //GetCasterLevel(OBJECT_SELF);
    int bElder = FALSE;

    // Horse anti-shapechange code.
    /*
    if ( !GetLocalInt(GetModule(), HORSELV_NO_SHAPESHIFT_CHECK) )
    {
        // The check is not disabled. Look for a mounted target.
        if ( HorseGetIsMounted(oTarget) )
        {
            // Inform the target and abort.
            FloatingTextStrRefOnCreature(111982, oTarget, FALSE); // "You cannot shapeshift while mounted."
            return;
        }
    }
    */

    if(GetLevelByClass(CLASS_TYPE_DRUID) >= 20)
    {
        bElder = TRUE;
    }
    //Determine Polymorph subradial type
    if(bElder == FALSE)
    {
        if(nSpell == 397)
        {
            nPoly = POLYMORPH_TYPE_HUGE_FIRE_ELEMENTAL;
        }
        else if (nSpell == 398)
        {
            nPoly = POLYMORPH_TYPE_HUGE_WATER_ELEMENTAL;
        }
        else if (nSpell == 399)
        {
            nPoly = POLYMORPH_TYPE_HUGE_EARTH_ELEMENTAL;
        }
        else if (nSpell == 400)
        {
            nPoly = POLYMORPH_TYPE_HUGE_AIR_ELEMENTAL;
        }
    }
    else
    {
        if(nSpell == 397)
        {
            nPoly = POLYMORPH_TYPE_ELDER_FIRE_ELEMENTAL;
        }
        else if (nSpell == 398)
        {
            nPoly = POLYMORPH_TYPE_ELDER_WATER_ELEMENTAL;
        }
        else if (nSpell == 399)
        {
            nPoly = POLYMORPH_TYPE_ELDER_EARTH_ELEMENTAL;
        }
        else if (nSpell == 400)
        {
            nPoly = POLYMORPH_TYPE_ELDER_AIR_ELEMENTAL;
        }
    }
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_ELEMENTAL_SHAPE, FALSE));

    int bWeapon = StringToInt(Get2DAString("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DAString("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DAString("polymorph","MergeI",nPoly)) == 1;
    int bArms = bItems && GetLocalInt(GetModule(),"71_POLYMORPH_MERGE_ARMS");

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,OBJECT_SELF);
    object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,OBJECT_SELF);
    object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,OBJECT_SELF);
    object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,OBJECT_SELF);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,OBJECT_SELF);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,OBJECT_SELF);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,OBJECT_SELF);
    object oBeltOld = GetItemInSlot(INVENTORY_SLOT_BELT,OBJECT_SELF);
    object oArmsOld = GetItemInSlot(INVENTORY_SLOT_ARMS,OBJECT_SELF);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,OBJECT_SELF);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,OBJECT_SELF);
    if (GetIsObjectValid(oShield))
    {   //1.71: this is now custom content compatible, polymorph will merge custom left-hand only items such as flags
        if (GetWeaponRanged(oShield) || IPGetIsMeleeWeapon(oShield))
        {
            oShield = OBJECT_INVALID;
        }
    }

    int nConBonus;
    if (bWeapon)
    {
        nConBonus = IPGetBestConBonus(nConBonus,oWeaponOld);
    }
    if (bArmor)
    {
        nConBonus = IPGetBestConBonus(nConBonus,oArmorOld);
        nConBonus = IPGetBestConBonus(nConBonus,oHelmetOld);
        nConBonus = IPGetBestConBonus(nConBonus,oShield);
    }
    if (bItems)
    {
        nConBonus = IPGetBestConBonus(nConBonus,oRing1Old);
        nConBonus = IPGetBestConBonus(nConBonus,oRing2Old);
        nConBonus = IPGetBestConBonus(nConBonus,oAmuletOld);
        nConBonus = IPGetBestConBonus(nConBonus,oCloakOld);
        nConBonus = IPGetBestConBonus(nConBonus,oBeltOld);
        nConBonus = IPGetBestConBonus(nConBonus,oBootsOld);
    }
    if (bArms)
    {
        nConBonus = IPGetBestConBonus(nConBonus,oArmsOld);
    }

    //Apply the VFX impact and effects
    ePoly = EffectPolymorph(nPoly);
     if(nConBonus > 0)
     {//1.70 patch fix by Shadooow: this fixes dying when unpolymorphed issue as well as server crash related to this
     ePoly = EffectLinkEffects(ePoly,EffectAbilityIncrease(ABILITY_CONSTITUTION,nConBonus));
     }
    ePoly = ExtraordinaryEffect(ePoly);
    ClearAllActions(); // prevents an exploit
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, OBJECT_SELF, HoursToSeconds(nDuration));

    object oWeaponNew = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,OBJECT_SELF);
    object oArmorNew = GetItemInSlot(INVENTORY_SLOT_CARMOUR,OBJECT_SELF);

    if (bWeapon)
    {
            IPWildShapeCopyItemProperties(oWeaponOld,oWeaponNew, TRUE);
    }
    if (bArmor)
    {
        IPWildShapeCopyItemProperties(oHelmetOld,oArmorNew);
        IPWildShapeCopyItemProperties(oArmorOld,oArmorNew);
        IPWildShapeCopyItemProperties(oShield,oArmorNew);
    }
    if (bItems)
    {
        IPWildShapeCopyItemProperties(oRing1Old,oArmorNew);
        IPWildShapeCopyItemProperties(oRing2Old,oArmorNew);
        IPWildShapeCopyItemProperties(oAmuletOld,oArmorNew);
        IPWildShapeCopyItemProperties(oCloakOld,oArmorNew);
        IPWildShapeCopyItemProperties(oBootsOld,oArmorNew);
        IPWildShapeCopyItemProperties(oBeltOld,oArmorNew);
    }
    if (bArms)
    {
        IPWildShapeCopyItemProperties(oArmsOld,oArmorNew);
    }
    if (GetLocalInt(GetModule(),"71_POLYMORPH_STACK_ABILITY_BONUSES"))
    {
        IPWildShapeStackAbilityBonuses(oArmorNew);
    }

    // track polymorphed
    //SetCreaturePolymorphed(spell.Target);
    CreaturePolymorphed(oTarget);
}
