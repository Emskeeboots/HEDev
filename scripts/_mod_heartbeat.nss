//::///////////////////////////////////////////////
//:: _mod_heartbeat
//:://////////////////////////////////////////////
/*
    Module Event: On Heartbeat
    Modified: x3_mod_def_hb (c) 2008 Bioware Corp.

    This heartbeat exists only to make sure it
    handles in its own way the benefits of having
    the feat Mounted Combat.   See the script
    x3_inc_horse for complete details of variables
    and flags that can be used with this.   This script
    is also used to provide support for persistence.

    Custom Death Addition:
    track if PC was damaged since last heartbeat
    if PC was damaged, then stabilized status is removed

    PETS - extension of The Magus' Innocuous Familiars
    handled in MasterHeartbeatEvent()

    CONSUMABLE LIGHT SOURCES extension of KMDS lightsources.
    see: doConsumableLightSource(object oPC)

*/
//:://////////////////////////////////////////////
//:: Created By: Deva Winblood (April 2nd, 2008)
//:: Modified: henesua (jan 5)
//:://////////////////////////////////////////////


#include "x3_inc_horse"

#include "_inc_util"
#include "_inc_data"
#include "_inc_xp"
#include "_inc_pets"
#include "_inc_light"
#include "tb_inc_util"

// KMDS light source BEGIN ---------------------------------------------
//keeps track of consumable torches and lanterns. [see: kmds_lightsource.nss]
void doConsumableLightSource(object oPC);
void doConsumableLightSource(object oPC)
{
  object oTorch = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
  int iLight    = GetLocalInt(oTorch, "LIGHTABLE");
  object oArea  = GetArea(oPC);
  // If we find a torch or lantern in the players left hand....
  if(iLight && !GetLocalInt(oTorch, "LIGHTABLE_LANTERN_EMPTY") && !GetLocalInt(oTorch,"CONTINUAL_FLAME"))
  {
      string sLight  = GetLocalString(oTorch,"LIGHTABLE_TYPE");
      //Initiate and declare variables used for Light System
      // Assume 10 heartbeat ticks per real life minute
      int nTicksLit   =   GetLocalInt(oTorch,"LIGHTABLE_BURNED_TICKS");

      // Check the time lit vs total allowed burntime...
      // For a torch, destroy and send message to pc if burntime exceeded.
      if(sLight=="torch" && nTicksLit >= MAX_TORCH_HB)
      {
          DestroyObject(oTorch);
          SendMessageToPC(oPC,GREY+TORCHHASBURNTOUT);
      }
      // For a candle, destroy and send message to pc if burntime exceeded.
      else if(sLight=="candle" && nTicksLit >= MAX_CANDLE_HB)
      {
          DestroyObject(oTorch);
          SendMessageToPC(oPC,GREY+CANDLEHASBURNTOUT);
      }
      // For a lantern, remove light property and send message to pc if burntime exceeded.
      else if(sLight=="lantern" && nTicksLit >= MAX_LANTERN_HB)
      {
          //loope through itemproperties on the lantern
          // remove light properties
          itemproperty ipLoop=GetFirstItemProperty(oTorch);
          while (GetIsItemPropertyValid(ipLoop))
          {
              //If ipLoop is a light property, remove it
              if (GetItemPropertyType(ipLoop)==ITEM_PROPERTY_LIGHT)
                  RemoveItemProperty(oTorch, ipLoop);
              //Next itemproperty on the list...
              ipLoop=GetNextItemProperty(oTorch);
          }

          SendMessageToPC(oPC,GREY+LANTERNISEMPTY);
          SetLocalInt(oTorch, "LIGHTABLE_LANTERN_EMPTY", TRUE);
          SetDescription(oTorch, GetDescription(oTorch, TRUE)+" The reservoir is empty.");
          AssignCommand(oArea, DelayCommand(0.25, RecomputeStaticLighting(oArea)) );
          PCLostLight(oPC, oTorch);
      }
      // Otherwise, increment the time the light object has been lit.
      else
      {
          ++nTicksLit;
          SetLocalInt(oTorch,"LIGHTABLE_BURNED_TICKS", nTicksLit);
          string sNewDescription = GetDescription(oTorch, TRUE);
          float fTorchRemainder;
          if (sLight=="candle")
          {
              fTorchRemainder = IntToFloat(MAX_CANDLE_HB-nTicksLit)/MAX_CANDLE_HB ;

              if (fTorchRemainder > 0.9 || nTicksLit == 1)
                  sNewDescription += " This candle is fresh.";
              else if (fTorchRemainder > 0.75)
                  sNewDescription += " This candle is mostly fresh.";
              else if (fTorchRemainder > 0.60)
                  sNewDescription += " More than half of this candle remains.";
              else if (fTorchRemainder > 0.45)
                  sNewDescription += " Only half of this candle remains.";
              else if (fTorchRemainder > 0.35)
                  sNewDescription += " More than half of this candle is spent.";
              else if (fTorchRemainder > 0.20)
                  sNewDescription += " Only a third of this candle's life remains unspent.";
              else if (fTorchRemainder > 0.05)
                  sNewDescription += " All that remains of this candle is a short stub. Its life is running out.";
              else
              {
                  sNewDescription += " This candle has been reduced to a wick in candle drippings. It has maybe a few minutes of life left.";
                  if(Random(2))
                      FloatingTextStringOnCreature(GREY+" The wick of your candle sputters in a molten pool.",oPC,FALSE);
              }
          }
          else if(sLight=="torch")
          {
              fTorchRemainder = IntToFloat(MAX_TORCH_HB-nTicksLit)/MAX_TORCH_HB ;
              if (fTorchRemainder > 0.9 || nTicksLit == 1)
                  sNewDescription += " This torch has been used.";
              else if (fTorchRemainder > 0.45)
                  sNewDescription += " This torch is well used.";
              else if (fTorchRemainder > 0.20)
                  sNewDescription += " This torch is blackened from use.";
              else if (fTorchRemainder > 0.05)
                  sNewDescription += " This torch is nearly charred through.";
              else
              {
                  sNewDescription += " This torch is charred. It has maybe a few minutes of life left.";
                  if(Random(2))
                      FloatingTextStringOnCreature(GREY+" Your torch sputters towards the end of its life.",oPC,FALSE);
              }
          }
          else if(sLight=="lantern")
          {
              fTorchRemainder = IntToFloat(MAX_LANTERN_HB-nTicksLit)/MAX_LANTERN_HB ;
              if(fTorchRemainder > 0.9 || nTicksLit==1)
                  sNewDescription += " The reservoir seems full.";
              else if (fTorchRemainder > 0.65)
                  sNewDescription += " The reservoir is mostly full.";
              else if (fTorchRemainder > 0.45)
                  sNewDescription += " The reservoir sloshes when you shake it, perhaps half full.";
              else if (fTorchRemainder > 0.20)
                  sNewDescription += " The reservoir has less than half of the oil remaining.";
              else if (fTorchRemainder > 0.05)
                  sNewDescription += " The reservoir has only a small amount of oil left.";
              else
              {
                  sNewDescription += " The reservoir is almost empty. It has maybe a few minutes of life left.";
                  if(Random(2))
                      FloatingTextStringOnCreature(GREY+" Your lantern burns inconsistently as if running on fumes.",oPC,FALSE);
              }
          }
          SetDescription(oTorch, sNewDescription);
      }
  }

}

void do_pc_heartbeat(object oPC, int nHBTick) {
        int nRoll;
        int nHPLast, nHPCurrent; // PC damage tracking
        int bNoCombat = GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"); // horses

        if(GetLocalInt(oPC, "IS_DEAD") || IsOOC(oPC) || GetIsDM(oPC) ) {
                return;
        }

        // PETS -------------------------------------
        AssignCommand(oPC, MasterHeartbeatEvent() );
        // END PETS ---------------------------------

        // HORSES --------------------------------------------------------------
        if (GetLocalInt(oPC,"bX3_STORE_MOUNT_INFO"))
        { // store
            DeleteLocalInt(oPC,"bX3_STORE_MOUNT_INFO");
            HorseSaveToDatabase(oPC,X3_HORSE_DATABASE);
        } // store
        if (!bNoCombat&&GetHasFeat(FEAT_MOUNTED_COMBAT,oPC)&&HorseGetIsMounted(oPC))
        { // check for AC increase
            nRoll=d20()+GetSkillRank(SKILL_RIDE,oPC);
            nRoll=nRoll-10;
            if (nRoll>4)
            { // ac increase
                nRoll=nRoll/5;
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectACIncrease(nRoll),oPC,7.0);
            } // ac increase
        } // check for AC increase
        // END HORSES ----------------------------------------------------------

        // Reward ROLEPLAY XP from likes ---------------------------------------
        if(GetLocalInt(oPC,"REWARD_ROLEPLAY_XP")) {
                if(d4()==1) {
                        XPRewardByType("like_roleplay", oPC, GetLocalInt(oPC,"REWARD_ROLEPLAY_XP"), XP_TYPE_ROLEPLAY);
                        DeleteLocalInt(oPC,"REWARD_ROLEPLAY_XP");
                }
        }
        // END Reward ROLEPLAY XP from likes -----------------------------------


        // PC DAMAGE TRACKING --------------------------------------------------
        nHPLast     = GetLocalInt(oPC,"PC_HITPOINTS");  // HP at last heartbeat
        nHPCurrent  = GetCurrentHitPoints(oPC);         // HP this heartbeat
        SetLocalInt(oPC, "PC_HITPOINTS", nHPCurrent);   // Store HP for retrieval next heartbeat
        // PC was damaged this last heartbeat
        if(nHPLast>nHPCurrent)
        {
                db("_mod_heartbeat: " + GetName(oPC) + " took damage - clearing stabilized.");
                DeleteLocalInt(oPC, "PC_STABILIZED"); // MAGUS Death system - PC is no longer stabilised if damaged
        }
        // END PC DAMAGE TRACKING ----------------------------------------------

        // CONSUMABLE LIGHT SOURCES
        doConsumableLightSource(oPC);

        // Armor encumbrance str check
        int nLastStr = GetLocalInt(oPC, "armor_enc_last_str");
        if (nLastStr != 0 && nLastStr != GetAbilityScore(oPC, ABILITY_STRENGTH)) {
                SetLocalInt(oPC, "move_tmp_op", 1);
                ExecuteScript("tb_do_moverate", oPC);
        }

        // PERSISTENCE
        // we only save PC Data once every 10 heartbeats
        // each PC's tick is chosen randomly on log in. See _mod_load
        if(GetLocalInt(oPC, "SAVE_THE_PC_ON_THIS_HB_TICK")==nHBTick) {
                Data_SavePC(oPC);
        }
}

/////////////////////////////////////////////////////////////[ MAIN ]///////////
void main() {
        object oMod         = GetModule();
        string campaign_id  = NWNX_GetCampaignID();

        int nHBTick         = GetLocalInt(oMod, "MOD_HEARTBEAT_TICK")+1;
        int nHBModulo       = GetLocalInt(oMod, "MOD_HB_TICK_MODULO");
    // Check if we need to do the hourly or daily scripts

        int nTimeStamp = CurrentTimeStamp();
        int nTime = TimeStampToHours(nTimeStamp);
        int nDay = TimeStampToDays(nTimeStamp);
        int bDoHourCheck = FALSE;
        int bDoDayCheck = FALSE;
        int nLastCheckHour = GetLocalInt(OBJECT_SELF, "LastCheckHour");
        int nLastCheckDay =  GetLocalInt(OBJECT_SELF, "LastCheckDay");
        if (nTime > nLastCheckHour) {
                dblvl(DEBUGLEVEL_HB, "ModHB, Doing Hour check : current time ", nTime, " Last check ", nLastCheckHour, TRUE);
                SetLocalInt(OBJECT_SELF, "LastCheckHour", nTime);
                bDoHourCheck = TRUE;
        }

        if (nDay > nLastCheckDay) {
                dblvl(DEBUGLEVEL_HB, "ModHB, Doing Day check : current Day ", nDay, " Last check ", nLastCheckDay, TRUE);
                SetLocalInt(OBJECT_SELF, "LastCheckDay", nDay);
                bDoDayCheck = TRUE;
        }

    //if(nHBTick>10){nHBTick=1;}
        if(nHBTick>nHBModulo){nHBTick=1;}
        SetLocalInt(oMod, "MOD_HEARTBEAT_TICK",nHBTick);

        // This serves as a sort of timestamp.
        int nHBCount         = GetLocalInt(oMod, "MOD_HEARTBEAT_COUNT")+1;
        SetLocalInt(oMod, "MOD_HEARTBEAT_COUNT",nHBCount);

        // PC traversal
        object oPC=GetFirstPC();

       //db("MOD HB tick = " , nHBTick, " Modulo = ", nHBModulo, TRUE, oPC);
        while(GetIsObjectValid(oPC)) {
                // OOC exclusion - only living PCs in game are traversed
                if(!GetLocalInt(oPC, "IS_DEAD") &&  !IsOOC(oPC) &&  !GetIsDM(oPC) ) {
                        DelayCommand(0.0, do_pc_heartbeat(oPC, nHBTick));

                        // These are things we only do every hour
                        if (bDoHourCheck) {
                                DelayCommand(0.0, ExecuteScript("tb_pc_hourly", oPC));
                        }

                        // These things are done once every day
                        if (bDoDayCheck) {
                                DelayCommand(0.0, ExecuteScript("tb_pc_daily", oPC));
                        }
                }
                // end OOC exclusion

                oPC=GetNextPC();
        }
    // end PC traversal

        // TODO - this is now too often.  Could use hourly and mark it when we knowingly modify (in _corpse code)
        // once every MOD_HB_TICK_MODULO ticks we save the corpses
        if(nHBTick==1) {
                object corpse_store = GetObjectByTag("corpse_storage");

        // TODO - flag in here when modified?
                if(GetIsObjectValid(corpse_store)) {
            SetPersistentObject(GetModule(), "corpse_storage", corpse_store, "0");
            //Data_SaveCampaignObject(corpse_store);
        }
        }

        // once every MOD_HB_TICK_MODULO ticks we save the time
        if(nHBTick==nHBModulo) {
                NWNX_SaveGameTime(campaign_id);
    }
}


