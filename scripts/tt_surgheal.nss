void main()
{

object oTarget = GetPCSpeaker();
int bHarmful, iSurg, iToHeal;
effect eEffect;



if (GetGold(oTarget) >= 35)
       {

            TakeGoldFromCreature(35, oTarget, TRUE);
            if (!GetIsObjectValid(oTarget)) return;

            iSurg = Random(6);
            bHarmful = FALSE;

            switch(iSurg)
               {
                 case 5:
                    {
                       bHarmful = TRUE;
                       eEffect = EffectDamage(Random(3)+1, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL);
                       ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oTarget);
                       ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_RED_SMALL), oTarget);
                       PlayVoiceChat(VOICE_CHAT_PAIN2, oTarget);
                       SendMessageToPC( oTarget, "Something goes wrong and you feel a horrible pain!");
                       break;
                     }
                 default: iToHeal = iSurg + 2; break;
              }

            if (!bHarmful)
              {
                effect eHeal = EffectHeal(iToHeal);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE), oTarget);
              }

            }


 else
     {
          AssignCommand(GetObjectByTag("tt_surgeon"), ActionSpeakString("No gold, no treatment! Don't try to fool me!"));
     }



}




