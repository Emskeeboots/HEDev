void main()
{

object oPC = GetClickingObject();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = oPC;

effect eEffect;
eEffect = EffectCutsceneGhost();

eEffect = SupernaturalEffect(eEffect);

ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);

}
