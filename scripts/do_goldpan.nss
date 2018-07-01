////////////////////////////////////////////////////////////////////////////////
//  goldpan.nss
//  HTF System - panning for gold
//  Modified by Meaglyn

//  Placed in the Module On Activate Item Event
//
//  You must be in a "Stream" body of water...basically
//  a water source trigger
//
//  NOTE: You will get a message when you enter one
//        of these triggers.
//
//
//
////////////////////////////////////////////////////////////////////////////////

#include "x2_inc_switches"
#include "tb_inc_color"

string NOPANNINGHERE    = "Find a Stream to pan for gold.";


// If these are stackable items you can randomize the stacksize
string PANNING_GRAND_RES = "tt_hnugget";  // large nugget
string PANNING_HIGH_RES = "tt_lnugget";  // large nugget
string PANNING_MED_RES = "tt_snugget";      // nugget
string PANNING_LOW_RES = "tt_gfleck";   // tiny bit



// From  "hfc_inc"
int hfcDoPanningCheck(object oPC, int bReport, int nDC) {

        int nSkill = GetAbilityModifier(ABILITY_WISDOM,oPC);
    if (nSkill > 4) nSkill = 4;

        if (nDC <= 0) nDC = 18;

        int nRoll = d20(); //The roll
        int nTotal    = nRoll + nSkill; //Total roll
        int bSuccess = nTotal >= nDC;

        //Tell Player Die Roll
        if (bReport) {
                string sTotal = ColorString(IntToString(nTotal), TEXT_COLOR_GREY);
                string sRoll = ColorString(IntToString(nRoll), TEXT_COLOR_GREY);
        string sSkill = ColorString(IntToString(nSkill), TEXT_COLOR_GREY);
                string sFinal = "Panning Skill " + sSkill + " Roll : "+sRoll +" vs. DC " + IntToString(nDC) + " = "+sTotal;
                //FloatingTextStringOnCreature(sFinal, oPC, FALSE);
        }
        return bSuccess;
}

void ActionCreatePrize(string sRef, object oPC, int nStack = 1) {
        CreateItemOnObject(sRef, oPC, nStack);
}

string hfcGetPanningMessage() {
        switch (Random(10)) {
    case 0: return  "*You place the pan beneath the waters surface , sifting it to and fro*";
    case 1: return  "*You place the pan beneath the waters surface , sifting it to and fro*";
        }
        return "*You pan for gold*";
}

string hfcGetSuccessMsg(string sMsg) {

        string sRet = "I found " + sMsg + " !";
        return ColorString(sRet, TEXT_COLOR_RED);
}

void doPanning(object oPC, int bReport, int nDC) {

        int bSuccess = hfcDoPanningCheck(oPC, TRUE, nDC);


    // Nothing
        if (!bSuccess)  {
                string sNothing = "*You find nothing but silt*";
        AssignCommand(oPC, ActionSpeakString(sNothing));
                AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_TAUNT));
        return;
        }


    // At this point we're going to give the PC something even if he or she
    // cancels by moving away.
    string sMsg;
        string sRef;
    object oTrigger = GetLocalObject(oPC, "WATERTRIGGER");
    int nBonus = GetLocalInt(oTrigger, "PANNING_MOD");
    int nAnim = ANIMATION_FIREFORGET_VICTORY3;
    int nStack = 1;

    int nResult = d100() + nBonus; //ok, what did the PC get?
        if (nResult >= 100) {
        // Extra floating text
                string sGold = ColorString("*You found gold!", TEXT_COLOR_RED);
                FloatingTextStringOnCreature(sGold, oPC, FALSE);

        // Extra sound effects
                AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_CHEER));






        sMsg = "a grand gold nugget";
        sRef =  PANNING_GRAND_RES;
        nAnim = ANIMATION_FIREFORGET_VICTORY1;
        } else if (nResult >= 98) {
        sMsg = "a large gold nugget";
        sRef =  PANNING_HIGH_RES;
        nAnim = ANIMATION_FIREFORGET_VICTORY1;
        } else if (nResult >= 70) {
        sMsg = "a gold nugget";
        sRef =  PANNING_MED_RES;
        //nStack = d2();
    } else {
        sMsg = "a fleck of gold";
        sRef = PANNING_LOW_RES;
        //nStack = d3();
    }

    // Most of these are not actions.
    AssignCommand(oPC, SpeakString(hfcGetSuccessMsg(sMsg)));
        AssignCommand(oPC, ActionPlayAnimation(nAnim));
    AssignCommand(oPC, ActionCreatePrize(sRef, oPC, nStack));
}


void main() {

        int nEvent = GetUserDefinedItemEventNumber();
        if (nEvent != X2_ITEM_EVENT_ACTIVATE) return;

        object oPC          = GetItemActivator();
        object oItem        = GetItemActivated();
        string sItemTag     = GetTag(oItem);

        location lLoc       = GetLocation(oPC);
        string sWBody       = GetLocalString(oPC,"WATERBODY");//Set when entering and exiting Water Source Triggers
        int nWSource        = GetLocalInt(oPC,"WSOURCE");//Set when entering and exiting Water Source Triggers

    int bPanning        = FALSE;

    // This applies to all Streams
    if(FindSubString(sWBody, "Stream") != -1) {
        //if (sWBody == "Stream" || sWBody == "Slow Stream" || sWBody == "Fast Stream"
        //|| sWBody == "Forest Stream") {
        bPanning = TRUE;
    }

    //The Player DID NOT enter a Stream water trigger
        if (!nWSource && !bPanning) {
                SendMessageToPC(oPC,NOPANNINGHERE);
                return;
        }

    int nDC = GetLocalInt(GetLocalObject(oPC, "WATERTRIGGER"), "PANNING_DC");

    // Drive everything through the action queue so that if the PC moves away or is interrupted nothing else happens
    AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_LOOPING_TALK_PLEADING, 1.0, 2.0));
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW, 1.0, 8.0));
    AssignCommand(oPC, ActionWait(2.0));
    AssignCommand(oPC, ActionSpeakString(ColorString( hfcGetPanningMessage(), TEXT_COLOR_GREY)));
    AssignCommand(oPC, ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW, 1.0, 8.0));

    AssignCommand(oPC, ActionDoCommand(doPanning(oPC, TRUE, nDC)));

}
