// tb_temple_zdlg.nss
// Generic variable driven NPC conversation allowing for priests in temples or shrines
//

#include "tb_inc_zdlg_utl"
#include "tb_inc_deity"
#include "deityconv_inc"
#include "nw_i0_plot"
//#include "_prr_inc_wrap"
//#include "tb_inc_death"
#include "_inc_corpse"

/*
    Basic general conversation driven by variables on the NPC

    4 choices at start - no intros

    1) PC is cleric in good standing with the NPCs Deity
                  Welcome home <Brother/Sister> of the faith!

                I am in need of services of the church.

                how may I help you?

    2) PC is follower in good standing with the NPCs Deity
                  Welcome to our <temple> <brother/sister>

                I am in need of services of the church.

                how may I help you?

    3)  PC is fallen cleric or lapsed follower
                 Welcome to our <temple>.

                I am in need of services of the church.

                how may I help you?


    4 ) PC is follower/cleric of a different deity.
                  Welcome to the <temple> of <deityname>.

                I was wondering if you might help me?




     How may I help you?

        (only if 4) Tell me about <deity>
                   Show token info
                  I see. Thank you.
                       return to main

            (only if 4) I wish to follow Deity
                    If cleric - You already serve another God.
                  Oh, I must have forgotten
                      return to main

            if pass check - Very well Let t be know that you follow deity. Welcome to the fold!
                  Thank you.
                                   return to main

                        if not pass - I'm sorry, Deity will not accept you as a follower.
                   I see. Thank you
                         return to main


        (only if 2) I wish to serve Deity as a cleric
                     if cleric (should not happen)  You already serve another God.

             else - You may serve deity if you are alignment/race/gender/subrace. Do you still with to serve?
                                      Yes -
                            If pass Then I will pray for <CUSTOM420> to call you to his service.  When you are experienced enough, begin your profession as a cleric with the <CUSTOM427> domains.  You must be <CUSTOM426>, otherwise your prayers will not be granted and you may suffer the wrath of <CUSTOM420>.
                             Thank you.
                                return to main
                        else To serve as a cleric of <CUSTOM420>, you must be  <CUSTOM426><CUSTOM428><CUSTOM429> and must take domains <CUSTOM427>.
                                                 I see
                                return to main

                      no  - return to main

        I would like to tithe to our <temple>
                  Offer amount and let PC decide
              if accepted take gold a set did tithe
              adjust favor towards deity if cleric/follower
               if now in favor treat as 1 or 2 for healing and store.

        I am in need of healing
                  If 1  - free just do it a show blessing
              if 2  - free if did tithe, else small fee (similar to tithe amount)
              if 3 or 4  - if did tithe, then small fee. If not then larger fee

        (if store) I would like to purchase goods
                  Open store with adjustment based on 1,2,3,4

        just looking around, thanks



 */
const int SUBDLG_INDEX = 5;

// Open the NPCs store with markup/discount based on PCs standing with NPCs church.
int dlgDietyOpenStore(object oPC, object oNPC = OBJECT_SELF, int bDidTithe = FALSE) {
    string sStore = GetLocalString(oNPC, "dlg_store");
    object oStore = GetNearestObjectByTag(sStore);
    int nDeity = GetDeityIndex(oNPC);
    int nStanding = deityGetStanding(nDeity, oPC);

    int nUp = 0;
    int nDown = 0;
    if (!nStanding) {
        if(bDidTithe) {
            nUp = 10;
        } else {
            nUp = 20;
        }
    } else if (nStanding ==  DEITY_STANDING_FOLLOWER_LAPSED) {
        if(bDidTithe){
            nUp = 5;
        } else {
            nUp = 15;
        }
    } else if (nStanding ==  DEITY_STANDING_FOLLOWER_OK || nStanding ==  DEITY_STANDING_FOLLOWER_HIGH) {
        if(bDidTithe) {
            nUp = 0;
            nDown = 5;
        } else {
            nUp = 5;
        }
    }  else if (nStanding ==  DEITY_STANDING_CLERIC_LAPSED) {
        if(bDidTithe) {
            nUp = 0;
        } else {
            nUp = 5;
        }
    } else if (nStanding ==  DEITY_STANDING_CLERIC_OK || nStanding ==  DEITY_STANDING_CLERIC_HIGH) {
        if(bDidTithe) {
            nUp = 0;
            nDown = 20;
        } else {
            nUp = 0;
            nDown = 10;
        }
    }


    if (GetObjectType(oStore) == OBJECT_TYPE_STORE) {
       // SetLocalObject(oNPC, "coins_tmp_store", oStore);
       // SetLocalInt(oNPC, "coins_tmp_rich", TRUE);
       // ExecuteScript("coins_init_store", oNPC);
        //prrWrapOpenStore(oPC, GetTag(oStore), oNPC, nUp,nDown);
        AssignCommand(oNPC, gplotAppraiseOpenStore(oStore, oPC, nUp,nDown));
        return TRUE;
    }

    db("Store " + sStore + " not found");
    return FALSE;
}

int IsSubDlg(object oNPC) {
        string sDlg = GetLocalString(oNPC, "dialog");

    // This tells us if this is a subdialog or not. If so we don't want to do
        if (sDlg != "tb_temple_zdlg")
                return TRUE;

        return FALSE;
}

string getTempleGreeting(object oPC, object oNPC) {
        int nDeity = GetLocalInt(oNPC, "dlg_deity_idx");
        int nStanding = deityGetStanding(nDeity, oPC);
        string sTemp =  GetDeityChurchName(nDeity);
        string sPrompt;

        if (nStanding == 0)
                sPrompt = "Welcome to the " + sTemp + " of " + GetDeity(OBJECT_SELF);
        else  if (nStanding == DEITY_STANDING_CLERIC_OK || nStanding ==  DEITY_STANDING_CLERIC_HIGH )
                sPrompt =  tbCookString("Welcome home <Brother/Sister> of the faith!", oPC);
        else  if (nStanding == DEITY_STANDING_FOLLOWER_OK || nStanding ==  DEITY_STANDING_FOLLOWER_HIGH )
                sPrompt = tbCookString("Welcome to our " + sTemp + " <Brother/Sister>.", oPC) ;
        else  if (nStanding < 0)
                sPrompt = "Welcome to our " + sTemp + ".";
        return sPrompt;
}

const string PAGEGREET    = "templegreet";
const string PAGEMAIN     = "templemain";
const string PAGEINFO     = "templeinfo";
const string PAGEFOLLOW   = "templefollow";
const string PAGESERVE    = "templeserve";
const string PAGESERVE2   = "templedidserve";
const string PAGETITHE    = "templetithe";
const string PAGETITHE2   = "templedidtithe";
const string PAGEHEAL     = "templeheal";
const string PAGEHEAL2    = "templedidheal";
const string PAGECURSE    = "templecurse";
const string PAGECURSE2   = "templedidcurse";
const string PAGEHOLYSYM  = "templeholysym";
const string PAGENOGOLD   = "templenogold";
const string PAGEREZZ     = "templerezz";
const string PAGEREZZDONE = "templerezzdone";


// Each page gets a buildPage routine. This is responsible for
// setting the DlgPrompt and setting the Page string to this page
// the reply list is build in the initpage routine.

void buildPageMain(object oPC) {
        int nIndex = 0;
        int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
        string sPage = PAGEMAIN;

        DeleteList(sPage, oPC);
        string sPrompt = "";


        if (IsSubDlg(OBJECT_SELF)) {
                sPrompt = getTempleGreeting(oPC, OBJECT_SELF);
                sPrompt += " ";
        }
        if (Random(2))
                sPrompt += "How may I be of service?";
        else
                sPrompt += "How may I help you?";

        SetDlgPrompt(sPrompt);

        int nStanding = deityGetStanding(nDeity, oPC);
        string sTemp =  GetDeityChurchName(nDeity);
        string sDeity = GetDeityName(nDeity);

        if (nStanding == DEITY_STANDING_OTHER) {
                AddStringElement("Tell me about " + sDeity + ".", sPage, oPC);
                ReplaceIntElement(nIndex++, 1, sPage, oPC);

                AddStringElement("I wish to follow " + sDeity + ".", sPage, oPC);
                ReplaceIntElement(nIndex++, 2, sPage, oPC);
        }

        if (nStanding ==  DEITY_STANDING_FOLLOWER_OK || nStanding ==  DEITY_STANDING_FOLLOWER_HIGH )  {
                AddStringElement("I wish to serve " + sDeity + " as a cleric.", sPage, oPC);
                ReplaceIntElement(nIndex++, 3, sPage, oPC);
        }

    // Tithing if not done already
        if (!GetLocalInt(oPC, "dlg_did_tithe")) {
                string sTmp = "the";
                if (nStanding != 0)
                        sTmp = "our";

                AddStringElement("I would like to make an offering to " + sTmp + " " + sTemp + " .", sPage, oPC);
                ReplaceIntElement(nIndex++, 4, sPage, oPC);
        }

    // optional subdialog line
        dlgDebug("Checking for subdlg, index = " + IntToString(GetLocalInt(oPC, "dlg_subdlg_index")));
        string sPCsub = getPCSubDlg(oPC, OBJECT_SELF, GetLocalInt(oPC, "dlg_subdlg_index"));
        if (sPCsub != "") {
                AddStringElement(sPCsub, sPage, oPC);
                ReplaceIntElement(nIndex++, 5, sPage, oPC);
        }

    // healing -
        if (!GetLocalInt(oPC, "dlg_did_heal")){
                AddStringElement("I am in need of healing.", sPage, oPC);
                ReplaceIntElement(nIndex++, 6, sPage, oPC);
        }
        // remove curse - only if haven't tried and PC has a curse
        if (!GetLocalInt(oPC, "dlg_did_curse")&& GetLocalInt(oPC, "dlg_has_curse")) {
                AddStringElement("I am afflicted with a curse.", sPage, oPC);
                ReplaceIntElement(nIndex++, 9, sPage, oPC);
        }

    // holysymbol
        if (!GetLocalInt(oPC, "dlg_did_holysym") && dlgDeityNeedsHolySymbol(oPC, nDeity, OBJECT_SELF)){
                AddStringElement("I am in need of a holy symbol for our deity.", sPage, oPC);
                ReplaceIntElement(nIndex++, 8, sPage, oPC);
        }

        if (dlgHasStore(oPC)) {
                AddStringElement("I would like to purchase goods.", sPage, oPC);
                ReplaceIntElement(nIndex++, 7, sPage, oPC);
        }

        if (GetIsObjectValid(GetLocalObject(oPC, "TEMPLE_REZZ_BODY"))) {
                AddStringElement("My companion is dead. Is there anything you can do?", sPage, oPC);
                ReplaceIntElement(nIndex++, 11, sPage, oPC);
        }

        if (IsSubDlg(OBJECT_SELF)) {
                AddStringElement("I'd like to talk about something else.", sPage, oPC);
                ReplaceIntElement(nIndex++, 10, sPage, oPC);
        }

        AddStringElement(dlgGetGoodBye(oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}

void buildPageGreet(object oPC, int bFirst) {
    int nIndex = 0;
    string sPage = PAGEGREET;
    DeleteList(sPage, oPC);

        // Skip the greeting if this was called as a subdlg.
    if (IsSubDlg(OBJECT_SELF)) {
        buildPageMain(oPC);
        SetDlgResponseList(PAGEMAIN, oPC);
        return;
    }

    string sPrompt = getTempleGreeting(oPC, OBJECT_SELF);
    SetDlgPrompt(sPrompt);

    AddStringElement("Thank you. I am in need of services.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement("Nevermind.", sPage, oPC); // dlgGetGoodBye ?
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

    // needed in the first page only
    SetDlgResponseList(sPage, oPC);
    SetDlgPageString(sPage);
}

void buildPageInfo(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = dlgGetDeityInfo(OBJECT_SELF);
    string sPage = PAGEINFO;

    DeleteList(sPage, oPC);

    SetDlgPrompt(sPrompt);
    AddStringElement("I see. Thank you.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}
void buildPageNoGold(object oPC) {
    int nIndex = 0;
    string sPage = PAGENOGOLD;

    DeleteList(sPage, oPC);

    SetDlgPrompt("I'm afraid you cannot afford this. Is there anything else I can do for you?");
    AddStringElement("Yes.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);


    AddStringElement("No thanks.", sPage, oPC);
    ReplaceIntElement(nIndex++, -1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageFollow(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";

    string sPage = PAGEFOLLOW;
    DeleteList(sPage, oPC);

    if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0) {
        sPrompt = "I believe you already serve another deity.";
        sResp = "Yes, I must have forgotten.";
    } else {
        if (DeityCheckCanFollow(oPC, nDeity)) {
            SetDeity(oPC, GetDeityName(nDeity));
            sPrompt = "Very well Let it be know that you follow deity." + deityGetBlessingStr(nDeity);
            sResp = "Thank you.";

        } else {
            sPrompt = "I'm sorry, " +  GetDeityName(nDeity) + " will not accept you as a follower at this time.";
            sResp = "I see.";
        }
    }

    SetDlgPrompt(sPrompt);
    AddStringElement(sResp, sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageServe(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGESERVE;
    DeleteList(sPage, oPC);

    if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0) {
        sPrompt = "I believe you already serve another deity.";
        sResp = "Yes, I must have forgotten.";
    } else {
        sPrompt = dlgGetDeityRestrictions() + " "
               + tbActionString("This will take the place of any other training you have done for your next level", oPC)
               + " Do you still wish to serve?";
        AddStringElement("Yes, I do.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);

        sResp = "No. I've changed my mind.";
    }

    SetDlgPrompt(sPrompt);
    AddStringElement(sResp, sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
 }

void buildPageServe2(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGESERVE2;
    DeleteList(sPage, oPC);

    if (DeityCheckCanServe(oPC, nDeity)) {
        sPrompt = dlgGetServeMessage(OBJECT_SELF);
        // no other action - must already have been a follower to get here.
        // TODO - no ... need to set some variable which can be checked by CCS system to allow level up as cleric.??
        // Also need to set this as the trained class
        SetPersistentInt(oPC, "deity_allowed_cleric", TRUE);
        sResp = "Thank you. I look forward to serving " +  GetLocalString(OBJECT_SELF, "_cur_deity_name") + ".";
    } else {

        sPrompt = "You may not serve " + GetLocalString(OBJECT_SELF, "_cur_deity_name") + " at this time.";
        sResp = "I see.";
    }
    SetDlgPrompt(sPrompt);
    AddStringElement(sResp, sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}


void buildPageTithe2(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGETITHE2;
    DeleteList(sPage, oPC);

    int nStand =  deityGetStanding(nDeity, oPC);
    // Do whatever work is needed - at least take the gold
    TakeGoldFromCreature(GetLocalInt(oPC, "_cur_tithe_amount"), oPC, TRUE);

    SetLocalInt(oPC, "dlg_did_tithe", 1);
    if (nStand) {
        deityAdjustFavor(oPC, 0);
    }

    SetDlgPrompt("Thank you for supporting our " +  GetDeityChurchName(nDeity) + ". Is there anything else?");
    AddStringElement("Yes.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement("Not at this time.", sPage, oPC);
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageTithe(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sPage = PAGETITHE;
    object oNPC = OBJECT_SELF;

    DeleteList(sPage, oPC);
    DeleteLocalInt(oPC, "_cur_tithe_amount");

    int nAmount = deityGetTitheAmount(nDeity, oPC);
    SetLocalInt(oPC, "_cur_tithe_amount", nAmount);

    int nStand = deityGetStanding(nDeity, oPC);
    if (!nStand) {
        sPrompt = "You are not a follower of " + GetLocalString(oNPC, "_cur_deity_name")
            + " but we would gladly except a donation of " + IntToString(nAmount) + tbCookString(" <gold>,", oPC);
    } else if (nStand == DEITY_STANDING_FOLLOWER_OK || nStand == DEITY_STANDING_FOLLOWER_HIGH || nStand == DEITY_STANDING_FOLLOWER_LAPSED) {
        sPrompt = "Your tithe is welcome. The typical tithe for someone of your status is " + IntToString(nAmount) + tbCookString(" <gold>.", oPC);
    } else if (nStand == DEITY_STANDING_CLERIC_OK || nStand == DEITY_STANDING_CLERIC_HIGH || nStand == DEITY_STANDING_CLERIC_LAPSED) {
        sPrompt = "Your tithe is welcome. The typical tithe for a cleric of your experience is " + IntToString(nAmount) + tbCookString(" <gold>.", oPC);    }

    // Check if PC has amount before doing this one
    if (GetGold(oPC) >= nAmount) {
        AddStringElement(tbActionString("Make the offering", oPC), sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);
    }

    SetDlgPrompt(sPrompt);
    AddStringElement ("I've changed my mind.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageHeal(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGEHEAL;
    DeleteList(sPage, oPC);
    DeleteLocalInt(oPC, "_cur_heal_amount");

    // Figure amount and make a statement -
    // depends on follower or cleric or other too.

    int nAmount = deityGetHealAmount(nDeity, oPC, GetLocalInt(oPC, "dlg_did_tithe"));
    int nStand =  deityGetStanding(nDeity, oPC);
    SetLocalInt(oPC, "_cur_heal_amount", nAmount);

    if (nAmount == 0) {
        // Cleric in good standing - free healing...
        sPrompt =  tbCookString("We are always available to help, my <Brother/Sister>. ", oPC) + deityGetBlessingStr(nDeity);
        // Do the healing and get out
        deityFullHeal(oPC, OBJECT_SELF);
        SetLocalInt(oPC, "dlg_did_heal", 1);

        SetDlgPrompt(sPrompt);
        AddStringElement("Thank you.", sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);
        return;
    }

    // not followers or lapsed followers pay full
    if (!nStand) {
        sPrompt = "You are not a follower of " + GetLocalString(OBJECT_SELF, "_cur_deity_name")
            + " but we could heal your injuries for " + IntToString(nAmount) + tbCookString(" <gold>.", oPC);

    } else {
        sPrompt = "We can heal all your wounds and maladies for " + IntToString(nAmount) + tbCookString(" <gold>.", oPC);
    }

    // Check if PC has amount before doing this one
    if (GetGold(oPC) >= nAmount) {
        AddStringElement("Please heal me.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);
    }

    SetDlgPrompt(sPrompt);
    AddStringElement("I've changed my mind.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageHeal2(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGEHEAL2;
    DeleteList(sPage, oPC);

    // Do whatever work is needed - at least take the gold
    TakeGoldFromCreature(GetLocalInt(oPC, "_cur_heal_amount"), oPC, TRUE);
    //TakeGoldFromCreature(GetLocalInt(oPC, "_cur_heal_amount"), oPC, TRUE);
    SetLocalInt(oPC, "dlg_did_heal", 1);

    deityFullHeal(oPC, OBJECT_SELF);
    SetDlgPrompt(deityGetBlessingStr(nDeity) + " Is there anything else?");
    AddStringElement("Thank you, yes.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement("Thank you, no.", sPage, oPC);
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageCurse(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGECURSE;
    DeleteList(sPage, oPC);
    DeleteLocalInt(oPC, "_cur_heal_amount");

    // Figure amount and make a statement -
    // depends on follower or cleric or other too.

    // TODO - this is the same as for healing now...
    int nAmount = deityGetHealAmount(nDeity, oPC, GetLocalInt(oPC, "dlg_did_tithe"));
    int nStand =  deityGetStanding(nDeity, oPC);
    SetLocalInt(oPC, "_cur_heal_amount", nAmount);

    if (nAmount == 0) {
        // Cleric in good standing - free healing...
        sPrompt =  tbCookString("We are always available to help, my <Brother/Sister>. ", oPC) + deityGetBlessingStr(nDeity);
        // do remove curse on PC
        //ActionCastSpellAtObject(SPELL_REMOVE_CURSE, oPC, TRUE);
        deityRemCurse(oPC);
        SetLocalInt(oPC, "dlg_did_curse", 1);

        SetDlgPrompt(sPrompt);
        AddStringElement("Thank you.", sPage, oPC);
        ReplaceIntElement(nIndex++, 3, sPage, oPC);

        SetDlgResponseList(sPage, oPC);
        SetDlgPageString(sPage);
        return;
    }

    // not followers or lapsed followers pay full
    if (!nStand) {
        sPrompt = "You are not a follower of " + GetLocalString(OBJECT_SELF, "_cur_deity_name")
            + " but we can attempt to remove any curses for " + IntToString(nAmount) + tbCookString(" <gold>.", oPC);

    } else {
        sPrompt = "We can attempt to remove any curses for " + IntToString(nAmount) + tbCookString(" <gold>.", oPC);
    }
    sPrompt += " Depending on the power of the curse this may not be successful and we are unable to offer any refunds.";

    // Check if PC has amount before doing this one
    if (GetGold(oPC) >= nAmount) {
        AddStringElement("Please proceed.", sPage, oPC);
        ReplaceIntElement(nIndex++, 2, sPage, oPC);
    }

    SetDlgPrompt(sPrompt);
    AddStringElement("I've changed my mind.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageCurse2(object oPC) {
    int nIndex = 0;
    int nDeity = GetLocalInt(OBJECT_SELF, "dlg_deity_idx");
    string sPrompt = "";
    string sResp = "";
    string sPage = PAGECURSE2;
    DeleteList(sPage, oPC);

    // Do whatever work is needed - at least take the gold
    TakeGoldFromCreature(GetLocalInt(oPC, "_cur_heal_amount"), oPC, TRUE);
    SetLocalInt(oPC, "dlg_did_curse", 1);

    // do remove curse here
    deityRemCurse(oPC);
    //ctionCastSpellAtObject(SPELL_REMOVE_CURSE, oPC, TRUE);

    // TODO report success or failure? Maybe just sendmessagetoPC in the remove curse code...
    SetDlgPrompt("We have done what we can with your afflictions. " + deityGetBlessingStr(nDeity) + " Is there anything else?");
    AddStringElement("Thank you, yes.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement("Thank you, no.", sPage, oPC);
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

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

    SetDlgPrompt("Here you are. Try to be more careful with this one. " + deityGetBlessingStr(nDeity) + " Is there anything else?");
    AddStringElement("Thank you, yes.", sPage, oPC);
    ReplaceIntElement(nIndex++, 1, sPage, oPC);

    AddStringElement("Thank you, no.", sPage, oPC);
    ReplaceIntElement(nIndex++, 2, sPage, oPC);

    SetDlgPageString(sPage);
}

void buildPageRezz(object oPC) {
        int nIndex = 0;
        string sPage = PAGEREZZ;

        DeleteList(sPage, oPC);

        if (GetLocalInt(OBJECT_SELF, "TEMPLE_NO_REZZ")) {
                SetDlgPrompt("I'm afraid we cannot help  you at this time.");
                AddStringElement("Very well.", sPage, oPC);
                ReplaceIntElement(nIndex++, -1, sPage, oPC);
                SetDlgPageString(sPage);
                return;
        }

        // TODO - check for more than one and complain. 
        // Should set this one as a local variable...
        //object oCorpse = GetItemPossessedBy(oPC, "it_deathcorpse");
	object oCorpse = GetLocalObject(oPC, "TEMPLE_REZZ_BODY");
	GetItemPossessedBy(oPC, "it_deathcorpse");
        if (!GetIsObjectValid(oCorpse) || GetItemPossessor(oCorpse) != oPC) {
                SetDlgPrompt("You do not seem to have any dead bodies.");
                AddStringElement("Sorry. I must have misplaced it.", sPage, oPC);
                ReplaceIntElement(nIndex++, -1, sPage, oPC);
                SetDlgPageString(sPage);
                return;
        }
        //SetLocalObject(oPC, "TEMPLE_REZZ_BODY", oCorpse);


        string sPrompt;
        int bCanRaise = FALSE;
        int bCanRezz = FALSE;
        
        // calculate cost and offer the option to rezz.
        // Check PC gold etc.
        // HCR has 3 levels. We have - raise, rezz
        // raise - penalty and 1 HP, rezz penalty full HP and true rezz  no penalty full HP
        // hc uses cleric level *50  + 500 * base (1) for raise and
        // level*70 + 500x for rezz and 90l+5000x for true rezz.
        // Cost in 3.5 is 5000 for raise and 10000 for rezz.

        // checks alignment of corpse versus cleric if both are not neutral.
        int nAlign=GetLocalInt(oCorpse, "Alignment");
        int nClericAlign = GetAlignmentGoodEvil(OBJECT_SELF);
        int nMod = 0;

        if (nAlign != ALIGNMENT_NEUTRAL && nClericAlign != ALIGNMENT_NEUTRAL) {
                if (nClericAlign == nAlign) {
                        nMod = 90;
                } else {
                        nMod = 110;
                }
        }
        int nClericLvl = GetLocalInt(OBJECT_SELF, "ClericLevel");

        // these are configurable in tb_death_cfg
        object oMod = GetModule();
        int nRaiseCost = GetLocalInt(oMod, "deathraisebase")  + 50 * nClericLvl;
        int nRezzCost1 = GetLocalInt(oMod, "deathrezzbase") + 50 *  nClericLvl;
        int nRezzCost2 = nRezzCost1 +  GetLocalInt(oMod, "deathequipment") ;
        if (nMod != 0) {
                nRaiseCost = (nRaiseCost * nMod)/100;
                nRezzCost1 = (nRezzCost1 * nMod)/100;  
                nRezzCost2 = (nRezzCost2 * nMod)/100;
        }


        SetLocalInt(oPC, "TMP_REZZ_COST1", nRaiseCost);
        SetLocalInt(oPC, "TMP_REZZ_COST2", nRezzCost1);
        SetLocalInt(oPC, "TMP_REZZ_COST3", nRezzCost2);
 
        // check cleric level to see what they can offer 10th for rais, 13th for rezz and 17th for true rezz.
        // hc_rezztrue, hc_ress and hc_raise_dead scripts.
        bCanRaise =TRUE; // = deathGetCanRaise(oCorpse, nClericLvl);
        bCanRezz = (nClericLvl > 12);

        if (bCanRaise && bCanRezz) {
                sPrompt = "This is a fairly recent death. We can summon the spirit right back but the body will be weak still. ";
                sPrompt += " We can also perform a full resurrection on your companion but it is expensive. "; 
                //sPrompt += " In Addition we could try to pull in any items which may have been associated with your companion for a bit more.";
        } else if (bCanRaise && !bCanRezz) {
                sPrompt = "This is a fairly recent death. We can summon the spirit right back but the body will be weak still. ";
        } else if (bCanRezz && !bCanRaise) {
                sPrompt = " We can perform a full resurrection on your companion but it is expensive."; 
                //sPrompt += " In Addition we can try to pull in any items which may have been associated with your companion for a bit more.";
        } else {
                sPrompt =  "I'm afraid your companion is beyond our help. You may have better luck at a larger temple.";
        }

        SetDlgPrompt(sPrompt);

        if (bCanRaise) {
                AddStringElement(tbActionString("Raise Dead - " + IntToString(nRaiseCost) + " <gold>", oPC) , sPage, oPC);
                ReplaceIntElement(nIndex++, 1, sPage, oPC);
        }
        if (bCanRezz) {
                AddStringElement(tbActionString("Resurrection - " + IntToString(nRezzCost1) + " <gold>", oPC), sPage, oPC);
                ReplaceIntElement(nIndex++, 2, sPage, oPC);

                // TODO - this could be only if logged in ?
                //AddStringElement(tbActionString("Resurrection with item summoning - " + IntToString(nRezzCost2) + " <gold>", oPC), sPage, oPC);
                //ReplaceIntElement(nIndex++, 3, sPage, oPC);
        }


        AddStringElement("I'll have to come to terms with the loss. Thank you.", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);
        SetDlgPageString(sPage);
}
void buildPageRezzDone(object oPC, int bOnline) {
        int nIndex = 0;
        string sPage = PAGEREZZDONE;

        DeleteList(sPage, oPC);
        DeleteLocalObject(oPC, "TEMPLE_REZZ_BODY");

        if (bOnline) {
                SetDlgPrompt("It is done. Your companion should be better momentarily.");
        } else {
                SetDlgPrompt("It is done. Your companion is not in this realm but will be restored upon return.");
        }
        AddStringElement("Thank you! I'd like to talk about something else.", sPage, oPC);
        ReplaceIntElement(nIndex++, 1, sPage, oPC);

        AddStringElement("Thank you!", sPage, oPC);
        ReplaceIntElement(nIndex++, -1, sPage, oPC);  

        SetDlgPageString(sPage);
}
/// Page selection handlers
// Each page gets a handlePage routine which decides what to do
// it is responsible for calling buildPage of the page which should be shown next
// or ending the dlg.
void handlePageServe(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGESERVE, oPC);
    dlgDebug("pageserve nCoice = "+ IntToString(nChoice));

    // no thanks
    if(nChoice == 1) {
        buildPageMain(oPC);
        return;
    }
    if(nChoice == 2) {
        buildPageServe2(oPC);
        return;
    }

    EndDlg();
}

void handlePageTithe(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGETITHE, oPC);
    dlgDebug("pagetithe nCoice = "+ IntToString(nChoice));

    // no thanks
    if(nChoice == 1) {
        buildPageMain(oPC);
        return;
    }

    if(nChoice == 2) {
        if (GetGold(oPC) < GetLocalInt(oPC, "_cur_tithe_amount")) {
                buildPageNoGold(oPC);
                return;
        }
        buildPageTithe2(oPC);
        return;
    }

    EndDlg();
}

void handlePageHeal(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGEHEAL, oPC);
    dlgDebug("pageheal nCoice = "+ IntToString(nChoice));

    // no thanks or done already - back to main
    if(nChoice == 1 || nChoice == 3) {
        buildPageMain(oPC);
        return;
    }

    // else pay for healing
    if(nChoice == 2) {
        if (GetGold(oPC) < GetLocalInt(oPC, "_cur_heal_amount")) {
                buildPageNoGold(oPC);
                return;
        }
        buildPageHeal2(oPC);
        return;
    }

    EndDlg();
}

void handlePageCurse(object oPC, int nSel) {

    int nChoice = GetIntElement(nSel, PAGECURSE, oPC);
    dlgDebug("pagecurse nCoice = "+ IntToString(nChoice));

    // no thanks or done already - back to main
    if(nChoice == 1 || nChoice == 3) {
        buildPageMain(oPC);
        return;
    }

    // else pay for healing
    if(nChoice == 2) {
        if (GetGold(oPC) < GetLocalInt(oPC, "_cur_heal_amount")) {
                buildPageNoGold(oPC);
                return;
        }
        buildPageCurse2(oPC);
        return;
    }

    EndDlg();
}
void handlePageMain(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEMAIN, oPC);
        dlgDebug("Page main nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                EndDlg();
                return;
        }

    // Tell me about deity
        if (nChoice == 1) {
                buildPageInfo(oPC);
                return;
        }

    // I wish to follow deity
        if (nChoice == 2) {
                buildPageFollow(oPC);
                return;
        }

    // I wish to serve deity
        if (nChoice == 3) {
                buildPageServe(oPC);
                return;
        }

    // I wish to tithe
        if (nChoice == 4) {
                buildPageTithe(oPC);
                return;
        }

    // start a sub dialog
        if (nChoice == 5) {
                dlgSetSubDlgDone(oPC);
                dlgStartSubDialog(oPC, OBJECT_SELF, GetLocalInt(oPC, "dlg_subdlg_index"));
                return;
        }

    // I wish to be healed
        if (nChoice == 6) {
                buildPageHeal(oPC);
                return;
        }

    // give holy symbol
        if (nChoice == 8) {
                buildPageHolySymbol(oPC);
                return;
        }

     // remove curses
        if (nChoice == 9) {
                buildPageCurse(oPC);
                return;
        }
    // Open the store
        if (nChoice == 7) {
                if (dlgDietyOpenStore(oPC, OBJECT_SELF,  GetLocalInt(oPC, "dlg_did_tithe"))) {
                        EndDlg();
                } else {
            // This is actually an error -
                        buildPageMain(oPC);
                        return;
                }
        }
  
        // return to original dialog
        if (nChoice == 10 ) {   
                dlgReturnToMainDlg(oPC, OBJECT_SELF);
                return;
        }

        // rezz body
        if (nChoice == 11 ) {   
                buildPageRezz(oPC);
                return;
        }
        EndDlg();
}
void handlePageRezz(object oPC, int nSel) {
        int nChoice = GetIntElement(nSel, PAGEREZZ, oPC);
        dlgDebug("Page main nChoice = " + IntToString(nChoice));

        if (nChoice == -1) {
                buildPageMain(oPC);
                return;
        }

        if (nChoice > 0 && nChoice < 4) {
                int nCost = GetLocalInt(oPC, "TMP_REZZ_COST" + IntToString(nChoice));
        // 1 = Raise dead  - check gold cost
        // 2 = rezz - check gold cost
        // 3 = rezz + items check gold cost
                object oCorpse =   GetLocalObject(oPC, "TEMPLE_REZZ_BODY");

                // Check for gold and if not enough go to page no gold.
                if (GetGold(oPC) < nCost) {
                        buildPageNoGold(oPC);
                } else if (!GetIsObjectValid(oCorpse)) {
                        // back to page rezz should generate the stop wasting my time
                        buildPageRezz(oPC);
                        return;
                } else {
                // else take gold and do apporpriate level of rezz.
                        TakeGoldFromCreature(nCost, oPC, TRUE);
                        // TODO hook this up to corpse code for rezzing. 
                        int nRet; 
			int nSpell = SPELL_RAISE_DEAD;
			if (nChoice > 1) 
				nSpell = SPELL_RESURRECTION;
                        // = deathDoRezz(oCorpse, oPC, OBJECT_SELF, nChoice);
			nRet = SpellRaiseCorpse(oCorpse, nSpell, GetLocation(oPC), OBJECT_SELF);
                        buildPageRezzDone(oPC, nRet);
                }
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

    dlgSetDebug();
    int nDeity = GetDeityIndex(OBJECT_SELF);
    SetLocalInt(OBJECT_SELF, "dlg_deity_idx", nDeity);

    if (nDeity < 0)
        dlgDebug("Invalid Deity on " + GetTag(OBJECT_SELF));
    DeleteLocalInt(oPC, "dlg_did_tithe");
    DeleteLocalInt(oPC, "dlg_did_heal");
    DeleteLocalInt(oPC, "dlg_did_curse");
    DeleteLocalInt(oPC, "dlg_did_holysym");

    if (IsSubDlg(OBJECT_SELF)) {
        dlgDebug("Running as subdlg, index now = " + IntToString(SUBDLG_INDEX));
        SetLocalInt(oPC, "dlg_subdlg_index", SUBDLG_INDEX);
    } else {
        DeleteLocalInt(oPC, "dlg_subdlg_index");
    }
    SetLocalInt(oPC, "dlg_has_curse", deityGetHasCurse(oPC));
    SetupDeityConversationTokens(nDeity, TRUE);
    // This should be by class or a variable on the NPC
    if (GetLocalInt(OBJECT_SELF, "ClericLevel") <= 0) {
        int nLevel = GetLevelByClass(CLASS_TYPE_CLERIC, OBJECT_SELF);
        if (nLevel <= 0) nLevel = 17;
        SetLocalInt(OBJECT_SELF, "ClericLevel", nLevel);
    }
    SetLocalString(OBJECT_SELF, "dlg_money_type_string", "gold");


    object oCorpse = deityGetCorpseItem(oPC);
    SetLocalObject(oPC, "TEMPLE_REZZ_BODY", oCorpse);
}

void PageInit() {
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("PAGEINIT: page = " + page);

    // These are special cases
    if(page == "" || page == PAGEGREET) {
        buildPageGreet(oPC, TRUE);
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
    DeleteList(PAGEINFO, oPC);
    DeleteList(PAGEHEAL, oPC);
    DeleteList(PAGEHEAL2, oPC);
    DeleteList(PAGECURSE, oPC);
    DeleteList(PAGECURSE2, oPC);
    DeleteList(PAGESERVE, oPC);
    DeleteList(PAGESERVE2, oPC);
    DeleteList(PAGETITHE, oPC);
    DeleteList(PAGETITHE2, oPC);
    DeleteList(PAGEFOLLOW, oPC);
    DeleteList(PAGEHOLYSYM, oPC); 
    DeleteList(PAGEREZZ, oPC);
    DeleteList(PAGEREZZDONE, oPC);

    // delete any variables
    DeleteLocalInt(OBJECT_SELF, "dlg_deity_idx");
    DeleteLocalInt(oPC, "dlg_did_tithe");
    DeleteLocalInt(oPC, "dlg_did_heal");
    DeleteLocalInt(oPC, "dlg_did_curse");
    DeleteLocalInt(oPC, "dlg_did_holysym");
    DeleteLocalInt(oPC, "_cur_tithe_amount");
    DeleteLocalInt(oPC, "_cur_heal_amount");
    DeleteLocalInt(oPC, "dlg_has_curse");
    DeleteLocalInt(oPC, "TMP_REZZ_COST1");
    DeleteLocalInt(oPC, "TMP_REZZ_COST2");
    DeleteLocalInt(oPC, "TMP_REZZ_COST3");
    DeleteLocalObject(oPC, "TEMPLE_REZZ_BODY");
    
    ClearDeityConversationVariables();
}

void HandleSelection() {
    int nSel = GetDlgSelection();
    string page = GetDlgPageString();
    object oPC = GetPcDlgSpeaker();
    dlgDebug("HANDLE : Got page = " + page + " nsel = " + IntToString(nSel));
    if (page == "") page = PAGEGREET;

    if(page == PAGEMAIN) {
        handlePageMain(oPC, nSel);
        return;
    }
    if(page == PAGESERVE) {
        handlePageServe(oPC, nSel);
        return;
    }
    if(page == PAGETITHE) {
        handlePageTithe(oPC, nSel);
        return;
    }
    if(page == PAGEHEAL) {
        handlePageHeal(oPC, nSel);
        return;
    }
    if(page == PAGECURSE) {
        handlePageCurse(oPC, nSel);
        return;
    } 

    if(page == PAGEREZZ) {
        handlePageRezz(oPC, nSel);
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
