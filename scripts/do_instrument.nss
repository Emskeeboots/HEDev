//::///////////////////////////////////////////////
//:: do_instrument
//:://////////////////////////////////////////////
/*
    script for musical instruments
        plays sound
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 nov 2)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_switches"

#include "_inc_util"

void UseInstrument(object oPC, object oItem)
{
    int nType       = StringToInt(GetStringRight(GetResRef(oItem),1));
    string sSound;
    int nRnd;
   if(!GetLevelByClass(CLASS_TYPE_BARD,oPC)
        &&
      !DoSkillCheck(oPC,SKILL_PERFORM, 10)
        &&
      !DoSkillCheck(oPC,SKILL_USE_MAGIC_DEVICE, 10)
     )
   {
        nRnd       = d2();
        // PCs declare to all present the failed performance
        AssignCommand(oPC, SpeakString("PERFORM_FAILURE", TALKVOLUME_SILENT_TALK) );

        if(nRnd==1)
            sSound = "as_pl_tavsongm1";
        else
            sSound = "as_pl_tavsongm2";
   }
   else
   {
    // PCs declare to all present the quality of the performance
    AssignCommand(oPC, SpeakString("PERFORM_"+IntToString(GetSkillRank(SKILL_PERFORM,oPC)), TALKVOLUME_SILENT_TALK) );

    switch(nType)
    {
        case 1:
        //tamborine
        nRnd        = d4();
        if(nRnd==1)
            sSound = "as_cv_tamborine1";
        else if (nRnd==2)
            sSound = "as_cv_tamborine2";
        else if (nRnd==3)
            sSound = "as_cv_drums2";
        else
            sSound = "al_pl_x2tablalp";
        break;
        case 2:
        case 3:
        case 5:
        case 7:
        //lute
        nRnd        = d3();
        if(nRnd==1)
            sSound = "as_cv_lute1";
       else if (nRnd==2)
            sSound = "as_cv_lute1b";
       else
            sSound = "sdr_bardsong";
        break;
        case 4:
        //pan flute
        nRnd        = d4();
        if(nRnd==1)
            sSound = "as_cv_flute1";
        else if (nRnd==2)
            sSound = "as_cv_eulpipe2";
        else if (nRnd==3)
            sSound = "as_cv_flute2";
        else
            sSound = "as_cv_eulpipe1";
        break;
        case 8:
        //trumpet
        nRnd        = d2();
        if (nRnd==1)
            sSound = "as_fanfare_intro";
        else
            sSound = "as_fanfare_long";

        break;
        default:
            sSound = "sdr_bardsong";
        break;
    }
   }
   AssignCommand(oPC, PlaySound(sSound));
}

void main()
{
    int nEvent      = GetUserDefinedItemEventNumber();

 if (nEvent ==X2_ITEM_EVENT_ACTIVATE)
 {
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
    UseInstrument(oPC, oItem);
 }
 else
 {
    object oDMFIUse = GetLocalObject(OBJECT_SELF, "DMFI_USE_INSTRUMENT");
    if(GetIsObjectValid(oDMFIUse))
    {
        DeleteLocalObject(OBJECT_SELF, "DMFI_USE_INSTRUMENT");
        UseInstrument(OBJECT_SELF, oDMFIUse);
    }
 }
}
