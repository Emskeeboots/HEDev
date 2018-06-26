//::///////////////////////////////////////////////
//:: _s0_dimswap
//:: Dimensional Swap
//:://////////////////////////////////////////////
// The second sub-spell granted when a player picks Dimensional Control,
// Dimensional Swap verifies line-of-sight, then swaps location of the caster
// and the target, stunning both for 6 seconds.
// Why? Well, why not, it's cool. At least I thought so. D:
// It's a subspell of Dimension Door because the caster will probably end up
// getting stuck on little normally-inaccessible areas, and can use DD
// to get out.
//:://////////////////////////////////////////////
//:: Created:   Sarah M. / Rubies
//:: Edited:    shinypearls 28/11/12
//                  removed notification of failure,
//                  could not locate sound file for it
//                  removed damage
//                  THIS VERSION IS NOT A SUB SPELL!!
//                  lowered the cast time to be reasonable for vanilla nwn
//:: Modified:  Henesua (2013 sept 29)  integrated with community patch and spell focus
//::////////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_color"
#include "_inc_spells"

//#include "_inc_constants"
//#include "_inc_util"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();

    object oArea        = GetArea(OBJECT_SELF);

    // Disable in areas which forbid teleportation
    if ( GetLocalInt(oArea, "AREA_NOTELEPORT") )
    {
        SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILED. You cannot teleport in this area.");
        return;
    }

    // Readability
    int VFX_IMP_DIMENSIONAL_SWAP = 1668;


    // SPECIAL TARGETTING - accepts "Spell Focus"- see _inc_util
    if(GetLocalInt(OBJECT_SELF, SPELLFOCUS_USE))
    {
        object oFocus   = GetLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        //garbage collection
        DeleteLocalInt(OBJECT_SELF, SPELLFOCUS_USE);
        DeleteLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        // Focus Data
        int nFocusType  = GetLocalInt(oFocus, SPELLFOCUS_TYPE);
        if(nFocusType==1)
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: Target must be a creature.");
            return;
        }
        else if(nFocusType==2)
            spell.Target    = GetLocalObject(oFocus, SPELLFOCUS_CREATURE);
        else if(nFocusType==3)
            spell.Target    = GetPCByPCID(GetLocalString(oFocus, SPELLFOCUS_CREATURE));

        oArea = GetAreaFromLocation(GetLocation(spell.Target));

        if(!GetIsObjectValid(spell.Target))
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail. You cannot teleport to your target at this time.");
            return;
        }
        else if(!GetIsObjectValid(oArea))
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: "+GetName(spell.Target)+" must be in the same area.");
            return;
        }
        else if(GetArea(OBJECT_SELF)==oArea)
        {
            SendMessageToPC(OBJECT_SELF, DMBLUE+"Success: "+GetName(spell.Target)+" targeted.");
            if(SPELLFOCUS_ONE_USE)
                DestroyObject(oFocus, 0.5);
        }
        else
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: "+GetName(spell.Target)+" must be in the same area.");
            return;
        }
    }
    // END SPECIAL TARGETTING --------------------------------------------------


    // loc Defs
    location lSpellTarget   = GetLocation(spell.Target);
    location lSpellSelf     = GetLocation(OBJECT_SELF);

    // eff Defs
    effect eVis             = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);  // Just some visual feedback to help the player know that they're immobilized.
    effect eEff             = EffectCutsceneImmobilize(); // Looks like you need some PARLYZ HEAL. :3
    effect eLink            = EffectLinkEffects(eVis, eEff);

    SignalEvent(spell.Target, EventSpellCastAt(OBJECT_SELF, spell.Id, TRUE));
    if(     !MyResistSpell(spell.Caster, spell.Target)
        &&  !MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC)
      )
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DIMENSIONAL_SWAP), lSpellTarget);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DIMENSIONAL_SWAP), lSpellSelf);

        AssignCommand(spell.Target, ClearAllActions(TRUE));
        AssignCommand(spell.Target, ActionJumpToLocation(lSpellSelf));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, 6.05f);

        ClearAllActions(TRUE);
        ActionJumpToLocation(lSpellTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, 6.0f);
    }
    else
    {
        SendMessageToPC(OBJECT_SELF, RED+"Fail: "+GetName(spell.Target)+" resists the spell.");
    }
}
