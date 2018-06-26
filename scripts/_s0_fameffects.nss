//::///////////////////////////////////////////////
//:: _s0_fameffects
//:://////////////////////////////////////////////
/*
    This spell is cast by the master of a familiar shortly after the familiar is summoned
    This enables us to track by spellid the familiar's effects on the caster
*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2013 jan 5)
//:: Modified:
//:://////////////////////////////////////////////

// THE MAGUS' INNOCUOUS FAMILIARS
#include "_inc_pets"

void main()
{
    // Only one of the following should be used. See FamiliarSpawnEvent(object oMaster)
    //object oFamiliar    = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);// more_efficient_familiar
    object oFamiliar    = GetLocalObject(OBJECT_SELF, FAMILIAR);// more_flexible_familiar

    int nFamIndex       = GetLocalInt(OBJECT_SELF, FAMILIAR_INDEX);
    string sBenefitType = Get2DAString(FAMILIAR_2DA, "MASTER_BENEFITS", nFamIndex );

    float fDist         = GetDistanceToObject(oFamiliar);
    int bBenefit        = TRUE;
    if(     fDist == -1.0
        ||  fDist>25.0
        ||  GetHasSpellEffect( SPELL_FAMILIAR_EFFECTS, OBJECT_SELF)
      )
    {
        bBenefit    = FALSE; // familiar is too distant for master to benefit
    }

    string sAlert, sBenefit, sAlign;
    effect eAlert, eBenefit;
    effect eAVFX        = EffectVisualEffect(VFX_IMP_HEAD_MIND);
    // Alertness Effect (only applied if master does not have Alertness feat)
    if(bBenefit && !GetHasFeat(FEAT_ALERTNESS))
    {
        // define effects
        eAlert      = EffectLinkEffects(EffectSkillIncrease(SKILL_SPOT, 2), EffectSkillIncrease(SKILL_LISTEN, 2));
        sAlert      = "you gain sharper senses ("+PALEBLUE+"+2 spot, +2 listen"+DMBLUE+")";
    }

    // Additional Benefits to the master ---------------------------------------
    // these are the special benefits per familiar type which can be customized
    if(bBenefit && sBenefitType!="")
    {
        struct BENEFITS Benefits = GetMasterBenefits(StringToInt(sBenefitType), sAlert!="");
        sBenefit    = Benefits.description;
        eBenefit    = Benefits.perk;
    }

    // Alignment shifting ------------------------------------------------------
    if(GetLocalInt(OBJECT_SELF,FAMILIAR_ALIGN_SHIFT))
    {
        int nAlign;
        // adjusting good/evil axis --------------------------------------------
        int nFamGood= GetAlignmentGoodEvil(oFamiliar);
        int nOldGood= GetAlignmentGoodEvil(OBJECT_SELF);
        if(nFamGood!=nOldGood)
        {
            int nDif    = GetGoodEvilValue(oFamiliar)-GetGoodEvilValue(OBJECT_SELF);
            int nAmt    = abs(nDif);

            if(nAmt<3)
                nAmt=1;
            else if(nAmt<5)
                nAmt=3;
            else
                nAmt=5;

            if(nDif<0)
            {
                nAlign +=1;
                AdjustAlignment(OBJECT_SELF,ALIGNMENT_EVIL,nAmt);
            }
            else
            {
                nAlign +=1;
                AdjustAlignment(OBJECT_SELF,ALIGNMENT_GOOD,nAmt);
            }
        }
        else if(nFamGood!=ALIGNMENT_NEUTRAL)
        {
            int nGood   = GetGoodEvilValue(OBJECT_SELF);
            if(nGood && nGood!=100)
            {
                nAlign +=1;
                AdjustAlignment(OBJECT_SELF,nFamGood,33);
            }
        }

        // adjusting law/chaos axis --------------------------------------------
        int nFamLaw = GetAlignmentLawChaos(oFamiliar);
        int nOldLaw = GetAlignmentLawChaos(OBJECT_SELF);
        if(nFamLaw!=nOldLaw)
        {
            int nDif    = GetLawChaosValue(oFamiliar)-GetLawChaosValue(OBJECT_SELF);
            int nAmt    = abs(nDif);

            if(nAmt<3)
                nAmt=1;
            else if(nAmt<5)
                nAmt=3;
            else
                nAmt=5;

            if(nDif<0)
            {
                nAlign +=1;
                AdjustAlignment(OBJECT_SELF,ALIGNMENT_CHAOTIC,nAmt);
            }
            else
            {
                nAlign +=1;
                AdjustAlignment(OBJECT_SELF,ALIGNMENT_LAWFUL,nAmt);
            }
        }
        else if(nFamLaw!=ALIGNMENT_NEUTRAL)
        {
            int nLaw    = GetLawChaosValue(OBJECT_SELF);
            if(nLaw && nLaw!=100)
            {
                nAlign +=1;
                AdjustAlignment(OBJECT_SELF,nFamLaw,33);
            }
        }

        // fundamental change
        if(nOldLaw!=GetAlignmentLawChaos(OBJECT_SELF) || nOldGood!=GetAlignmentGoodEvil(OBJECT_SELF))
            nAlign +=3;

        if(nAlign==0)
            sAlign  = GetName(oFamiliar)+" is happy with you.";
        else if(nAlign<3)
            sAlign  = GetName(oFamiliar)+" spins your moral compass.";
        else
            sAlign  = GetName(oFamiliar)+" gives you a new outlook on the world.";

        DeleteLocalInt(OBJECT_SELF,FAMILIAR_ALIGN_SHIFT);
    }

    // Feedback and Perks ------------------------------------------------------
    if(sBenefit!="" || sAlert!="" || sAlign!="")
    {
        // apply effects
        effect ePerk;
        if(sAlert!="")
        {
            ePerk   = eAlert;
            if(sBenefit!="")
                ePerk   = EffectLinkEffects(ePerk, eBenefit);
        }
        else
        {
            ePerk   = eBenefit;
        }

        ePerk   = SupernaturalEffect(ePerk);// not removed by rest. - but dispellable

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eAVFX, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePerk, OBJECT_SELF);

        // give text feedback
        if(sAlert!="" || sBenefit!="")
            SendMessageToPC(OBJECT_SELF, DMBLUE+"With "+GetName(oFamiliar)+" nearby, "+sAlert+sBenefit+".");
        if(sAlign!="")
            SendMessageToPC(OBJECT_SELF, PINK+sAlign);
    }
}
