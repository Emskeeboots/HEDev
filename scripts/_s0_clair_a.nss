//::///////////////////////////////////////////////
//:: _s0_clair_a
//:://////////////////////////////////////////////
/*
    AOE on Enter for a Scry Sensor

    Entering creature has a slight chance of noticing the scry sensor
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 19)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_constants"

void main()
{
    object oSensor = GetLocalObject(OBJECT_SELF, "PAIRED");

    // entering object
    object oCreature= GetEnteringObject();
    if(GetObjectType(oCreature)!=OBJECT_TYPE_CREATURE)
        return;

    SetAILevel(oCreature, AI_LEVEL_NORMAL);

    // send enter AOE event to sensor
    if(oCreature!=oSensor)
    {
        if(oCreature!=GetLocalObject(oSensor, "CREATOR") && GetObjectHeard(oCreature, oSensor))
        {
            SetLocalObject(oSensor, "USERD_ENTER", oCreature);
            SignalEvent(oSensor, EventUserDefined(5550));
        }
    }

    if(GetAbilityScore(oCreature, ABILITY_INTELLIGENCE)>5)
    {
      // initialize sensor data
      int nSpellId    = GetLocalInt(oSensor, "SCRY_SPELL"); // spell used to create the sensor
      object oCaster  = GetLocalObject(oSensor, "CREATOR"); // Creator of sensor
      int nCount      = GetLocalInt(oSensor, "CREATURES_IN_AOE")+1;
      SetLocalInt(oSensor, "CREATURES_IN_AOE", nCount);

      // Silent Scry check
      int bSuccess;
      //int nRank = GetSkillRank(SKILL_SCRY, oCreature);
        int nRank = GetSkillRank(SKILL_SPELLCRAFT, oCreature);
      int dRoll = d20(1);
      if( (nRank+dRoll) >= 20 )
        bSuccess=TRUE;

      if(       bSuccess
            &&  LineOfSightObject( oCreature, oSensor )
        )
      {
        if(GetIsPC(oCreature))
        {
            if(GetSkillRank(SKILL_SPELLCRAFT, oCreature, TRUE)>5)
                SendMessageToPC(oCreature,DMBLUE+"You discover a scry sensor...");
            else
                SendMessageToPC(oCreature,DMBLUE+"You notice something here...");
        }
        else
            PlayVoiceChat(  VOICE_CHAT_LOOKHERE, oCreature);

        // Remove cutscene invis
        int nEffect;
        effect eEffect  = GetFirstEffect(oSensor);
        while(GetIsEffectValid(eEffect))
        {
            nEffect = GetEffectType(eEffect);
            if( nEffect==EFFECT_TYPE_ETHEREAL )
                RemoveEffect(oSensor,eEffect);
            eEffect = GetNextEffect(oSensor);
        }
      }// succesful scry check
    }// END creatures with INT greater than 5
}
