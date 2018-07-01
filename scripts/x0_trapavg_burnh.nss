//::///////////////////////////////////////////////////
//:: X0_TRAPAVG_FARRW
//:: OnTriggered script for a projectile trap
//:: Spell fired: SPELL_FLAME_ARROW
//:: Spell caster level: 5
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/17/2002
//::///////////////////////////////////////////////////

#include "x0_i0_projtrap"

void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

object oCaster;
oCaster = GetObjectByTag("x0_trapavg_burnh");

object oTarget;
oTarget = oPC;

AssignCommand(oCaster, ActionCastSpellAtObject(SPELL_BURNING_HANDS, oTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, FALSE));

}

