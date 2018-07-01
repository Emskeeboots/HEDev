//::///////////////////////////////////////////////
//:: _s2_playtool
//:://////////////////////////////////////////////
/*
    Player Tool

    makes use of the DMFI player tools.
    this associates use of class radial tools with particular DMFI tools
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 15)
//:: Modified:  Henesua (2014 may 30) added "looks around" and "like roleplay"
//:://////////////////////////////////////////////
//:: Modified:  Henesua (2016 jan 18) nwnx hook

#include "70_inc_spells"

#include "_inc_color"
#include "_inc_constants"
#include "_inc_util"

#include "aid_inc_fcns"

void main() {
     object oPC = OBJECT_SELF;
        
    //Declare major variables
    spellsDeclareMajorVariables();

    // Set up DMFI variables
    SetLocalObject(oPC, "dmfi_univ_target", oPC);
    SetLocalLocation(oPC, "dmfi_univ_location", spell.Loc);

    // Detemrine which Player Tool Feat was used
    int nSpellID        = GetSpellId();
    int nMinuteNow       = GetTimeCumulative();
  switch(nSpellID)
  {
    // PLAYER_DICE
    case 831:
        SetLocalString(oPC, "dmfi_univ_conv", "pc_dicebag");
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionStartConversation(oPC, "dmfi_universal", TRUE));
    break;
    // PLAYER_EMOTE
    case 832:
        SetLocalString(oPC, "dmfi_univ_conv", "pc_emote");
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionStartConversation(oPC, "dmfi_universal", TRUE));
    break;
    // PLAYER_AUTOFOLLOW
    case 833:
        SendMessageToPC(oPC, " ");
        FloatingTextStringOnCreature(DMBLUE+"Now following "+ GetName(spell.Target) +".",oPC, FALSE);
        DelayCommand(2.0f, AssignCommand(oPC, ActionForceFollowObject(spell.Target, 2.0f)));
    break;
    // PLAYER_SUBDUALDAMAGE
    case 834:
        if(GetLocalInt(oPC, "COMBAT_NONLETHAL"))
        {
            SetLocalInt(oPC, "COMBAT_NONLETHAL", FALSE);
            SendMessageToPC(oPC, " ");
            FloatingTextStringOnCreature(DMBLUE+"Subdual damage: "+CYAN+"OFF",oPC, FALSE);
        }
        else
        {
            SetLocalInt(oPC, "COMBAT_NONLETHAL", TRUE);
            SendMessageToPC(oPC, " ");
            FloatingTextStringOnCreature(DMBLUE+"Subdual damage: "+CYAN+"ON",oPC, FALSE);
            SendMessageToPC(oPC, DMBLUE+"The damage you cause will incapacitate rather than kill another PC or NPC.");
        }
    break;
    // PLAYER_LOOKS_AROUND
    case 836:
        SpeakString("*looks around*");
        DoLookAround(oPC,TRUE);
    break;
    // PLAYER_LIKES_ROLEPLAY
    case 837:
        // keep count of how many times each player uses the tool
        // TODO - could put this in the main table so we can see from the sql db (outside of game)
        SetPersistentInt(oPC, "PCLIKESROLEPLAY_USES", GetPersistentInt(oPC, "PCLIKESROLEPLAY_USES") + 1);

        // targetting self?
        if(spell.Target==oPC)
        {
            SendMessageToPC(oPC,
                            DMBLUE+"Target another player to like their roleplay."
                            +" They will be given anonymous positive reinforcement."
                            +" However you will not benefit from patting yourself on the back"
                            +" other than to be granted the opportunity to read this brilliantly"
                            +" written documentation."
                           );
        }
        // targetting another PC?
        else if(GetIsPC(spell.Target))
        {
            // DM exclusion.....................................................
            if(GetIsDM(spell.Target))
            {
                // let the Targeted PC know once every minute or so
                if( !GetLocalInt(spell.Target, "PC_RP_FEEDBACK_TIME")
                    || GetLocalInt(spell.Target, "PC_RP_FEEDBACK_TIME")+3<nMinuteNow
                  )
                {
                    SetLocalInt(spell.Target, "PC_RP_FEEDBACK_TIME",nMinuteNow);
                    SendMessageToPC(spell.Target, DMBLUE+"Someone likes your roleplaying.");
                }
            }
            // have they chat anything in the last 2 real minutes?
            else if(GetLocalInt(spell.Target, "LAST_CHAT_TIME")+(GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE")*2)>=nMinuteNow)
            {
                // let the Targeted PC know once every minute or so
                if( !GetLocalInt(spell.Target, "PC_RP_FEEDBACK_TIME")
                    || GetLocalInt(spell.Target, "PC_RP_FEEDBACK_TIME")+3<nMinuteNow
                  )
                {
                    SetLocalInt(spell.Target, "PC_RP_FEEDBACK_TIME",nMinuteNow);
                    SendMessageToPC(spell.Target, DMBLUE+"Someone likes your roleplaying.");
                }
                // nothing else counts when out of character
                if(IsOOC(oPC))
                    return;

                // track total votes for this player
                SetPersistentInt(spell.Target, "PCLIKESROLEPLAY_LIKES_RECEIVED", 
                        GetPersistentInt(spell.Target, "PCLIKESROLEPLAY_LIKES_RECEIVED") + 1);
                PCLikesTargetsRP(spell.Target);
            }
            else
            {
                // meaningless award... we might want to track PCs that hand these out
            }
        }
        // not targetting a creature?
        else if(GetObjectType(spell.Target)!=OBJECT_TYPE_CREATURE)
        {
            SendMessageToPC(oPC,
                            DMBLUE+"Target another player to like their roleplay."
                            +" They will be given anonymous positive reinforcement."
                            +VIOLET+" Your current target is not even a creature let alone a player."
                           );
        }
    break;
    // PLAYER_OOC_LOUNGE
    case 839:
        ExecuteScript("do_pclounge",oPC);
    break;
    default:
    break;
  }
}
