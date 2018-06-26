//::///////////////////////////////////////////////
//:: _trg_describe
//:://////////////////////////////////////////////
/*
    place in a trigger's onenter event
    entering pc's will get descriptive text

    local vars can be used to customize the trigger.

    DESCRIPTION description given to the PC (The name field of the trigger is given as a title)

    DESCRIPTION_TYPE            0 = unlimited uses (but only once a minute per PC)
                                1 = one use per reset
                                2 = one use per PC per reset
                                3 = one use per PC - persistent across resets

    DESCRIPTION_XP              amount of XP awarded for discovering

    DESCRIPTION_SOUND           sound string of a sound to play
    DESCRIPTION_SOUND_DELAY     float delay for sound play back
    DESCRIPTION_VFX             vfx int to play
    DESCRIPTION_VFX_DURATION    float seconds for VFX duration
    DESCRIPTION_VFX_DELAY       float seconds until VFX happens

    DESCRIPTION_SCRIPT          custom script to run after giving description


    Determining Whether the Description Can Continue
    see GetDescriptionCanContinue() in _inc_util

    DESCRIPTION_OBJECT          tag of an object. The description is only given when the object is present.
    DESCRIPTION_TRACK           only runs for PC with tracking feat
    DESCRIPTION_STONECUNNING    only runs for characters with stone cunning
    DESCRIPTION_SCENT           only runs for PC with scent feat
    DESCRIPTION_HOUR_START      only runs at this hour or later
    DESCRIPTION_HOUR_END        does not run at this hour or later
    DESCRIPTION_NIGHT           only runs during the night
    DESCRIPTION_DAY             only runs during the day

*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2011 july 23)
//:: Modified:   The Magus (2012 jan 7) adjusted use of GetCurrentGameTime and error tracking
//:: Modified:   The Magus (2012 mar 15) added sound, sound delay, and custom script
//:: Modified:   The Magus (2012 aug 5) added type 3: PC persistent
//:: Modified:  The Magus (2012 nov 9) added vfx to happen with sound
//:://////////////////////////////////////////////
//:: Modified:  The Magus (2013 dec 7) vivesified
//:: Modified:  Henesua (2014 jun 9) added check for DESCRIPTION_OBJECT --> presence of an object which this trigger describes

// INCLUDES
#include "_inc_constants"
#include "_inc_util"
#include "_inc_data"
#include "_inc_xp"

void main()
{
    object oPC  = GetEnteringObject();

    // if not a PC we don't need to deliver a description
    if(!GetIsPC(oPC)) return;

    // exclusivity checks
    if(!GetDescriptionCanContinue(oPC)) return;

    int iLimit  = GetLocalInt(OBJECT_SELF, "DESCRIPTION_TYPE");
    int iXP     = GetLocalInt(OBJECT_SELF, "DESCRIPTION_XP");
    string sNam = GetName(OBJECT_SELF);
    string sDes = GetLocalString(OBJECT_SELF, "DESCRIPTION");
    string sTag = GetTag(OBJECT_SELF);
    string sID  = "TRG_"+sTag+"_"+GetStringRight(sDes, 12);
    int iUses   = GetLocalInt(OBJECT_SELF, "USES");
    int iPCUses;
    if(iLimit==2)
        iPCUses = GetLocalInt(oPC, TAG_ENTRY+sID);
    else if(iLimit==3) {
        iPCUses = GetPersistentInt(oPC, TAG_ENTRY+sID);
    }

    int iPCTime = GetLocalInt(oPC, sID+"_TIME");
    int iTrgTime= GetLocalInt(OBJECT_SELF, "TIME");
    int iMinute = GetTimeCumulative(TIME_MINUTES);
    SetLocalInt(OBJECT_SELF, "TIME", iMinute);

    string sFnc = GetLocalString(OBJECT_SELF, "SCRIPT");

    // Check if description was set
    if(sDes == "")
    {
        WriteTimestampedLogEntry("ERR> _trg_describe - string(DESCRIPTION) not set on Trigger("+sID+") in Area("+GetName(GetArea(OBJECT_SELF))+")");
        return;
    }

    // Determine if description is given
    switch (iLimit)
    {
        case 0:
            if (iPCTime != 0 && iPCTime <= (iMinute+2)) return;
            else
                SetLocalInt(oPC, sID+"_TIME", iMinute);
        break;
        case 1:
            if(iUses > 0) return;
            else if(!GetIsDM(oPC))
                SetLocalInt(OBJECT_SELF, "USES", ++iUses);
        break;
        case 2:
            if(iPCUses > 0) return;
            else
                SetLocalInt(oPC, TAG_ENTRY+sID, ++iPCUses);
        break;
        case 3:
            if(iPCUses > 0) return;
            else { 
                  SetPersistentInt(oPC, TAG_ENTRY+sID, ++iPCUses);
            }
        break;
        default:
            WriteTimestampedLogEntry("ERR> _trg_describe - int(TYPE) has incorrect value on Trigger("+sID+") in Area("+GetName(GetArea(OBJECT_SELF))+")");
            return;
        break;
    }

    DelayCommand(0.5, SendMessageToPC(oPC, " "));
    if(sNam!="" && sNam!="Description Title")
        DelayCommand(0.6, SendMessageToPC(oPC, GREEN+sNam));
    DelayCommand(0.7, SendMessageToPC(oPC, LIME+"  "+sDes));
    /*
    // Give list of AID objects
    string sListOfAIDObjects    = GetNamesOfNearbyAIDObjects(oPC);
    if(sListOfAIDObjects!="")
        DelayCommand(0.8, SendMessageToPC(oPC, sListOfAIDObjects) );
    */

    if(!iTrgTime || iMinute>iTrgTime)
    {   // only play the sound and/or VFX once per minute
        string sSnd = GetLocalString(OBJECT_SELF, "DESCRIPTION_SOUND");
        float fDelay= GetLocalFloat(OBJECT_SELF, "DESCRIPTION_SOUND_DELAY");
        int nVFX    = GetLocalInt(OBJECT_SELF, "DESCRIPTION_VFX");

        if(sSnd!="")
            AssignCommand(  oPC,
                            DelayCommand(fDelay, PlaySound(sSnd))
                          );
        if(nVFX && !GetIsDM(oPC))
        {
            float fVFXDur   = GetLocalFloat(OBJECT_SELF, "DESCRIPTION_VFX_DURATION");
            int nVFXType;
            if(fVFXDur>0.0)
                nVFXType    = DURATION_TYPE_TEMPORARY;
            else
                nVFXType    = DURATION_TYPE_INSTANT;
            DelayCommand(   GetLocalFloat(OBJECT_SELF, "DESCRIPTION_VFX_DELAY"),
                            ApplyEffectAtLocation(  nVFXType,
                                                    EffectVisualEffect(nVFX),
                                                    GetLocation(oPC),
                                                    fVFXDur
                                                  )
                        );
        }
    }

    if(iXP>0)
        DelayCommand(1.2, XPRewardByType(sID, oPC, iXP, XP_TYPE_DISCOVERY));

    if(sFnc!="")
        ExecuteScript(sFnc, OBJECT_SELF);
}
