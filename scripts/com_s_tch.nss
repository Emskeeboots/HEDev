#include "com_source"
///////////////////////////////////////////////////////////////////////////////
/////////////////////Mad Rabbit's Player Chat Commands/////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////Declarations////////////////////////////////////

//Temporarily saves the description of oPC
//void TouchOn(object oPC)

//Loads the saved description for oPC
//void TouchOff(object oPC)


///////////////////////////////Definition//////////////////////////////////////



void TouchOn(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    object oPC = OBJECT_SELF;

    //allows characters to get close to each othere

   // Apply Ghost Effect/etc
    effect eGhost = EffectCutsceneGhost();
    eGhost = SupernaturalEffect( eGhost );
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,eGhost,oPC);
    SendMessageToPC(oPC, "Touching On");
}

void TouchOff(object oPC)
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    object oPC = OBJECT_SELF;

    //turns off touching

   // Apply Ghost Effect/etc
    effect eGhost = EffectCutsceneGhost();
    eGhost = SupernaturalEffect( eGhost );
    RemoveEffect(oPC, eGhost);
    SendMessageToPC(oPC, "Touching Off");
}

////////////////////////////////Main Code//////////////////////////////////////

void main()
{
    object oPC = OBJECT_SELF;
    string sMessage = GetPCChatMessage();
    string sSecondaryCommand = GetSubString(sMessage, 5, 3);

    if (sSecondaryCommand == "on")
        TouchOn(oPC);
    else if (sSecondaryCommand == "off")
        TouchOff(oPC);

}



