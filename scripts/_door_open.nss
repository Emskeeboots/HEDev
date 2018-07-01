//::///////////////////////////////////////////////
//:: _door_open
//:://////////////////////////////////////////////
/*
    intended for use in a doors (or placeable container) onopen event
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 feb 7)
//:: Modified: The Magus (2012 jun 9) modified to work with placeable container
//:: Modified: Henesua (2013 dec 2) changed time delay (on key unidentified check) from miliseconds to seconds
//:://////////////////////////////////////////////

#include "x2_inc_switches"
#include "NW_I0_GENERIC"

#include "_inc_spells" // for SPELL_ACT_PASSDOOR
#include "_inc_util" // for creature calls
#include "_inc_loot"

void main()
{
    int bClose, bLock   = FALSE;
    object oCreature    = GetLastOpenedBy();
    int bHandsRequired  = GetLocalInt(OBJECT_SELF, "HANDS_REQUIRED_TO_OPEN");
    int bIncorporeal    = CreatureGetIsIncorporeal(oCreature);

    // retrieve time-stamp of attempted use of unidentified key
    int nKeyUnID        = GetLocalInt(oCreature, "KEY_UNIDENTIFIED");
    DeleteLocalInt(oCreature, "KEY_UNIDENTIFIED");

    // work around for the use of unidentified keys on a locked door
    if( nKeyUnID && nKeyUnID+2 > GetTimeCumulative(TIME_SECONDS) )
    {
        bClose = TRUE; bLock  = TRUE;
    }
    // some creatures do not need to open certain doors
    else if(    !GetLockKeyRequired(OBJECT_SELF)
            &&  !GetLocalInt(OBJECT_SELF,"DOOR_NO_PASS")
            &&
                (   bIncorporeal
                ||  GetHasFeat(FEAT_PASS_DOOR, oCreature)
                ||  CreatureGetIsSoftBodied(oCreature)
                )
            )
    {
        bClose = TRUE;
        object oDoor    = OBJECT_SELF;
        AssignCommand(oCreature,
            ActionCastSpellAtObject(SPELL_ACT_PASSDOOR, oDoor, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)
                );
    }
    // some doors require the use of hands
    else if(    bHandsRequired
            && (bIncorporeal || !CreatureGetHasHands(oCreature))
            )
    {
        bClose = TRUE;
        if(GetIsPC(oCreature))
            SendMessageToPC(oCreature, RED+"You need hands to open the "+PINK+GetName(OBJECT_SELF)+RED+".");
    }

    if(bClose)
    {
        int bDestDoor;object oDest;
      if(GetObjectType(OBJECT_SELF)==OBJECT_TYPE_DOOR)
      {
        oDest = GetTransitionTarget(OBJECT_SELF);
        bDestDoor= GetObjectType(oDest)==OBJECT_TYPE_DOOR;
        PlayAnimation(ANIMATION_DOOR_CLOSE);
        if(bDestDoor)
            AssignCommand(oDest, PlayAnimation(ANIMATION_DOOR_CLOSE));
        else
        {
            string sDestDoor    = GetLocalString(OBJECT_SELF,"DOOR_PAIRED_TAG");
            if(sDestDoor!="")
            {
                int nNth;
                oDest   = GetObjectByTag(sDestDoor,nNth);
                while(GetIsObjectValid(oDest))
                {
                    bDestDoor= GetObjectType(oDest)==OBJECT_TYPE_DOOR;
                    if(bDestDoor)
                    {
                        AssignCommand(oDest, PlayAnimation(ANIMATION_DOOR_CLOSE));
                        break;
                    }
                    oDest   = GetObjectByTag(sDestDoor,++nNth);
                }
            }
        }
      }
      else
        PlayAnimation(ANIMATION_PLACEABLE_CLOSE);

      if(bLock)
      {
        SetLocked(OBJECT_SELF,TRUE);



        if(bDestDoor)
            DelayCommand(0.2, SetLocked(oDest,TRUE));
        string sSnd     = GetLocalString(OBJECT_SELF, "DOOR_LOCKED_SOUND");
        if(sSnd==""){sSnd="as_dr_locked1";}
        PlaySound(sSnd);
        FloatingTextStringOnCreature(WHITE+"*Fumbles with the "+GetName(OBJECT_SELF)+"*", oCreature);
        SendMessageToPC(oCreature, "This object is locked.");
      }
    }
    // open door -- special case for a door which has a pair but transitions to a waypoint instead
    else
    {
        int bDestDoor;object oDest;
      if(GetObjectType(OBJECT_SELF)==OBJECT_TYPE_DOOR)
      {
        oDest = GetTransitionTarget(OBJECT_SELF);
        bDestDoor= GetObjectType(oDest)==OBJECT_TYPE_DOOR;
        if(!bDestDoor)
        {
            string sDestDoor    = GetLocalString(OBJECT_SELF,"DOOR_PAIRED_TAG");
            if(sDestDoor!="")
            {
                int nNth;
                oDest   = GetObjectByTag(sDestDoor,nNth);
                while(GetIsObjectValid(oDest))
                {
                    bDestDoor= GetObjectType(oDest)==OBJECT_TYPE_DOOR;
                    if(bDestDoor)
                    {
                        AssignCommand(oDest, PlayAnimation(ANIMATION_DOOR_OPEN1));
                        break;
                    }
                    oDest   = GetObjectByTag(sDestDoor,++nNth);
                }
            }
        }
      }
      // not a door.. this is a placeable, perhaps with loot
      else
      {
        if(GetLocalInt(OBJECT_SELF,"LOOT"))
            LootGenerate(oCreature);
      }
    }

    object oDoor    = OBJECT_SELF;
    DelayCommand(60.0, AssignCommand(oDoor, ActionCloseDoor(oDoor)));



}





