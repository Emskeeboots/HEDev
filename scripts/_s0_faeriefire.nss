//::///////////////////////////////////////////////
//:: _s0_faeriefire
//:://////////////////////////////////////////////
/*
    Faerie Fire (idea by Carcerian)
    This spell script adapts the idea to work as a druid spell

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 16)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "NW_I0_SPELLS"

#include "x2_inc_spellhook"

#include "_inc_spells"

void main()
{
    // Spellcast Hook Code
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode())
        return;

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_10);
    int FXColor, FXAura;
    float fDelay;

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    // * Duration ------------------------------------------
    int nDuration   = spell.Level;
    if(spell.Meta==METAMAGIC_EXTEND)    //Duration is +100%
        nDuration   = nDuration * 2;
    float fDuration = RoundsToSeconds(nDuration);

    switch (spell.Id)
    {
        case 848: FXColor = VFX_DUR_LIGHT_RED_5;    FXAura = VFX_DUR_AURA_RED;    break;
        case 849: FXColor = VFX_DUR_LIGHT_YELLOW_5; FXAura = VFX_DUR_AURA_YELLOW; break;
        case 850: FXColor = VFX_DUR_LIGHT_GREY_5;   FXAura = VFX_DUR_AURA_GREEN;  break;
        case 851: FXColor = VFX_DUR_LIGHT_BLUE_5;   FXAura = VFX_DUR_AURA_BLUE;   break;
        case 852: FXColor = VFX_DUR_LIGHT_PURPLE_5; FXAura = VFX_DUR_AURA_PURPLE; break;
    }

    effect FaerieAura   = MagicalEffect(EffectVisualEffect(FXAura));
    effect FaerieGlow   = MagicalEffect(EffectVisualEffect(FXColor));
    effect eHidePenalty = EffectSkillDecrease(SKILL_HIDE, 10);
    effect FaerieFire   = EffectLinkEffects(FaerieAura, FaerieGlow);
           FaerieFire   = EffectLinkEffects(eHidePenalty, FaerieFire);

    object oCreature    = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, spell.Loc);
    while(GetIsObjectValid(oCreature))
    {
        // Make SR check.
        if(!MyResistSpell(OBJECT_SELF, oCreature))
        {
            fDelay = GetRandomDelay(0.2, 1.1);
            //Fire spell cast at event for target
            if(GetIsReactionTypeFriendly(oCreature) || GetFactionEqual(oCreature))
                SignalEvent(oCreature, EventSpellCastAt(OBJECT_SELF, SPELL_FAERIE_FIRE, FALSE));
            else
                SignalEvent(oCreature, EventSpellCastAt(OBJECT_SELF, SPELL_FAERIE_FIRE, TRUE));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,FaerieFire,oCreature, fDuration));
            // temporarily make targettable
        }
        //Get the next target in the specified area around the target
        oCreature = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, spell.Loc);
    }
}
