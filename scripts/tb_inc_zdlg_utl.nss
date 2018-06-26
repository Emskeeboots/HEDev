//tb_inc_zdlg_utl.nss
// Utilities for zdlgs which don't require as many other includes.
#include "zdlg_include_i"
#include "tb_inc_string"
#include "_inc_data"
#include "tb_inc_util"
#include "00_debug"

const int ZDLG_ANIM_TALK  = ANIMATION_LOOPING_TALK_NORMAL;
const int ZDLG_ANIM_LAUGH = ANIMATION_LOOPING_TALK_LAUGHING;
const int ZDLG_ANIM_ANGRY = ANIMATION_LOOPING_TALK_FORCEFUL;
const int ZDLG_ANIM_PLEAD = ANIMATION_LOOPING_TALK_PLEADING;

const int ZDLG_ANIM_BOW    = ANIMATION_FIREFORGET_BOW;
const int ZDLG_ANIM_READ   = ANIMATION_FIREFORGET_READ;
const int ZDLG_ANIM_DRINK  = ANIMATION_FIREFORGET_DRINK;
const int ZDLG_ANIM_SALUTE = ANIMATION_FIREFORGET_SALUTE;
const int ZDLG_ANIM_GREET  = ANIMATION_FIREFORGET_GREETING;
const int ZDLG_ANIM_TAUNT  = ANIMATION_FIREFORGET_TAUNT;


void dlgPlayAnim(int nAnim, object oNPC = OBJECT_SELF, float nDur = 3.0){
        AssignCommand(oNPC, PlayAnimation(nAnim, 1.0, nDur));
}


// This is normally always set to false unless you want to enable debug for _all_ dialogs that use
// this file. Each dialog can enable debug for itself with dlgSetDebug called from the INIT handler.
int DLG_DEBUG = FALSE;
void dlgDebug(string sMsg, object oPC = OBJECT_INVALID) {
        if (DLG_DEBUG || GetLocalInt(OBJECT_SELF, "DLG_DEBUG")) {
                if (!GetIsObjectValid(oPC))
                        oPC = GetPcDlgSpeaker();
                dbstr(sMsg, oPC);
        }
}
void dlgSetDebug(int bDebug = TRUE) {
        if (bDebug)
            SetLocalInt(OBJECT_SELF, "DLG_DEBUG", TRUE);
        else
             DeleteLocalInt(OBJECT_SELF, "DLG_DEBUG");
}


object dlgGetStore(string sStore) {
        object oStore = GetNearestObjectByTag(sStore);

        dlgDebug("getstore got " + GetTag(oStore));
        if (GetIsObjectValid(oStore))
                return oStore;

        // not found yet - try globally
        oStore = GetObjectByTag(sStore);

        if (GetObjectType(oStore) ==  OBJECT_TYPE_STORE)
                return oStore;

        return OBJECT_INVALID;
}

int dlgHasStore(object oPC, object oNPC = OBJECT_SELF) {
        string sStore = GetLocalString(oNPC, "dlg_store");

        if (sStore == "")
                return FALSE;

        dlgDebug("Got Store " + sStore);
        if (GetIsObjectValid(dlgGetStore(sStore)))
                return TRUE;

        return FALSE;
}

int dlgHasOptStore(object oPC, object oNPC = OBJECT_SELF) {
        string sStore = GetLocalString(oNPC, "dlg_store1");

        if (sStore == "")
                return FALSE;

        if (GetIsObjectValid(dlgGetStore(sStore)))
                return TRUE;

        return FALSE;
}


string dlgGetStorePCText(object oPC, object oNPC = OBJECT_SELF) {
    string sString = GetLocalString(oNPC, "dlg_pc_store");

    if (sString == "") {
        switch (Random(4)) {
        case 0: sString = "I'd like to see your wares."; break;
        case 1: sString = "May I see what you have for sale?"; break;
        case 2: sString = "I'd like to trade."; break;
        case 3: sString = "Let's see what you have to trade."; break;
        }
    }
    return tbCookString(sString, oPC);
}

string dlgGetOptStorePCText(object oPC, object oNPC = OBJECT_SELF) {
    string sString = GetLocalString(oNPC, "dlg_pc_store1");

    if (sString == "") {
        switch (Random(4)) {
        case 0: sString = "I'd like to see the special items."; break;
        case 1: sString = "May I see the extra goods?"; break;
        case 2: sString = "Show me the good stuff.."; break;
        case 3: sString = "Let's see what special goods you have."; break;
        }
    }
    return tbCookString(sString, oPC);
}


int dlgOpenStore(object oPC, object oNPC = OBJECT_SELF, int bOpt = FALSE) {
        string sStore = GetLocalString(oNPC, "dlg_store");
        if (bOpt)
                sStore = GetLocalString(oNPC, "dlg_store1");

        SetLocalObject(oNPC, "PC_Speaker", oPC);
        SetLocalString(oNPC, "store_tag", sStore);

        ExecuteScript("tb_open_store", oNPC);

        DeleteLocalObject(oNPC, "PC_Speaker");
        DeleteLocalString(oNPC, "store_tag");
        return TRUE;
}

// Random selection of variations on leave me alone.
string dlgGetNoDlgOneliner(object oPC) {

        switch (Random(6)) {
                case 0: return "Buzz off.";
                case 1: return "Can't you see I'm busy.";
                case 2: return "Leave me alone.";
                case 3: return "Get lost or I'll call the guard.";
                case 4: return "Go bother someone else.";
                case 5: return "Piss off.";
        }
        return  "Piss off.";
}

string dlgGetNakedOneliner(object oPC, int nRepLevel, object oNPC = OBJECT_SELF) {
        int nNPCGend = GetGender(oNPC);
        int nPCGend = GetGender(oPC);

        if (nRepLevel && nRepLevel < 3 ) { // PRR_UNFAVORABLE) {
                switch(Random(3)) {
                        case 0: return "Get Lost <rake/whore>.";
                        case 1: return "Cover yourself <cad/harlot>.";
                        case 2:  if (nPCGend == GENDER_MALE) {
                                        if (nNPCGend == GENDER_FEMALE)
                                                return "Get away you Cad!";
                                        else
                                                return "Go away little man.";
                                } else {
                                        if (nNPCGend == GENDER_FEMALE)
                                                return "Get away you harlot!";
                                        else
                                                return "I've got just the thing for you, whore.";
                                }
                }
        } else if (!nRepLevel || nRepLevel < 6) { //PRR_FRIENDLY) {
                switch(Random(3)) {
                        case 0: return "Cover yourself <lad/lass>.";
                        case 1: return "You'd best find something to wear <man/woman>.";
                        case 2:  if (nPCGend == GENDER_MALE) {
                                        if (nNPCGend == GENDER_FEMALE)
                                                return "Please sir, put that away.";
                                        else
                                                return "Bit drafty isn't.";
                                } else {
                                        if (nNPCGend == GENDER_FEMALE)
                                                return "Please madam, put something on.";
                                        else
                                                return "Bit drafty isn't.";
                                }
                }

        } else {
                switch(Random(3)) {
                        case 0: return "Cover yourself my good <lad/lass>.";
                        case 1: return "You'd best find something to wear <sir/madam>.";
                        case 2:  if (nPCGend == GENDER_MALE) {
                                        if (nNPCGend == GENDER_FEMALE)
                                                return "Please sir, put that away.";
                                        else
                                                return "Bit drafty isn't.";
                                } else {
                                        if (nNPCGend == GENDER_FEMALE)
                                                return "Please madam, put something on.";
                                        else
                                                return "Bit drafty isn't.";
                                }
                }
        }
        return  "Cover yourself <lad/lass>.";
}

string dlgGetGoodBye(object oPC) {
    string sRet =  "Goodbye.";
    switch (Random(4)) {
    case 0: sRet = "Goodbye."; break;
    case 1: sRet = "Farewell."; break;
    case 2: sRet = "Nevermind."; break;
    case 3: sRet = "I take my leave."; break;
    }
    //return  sRet + tbEndString();
    return  sRet;
}

string getUnmetGreetingNoPrr(object oPC) {

    string sRet =  GetLocalString(OBJECT_SELF, "dlg_firstgreet");
    if (sRet == "") {
        sRet = "Greetings stranger.";
    } else if (sRet == "NOSTRING") {
            sRet = "";
    }

    string sDesc = GetLocalString(OBJECT_SELF, "dlg_description");
    if (sDesc != "") {
        //sRet = tbActionString(sDesc, oPC) + "\n" + tbCookString(sRet, oPC);
        sRet = tbActionString(sDesc, oPC) + " " + tbCookString(sRet, oPC);
    }
    if (sRet == "")
          return "";
    return tbCookString(sRet, oPC);
}

// This can be used to start a regular conversation file from a running zldg
void dlgStartConversation(object oPC, string sConv, object oNPC = OBJECT_SELF) {
        EndDlg();
         // Probably should Clear all actions here
        DelayCommand(0.1, AssignCommand(oNPC, ActionStartConversation(oPC, sConv, TRUE, FALSE)));
}

void dlgStartNewZdlg(string sDlg, object oPC, object oNPC = OBJECT_SELF) {
        SendMessageToPC(oPC, "starting new zdlg :" + sDlg);
       _SendDlgEvent(oPC, DLG_END );
       _CleanupDlg(oPC) ;
       SetCurrentDlgHandlerScript(sDlg);
       // This is not needed because this is only called from zdlg events which will be
       // triggering their own calls to initializepage already. Using this duplicates the call
       // which can lead to problems.
       //_InitializePage(oPC, oNPC);

}

void dlgReturnToMainDlg(object oPC, object oNPC = OBJECT_SELF) {
        string sDlg = GetLocalString(oNPC, "dialog");
        _SendDlgEvent(oPC, DLG_END );
        _CleanupDlg(oPC) ;
        SetCurrentDlgHandlerScript(sDlg);
        SetLocalInt(oPC, "dlg_do_page_main", TRUE);

}



// If the NPC has an override conversation file then start that
// return true if so.
int dlgDoOverrideConversation(object oPC, object oNPC = OBJECT_SELF) {
        string sConv = GetLocalString(oNPC, "dlg_override_conv");
        string sDlg = GetLocalString(oNPC, "dlg_override_dlg");

        if (sConv == "" && sDlg == "")
                return FALSE;

        if (GetPersistentInt(oPC, "dlg_done_over_" + GetTag(oNPC)))
                return FALSE;

        if (sDlg != "") {
                SetLocalString( oPC, DLG_CURRENT_HANDLER, sDlg );
                //StartDlg(oPC, oNPC, sDlg, FALSE, FALSE);
                AssignCommand( oNPC, ClearAllActions());
                AssignCommand( oNPC, ActionStartConversation( oPC, "zdlg_converse", FALSE, FALSE) );

                //dlgStartNewZdlg(sDlg,oPC);
                //_InitializePage(oPC, oNPC);
        } else {
                dlgStartConversation(oPC, sConv, oNPC);
        }

        return TRUE;
}


int hasSubDlg(object oPC, object oNPC = OBJECT_SELF, int nIdx = 0) {
    string sIdx = "";
    if (nIdx > 0)
        sIdx = IntToString(nIdx);
    string sSub = GetLocalString(oNPC, "dlg_subdlg" + sIdx);
    if (sSub  != "" && !GetPersistentInt(oPC, "dlg_subdlg" + sIdx + "_" + GetTag(oNPC)))
        return TRUE;

    return FALSE;
}

// This can be used as both a check and a getter of the PC string.
// It returns "" if there is no sub dialog.
string getPCSubDlg(object oPC, object oNPC = OBJECT_SELF, int nIdx = 0) {
    string sIdx = "";
    if (nIdx > 0)
        sIdx = IntToString(nIdx);
    string sSub = GetLocalString(oNPC, "dlg_subdlg" + sIdx);
    string sPCSub = GetLocalString(oNPC, "dlg_pc_subdlg" + sIdx);
    // nothing to show - caller should check for ""
    //dlgDebug("Got sub = '" + sSub + "' dlg_subdlg_" + GetTag(oNPC) + " =" +
    //IntToString(GetPersistentInt(oPC, "dlg_subdlg_" + GetTag(oNPC))));
    if (sSub  == "" || GetPersistentInt(oPC, "dlg_subdlg" + sIdx + "_" + GetTag(oNPC)))
        return "";

    if (sPCSub == "")
        return "Let's talk about something else.";

    return tbCookString(sPCSub, oPC);
}

void dlgStartSubDialog(object oPC,  object oNPC = OBJECT_SELF, int nIdx = 0) {
    string sIdx = "";
    if (nIdx > 0)
        sIdx = IntToString(nIdx);
    string sSub = GetLocalString(oNPC, "dlg_subdlg" + sIdx);
    if (sSub != "") {
        if (GetLocalInt(oNPC, "dlg_conv_subdlg" + sIdx)) {
            dlgStartConversation(oPC, sSub, oNPC);
        } else {
              dlgStartNewZdlg(sSub, oPC);
      }
    }
}

void dlgSetSubDlgDone(object oPC, object oNPC = OBJECT_SELF, int nIdx = 0) {
        string sIdx = "";
        if (nIdx > 0)
            sIdx = IntToString(nIdx);
    if (GetLocalInt(OBJECT_SELF, "dlg_once_subdlg" + sIdx)) {
        string sSub = GetLocalString(oNPC, "dlg_subdlg" + sIdx);
        if (sSub != "")
                SetPersistentInt(oPC, "dlg_subdlg"+ sIdx + "_" + GetTag(oNPC), 1);
    }
}
int dlgDoSeatedCheck(object oNPC) {
        int nCur = GetCurrentAction(oNPC);
        object oSeat = OBJECT_INVALID;
        if (nCur == ACTION_SIT) {
                if (GetLocalInt(oNPC, "npc_stays_seated")) {
                        oSeat = GetLocalObject(oNPC, "aww_current_chair");
                        if (!GetIsObjectValid(oSeat))
                                oSeat = GetLocalObject(oNPC, "current_seat");
                        if (!GetIsObjectValid(oSeat)) {
                                oSeat = GetNearestObjectByTag("Chair", oNPC);
                                if (GetSittingCreature(oSeat) != oNPC)
                                        oSeat = OBJECT_INVALID;

                                if (GetIsObjectValid(oSeat))
                                    SetLocalObject(oNPC, "current_seat", oSeat);
                        }
                }
                SendMessageToPC(GetFirstPC(), "NPC is seated, oSeat = " + GetName(oSeat));
        } else {
                SendMessageToPC(GetFirstPC(), "NPC is not seated - nothing to do");
        }

        return GetIsObjectValid(oSeat);

}

void dlgDoSeatedSpeaker(object oNPC, object oPC) {
        object oSeat = OBJECT_INVALID;
        if (GetLocalInt(oNPC, "npc_stays_seated")) {
               oSeat = GetLocalObject(oNPC, "aww_current_chair");
               if (!GetIsObjectValid(oSeat))
                      oSeat = GetLocalObject(oNPC, "current_seat");
               if (!GetIsObjectValid(oSeat)) {
                      SendMessageToPC(oPC, "NPC is not seated - nothing to do");
                      return;
               }
               SendMessageToPC(oPC, "NPC is seated, oSeat = " + GetName(oSeat));
               ClearAllActions();// keep NPC from spinning in chair
               ActionSit(oSeat);
        }
}


string getMultiPageString(object oPC, string sVar, int nPage = 0, object oHolder = OBJECT_SELF) {
    string sRet;

    if (nPage == 0) {
        sRet = GetLocalString(oHolder, sVar);
     } else {
        sRet = GetLocalString(oHolder, sVar + IntToString(nPage));
     }
    if (sRet == "")
            return "";
    return tbCookString(sRet,oPC);
}

int buildPageWithMore(object oPC, string sPage, string sVarBase, int nEnd = FALSE, object oHolder = OBJECT_SELF, string sDef = "") {

    int nCur = GetLocalInt(oPC, "dlg_page_curidx");
    string sPrompt;
    sPrompt = getMultiPageString(oPC, sVarBase, nCur, oHolder);

    if (sPrompt == "" && !nCur) {
        // These are defaults in case nothing is set.
        //if (sVarBase == "dlg_questdesc")
        //  sPrompt = "Sorry, I thought I had something for you.";
        //if (sVarBase == "dlg_selftalk")
        //sPrompt = dlgGetNoSelfTalk(oPC);
        //else if (GetStringLeft(sVarBase, 9) == "dlg_rumor")
        //sPrompt = dlgGetNoNews(oPC) ;
        if (sDef != "") sPrompt = sDef;
    }

    DeleteList(sPage, oPC);

    // This one should never happen
    if (sPrompt == "") {
        // we've found no more pages so clear this
        DeleteLocalInt(oPC, "dlg_page_curidx");
        return FALSE;
    }

    SetDlgPrompt(sPrompt);
    string sTmp;

    sTmp = getMultiPageString(oPC, sVarBase, nCur + 1);

    if (sTmp == "") {
        if (nEnd)
            AddStringElement(tbEndString(), sPage, oPC);
        else
            AddStringElement(tbContinueString(), sPage, oPC);
        DeleteLocalInt(oPC,"dlg_page_more");
    } else  {
        SetLocalInt(oPC,"dlg_page_more", 1);
        if (GetObjectType(OBJECT_SELF) != OBJECT_TYPE_CREATURE || Random(2))
            AddStringElement(tbContinueString(), sPage, oPC);
        else
            AddStringElement("Go on...", sPage, oPC);
    }
    SetLocalInt(oPC, "dlg_page_curidx", nCur + 1);
    SetDlgPageString(sPage);
    return TRUE;
}
