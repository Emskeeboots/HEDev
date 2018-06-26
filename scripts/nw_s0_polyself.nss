//::///////////////////////////////////////////////
//:: Polymorph Self
//:: NW_S0_PolySelf.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The PC is able to changed their form to one of
    several forms.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 21, 2002
//:://////////////////////////////////////////////
//:: Modified: Henesua (2012 jul 14) hook for polymorph self potions
//:: Modified: Henesua (2012 sep 28) change to new polytype
                                    // added animal shapes spell forms
//:: Modified: Henesua (2012 oct 10) ClearAppearanceData
//:: Modified: Henesua (2014 jan 25) Merged Krit's Horse Fix

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x3_inc_horse"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis     = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly;
    int nPoly;
    int nDuration   = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration *2; //Duration is +100%

    int nItemType   = GetBaseItemType(spell.Item);
    int nSpiritType = GetAnimalCompanionCreatureType(spell.Caster);
    int bArmor, bItems, bWeapon;

    // Horse anti-shapechange code.
    /*
    if ( !GetLocalInt(GetModule(), HORSELV_NO_SHAPESHIFT_CHECK) )
    {
        // The check is not disabled. Look for a mounted target.
        if ( HorseGetIsMounted(spell.Target) )
        {
            // Inform the target and abort.
            FloatingTextStrRefOnCreature(111982, spell.Target, FALSE); // "You cannot shapeshift while mounted."
            return;
        }
    }
    */
    string sName;
    int bSuccess;
    int merge_items = FALSE;
    // Poly Morph Potions ------------------------------------------------------
    if(nItemType==BASE_ITEM_POTIONS)
    {
        string sPotion  = GetTag(spell.Item);
        // polymorph types for potions
        if(sPotion=="polymouse")
        {
            bSuccess    = TRUE;
            nPoly       = 201; // polymorph type mouse
            nDuration   = 1; // hour
            sName       = "Mouse";
            merge_items = TRUE;
        }
    }

    int nRace   = GetRacialType(spell.Caster);
    if(     nRace==RACIAL_TYPE_FEY
        //||  nRace==RACIAL_TYPE_ANIMORPH
        ||  nRace==15   // scalykind
      )
    {
        bArmor  = 1;
        bItems  = 1;
    }


    // Typical Polymorph Self Spell --------------------------------------------
    if(!bSuccess)
    {
        //Determine Polymorph subradial type
        // Polymorph Self (level 4) ------------
        if(spell.Id == 387)
        {
            spell.Id= SPELL_POLYMORPH_SELF;
            nPoly   = POLYMORPH_TYPE_GIANT_SPIDER;
            sName   = "Giant Spider";
        }
        else if (spell.Id == 388)
        {
            spell.Id= SPELL_POLYMORPH_SELF;
            nPoly   = 208; // poly type ogre
            sName   = "Ogre";
            bWeapon = 1;
            bItems  = 1;
            bArmor  = 1;
        }
        else if (spell.Id == 389)
        {
            spell.Id= SPELL_POLYMORPH_SELF;
            nPoly = 206; // poly type wyvern
            sName   = "Wyvern";
        }
        else if (spell.Id == 390)
        {
            spell.Id= SPELL_POLYMORPH_SELF;
            nPoly = 209; // poly type crab
            sName   = "Giant Crab";
            bItems  = 1;
            bArmor  = 1;
        }
        else if (spell.Id == 391)
        {
            spell.Id= SPELL_POLYMORPH_SELF;
            nPoly = 210; // poly type ochre jelly
            sName   = "Ochre Jelly";
        }

        // Animal Shapes (level 3) --------------
        else if (spell.Id == 870)
        {
            spell.Id= 869;
            nPoly = 201; // poly type mouse
            sName   = "Mouse";
            if( nSpiritType==0 ) // badger spirit
                bItems  = 1;
            if(spell.Class==CLASS_TYPE_RANGER)
                bArmor  = 1;

            merge_items = TRUE;
        }
        else if (spell.Id == 871)
        {
            spell.Id= 869;
            nPoly = 202; // poly type frog
            sName   = "Frog";
            if(spell.Class==CLASS_TYPE_RANGER)
                bArmor  = 1;

            merge_items = TRUE;
        }
        else if (spell.Id == 872)
        {
            spell.Id= 869;
            nPoly = 203; // poly type raven
            sName   = "Raven";
            if( nSpiritType==4 ) // hawk spirit
                bItems  = 1;
            if(spell.Class==CLASS_TYPE_RANGER)
                bArmor  = 1;

            merge_items = TRUE;
        }
        else if (spell.Id == 873)
        {
            spell.Id= 869;
            nPoly = 204; // poly type bat
            sName   = "Bat";
            if(spell.Class==CLASS_TYPE_RANGER)
                bArmor  = 1;

            merge_items = TRUE;
        }
        else if (spell.Id == 874)
        {
            spell.Id= 869;
            nPoly = 205; // poly type cat
            sName   = "Cat";
            if( nSpiritType==5 ) // panther spirit
                bItems  = 1;
            if(spell.Class==CLASS_TYPE_RANGER)
                bArmor  = 1;

            merge_items = TRUE;
        }
    }

    if(!GetIsPC(OBJECT_SELF))
    {
        SetLocalString(OBJECT_SELF, "LAST NAME", GetName(OBJECT_SELF));
        SetName(OBJECT_SELF, sName);

      if(CreatureGetIsIncorporeal(OBJECT_SELF))
      {
        effect eEf  = GetFirstEffect(OBJECT_SELF);
        while(GetIsEffectValid(eEf))
        {
            if(     GetEffectCreator(eEf)==OBJECT_SELF
                &&  GetEffectSpellId(eEf)==-1
                &&  GetEffectType(eEf)==EFFECT_TYPE_CUTSCENEGHOST
              )
            {
                RemoveEffect(OBJECT_SELF, eEf);
            }
            eEf = GetNextEffect(OBJECT_SELF);
        }
      }
    }

        // Gather item properties for merge
        object oWeaponOld   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,OBJECT_SELF);
        object oArmorOld    = GetItemInSlot(INVENTORY_SLOT_CHEST,OBJECT_SELF);
        object oRing1Old    = GetItemInSlot(INVENTORY_SLOT_LEFTRING,OBJECT_SELF);
        object oRing2Old    = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,OBJECT_SELF);
        object oAmuletOld   = GetItemInSlot(INVENTORY_SLOT_NECK,OBJECT_SELF);
        object oCloakOld    = GetItemInSlot(INVENTORY_SLOT_CLOAK,OBJECT_SELF);
        object oBootsOld    = GetItemInSlot(INVENTORY_SLOT_BOOTS,OBJECT_SELF);
        object oBeltOld     = GetItemInSlot(INVENTORY_SLOT_BELT,OBJECT_SELF);
        object oHelmetOld   = GetItemInSlot(INVENTORY_SLOT_HEAD,OBJECT_SELF);
        object oShield      = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,OBJECT_SELF);
        if(GetIsObjectValid(oShield))
        {
          if(     GetBaseItemType(oShield) !=BASE_ITEM_LARGESHIELD
              &&  GetBaseItemType(oShield) !=BASE_ITEM_SMALLSHIELD
              &&  GetBaseItemType(oShield) !=BASE_ITEM_TOWERSHIELD
            )
            oShield = OBJECT_INVALID;
        }

    ePoly = EffectPolymorph(nPoly);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                                                        //returns master spell as set above
    //Apply the VFX impact and effects
    AssignCommand(spell.Target, ClearAllActions()); // prevents an exploit
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, spell.Target, HoursToSeconds(nDuration));

    object oWeaponNew   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,OBJECT_SELF);
    if(bWeapon)
        IPWildShapeCopyItemProperties(oWeaponOld,oWeaponNew, TRUE);

    object oArmorNew    = GetItemInSlot(INVENTORY_SLOT_CARMOUR,OBJECT_SELF);
    if(bArmor)
    {
        IPWildShapeCopyItemProperties(oShield,oArmorNew);
        IPWildShapeCopyItemProperties(oHelmetOld,oArmorNew);
        IPWildShapeCopyItemProperties(oArmorOld,oArmorNew);
    }

    if(bItems)
    {
        IPWildShapeCopyItemProperties(oRing1Old,oArmorNew);
        IPWildShapeCopyItemProperties(oRing2Old,oArmorNew);
        IPWildShapeCopyItemProperties(oAmuletOld,oArmorNew);
        IPWildShapeCopyItemProperties(oCloakOld,oArmorNew);
        IPWildShapeCopyItemProperties(oBootsOld,oArmorNew);
        IPWildShapeCopyItemProperties(oBeltOld,oArmorNew);
    }

    // track polymorphed
    CreaturePolymorphed(spell.Target,merge_items);
}
