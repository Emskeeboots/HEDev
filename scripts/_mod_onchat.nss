//::///////////////////////////////////////////////
//:: _mod_onchat
//:://////////////////////////////////////////////
/*
    SCRIPT HANDLING PLAYER CHATTING

    extension of q_acp_onchat
        from Project Q
        Website: http://www.qnwn.net
        Contact: projectq@qnwn.net

    Custom Modifications added:
    Dungeon Master Friendly Initiative (DMFI) by Hahnsoo and Tsunami
    Ambiguous Interactive Dungeons (AID) by Layonara Team and modified by The Magus
*/
//:://////////////////////////////////////////////
//:: Created By: thurgood (17 August 2009)
//:: Modified  : The Magus (2011 dec 7)
//:: Modified  : The Magus (2011 dec 29)integration of AID and DMFI
//:://////////////////////////////////////////////

#include "_inc_util"
#include "_inc_nwnx"
#include "_inc_pets"

// rewritten dmfi_plychat_exe to work as include
// much DMFI code and AID code pasted into Main of this script
// Why?  it's better code as an exe... 
#include "dmfi_plychat_fnc"

// ACP (Alt Combat Phenotypes) Include
#include "q_inc_acp"

// GLOBALS /////////////////////////////////////////////////////////////////////
int bFail = FALSE;// used to determine if a command failed
string sErr = ""; // a special failure message

// FUNCTIONS DECLARED //////////////////////////////////////////////////////////
// determines the first word. between the "/" and " "       [File: _mod_onchat]
string GetCommand(string sText);
// responds to dispel command                               [File: _mod_onchat]
void DoDispel(string sText, object oPC);
// responds to style command                                [File: _mod_onchat]
void DoStyle(string sText, object oPC);
// responds to item command                                 [File: _mod_onchat]
void DoItem(string sText, object oPC);
// responds to addcdkey command                             [File: _mod_onchat]
void DoCDKey(object oPC);
// responds to dm_wipecdkey command                         [File: _mod_onchat]
void DoWipeCDKey(string sMessage, object oPC);
// responds to dm_listpcs command                           [File: _mod_onchat]
void DoListPCs(object oPC);
// responds to language command                             [File: _mod_onchat]
void DoLanguages(string sText, object oPC);
// responds to set command - taken from DMFI .set           [File: _mod_onchat]
void SetChatTarget(string sText, object oCommander, object oTarget);
// responds to aid command - taken from AID                 [File: _mod_onchat]
void DoAIDCommand(string sText, object oTarget);
// responds to help command                                 [File: _mod_onchat]
void DoHelp(string sText, object oPC);
// modifies speach for charaters that can not speak         [File: _mod_onchat]
string AlterSpeach(string sText, object oTarget, int nVolume, object oPC, int nAlt);

// FUNCTIONS IMPLEMENTED ///////////////////////////////////////////////////////

// determines the first word. between the "/" and " "
string GetCommand(string sText)
{
    string sP   = " ";
    int nLen    = GetStringLength(sText);
    int n1      = FindSubString(sText, sP);

    if(nLen == 1)
        return "";
    else if (n1==-1)
        return GetStringRight(sText,nLen-1);
    else
        return GetSubString(sText,1,n1-1);
}

// responds to dispel command
void DoDispel(string sText, object oPC)
{
    int nScrying    = GetLocalInt(oPC, "SCRYING");
//    if(GetStringLength(sText)<=8)
//    {
        if(nScrying)
        {
            EndScrying(oPC);
        }
        else
        {
            // Remove all effects created by oPC on self
            int bDispelled, nSpellId;

            effect eEffect = GetFirstEffect(oPC);

            while(GetIsEffectValid(eEffect))
            {
                if( GetEffectCreator(eEffect)==oPC)
                {
                    nSpellId    =  GetEffectSpellId(eEffect);
                    //if(nSpellId > -1 && nSpellId != SPELL_FAMILIAR_EFFECTS)
                    {
                        RemoveEffect(oPC, eEffect);
                        bDispelled  = TRUE;
                    }
                }
                eEffect = GetNextEffect(oPC);
            }

            if(bDispelled)
                SendMessageToPC(oPC, DMBLUE+"Spells cancelled.");
        }
//    {
//    else
//    {


//    }
}

// responds to style command
void DoStyle(string sText, object oPC)
{
    if(GetStringLength(sText)<=GetStringLength(Q_ACP_KEYWORD)+2)
    {
      // single word. list styles.
      SendMessageToPC(oPC, " ");
      FloatingTextStringOnCreature(RED+"STYLE CHAT COMMAND",oPC, FALSE);
      if(GetSkinString(oPC, "PHENOTYPE_NATURAL_NAME")=="large")
      {
        SendMessageToPC(oPC, PINK+"You are playing a large phenotype character."
            +" The alternate combat style animations were not made for the large phenotype"
            +" and the developer of this module did not have the ability (or time) to make"
            +" the adaptation. If they become available in Project Q, we will update the module"
            +" to work with them. Until that happens the style command will be unavailable to your character."
        );
        SendMessageToPC(oPC, " ");
      }
      else
      {
        string sDefault=GetSkinString(oPC, "PHENOTYPE_DEFAULT_NAME");
        SendMessageToPC(oPC, PINK+"To change combat styles enter "+YELLOW+"/style"+PINK+" followed by the name of the combat style."
                        +" Example: "+YELLOW+"/style warrior");
        SendMessageToPC(oPC, PINK+"Your default style is currently "+RED+sDefault+PINK+".");
        SendMessageToPC(oPC, PINK+"The following styles are also available to you:");
        SendMessageToPC(oPC, YELLOW+"normal "+PINK+"Return to normal animations.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_KENSAI_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"kensai "+PINK+"Ancient sword art using one or two hands.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_ASSASSIN_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"monkey grip "+PINK+"Reversed grip on one handed weapons.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_HEAVY_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"heavy "+PINK+"Two weapon melee animations.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_FENCING_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"fencing "+PINK+"Sword style with upright, side stance.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_WARRIOR_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"warrior "+PINK+"One weapon melee animations.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_MUAY_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"tiger fang "+PINK+"Unarmed strike with cat stance and boxer's defense.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_SHOTO_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"sun fist "+PINK+"Unarmed strike with wide stance and upward facing palm.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_SHAO_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"dragon palm "+PINK+"Unarmed strike with sharp chops and kicks.");
        if(GetSkinInt(oPC, Q_ACP_KNOWN+Q_ACP_HUNG_STRING) || MODULE_DEVELOPMENT_MODE)
            SendMessageToPC(oPC, YELLOW+"bear claw "+PINK+"Unarmed strike with low crouch, and hand rakes.");
        SendMessageToPC(oPC, " ");
      }
    }
    else
        Q_ACPCheckChat(oPC, GetStringRight(sText, GetStringLength(sText)-1) );
}

// responds to item command
void DoItem(string sText, object oPC)
{
    if(GetStringLength(sText)<=GetStringLength("/item")+1)
    {
      // single word. list items.
      SendMessageToPC(oPC, " ");
      FloatingTextStringOnCreature(RED+"ITEM CHAT COMMAND",oPC, FALSE);
      SendMessageToPC(oPC, PINK+"To create or destroy special (undroppable) items in your inventory enter "+YELLOW+"/item"+PINK+" followed by the name of the special item."
                        +" Example: "+YELLOW+"/item manual");
      SendMessageToPC(oPC, PINK+"Special items include the following:");
      SendMessageToPC(oPC, YELLOW+"manual"+PINK+" Create or destroy a player's manual which describes chat commands.");
      SendMessageToPC(oPC, YELLOW+"backpack"+PINK+" Create or destroy a wearable, but non-functional backpack.");

      SendMessageToPC(oPC, " ");
    }
    else
    {
        string sRef     = "";
        string sItem    = GetStringRight(sText, GetStringLength(sText)-6);
        if(GetStringLeft(sItem,6)=="manual")
            sRef="spc_manual";
        else if(GetStringLeft(sItem,8)=="backpack")
            sRef="spc_backpack";
        if(sRef=="")
            return;
        // declare vars
        object oItem;
        int bFound  = FALSE;

        // look at cloak slot
        oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
        if (GetResRef(oItem)==sRef)
        {
            bFound = TRUE;
            DestroyObject(oItem, 0.01);
        }

        oItem = GetFirstItemInInventory(oPC);
        while(GetIsObjectValid(oItem))
        {
            if (GetResRef(oItem)==sRef)
            {
                bFound = TRUE;
                DestroyObject(oItem, 0.01);
                break;
            }
            oItem = GetNextItemInInventory(oPC);
        }
        if(!bFound)
            oItem = CreateItemOnObject(sRef,oPC,1,sRef);

    }
}

// responds to dm_wipecdkey command
// TODO - this is not implemented for SQL
void DoWipeCDKey(string sMessage, object oPC)
{
    if (!GetIsDM(oPC))
    {
        if(MODULE_DEBUG_MODE)
            FloatingTextStringOnCreature(RED+"Command restricted!", oPC, FALSE);
        bFail = TRUE;
    }
    else
    {
        string sPlayerName = GetStringRight(sMessage, GetStringLength(sMessage)-13);
        string sStoredKey = NBDE_GetCampaignString(PLAYER_DATA, sPlayerName);
        if (sStoredKey != "")
        {
            NBDE_DeleteCampaignString(PLAYER_DATA, sPlayerName);
            FloatingTextStringOnCreature(LIGHTBLUE+"CD Key bindings for Playername: '" +YELLOW+ sPlayerName +LIGHTBLUE+ "' erased.", oPC, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature(RED+"No CD Key bindings for Playername: '" +YELLOW+ sPlayerName +RED+
                "' were found! Please check to make sure you entered the right name.", oPC, FALSE);
        }
    }
}

// responds to dm_listpcs command
void DoListPCs(object oPC)
{
    if(     !GetIsDM(oPC)
        //&&  !GetIsCPC(oPC)
        &&  !MODULE_DEVELOPMENT_MODE
      )
    {
        bFail = TRUE;
    }
    else
    {
        SendMessageToPC(oPC, " ");
        FloatingTextStringOnCreature(BLUE+"TYPE"+LIGHTBLUE+"  PLAYER (CHARACTER) "+LIME+"AREA", oPC, FALSE);
        object oPlayer = GetFirstPC();
        int nIt = 0;
        string sMessage;
        while(GetIsObjectValid(oPlayer))
        {   nIt++;

            if(GetIsDM(oPlayer))
                sMessage = BLUE+"DM  ";
            //else if(GetIsCPC(oPlayer))
            //    sMessage = BLUE+"CPC ";
            else
                sMessage = BLUE+"PC  ";
            sMessage += LIGHTBLUE+GetPCPlayerName(oPlayer)+ " ("+GetName(oPlayer)+")";



            sMessage +="  "+LIME+GetName(GetArea(oPlayer));

            SendMessageToPC(oPC, sMessage);
            oPlayer = GetNextPC();
        }
        if(nIt<1)
            SendMessageToPC(oPC, RED+"No players.");

    }
}

void DoLanguages(string sText, object oPC)
{
    int nSpace  = FindSubString(sText, " ");
    if( nSpace == -1 )
    {
        // single word. list languages.
        SendMessageToPC(oPC, " ");
        FloatingTextStringOnCreature(RED+"LANGUAGE CHAT COMMAND",oPC, FALSE);
        SendMessageToPC(oPC, PINK+"To change the language you currently speak, enter "+YELLOW+"/language"+PINK+" followed"
                        +" by the name of a language that you know. (only the first 3 letters are necessary)"
                        +" Example: "+YELLOW+"/language gob"+PINK+" for Goblin.");
        ListKnownLanguages(oPC);
        SendMessageToPC(oPC, " ");
    }
    else
    {
        // Change language
        int nLen    = GetStringLength(sText);
        string sLan = GetStringLeft(GetStringRight(sText,nLen-(nSpace+1)),3);
        int nLan    = GetLanguageID(sLan);
        SetCurrentLanguageSpoken(oPC, nLan);
    }
}

void SetChatTarget(string sText, object oCommander, object oTarget)
{
    string sChar;
    sText   = GetStringRight(sText,GetStringLength(sText)-4);
    object oMaster  = GetMaster(oCommander);
    if(oMaster==OBJECT_INVALID)
        oMaster = oCommander;

    while (sText != "")
    {
        sChar   = GetStringLeft(sText, 1);
        if(     FindSubString(CHAT_KEY, sChar )!=-1
            ||  GetIsAlphanumeric(sChar)
          )
            sText = GetStringRight(sText, GetStringLength(sText)-1);
        else
        {
            if(GetIsDM(oTarget))
            {
                if(oCommander!=oTarget)
                {
                    SendMessageToPC(oCommander, RED+"You may not target another DM.");
                    return;
                }
                oTarget = GetLocalObject(oMaster, "dmfi_VoiceTarget");
                if(!GetIsObjectValid(oTarget))
                {
                    SendMessageToPC(oCommander, RED+"Your voice target is invalid.");
                    return;
                }
            }
            else if(GetIsDMPossessed(oTarget))
            {
                if(oTarget!=GetLocalObject(oMaster,"POSSESSED_CREATURE"))
                {
                    SendMessageToPC(oCommander, RED+GetName(oTarget)+" is possessed by another DM.");
                    return;
                }
            }

            SetLocalObject(oMaster, sChar, oTarget);
            SendMessageToPC(oCommander, DMBLUE+"The Control character for " + GetName(oTarget) + " is " + sChar);
            return;
        }
    }
    SendMessageToPC(oCommander, RED+"Your control character is NOT valid. Perhaps you are using a reserved character such as "+PINK+"/ : , ;");
    return;
}

void DoAIDCommand(string sText, object oTarget)
{
/*
          if (sLeft == "debu")
          {
            if(ALLOW_PC_DEBUG || GetIsDM(oPC))
            {
                if(!GetLocalInt(oPC, "DebugMode"))
                {
                    SetLocalInt(oPC, "DebugMode", 1);
                    SendMessageToPC(oPC, (COLOR_MESSAGE + sDebugMode1 + COLOR_END));
                }
                else
                {
                    SetLocalInt(oPC, "DebugMode", 0);
                    SendMessageToPC(oPC, (COLOR_MESSAGE + sDebugMode2 + COLOR_END));
                }
            }
            else
            {
                sErr    = PINK+"The command "+YELLOW+"/debug"+PINK+" which toggles AID debug mode will only work when the module is in debug mode.";
                bFail   = TRUE;
            }
          }
          else
          {
            int iDMNewInt;
            string sDMObject;   // DM handling, which object is being edited
            string sDMVar;      // DM handling, which var on that object?
            string sDMNewString;// DM handling, set var to this
            string sTempString; // used for convenience in DM handling
            object oDMObject;   // DM handling

            // Gather data for DM IG variable manipulation
            // Find the break between the first word and the rest
            int iLocWordBreak = FindSubString(sChat, " ");
            // Length of first word is that position -1 because the zeroth char is @ and will be dropped
            int iLengthSubString1 = (iLocWordBreak - 1);
            // Set as object/target
            sDMObject = GetSubString(sChat, 1, iLengthSubString1);
            // Find Length of all the rest of the string
            int iLengthSubString2 = GetStringLength(sChat) - (iLocWordBreak + 1);
            // Dump rest of string into this var, will have two words left in it
            sTempString = GetSubString(sChat, (iLocWordBreak+1), iLengthSubString2);
            // find the break between the words in the temp string
            iLocWordBreak = FindSubString(sTempString, " ");
            // take the first one and make it the Var to be adressed. Item var names must be LC.
            sDMVar = GetStringLowerCase(GetSubString(sTempString, 0, iLocWordBreak));
            // Reuse iLengthSubString1 for the length of the third word (second in tempstring)
            iLengthSubString1 = GetStringLength(sTempString) - (iLocWordBreak + 1);
            // Whatevers left is used as the value
            sDMNewString = GetSubString(sTempString, (iLocWordBreak+1), iLengthSubString1);
            // all tags must be LC
            oDMObject = GetNearestObjectByTag(GetStringLowerCase(sDMObject), oPC);

            if (sDMVar == "destroy")
            {
                DestroyObject(oDMObject);
                SendMessageToPC(oPC, (COLOR_OBJECT + sDMObject + COLOR_MESSAGE + sDMDestroy));
            }
            else if (sDMVar == "dmexamine")
            {
                DumpAIDVariables(oPC, oDMObject);
            }
            else if (GetStringLeft(sDMNewString, 1) == "#")
            {
                sDMNewString = GetSubString(sDMNewString, 1, GetStringLength(sDMNewString));
                iDMNewInt = StringToInt(sDMNewString);

                SetLocalInt(oDMObject, sDMVar, iDMNewInt);
                SendMessageToPC(oPC, (COLOR_MESSAGE + sDMSet1 + COLOR_VARNAME + sDMVar + COLOR_MESSAGE + sDMSet3 + COLOR_OBJECT + sDMObject + COLOR_MESSAGE + " to: " + sDMNewString));
            }
            else
            {
                SetLocalString(oDMObject, sDMVar, sDMNewString);
                //feedback
                SendMessageToPC(oPC, (COLOR_MESSAGE + sDMSet1 + COLOR_VARNAME + sDMVar + COLOR_MESSAGE + sDMSet2 + COLOR_OBJECT + sDMObject + COLOR_MESSAGE + " to: " + sDMNewString));
            }
          }
*/
}

// responds to help command
void DoHelp(string sText, object oPC)
{
  if(GetIsPC(oPC))
  {
    SendMessageToPC(oPC, " ");
    FloatingTextStringOnCreature(RED+"PC CHAT COMMANDS",oPC, FALSE);
    SendMessageToPC(oPC, PINK+"Commands consist of a "+YELLOW+"/"+PINK+" followed"
                    +" immediately by a command word. Typically a command word's first 4 letters are sufficient. The following commands are available:");
    SendMessageToPC(oPC, YELLOW+"/help     "+PINK+"List available chat commands.");
    SendMessageToPC(oPC, YELLOW+"/dispel   "+PINK+"(1) Exit current spell mode (eg. scry) or (2) Remove personal spell effects.");
    SendMessageToPC(oPC, YELLOW+"/item     "+PINK+"List of special items a character can create or destroy.");
    SendMessageToPC(oPC, YELLOW+"/lounge   "+PINK+"Enter or exit the OOC lounge.");
    SendMessageToPC(oPC, YELLOW+"/style    "+PINK+"List available combat styles and animations.");
    SendMessageToPC(oPC, YELLOW+"/language "+PINK+"List available languages."); 
    SendMessageToPC(oPC, YELLOW+"/pray "+PINK+"Pray to your Deity.");
    //SendMessageToPC(oPC, YELLOW+"/addcdkey "+PINK+"Tell the server that you want to associate another CD Key with your player account. After you issue this command, you should immediately quit and then log back in with a different CD Key.");
    SendMessageToPC(oPC, " ");
    SendMessageToPC(oPC, RED+"EMOTES");
    SendMessageToPC(oPC, PINK+"Enclosing chat with "+YELLOW+"*"+PINK+" and "+YELLOW+"*"+PINK
                    +" will trigger emote parsing. Some areas have special objects which"
                    +" respond to emoted commands. To search for these objects, "
                    +YELLOW+"*look around*"+PINK+" periodically.");
    SendMessageToPC(oPC, " ");
    SendMessageToPC(oPC, RED+"CHAT PUPPETS");
    SendMessageToPC(oPC, PINK+"You may speak through your associates when you precede"
                    +" a chat with "+YELLOW+","+PINK+" or "+YELLOW+";"+PINK+"."
                    +" Who speaks depends upon the following priorities from left to right:" );
    SendMessageToPC(oPC, YELLOW+"; "+PINK+" - master / familiar / spirit animal / henchman / summon");
    SendMessageToPC(oPC, YELLOW+", "+PINK+" - summon / henchman / spirit animal / familiar / master");
    SendMessageToPC(oPC, " ");
    SendMessageToPC(oPC, RED+"CHAT UTILITIES");
    SendMessageToPC(oPC, YELLOW+"<last     "+PINK+"Repeat last chat line.");
    SendMessageToPC(oPC, YELLOW+"<mem1     "+PINK+"Repeat chat stored in chat slot "+YELLOW+"1"+PINK+".");
    SendMessageToPC(oPC, YELLOW+">mem1     "+PINK+"Store last chat line in chat slot "+YELLOW+"1"+PINK+".");
    SendMessageToPC(oPC, " ");
  }
  if(   GetIsDM(oPC)
    //|| GetIsCPC(oPC)
    || MODULE_DEVELOPMENT_MODE
    )
  {
    SendMessageToPC(oPC, " ");
    FloatingTextStringOnCreature(RED+"CPC CHAT COMMANDS",oPC, FALSE);
    /*
    if(GetIsCPC(oPC))
    {
        SendMessageToPC(oPC, PINK+"Cast Player Characters have the above PC commands available to them,"
                    +" in addition to the following:");
    }
    */
    SendMessageToPC(oPC, YELLOW+"/pclist     "+PINK+"List players logged in.");
    SendMessageToPC(oPC, " ");
  }
  if(GetIsDM(oPC))
  {
    SendMessageToPC(oPC, " ");
    FloatingTextStringOnCreature(RED+"DM CHAT COMMANDS",oPC, FALSE);
    SendMessageToPC(oPC, PINK+"DM's have all of the above commands available to them,"
                    +" in addition to the following which are DM only:");
    SendMessageToPC(oPC, YELLOW+"/wipecdkeys "+PINK+"Wipe cdkey-playername associations. After the command type the player name.");
    SendMessageToPC(oPC, " ");
  }
}

string AlterSpeach(string sText, object oTarget, int nVolume, object oPC, int nAlt)
{
    if(nAlt==1)
    {
        // remove spoken words
        sText   = TranslateToLanguage(sText, oTarget, nVolume, oTarget, LANG_SILENCE);
    }
    else if(nAlt==2)
    {
        // convert to animal noise language
        sText   = TranslateToLanguage(sText, oTarget, nVolume, oPC, LANG_ANIMAL);
    }
    else if(nAlt==3)
    {
        // convert to lycanthropic growling
        SendMessageToPC(oPC," ");
        SendMessageToPC(oPC,PINK+"Communication is difficult.");
        SendMessageToPC(oPC," ");
        string sLCChat  = GetStringLowerCase(sText);
        string sGrowl = "grrr";
        int nHelp, nSorry, nRun, nDie, nNext;
        nHelp   = FindSubString(sLCChat, "help");
        nSorry  = FindSubString(sLCChat, "sorry");
        nRun    = FindSubString(sLCChat, "run");
        nDie    = FindSubString(sLCChat, "die");

        if(d4()==1)
            sGrowl += "RRRrrr";
        if(nDie>8)
        {
            if(nNext<nDie)
                nNext = 3;
            sGrowl += GetSubString(sLCChat,nDie-8,nDie+2)+"rrr";
        }
        if(d4()==1)
            sGrowl += "RRRrrr";
        if(nHelp!=-1)
        {
            nNext   = FindSubString(sLCChat," ",nHelp+5)-nHelp;
            if(nNext<nHelp)
                nNext = 4;
            sGrowl += GetSubString(sLCChat,nHelp,nNext)+"rrr";
        }
        if(d4()==1)
            sGrowl += "RRRrrr";
        if(nSorry!=-1)
        {
            nNext   = FindSubString(sLCChat," ",nSorry+6)-nSorry;
            if(nNext<nSorry)
                nNext = 5;
            sGrowl += GetSubString(sLCChat,nSorry,nNext)+"rrr";
        }
        if(d4()==1)
            sGrowl += "RRRrrr";
        if(nRun!=-1)
        {
            nNext   = FindSubString(sLCChat," ",nRun+4)-nRun;
            if(nNext<nRun)
                nNext = 3;
            sGrowl += GetSubString(sLCChat,nRun,nNext)+"rrr";
        }
        if(d4()==1)
            sGrowl += "RRRrrr";
        if(nDie!=-1)
        {
            nNext   = FindSubString(sLCChat," ",nDie+3)-nDie;
            if(nNext<nDie)
                nNext = 3;
            sGrowl += GetSubString(sLCChat,nDie,nNext)+"rrr";
        }
        if(d4()==1)
            sGrowl += "RRRrrr";

        sGrowl += "!";
        sText = sGrowl;
    }
    else if(nAlt==4)
    {
        // handle scry state
        object oPCCopy = GetLocalObject(oPC, "SCRY_COPY");
        AssignCommand(oPCCopy, SpeakString(sText, nVolume));

        if(!GetLocalInt(oPC, "SCRY_SPEAK"))
        {
            sText = "";
        }
        else
        {
            // strip emotes
            string sReply, sChar;
            string sPhrase = sText;
            int iToggle;
            int nPos1, nPos2, nLen;
            while (sPhrase=="")
            {
                nPos1   = FindSubString(sPhrase, "*");
                if (nPos1!=-1)
                {
                    nPos2   = FindSubString(sPhrase, "*", nPos1+1);
                    if(nPos2!=-1)
                    {
                        nLen     = GetStringLength(sPhrase);
                        sReply  += GetStringLeft(sPhrase, nPos1)+" ";
                        sPhrase  = GetStringRight(sPhrase, nLen-(nPos2+1));
                    }
                    else
                    {
                        // END;
                        sReply  += GetStringLeft(sPhrase, nPos1);
                        sPhrase = "";
                    }
                }
                else
                {
                    // END
                    sReply += sPhrase;
                    sPhrase = "";
                }
            }
            sText = TranslateToLanguage("*disembodied* "+sReply, oTarget, nVolume, oPC);
        }
    }
    else if(nAlt==5)
    {
        // convert to lycanthropic growling
        SendMessageToPC(oPC," ");
        SendMessageToPC(oPC,PINK+"Communication is difficult underwater.");
        SendMessageToPC(oPC," ");
        // convert to underwater blubbing
        sText   = TranslateToLanguage(sText, oTarget, nVolume, oPC, LANG_UNDERWATER);
    }
    else if(!nAlt)
    {
        // error
    }

    return sText;
}

/////////////////////////[MAIN]/////////////////////////////////////////////////
void main()
{
    object oPC      = GetPCChatSpeaker();
    if(!GetIsObjectValid(oPC)){return;}     // Catch exceptions

    int bDMPossessed= GetIsDMPossessed(oPC);
    int bDM         = GetIsDM(oPC);
    object oMaster  = GetMaster(oPC);
    if(!GetIsObjectValid(oMaster))
        oMaster     = oPC;
    if(bDMPossessed)
    {
        TrackDMPossession(oMaster, oPC);
    }

    int bRecordChat = GetLocalInt(oPC, "RECORD_CHAT"); // record this chat and do nothing else
    int nAltSpeech; // altered speach?
    int nLang;  // language spoken
    object oTarget  = GetLocalObject(oPC, "LYCANTHROPY_BEAST"); // if valid beast-form is speaking
    int iTargetType = 0;
    int nVolume     = GetPCChatVolume();
    // Get Chat String
    string sChat    = GetPCChatMessage();
    // eat leading whitespace
    /*
    while (GetStringLeft(sChat, 1) == " ")
        sChat = GetStringRight(sChat, GetStringLength(sChat)-1);
    */
    // store chat string for AID's last command function
    string sLastChat= sChat;
    // Set Chat String lower case
    string sLCChat  = GetStringLowerCase(sChat);
    // leading command character
    string sKey     = GetStringLeft(sLCChat, 1);

    // Chat text was changed
    int bChangedText= FALSE;
    int bLastCommand= FALSE;
    int bTranslate  = FALSE;
    string sTranslation;
    
    // DBG commands  "#dbg ..." 
    // See if the debug code wants it
    if (ExecuteScriptAndReturnInt("tb_dbg_pcchat", OBJECT_SELF)) {
        return;
    }
 
    // See if the tailor code wants it
    if (ExecuteScriptAndReturnInt("tlr_pc_chat", OBJECT_SELF)) {
        return;
    }


    //Madrabbits Chatcommands
    // TODO - this should return if took care of the command. 
    // also. these use / too.  That will keep us from running extra code below.
    // Or just run the commands in the hillsedge section below. 
    //MRPlayerChat();

    // COMMAND CHARACTERS INCLUDE:
    //  /       = VIVES commands
    //  *       = chat text enclosed by * indicates an emote and/or AID command
    //  >mem    = AID store last chat in memory slot by index
    //  <       = AID speak last chat
    //  :       = DMFI indicate voice target as last designated target
    //  ;       = DMFI indicate voice target - master / animal companion / familiar / henchman / summon
    //  ,       = DMFI indicate voice target - summon / henchman / familiar / animal companion / master

    // unused
    //  [       = DMFI speak in alternate language
    //  @       = AID DM commands
    //  #       = AID Debugging commands
    //  .       = DMFI command to execute

    // Records chat to local string. Garbage collection will need to be handled elsewhere.
    if(bRecordChat)
    {
        SetLocalString(oPC, "CHAT_RECORDED", sChat);
        if(bRecordChat==2)
        {
            SendMessageToPC(oPC, YELLOWSERV+"<Recorded>: "+WHITE+sChat);
            SetPCChatMessage("");
            return;
        }
    }

    // DMFI Voice Targets ------------------------------------------------------
    if(sKey==":")
    {
        if(bDM || bDMPossessed)
        {
            iTargetType = 1;
            oTarget     = GetLocalObject(oMaster, "dmfi_VoiceTarget");
        }
        else
        {
            iTargetType = -1;
            oTarget     = OBJECT_INVALID;
        }
    }
    else if(GetIsObjectValid(GetLocalObject(oMaster, sKey)))
    {
        if(bDM || bDMPossessed)
        {
            iTargetType = 1;
            oTarget     = GetLocalObject(oMaster, sKey);
        }
        else
        {
            iTargetType = -1;
            oTarget     = OBJECT_INVALID;
        }
    }
    else if(sKey == ";")
    {
        // master / animal companion / familiar / henchman / summon
        iTargetType = 2;
        oTarget = oMaster;
        if(!GetIsObjectValid(oTarget))
        {
            oTarget = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
            if(!GetIsObjectValid(oTarget))
            {
                oTarget = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                if(!GetIsObjectValid(oTarget))
                {
                    oTarget = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC);
                    if(!GetIsObjectValid(oTarget))
                        oTarget = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                }
            }
        }
    }
    else if(sKey == ",")
    {
        // summon / henchman / familiar / animal companion / master
        iTargetType = 3;
        oTarget = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
        if (!GetIsObjectValid(oTarget))
        {
            oTarget = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC);
            if (!GetIsObjectValid(oTarget))
            {
                oTarget = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                if (!GetIsObjectValid(oTarget))
                {
                    oTarget = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                    if (!GetIsObjectValid(oTarget))
                        oTarget = oMaster;
                }
            }
        }
    }

    if(oTarget==OBJECT_INVALID)
        oTarget = oPC; // untargeted chat applies to self

    if(iTargetType)
    {
        // eat the targeting character
        sChat       = GetStringRight(sChat, GetStringLength(sChat)-1);
        while (GetStringLeft(sChat, 1) == " ")
            sChat = GetStringRight(sChat, GetStringLength(sChat)-1);
        // update chat strings
        sLCChat     = GetStringLowerCase(sChat);
        sLastChat   = sChat;
        sKey        = GetStringLeft(sChat, 1);
    }

    // END DMFI Voice Targets --------------------------------------------------

    // Recall last or saved speach ---------------------------------------------
    if (sKey == "<")
    {
        // last spoken
        if (GetStringLeft(sLCChat, 5) == "<last")
        {
            SendMessageToPC(oPC, YELLOWSERV+"<Using last chat>");
            sChat       = GetLocalString(oTarget, "LAST_CHAT");
            if(sChat=="")
                sChat   = GetLocalString(oPC, "LAST_CHAT");
            sLastChat   = sChat;
            sLCChat     = GetStringLowerCase(sChat);
            sKey        = GetStringLeft(sLCChat, 1);
            bLastCommand= TRUE;
        }
        // mem slot
        else if (GetStringLeft(sLCChat, 4) == "<mem")
        {
            string sMemPos = GetSubString(sLCChat, 4, 1);
            SendMessageToPC(oPC, YELLOWSERV+"<Using chat slot #"+sMemPos+">");
            sChat       = GetSkinString(oPC, "aid_memory_"+sMemPos);
            sLastChat   = sChat;
            sLCChat     = GetStringLowerCase(sChat);
            sKey        = GetStringLeft(sLCChat, 1);
            bLastCommand= TRUE;
        }
        else
        {
            bFail   = TRUE;
            SendMessageToPC(oPC," ");
            SendMessageToPC(oPC,RED+"FAIL: "+YELLOW+sChat);
            SendMessageToPC(oPC,PINK+"The commands "+YELLOW+"<last"+PINK+" or "+YELLOW+"<mem"+PINK
                    +" are the commands which begin with the "+YELLOW+"<"+PINK+" key,"
                    +" and thus retrieve recorded chat strings. "
                    +YELLOW+"<mem"+PINK+" should be followed by a single character"
                    +" to identify which chat memory slot you wish to repeat."
                    +PINK+"Enter the command "+YELLOW+"/help"+PINK+" for more information."
                );
            SendMessageToPC(oPC," ");
            bChangedText = 1;
            sChat="";
        }
    }
    // END recall last or saved speech -----------------------------------------

    if(sKey == "/") // HILL's EDGE COMMANDS -----------------------------------
    {
        string sCommand = GetCommand(sLCChat);
        string sLeft    = GetStringLeft(sCommand,4);
        if (sCommand == "dispel")
            DoDispel(sLCChat, oTarget);
        //else if (sCommand == "addcdkey")
        //    NWNX_SetAddCDKey(oPC);
        //else if (sCommand == "wipecdkeys")
        //    DoWipeCDKey(sLCChat, oPC);
        //else if (sCommand == "track")
        //    AssignCommand(oTarget, ActionCastSpellAtLocation(SPELL_ACT_TRACK, GetLocation(oTarget)) );
        else if (sLeft == "styl")
            DoStyle(sLCChat, oTarget);
        // AID - DM commands debug mode
        else if(sCommand == "aid" && (bDM || bDMPossessed || MODULE_DEBUG_MODE)) // AID DM Commands ---------
            DoAIDCommand(sLCChat, oTarget);
        else if (sLeft == "help")
            DoHelp(sLCChat, oPC);
        else if (sLeft == "item")
            DoItem(sLCChat, oTarget);
        else if (sLeft == "loun")
            ExecuteScript(PREFIX+"pclounge",oPC);
        else if (sLeft == "pcli")
            DoListPCs(oPC);
        else if (sLeft == "lang")
            DoLanguages(sLCChat, oTarget);
        else if (sLeft == "pray") {
                SetLocalInt(oPC, "deity_tmp_op", 5);
                ExecuteScript("deity_do_op", oPC); 
        }
        else if (sLeft == "hug") {
		ExecuteScript("com_s_hug", oPC)  ;
        } else if (sLeft == "dsc") {
                ExecuteScript("com_s_dsc", oPC) ;
        } else if (sLeft == "tch") {
               ExecuteScript("com_s_tch", oPC)  ;
        } else if (sCommand == "set" && (bDM || bDMPossessed || MODULE_DEBUG_MODE))
            SetChatTarget(sLCChat, oPC, oTarget);
        else
            bFail = TRUE;
        /*
        if (sKey == ".")
        {
            bChangedText = 1;
            if (oTarget == OBJECT_INVALID)
            {
                // 2008.05.29 tsunami282 - no target set, so dot command uses DMFI targeting wand
                oTarget = GetLocalObject(oPC, "dmfi_univ_target");
                if(oTarget==OBJECT_INVALID)
                    oTarget = GetLocalObject(oPC, "dmfi_VoiceTarget");
            }

            if (GetIsObjectValid(oTarget))
            {
                ParseCommand(oTarget, oPC, sLCChat);
                sChat = "";
            }
            else
            {
                // target invalid
                bChangedText = 1;
                SendMessageToPC(oPC, RED+"Command not processed due to lack of a target."
                    +" To specify a target use the DM Wand or Voice Widget on a target"
                    +" OR precede your command with a voice target key such as "+YELLOW+":"+RED+"."
                    +" Example: "+YELLOW+": .set #"+RED+" would apply the custom"
                    +" voice target key "+YELLOW+"#"+RED+" to your current voice target."
                  );
                sChat = "";
            }
        }
        */

        if(bFail)
        {
            SendMessageToPC(oPC," ");
            SendMessageToPC(oPC,RED+"COMMAND FAILED: "+YELLOW+"/"+sCommand);
            if(sErr=="")
                SendMessageToPC(oPC,PINK+"The command "+YELLOW+"/help"+PINK+" will display a list of commands available to you.");
            else
                SendMessageToPC(oPC,sErr);
            SendMessageToPC(oPC," ");
            bChangedText = 1;
            sChat="";
        }
        nVolume = TALKVOLUME_TELL;

    }
    // commit to memory
    else if(sKey == ">")// AID Memory Slot Commands -------------------------
    {
        nVolume = TALKVOLUME_TELL;
        if(GetStringLeft(sLCChat, 4) == ">mem")
        {
            string sMemPos = GetSubString(sLCChat, 4, 1);
            SendMessageToPC(oPC, sMemPos);
            SetSkinString(oPC, "aid_memory_" + sMemPos, GetLocalString(oPC, "LAST_CHAT"));
        }
    }
    else if(!bFail)
    {
            nAltSpeech  = GetCanNotSpeak(oTarget);
            nLang       = GetCurrentLanguageSpoken(oTarget);
            // alter the speech to deal with beast forms and polymorphs and familiars etc...
            // some alt speach forms wipe out emotes
            if(nAltSpeech)
            {
                bChangedText    = 1;
                bTranslate      = TRUE;
                sTranslation    = sChat;
                sChat           = AlterSpeach(sChat, oTarget, nVolume, oPC, nAltSpeech);
            }
            else if(nLang && nLang!=LANG_COMMON)
            {
                bChangedText    = 1;
                bTranslate      = TRUE;
                sTranslation    = sChat;
                sChat           = TranslateToLanguage(sChat, oTarget, nVolume, oPC);
            }

            // process emotes
            if(FindSubString(sChat, "*")!=-1)
                ParseEmote(sLastChat, oTarget);

            /*
            // AID - OnSecretWord --------------------------------------------------
            object oSWObject = SecretWord(oPC, sLCChat);
            if (oSWObject != OBJECT_INVALID)
                OnSecretWord(oSWObject, oPC);
            */
    }

    if (sChat != "")
    {
        string sColor;
        string sTell;
        if(nVolume==TALKVOLUME_WHISPER)
            sColor  = GREY;
        else if(nVolume==TALKVOLUME_TALK || nVolume==TALKVOLUME_PARTY)
            sColor  = WHITE;
        else if(nVolume==TALKVOLUME_TELL)
        {
            sColor  = NEONGREEN;
            sTell = "TELL ";
        }
        object oArea;
        location lLoc;
        string sNameArea;
        string sNamePC  = GetName(oPC);
        string sNameTar = GetName(oTarget);
        string sNameLan = GetLanguageName(nLang);
        string sLogChat;
        string sDMMsg;

        // target was changed from speaker
        if (iTargetType>0)
        {
            oArea    = GetArea(oTarget);
            lLoc     = GetLocation(oTarget);
            sNameArea= GetName(oArea);

            // Message
            if(!bTranslate)
            {
                sDMMsg  = DMBLUE+ "[" +sNameArea+ "] " +sNameTar+ ": " +sColor+sChat;
                sLogChat= sTell+"[" +sNameArea+ "] " +sNamePC+ "(" +sNameTar+ ") : " +sChat;
            }
            else
            {
                sDMMsg  = DMBLUE+ "[" +sNameArea+ "] " +sNameTar+ ": ("+sNameLan+") " +sColor+sTranslation;
                sLogChat= sTell+"[" +sNameArea+ "] " +sNamePC+ "(" +sNameTar+ ") : ("+sNameLan+") " +sTranslation;
            }
            // throw the message
            if(nVolume!=TALKVOLUME_TELL)
            {
                AssignCommand(oTarget, SpeakString(sChat, nVolume));
                sChat = "";
            }
            else
                sChat = GetName(oTarget)+": "+sChat;

            bChangedText = 1;
        }
        else
        {
            oArea    = GetArea(oPC);
            lLoc     = GetLocation(oPC);
            sNameArea= GetName(oArea);

            // Message
            if(!bTranslate)
            {
                sDMMsg  = DMBLUE+ "[" +sNameArea+ "] " +sNamePC+ ": " +sColor+sChat;
                sLogChat= sTell+"["+sNameArea+"] " +sNamePC+": " + sChat;
            }
            else
            {
                sDMMsg  = DMBLUE+ "[" +sNameArea+ "] " +sNamePC+ ": ("+sNameLan+") " +sColor+sTranslation;
                sLogChat= sTell+"["+sNameArea+"] " +sNamePC+": ("+sNameLan+") " +sTranslation;
            }
        }

        WriteTimestampedLogEntry(sLogChat); // log what was said

        // SEND MESSAGE TO ALL DMs
        float fDistance  = 20.0f;
        if (nVolume == TALKVOLUME_WHISPER)
            fDistance    = 2.0f;

        object oEavesdrop  = GetFirstPC();
        object oFamiliar;
        while(GetIsObjectValid(oEavesdrop))
        {
          if(nVolume!=TALKVOLUME_TELL)
          {
            oFamiliar   = GetLocalObject(oEavesdrop, FAMILIAR);
            if(GetIsDM(oEavesdrop))
            {
                SendMessageToPC(oEavesdrop, sDMMsg);
                SendMessageToPC(GetLocalObject(oEavesdrop,"POSSESSED_CREATURE"), sDMMsg);
            }
            // attempt to get message to familiar
            else if(    GetIsPossessedFamiliar(oFamiliar)
                    &&  oArea==GetArea(oFamiliar)
                    &&  GetDistanceBetweenLocations(lLoc, GetLocation(oFamiliar))<=fDistance
                   )
            {
                if(nLang==LANG_THIEVESCANT && GetStringLength(sTranslation)>25)
                    sTranslation = GetStringLeft(sTranslation, 25);
                subTranslateToLanguage(sTranslation, oTarget, nVolume, oPC, nLang, sNameLan, oFamiliar);
            }
            // taken from DMFI translate
            else if(    bTranslate
                    &&( (       nVolume==TALKVOLUME_PARTY
                            &&  GetFactionEqual(oTarget,oEavesdrop)
                        )
                        ||
                        (       nVolume!=TALKVOLUME_PARTY
                            &&  oArea==GetArea(oEavesdrop)
                            &&  GetDistanceBetweenLocations(lLoc, GetLocation(oEavesdrop))<=fDistance
                        )
                      )
                   )
            {
                if(nLang==LANG_THIEVESCANT && GetStringLength(sTranslation)>25)
                    sTranslation = GetStringLeft(sTranslation, 25);
                subTranslateToLanguage(sTranslation, oTarget, nVolume, oPC, nLang, sNameLan, oEavesdrop);
            }
          }
          oEavesdrop = GetNextPC();
        }
    }

    if(sChat!="")
    {
        // timestamp player as having chat something (used in determining whether PC is roleplaying)
        SetLocalInt(OBJECT_SELF, "LAST_CHAT_TIME",GetTimeCumulative());
    }

    SetPCChatVolume(nVolume);
    if (bChangedText || bLastCommand)
        SetPCChatMessage(sChat);

    // AID Set lastchat (which is now the current chat) to this var to enable repeat last line util.
    if (sKey != "<" && sKey != ">")
        SetLocalString(oTarget, "LAST_CHAT", sLastChat);
}
