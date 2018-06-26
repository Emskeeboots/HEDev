//::///////////////////////////////////////////////
//:: Searing Light
//:: s_SearLght.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Focusing holy power like a ray of the sun, you project
//:: a blast of light from your open palm. You must succeed
//:: at a ranged touch attack to strike your target. A creature
//:: struck by this ray of light suffers 1d8 points of damage
//:: per two caster levels (maximum 5d8). Undead creatures suffer
//:: 1d6 points of damage per caster level (maximum 10d6), and
//:: undead creatures particularly vulnerable to sunlight, such
//:: as vampires, suffer 1d8 points of damage per caster level
//:: (maximum 10d8). Constructs and inanimate objects suffer only
//:: 1d6 points of damage per two caster levels (maximum 5d6).
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: 02/05/2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 25, 2001
//:://////////////////////////////////////////////
//:: Modified: Henesua (2013 Sept 10) max 10d8 for undead
//::                                  max 10d6 for fungus, oozes, and others vulnerable to light
//::                                  max 5d4 for constructs

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

#include "_inc_util"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    int nNumber = spell.Level; // number of dice
    int nDamage, nDice;
    int nRace   = GetRacialType(spell.Target);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eRay = EffectBeam(VFX_BEAM_HOLY, spell.Caster, BODY_NODE_HAND);
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make an SR Check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Limit caster level
            if (nNumber > 10)
                nNumber = 10;

            //Check for racial type undead
            if(nRace == RACIAL_TYPE_UNDEAD)
            {
                nDice = 8;
            }
            // others who are vulnerable to light
            else if(    nRace == RACIAL_TYPE_OOZE
                    ||  CreatureGetIsFungus(spell.Target)
                    ||  spellsIsLightVulnerable(spell.Target)
                   )
            {
                nDice   = 6;
            }
            // maximum of 5 dicefor all others
            else
            {
                nNumber /= 2;
                if(nNumber < 1)
                    nNumber = 1;

                // constructs are the least vulnerable
                if (nRace == RACIAL_TYPE_CONSTRUCT)
                    nDice   = 4;
                else
                    nDice   = 6;
            }
            nDamage = MaximizeOrEmpower(nDice,nNumber,spell.Meta);

            //Set the damage effect
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_DIVINE);
            //Apply the damage effect and VFX impact
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
        }
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.7);
}
