//::///////////////////////////////////////////////
//:: _dlg_corpse
//:://////////////////////////////////////////////
/*
    Corpse Dialog

    Z-Dialog Script for a Corpse

*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 july 7)
//:: Modified:
//:://////////////////////////////////////////////

#include "zdlg_include_i"

#include "_inc_constants"
#include "_inc_util"
#include "_inc_nwnx"
#include "_inc_corpse"

// Constants
const string PAGE_START         = "start";
const string PAGE_ELSE          = "else";

// Globals (fake constants)

// DECLARATIONS
// custom

// Zdlg
void Init();
void PageInit();
void CleanUp();
void HandleSelection();

// IMPLEMENTATION
// custom ----------------------------------------------------------------------

void TakeBody(object oPC);

void TakeBody(object oPC)
{
    SetLocalInt(OBJECT_SELF,"TAKEN",TRUE);

    // Destroy body (this is the pretty/dressed corpse)
    object oCorpse      = GetLocalObject(OBJECT_SELF, "CORPSE_BODY");
    StripInventory(oCorpse);
    AssignCommand(oCorpse,SetIsDestroyable(TRUE,FALSE,FALSE));
    DestroyObject(oCorpse, 0.1);

    //Delete paired objects - bloodstain
    DestroyObject(GetLocalObject(OBJECT_SELF,"PAIRED"), 12.0);

    // create Corpse Item (carryable) on the PC taker
    object oCorpseItem  = CreateCorpseItemFromCorpseNode(OBJECT_SELF, oPC);

    // Store corpse location as being the PC taker
    NWNX_CorpseSaveLocationToTaker(oPC, oCorpseItem);

    // wipe out corpse node inventory since it no longer matters
    SetLocalInt(OBJECT_SELF,"SUPPRESS_DISTURB",TRUE);   // disturb event unnecessary during init
    StripInventory(OBJECT_SELF);

    // cleanup persistent inventory
    object oInventory   = GetLocalObject(OBJECT_SELF,"PERSISTENT_INVENTORY");

    if(GetIsObjectValid(oInventory))
        SignalEvent(oInventory, EventUserDefined(EVENT_GARBAGE_COLLECTION));

    // destroy the corpse node
    DestroyObject(OBJECT_SELF, 0.4);
}

// ZDLG ------------------------------------------------------------------------
void Init()
{
    if(GetLocalInt(OBJECT_SELF,"TAKEN"))
        return;

    object oPC          = GetPcDlgSpeaker();

    SetLocalString(oPC, "ZDLG_END", "[Nothing. Let it be.]");
    SetShowEndSelection( TRUE );

    // General List
    string sUser    = GetLocalString(OBJECT_SELF, "IN_USE_BY");
    if(sUser=="")
    {
        SetLocalString(OBJECT_SELF, "IN_USE_BY", GetName(oPC));
        if(!GetLocalInt(oPC, "IN_CONV"))
        {
            SetDlgPageString(PAGE_START);
            SetLocalInt(oPC, "IN_CONV", TRUE);
        }
    }
    else
        SendMessageToPC(oPC, PINK+GetName(OBJECT_SELF)+RED+" is currently occupied with "+PINK+sUser+RED+".");
}

void PageInit()
{
    string sPage    = GetDlgPageString();

    object oPC      = GetPcDlgSpeaker();
    object oHolder  = oPC;

    string sPrompt;

    // Generate fresh response list
    DeleteList( sPage, oHolder );
    string conv_id  = ObjectToString(OBJECT_SELF);
    int bLooted     = GetLocalInt(oPC,"CONV_LOOTED"+conv_id);
    string sReply   = GetLocalString(oPC,"CONV_REPLY"+conv_id);
    if(sReply=="")
        sReply  = "Done!.";

    sReply += BR+BR;


    // Initialize prompt and responses
    if( sPage==PAGE_START || sPage==PAGE_ELSE )
    {
      if(sPage==PAGE_START)
        sPrompt =
             "What would you like to do with "+GetName(OBJECT_SELF)+"?"
            ;
      else
        sPrompt =
                    sReply
                   +"What else would you like to do?"
                   ;

        if(GetLocalInt(GetModule(),"PC_CORPSE_LOOTABLE") &&  !bLooted) {
            AddStringElement( "[Loot the body.]", sPage, oHolder );
        }

        AddStringElement( "[Carry the body.]", sPage, oHolder );
    }

    // Set Prompt and Response List ............................................
    SetDlgPrompt( sPrompt );
    SetDlgResponseList( sPage, oHolder );
}

void CleanUp()
{
    object oPC = GetPcDlgSpeaker();
    DeleteLocalInt(oPC, "IN_CONV");
    DeleteLocalString(OBJECT_SELF, "IN_USE_BY");

    string conv_id  = ObjectToString(OBJECT_SELF);
    DeleteLocalInt(oPC,"CONV_LOOTED"+conv_id);
    DeleteLocalString(oPC,"CONV_REPLY"+conv_id);
}

void HandleSelection()
{
  object oPC    = GetPcDlgSpeaker();
  object oHolder= oPC;
  object oBody  = OBJECT_SELF;
  string sPage  = GetDlgPageString();
  int nSelect   = GetDlgSelection();
  string sSelect= GetStringElement( nSelect, sPage, oPC);
  string sReply;
  string conv_id= ObjectToString(OBJECT_SELF);

    if(sSelect=="[Loot the body.]")
    {
        if(GetIsObjectValid(GetFirstItemInInventory()))
        {
            SetLocalInt(OBJECT_SELF, "CONVERSATION_SUPRESSED", TRUE);
            AssignCommand(oPC, ActionInteractObject(oBody));
            EndDlg();
        }
        else
        {
            sReply  = GetName(OBJECT_SELF)+" has nothing left to take.";
            SetLocalInt(oPC,"CONV_LOOTED"+conv_id,TRUE);
        }
    }
    else if(sSelect=="[Carry the body.]")
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_GET_LOW,1.0,3.0) );
        TakeBody(oPC);
        EndDlg();
    }

    SetLocalString(oPC,"CONV_REPLY"+conv_id,sReply);
    SetDlgPageString(PAGE_ELSE);

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
