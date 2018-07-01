// tb_deitylst_zdlg
// Deity listing and chooser dialogue for testing and setting deities for PCs.
//

#include "tb_inc_zdlg_utl"
#include "tb_inc_deity"
#include "deityconv_inc"
#include "_inc_nwnx"

/*

   greet -
     Would you like to learn about the deities of <WORLD>?

     yes
     could I see the list of those who find me acceptable
     no thanks


     yes:
           build deity page for current deity

             <next>
         <prev>
         I'd like to follow <deity>
         I'd like to serve <deity>
         goodbye

     could I:
            Walk deities and produce a list
        If list empty  "No deity finds you acceptable"
        else "Here are the deities who you could follow"

              deity1
          deity2
          ...
          nevermid.

 */


int dlgGetSuitableDeity(object oPC, int nStart, int nReverse = FALSE, int bFirst = FALSE) {

    int nDeity = nStart;

    if (nDeity < 0) nDeity = 0;
    if (nDeity >=  GetDeityCount()) nDeity = 0;

    // If we want the first then check it and if not okay, advance to next.
    // direction does not matter here.
    if (bFirst) {
        if (DeityCheckCanServe(oPC, nDeity))
            return nDeity;
        nDeity ++;
        if (nDeity == GetDeityCount())
            nDeity = 0;
    } else {
         if (nReverse) {
            nDeity --;
            if (nDeity < 0)
                nDeity = GetDeityCount() - 1;
        } else {
            nDeity ++;
            if (nDeity == GetDeityCount())
                nDeity = 0;
        }
    }

    dlgDebug("GetsuitableDeity - start = " + IntToString(nStart));
    while (!DeityCheckCanServe(oPC, nDeity) && nDeity != nStart) {

        if (nReverse) {
            nDeity --;
            if (nDeity < 0)
                nDeity = GetDeityCount() - 1;
        } else {
            nDeity ++;
            if (nDeity == GetDeityCount())
                nDeity = 0;
        }
    }
    if (DeityCheckCanServe(oPC, nDeity))
        return nDeity;

    return -1;
}

const string PAGEGREET    = "listgreet";
const string PAGEMAIN     = "listmain";
const string PAGEFOLLOW   = "listfollow";
const string PAGELIST     = "listlist";
const string PAGENODEITY  = "listnodeity";
const string PAGEINFO     = "listinfo";
const string PAGECHANGEDOM = "listchdom";
const string PAGEDOMLIST  = "listdomlist";


// Each page gets a buildPage routine. This is responsible for
// setting the DlgPrompt and setting the Page string to this page
// the reply list is build in the initpage routine.

void buildPageMain(object oPC, string sPage) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    //string sPage = PAGEMAIN;
    DeleteList(sPage, oPC);

    dlgDebug("BuildPage " + sPage + " - nDeity = " + IntToString(nDeity));
    SetupDeityConversationTokens(nDeity, TRUE);
    string sPrompt = dlgGetDeityInfo(OBJECT_SELF);
    SetDlgPrompt(sPrompt);

    string sDeity =   GetDeityName(nDeity);

    AddStringElement(tbActionString("Next", oPC), sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement(tbActionString("Prev", oPC), sPage, oPC);
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

    if (deityIsCleric(oPC))
        AddStringElement("I wish to serve " + sDeity + ".", sPage, oPC);
    else
        AddStringElement("I wish to follow " + sDeity + ".", sPage, oPC);
    ReplaceIntElement(nIndex++, 3, sPage, oPC);

    // "I wish to serve" may not be needed, we really just need to get PCs deity set
    //- but how do you handle the cases where a cleric is doing this and
    // does not have any valid combination of domains?

    AddStringElement("Return.", sPage, oPC);
    ReplaceIntElement(nIndex++, -1, sPage, oPC);
    SetDlgPageString(sPage);
}

void buildPageGreet(object oPC) {
        int nIndex = 0;
    //int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
        string sPage = PAGEGREET;
        DeleteList(sPage, oPC);

        int nDeity = GetDeityIndex(oPC);
        string sName = "an unknown Deity";
        if (nDeity >= 0) sName =  GetDeityName(nDeity);
        string sVerb = "follower";
        if (deityIsCleric(oPC)) sVerb = "servant";

        SetDlgPrompt("Welcome " + sVerb + " of " + sName + "! Would you like to learn of the dieties of " + WORLDNAME + "?");

        AddStringElement("Yes, show me the whole list.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        if (deityIsCleric(oPC)) {
                AddStringElement("List only those deities I could serve as a cleric, druid, paladin or ranger, please.", sPage, oPC);
        } else {
                AddStringElement("Show only those deities I could follow as I am, please.", sPage, oPC);
        }
        ReplaceIntElement(nIndex++, 2, sPage, oPC);


        if (GetHaveNWNX() && GetLevelByClass(CLASS_TYPE_CLERIC, oPC)) {
                AddStringElement("I'd like to modify my domains.", sPage, oPC);
                ReplaceIntElement(nIndex++, 3, sPage, oPC);
        }
        AddStringElement("Tell me about how this works.", sPage, oPC);
        ReplaceIntElement(nIndex++, 4, sPage, oPC);

        AddStringElement("All Done.", sPage, oPC); // dlgGetGoodBye ?
        ReplaceIntElement(nIndex++, -1, sPage, oPC);

    // needed in the first page only
    SetDlgResponseList(sPage, oPC);
    SetDlgPageString(sPage);
}


// We only get here if NWNX is supported
void buildPageChangeDomain(object oPC) {
    int nIndex = 0;
    string sPage = PAGECHANGEDOM;
    DeleteList(sPage, oPC);

    string sPrompt = "Which of your domains would you like to change?";
    SetDlgPrompt(sPrompt);

    int nDom = nwnxGetClericDomain(oPC, 1);
    AddStringElement("First domain [" + DomainToString(nDom) + "].", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    nDom = nwnxGetClericDomain(oPC, 2);
    AddStringElement("Second domain [" + DomainToString(nDom) + "].", sPage, oPC);
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

    AddStringElement("All done.", sPage, oPC); // dlgGetGoodBye ?
    ReplaceIntElement(nIndex++, -1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageDomList(object oPC) {
        int nIndex = 0;
        string sPage = PAGEDOMLIST;
        DeleteList(sPage, oPC);

        string sNum = "first";
        if (GetLocalInt(oPC, "deity_tmp_dom_index") == 2)
                sNum = "second";

        string sPrompt = "Select your " + sNum + " domain:";
        SetDlgPrompt(sPrompt);

        int i;
        // domains.2da 
        for (i = 0; i < 23 ; i ++) {
                int nFeat = StringToInt(Get2DAString("domains", "GrantedFeat", i));
                if (!GetHasFeat(nFeat, oPC)) {
                        AddStringElement(DomainFeatToString(nFeat), sPage, oPC);
                        ReplaceIntElement(nIndex++, i, sPage, oPC);
                }
        }
        /*
        for (i = FEAT_WAR_DOMAIN_POWER ; i <= FEAT_WATER_DOMAIN_POWER ; i++) {
                if (!GetHasFeat(i, oPC)) {
                        AddStringElement(DomainFeatToString(i), sPage, oPC);
                        ReplaceIntElement(nIndex++, i, sPage, oPC);
                }
        }
        for (i = 1998; i < 2000; i++){
                if (!GetHasFeat(i, oPC)) {
                        AddStringElement(DomainFeatToString(i), sPage, oPC);
                        ReplaceIntElement(nIndex++, i, sPage, oPC);
                }
        }
*/
        AddStringElement("return.", sPage, oPC); // dlgGetGoodBye ?
        ReplaceIntElement(nIndex++, -1, sPage, oPC);

        SetDlgPageString(sPage);
}

void buildPageNoDeity(object oPC) {
    int nIndex = 0;
    string sPage = PAGENODEITY;
    DeleteList(sPage, oPC);

    string sPrompt = "I'm afraid none of the deities of " + WORLDNAME + " will accept you as you are. ";
    if (GetHaveNWNX() && GetLevelByClass(CLASS_TYPE_CLERIC, oPC))
        sPrompt += "You may want to change your domains and check again. Use the full list to help find a suitable selection. ";

    sPrompt +=   "Would you like to see the complete list?";
    SetDlgPrompt(sPrompt);

    AddStringElement("Yes.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement("No.", sPage, oPC); // dlgGetGoodBye ?
    ReplaceIntElement(nIndex++, -1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageInfo(object oPC) {
    int nIndex = 0;
    string sPage = PAGEINFO;
    DeleteList(sPage, oPC);

    string sPrompt = "In " + WORLDNAME + " you may follow no god or one of those listed here. If you are a Cleric, Druid, Paladin or Ranger you must serve one of the Deities.";
    sPrompt += " You can only serve deities who match alignment, race, gender and, if a Cleric, allowed domains. Followers can generally choose any deity. Choosing a deity "
    + " with similar alignment is a good idea. With continual prayer followers will shift towards the deity's alignment.";
    if (GetHaveNWNX())
        sPrompt += " As a cleric you may use this conversation to modify your chosen domains to match the deity you wish to serve. ";
    sPrompt += " Divine spell casters must be in favor with their dieties to cast spells. "
    + "Praying, at appropriate altars, along with maintaining a suitable alignment, will help keep you in favor with your deity. "
    + " Praying to your deity during combat may provide benefits if you are in need and in high favor. Any class may pray and maintain favor. "
    + " Clerics, Paladins, Druids and to a lesser extent Rangers must pray (or commune with nature).";

    SetDlgPrompt(sPrompt);

    AddStringElement("return.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);


    AddStringElement("Goodbye.", sPage, oPC); // dlgGetGoodBye ?
    ReplaceIntElement(nIndex++, -1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageFollow(object oPC) {
        int nIndex = 0;
        int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
        string sPrompt = "";
        string sResp = "";
        string sDeity =  GetDeityName(nDeity);

        string sPage = PAGEFOLLOW;
        DeleteList(sPage, oPC);

        if (deityIsCleric(oPC)) {
                if (DeityCheckCanServe(oPC, nDeity)) {
                        deitySetDeity(oPC, sDeity);
                        sPrompt = "Very well Let it be known that you serve " + sDeity + ". " + deityGetBlessingStr(nDeity);
                        sResp = "Thank you.";
                } else {
                        sPrompt = "You may not serve as a cleric, druid or paladin of " + sDeity + ".";
                        sResp = "I see";
                }
        } else {
                if (DeityCheckCanFollow(oPC, nDeity)) {
                        deitySetDeity(oPC, sDeity);
                        sPrompt = "Very well Let it be known that you follow " + sDeity + ". " + deityGetBlessingStr(nDeity);
                        sResp = "Thank you. I'd like to keep looking.";
                        AddStringElement("Thank you. Good bye.", sPage, oPC);
                        ReplaceIntElement(nIndex++, 2, sPage, oPC);
                } else {
                        sPrompt = "I'm sorry, " +  sDeity + " will not accept you as a follower at this time.";
                        sResp = "I see.";
                }
        }

        SetDlgPrompt(sPrompt);
        AddStringElement(sResp, sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

    //SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);
}


/// Page selection handlers
// Each page gets a handlePage routine which decides what to do
// it is responsible for calling buildPage of the page which should be shown next
// or ending the dlg.
void handlePageGreet(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGEGREET, oPC);
    dlgDebug("page greet" + " nCoice = "+ IntToString(nChoice));

    if(nChoice == 1) {
        buildPageMain(oPC, PAGEMAIN);
        return;
    }

    if(nChoice == 2) {
        // first must advance the index to be at the first acceptible deity
        int nDeity =  dlgGetSuitableDeity(oPC, GetLocalInt(OBJECT_SELF, "dlg_deity_idx"), FALSE, TRUE);
        if (nDeity < 0) {
        // turn off the domain check and try again...
                if (!GetHaveNWNX()) {
                        SetLocalInt(oPC, "deity_no_domaincheck", 1);
                        dlgDebug("No matches - setting no_domaincheck");
                        nDeity =  dlgGetSuitableDeity(oPC, GetLocalInt(OBJECT_SELF, "dlg_deity_idx"), FALSE, TRUE);
                }
                if (nDeity < 0) {
                        buildPageNoDeity(oPC);
                        return;
                }
        }
        SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);
        buildPageMain(oPC, PAGELIST);
        return;
    }
    if(nChoice == 3) {
        buildPageChangeDomain(oPC);
        return;
    }
    if(nChoice == 4) {
        buildPageInfo(oPC);
        return;
    }

    EndDlg();
}


// This is for page main when listing all deities
void handlePageMain(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGEMAIN, oPC);
    dlgDebug("Page main nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        buildPageGreet(oPC);
        return;
    }

    // next deity
    if (nChoice == 1) {
        int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
        nDeity ++;
        if (nDeity == GetDeityCount())
            nDeity = 0;
        SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);

        buildPageMain(oPC, PAGEMAIN);
        return;
    }

    // previous
    if (nChoice == 2) {
        int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
        nDeity --;
        if (nDeity < 0)
            nDeity = GetDeityCount() - 1;
        SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);

        buildPageMain(oPC, PAGEMAIN);
        return;

    }

    // I wish to follow
    if (nChoice == 3) {
        buildPageFollow(oPC);
        return;
    }

    EndDlg();
}


// This is for listing only those whom PC may follow/serve
void handlePageList(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGELIST, oPC);
    dlgDebug("Page list nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        buildPageGreet(oPC);
        return;
    }

    // next deity
    if (nChoice == 1) {
        int nDeity = dlgGetSuitableDeity(oPC, GetLocalInt(OBJECT_SELF, "dlg_deity_idx") + 1);

        // Check for -1 here, should not happen though...
        if (nDeity < 0) {
            buildPageNoDeity(oPC);
            return;
        }
        SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);

        buildPageMain(oPC, PAGELIST);
        return;
    }

    // previous
    if (nChoice == 2) {
        int nDeity = dlgGetSuitableDeity(oPC, GetLocalInt(OBJECT_SELF, "dlg_deity_idx") - 1, TRUE);

        // Check for -1 here, should not happen though...
        if (nDeity < 0) {
            buildPageNoDeity(oPC);
            return;
        }
        SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);

        buildPageMain(oPC, PAGELIST);
        return;

    }

    // I wish to follow
    if (nChoice == 3) {
        buildPageFollow(oPC);
        return;
    }

    EndDlg();
}

void handlePageChangeDom(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGECHANGEDOM, oPC);
    dlgDebug("page " + PAGECHANGEDOM + " nCoice = "+ IntToString(nChoice));

    if(nChoice == 1 || nChoice == 2) {
        SetLocalInt(oPC, "deity_tmp_dom_index", nChoice);
            buildPageDomList(oPC);
            return;
    }

    buildPageGreet(oPC);
}

void handlePageDomList(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGEDOMLIST, oPC);
    dlgDebug("page " + PAGEDOMLIST + " nCoice = "+ IntToString(nChoice));


    if (nChoice == -1) {
       buildPageChangeDomain(oPC);
       return;
    }

    int nNum = GetLocalInt(oPC, "deity_tmp_dom_index");
    //if ((nChoice > 305 && nChoice < 325) || nChoice == 1998 || nChoice == 1999) {
    nwnxSetClericDomain(oPC, nNum , nChoice);
    //}

    buildPageChangeDomain(oPC);
}

void handlePageNoDeity(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGENODEITY, oPC);
    dlgDebug("page " + PAGENODEITY + " nCoice = "+ IntToString(nChoice));

    if(nChoice == 1) {
            buildPageMain(oPC, PAGEMAIN);
        return;
    }

    buildPageGreet(oPC);
}

// Generic handler for exit or return to page main. Pages using this should
// make sure choice 1 is the return to main. Any other choice exits.
// Often this can be used as the catch all in the main HandleSelection() routine
void handleReturnToMain(object oPC, int nSel, string sPage) {

    int nChoice = GetIntElement(nSel, sPage, oPC);
    dlgDebug("page " + sPage + " nCoice = "+ IntToString(nChoice));

    if(nChoice == 1) {
        buildPageGreet(oPC);
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
    int nDeity = GetDeityIndex(OBJECT_SELF);
    if (nDeity < 0) nDeity = 0;
    SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);
    dlgDebug("INIT -setting nDeity to " + IntToString(nDeity));
}

void PageInit() {
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("PAGEINIT: page = " + page);

    // These are special cases
    if(page == "" || page == PAGEGREET) {
        buildPageGreet(oPC);
        return;
    }

    // All other pages just set the responselist - page has already been built
    // in the selection handler path
    SetDlgResponseList(page,oPC);

}

void Clean() {
    object oPC = GetPcDlgSpeaker();
    DeleteList(PAGEGREET, oPC);
    DeleteList(PAGEMAIN, oPC);
    DeleteList(PAGEFOLLOW, oPC);
    DeleteList(PAGELIST, oPC);
    DeleteList(PAGENODEITY, oPC);


    // delete any variables
    DeleteLocalInt(OBJECT_SELF, "dlg_deity_idx");
    DeleteLocalInt(oPC, "deity_tmp_dom_index");

    ClearDeityConversationVariables();
    dlgSetDebug(FALSE);
}

void HandleSelection() {
    int nSel = GetDlgSelection();
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("HANDLE : Got page = " + page + " nsel = " + IntToString(nSel));
    if (page == "") page = PAGEGREET;

    if(page == PAGEGREET) {
        handlePageGreet(oPC, nSel);
        return;
    }

    if(page == PAGEMAIN) {
        handlePageMain(oPC, nSel);
        return;
    }
    if(page == PAGELIST) {
        handlePageList(oPC, nSel);
        return;
    }
    if(page == PAGENODEITY) {
        handlePageNoDeity(oPC, nSel);
        return;
    }

     if(page == PAGECHANGEDOM) {
            handlePageChangeDom(oPC, nSel);
            return;
    }
     if(page == PAGEDOMLIST) {
            handlePageDomList(oPC, nSel);
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
