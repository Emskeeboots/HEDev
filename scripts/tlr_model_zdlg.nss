// tlr_model_zdlg
// tailoring model conversation
//
#include "tb_inc_zdlg_utl"
#include "tb_inc_util"
#include "tb_tlr_inc"

/*

        0 Welcome to the Clothier's Shoppe.
            Change model to my race
                But of course. Change to <race> when you say yes.
                        Yes - do it here and end dlg
                        no return to main
            Modify the Clothing's appearance.
                1 What would you like to change?
                    The design
                          3 Select a Category:
                              neck -> tlr_modneck
                                    2: What change would you like to make?
                                         Next Apearance -> tlr_increaseitem - to 2
                                         Prev Apearance -> tlr_decreaseitem - to 2
                                         Enter an exact value. -> tlr_listenon
                                             Using the 'Talk' box type in the value you would like to set it to.
                                             Then click '1. Done' when you are complete.
                                                 done  -> tlr_setitem - to 2
                                                 cancel -> tlr_listenoff  - to 2
                                          Copy from other side. -> tlr_s_otherside - to 2
                                          Copy to other side. -> tlr_s_otherside2 - to 2
                                          Remove it. -> tlr_removeitem - to 2
                                          Rotate model clockwise. - tlr_rotateclock - to 2
                                          Rotate model counter-clockwise. - tlr_rotatecountr - to 2
                                          Re-equip clothing, to fix graphic bugs. -> tlr_fixclothing - to 2
                                          Done. - to 3
                                Belt   -> tlr_modbelt to 2
                                Pelvis  -> tlr_modpelvis to 2
                                Robe    -> tlr_modrobe to 2
                                Torso - selects AC filter (TorsoFilter int - never cleared anywhere) then goes to 2
                                Arms
                                     4 Select an item to modify
                                           Right shoulder -> tlr_modrshoulder - to 2
                                           Left shoulder -> tlr_modlshoulder- to 2
                                           ...
                                           Remove all arm parts  -> tlr_r_remarms to 4
                                           Back. -> to 3
                                Legs
                                     5  Select an item to modify
                                           Right thigh -> tlr_modrthigh - to 2
                                           Left thigh -> tlr_modlthigh- to 2
                                           ...
                                           Remove all leg parts  -> tlr_r_remlegs to 5
                                           Back. -> to 3
                                Symmetry
                                       Select a Category
                                            Arms -> tlr_s_setarms
                                                 Copy right to left -> tlr_s_r2l - to 3
                                                 Copy left to rigth  -> tlr_s_l2r - to 3
                                                 // Remove swap aa not really needed Swap left and right  -> tlr_s_swap - to 3
                                            Legs -> tlr_s_setlegs
                                                 (same as above)
                                            Both  -> tlr_s_setboth
                                                  (same as above)
                                            Back - to 3
                    The colors
                           7 Select the material to dye
                                Leather 1 -> tlr_leather1
                                      6 Select a color category.
                                          Tan/Brown & Tan/Red. -> tlr_group0
                                              select a color
                                                     (these names are all different for each group)
                                                     lighest ... -> tlr_color0 - to 7
                                                     ...
                                                     darkest  ... -> tlr_color7 - to 7
                                                     back - to 6
                                          Tan/Yellow & Tan/Gray. ...
                                          Olive, White, Gray & Charcoal.
                                          Blue, Aqua, Teal & Green.
                                          Yellow, Orange, Red & Pink.
                                          Purple, Violet & Shiny/Metallic group 1.
                                          Shiny/Metallic group 2.
                                          Hidden colors: Metallic & pure white and black. -> tlr_group7
                                Leather 2 -> tlr_leather2
                                ...
                                (metal group names are different from cloth/leather - otherwise same code)
                                Back. - to 1
                    // Move this up a level Copy the appearance of my clothing to the model's clothing. -> tlr_copypcoutfit - to 1
                    Reset the clothing to the default appearance. -> tlr_reset - > 1
                    Back (Purchase). - to 0
            Change the Model's appearance.
                what would you like to change?
                      set race to dwarf --> tlr_modeldwarf - to 0
                      ...
                      nevermind - to 0
            Buy the Model's current outfit.
                   (tlr_buycost - sets custom9876) -
                         (tlr_hascost) Yes I'll pay  -> tlr_buyoutfit - to 0
                         no thanks - to 0
            Copy the appearance of the model's outfit to my clothing.
                 (tlr_copycost - sets custom9876) -
                         (tlr_hascost) Yes I'll pay  -> tlr_copynpcoutfi - to 0
                         no thanks - to 0
            Copy the appearance of my clothing to the model's clothing. -> tlr_copypcoutfit - to 0
            Re-equip clothing, to fix graphic bugs. -> tlr_fixclothing - to 0
            Reset the clothing to the default appearance. -> tlr_reset - to 0
            nevermind.

 */

const string PAGEMAIN      = "tlrmain";
const string PAGEBUY       = "tlrbuy";
const string PAGECOPY      = "tlrcopy";
const string PAGENOGOLD    = "tlrnogold";
const string PAGEMODIFY    = "tlrmodify";
const string PAGEDESIGN    = "tlrdesign";
const string PAGEPART      = "tlrpart";
const string PAGEARMS      = "tlrarms";
const string PAGELEGS      = "tlrlegs";
const string PAGECOLOR     = "tlrcolor";
const string PAGESYMMETRY  = "tlrsymmetry";
const string PAGECHANNEL   = "tlrchannel";
const string PAGECHAT      = "tlrchat";
const string PAGERACE      = "tlrrace";



string tlrGetArmorName(int nAC) {
        switch (nAC) {
                case 0: return "clothing";
                case 1: return "padded armor";
                case 2: return "leather armor";
                case 3: return "studded leather and hide armor";
                case 4: return "chain shirts and scale armor";
                case 5: return "full chain male and breast plates";
                case 6: return "splint and banded mails";
                case 7: return "half-plate armor";
                case 8: return "full plate armor";
        }
        // -1
        return "any armor or clothing.";
}
// Each page gets a buildPage routine. This is responsible for
// setting the DlgPrompt and setting the Page string to this page
// the reply list is build in the initpage routine.

void buildPageMain(object oPC) {
        int nIndex = 0;
        string sPage = PAGEMAIN;

        DeleteList(sPage, oPC);
        int nAC = tlrGetAllowedAC(OBJECT_SELF);
        string sPrompt = "";
        if (!nAC) {
               sPrompt += "Welcome to the Clothier's Shoppe. This model will generate custom clothing.";
        } else {
               sPrompt += "Welcome to the Armorer's Shoppe. ";
               sPrompt += " This model will generate " + tlrGetArmorName(nAC) + ". ";
        }

        sPrompt += "What would you like to do?";
        SetDlgPrompt(sPrompt);
        object oNPCItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        object oPCItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);

        int nRace = GetRacialType(oPC);
        if (tlrGetAppearanceFromRace(nRace) != GetAppearanceType(OBJECT_SELF)) {
                AddStringElement("Set the model to my race.", sPage, oPC);
                ReplaceIntElement(nIndex++, 7, sPage, oPC);  
        }


        AddStringElement("Modify the Clothing's appearance.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Buy the model's current outfit.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        if (GetIsObjectValid(oNPCItem) && GetIsObjectValid(oPCItem) && CompareAC(oNPCItem, oPCItem)) {
                AddStringElement("Copy the appearance of the model's outfit to my clothing.", sPage, oPC);
                ReplaceIntElement(nIndex++, 3, sPage, oPC);
        }

        if (GetIsObjectValid(oPCItem)) {
        // && GetItemACBase(oPCItem) == 0) {  
                AddStringElement("Copy the appearance of my clothing to the model's clothing.", sPage, oPC);
                ReplaceIntElement(nIndex++, 4, sPage, oPC);
        }

        AddStringElement("Re-equip clothing, to fix graphic bugs.", sPage, oPC);
        ReplaceIntElement(nIndex++, 5, sPage, oPC);

        AddStringElement("Reset the clothing to the default appearance.", sPage, oPC);
        ReplaceIntElement(nIndex++, 6, sPage, oPC);

        AddStringElement("Nothing.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageNoGold(object oPC) {
        int nIndex = 0;
        string sPage = PAGENOGOLD;

        DeleteList(sPage, oPC);

        SetDlgPrompt("It appears you cannot afford this after all. Will there be anything else?");
        AddStringElement("Yes.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("nevermind.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageBuy(object oPC) {
        int nIndex = 0;
        string sPage = PAGEBUY;

        DeleteList(sPage, oPC);

        int nCost = tlrGetBuyCost(oPC, OBJECT_SELF);

        string sPrompt = "To buy the current selection will be " + IntToString(nCost) + " gold.";
        int bHasGold = (GetGold(oPC) > nCost);

        if (bHasGold) {
                sPrompt += " Would you like to pay?";
                AddStringElement("Yes, I'll pay.", sPage, oPC);
                ReplaceIntElement(nIndex++, 1, sPage, oPC);
        } else {
                 sPrompt += " This seems to be out your price range at the moment.";
        }
        SetDlgPrompt(sPrompt);

        AddStringElement("Nevermind.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageCopy(object oPC) {
        int nIndex = 0;
        string sPage = PAGECOPY;

        DeleteList(sPage, oPC);

        int nCost = tlrGetCopyCost(oPC, OBJECT_SELF);

        string sPrompt = "To copy these modifications to your current clothes will be " + IntToString(nCost) + " gold.";
        int bHasGold = (GetGold(oPC) > nCost);

        if (bHasGold) {
                sPrompt += " Would you like to pay?";
                AddStringElement("Yes, I'll pay.", sPage, oPC);
                ReplaceIntElement(nIndex++, 1, sPage, oPC);
        } else {
                sPrompt += " This seems to be out your price range at the moment. Can I help you with anything else?";
                AddStringElement("Yes.", sPage, oPC);
                ReplaceIntElement(nIndex++, 2, sPage, oPC);
        }
        SetDlgPrompt(sPrompt);

        AddStringElement("Nevermind.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageModify(object oPC) {
        int nIndex = 0;
        string sPage = PAGEMODIFY;

        DeleteList(sPage, oPC);
        SetDlgPrompt("What would you like to change?");


        AddStringElement("The design.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("The colors.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        AddStringElement("Reset the clothing to default.", sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}
void buildPageDesign(object oPC) {
        int nIndex = 0;
        string sPage = PAGEDESIGN;

        DeleteList(sPage, oPC);
        SetDlgPrompt("What would you like to work on?");

        AddStringElement("Neck.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_NECK, sPage, oPC);

        AddStringElement("Belt.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_BELT, sPage, oPC);

        AddStringElement("Pelvis.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_PELVIS, sPage, oPC);

        AddStringElement("Robe.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_ROBE, sPage, oPC);

        AddStringElement("Torso.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_TORSO, sPage, oPC);

        AddStringElement("Arms.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LFOREARM, sPage, oPC);

        AddStringElement("Legs.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LTHIGH, sPage, oPC);

        AddStringElement("Symmtery.", sPage, oPC);
        ReplaceIntElement(nIndex++, -2, sPage, oPC);


        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPagePart(object oPC, int nIdx = -1) {
        int nIndex = 0;
        string sPage = PAGEPART;
        string sPrompt = "";

        DeleteList(sPage, oPC);

        int nPart = GetLocalInt(oPC, "TLR_TOMODIFY");
        dlgDebug("page part modifying part : " + IntToString(nPart));

        // Display current part number (ooc but still useful)
        if (nIdx <= 0)
                nIdx = tlrGetCurrentPartNo(nPart);
        if (nIdx > 0) {
                sPrompt = "Current part index = " + IntToString(nIdx);
        //if (nCur == ITEM_APPR_ARMOR_MODEL_TORSO)
                sPrompt += " AC: " + IntToString(tlrGet2DAAC(nPart, nIdx)) + ".";
        }

        sPrompt += "What change would you make?";
        SetDlgPrompt(sPrompt);

        AddStringElement("Next part.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Prev part.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        AddStringElement("Enter an exact value (subject to availability).", sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        // These are only meaningful if one side or the other...
        if ( tlrIsSymmetrical(nPart)) {
                AddStringElement("Copy to other side.", sPage, oPC);
                ReplaceIntElement(nIndex++, 4, sPage, oPC);

                AddStringElement("Copy from other side.", sPage, oPC);
                ReplaceIntElement(nIndex++, 5, sPage, oPC);

        }

        // sets part to 0 (or lowest allowed)
        AddStringElement("Remove part.", sPage, oPC);
        ReplaceIntElement(nIndex++, 6, sPage, oPC);

        AddStringElement("Rotate model clockwise.", sPage, oPC);
        ReplaceIntElement(nIndex++, 7, sPage, oPC);

        AddStringElement("Rotate model counter-clockwise.", sPage, oPC);
        ReplaceIntElement(nIndex++, 8, sPage, oPC);

        AddStringElement("Re-equip clothing, to fix graphic bugs.", sPage, oPC);
        ReplaceIntElement(nIndex++, 9, sPage, oPC);

        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageArms(object oPC) {
        int nIndex = 0;
        string sPage = PAGEARMS;

        DeleteList(sPage, oPC);
        SetDlgPrompt("What arm part would you like to work on?");

        AddStringElement("Right shoulder.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RSHOULDER, sPage, oPC);

        AddStringElement("Left shoulder.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LSHOULDER, sPage, oPC);

        AddStringElement("Right bicep.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RBICEP, sPage, oPC);

        AddStringElement("Left bicep.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LBICEP, sPage, oPC);

        AddStringElement("Right forearm.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RFOREARM, sPage, oPC);

        AddStringElement("Left forearm.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LFOREARM, sPage, oPC);

        AddStringElement("Right hand.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RHAND, sPage, oPC);

        AddStringElement("Left hand.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LHAND, sPage, oPC);

        AddStringElement("Remove all arm parts.", sPage, oPC);
        ReplaceIntElement(nIndex++, -2, sPage, oPC);


        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}
void buildPageLegs(object oPC) {
        int nIndex = 0;
        string sPage = PAGELEGS;

        DeleteList(sPage, oPC);
        SetDlgPrompt("What leg part would you like to work on?");

        AddStringElement("Right thigh.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RTHIGH, sPage, oPC);

        AddStringElement("Left thigh.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LTHIGH, sPage, oPC);

        AddStringElement("Right shin.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RSHIN, sPage, oPC);

        AddStringElement("Left shin.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LSHIN, sPage, oPC);

        AddStringElement("Right foot.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_RFOOT, sPage, oPC);

        AddStringElement("Left foot.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_MODEL_LFOOT, sPage, oPC);

        AddStringElement("Remove all leg parts.", sPage, oPC);
        ReplaceIntElement(nIndex++, -2, sPage, oPC);


        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageSymmetry(object oPC) {
        int nIndex = 0;
        string sPage = PAGESYMMETRY;

        DeleteList(sPage, oPC);

        // Display current part number (ooc but still useful)
        SetDlgPrompt("What change would you make?");


        AddStringElement("Arms - copy right to left.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Arms - copy left to right.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        //AddStringElement("Arms - swap left and right.", sPage, oPC);
        //ReplaceIntElement(nIndex++, 3, sPage, oPC);

        AddStringElement("Legs - copy right to left.", sPage, oPC);
        ReplaceIntElement(nIndex++, 4, sPage, oPC);

        AddStringElement("Legs - copy left to right.", sPage, oPC);
        ReplaceIntElement(nIndex++, 5, sPage, oPC);

        //AddStringElement("Legs - swap left and right.", sPage, oPC);
        //ReplaceIntElement(nIndex++, 6, sPage, oPC);

        AddStringElement("Both - copy right to left.", sPage, oPC);
        ReplaceIntElement(nIndex++, 7, sPage, oPC);

        AddStringElement("Both - copy left to right.", sPage, oPC);
        ReplaceIntElement(nIndex++, 8, sPage, oPC);

        //AddStringElement("Both - swap left and right.", sPage, oPC);
        //ReplaceIntElement(nIndex++, 9, sPage, oPC);

        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

// Color handling
void buildPageColor(object oPC) {
        int nIndex = 0;
        string sPage = PAGECOLOR;

        DeleteList(sPage, oPC);
        SetDlgPrompt("What would you like to dye?");


        AddStringElement("Leather 1", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_COLOR_LEATHER1, sPage, oPC);

        AddStringElement("Leather 2.", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_COLOR_LEATHER2, sPage, oPC);

        AddStringElement("Cloth 1", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_COLOR_CLOTH1, sPage, oPC);

        AddStringElement("Cloth 2", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_COLOR_CLOTH2, sPage, oPC);

        AddStringElement("Metal 1", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_COLOR_METAL1, sPage, oPC);

        AddStringElement("Metal 2", sPage, oPC);
        ReplaceIntElement(nIndex++, ITEM_APPR_ARMOR_COLOR_METAL2, sPage, oPC);


        AddStringElement("Back.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
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
void buildPageChangeRace(object oPC) {
        int nIndex = 0;
        string sPage = PAGERACE;

        DeleteList(sPage, oPC);
        SetDlgPrompt("Of course. Selecting 'Yes' will change to model " 
                + tbCookString("to <race>", oPC) + " and end the conversation. Restart it to continue.");


        AddStringElement("Yes.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Cancel.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}
// for selecting the color of the current channel
//
void buildPageChannel(object oPC, int nIdx = -1) {
        int nIndex = 0;
        string sPage = PAGECHANNEL;
        string sPrompt = "";

        DeleteList(sPage, oPC);

        int nChannel = GetLocalInt(oPC, "TLR_MOD_CHANNEL");
        dlgDebug("page channel modifying channel : " + IntToString(nChannel));

        // Display current color  and row  and color
        if (nIdx < 0)
                nIdx = tlrGetCurrentColorNo(nChannel);

        if (nIdx >= 0) {
                sPrompt = "Current color = " + IntToString(nIdx);
        }

        sPrompt += " What change would you make?";
        SetDlgPrompt(sPrompt);

        AddStringElement("Next color.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Prev color.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        AddStringElement("Next row.", sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        AddStringElement("Prev row.", sPage, oPC);
        ReplaceIntElement(nIndex++, 4, sPage, oPC);

        AddStringElement("Enter an exact value (0 - 175).", sPage, oPC);
        ReplaceIntElement(nIndex++, 5, sPage, oPC);

        // Optionallly add one to copy from one of the other channels.
        // might be nice

        AddStringElement("Rotate model clockwise.", sPage, oPC);
        ReplaceIntElement(nIndex++, 7, sPage, oPC);

        AddStringElement("Rotate model counter-clockwise.", sPage, oPC);
        ReplaceIntElement(nIndex++, 8, sPage, oPC);

        AddStringElement("Re-equip clothing, to fix graphic bugs.", sPage, oPC);
        ReplaceIntElement(nIndex++, 9, sPage, oPC);

        AddStringElement("Back.", sPage, oPC);
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

    // Change clothing
        if (nChoice == 1) {
                buildPageModify(oPC);
                return;
        }


    // Buy current outfit new
        if (nChoice == 2) {
                buildPageBuy(oPC);
                return;
        }

     // Buy (copy) current outfit to PC
        if (nChoice == 3) {
                buildPageCopy(oPC);
                return;
        }
       // copy PC outfit to model.
        if (nChoice == 4) {
                tlrCopyToModel(oPC, OBJECT_SELF);
                buildPageMain(oPC);
                return;
        }
        // re-equip to fix bug
        if (nChoice == 5) {
            // build page foo
                tlrReEquip(OBJECT_SELF);
                buildPageMain(oPC);
                return;
        }

     // Reset model to default
        if (nChoice == 6) {
                tlrReset();
                buildPageMain(oPC);
                return;
        }
   
       // Change to PC race 
        if (nChoice == 7) {
                tlrReset();
                buildPageChangeRace(oPC);
                return;
        }


        EndDlg();
}
void handlePageBuy(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEBUY, oPC);
        dlgDebug("Page buy nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageMain(oPC);
                return;
        }

        //Actually buy the item
        if (nChoice == 1) {
                if (!tlrDoBuyItem(oPC, OBJECT_SELF)) {
                        buildPageNoGold(oPC);

                } else {
                        tlrReset();
                        buildPageMain(oPC);
                }
                DeleteLocalInt(oPC, "TLR_CURRENTPRICE");
                return;
        }

        EndDlg();
}
void handlePageCopy(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGECOPY, oPC);
        dlgDebug("Page copy nChoice = " + IntToString(nChoice));

	// Go back to main on nevermind not leave whole dialog since that resets the model
        if (nChoice == -1) {
                buildPageMain(oPC);
                return;
        }

        // PC hasn't enough money but wants to continue.
        if (nChoice == 2) {
                buildPageMain(oPC);
                return;
        }

        //Actually buy the item
        if (nChoice == 1) {
                if (!tlrDoCopyItemToPC(oPC, OBJECT_SELF)) {
                        buildPageNoGold(oPC);
                } else {
                        tlrReset();
                        buildPageMain(oPC);
                }
                DeleteLocalInt(oPC, "TLR_CURRENTPRICE");
                return;
        }

        EndDlg();
}
void handlePageModify(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEMODIFY, oPC);
        dlgDebug("Page Modify nChoice = " + IntToString(nChoice));


        // This is not needed
        if (nChoice == -1) {
                buildPageMain(oPC);
                return;
        }

        // Change design
        if (nChoice == 1) {
                buildPageDesign(oPC);
                return;
        }


        // color
        if (nChoice == 2) {
                buildPageColor(oPC);
                return;
        }

        // Reset appearance
        if (nChoice == 3) {
                tlrReset();
                buildPageModify(oPC);
                return;
        }
        buildPageMain(oPC);
}

void handlePageDesign(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEDESIGN, oPC);
        dlgDebug("Page design nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageMain(oPC);
                return;
        }
        // Symmetry menu
        if (nChoice == -2) {
                buildPageSymmetry(oPC);
                return;
        }


        // Arms submenu
        if (nChoice == ITEM_APPR_ARMOR_MODEL_LFOREARM) {
                buildPageArms(oPC);
                return;
        }

        // legs submenu
        if (nChoice == ITEM_APPR_ARMOR_MODEL_LTHIGH) {
                buildPageLegs(oPC);
                return;
        }


        SetLocalInt(oPC, "TLR_TOMODIFY", nChoice);
        buildPagePart(oPC);
}

void handlePageArms(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEARMS, oPC);
        dlgDebug("Page arm nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageDesign(oPC);
                return;
        }
        // remove all arm parts
        if (nChoice == -2) {
                tlrRemoveArms();
                buildPageArms(oPC);
                return;
        }

        SetLocalInt(oPC, "TLR_TOMODIFY", nChoice);
        buildPagePart(oPC);
}

void handlePageLegs(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGELEGS, oPC);
        dlgDebug("Page legs nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageDesign(oPC);
                return;
        }
        // remove all leg parts
        if (nChoice == -2) {
                tlrRemoveLegs();
                buildPageLegs(oPC);
                return;
        }

        SetLocalInt(oPC, "TLR_TOMODIFY", nChoice);
        buildPagePart(oPC);
}

void handlePagePart(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEPART, oPC);
        dlgDebug("Page part nChoice = " + IntToString(nChoice));
        int nNew = -1;

        if (nChoice == -1) {
                int nPart = GetLocalInt(oPC, "TLR_TOMODIFY");
                if (tlrIsArms(nPart))
                        buildPageArms(oPC);
                else if (tlrIsLegs(nPart))
                        buildPageLegs(oPC);

                buildPageDesign(oPC);
                return;
        }

        //  next part
        if (nChoice == 1) {
                nNew = tlrIncrementPart(GetLocalInt(oPC, "TLR_TOMODIFY"), oPC, FALSE, OBJECT_SELF);
                buildPagePart(oPC, nNew);
                return;
        }


        // previous part
        if (nChoice == 2) {
                nNew = tlrIncrementPart(GetLocalInt(oPC, "TLR_TOMODIFY"), oPC, TRUE, OBJECT_SELF);
                buildPagePart(oPC, nNew);
                return;
        }

     // enter numerical value
        if (nChoice == 3) {
                SetLocalInt(oPC, "TLR_CHAT_PAGE", 1);
                tlrStartChat(oPC, OBJECT_SELF);
                buildPageChat(oPC);
                return;
        }

       // copy to other side
        if (nChoice == 4) {
                tlrToOtherSide(GetLocalInt(oPC, "TLR_TOMODIFY"));
                buildPagePart(oPC);
                return;
        }
        // copy from other side
        if (nChoice == 5) {
                nNew = tlrFromOtherSide(GetLocalInt(oPC, "TLR_TOMODIFY"));
                buildPagePart(oPC, nNew);
                return;
        }

     // Remove part
        if (nChoice == 6) {
                tlrRemovePart(GetLocalInt(oPC, "TLR_TOMODIFY"));
                buildPagePart(oPC);
                return;
        }
         // Rotate clockwise
        if (nChoice == 7) {
                tlrRotateModel();
                buildPagePart(oPC);
                return;
        }
  // Rotate counter-clockwise
        if (nChoice == 8) {
                tlrRotateModel(TRUE);
                buildPagePart(oPC);
                return;
        }

        // Requip
        if (nChoice == 9) {
                tlrReEquip(OBJECT_SELF);
                buildPagePart(oPC);
                return;
        }

        buildPageDesign(oPC);
}

void handlePageSymmetry(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGESYMMETRY, oPC);
        dlgDebug("Page Symmetry nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageDesign(oPC);
                return;
        }

        // arms right to left
        if (nChoice == 1) {
                tlrSymmCopy(1);
                buildPageDesign(oPC);
                return;
        }

        // arms left to right
        if (nChoice == 2) {
                tlrSymmCopy(1, TRUE);
                buildPageDesign(oPC);
                return;
        }

        // arms swap
        if (nChoice == 3) {
                buildPageDesign(oPC);
                return;
        }

        // legs right to left
        if (nChoice == 4) {
                tlrSymmCopy(2);
                buildPageDesign(oPC);
                return;
        }

        // legs left to right
        if (nChoice == 5) {
                tlrSymmCopy(2, TRUE);
                buildPageDesign(oPC);
                return;
        }

        // legs swap
        if (nChoice == 6) {
                buildPageDesign(oPC);
                return;
        }

        //  both right to left
        if (nChoice == 7) {
                tlrSymmCopy(3);
                buildPageDesign(oPC);
                return;
        }

        // both left to right
        if (nChoice == 8) {
                tlrSymmCopy(3, TRUE);
                buildPageDesign(oPC);
                return;
        }

        // both swap
        if (nChoice == 9) {
                buildPageDesign(oPC);
                return;
        }

        buildPageDesign(oPC);
}

void handlePageColor(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGECOLOR, oPC);
        dlgDebug("Page Color nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageModify(oPC);
                return;
        }

        SetLocalInt(oPC, "TLR_MOD_CHANNEL", nChoice);
        buildPageChannel(oPC);
}
void handlePageChannel(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGECHANNEL, oPC);
        dlgDebug("Page channel nChoice = " + IntToString(nChoice));
        int nNew = -1;

        if (nChoice == -1) {
                buildPageColor(oPC);
                return;
        }

        //  next color
        if (nChoice == 1) {
                nNew = tlrIncrementColor(GetLocalInt(oPC, "TLR_MOD_CHANNEL"), FALSE, FALSE, OBJECT_SELF);
                buildPageChannel(oPC, nNew);
                return;
        }


        // previous color
        if (nChoice == 2) {
                nNew = tlrIncrementColor(GetLocalInt(oPC, "TLR_MOD_CHANNEL"), FALSE, TRUE, OBJECT_SELF);
                buildPageChannel(oPC, nNew);
                return;
        }

        //  next row
        if (nChoice == 3) {
                nNew = tlrIncrementColor(GetLocalInt(oPC, "TLR_MOD_CHANNEL"), TRUE, FALSE, OBJECT_SELF);
                buildPageChannel(oPC, nNew);
                return;
        }


        // previous row
        if (nChoice == 4) {
                nNew = tlrIncrementColor(GetLocalInt(oPC, "TLR_MOD_CHANNEL"), TRUE, TRUE, OBJECT_SELF);
                buildPageChannel(oPC, nNew);
                return;
        }

     // enter numerical value
        if (nChoice == 5) {
                SetLocalInt(oPC, "TLR_CHAT_PAGE", 2);
                tlrStartChat(oPC, OBJECT_SELF);
                buildPageChat(oPC);
                return;
        }

         // Rotate clockwise
        if (nChoice == 7) {
                tlrRotateModel();
                buildPageChannel(oPC);
                return;
        }
  // Rotate counter-clockwise
        if (nChoice == 8) {
                tlrRotateModel(TRUE);
                buildPageChannel(oPC);
                return;
        }

        // Requip
        if (nChoice == 9) {
                tlrReEquip(OBJECT_SELF);
                buildPageChannel(oPC);
                return;
        }

        buildPageColor(oPC);
}

void handlePageChat(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGECHAT, oPC);
        dlgDebug("Page Chat nChoice = " + IntToString(nChoice));
        int nRet = GetLocalInt(oPC, "TLR_CHAT_PAGE");
        DeleteLocalInt(oPC, "TLR_CHAT_PAGE");

        int nVal = tlrStopChat(oPC);
        int nNew;

        tlrDebug("CHAT got '" + IntToString(nVal) + "'");
        if (nChoice == -1 || nVal == -1) {
                // Need to know which page to return to - in either case
                if (nRet == 1)
                        buildPagePart(oPC);
                else
                        buildPageChannel(oPC);
                return;
        }

        if (nChoice == 1) {
                if (nRet == 1) {
                        nNew = tlrSetSpecificPart(GetLocalInt(oPC, "TLR_TOMODIFY"), oPC, nVal, OBJECT_SELF);
                        buildPagePart(oPC, nNew);
                }
                else {
                        nNew = tlrSetSpecificColor(GetLocalInt(oPC, "TLR_MOD_CHANNEL"), nVal, OBJECT_SELF);
                        buildPageChannel(oPC, nNew);
                }
        }
}
void handlePageChangeRace(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGERACE, oPC);
        dlgDebug("Page Race nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageMain(oPC);
                return;
        }
        int nRace = GetRacialType(oPC);
        DelayCommand(1.0, tlrDoModelType(nRace));
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
       //tlr_testlist(oPC);
	
	object oCloth = GetItemInSlot(INVENTORY_SLOT_CHEST);
	string sBP = tlrGetBaseResref(OBJECT_SELF);
	//SendMessageToPC(oPC, "TLR INIT wearing " + GetResRef(oCloth) + " default = " + sBP);
	//SetLocalString(OBJECT_SELF, "TLR_BASE_RESREF",  GetResRef(oCloth));
	
        //  Change model to match PC
        /*
        if (tlrSetModelType(GetRacialType(oPC))) {
               dlgDebug("Changed appearance - restarting conversation.");
               ClearAllActions();
               SetLocalInt(OBJECT_SELF, "tlr_did_change", TRUE);
               DelayCommand(5.0, AssignCommand(OBJECT_SELF, ActionStartConversation(oPC, "", TRUE, FALSE)));
               //EndDlg();
               return;
        }
        */
}

void PageInit() {
        string page = GetDlgPageString();
        object oPC = GetPcDlgSpeaker();
        dlgDebug("PAGEINIT: page = " + page);

    // These are special cases
        if(page == "" || page == PAGEMAIN) {
                buildPageMain(oPC);
                SetDlgResponseList(PAGEMAIN,oPC);
                return;
        }

    // All other pages just set the responselist - page has already been built
    // in the selection handler path
        SetDlgResponseList(page,oPC);
}

void Clean() {
        object oPC = GetPcDlgSpeaker();
        DeleteList(PAGEMAIN, oPC);
        DeleteList(PAGEBUY, oPC);
        DeleteList(PAGECOPY, oPC);
        DeleteList(PAGENOGOLD, oPC);
        DeleteList(PAGEMODIFY, oPC);
        DeleteList(PAGEDESIGN, oPC);
        DeleteList(PAGEPART, oPC);
        DeleteList(PAGEARMS, oPC);
        DeleteList(PAGELEGS, oPC);
        DeleteList(PAGECOLOR, oPC);
        DeleteList(PAGESYMMETRY, oPC);
        DeleteList(PAGECHANNEL, oPC);
        DeleteList(PAGECHAT, oPC);
        DeleteList(PAGERACE, oPC);

        // delete any variables and clean up - restore original clothing
        tlrReset();
        DeleteLocalInt(oPC, "TLR_TOMODIFY");
        DeleteLocalInt(oPC, "TLR_MOD_CHANNEL");
        DeleteLocalInt(oPC, "TLR_CHAT_PAGE");
        DeleteLocalInt(oPC, "TLR_CURRENTPRICE");
        DeleteLocalInt(oPC, "TLR_DID_PCITEM");

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
        if(page == PAGEBUY) {
                handlePageBuy(oPC, nSel);
                return;
        }
        if(page == PAGECOPY) {
                handlePageCopy(oPC, nSel);
                return;
        }
        if(page == PAGEMODIFY) {
                handlePageModify(oPC, nSel);
                return;
        }
        if(page == PAGEDESIGN) {
                handlePageDesign(oPC, nSel);
                return;
        }
        if(page == PAGEPART) {
                handlePagePart(oPC, nSel);
                return;
        }
        if(page == PAGELEGS) {
                handlePageLegs(oPC, nSel);
                return;
        }
        if(page == PAGEARMS) {
                handlePageArms(oPC, nSel);
                return;
        }
        if(page == PAGESYMMETRY) {
                handlePageSymmetry(oPC, nSel);
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
        if(page == PAGERACE) {
                handlePageChangeRace(oPC, nSel);
                return;
        }
    // handle any pages with 1 or 2 responses (return to main or endDlg)
        handleReturnToMain(oPC, nSel, page);
        return;
}

void main() {
        switch(GetDlgEventType()) {
                case DLG_INIT:      Init(); break;
                case DLG_PAGE_INIT: PageInit(); break;
                case DLG_SELECTION: HandleSelection(); break;
                case DLG_ABORT:     Clean(); break;
                case DLG_END:       Clean(); break;
        }
}
