//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT9
/*
 * Default OnSpawn handler with XP1 revisions.
 * This corresponds to and produces the same results
 * as the default OnSpawn handler in the OC.
 *
 * This can be used to customize creature behavior in three main ways:
 *
 * - Uncomment the existing lines of code to activate certain
 *   common desired behaviors from the moment when the creature
 *   spawns in.
 *
 * - Uncomment the user-defined event signals to cause the
 *   creature to fire events that you can then handle with
 *   a custom OnUserDefined event handler script.
 *
 * - Add new code _at the end_ to alter the initial
 *   behavior in a more customized way.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/11/2002
//:://////////////////////////////////////////////////
//:: Updated 2003-08-20 Georg Zoeller: Added check for variables to active spawn in conditions without changing the spawnscript


#include "x0_i0_anims"
#include "x0_i0_treasure"
#include "ave_npc_inc"
#include "x2_inc_switches"
#include "_inc_util"
#include "_inc_spawn"
#include "_inc_languages"

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
    // ***** Spawn-In Conditions ***** //

    // * REMOVE COMMENTS (// ) before the "Set..." functions to activate
    // * them. Do NOT touch lines commented out with // *, those are
    // * real comments for information.

    // * This causes the creature to say a one-line greeting in their
    // * conversation file upon perceiving the player. Put [NW_D2_GenCheck]
    // * in the "Text Seen When" field of the greeting in the conversation
    // * file. Don't attach any player responses.
    // *
    // SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);

    // * Same as above, but for hostile creatures to make them say
    // * a line before attacking.
    // *
    // SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);

    // * This NPC will attack when its allies call for help
    // *
    // SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);

    // * If the NPC has the Hide skill they will go into stealth mode
    // * while doing WalkWayPoints().
    // *
    // SetSpawnInCondition(NW_FLAG_STEALTH);

    //--------------------------------------------------------------------------
    // Enable stealth mode by setting a variable on the creature
    // Great for ambushes
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_STEALTH) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_STEALTH);
    }
    // * Same, but for Search mode
    // *
    // SetSpawnInCondition(NW_FLAG_SEARCH);

    //--------------------------------------------------------------------------
    // Make creature enter search mode after spawning by setting a variable
    // Great for guards, etc
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_SEARCH) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_SEARCH);
    }
    // * This will set the NPC to give a warning to non-enemies
    // * before attacking.
    // * NN -- no clue what this really does yet
    // *
    // SetSpawnInCondition(NW_FLAG_SET_WARNINGS);

    // * Separate the NPC's waypoints into day & night.
    // * See comment on WalkWayPoints() for use.
    // *
    // SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING);

    // * If this is set, the NPC will appear using the "EffectAppear"
    // * animation instead of fading in, *IF* SetListeningPatterns()
    // * is called below.
    // *
    //SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);

    // * This will cause an NPC to use common animations it possesses,
    // * and use social ones to any other nearby friendly NPCs.
    // *
    // SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);

    //--------------------------------------------------------------------------
    // Enable immobile ambient animations by setting a variable
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_AMBIENT_IMMOBILE) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
    }
    // * Same as above, except NPC will wander randomly around the
    // * area.
    // *
    // SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);


    //--------------------------------------------------------------------------
    // Enable mobile ambient animations by setting a variable
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_AMBIENT) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
    }
    // **** Animation Conditions **** //
    // * These are extra conditions you can put on creatures with ambient
    // * animations.

    // * Civilized creatures interact with placeables in
    // * their area that have the tag "NW_INTERACTIVE"
    // * and "talk" to each other.
    // *
    // * Humanoid races are civilized by default, so only
    // * set this flag for monster races that you want to
    // * behave the same way.
    // SetAnimationCondition(NW_ANIM_FLAG_IS_CIVILIZED);

    // * If this flag is set, this creature will constantly
    // * be acting. Otherwise, creatures will only start
    // * performing their ambient animations when they
    // * first perceive a player, and they will stop when
    // * the player moves away.
    // SetAnimationCondition(NW_ANIM_FLAG_CONSTANT);

    // * Civilized creatures with this flag set will
    // * randomly use a few voicechats. It's a good
    // * idea to avoid putting this on multiple
    // * creatures using the same voiceset.
    // SetAnimationCondition(NW_ANIM_FLAG_CHATTER);

    // * Creatures with _immobile_ ambient animations
    // * can have this flag set to make them mobile in a
    // * close range. They will never leave their immediate
    // * area, but will move around in it, frequently
    // * returning to their starting point.
    // *
    // * Note that creatures spawned inside interior areas
    // * that contain a waypoint with one of the tags
    // * "NW_HOME", "NW_TAVERN", "NW_SHOP" will automatically
    // * have this condition set.
    // SetAnimationCondition(NW_ANIM_FLAG_IS_MOBILE_CLOSE_RANGE);


    // **** Special Combat Tactics *****//
    // * These are special flags that can be set on creatures to
    // * make them follow certain specialized combat tactics.
    // * NOTE: ONLY ONE OF THESE SHOULD BE SET ON A SINGLE CREATURE.

    // * Ranged attacker
    // * Will attempt to stay at ranged distance from their
    // * target.
    // SetCombatCondition(X0_COMBAT_FLAG_RANGED);

    // * Defensive attacker
    // * Will use defensive combat feats and parry
    // SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE);

    // * Ambusher
    // * Will go stealthy/invisible and attack, then
    // * run away and try to go stealthy again before
    // * attacking anew.
    // SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER);

    // * Cowardly
    // * Cowardly creatures will attempt to flee
    // * attackers.
    // SetCombatCondition(X0_COMBAT_FLAG_COWARDLY);


    // **** Escape Commands ***** //
    // * NOTE: ONLY ONE OF THE FOLLOWING SHOULD EVER BE SET AT ONE TIME.
    // * NOTE2: Not clear that these actually work. -- NN

    // * Flee to a way point and return a short time later.
    // *
    // SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);

    // * Flee to a way point and do not return.
    // *
    // SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);

    // * Teleport to safety and do not return.
    // *
    // SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);

    // * Teleport to safety and return a short time later.
    // *
    // SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);



    // ***** CUSTOM USER DEFINED EVENTS ***** /


    /*
      If you uncomment any of these conditions, the creature will fire
      a specific user-defined event number on each event. That will then
      allow you to write custom code in the "OnUserDefinedEvent" handler
      script to go on top of the default NPC behaviors for that event.

      Example: I want to add some custom behavior to my NPC when they
      are damaged. I uncomment the "NW_FLAG_DAMAGED_EVENT", then create
      a new user-defined script that has something like this in it:

      if (GetUserDefinedEventNumber() == 1006) {
          // Custom code for my NPC to execute when it's damaged
      }

      These user-defined events are in the range 1001-1007.
    */

    // * Fire User Defined Event 1001 in the OnHeartbeat
    // *
    // SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);

    // * Fire User Defined Event 1002
    // *
    // SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);

    // * Fire User Defined Event 1005
    // *
    // SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);

    // * Fire User Defined Event 1006
    // *
    // SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);

    // * Fire User Defined Event 1008
    // *
    // SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);

    // * Fire User Defined Event 1003
    // *
    // SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);

    // * Fire User Defined Event 1004
    // *
    // SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);



    // ***** DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) ***** //

    // * Goes through and sets up which shouts the NPC will listen to.
    // *
    SetListeningPatterns();

    // * Walk among a set of waypoints.
    // * 1. Find waypoints with the tag "WP_" + NPC TAG + "_##" and walk
    // *    among them in order.
    // * 2. If the tag of the Way Point is "POST_" + NPC TAG, stay there
    // *    and return to it after combat.
    //
    // * Optional Parameters:
    // * void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
    //
    // * If "NW_FLAG_DAY_NIGHT_POSTING" is set above, you can also
    // * create waypoints with the tags "WN_" + NPC Tag + "_##"
    // * and those will be walked at night. (The standard waypoints
    // * will be walked during the day.)
    // * The night "posting" waypoint tag is simply "NIGHT_" + NPC tag.
    SetWalkCondition(NW_WALK_FLAG_CONSTANT);
//    aww_WalkWayPoints(FALSE, 0.5);

    //* Create a small amount of treasure on the creature
    if ((GetLocalInt(GetModule(), "X2_L_NOTREASURE") == FALSE)  &&
        (GetLocalInt(OBJECT_SELF, "X2_L_NOTREASURE") == FALSE)   )
    {
        //CTG_GenerateNPCTreasure(TREASURE_TYPE_MONSTER, OBJECT_SELF);
    }

    DelayCommand(0.2, SpawnAveNPCTreasure(OBJECT_SELF));
    CheckNPCPartConfig(OBJECT_SELF,"color");
    CheckNPCPartConfig(OBJECT_SELF,"part");

    // ***** ADD ANY SPECIAL ON-SPAWN CODE HERE ***** //

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL))
    {
        CreatureDoIncorporeal(OBJECT_SELF);
        /*
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal        = ExtraordinaryEffect(eConceal);
        effect eGhost   = EffectCutsceneGhost();
        eGhost          = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, OBJECT_SELF);
        */
    }
    // social NPCs shouldn't have wayfinding issues. allow them to move about in crowds.
    if(     GetLocalInt(OBJECT_SELF,"SPAWN_EFFECT_GHOST")
        ||  GetPhenoType(OBJECT_SELF)==40
      )
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(),OBJECT_SELF);
    }

    // Languages ------------------------- // MAGUS
    InitializeNPCLanguages();

    // Name
    SpawnInitializeName();


    // Random appearance -----------------
    if(GetLocalInt(OBJECT_SELF,"APPEARANCE_TYPE"))
        DelayCommand(0.1,ExecuteScript("_npc_rnd_apear",OBJECT_SELF));
    if(GetLocalInt(OBJECT_SELF,"EQUIPMENT_TYPE"))
        DelayCommand(0.2,ExecuteScript("_npc_rnd_equip",OBJECT_SELF));



    // * TT CODE * //





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




