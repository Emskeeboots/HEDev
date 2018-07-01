//::///////////////////////////////////////////////
//:: _s2_track
//:://////////////////////////////////////////////
/*
    Tracking Feat

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 16)
//:: Modified
//:://////////////////////////////////////////////

#include "_inc_spells"
#include "_inc_xp"

void RewardTracker(object oTracker, int bSuccess)
{
    int nLastTrackTime  = GetLocalInt(oTracker, "SKILL_TRACK_MINUTE");
    int nThisTrackTime  = GetTimeCumulative();
    SetLocalInt(oTracker, "SKILL_TRACK_MINUTE", nThisTrackTime);
    if (nLastTrackTime+1 <= nThisTrackTime)
        XPRewardByType("SKILL_TRACK", oTracker, bSuccess*2, XP_TYPE_ABILITY); // reward ability use
}

//examine specific tracks
int ExamineSpecificTracks(object oTracks, object oTracker, int iTrackArea)
{
    int nFindValue = 0;
    string sTracked, sTime, sMsg;
    int nLevel  = GetLevelByClass(CLASS_TYPE_RANGER, oTracker);
    int iSkill  = GetSkillRank(SKILL_SEARCH, oTracker, TRUE) + GetAbilityModifier(ABILITY_WISDOM, oTracker);
    int nNow    = GetTimeCumulative(TIME_HOURS); // gives current game hour
    object oQuarry1 = GetLocalObject(oTracker,"QUARRY_1");
    object oQuarry2 = GetLocalObject(oTracker, "QUARRY_2");
    int bQ1, bQ2;
    if(GetIsObjectValid(oQuarry1))
        bQ1 = TRUE;
    if(GetIsObjectValid(oQuarry2))
        bQ2 = TRUE;

    int nTrTime, nTrRace, nTrSex, nTrLoad, nFE, nHours;
    object oTrID;

    // Object type
    int nTrackType  = GetObjectType(oTracks);

    // Campsite ----------------------------------------------------------------
    if(GetLocalInt(oTracks,"campsite"))
    {
        sMsg = "Examining the old campsite you find ";
        int nTracks = GetLocalInt(oTracks,"RESTED_TOTAL");
        if(nTracks > 0)
        {
            int nIter = 1;

            while (nIter <= nTracks)
            {
                nTrTime = GetLocalInt(oTracks,"RESTED_"+IntToString(nIter)+"_HOUR");
                oTrID   = GetLocalObject(oTracks,"RESTED_"+IntToString(nIter)+"_ID");

                nHours  = nNow - nTrTime;
                if (nLevel > 0)
                    nFE = GetFavoredEnemyBonus(oTracker, oTrID);

                if( (d20() + iSkill + nFE) >= (iTrackArea+nHours) )
                {
                    ++nFindValue;
                    if(nFindValue>1)
                        sTracked+=", ";
                    if((oTrID==oQuarry1 && bQ1) || (oTrID==oQuarry2 && bQ2))
                    {
                        sTracked += GetName(oTrID);
                    }
                    else
                    {
                        nTrRace = GetLocalInt(oTracks,"RESTED_"+IntToString(nIter)+"_RACE");
                        nTrSex  = GetLocalInt(oTracks,"RESTED_"+IntToString(nIter)+"_GENDER");
                        sTracked += "a ";
                        // gender/race
                        if(nTrSex == GENDER_MALE)
                            sTracked += "male ";
                        else if(nTrSex == GENDER_FEMALE)
                            sTracked += "female ";

                        if(nTrRace == RACIAL_TYPE_HALFLING)
                            sTracked += "pygmy";
                        else if(nTrRace == RACIAL_TYPE_ELF)
                            sTracked += "elf";
                        else if(nTrRace == RACIAL_TYPE_DWARF)
                            sTracked += "dwarf";
                        else if(nTrRace == RACIAL_TYPE_GNOME)
                            sTracked += "gnome";
                        else if(nTrRace == RACIAL_TYPE_HALFELF)
                            sTracked += "feyborn";
                        else if(nTrRace == RACIAL_TYPE_HALFORC)
                            sTracked += "goblin-touched";
                        else if(nTrRace == RACIAL_TYPE_HUMAN)
                            sTracked += "human";
                    }
                    // time frame
                    if (nHours<1)
                        sTracked += " recently";
                    else
                    {
                        sTracked += " "+ IntToString(nHours)+" hour";
                        if(nHours>1)
                            sTracked += IntToString(nHours)+"s";
                        sTracked += " ago";
                    }
                    // heavy load?
                    nTrLoad = GetLocalInt(oTracks,"RESTED_"+IntToString(nIter)+"_WEIGHT");
                    sTracked += " weighing "+(IntToString(nTrLoad))+" pounds with gear";
                }
                nIter++;
            }
            if(nFindValue>0)
                sMsg += "the signs of "+IntToString(nFindValue)+" who rested here including:";
        }
        if(sTracked=="")
            sMsg += "no sign of who used it.";
        SendMessageToPC(oTracker, LIME+sMsg);
        if(sTracked!="")
            SendMessageToPC(oTracker, LIME+sTracked+".");
    }
    // cast off item -----------------------------------------------------------
    else if(nTrackType==OBJECT_TYPE_ITEM)
    {

        nTrTime     = GetLocalInt(oTracks,"TRACKS_TIME");
        oTrID       = GetLocalObject(oTracks,"TRACKS_ID");
        string sDesc= GetLocalString(oTracks,"TRACKS_DESCRIPTION");
        nTrRace     = GetLocalInt(oTracks,"TRACKS_RACE");
        int nLycan  = GetLocalInt(oTracks,"TRACKS_LYCAN");
        nTrSex      = GetLocalInt(oTracks,"TRACKS_GENDER");
        nHours  = nNow - nTrTime;
        if (nLevel > 0)
            nFE = GetFavoredEnemyBonus(oTracker, oTrID);

        if( (d20() + iSkill + nFE) >= (iTrackArea+nHours) )
        {
            if(nHours<1)
                sTime+="less than an hour ago";
            else if(nHours==1)
                sTime+="1 hour ago";
            else
                sTime+=IntToString(nHours)+" hours ago";

            sTracked = "You have found ";
            nFindValue = 1;
            if((oTrID==oQuarry1 && bQ1) || (oTrID==oQuarry2 && bQ2))
            {
                sTracked += GetName(oTrID)+"'s ";
                //if(nTrRace == RACIAL_TYPE_LYCANTHROPE)
                if(nTrRace == RACIAL_TYPE_SHAPECHANGER)
                {
                    sMsg = " dropped "+sTime+" while transforming into a ";
                    if(nLycan==POLYMORPH_TYPE_WERERAT)
                        sMsg += "wererat";
                    else if(nLycan==POLYMORPH_TYPE_WERECAT)
                        sMsg += "werepanther";
                    else if(nLycan==POLYMORPH_TYPE_WEREWOLF)
                        sMsg += "werewolf";
                    else if(nLycan==POLYMORPH_TYPE_WEREBOAR)
                        sMsg += "wereboar";
                    else
                        sMsg += "lycanthrope";
                }
            }
            else
            {
                // gender/race
                if(nTrSex == -1)
                    sTracked += "";
                else if(nTrSex == GENDER_MALE)
                    sTracked += "a male ";
                else if(nTrSex == GENDER_FEMALE)
                    sTracked += "a female ";

                if(nTrRace == -1)
                    sTracked += "a being";
                else if(nTrRace == RACIAL_TYPE_HALFLING)
                    sTracked += "halfling";
                else if(nTrRace == RACIAL_TYPE_ELF)
                    sTracked += "elf";
                else if(nTrRace == RACIAL_TYPE_DWARF)
                    sTracked += "dwarf";
                else if(nTrRace == RACIAL_TYPE_GNOME)
                    sTracked += "gnome";
                else if(nTrRace == RACIAL_TYPE_HALFELF)
                    sTracked += "half-elf";
                else if(nTrRace == RACIAL_TYPE_HALFORC)
                    sTracked += "orclun";
                else if(nTrRace == RACIAL_TYPE_HUMAN)
                    sTracked += "human";
                else if(nTrRace == RACIAL_TYPE_SHAPECHANGER)
                {
                    if(nLycan==POLYMORPH_TYPE_WERERAT)
                        sTracked += "wererat";
                    else if(nLycan==POLYMORPH_TYPE_WERECAT)
                        sTracked += "werepanther";
                    else if(nLycan==POLYMORPH_TYPE_WEREWOLF)
                        sTracked += "werewolf";
                    else if(nLycan==POLYMORPH_TYPE_WEREBOAR)
                        sTracked += "wereboar";
                    else
                        sTracked += "lycanthrope";
                }
                sTracked +="'s ";
            }
            if(sDesc=="")
                sTracked += GetName(oTracks);
            else
                sTracked += sDesc;

            if(sMsg=="")
                sTracked += " dropped "+sTime;
            else
                sTracked += sMsg;

            DeleteLocalInt(oTracks,"TRACKS");
            DeleteLocalObject(oTracks,"TRACKS_ID");
            DeleteLocalString(oTracks,"TRACKS_DESCRIPTION");
            DeleteLocalInt(oTracks,"TRACKS_OWNER_RACE");
            DeleteLocalInt(oTracks,"TRACKS_LYCAN");
            DeleteLocalInt(oTracks,"TRACKS_GENDER");

            SendMessageToPC(oTracker, LIME+sTracked+".");
        }
    }
    // tracks placed in toolset ------------------------------------------------
    else if(nTrackType==OBJECT_TYPE_PLACEABLE)
    {
        nHours      = GetLocalInt(oTracks,"TRACKS_TIME_HOUR");
        if(nHours)
        {
            nHours  = GetTimeHour() - nHours;
            if(nHours<0){nHours += 24;}
            DeleteLocalInt(oTracks,"TRACKS_TIME_HOUR");
            SetLocalInt(oTracks,"TRACKS_TIME",nNow-nHours);
        }
        else
            nHours  = nNow - GetLocalInt(oTracks,"TRACKS_TIME");

        if(nHours<1)
            sTime   = "less than an hour";
        else if(nHours==1)
            sTime   = "1 hour";
        else
            sTime   = IntToString(nHours)+" hours";

        nTrRace     = GetLocalInt(oTracks,"TRACKS_RACE");
        if(nTrRace==-1)
            nTrRace=RACIAL_TYPE_INVALID;
        //int nLycan  = GetLocalInt(oTracks,"TRACKS_LYCAN");
        //nTrSex      = GetLocalInt(oTracks,"TRACKS_GENDER");

        // Determine difficulty of tracks
        int nAdj    = GetLocalInt(oTracks,"TRACKS_DIFFICULTY");
        // convert hours into DC adjustment
        int nWeatherConditions;
        if(!nWeatherConditions)
            nAdj    = nAdj + FloatToInt(nHours/12.0);
        else if(nWeatherConditions==1)
            nAdj    = nAdj + FloatToInt(nHours/4.0);
        else if(nWeatherConditions==2)
            nAdj    = nAdj + nHours;

        // Determine outcome of tracking
        if (nLevel > 0)
            nFE = GetFavoredEnemyBonus(oTracker, OBJECT_INVALID, nTrRace);
        if( (d20() + iSkill + nFE) >= (iTrackArea+nAdj) )
        {
            nFindValue  = 1;
            sTracked    =   GREEN   +GetName(oTracks)   +BR
                           +LIME    +sTime+" old:"           +BR
                                    +GetLocalString(oTracks,"TRACKS_DESCRIPTION");
            SendMessageToPC(oTracker, sTracked);
        }
    }
    else
    {
        // no other tracks yet implented
    }
    return nFindValue;
}

//  Given the facing value (0-360), set the compass direction.
void GetDirection(float fFacing, object oTracker, object oCritter)
{
    //Correct the bug in GetFacing (Thanks Iskander)
    if (fFacing >= 360.0)
        fFacing  =  720.0 - fFacing;
    if (fFacing <    0.0)
        fFacing += (360.0);

    string sDirection = "";
    if((fFacing >= 348.75) || (fFacing <= 11.25))
        sDirection = "E";
    else if((fFacing >= 11.25) && (fFacing <= 33.75))
        sDirection = "ENE";
    else if((fFacing >= 33.75) && (fFacing <= 56.25))
        sDirection = "NE";
    else if((fFacing >= 56.25) && (fFacing <= 78.75))
        sDirection = "NNE";
    else if((fFacing >= 78.75) && (fFacing <= 101.25))
        sDirection = "N";
    else if((fFacing >= 101.25) && (fFacing <= 123.75))
        sDirection = "NNW";
    else if((fFacing >= 123.75) && (fFacing <= 146.25))
        sDirection = "NW";
    else if((fFacing >= 146.25) && (fFacing <= 168.75))
        sDirection = "WNW";
    else if((fFacing >= 168.75) && (fFacing <= 191.25))
        sDirection = "W";
    else if((fFacing >= 191.25) && (fFacing <= 213.75))
        sDirection = "WSW";
    else if((fFacing >= 213.75) && (fFacing <= 236.25))
        sDirection = "SW";
    else if((fFacing >= 236.25) && (fFacing <= 258.75))
        sDirection = "SSW";
    else if((fFacing >= 258.75) && (fFacing <= 281.25))
        sDirection = "S";
    else if((fFacing >= 281.25) && (fFacing <= 303.75))
        sDirection = "SSE";
    else if((fFacing >= 303.75) && (fFacing <= 326.25))
        sDirection = "SE";
    else if((fFacing >= 326.25) && (fFacing <= 348.75))
        sDirection = "ESE";

    SendMessageToPC(oTracker, LIGHTBLUE + GetName(oCritter) + " is to the " + sDirection);
}

void main()
{
    string STOPTRACKING = LIGHTBLUE + "You stop tracking your target.";
    string NOFOOTPRINTS = LIGHTBLUE + "You detect no footprints to track.";
    string STARTTRACK   = LIGHTBLUE + "You begin tracking: ";
    string CONTTRACK    = LIGHTBLUE + "You continue tracking: ";
    string NOTPOSSIBLE  = LIGHTBLUE + "It is impossible to sort out tracks here.";
    string DCFAIL       = LIGHTBLUE + "You are unable to single out a track to follow.";
    string DCCONTFAIL   = LIGHTBLUE + "You lose the track.";
    string TRAILGONE    = LIGHTBLUE + "The trail seems to have stopped here...";
    string TOOMANY      = LIGHTBLUE + "There are too many tracks here to sort out.";


    if(!GetHasFeat(FEAT_TRACK) && !GetHasFeat(FEAT_SCENT) )
    {
        SendMessageToPC(OBJECT_SELF, RED + "You lack the skill to sort out tracks.");
        return;
    }

    if(GetLocalInt(OBJECT_SELF, "TRACKING_MODE"))
        return;
    else
        SetLocalInt(OBJECT_SELF, "TRACKING_MODE",TRUE);

    // tracking begin
    int nSpellId    = GetSpellId();
    if(nSpellId==SPELL_ACT_TRACK)
        ClearAllActions(TRUE);

    int bFound, bSuccess;
    object oTarget      = GetSpellTargetObject();
    location lTarget    = GetSpellTargetLocation();
    object oArea        = GetArea(OBJECT_SELF);
    int iTrackArea      = GetLocalInt(oArea, "AREA_TRACK_DC_ADJUSTMENT");
    if(!iTrackArea){ iTrackArea = 10;} // default track DC
    float fDist;
    // Specific Trails the tracker can follow
    object oQuarry1     = GetLocalObject(OBJECT_SELF,"QUARRY_1");
    object oQuarry2     = GetLocalObject(OBJECT_SELF,"QUARRY_2");

    if(oTarget!=OBJECT_SELF)
        fDist   = GetDistanceBetweenLocations(lTarget, GetLocation(OBJECT_SELF));

    if(GetLocalInt(oTarget,"TRACKS"))
        bFound = TRUE;

    if(fDist>=2.0)
    {
        if(bFound || !GetIsObjectValid(oTarget))
            ActionMoveToLocation(lTarget); // tracks (placeable) or ground targeted
    }

    if(!bFound && GetObjectType(oTarget)==OBJECT_TYPE_CREATURE && nSpellId!=SPELL_ACT_SCENT)
    {
      // TRACKING PCS --------------------------------------------------------
      if(GetIsPC(oTarget))
      {
        if(GetObjectSeen(OBJECT_SELF,oTarget))
        {
            SendMessageToPC(oTarget, LIGHTBLUE+GetName(OBJECT_SELF)+" watches you intently.");
        }

        // feedback
        string sTrackingMessage = LIGHTBLUE+"You are now tracking ";
        sTrackingMessage += GetName(oTarget);
        if(GetIsObjectValid(oQuarry1))
            sTrackingMessage += " and "+GetName(oQuarry1)+".";
        else
            sTrackingMessage +=".";
        //update trails which the tracker is following
        if(oTarget!=oQuarry1)
        {
            SetLocalObject(OBJECT_SELF, "QUARRY_1", oTarget);
            SetLocalObject(OBJECT_SELF, "QUARRY_2", oQuarry1);
        }
        else
        {
            sTrackingMessage = PINK+"You are already tracking "+GetName(oTarget)+".";
        }

        SendMessageToPC(OBJECT_SELF, sTrackingMessage);

        if(GetIsObjectValid(oQuarry2) && oTarget!=oQuarry2 && oQuarry1!=oQuarry2)
        {
            // Garbage collection. Stop tracking last quarry.
            int nTemp = GetLocalInt(oQuarry2,"TRACKED")-1;
            if(nTemp < 1)
                DeleteLocalInt(oQuarry2,"TRACKED");
            else
                SetLocalInt(oQuarry2,"TRACKED",nTemp);

            SendMessageToPC(OBJECT_SELF, PINK+"You have abandonned the trail of "+GetName(oQuarry2)+".");
        }

        // iterate target's tracking count if we are not yet tracking this one
        if(oTarget!=oQuarry1 && oTarget!=oQuarry2)
            SetLocalInt(oTarget,"TRACKED",GetLocalInt(oTarget,"TRACKED")+1);
        return;
      }
      else
      {
        SendMessageToPC(OBJECT_SELF, PINK+"This creature can not be singled out for tracking.");
        return;
      }
    }
    else
    {
        ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW,1.0,4.0);
    }

// TRACKING BEGINS -------------------------------------------------------------
    // Is the area Trackable?
    /*
    if(iTrackArea == -1)
    {
        SendMessageToPC(OBJECT_SELF, NOTPOSSIBLE);
        return;
    }
    else if(iTrackArea == 21)
    {
        SendMessageToPC(OBJECT_SELF, TOOMANY);
        return;
    }
    */

    //looking for special tracks
    int nNth=1;
    object oTracks = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_ITEM, lTarget, nNth);
    while (GetDistanceBetweenLocations(lTarget, GetLocation(oTracks))<=6.5 && !bFound)
    {
        //SendMessageToPC(OBJECT_SELF,"Found tracks("+GetName(oTracks)+")");
        if(GetLocalInt(oTracks,"TRACKS"))
        {
            // found some special tracks
            bSuccess   += ExamineSpecificTracks(oTracks,OBJECT_SELF,iTrackArea);
            if(bSuccess > 0)
                bFound = TRUE;
        }

        oTracks = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lTarget, ++nNth);
    }

    // if nothing has yet been found run the standard tracking routine
  if(!bFound || nSpellId==SPELL_ACT_SCENT)
  {
    object oCritter;
    int nLevel  =GetLevelByClass(CLASS_TYPE_RANGER, OBJECT_SELF);
    int iSkill  = GetSkillRank(SKILL_SEARCH, OBJECT_SELF, TRUE) + GetAbilityModifier(ABILITY_WISDOM, OBJECT_SELF);
    int nCnt=1;
    float fDistance;
    int nDCAdj;
    int nFE = 0;
    vector vCritter;
    oCritter=GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, nCnt);
    while(GetIsObjectValid(oCritter) &&
          GetArea(oCritter)==oArea)
    {
        fDistance=GetDistanceBetween(oCritter, OBJECT_SELF);
        nDCAdj=FloatToInt(fDistance/10.0);
        if (nLevel > 0)
            nFE = GetFavoredEnemyBonus(OBJECT_SELF, oCritter);
        if( (d20() + iSkill + nFE) >= (iTrackArea+nDCAdj)
            && (
                !GetLocalInt(oCritter,"NOTRACK")
                && !CreatureGetIsIncorporeal(oCritter)
                && !CreatureGetIsFlying(oCritter)
                && !GetHasFeat(FEAT_TRACKLESS_STEP, oCritter)
                && !GetHasSpellEffect(SPELL_PASS_WITH_NO_TRACE, oCritter)
                )
           )
        {
            // success
            bSuccess ++;
            vCritter=GetPosition(oCritter);
            AssignCommand(OBJECT_SELF,SetFacingPoint (vCritter));
            AssignCommand(OBJECT_SELF,GetDirection(GetFacing(OBJECT_SELF),OBJECT_SELF,
                oCritter));
        }
        nCnt++;
        oCritter=GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, nCnt);
    }
  }// General Tracking Completed

    // Reward successful trackers
    if(bSuccess)
        RewardTracker(OBJECT_SELF, bSuccess);

    SendMessageToPC(OBJECT_SELF, LIGHTBLUE + "Tracking Completed.");
    DelayCommand(1.0, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD));
    DelayCommand(3.2, DeleteLocalInt(OBJECT_SELF, "TRACKING_MODE"));
}
