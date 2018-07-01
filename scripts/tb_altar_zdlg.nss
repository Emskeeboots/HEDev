// tb_altar_zdlg
// Generic variable driven altar conversation allowing the PC to pray at the altar
//

#include "tb_inc_zdlg_utl"
#include "tb_inc_deity"
#include "deityconv_inc"

/*
    Altar must have deity_name variable defined.

    Basic general conversation driven by variables on the altar

    description and title

    [Large stone altar]  This is a/an [shrine/altar] to <deityname> god/goddess/deity of foobar...

    1You are not a follower of <deityname>
    2You are a follower of <deityname>
    3you are a cleric of <deityname>

    A) if not follower/cleric - desicrate altar/shrine

            TBD - bad effect of some kind.

    B) pray at the altar/shrine

         if not follower/cleric  make very minor alignment shift towards altar's deity.

           end.

     else adjust favor up and if in good standing provide effect.

               give some feed back - if out of favor - Deity does not seem to hear your prayers.
           else you feel a sense of calm.

    c) leave
          end.

*/


const string PAGEMAIN     = "altarmain";
const string PAGEPRAY     = "altarrpray";
const string PAGEDESEC    = "altardesec";
const string PAGEHOLYSYM  = "altarholysym";


// Each page gets a buildPage routine. This is responsible for
// setting the DlgPrompt and setting the Page string to this page
// the reply list is build in the initpage routine.

void buildPageMain(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPage = PAGEMAIN;

    DeleteList(sPage, oPC);
/*
 [Large stone altar]  This is a/an [shrine/altar] to <deityname> god/goddess/deity of foobar...

    1You are not a follower of <deityname>
    2You are a follower of <deityname>
    3you are a cleric of <deityname>
*/
    string sDesc = GetLocalString(OBJECT_SELF, "dlg_description");
    int nStanding = deityGetStanding(nDeity, oPC);
    string sTemp =  dlgGetAltarName(nDeity, OBJECT_SELF);
    string sDeity = GetDeityName(nDeity);

    if (sDesc != "")
        sDesc = tbActionString(sDesc, oPC) + " ";

    string sStat = "You are not a follower of " +  sDeity + ".";
    if (nStanding ==  DEITY_STANDING_CLERIC_OK || nStanding ==  DEITY_STANDING_CLERIC_HIGH )
        sStat = "You serve " +  sDeity + " faithfully.";
    else if (nStanding == DEITY_STANDING_CLERIC_LAPSED)
        sStat = "You serve " +  sDeity + " but are out of favor.";
    if (nStanding ==  DEITY_STANDING_FOLLOWER_OK || nStanding ==  DEITY_STANDING_FOLLOWER_HIGH)
        sStat = "You follow " +  sDeity + " faithfully.";
    else if (nStanding == DEITY_STANDING_FOLLOWER_LAPSED)
        sStat = "You are a lapsed follower of " +  sDeity + ".";

    SetDlgPrompt(sDesc + dlgGetAltarMessage(nDeity, OBJECT_SELF) + " " + sStat);

    if (nStanding == DEITY_STANDING_OTHER && !GetLocalInt(oPC, "_dlg_did_desecrate")) {
        AddStringElement(tbActionString("Desecrate the " + sTemp + ".", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);
    }

    if (!GetLocalInt(oPC, "_dlg_did_pray")) {
        AddStringElement(tbActionString("Pray at the " + sTemp + ".",oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);
    }

    // holysymbol
    if (!GetLocalInt(oPC, "dlg_did_holysym") && dlgDeityNeedsHolySymbol(oPC, nDeity, OBJECT_SELF)){
        AddStringElement(tbActionString("Consecrate a new holy symbol.", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);
    }

    AddStringElement(tbActionString("Leave", oPC), sPage, oPC);
    ReplaceIntElement(nIndex++, -1, sPage, oPC);
    // This is only needed on the first page
    SetDlgResponseList(sPage, oPC);
    SetDlgPageString(sPage);
}

void buildPagePray(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPage = PAGEPRAY;
    string sTemp =  dlgGetAltarName(nDeity, OBJECT_SELF);
    string sDeity = GetDeityName(nDeity);

    DeleteList(sPage, oPC);
    SetLocalInt(oPC, "_dlg_did_pray",1);

    string sPrompt;

    deityAnimatePrayer(nDeity, oPC);
    int nRes = deityDoPrayer(nDeity, oPC, TRUE);

    int nStanding = deityGetStanding(nDeity, oPC);
    switch (nStanding) {
    case DEITY_STANDING_FOLLOWER_LAPSED:
    case DEITY_STANDING_CLERIC_LAPSED:
        sPrompt = "You pray at the " + sTemp + " but feel that " + sDeity + " was deaf to you.";
        break;

    case DEITY_STANDING_FOLLOWER_HIGH:
    case DEITY_STANDING_CLERIC_HIGH: 
    case DEITY_STANDING_FOLLOWER_OK:
    case DEITY_STANDING_CLERIC_OK:
        if (nRes)
            sPrompt = "You pray at the " + sTemp + " and feel that " + sDeity + " is pleased with you.";
        else
            sPrompt = "You pray at the " + sTemp + " but feel that " + sDeity + " may have heard you.";
        break;

    case DEITY_STANDING_OTHER:
    default:
        sPrompt = "You pray at the " + sTemp + ".";
        break;
    }

    SetDlgPrompt(sPrompt);
    AddStringElement(tbContinueString(), sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageDesecrate(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";

    string sPage = PAGEDESEC;
    DeleteList(sPage, oPC);

    SetDlgPrompt("You decide that it might be unwise to draw the attention of deities...");
    AddStringElement(tbContinueString(), sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageHolySymbol(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGEHOLYSYM;
    DeleteList(sPage, oPC);

    // give the holy symbol
    GiveHolySymbol(oPC);
    SetLocalInt(oPC, "dlg_did_holysym", 1);

    SetDlgPrompt("You fashion and consecrate a suitable holy symbol for " + GetDeityName(nDeity) + ".");
    AddStringElement(tbContinueString(), sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

////////////// Page selection handlers
// Each page gets a handlePage routine which decides what to do
// it is responsible for calling buildPage of the page which should be shown next
// or ending the dlg.

void handlePageMain(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGEMAIN, oPC);
    dlgDebug("Page main nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        EndDlg();
    return;
    }

    // desecrate altar
    if (nChoice == 1) {
        buildPageDesecrate(oPC);
        return;
    }

    // pray at altar
    if (nChoice == 2) {
        buildPagePray(oPC);
        return;
    }

    // make a holy symbol
    if (nChoice == 3) {
        buildPageHolySymbol(oPC);
        return;
    }

    EndDlg();
}

// Generic handler for exit or return to page main. Pages using this should
// make sure choice 1 is the return to main. Any other choice exits.
// Often this can be used as the catch all in the main HandleSelection() routine
void handleReturnToMain(object oPC, int nSel, string sPage) {

    int nChoice = GetIntElement(nSel, sPage, oPC);
    dlgDebug("page " + sPage + " nCoice = "+ IntToString(nChoice));

    if(nChoice == 1) {
        buildPageMain(oPC);
        return;
    }

    EndDlg();
}

////////////////////////////////////////////////////
// These are mostly boilerplate routines for the events from zdlg
//
// Init routine defined for zdlg event Init
void Init() {
    object oPC = GetPcDlgSpeaker();

    //dlgSetDebug();
    string sDeity = GetLocalString(OBJECT_SELF, "deity_name");
    int nDeity = GetDeityIndexFromName(sDeity);
    SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);
    DeleteLocalInt(oPC, "_dlg_did_pray");
    DeleteLocalInt(oPC, "_dlg_did_desecrate");

    if (nDeity < 0)
        dlgDebug("Invalid Deity on " + GetTag(OBJECT_SELF));

    SetupDeityConversationTokens(nDeity, TRUE);
}

void PageInit() {
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("PAGEINIT: page = " + page);

    // The first page is a special case
    if(page == "" || page == PAGEMAIN) {
        buildPageMain(oPC);
        return;
    }

    // All other pages just set the responselist - page has already been built
    // in the selection handler path
    SetDlgResponseList(page,oPC);

}

void Clean() {
    object oPC = GetPcDlgSpeaker();
    DeleteList(PAGEPRAY, oPC);
    DeleteList(PAGEMAIN, oPC);
    DeleteList(PAGEDESEC, oPC);

    // delete any variables
    DeleteLocalInt(OBJECT_SELF, "dlg_deity_idx");
    DeleteLocalInt(oPC, "_dlg_did_pray");
    DeleteLocalInt(oPC, "_dlg_did_desecrate");

    ClearDeityConversationVariables();
	dlgSetDebug(FALSE);
}

void HandleSelection() {
    int nSel = GetDlgSelection();
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("HANDLE : Got page = " + page + " nsel = " + IntToString(nSel));
    if (page == "") page = PAGEMAIN;

    if(page == PAGEMAIN) {
        handlePageMain(oPC, nSel);
        return;
    }
    handleReturnToMain(oPC, nSel, page);
    return;


}

void main() {
    switch(GetDlgEventType()) {
    case DLG_INIT: Init(); break;
    case DLG_PAGE_INIT: PageInit(); break;
    case DLG_SELECTION: HandleSelection(); break;
    case DLG_ABORT: Clean(); break;
    case DLG_END: Clean(); break;
    }
}
