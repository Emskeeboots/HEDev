//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT7
/*
  Default OnDeath event handler for NPCs.

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 1st, 2008
//:: Added Support for Dying Wile Mounted
//:://////////////////////////////////////////////////
//:: Modified: henesua (2016 jan 1)

#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "x3_inc_horse"
#include "_inc_color"
#include "_inc_death"
//#include "_inc_xp"
#include "_inc_loot"

void main()
{
    if (GetLocalInt(OBJECT_SELF, "IS_DEAD"))
        return; // we have already processed death once (in the custom xp script)

    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();
    object oTempMaster  = GetMaster(oKiller);
    object oMaster;

// Oldfog *******************
//    object oCreature = GetLastKiller();
// Oldfog *******************

    while(GetIsObjectValid(oTempMaster))
    {
        oMaster=oTempMaster;
        oTempMaster=GetMaster(oMaster);
    }

    object oRight   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oKiller);
    object oLeft    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oKiller);
    int nNonLethal  = GetLocalInt(OBJECT_SELF,"DAMAGE_NONLETHAL");
    if(     GetLocalInt(oRight,"WEAPON_NONLETHAL")
        ||  GetLocalInt(oLeft,"WEAPON_NONLETHAL")
        ||  GetLocalInt(oKiller,"COMBAT_NONLETHAL")// subdual mode
        ||  nNonLethal
      )
    {
        int nCurrent    = GetCurrentHitPoints();
        if(!nNonLethal)
            nNonLethal  = abs(nCurrent)+1;
        if( (nNonLethal+nCurrent)>-1)
        {
            SpeakString(SHOUT_SUBDUAL_DEAD, TALKVOLUME_SILENT_TALK);
           //float fDur  = nNonLethal*12.0;
            float fDur = 50.0;
            effect eSubdued = EffectLinkEffects(EffectCutsceneParalyze(),EffectVisualEffect(VFX_IMP_SLEEP) );
                   eSubdued = EffectLinkEffects(eSubdued,EffectKnockdown() );

            SetIsDestroyable(FALSE,TRUE);
            object oSelf    = OBJECT_SELF;
            ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oSelf);
            DelayCommand(6.1, AssignCommand(GetModule(), ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oSelf)) );
            DelayCommand(6.2, AssignCommand(GetModule(), ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(nNonLethal),oSelf)) );
            DelayCommand(6.3, AssignCommand(GetModule(), ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eSubdued,oSelf,fDur)) );
            DelayCommand(8.0, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oSelf) );
            DelayCommand(16.4, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oSelf) );
            DelayCommand(30.0, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oSelf));
            DelayCommand(45.0, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oSelf));
            return;
        }
    }

    if (GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB")&&GetIsObjectValid(GetMaster(OBJECT_SELF))) SetLocalInt(GetMaster(OBJECT_SELF),"bX3_STORE_MOUNT_INFO",TRUE);


    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    SetLocalInt(OBJECT_SELF, "SKIN_MAXHP", GetMaxHitPoints(OBJECT_SELF) );

    if( GetIsPC(oKiller) || GetIsPC(oMaster) )
    {
        // record this death?
        StoreKillerDataOnVictim(OBJECT_SELF, oKiller);
        RecordPCDeath(OBJECT_SELF);// testing this out... lets see if tracking PC killing of NPCs in DB is worth it
        DelayCommand(2.5, WipeKillerDataFromVictim(OBJECT_SELF));
        LootCreatureDeath(oKiller, OBJECT_SELF); // item drop


    }
    /*
    else if(    GetLocalInt(oKiller,"AI_CARNIVORE")
            ||  GetLocalInt(oKiller,"AI_OMNIVORE")
           )
    {
        if(GetIsPrey(OBJECT_SELF,oKiller))
            CreatureEatsPrey(oKiller,OBJECT_SELF);
    }
    */

    SetLocalInt(OBJECT_SELF, "IS_DEAD",TRUE);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }

    // TODO - this is not working
    //if(GetLocalInt(OBJECT_SELF,"LOOT"))
    //   LootGenerate(oKiller);
  
    // Tell NESS we are dead - this removes the delay of waiting for the PHB to run
    ExecuteScript("spawn_do_death", OBJECT_SELF);
    
    // henesua - special XP system
    // XPRewardCombat(oKiller, OBJECT_SELF);
    // Use this to use knat's pw XP system.
    // ExecuteScript("pwfxp", OBJECT_SELF);
    // Use this to use Scarface XP system.
    ExecuteScript("sf_xp", OBJECT_SELF);

    // Custom code

    // TODO - this should just be a hook to run whataver script is in CUSTOM_DEATH variable
    // 0tting (28-02-2018): Custom code in a horrible location until I figure out how this
    //  should be done better. Script checks if the sacrificial waypoint was near when this creature dies and
    //  if so, commands the door to open.
    //  Script is used in "The Sunset Vale - The Barrows"
    if(GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD) {
        // This is the fastest method to find a WP in our area, right?
        object sacWaypoint = GetNearestObjectByTag("ot_unq_sac_wp");
        if(sacWaypoint != OBJECT_INVALID) {
            float sacDist = GetDistanceToObject(sacWaypoint);
            if(sacDist < 10.0) {
                object sacDoor = GetObjectByTag("sv_barrow_door");
                if(!GetIsOpen(sacDoor)) {
                    AssignCommand(sacDoor, ActionOpenDoor(sacDoor));
                    object sacDoorNode = GetWaypointByTag("vfx_node");
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY), sacDoorNode);
                    FloatingTextStringOnCreature("The blood from the sacrifice slowly make its way between the cracks in the stonefloor. A mechanical rumble echoes through the halls" , oKiller);
                }
            }
        }
    }
}



