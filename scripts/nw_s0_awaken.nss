//::///////////////////////////////////////////////
//:: Awaken
//:: NW_S0_Awaken
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell makes an animal ally more
    powerful, intelligent and robust for the
    duration of the spell.  Requires the caster to
    make a Will save to succeed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 10, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70, fix by Shadooow

- maximized version fixed
- the spell stacked before
*/
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 sept 12) Awaken is persistent

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x0_i0_spells"

#include "_inc_util"
#include "_inc_pets"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables
    spellsDeclareMajorVariables();

    int bReawaken   = GetLocalInt(spell.Target, "REAWAKEN"); // has this spell been cast by animal companion spawn
    DeleteLocalInt(spell.Target, "REAWAKEN");

    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eInt;
    effect eAttack = EffectAttackIncrease(2);
    effect eVis = EffectVisualEffect(VFX_IMP_HOLY_AID);

    int nInt, nDuration;
    if(bReawaken)
    {
        nInt        = GetLocalInt(spell.Target, "REAWAKEN_WISDOM");
        DeleteLocalInt(spell.Target, "REAWAKEN_WISDOM");
        nDuration   = GetLocalInt(spell.Target, "REAWAKEN_DURATION");
        DeleteLocalInt(spell.Target, "REAWAKEN_DURATION");
    }
    else
    {
        // Enter Metamagic Conditions
        nInt        = MaximizeOrEmpower(10,1,spell.Meta);
        nDuration   = 24;
        if (spell.Meta==METAMAGIC_EXTEND)
            nDuration = nDuration *2; //Duration is +100%
    }


    if(     bReawaken
        ||(     GetAssociateType(spell.Target)==ASSOCIATE_TYPE_ANIMALCOMPANION
            &&(    GetMaster(spell.Target)==spell.Caster
                || GetIsDM(spell.Caster)
               )
          )
      )
    {
        if(!GetHasSpellEffect(spell.Id,spell.Target))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

            eInt            = EffectAbilityIncrease(ABILITY_WISDOM, nInt);

            effect eLink    = EffectLinkEffects(eStr, eCon);
            eLink           = EffectLinkEffects(eLink, eAttack);
            eLink           = EffectLinkEffects(eLink, eInt);
            eLink           = EffectLinkEffects(eLink, eDur);
            eLink           = SupernaturalEffect(eLink);

            RemoveEffectsFromSpell(spell.Target, spell.Id);

            if(!bReawaken)
            {
                SetSkinInt(OBJECT_SELF, COMPANION_AWAKENED, GetTimeCumulative(TIME_HOURS)+nDuration);
                SetSkinInt(OBJECT_SELF, COMPANION_AWAKENED_WIS, nInt);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
            else
                SendMessageToPC(OBJECT_SELF, BLUE+GetName(spell.Target)+DMBLUE+" is still 'Awakened'.");

            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, HoursToSeconds(nDuration));

        }
    }
    else
    {
        FloatingTextStrRefOnCreature(83384,spell.Caster,FALSE);
    }
}
