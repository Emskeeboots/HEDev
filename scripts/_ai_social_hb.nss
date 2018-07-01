//::///////////////////////////////////////////////
//:: _ai_social_hb
//:://////////////////////////////////////////////
/*
    Userdef Heartbeat AI for social phenotype characters

 */
//:://////////////////////////////////////////////////
//:: Created: Henesua (2014 may 16)
//:://////////////////////////////////////////////////

#include "_inc_constants"
#include "_inc_util"

#include "nw_i0_generic"

void SocialChair(string sRef, location lLoc, float fFacing);
void SocialChair(string sRef, location lLoc, float fFacing)
{
    object oChair   = CreateObject( OBJECT_TYPE_PLACEABLE,
                                    sRef,
                                    lLoc,FALSE,"SEAT"+ObjectToString(OBJECT_SELF)
                                  );
    SetLocalString(oChair, "SEAT_ORIGINAL", GetStringLeft(sRef,GetStringLength(sRef)-1) );
    SetLocalObject(OBJECT_SELF,"SEAT_CLAIMED",oChair);
    SetLocalString(oChair,"SEAT_CLAIMED",ObjectToString(OBJECT_SELF));
    SetLocalFloat(oChair, "SEAT_FACING", fFacing);
}

int GetIsPositionDifferent(location lLoc1, location lLoc2, float fMaxDist);
int GetIsPositionDifferent(location lLoc1, location lLoc2, float fMaxDist)
{
    if(     GetDistanceBetweenLocations(lLoc1,lLoc2)>fMaxDist
      )
        return TRUE;
    else
    {
        float fOrig = GetLocalFloat(GetLocalObject(OBJECT_SELF,"SEAT_CLAIMED"),"SEAT_FACING");

        float fSelf = GetFacing(OBJECT_SELF);

            int nDif    = abs(FloatToInt(fSelf-fOrig));

            if(MODULE_DEBUG_MODE)
                SendMessageToPC(GetFirstPC(),"Facing Dif("+IntToString(nDif)+") Orig("+FloatToString(fOrig, 6)+") Self("+FloatToString(fSelf, 6)+")");

            if(nDif>5)
                return TRUE;

    }


    return FALSE;
}

int SocialInteractWithFriend(object oFriend);
int SocialInteractWithFriend(object oFriend)
{
    int bBusy;
    float fDistance = GetDistanceBetween(oFriend,OBJECT_SELF);

    if(fDistance<=3.5)
    {
        TurnToFaceObject(oFriend);
        // speak, drink, or cheer

        //bSuccess = TRUE;
    }
    else if(fDistance<=12.0)
    {
        ClearAllActions();
        ActionMoveToObject(oFriend);
        // speak, drink, or cheer

        bBusy = TRUE;
    }
    else
    {
        ClearAllActions();
        ActionMoveToObject(oFriend);
    }

    return bBusy;
}

void main()
{
    if(CreatureGetIsBusy())
        return;
    // Q - Social --------------------------------------------------------------
    object oSeat    = GetLocalObject(OBJECT_SELF,"SEAT_CLAIMED");
    // have we taken a seat once before using a social seating animation?
    if(GetLocalInt(OBJECT_SELF,"SEAT_SOCIAL"))
    {

        location lLoc   = GetLocation(oSeat);
        // have we left our seat?
        // if so then we should reset our chair so that it can be used
        // we will however maintain our claim on it if we can
        if(GetIsPositionDifferent(lLoc, GetLocation(OBJECT_SELF), 0.3))
        {
                ClearAllActions();

                string sReplace = GetLocalString(oSeat,"SEAT_ORIGINAL");
                if(sReplace=="")
                {
                    float fFacing   = GetLocalFloat(oSeat, "SEAT_FACING");

                    DelayCommand(1.0,JumpToLocation(lLoc));
                    DelayCommand(0.6,SetFacing(fFacing));
                    if(d2()==1)
                        DelayCommand(1.1,ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS,1.0,60000.0));
                    else
                        DelayCommand(1.1,ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM2,1.0,60000.0));
                }
                else
                {
                    DeleteLocalInt(OBJECT_SELF,"SEAT_SOCIAL");
                    object oReplace = CreateObject( OBJECT_TYPE_PLACEABLE, sReplace, lLoc );
                    SetLocalObject(OBJECT_SELF,"SEAT_CLAIMED",oReplace);
                    SetLocalString(oReplace,"SEAT_CLAIMED",ObjectToString(OBJECT_SELF));
                    DestroyObject(oSeat);

                }
            }


            return;
        }
        // are we currently taking a default sit action?
        // if so then we need to switch to a social seating animation
        else if(    GetCurrentAction(OBJECT_SELF)==ACTION_SIT
               )
        {
            if(     GetSittingCreature(oSeat)==OBJECT_SELF
                ||  GetLocalInt(OBJECT_SELF,"SEAT_NOT_CHOSEN_COUNT")
              )
            {
                if(GetLocalInt(OBJECT_SELF,"SEAT_NOT_CHOSEN_COUNT"))
                {
                    DeleteLocalInt(OBJECT_SELF,"SEAT_NOT_CHOSEN_COUNT");
                    string sSeatTag = GetLocalString(OBJECT_SELF, "SEAT_TAG");
                    if(sSeatTag=="")
                        sSeatTag    = GetLocalString(GetModule(), "SEAT_TAG");

                    oSeat = GetNearestObjectByTag(sSeatTag, OBJECT_SELF, 1);
                }

                float fFacing   = GetFacing(OBJECT_SELF);

                SetLocalInt(OBJECT_SELF,"SEAT_SOCIAL",TRUE);
                SetLocalInt(OBJECT_SELF,"SEAT_CLAIMED",TRUE);
                string sConvSnd = GetLocalString(OBJECT_SELF, "SOCIAL_SOUND");
                if(sConvSnd=="")
                {
                    int iChange = d4();
                    string sTxt = "as_pl_x2rghtav";
                    string sSound = sTxt + IntToString(iChange);
                    SetLocalString(OBJECT_SELF,"SOCIAL_SOUND",sSound);
                }
                ClearAllActions();
                location lLoc   = GetLocation(oSeat);

                string sRef     = GetResRef(oSeat)+"s";
                object oTemp    = CreateObject( OBJECT_TYPE_PLACEABLE, sRef, lLoc );
                if(GetIsObjectValid(oTemp))
                    DestroyObject(oSeat);
                else
                    sRef        = "stool1s";
                DestroyObject(oTemp,0.1);
                DelayCommand(1.0,JumpToLocation(lLoc));
                DelayCommand(1.1,SetFacing(fFacing));
                if(d2()==1)
                    DelayCommand(1.2,ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS,1.0,60000.0));
                else
                    DelayCommand(1.2,ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM2,1.0,60000.0));
                DelayCommand(1.3, SocialChair(sRef, lLoc, fFacing));
            }
            else
            {
                SetLocalInt(OBJECT_SELF,"SEAT_NOT_CHOSEN_COUNT",TRUE);
            }

            return;
        }
        // -- we are walking around and drinking and doing other social animations
        // lets try to congregate with our group members
        object oClothing    = GetItemInSlot(INVENTORY_SLOT_CHEST);
        int nClothingValue  = GetGoldPieceValue(oClothing);
        string sClothingRef = GetResRef(oClothing);

        int bSartorial      = (FindSubString(sClothingRef,"formal")!=-1);
        if(!bSartorial) bSartorial = (sClothingRef=="cloth005");
        int bSuccess,nIt;
      while(!bSuccess)
      {
        int nNth = 1;
        object oDrinkBuddy  = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, OBJECT_SELF, nNth);
        while(oDrinkBuddy!=OBJECT_INVALID)
        {
            oClothing    = GetItemInSlot(INVENTORY_SLOT_CHEST,oDrinkBuddy);
            if(    //GetSharesGroupMembership(oDrinkBuddy) // not yet implemented groups and factions
                   GetFactionEqual(oDrinkBuddy) // temp work around
                &&((!nIt &&( (bSartorial&&sClothingRef==GetResRef(oClothing)) || (!bSartorial&&GetGender(oDrinkBuddy)==GENDER_FEMALE) ))
                    || nIt
                  )
              )
            {
                bSuccess    = SocialInteractWithFriend(oDrinkBuddy);
                break;
            }

            oDrinkBuddy  = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, OBJECT_SELF, ++nNth);
        }
        ++nIt;
        if(nIt==2)break;
      }
        if(bSuccess)
            return;

        // random actions on heartbeat
        int iRnd = d20();
        switch(iRnd)
        {
            case 1:
             ClearAllActions();       //drink  (15% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_BOW));
            break;

            case 2:
             ClearAllActions();       //drink
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_BOW));
            break;

            case 3:
             ClearAllActions();       //drink
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_BOW));
            break;

            case 4:
             ClearAllActions();       //look right (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT));
            break;

            case 5:
             ClearAllActions();       //look left (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT));
            break;

            case 6:
             ClearAllActions();       //chug (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD));
            break;

            case 7:
             ClearAllActions();       //pause   (20% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE,1.0,6.0));
            break;

            case 8:
             ClearAllActions();      //pause
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE,1.0,6.0));
            break;

            case 9:
             ClearAllActions();      //pause
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE,1.0,6.0));
            break;

            case 10:
             ClearAllActions();      //pause
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE,1.0,6.0));
            break;

            case 11:
             ClearAllActions();      //cheers!  (10% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_GREETING));
            break;

            case 12:
             ClearAllActions();      //cheers!
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_GREETING));
            break;

            case 13:
             ClearAllActions();      //cheers! + drink   (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE));
            break;

            case 14:
             ClearAllActions();     //walk...   (10% chance)
             AssignCommand(OBJECT_SELF,ActionRandomWalk());
            break;

            case 15:
             ClearAllActions();     //walk...
             AssignCommand(OBJECT_SELF,ActionRandomWalk());
            break;

            case 16:
             ClearAllActions();     //bored   (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_BORED));
            break;

            case 17:
             ClearAllActions();     //we're getting a buzz now!  (10% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK,1.0,6.0));
            break;

            case 18:
             ClearAllActions();     //we're getting a buzz now!
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK,1.0,6.0));
            break;

            case 19:
             ClearAllActions();     //wahoo!   (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY3));
            break;

            case 20:
             ClearAllActions();     //tired    (5% chance)
             AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED,1.0,6.0));
            break;
        }
}
