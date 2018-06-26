//::///////////////////////////////////////////////
//:: _door_openfail
//:://////////////////////////////////////////////
/*
    intended for use in a door's OnFailToOpen event
*/
//:://////////////////////////////////////////////
//:: Created By: henesua (2016 jan 5)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_switches"
//#include "NW_I0_GENERIC"

//#include "_inc_constants"
#include "_inc_util"    // some creature calls - change if moved to inc_creature
#include "_inc_spells" // for SPELL_ACT_PASSDOOR
#include "aid_inc_global"

// Assign to the creature object using the key  [File: aa_door_openfail]
void ActionUseKey(object oKey, object oDoor);
void ActionUseKey(object oKey, object oDoor)
{
    SendMessageToPC(OBJECT_SELF, DMBLUE+"Your "+GetName(oKey)+" should fit the lock.");
    ActionPlayAnimation(ANIMATION_LOOPING_GET_MID,1.0,3.0);
    // Simulate using the item
    SetLocalObject(OBJECT_SELF,"SPELL995_KEY",oKey); // set the item used on PC
    // Use Key spellId=995
    ActionCastSpellAtObject(995,oDoor,METAMAGIC_NONE,TRUE,0,PROJECTILE_PATH_TYPE_DEFAULT,TRUE );
    //SignalEvent(GetModule(), EventActivateItem(oKey, GetLocation(oDoor), oDoor));
}

void main()
{
    object oDoor        = OBJECT_SELF;
    object oCreature    = GetClickingObject();
    int bSuccess        = FALSE;

    // if you can pass through the door... do so.
    // Magic doors stop all, Doors requiring special key are only passed by incorporeal
    if(  !GetLocalInt(oDoor,"MAGIC")
        &&
        (   CreatureGetIsIncorporeal(oCreature)
            || (    !GetLockKeyRequired(oDoor)
                && (    GetHasFeat(FEAT_PASS_DOOR, oCreature)
                    ||  CreatureGetIsSoftBodied(oCreature)
                    )
                )
        )
      )
    {
        AssignCommand(oCreature,
            ActionCastSpellAtObject(SPELL_ACT_PASSDOOR, oDoor, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)
                );
        bSuccess=TRUE;
    }
    else if (CreatureGetHasHands(oCreature))
    {
        string sDoorID  = GetTag(oDoor)+GetLockKeyTag(oDoor);
        string sTagVar  = GetLocalString(oDoor,"KEY");
        string sTag;
        // look for special key
        object oKey = GetItemPossessedBy(oCreature, sTagVar);
        if( GetLocalInt(oKey,sDoorID) )//has it been used?
        {
            if(GetIdentified(oKey))
            {
                AssignCommand(oCreature, ActionDoCommand(ActionUseKey(oKey,oDoor)) );
                bSuccess=TRUE;
            }
            else
            {
                //if unidentified, then this player has not used it before
                CopyItem(oKey, oCreature); // removes all local vars
                DestroyObject(oKey, 0.1);
            }
        }
    }

    if(     !bSuccess
        &&  GetLocalInt(OBJECT_SELF,"MOVE_SKILL")

      )
    {
        if(GetLocalInt(OBJECT_SELF,"MOVE_SIZE")>=GetCreatureSize(oCreature))
        {
            bSuccess = TRUE;
            SetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT, oCreature);
            ExecuteScript("_plc_moveskill",OBJECT_SELF);
        }
        else
        {
            FloatingTextStringOnCreature( PINK+"You are too large to squeeze past the "+YELLOW+GetName(OBJECT_SELF)+PINK+".", oCreature, FALSE);

        }
    }
}
