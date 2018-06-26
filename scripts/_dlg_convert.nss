//::///////////////////////////////////////////////
//:: _dlg_convert
//:://////////////////////////////////////////////
/*
    Z-Dialog Script for the Convert ability

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 19)
//:: Modified:
//:://////////////////////////////////////////////

#include "x3_inc_skin"

#include "zdlg_include_i"
#include "deity_include"
#include "nbde_inc"

#include "_inc_constants"
#include "_inc_util"
#include "_inc_deity"

// Constants
const string PAGE_START     = "convert_start";
const string PAGE_YES       = "convert_yes";
const string PAGE_CONVERT   = "converted";


// DECLARATIONS
// custom

string GetReligion(object oPC);

string ConvertShallow(object oPC, object oPriest);

string ConvertDeep(object oPC, object oPriest);

void TrackConversion(object oPC, object oPriest, int nConvert);

// Zdlg
void Init();
void PageInit();
void CleanUp();
void HandleSelection();

// IMPLEMENTATION
// custom ----------------------------------------------------------------------
string GetReligion(object oPriest)
{
    int nDeity  = GetDeityIndex(oPriest);
    switch(nDeity)
    {
        case  0: return "Do you renounce all faiths, creeds, and gods?"; // Undevoted
        case  1: return "Do you recognize Nature as the primal force?"; // Nature
        case  2: return "Will you pursue The Mystery?"; // The Mystery
        case  3: return "Will you devote yourself to The Faith?"; // The Faith (general)
        case  4: return "Will you devote yourself to The Faith with Apriana as your divine Patron?"; // The Faith (apriana)
        case  5: return "Will you devote yourself to The Faith with Aurelia as your divine Patron?"; // The Faith (aurelia)
        case  6: return "Will you devote yourself to The Faith with Barnabus as your divine Patron?"; // The Faith (barnabus)
        case  7: return "Will you devote yourself to The Faith with Cagli as your divine Patron?"; // The Faith (cagli)
        case  8: return "Will you devote yourself to The Faith with Cosm as your divine Patron?"; // The Faith (cosm)
        case  9: return "Will you devote yourself to The Faith with Cyriacus as your divine Patron?"; // The Faith (cyriacus)
        case 10: return "Will you devote yourself to The Faith with Kester as your divine Patron?"; // The Faith (kester)
        case 11: return "Will you devote yourself to The Faith with Kilili as your divine Patron?"; // The Faith (kilili)
        case 12: return "Will you devote yourself to The Faith with Maia as your divine Patron?"; // The Faith (maia)
        case 13: return "Will you devote yourself to The Faith with Orcus as your divine Patron?"; // The Faith (orcus)
        case 14: return "Will you devote yourself to The Faith with Veneros as your divine Patron?"; // The Faith (veneros)
        case 15: return "Will you worship all the gods as a Polytheist?"; // Polytheist(general)
        case 16: // Polytheist- alignment - begin
        case 17:
        case 18:
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
        case 24: return "Will you devote yourself to and worship "+GetDeityTitle(nDeity)+"?"; // Polytheist- alignment
        case 25: // Polytheist- single god - begin
        case 26:
        case 27:
        case 28:
        case 29:
        case 30:
        case 31:
        case 32:
        case 33:
        case 34:
        case 35: return "Will you worship "+GetDeityTitle(nDeity)+" above all other gods?"; // Polytheist- single god
        default: return "Will you devote yourself to "+GetDeityTitle(nDeity)+"?"; // default
    }
    return "";
}

string ConvertShallow(object oPC, object oPriest)
{
    string sConvert = "Done.";
    int nDeity      = GetDeityIndex(oPriest);
    int nParent     = GetDeityParent(nDeity);

    // an actual conversion?
    if(GetDeityIndex(oPC)!=nParent)
        TrackConversion(oPC, oPriest, nParent);

    SetDeity(oPC, GetDeityName(nParent));
    return sConvert;
}

string ConvertDeep(object oPC, object oPriest)
{
    // initialize data
    string sConvert = "Done.";

    // new deity
    int nDeity      = GetDeityIndex(oPriest);

    // an actual conversion?
    if(GetDeityIndex(oPC)!=nDeity)
        TrackConversion(oPC, oPriest, nDeity);

    SetDeity(oPC, GetDeityName(nDeity));

    return sConvert;
}

void TrackConversion(object oPC, object oPriest, int nConvert)
{
    // init data ------------------------------
    // old deity
    int nCurDeity   = GetDeityIndex(oPC);
    int nCurParent  = GetDeityParent(nCurDeity);
    string sCurDeity= GetDeityName(nCurDeity);
    // priest deity
    int nDeity      = GetDeityIndex(oPriest);
    int nParent     = GetDeityParent(nDeity);
    // name of religion converted to
    string sDeity   = GetDeityName(nConvert);

    int nCount;


    // increment conversion count for PC ---------------------------------------
    NBDE_SetCampaignInt(    CAMPAIGN_NAME,
                                "CONVERSIONS",
                                (1 + NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERSIONS", oPC)),
                                oPC
                           );

    // OLD DEITY LOSES A FOLLOWER ----------------------------------------------
    // get last priest to convert PC, and decrement their tally of converts
    string sLast    = NBDE_GetCampaignString(CAMPAIGN_NAME, "CONVERTED_BY", oPC);
    if(sLast!="")
    {
        nCount  = NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERTS"+sLast) - 1;
        if(nCount<0){nCount = 0;}
        NBDE_SetCampaignInt(    CAMPAIGN_NAME,
                                    "CONVERTS"+sLast,
                                    nCount
                                );
    }
    // decrement convert count on old deity
    nCount  = NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERTS_DEITY_"+sCurDeity) - 1;
    if(nCount<0){nCount = 0;}
    NBDE_SetCampaignInt(CAMPAIGN_NAME,
                            "CONVERTS_DEITY_"+sCurDeity,
                            nCount
                           );

    // NEW DEITY GAINS A FOLLOWER ----------------------------------------------
    // increment the convert tally for this priest
    string sPriest  = GetPCID(oPriest);
    if(sPriest!="")
    {
        NBDE_SetCampaignInt(    CAMPAIGN_NAME,
                                    "CONVERTS"+sPriest,
                                    (NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERTS"+sPriest)+1)
                                );
        // flag PC as converted by oPriest
        NBDE_SetCampaignString(CAMPAIGN_NAME, "CONVERTED_BY", sPriest, oPC);
    }
    // increment convert count for new deity
    NBDE_SetCampaignInt(CAMPAIGN_NAME,
                            "CONVERTS_DEITY_"+sDeity,
                            (NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERTS_DEITY_"+sDeity)+1)
                           );

    string sParent      = GetDeityName(nParent);
    string sCurParent   = GetDeityName(nCurParent);

    // is this a change to a new parent religion?
    if(nParent!=nCurParent)
    {
            // increment convert count for new religion/parent
            NBDE_SetCampaignInt(CAMPAIGN_NAME,
                                    "CONVERTS_RELIGION_"+sParent,
                                    (NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERTS_RELIGION_"+sParent)+1)
                                   );
            // decrement convert count for old religion/parent
            nCount  = NBDE_GetCampaignInt(CAMPAIGN_NAME, "CONVERTS_RELIGION_"+sCurParent) - 1;
            if(nCount<0){nCount = 0;}
            NBDE_SetCampaignInt(CAMPAIGN_NAME,
                                    "CONVERTS_RELIGION_"+sCurParent,
                                    nCount
                                   );
    }

    // FEEDBACK TO PRIEST AND DMs///////////////////////////////////////////////
    string sName    = GetName(oPC);
    string sFeedback;
    // is this conversion to a specific sect of a religious supergroup? -------------------------
    if(nParent!=nConvert)
    {
        // is this a change to a new parent religion?
        if(nParent!=nCurParent)
        {
            // substantial change
            sFeedback   = " commits to "+GetDeityTitle(nConvert)+".";
        }
        // special case -- polytheism.
        else if(sParent=="Polytheist")
        {
            // still considered a substantial change
            sFeedback   = " commits to worshipping "+GetDeityTitle(nConvert)+".";
        }
        // shifting around within the same religion
        else
        {
            // minor change
            sFeedback   = " commits to "+GetDeityTitle(nConvert)+".";
        }
    }
    // converted to a religious supergroup (parent religion)
    else
    {
        // Deep -- religious group and sect are the same
        if(nParent==nDeity)
        {
            sFeedback   = " commits to "+GetDeityTitle(nConvert)+".";
        }
        // Shallow -- converted to religous super group although a specific sect was offered
        else
        {
            if(sParent=="Polytheist")
            {
                // most shallow -- rejected worship of a deity
                sFeedback   = " converts to Polytheism, but not to the worship of "+GetDeityTitle(nDeity)+".";
            }
            else
            {
                sFeedback   = " commits to "+GetDeityTitle(nConvert)+", but not to "+GetDeityTitle(nDeity)+".";
            }
        }
    }
    SendMessageToPC(oPriest, GREEN+sName+LIME+sFeedback);
    SendMessageToAllDMs(DMBLUE+"CONVERSION: "+GREEN+GetName(oPriest)+DMBLUE+" converts "+GREEN+sName+DMBLUE+".");
    SendMessageToAllDMs(DMBLUE+"CONVERSION: "+GREEN+sName+DMBLUE+sFeedback);
    WriteTimestampedLogEntry("RELIGION: "+sName+sFeedback);
}

// ZDLG ------------------------------------------------------------------------
void Init()
{
    object oPC          = GetPcDlgSpeaker();

    //SetLocalString(oPC, "ZDLG_END", "[Reject the Atonement.]");
    //SetShowEndSelection( TRUE );

    // General List
    if(!GetLocalInt(oPC, "IN_CONV"))
    {
        SetDlgPageString(PAGE_START);

        SetLocalInt(oPC, "IN_CONV", TRUE);
    }
}

void PageInit()
{
    string sPage    = GetDlgPageString();

    object oPC      = GetPcDlgSpeaker();
    object oHolder  = oPC;

    string sPrompt;

    // Generate fresh response list
    DeleteList( sPage, oHolder );

    object oPriest  = GetLocalObject(oPC,"CONVERSION_PRIEST");
    int nDeity      = GetDeityIndex(oPriest);
    // Initialize prompt and responses
    // TEACHER CONVERSATION ----------------------------------------------------
    if( sPage==PAGE_START )
    {
        string sReligionQuestion    = GetDeityConvertQuestion(nDeity);
        if(sReligionQuestion=="")
            sReligionQuestion       = "Will you devote yourself to and worship "+GetDeityTitle(nDeity)+"?";

        sPrompt =   GREEN+GetName(oPriest)+LIME+" offers you the opportunity to convert..."+BR
                    +BR
                    +WHITE+sReligionQuestion
            ;

        AddStringElement( "[Yes.]", sPage, oHolder );  // ExecuteScript("v2_ex_animpray", oPC);
        AddStringElement( "[No.]", sPage, oHolder );
    }
    else if( sPage==PAGE_YES )
    {


        sPrompt =   "How deep is your devotion?"+BR
                    +BR
                    +"A "+Q+"Deep"+Q+" conversion is one in which you fully adopt"
                    +" "+GetName(oPriest)+"'s religion, and sect as your own."+BR
                    +BR
                    +"A "+Q+"Shallow"+Q+" conversion is an adoption of the basic beliefs"
                    +" of "+GetDeityTitle(GetDeityParent(nDeity))+"."
            ;

        AddStringElement( "[Deep.]", sPage, oHolder );
        AddStringElement( "[Shallow.]", sPage, oHolder );
    }
    else if( sPage==PAGE_CONVERT )
    {
        sPrompt = GetLocalString(oPC, "CONVERSION_MESSAGE")
            ;

        AddStringElement( "[End.]", sPage, oHolder );
    }


    // Set Prompt and Response List ............................................
    SetDlgPrompt( sPrompt );
    SetDlgResponseList( sPage, oHolder );
}

void CleanUp()
{
    object oPC = GetPcDlgSpeaker();
    DeleteLocalInt(oPC, "IN_CONV");

    if(GetLocalString(oPC, "CONVERSION_MESSAGE")=="")
        SendMessageToPC(GetLocalObject(oPC, "CONVERSION_PRIEST"),
                        GREEN+GetName(oPC)+LIME+" does not convert."
                       );

    DeleteLocalObject(oPC, "CONVERSION_PRIEST");
    DeleteLocalString(oPC, "CONVERSION_MESSAGE");
}

void HandleSelection()
{
  object oPC    = GetPcDlgSpeaker();
  object oHolder= oPC;
  string sPage  = GetDlgPageString();
  int nSelect   = GetDlgSelection();
  string sSelect= GetStringElement( nSelect, sPage, oPC);

  object oPriest= GetLocalObject(oPC, "CONVERSION_PRIEST");
  int nDeity    = GetDeityIndex(oPriest);
  int nParent   = GetDeityParent(nDeity);

    if(sSelect=="[Yes.]")
    {
        ExecuteScript("v2_ex_animpray", oPC);

        if(nParent && nParent!=nDeity)
            SetDlgPageString(PAGE_YES);
        else
        {
            SetLocalString(oPC, "CONVERSION_MESSAGE", ConvertDeep(oPC, oPriest));
            SetDlgPageString(PAGE_CONVERT);
        }
    }
    else if(sSelect=="[Shallow.]")
    {
        SetLocalString(oPC, "CONVERSION_MESSAGE", ConvertShallow(oPC, oPriest));
        SetDlgPageString(PAGE_CONVERT);
    }
    else if(sSelect=="[Deep.]")
    {
        SetLocalString(oPC, "CONVERSION_MESSAGE", ConvertDeep(oPC, oPriest));
        SetDlgPageString(PAGE_CONVERT);
    }
    else if(sSelect=="[No.]" || sSelect=="[End.]")
    {
        EndDlg();
    }
}

// MAIN ------------------------------------------------------------------------
void main()
{
    object oSelf    = OBJECT_SELF;

    int iEvent = GetDlgEventType();
    switch( iEvent )
    {
        case DLG_INIT:
            Init();
        break;
        case DLG_PAGE_INIT:
            PageInit();
        break;
        case DLG_SELECTION:
            HandleSelection();
        break;
        case DLG_ABORT:
        case DLG_END:
            // We do the same thing on abort or end
            CleanUp();
        break;
    }
}
