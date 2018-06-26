//::///////////////////////////////////////////////
//:: _s0_danclight
//:://////////////////////////////////////////////
/*
    Spell Script for Dancing Lights

    Summons the Dancing Light creature which will temporarily distract an unengaged opponent

*/
//:://////////////////////////////////////////////
//:: Created By: Henesua (2013 sept 15)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_spells"
#include "_inc_light"

void main()
{
    if (!X2PreSpellCastCode())
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;

    //Declare major variables
    spellsDeclareMajorVariables();

    string sRefDancingLight     = "dancinglight";
    effect   eImpact= EffectVisualEffect(97);

    // * determine duration
    int nDuration   = spell.Level; // rounds
    if(spell.Meta==METAMAGIC_EXTEND)
        nDuration   = nDuration *2; //Duration is +100%
    if(nDuration<4)
        nDuration   = 4;

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    object oLight = CreateObject(OBJECT_TYPE_CREATURE, sRefDancingLight, spell.Loc);
    SetLocalInt(oLight,"LEVEL", spell.Level);
    SetLocalObject(oLight, "CREATOR", OBJECT_SELF);
    SetLocalInt(oLight, "TIMER", nDuration);

    // light effect on Dancing Light
    //Declare major variables
    effect eVis = (EffectVisualEffect(VFX_DUR_LIGHT_WHITE_10));
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = SupernaturalEffect(EffectLinkEffects(eVis, eDur));
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oLight);
    SetLocalInt(oLight,LIGHT_VALUE,2);
}
