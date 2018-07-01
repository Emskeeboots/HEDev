//::///////////////////////////////////////////////
//:: _s0_polyother
//:://////////////////////////////////////////////
/*
    Spell Script for Baleful Polymorph

    Transforms a creature target into a tiny, inoffensive creature
    this is a wicked spell if cast on a player as they will be out of comission for hours

    from original spell description:
    Incorporeal or gaseous creatures are immune to baleful polymorph,
*/
//:://////////////////////////////////////////////
//:: Created:  Henesua (2013 sept 16)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_color"

#include "_inc_util"  // creature functions
#include "_inc_spells"

void main()
{
    // Spellcast Hook Code
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode())
        return;

    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_polyother - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    // spells fail on incorporeal creatures because they have no body to change
    // I'm not sure what else to check to determine whether the target is incorporeal
    // perhaps
    if(CreatureGetIsIncorporeal(spell.Target))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE),spell.Target);
        FloatingTextStringOnCreature(RED+"Incorporeal beings are immune to Baleful Polymorph.", OBJECT_SELF, FALSE);
        return;
    }

    effect eVis     = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly;
    int nPoly;
    // shapechangers can automatically shift out of the baleful polymorph, others are bLocked from doing so
    int bLocked     = TRUE;
    if(     GetRacialType(spell.Target)==RACIAL_TYPE_SHAPECHANGER
        ||  GetLevelByClass(CLASS_TYPE_SHIFTER,spell.Target)
      )
        bLocked     = FALSE;


    // * Duration --------------------------------------------------------------
    int nDuration   = spell.Level;
    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration   = nDuration *2; //Duration is +100%
    float fDuration = HoursToSeconds(nDuration);

    // * Determine the form ----------------------------------------------------
    // It would be great if we changed this so that the caster could learn particular forms
    // amd then specify which one to use when casting the spell.
    // right now its just random: Mouse or Toad.
    if(d2()==1)
        nPoly   = 201; // mouse
    else
        nPoly   = 202; // toad
    ePoly = EffectLinkEffects(EffectPolymorph(nPoly, bLocked),EffectCurse(0,0,0,0,0,0));


    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(OBJECT_SELF, SPELL_BALEFUL_POLYMORPH, TRUE));

    //SR and saving throw
    if(     !MyResistSpell(spell.Caster, spell.Target)
        &&  !MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_SPELL, spell.Caster)
      )
    {
        //Apply the VFX impact and effects
        AssignCommand(spell.Target, ClearAllActions()); // prevents an exploit
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, spell.Target, fDuration);

        // how to make name and description generic?

        // track polymorphed
        CreaturePolymorphed(spell.Target,TRUE);
    }
}
