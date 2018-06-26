//::///////////////////////////////////////////////
//:: _s0_clair_b
//:://////////////////////////////////////////////
/*
    AOE on Exit for a Scry Sensor

    When no more creatures with INT of 5 or greater are in area,
    restore cutscene invis
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 feb 20)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_constants"

void main()
{
    object oSensor = GetLocalObject(OBJECT_SELF, "PAIRED");

    if(!GetIsObjectValid(oSensor)){DestroyObject(OBJECT_SELF,0.1);} // cleanup

    // entering object
    object oCreature= GetExitingObject();
    if(GetObjectType(oCreature)!=OBJECT_TYPE_CREATURE)
        return;

    SetAILevel(oCreature, AI_LEVEL_DEFAULT);

    // send exit AOE event to sensor
    if(oCreature!=oSensor)
    {
        if(oCreature!=GetLocalObject(oSensor, "CREATOR") && GetObjectHeard(oCreature, oSensor))
        {
            SetLocalObject(oSensor, "USERD_EXIT", oCreature);
            SignalEvent(oSensor, EventUserDefined(5551));
        }
    }
    else
        DestroyObject(OBJECT_SELF,0.1); // cleanup

    if(GetAbilityScore(oCreature, ABILITY_INTELLIGENCE)>5)
    {
      // initialize sensor data
      int nCount      = GetLocalInt(oSensor, "CREATURES_IN_AOE")-1;
      SetLocalInt(oSensor, "CREATURES_IN_AOE", nCount);

      if(!nCount)
      {
        effect eVFX     = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
        effect eInvis   = EffectEthereal();
               eInvis   = EffectLinkEffects(eVFX,eInvis);
               eInvis   = SupernaturalEffect(eInvis);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eInvis, oSensor);
      }// no creatures in area
    }// creatures with INT greater than 5
}
