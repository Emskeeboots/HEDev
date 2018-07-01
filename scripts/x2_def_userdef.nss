//::///////////////////////////////////////////////
//:: Name x2_def_userdef
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On User Defined Event script
*/
//:://////////////////////////////////////////////
//:: Created: Keith Warner June 11/03
//:: Modified: Henesua (2013 dec 29)
//:://////////////////////////////////////////////

#include "_inc_vfx"
#include "_inc_constants"
#include "_inc_util"

#include "x0_i0_behavior"
#include "nw_i0_generic"

#include "x2_inc_itemprop"

// Bioware
const int EVENT_USER_DEFINED_PRESPAWN       = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN      = 1511;

void AveDoAnimLoop(int AnimType,float fVar1,float fVar2, float fIterationDelay)
{
DelayCommand(fIterationDelay,AveDoAnimLoop(AnimType,fVar1,fVar2,fIterationDelay));
PlayAnimation(AnimType,fVar1,fVar2);
}

void AveDoEffectLoop(int nDurationType,effect eEffectToLoop, object oTarget,float fIterationDelay)
{
    DelayCommand(fIterationDelay,AveDoEffectLoop(nDurationType,eEffectToLoop,oTarget,fIterationDelay));
    ApplyEffectToObject(nDurationType,eEffectToLoop,oTarget);
}


void main()
{
    int nUser = GetUserDefinedEventNumber();
    // HEARTBEAT ---------------------------------------------------------------
    if(nUser == EVENT_HEARTBEAT )
    {
        ExecuteScript(GetLocalString(OBJECT_SELF, "USERDEF_HEARTBEAT"), OBJECT_SELF);
    }
    // PERCEIVE ----------------------------------------------------------------
    else if(nUser == EVENT_PERCEIVE)
    {
        ExecuteScript(GetLocalString(OBJECT_SELF, "USERDEF_PERCEIVE"), OBJECT_SELF);
        DeleteLocalObject(OBJECT_SELF, "PERCEIVED");
        DeleteLocalString(OBJECT_SELF, "PERCEIVED_TYPE");
    }

    // END OF COMBAT ROUND -----------------------------------------------------
    else if(nUser == EVENT_END_COMBAT_ROUND)
    {

    }

    // ON DIALOGUE -------------------------------------------------------------
    else if(nUser == EVENT_DIALOGUE)
    {

    }

    // ATTACKED ----------------------------------------------------------------
    else if(nUser == EVENT_ATTACKED)
    {
        ExecuteScript(GetLocalString(OBJECT_SELF, "USERDEF_ATTACKED"), OBJECT_SELF);
        DeleteLocalObject(OBJECT_SELF, "ATTACKED");
    }

    // DAMAGED -----------------------------------------------------------------
    else if(nUser == EVENT_DAMAGED)
    {

    }

    // SPELLCAST AT ------------------------------------------------------------
    else if(nUser == EVENT_SPELL_CAST_AT)
    {

        // Garbage Collection
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        DeleteLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
    }

    // DEATH  - do not use for critical code, does not fire reliably all the time
    else if(nUser == 1007)
    {


    }

    // DISTURBED ---------------------------------------------------------------
    else if(nUser == EVENT_DISTURBED)
    {

    }

    // ALERTED -----------------------------------------------------------------
    else if(nUser == EVENT_ALERTED)
    {
        // right now state of alert is on or off.
        // do we want to enable responses to different alarms?
        // if so we'll need a way of discerning between alarms
        SetLocalInt(OBJECT_SELF, "AI_ALERTED", TRUE);

        object oAlarm   = GetLocalObject(OBJECT_SELF, "ALARM_SOURCE");

        // spread the alarm
        SpeakString(SHOUT_ALERT,TALKVOLUME_SILENT_SHOUT);
        // actually speak?



        if(GetLocalInt(OBJECT_SELF, "AI_STEALTHY"))
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);

        // extension
        string sUserAlerted = GetLocalString(OBJECT_SELF, "USERDEF_ALERTED");
        if(sUserAlerted!="")
            ExecuteScript(sUserAlerted, OBJECT_SELF);
    }

    // PRESPAWN ----------------------------------------------------------------
    else if (nUser == EVENT_USER_DEFINED_PRESPAWN)
    {
        int nRace   = GetRacialType(OBJECT_SELF);
        int nEmpDC  = 15+GetHitDice(OBJECT_SELF);
        if( nRace==RACIAL_TYPE_BEAST)
            nEmpDC  += 4;
        else if(nRace==RACIAL_TYPE_MAGICAL_BEAST)
            nEmpDC  += 8;
        else if(nRace==RACIAL_TYPE_SHAPECHANGER)
            nEmpDC  += 12;

        if(GetLocalInt(OBJECT_SELF, "AI_HERBIVORE"))
        {
            SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
            SetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE);
        }
        else if(GetLocalInt(OBJECT_SELF, "AI_OMNIVORE"))
        {
            SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
            SetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE);
        }
        else if(GetLocalInt(OBJECT_SELF, "AI_CARNIVORE"))
        {
            SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
            SetBehaviorState(NW_FLAG_BEHAVIOR_CARNIVORE);
        }

        SetLocalInt(OBJECT_SELF, "ANIMAL_EMPATHY_DC", nEmpDC);
    }

    // POSTSPAWN ----------------------------------------------------------------
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {
        // taken from tt_npc_onspawn

        // SIT //
        object oSelf = OBJECT_SELF;
        if (GetLocalInt(oSelf, "npc_sit")== 1)
        {
            DelayCommand(2.0, ActionSit( GetNearestObjectByTag( "Chair")));
        }
        else if (GetLocalInt(oSelf, "npc_sit_sleep")== 1)
        {
            DelayCommand(0.0, ActionSit( GetNearestObjectByTag( "Chair")));
            AveDoEffectLoop(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oSelf,20.0);
            //DelayCommand(10.0, ExecuteScript("tt_npc_onspawn",OBJECT_SELF));
        }

        else if (GetLocalInt(oSelf, "npc_sit_cross")== 1)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_SIT_CROSS,1.0,20.0,20.0);
            //ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0f, 9999.0f);
        }

        // VFX //
        //spawn_instant_vfx (int)=vfx number of instant vfx
        //spawn_permanent_vfx (int)=vfx number of permanent, undispellable vfx
        //spawn_temporary_vfx (int)=vfx number of temporary, undispellable vfx
        //spawn_temporary_duration (float)=number of seconds the temporary vfx lasts

        int nInstVfx=GetLocalInt(oSelf,"spawn_instant_vfx");
        if(nInstVfx>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,SupernaturalEffect(EffectVisualEffect(nInstVfx)),oSelf);
        }

        int nPermVfx=GetLocalInt(oSelf,"spawn_permanent_vfx");
        if(nPermVfx>0)
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectVisualEffect(nPermVfx),oSelf);
        }

        int nTempVfx=GetLocalInt(oSelf,"spawn_temporary_vfx");
        float fTempDuration=GetLocalFloat(oSelf,"spawn_temporary_duration");
        if(nTempVfx>0)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,SupernaturalEffect(EffectVisualEffect(nTempVfx)),oSelf,fTempDuration);
        }

        /* EMOTES //
        Set Integer "npc_emote" = X on Variables
        Se forum for list of emotes

        */

        int nEmote=GetLocalInt(oSelf,"npc_emote");
        if(GetLocalInt(oSelf,"npc_emote")==1)
        {
            //failsafe - check correct phenotype
            if (GetPhenoType(OBJECT_SELF) != 40)
                SetPhenoType(40);
            effect eBanjo = EffectVisualEffect(2320);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eBanjo,OBJECT_SELF);
            ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM1,1.0,60000.0);
        }
        else if(nEmote>0)
        {
            DelayCommand(0.0, AveDoAnimLoop(nEmote,1.0,20.0,20.0));
        }
        /*
        else if(GetLocalInt(oSelf,"npc_emote")==2)
        {
            ActionSit( GetNearestObjectByTag( "Chair"));
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM2,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==3)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM3,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==4)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM4,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==5)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM5,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==7)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM7,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==10)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM10,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==17)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM17,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==18)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM18,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==19)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_CUSTOM19,1.0,20.0,20.0);
        }

        else if(GetLocalInt(oSelf,"npc_emote")==30)
        {
            AveDoAnimLoop(ANIMATION_LOOPING_GET_MID,1.0,20.0,20.0);
        }
        */

    }
}

