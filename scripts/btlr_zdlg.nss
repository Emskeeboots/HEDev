// btlr zdlg
// Body tailor dialog
// Used to allow players to customize selves.
//

#include "tb_inc_zdlg_utl"
#include "tb_inc_util"
#include "tb_btlr_inc"

/*
    This mirror allows you to tailor your appearance,
    allowing you to change heads, tattoos, and hair, skin, and tattoo color.
    You may alos use it to add a tail or wings.
    please choose from the following menu:
        <StartAction>[Change Appearance]</Start>
                 Modify which part
                    <StartAction>[Change Head]</Start> -> at_tailor001 : bt_PrepareBodyTailor(GetPCSpeaker(), CREATURE_PART_HEAD);
                        Select from the following menu:
                             <StartAction>Next part...</Start>  at_tailor002
                                                                        int nPart = GetLocalInt(oPC, "Body_Part_Modified");
                                                                        bt_IncrementBodyPart(oPC, nPart);
                                    loop to Select from the following menu:
                             <StartAction>Prev part...</Start>  at_tailor003 bt_DecrementBodyPart
                             <StartAction>Confirm Change</Start>  at_tailor004 :   DeleteLocalInt(GetPCSpeaker(), "Body_Part_Modified");
                                                                                   DeleteLocalInt(GetPCSpeaker(), "Body_Part_ID");

                             <StartAction>Abort...</Start>  - at_tailor005 :int nPart = GetLocalInt(oPC, "Body_Part_Modified");
                                                                            int nID   = GetLocalInt(oPC, "Body_Part_ID");

                                                                            if (nID != -1) {
                                                                               SetCreatureBodyPart(nPart, nID, oPC);
                                                                             }

                                                                             DeleteLocalInt(oPC, "Body_Part_Modified");
                                                                             DeleteLocalInt(oPC, "Body_Part_ID");

                                                                             AssignCommand(oPC, ClearAllActions());


                                                                             object oClothes = GetLocalObject(oPC, "CLOTHES_ON");
                                                                             AssignCommand(oPC, ActionEquipItem(oClothes, INVENTORY_SLOT_CHEST));


                    <StartAction>[Change Torso]</Start>
                    <StartAction>[Change Right Bicep]</Start>
                    ... No feet?
                        no pelvis

        <StartAction>[Change Color]</Start>
                 change which color?
                 <StartAction>[Hair Color]</Start>  -> at_tailor015: bt_PrepareColorTailor(GetPCSpeaker(), COLOR_CHANNEL_HAIR);
                      Select from the following menu:
                          <StartAction>[Next Color]</Start> - at_tailor019:  int nChannel = GetLocalInt(oPC, "Color_Channel_Modified");
                                                                             bt_IncrementColor(oPC, nChannel);
                          <StartAction>[Prev Color]</Start> - at_tailor020:  int nChannel = GetLocalInt(oPC, "Color_Channel_Modified");
                                                                             bt_DecrementColor(oPC, nChannel);

                          <StartAction>[Confirm Changes]</Start> - at_tailor021:  DeleteLocalInt(GetPCSpeaker(), "Color_Channel_Modified");
                                                                                  DeleteLocalInt(GetPCSpeaker(), "Color_ID");

                          Abort...   -> no action? This seems to be a bug...
                 <StartAction>[Skin Color]</Start>
                 <StartAction>[Tattoo1 Color]</Start>
                 <StartAction>[Tattoo2 Color]</Start>
        <StartAction>[Add Tail]</Start>
        <StartAction>[Add Wing]</Start>
        Abort...


 */

const string PAGEMAIN    = "btmain";
const string PAGEAPPEAR  = "btappear";
const string PAGEPART    = "btpart";
const string PAGECOLOR   = "btcolor";
const string PAGECHANNEL = "btchannel";
const string PAGECHAT    = "btchat";

// if set to TRUE PCs with > 1 XP cannot change heads.
const int BT_LIMIT_HEAD_CHANGE = FALSE;

// if set to TRUE allow PCs to change pelvis model
const int BT_ALLOW_PELVIS_CHANGE = TRUE;

// if set to TRUE allow PCs to change pelvis model
const int BT_LIMIT_SKIN_CHANGE = TRUE;


// Each page gets a buildPage routine. This is responsible for
// setting the DlgPrompt and setting the Page string to this page
// the reply list is build in the initpage routine.

void buildPageMain(object oPC) {
        int nIndex = 0;
        string sPage = PAGEMAIN;

        DeleteList(sPage, oPC);
        SetDlgPrompt("This mirror allows you to tailor your appearance, allowing you to change heads, tattoos, "
                + "and hair, skin, and tattoo color." + "Some things, like heads, can only be changed when you enter the world."
                + "Please choose from the following menu:");


        AddStringElement(tbActionString("Change Appearance", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement(tbActionString("Change Color", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);


        AddStringElement("All Done.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageAppearance(object oPC) {

        int nIndex = 0;
        string sPage = PAGEAPPEAR;

        DeleteList(sPage, oPC);
        SetDlgPrompt("Which body part would you like to change?");

        if ( !BT_LIMIT_HEAD_CHANGE || GetXP(oPC) < 2) {
                AddStringElement(tbActionString("Change Head", oPC), sPage, oPC);
                ReplaceIntElement(nIndex++, CREATURE_PART_HEAD, sPage, oPC);
        }

        AddStringElement(tbActionString("Change Torso", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_TORSO, sPage, oPC);

        AddStringElement(tbActionString("Change Right Bicep", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_RIGHT_BICEP, sPage, oPC);

        AddStringElement(tbActionString("Change Left Bicep",oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_LEFT_BICEP, sPage, oPC);

        AddStringElement(tbActionString("Change Right Forearm", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_RIGHT_FOREARM, sPage, oPC);

        AddStringElement(tbActionString("Change Left Forearm",oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_LEFT_FOREARM, sPage, oPC);

        AddStringElement(tbActionString("Change Right Thigh", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_RIGHT_THIGH, sPage, oPC);

        AddStringElement(tbActionString("Change Left Thigh",oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_LEFT_THIGH, sPage, oPC);

        AddStringElement(tbActionString("Change Right Shin", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_RIGHT_SHIN, sPage, oPC);

        AddStringElement(tbActionString("Change Left Shin",oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, CREATURE_PART_LEFT_SHIN, sPage, oPC);


        //AddStringElement(tbActionString("Change Right Foot", oPC), sPage, oPC);
        //ReplaceIntElement(nIndex++, CREATURE_PART_RIGHT_FOOT, sPage, oPC);

        //AddStringElement(tbActionString("Change Left Foot",oPC), sPage, oPC);
        //ReplaceIntElement(nIndex++, CREATURE_PART_LEFT_FOOT, sPage, oPC);

        //AddStringElement(tbActionString("Change Right Hand", oPC), sPage, oPC);
        //ReplaceIntElement(nIndex++, CREATURE_PART_RIGHT_HAND, sPage, oPC);

        //AddStringElement(tbActionString("Change Left Hand",oPC), sPage, oPC);
        //ReplaceIntElement(nIndex++, CREATURE_PART_LEFT_HAND, sPage, oPC);

        if (BT_ALLOW_PELVIS_CHANGE) {
                AddStringElement(tbActionString("Change Pelvis",oPC), sPage, oPC);
                ReplaceIntElement(nIndex++, CREATURE_PART_PELVIS, sPage, oPC);
        }

        AddStringElement("Nevermind.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);


}

void buildPagePart(object oPC) {

        int nIndex = 0;
        string sPage = PAGEPART;
        int nPart = GetLocalInt(oPC, "Body_Part_Modified");
        int nCur = GetCreatureBodyPart(nPart, oPC);
        SetDlgPrompt("You are currently at part " + IntToString(nCur) + ". What would you like to do?");


        DeleteList(sPage, oPC);
        AddStringElement(tbActionString("Next Part", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);


        AddStringElement(tbActionString("Prev Part", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        AddStringElement(tbActionString("Confirm Changes", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        AddStringElement(tbActionString("Abort", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageColor(object oPC) {

        int nIndex = 0;
        string sPage = PAGECOLOR;

        DeleteList(sPage, oPC);

        SetDlgPrompt("What would you like to do?");

        AddStringElement(tbActionString("Change Hair Color", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, COLOR_CHANNEL_HAIR, sPage, oPC);

        if (!BT_LIMIT_SKIN_CHANGE || GetXP(oPC) < 2) {
                AddStringElement(tbActionString("Change Skin Color", oPC), sPage, oPC);
                ReplaceIntElement(nIndex++, COLOR_CHANNEL_SKIN, sPage, oPC);
        }

        AddStringElement(tbActionString("Change Tattoo 1", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, COLOR_CHANNEL_TATTOO_1, sPage, oPC);

        AddStringElement(tbActionString("Change Tattoo 2", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, COLOR_CHANNEL_TATTOO_2, sPage, oPC);


        AddStringElement("Nevermind.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);

}

void buildPageChannel(object oPC) {

        int nIndex = 0;
        string sPage = PAGECHANNEL;

        DeleteList(sPage, oPC);

        int nChannel = GetLocalInt(oPC, "Color_Channel_Modified");
        int nID = GetColor(oPC, nChannel);
        SetDlgPrompt("You are currently at color " + IntToString(nID) + ". What would you like to do?");

        AddStringElement(tbActionString("Next Color", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);


        AddStringElement(tbActionString("Prev Color", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        AddStringElement(tbActionString("Enter a specific color (0-175)", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 4, sPage, oPC);

        AddStringElement(tbActionString("Confirm Changes", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        AddStringElement(tbActionString("Abort", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);


}

void buildPageChat(object oPC) {
        int nIndex = 0;
        string sPage = PAGECHAT;

        DeleteList(sPage, oPC);
        SetDlgPrompt("Speak the number you want to use in the chat bar. Cancel or Done when finished.");


        AddStringElement("Done.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Cancel.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

/// Page selection handlers
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

    // Appearances
    if (nChoice == 1) {
        buildPageAppearance(oPC);
        return;
    }

    // Color
    if (nChoice == 2) {
        buildPageColor(oPC);
        return;
    }


    EndDlg();
}

void handlePageAppear(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGEAPPEAR, oPC);
    dlgDebug("Page appear nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        EndDlg();
        return;
    }

    bt_PrepareBodyTailor(oPC, nChoice);
    buildPagePart(oPC);

}

void handlePagePart(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGEPART, oPC);
    dlgDebug("Page part nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        bt_ResetBodyTailor(oPC);
        buildPageMain(oPC);
        return;
    }
    if (nChoice == 1) {
        bt_IncrementBodyPart(oPC, GetLocalInt(oPC, "Body_Part_Modified"));
        buildPagePart(oPC);
        return;
    }
    if (nChoice == 2) {
        bt_DecrementBodyPart(oPC, GetLocalInt(oPC, "Body_Part_Modified"));
        buildPagePart(oPC);
        return;
    }
    // Confirm changes
    if (nChoice == 3) {
        bt_ResetBodyTailor(oPC, TRUE);
        buildPageMain(oPC);
        return;
    }
}

void handlePageColor(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGECOLOR, oPC);
    dlgDebug("Page color nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        EndDlg();
        return;
    }

    bt_PrepareColorTailor(oPC, nChoice);
    buildPageChannel(oPC);

}

void handlePageChannel(object oPC, int nSel) {
    int nChoice = GetIntElement(nSel, PAGECHANNEL, oPC);
    dlgDebug("Page Channel nChoice = " + IntToString(nChoice));

    if (nChoice == -1) {
        bt_ResetColorTailor(oPC);
        buildPageMain(oPC);
        return;
    }
    if (nChoice == 1) {
        bt_IncrementColor(oPC, GetLocalInt(oPC, "Color_Channel_Modified"));
        buildPageChannel(oPC);
        return;
    }
    if (nChoice == 2) {
        bt_DecrementColor(oPC, GetLocalInt(oPC, "Color_Channel_Modified"));
        buildPageChannel(oPC);
        return;
    }
 // enter numerical value
        if (nChoice == 4) {
                tlrStartChat(oPC, OBJECT_SELF);
                buildPageChat(oPC);
                return;
        }


    // Confirm changes
    if (nChoice == 3) {
        bt_ResetColorTailor(oPC, TRUE);
        buildPageMain(oPC);
        return;
    }
}

void handlePageChat(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGECHAT, oPC);
        dlgDebug("Page Chat nChoice = " + IntToString(nChoice));

        int nVal = tlrStopChat(oPC);

        if (nChoice == -1 || nVal == -1) {
                buildPageChannel(oPC);
                return;
        }

        if (nChoice == 1) {
                bt_SetColor(oPC, GetLocalInt(oPC, "Color_Channel_Modified"), nVal);
                buildPageChannel(oPC);
        }
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
        DeleteLocalInt(oPC, "Body_Part_Modified");
        DeleteLocalInt(oPC, "Body_Part_ID");
        DeleteLocalInt(oPC, "Color_Channel_Modified");
        DeleteLocalInt(oPC, "Color_ID");
}

void PageInit() {
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("PAGEINIT: page = " + page);

    // These are special cases
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
    DeleteList(PAGEMAIN, oPC);
    DeleteList(PAGEAPPEAR, oPC);
    DeleteList(PAGEPART, oPC);
    DeleteList(PAGECOLOR, oPC);
    DeleteList(PAGECHANNEL, oPC);


    // clean up and abort anyu changes.
    bt_ResetBodyTailor(oPC);
    bt_ResetColorTailor(oPC);
	dlgSetDebug(FALSE);
}

void HandleSelection() {
    int nSel = GetDlgSelection();
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("HANDLE : Got page = " + page + " nsel = " + IntToString(nSel));
    if (page == "") page =  PAGEMAIN;

    if(page == PAGEMAIN) {
        handlePageMain(oPC, nSel);
        return;
    }

     if(page == PAGEAPPEAR) {
        handlePageAppear(oPC, nSel);
        return;
    }

    if(page == PAGEPART) {
        handlePagePart(oPC, nSel);
        return;
    }
    if(page == PAGECOLOR) {
        handlePageColor(oPC, nSel);
        return;
    }
    if(page == PAGECHANNEL) {
        handlePageChannel(oPC, nSel);
        return;
    }
     if(page == PAGECHAT) {
        handlePageChat(oPC, nSel);
        return;
    }
    // handle any pages with 1 or 2 responses (return to main or endDlg)
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
