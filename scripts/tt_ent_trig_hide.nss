void main()
{

object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = oPC;

effect eEffect;
eEffect = EffectSkillIncrease(SKILL_HIDE, 10);

ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);

}
