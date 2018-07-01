/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
* File Name:  _s0_bubbwall
*
* Purpose:  ImpactScript for Bubble Wall spell.  Part of Custom Content Challenge
*           for November 2011, Underwater Stuff.
*
* Created By: Rubies
* Created On: 12-2-11
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
void main()
{
    effect eVis = EffectAreaOfEffect(51, "****", "****", "****");
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, GetSpellTargetLocation(), 12.0f);
}
