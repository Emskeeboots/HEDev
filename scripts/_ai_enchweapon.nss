//::///////////////////////////////////////////////
//:: _ai_enchweapon
//:://////////////////////////////////////////////
/*
    ANIMATED WEAPON On User Defined Event script
    this uses the v2_ai_mg_* set of ai scripts for other events

    pre and post spawn events set with
    Local Int "X2_USERDEFINED_ONSPAWN_EVENTS"
    1 = Pre Spawn
    2 = Post Spawn
    3 = Both PRe and Post Spawn
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 20)
//:://////////////////////////////////////////////

#include "_inc_constants"
#include "_inc_spells"

#include "x0_i0_anims"
#include "X0_INC_HENAI"
#include "x2_inc_switches"

#include "X2_INC_SPELLHOOK"

const int EVENT_USER_DEFINED_PRESPAWN = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN = 1511;

void main()
{
    int nUser       = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {
        /*
        if(!GetIsInCombat())
        {
            int nTimer      = GetLocalInt(OBJECT_SELF, "TIMER")-1;
            if(     nTimer < 1
                ||  GetArea(OBJECT_SELF) != GetArea(GetLocalObject(OBJECT_SELF, "CREATOR"))
            )
            {
                CancelDancingWeapon();
                return;
            }

            SetLocalInt(OBJECT_SELF, "TIMER", nTimer);
        }
        */

        object oMaster  = GetMaster();
        int nAction     = GetCurrentAction(OBJECT_SELF);

        // Check if concentration is required to maintain this creature
        //X2DoBreakConcentrationCheck();

        if(     GetLocalInt(oMaster,"IS_DEAD")
            ||  GetIsDead(oMaster)
          )
        {
            CancelDancingWeapon();
            return;
        }

      if(!GetAssociateState(NW_ASC_IS_BUSY))
      {
        if(GetIsObjectValid(oMaster))
        {
            float fDistToMaster = GetDistanceToObject(oMaster);
            float fDistFollow   = GetFollowDistance();

            if(     nAction != ACTION_FOLLOW
                &&  nAction != ACTION_DISABLETRAP
                &&  nAction != ACTION_OPENLOCK
                &&  nAction != ACTION_REST
                &&  nAction != ACTION_ATTACKOBJECT
              )
            {
                if(    !GetIsObjectValid(GetAttackTarget())
                    && !GetIsObjectValid(GetAttemptedSpellTarget())
                    && !GetIsObjectValid(GetAttemptedAttackTarget())
                    && !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN))
                  )
                {
                    if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                    {
                        if(fDistToMaster > fDistFollow)
                        {
                            ClearAllActions();
                            ActionForceFollowObject(oMaster, fDistFollow);

                        } // END farther than follow dist
                    }// END not standing ground
                    else
                    {
                        ClearAllActions();
                    }// END standing ground
                }// END not fighting and no enemies in range.
            }// not following etc...
        } // END Has Master

        // * if I am dominated, ask for some help
        if (GetHasEffect(EFFECT_TYPE_DOMINATED, OBJECT_SELF) && !GetIsEncounterCreature(OBJECT_SELF))
        {
            SendForHelp();
        }
      }
    }
    else if(nUser == EVENT_END_COMBAT_ROUND) // END COMBT ROUND
    {
        int nTimer      = GetLocalInt(OBJECT_SELF, "TIMER")-1;
        if(     nTimer < 1
            ||  GetArea(OBJECT_SELF) != GetArea(GetLocalObject(OBJECT_SELF, "CREATOR"))
            ||  !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))
          )
        {
            CancelDancingWeapon();
            return;
        }

        SetLocalInt(OBJECT_SELF, "TIMER", nTimer);
    }
    else if(nUser == EVENT_SPELL_CAST_AT) // SPELL CAST AT
    {
        // Initialize Event Vars
        int nSpellID    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        object oCaster  = GetLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        int bHarmful    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
        //object oCreator = GetLocalObject(OBJECT_SELF, "CREATOR");
        int nLevel      = GetCasterLevel(oCaster);

        // Dispelled?
        int nDC         = GetLocalInt(OBJECT_SELF, "LEVEL")+11;
        if(DispelObject(nSpellID, nLevel, nDC))
            CancelDancingWeapon(TRUE);

        // Garbage Collection
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        DeleteLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
    }
    else if(nUser == EVENT_RESTED)
    {
        CancelDancingWeapon();
    }
    else if (nUser == EVENT_USER_DEFINED_PRESPAWN)
    {

    }
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {
        SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);
        SetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT);
        SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);
        SetSpawnInCondition(NW_FLAG_RESTED_EVENT);

        SetAssociateState(NW_ASC_POWER_CASTING, FALSE);
        SetAssociateState(NW_ASC_HEAL_AT_50, FALSE);
        SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, FALSE);
        SetAssociateState(NW_ASC_DISARM_TRAPS, FALSE);

        SetIsDestroyable(TRUE, FALSE, FALSE);
        // Random appearance -----------------
        if(GetLocalInt(OBJECT_SELF,"APPEARANCE_TYPE"))
            ExecuteScript("_npc_rnd_apear",OBJECT_SELF);
     }
}
