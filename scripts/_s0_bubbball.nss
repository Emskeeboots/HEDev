/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
* File Name:  _s0_bubbball
*
* Purpose:  ImpactScript for Bubble Ball spell.  Part of Custom Content Challenge
*           for November 2011, Underwater Stuff.
*
* Created By: Rubies
* Created On: 12-2-11
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
void main()
{
    effect eVis = EffectVisualEffect(1149);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetSpellTargetLocation());
}
