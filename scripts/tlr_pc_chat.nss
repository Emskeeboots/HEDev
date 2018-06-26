// tlr_pc_chat

#include "x2_inc_switches"
#include "tlr_inc_utils"

void main(){
        object oPC = GetPCChatSpeaker();
        string sChat = GetPCChatMessage();

        int nRes = tlrDoPCChat(oPC, sChat);
        if (nRes) {
                SetPCChatMessage("");       // Change the text of the chat.
                SetPCChatVolume(TALKVOLUME_TELL); // make only the speaking PC see it
                SetExecutedScriptReturnValue(TRUE); // EXECUTE_SCRIPT_END
        }
}
