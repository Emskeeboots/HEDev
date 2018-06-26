//::///////////////////////////////////////////////
//:: _ai_danclight
//:://////////////////////////////////////////////
/*
    DANCING LIGHT On User Defined Event script
    this uses the v2_ai_mg_* set of ai scripts for other events

    pre and post spawn events set with
    Local Int "X2_USERDEFINED_ONSPAWN_EVENTS"
    1 = Pre Spawn
    2 = Post Spawn
    3 = Both Pre and Post Spawn
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 20)
//:://////////////////////////////////////////////

#include "x0_i0_anims"

#include "_inc_constants"
#include "_inc_spells"

const int EVENT_USER_DEFINED_PRESPAWN = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN = 1511;

void main()
{
    int nUser       = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {
        ActionRandomWalk();
        if(!GetIsInCombat())
        {
            int nTimer      = GetLocalInt(OBJECT_SELF, "TIMER")-1;
            if(     nTimer < 1
                ||  GetArea(OBJECT_SELF) != GetArea(GetLocalObject(OBJECT_SELF, "CREATOR"))
              )
            {
                SetPlotFlag(OBJECT_SELF, FALSE);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(282), GetLocation(OBJECT_SELF));  // hit elec
                DestroyObject(OBJECT_SELF, 1.0);
                return;
            }

            SetLocalInt(OBJECT_SELF, "TIMER", nTimer);
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
            SetPlotFlag(OBJECT_SELF, FALSE);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(282), GetLocation(OBJECT_SELF));  // hit elec
            DestroyObject(OBJECT_SELF, 1.0);
            return;
        }

        SetLocalInt(OBJECT_SELF, "TIMER", nTimer);
    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {
        object oAttacker = GetLocalObject(OBJECT_SELF, "USERD_ATTACKER");
        ActionMoveAwayFromObject(oAttacker, TRUE, 10.0);
        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_ATTACKER");
    }
    else if(nUser == EVENT_SPELL_CAST_AT) // SPELL CAST AT
    {
        // Initialize Event Vars
        int nSpellID    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        object oCaster  = GetLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        int bHarmful    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");

        int nLevel      = GetCasterLevel(oCaster);
        object oCreator = GetLocalObject(OBJECT_SELF, "CREATOR");
        int nDC         = GetLocalInt(OBJECT_SELF, "LEVEL")+11;

        // if NOT dispelled
        if(!DispelObject(nSpellID, nLevel, nDC, oCaster==oCreator))
        {
            ActionRandomWalk();
            DelayCommand(6.0, SurrenderToEnemies());
        }
        else
            DestroyObject(OBJECT_SELF, 1.5);

        // Garbage Collection
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        DeleteLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
    }
    else if(nUser == EVENT_DAMAGED) // DAMAGED
    {
        object oDamager = GetLocalObject(OBJECT_SELF, "USERD_DAMAGER");

        ActionMoveAwayFromObject(oDamager, TRUE, 10.0);
        //SurrenderToEnemies();

        SetIsTemporaryNeutral(OBJECT_SELF, oDamager);
        AssignCommand(oDamager, ClearAllActions(TRUE));
        AssignCommand(oDamager, ActionAttack(GetNearestPerceivedEnemy(OBJECT_SELF)));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetLocalInt(OBJECT_SELF, "USERD_DAMAGE")), OBJECT_SELF);
        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_DAMAGER");
        DeleteLocalInt(OBJECT_SELF, "USERD_DAMAGE");
    }
    else if (nUser == EVENT_USER_DEFINED_PRESPAWN)
    {

    }
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {
        SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);
        SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);
        SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);
        SetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT);
        SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);

        ActionRandomWalk();
    }
}
