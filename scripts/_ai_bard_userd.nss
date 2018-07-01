//::///////////////////////////////////////////////
//:: _ai_bard_userd
//:://////////////////////////////////////////////
/*
    Userdef AI for bards when they are in a place where they can perform

    This primarily executes on heartbeat
    BUT it can also be executed from other events to terminate itself

    Set this as custom userdef heartbeat event

 */
//:://////////////////////////////////////////////////
//:: Created: Henesua (2016 jan 16)
//:://////////////////////////////////////////////////


#include "_inc_util"
#include "_inc_craft"
//#include "v2_inc_vfx"
//#include "v2_inc_factions"

#include "nw_i0_generic"
// Bioware
const int EVENT_USER_DEFINED_PRESPAWN       = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN      = 1511;


//declarations ................................................................

int BardGetInstrumentVFX(object oRight=OBJECT_INVALID);

void BardStartPerformance();

void BardPrepareForPerformance(int nDur);

void BardRestoresAppearance();

void BardContinuePerformance();

void BardEndPerformance();

void BardAITerminate();


int BardGetInstrumentVFX(object oRight=OBJECT_INVALID)
{
    int nVFX;
    /*  // vfx not yet implemented
    if(oRight==OBJECT_INVALID)
        oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);

    if(GetIsObjectValid(oRight))
    {
        if(     GetBaseItemType(oRight)==107
            &&  GetItemAppearance(oRight, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE)==2
          )
        {
            int nInstrumentType = GetItemAppearance(oRight, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_MODEL_MIDDLE);
            if(nInstrumentType==7)
            {
                nVFX    = TOOL_BANJO+getVFXModifier(BODY_EFFECTS_TOOL, OBJECT_SELF);
            }
            else if(nInstrumentType==5)
            {
                nVFX    = TOOL_GUITAR+getVFXModifier(BODY_EFFECTS_TOOL, OBJECT_SELF);
            }
            else if(nInstrumentType==3)
            {
                nVFX    = TOOL_LUTE+getVFXModifier(BODY_EFFECTS_TOOL, OBJECT_SELF);
            }
            else
            {
                return 0;
            }
        }
    }
    if(!nVFX)
    {
        oRight  = GetItemPossessedBy(OBJECT_SELF,"instrument");
        if(     GetBaseItemType(oRight)==107
            &&  GetItemAppearance(oRight, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE)==2
          )
        {
            int nInstrumentType = GetItemAppearance(oRight, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_MODEL_MIDDLE);
            if(nInstrumentType==7)
            {
                nVFX    = TOOL_BANJO+getVFXModifier(BODY_EFFECTS_TOOL, OBJECT_SELF);
            }
            else if(nInstrumentType==5)
            {
                nVFX    = TOOL_GUITAR+getVFXModifier(BODY_EFFECTS_TOOL, OBJECT_SELF);
            }
            else if(nInstrumentType==3)
            {
                nVFX    = TOOL_LUTE+getVFXModifier(BODY_EFFECTS_TOOL, OBJECT_SELF);
            }
            else
            {
                return 0;
            }
        }
    }
    */// end vfx nt yet implemented
    return nVFX;
}

void BardStartPerformance()
{
    DeleteLocalInt(OBJECT_SELF,"PERFORMER_OFFSTAGE_STATUS");
    int nState  = GetLocalInt(OBJECT_SELF,"PERFORMER_STAGE_STATUS");

    if(!nState)
    {
        object oDest    = GetWaypointByTag("performer_stage");
        object oInterim = GetNearestObjectByTag("performer_stage_entry");
        if(     GetIsObjectValid(oDest)
            &&  GetArea(oDest)==GetArea(OBJECT_SELF)
          )
        {
            float fProximityToDest  = GetDistanceBetween(OBJECT_SELF,oDest);
            if(fProximityToDest<=2.0)
            {
                string sPerformScript   = GetLocalString(OBJECT_SELF,"PERFORM_SCRIPT");
                if(     sPerformScript==""
                    &&  BardGetInstrumentVFX()
                  )
                {
                    int nOffstagePheno = GetPhenoType(OBJECT_SELF);
                    SetLocalInt(OBJECT_SELF,"PERFORMER_PHENO_OFFSTAGE",nOffstagePheno);
                    if(nOffstagePheno != 40){ActionDoCommand(SetPhenoType(40));}
                }
                SetLocalInt(OBJECT_SELF,"PERFORMER_STAGE_STATUS",1);
            }
            else
            {
                if(     GetIsObjectValid(oInterim)
                    &&  GetDistanceBetween(OBJECT_SELF,oInterim)<fProximityToDest
                  )
                    ActionMoveToObject(oInterim,FALSE,0.0);

                ActionMoveToObject(oDest,FALSE,0.0);
                ActionDoCommand(SetFacing(GetFacing(oDest)));
                         object oItem    = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
            }
        }
        else
        {
            string sPerformScript   = GetLocalString(OBJECT_SELF,"PERFORM_SCRIPT");
            if(     sPerformScript==""
                &&  BardGetInstrumentVFX()
              )
            {
                int nOffstagePheno = GetPhenoType(OBJECT_SELF);
                SetLocalInt(OBJECT_SELF,"PERFORMER_PHENO_OFFSTAGE",nOffstagePheno);
                if(nOffstagePheno != 40){ActionDoCommand(SetPhenoType(40));}
            }
            SetLocalInt(OBJECT_SELF,"PERFORMER_STAGE_STATUS",1);
        }
    }
    else if(nState==1)
    {
        SetLocalInt(OBJECT_SELF,"PERFORMING",TRUE);
        SetLocalInt(OBJECT_SELF, "IN_CONV", TRUE);
        DeleteLocalInt(OBJECT_SELF,"PERFORMER_STAGE_STATUS");

        string sPerformScript   = GetLocalString(OBJECT_SELF,"PERFORM_SCRIPT");
        if(sPerformScript=="")
        {
            object oArea    = GetArea(OBJECT_SELF);

            int nTrack  =1;string sSongLength; int nDur; string sTrack="01";
            int nSongID = GetLocalInt(OBJECT_SELF,"PERFORM_SONG_01");

            int nFirstSongID    = nSongID;
            while(nSongID)
            {
                SetLocalInt(oArea,"SONG_ID_"+sTrack,nSongID);// set up song list on area
                sSongLength = Get2DAString("ambientmusic_x","LENGTH",nSongID);

                nDur       += StringToInt(sSongLength);// calculate the duration of the performance

                // get next track
                ++nTrack;
                if(nTrack<10)
                    sTrack  = "0"+IntToString(nTrack);
                else
                    sTrack  = IntToString(nTrack);
                nSongID     = GetLocalInt(OBJECT_SELF,"PERFORM_SONG_"+sTrack);
            }

            // set a blank track to finish with
            SetLocalInt(oArea,"SONG_ID_"+sTrack,100);// set up song list on area

            BardPrepareForPerformance(nDur);

            DeleteLocalInt(OBJECT_SELF, "SONG_ID_CURRENT");
            int nSecond     = GetTimeSecond();
            int nTime       = ConvertRealSecondsToGameSeconds(nDur+nSecond);
            int nSecondsNow = GetTimeCumulative(TIME_SECONDS)-nSecond;

            nTime += nSecondsNow;

            SetLocalInt(OBJECT_SELF, "PERFORM_END",nTime);

            ExecuteScript("_ex_music",oArea);
        }
        else
        {
            SetLocalInt(OBJECT_SELF,"PERFORMANCE_START",TRUE);
            ExecuteScript(sPerformScript,OBJECT_SELF);
            DeleteLocalInt(OBJECT_SELF,"PERFORMANCE_START");
        }

    }
}

void BardPrepareForPerformance(int nDur)
{
    object oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    SetLocalObject(OBJECT_SELF,"PERFORMER_ITEM_RIGHT",oRight);
    int nVFX        = BardGetInstrumentVFX(oRight);

    object oLeft    = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if(GetIsObjectValid(oLeft))
    {
        SetLocalObject(OBJECT_SELF,"PERFORMER_ITEM_LEFT",oLeft);
        ActionUnequipItem(oLeft);
    }

    float fDur  = IntToFloat(nDur);
    if(nVFX)
    {
        object oItem    = GetItemInSlot(INVENTORY_SLOT_CHEST);
        int nRobe       = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE);
        if(     GetIsObjectValid(oItem)
            &&  !GetPlotFlag(oItem)
            &&  !GetLocalInt(oItem, "ARMOR_COAT") // this armor is a coat by itself and so you may not remove the coat.
            &&  GetIsCoat(nRobe)
          )
        {
            if(nRobe==ROBE_LONGCOAT1 || nRobe==ROBE_LONGCOAT2)
                nRobe   = 20;
            SetLocalInt(OBJECT_SELF,"PERFORMER_COAT_INDEX",nRobe);

            object oNew     = RemoveArmorRobe(oItem, OBJECT_SELF);
            if(oNew != oItem)
            {
                DestroyObject(oItem);
                ActionEquipItem(oNew,INVENTORY_SLOT_CHEST);
            }
        }
        ActionWait(1.0);
        ActionUnequipItem(oRight);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(nVFX),OBJECT_SELF,fDur);
        ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM1,1.0,fDur-2.0);
    }
    else
    {
        oRight  = GetItemPossessedBy(OBJECT_SELF,"instrument");
        if(GetIsObjectValid(oRight))
        {
            ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
        }
    }

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(468), OBJECT_SELF, fDur);
}

void BardRestoresAppearance()
{
    DeleteLocalInt(OBJECT_SELF, "PERFORMANCE_RESTORE_APPEARANCE");

    int nOffstagePheno  = GetLocalInt(OBJECT_SELF,"PERFORMER_PHENO_OFFSTAGE");
    if(nOffstagePheno != 40)
        ActionDoCommand(SetPhenoType(nOffstagePheno));
    ActionWait(0.25);
    int nRobe       = GetLocalInt(OBJECT_SELF,"PERFORMER_COAT_INDEX");
    if(nRobe)
    {
        object oItem    = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        object oNew     = SwapArmorRobe(oItem, OBJECT_SELF, nRobe);
        if(oNew != oItem)
        {
            DeleteLocalInt(OBJECT_SELF,"PERFORMER_COAT_INDEX");
            DestroyObject(oItem);
            ActionEquipItem(oNew,INVENTORY_SLOT_CHEST);
        }
    }

    object oRight   = GetLocalObject(OBJECT_SELF,"PERFORMER_ITEM_RIGHT");
    if(GetIsObjectValid(oRight))
    {
        DeleteLocalObject(OBJECT_SELF,"PERFORMER_ITEM_RIGHT");
        if(oRight!=GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))
            ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
    }
    else
    {
        oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        if(GetIsObjectValid(oRight))
            ActionUnequipItem(oRight);
    }

    object oLeft    = GetLocalObject(OBJECT_SELF,"PERFORMER_ITEM_LEFT");
    if(GetIsObjectValid(oLeft))
    {
        DeleteLocalObject(OBJECT_SELF,"PERFORMER_ITEM_LEFT");
        ActionEquipItem(oLeft,INVENTORY_SLOT_LEFTHAND);
    }
}

void BardContinuePerformance()
{
    string sPerformScript   = GetLocalString(OBJECT_SELF,"PERFORM_SCRIPT");
    if(sPerformScript=="")
    {

    }
    else
    {
        SetLocalInt(OBJECT_SELF,"PERFORMANCE_CONTINUE",TRUE);
        ExecuteScript(sPerformScript,OBJECT_SELF);
        DeleteLocalInt(OBJECT_SELF,"PERFORMANCE_CONTINUE");
    }
}

void BardEndPerformance()
{
    DeleteLocalInt(OBJECT_SELF,"PERFORMING");
    DeleteLocalInt(OBJECT_SELF, "IN_CONV");// NPC will ignore conversation attempts by PC
    int nDelay  = GetLocalInt(OBJECT_SELF,"PERFORM_DELAY");
    int nRLMinutes = GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE");

    if(!nDelay)
        nDelay  = (2+Random(5))*nRLMinutes;
    else
        nDelay  = (nDelay+Random(2))*nRLMinutes;

    SetLocalInt(OBJECT_SELF, "PERFORM_NEXT",GetTimeCumulative()+nDelay);

    string sPerformScript   = GetLocalString(OBJECT_SELF,"PERFORM_SCRIPT");
    if(sPerformScript=="")
    {
        //ClearAllActions();
        if(!GetIsInCombat())
            BardRestoresAppearance();
        else
            SetLocalInt(OBJECT_SELF, "PERFORMANCE_RESTORE_APPEARANCE",TRUE);

        //RemovePersonalVFX(OBJECT_SELF, 0); // VFX not yet implemented
        DelayCommand(1.0, ActionPlayAnimation(ANIMATION_FIREFORGET_BOW));

        // Reset Music
        object oArea    = GetArea(OBJECT_SELF);
        MusicBackgroundStop(oArea);
        DeleteLocalInt(oArea, "SONG_ID_CURRENT");
        DeleteLocalInt(oArea, "SONG_ID_01");
        DeleteLocalInt(oArea, "SONG_CHANGE_TIME");
        MusicBackgroundChangeDay(oArea, 0);
        MusicBackgroundChangeNight(oArea, 0);
    }
    else
    {
        SetLocalInt(OBJECT_SELF,"PERFORMANCE_END",TRUE);
        ExecuteScript(sPerformScript,OBJECT_SELF);
        DeleteLocalInt(OBJECT_SELF,"PERFORMANCE_END");
    }
}

void BardBetweenPerformance()
{
    int nState  = GetLocalInt(OBJECT_SELF,"PERFORMER_OFFSTAGE_STATUS");
    if(!nState)
    {
        object oDest    = GetWaypointByTag("performer_offstage");
        object oInterim = GetNearestObjectByTag("performer_stage_entry",oDest);
        if(     GetIsObjectValid(oDest)
            &&  GetArea(oDest)==GetArea(OBJECT_SELF)
          )
        {
            float fProximityToDest  = GetDistanceBetween(OBJECT_SELF,oDest);
            if(fProximityToDest<=2.0)
                SetLocalInt(OBJECT_SELF,"PERFORMER_OFFSTAGE_STATUS",1);
            else
            {
                if(     GetIsObjectValid(oInterim)
                    &&  GetDistanceBetween(OBJECT_SELF,oInterim)<fProximityToDest
                  )
                    ActionMoveToObject(oInterim,FALSE,0.0);

                ActionMoveToObject(oDest,FALSE,0.0);
                ActionDoCommand(SetFacing(GetFacing(oDest)));
            }
        }
        else
        {
            if(     GetIsObjectValid(oInterim)
                &&  GetDistanceBetween(OBJECT_SELF,oInterim)>=2.0
              )
                ActionMoveToObject(oInterim,FALSE,0.0);
            else
                SetLocalInt(OBJECT_SELF,"PERFORMER_OFFSTAGE_STATUS",2);
        }
    }
    // made it to destination where we wait out the time between performances
    else if(nState==1)
    {
        int nNth    = 1;
        object oBuddy  = GetNearestCreature(CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,OBJECT_SELF,nNth);
        while(GetIsObjectValid(oBuddy))
        {
            if(     GetIsFriend(oBuddy)
                //||  GetSharesGroupMembership(oBuddy) // groups and subfactions not yet implemented
              )
            {
                if(GetDistanceBetween(OBJECT_SELF,oBuddy)<=5.0)
                {
                    TurnToFaceObject(oBuddy);
                    break;
                }
            }

            oBuddy  = GetNearestCreature(CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,OBJECT_SELF,++nNth);
        }
    }
    // have no destination to wait at... so wander about
    else if(nState==2)
    {
        if(GetCurrentAction()==ACTION_RANDOMWALK)
        {
            if(d4()==1)
                ClearAllActions();
        }
        else
        {
            int bSuccess;
            int nNth    = 1;
            object oBuddy  = GetNearestCreature(CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,OBJECT_SELF,nNth);
            while(GetIsObjectValid(oBuddy))
            {
                if((    GetIsFriend(oBuddy)
                    //||  GetSharesGroupMembership(oBuddy) // groups and subfactions not yet implemented
                   )
                  )
                {
                    if(GetDistanceBetween(OBJECT_SELF,oBuddy)>=3.0)
                    {
                        bSuccess    = TRUE;
                        ActionMoveToObject(oBuddy);
                        break;
                    }
                    else
                    {
                        bSuccess    = TRUE;
                        TurnToFaceObject(oBuddy);
                        AnimActionPlayRandomTalkAnimation((GetHitDice(OBJECT_SELF)-GetHitDice(oBuddy)));
                        break;
                    }
                }

                oBuddy  = GetNearestCreature(CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,OBJECT_SELF,++nNth);
            }

            if(!bSuccess)
            {
                ActionRandomWalk();
            }
        }


    }
}

void BardAITerminate()
{

}

void main()
{
    if(GetIsDMPossessed(OBJECT_SELF))
    {
        return;
    }

    int nUser = GetUserDefinedEventNumber();
    // HEARTBEAT ---------------------------------------------------------------
    if(nUser == EVENT_HEARTBEAT )
    {
        if(CreatureGetIsBusy())
        {
            return;
        }
        // in the midst of performance?
        else if(GetLocalInt(OBJECT_SELF,"PERFORMING"))
        {

            if(GetTimeCumulative(TIME_SECONDS)>=GetLocalInt(OBJECT_SELF, "PERFORM_END"))
            {
                BardEndPerformance();
            }
            else
            {
                BardContinuePerformance();
            }
        }
        // time to begin the next performance?
        else if(GetTimeCumulative()>=GetLocalInt(OBJECT_SELF, "PERFORM_NEXT"))
        {
            BardStartPerformance();
        }
        else
        {
            BardBetweenPerformance();
            if(     !GetIsInCombat()
                &&  GetLocalInt(OBJECT_SELF, "PERFORMANCE_RESTORE_APPEARANCE")
              )
                BardRestoresAppearance();
        }
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
        if(GetLocalInt(OBJECT_SELF,"PERFORMING"))
            BardEndPerformance();
        else if(     !GetIsInCombat()
                &&  GetLocalInt(OBJECT_SELF, "PERFORMANCE_RESTORE_APPEARANCE")
               )
            BardRestoresAppearance();

    }

    // ON DIALOGUE -------------------------------------------------------------
    else if(nUser == EVENT_DIALOGUE)
    {

    }

    // ATTACKED ----------------------------------------------------------------
    else if(nUser == EVENT_ATTACKED)
    {
        if(GetLocalInt(OBJECT_SELF,"PERFORMING") )
            BardEndPerformance();

        ExecuteScript(GetLocalString(OBJECT_SELF, "USERDEF_ATTACKED"), OBJECT_SELF);
        DeleteLocalObject(OBJECT_SELF, "ATTACKED");
    }
    // DAMAGED -----------------------------------------------------------------
    else if(nUser == EVENT_DAMAGED)
    {
        if( GetLocalInt(OBJECT_SELF,"PERFORMING") )
            BardEndPerformance();
    }

    // SPELLCAST AT ------------------------------------------------------------
    else if(nUser == EVENT_SPELL_CAST_AT)
    {
        if(     GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL")
            && GetLocalInt(OBJECT_SELF,"PERFORMING")
          )
            BardEndPerformance();

        // Garbage Collection
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        DeleteLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
    }

    // DEATH  - do not use for critical code, does not fire reliably all the time
    else if(nUser == 1007)
    {
        if( GetLocalInt(OBJECT_SELF,"PERFORMING") )
            BardEndPerformance();
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

    }

    // POSTSPAWN ----------------------------------------------------------------
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {
        // ***** CUSTOM USER DEFINED EVENTS ***** /
        // * EVENT_BLOCKED
        // SetLocalInt(OBJECT_SELF, "USERDEF_BLOCKED", TRUE);
        // * 1001 - EVENT_HEARTBEAT
        SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);
        // * 1002 - EVENT_PERCEIVE
        //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);
        // * 1003 - EVENT_END_COMBAT_ROUND
        SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);
        // * 1004 - EVENT_DIALOGUE
        //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);
        // * 1005 - EVENT_ATTACKED
        SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);
        // * 1006 - EVENT_DAMAGED
        SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);
        // * 1007 - EVENT_DEATH
        SetSpawnInCondition(NW_FLAG_DEATH_EVENT);
        // * 1008 - EVENT_DISTURBED
        //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);
        // * EVENT_SPELL_CAST_AT
        SetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT);
        // * EVENT_RESTED
        //SetSpawnInCondition(NW_FLAG_RESTED_EVENT);
    }
}
